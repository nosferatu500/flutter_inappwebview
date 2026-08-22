package dev.nosferatu500.inappwebview.webview.web_message

import android.net.Uri
import android.text.TextUtils
import android.webkit.WebView
import androidx.webkit.JavaScriptReplyProxy
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.PluginScript
import dev.nosferatu500.inappwebview.types.UserScriptInjectionTime
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
//
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
@Suppress("UNCHECKED_CAST")
class WebMessageListener(
  @JvmField var id: String,
  webView: InAppWebViewInterface,
  messenger: BinaryMessenger,
  @JvmField var jsObjectName: String,
  @JvmField var allowedOriginRules: Set<String>
) : Disposable {

  @JvmField
  var listener: WebViewCompat.WebMessageListener? = null

  @JvmField
  var replyProxy: JavaScriptReplyProxy? = null

  @JvmField
  var webView: InAppWebViewInterface? = webView

  @JvmField
  var channelDelegate: WebMessageListenerChannelDelegate?

  init {
    val channel = MethodChannel(
      messenger, METHOD_CHANNEL_NAME_PREFIX + id + "_" + jsObjectName
    )
    channelDelegate = WebMessageListenerChannelDelegate(this, channel)

    if (webView is InAppWebView) {
      listener = WebViewCompat.WebMessageListener {
          _: WebView,
          message: WebMessageCompat,
          sourceOrigin: Uri,
          isMainFrame: Boolean,
          javaScriptReplyProxy: JavaScriptReplyProxy
        ->
        replyProxy = javaScriptReplyProxy
        channelDelegate?.onPostMessage(
          WebMessageCompatExt.fromMapWebMessageCompat(message),
          if (sourceOrigin.toString() == "null") null else sourceOrigin.toString(),
          isMainFrame
        )
      }
    }
  }

  fun initJsInstance() {
    val view = webView ?: return
    val jsObjectNameEscaped = Util.replaceAll(jsObjectName, "'", "\\'")
    val allowedOriginRulesStringList = mutableListOf<String>()
    for (allowedOriginRule in allowedOriginRules) {
      if ("*" == allowedOriginRule) {
        allowedOriginRulesStringList.add("'*'")
      } else {
        val rule = Uri.parse(allowedOriginRule)
        val ruleHost = rule.host
        val host = if (ruleHost != null) {
          "'" + Util.replaceAll(ruleHost, "'", "\\'") + "'"
        } else {
          "null"
        }
        allowedOriginRulesStringList.add(
          "{scheme: '" + rule.scheme + "', host: " + host + ", port: " +
            (if (rule.port != -1) rule.port else "null") + "}"
        )
      }
    }
    val allowedOriginRulesString = TextUtils.join(", ", allowedOriginRulesStringList)

    val source = "(function() {" +
      "  var allowedOriginRules = [" + allowedOriginRulesString + "];" +
      "  var isPageBlank = window.location.href === 'about:blank';" +
      "  var scheme = !isPageBlank ? window.location.protocol.replace(':', '') : null;" +
      "  var host = !isPageBlank ? window.location.hostname : null;" +
      "  var port = !isPageBlank ? window.location.port : null;" +
      "  if (window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
      "._isOriginAllowed(allowedOriginRules, scheme, host, port)) {" +
      "      window['" + jsObjectNameEscaped +
      "'] = new FlutterInAppWebViewWebMessageListener('" + jsObjectNameEscaped + "');" +
      "  }" +
      "})();"
    view.getUserContentController().addPluginScript(
      PluginScript(
        "WebMessageListener-$jsObjectName",
        source,
        UserScriptInjectionTime.AT_DOCUMENT_START,
        null,
        false,
        view.getCustomSettings().pluginScriptsOriginAllowList,
        view.getCustomSettings().pluginScriptsForMainFrameOnly
      )
    )
  }

  @Throws(Exception::class)
  fun assertOriginRulesValid() {
    var index = 0
    for (originRule in allowedOriginRules) {
      if (originRule.isEmpty()) {
        throw Exception("allowedOriginRules[$index] is empty")
      }
      if ("*" == originRule) {
        continue
      }
      val url = Uri.parse(originRule)
      val scheme = url.scheme
      val host = url.host
      val path = url.path
      val port = url.port
      if (scheme == null) {
        throw Exception("allowedOriginRules $originRule is invalid")
      }
      if (("http" == scheme || "https" == scheme) && host.isNullOrEmpty()) {
        throw Exception("allowedOriginRules $originRule is invalid")
      }
      if ("http" != scheme && "https" != scheme && (host != null || port != -1)) {
        throw Exception("allowedOriginRules $originRule is invalid")
      }
      if (host.isNullOrEmpty() && port != -1) {
        throw Exception("allowedOriginRules $originRule is invalid")
      }
      if (!path.isNullOrEmpty()) {
        throw Exception("allowedOriginRules $originRule is invalid")
      }
      if (host != null) {
        val distance = host.indexOf("*")
        if (distance != 0 || !host.startsWith("*.")) {
          throw Exception("allowedOriginRules $originRule is invalid")
        }
        if (host.startsWith("[")) {
          if (!host.endsWith("]")) {
            throw Exception("allowedOriginRules $originRule is invalid")
          }
          val ipv6 = host.substring(1, host.length - 1)
          if (!Util.isIPv6(ipv6)) {
            throw Exception("allowedOriginRules $originRule is invalid")
          }
        }
      }
      index++
    }
  }

  fun postMessageForInAppWebView(message: WebMessageCompatExt, result: MethodChannel.Result) {
    val proxy = replyProxy
    if (proxy != null && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
      val data = message.data
      if (data != null) {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
          message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
        ) {
          proxy.postMessage(data as ByteArray)
        } else {
          proxy.postMessage(data.toString())
        }
      }
    }
    result.success(true)
  }

  fun isOriginAllowed(scheme: String?, host: String?, port: Int): Boolean {
    for (allowedOriginRule in allowedOriginRules) {
      if ("*" == allowedOriginRule) {
        return true
      }
      if (scheme.isNullOrEmpty()) {
        continue
      }
      val rule = Uri.parse(allowedOriginRule)
      val rulePort = if (rule.port == -1 || rule.port == 0) {
        if ("https" == rule.scheme) 443 else 80
      } else {
        rule.port
      }
      val currentPort = if (port == 0 || port == -1) {
        if ("https" == scheme) 443 else 80
      } else {
        port
      }
      var iPv6: String? = null
      val ruleHost = rule.host
      if (ruleHost != null && ruleHost.startsWith("[")) {
        try {
          iPv6 = Util.normalizeIPv6(ruleHost.substring(1, ruleHost.length - 1))
        } catch (ignored: Exception) {
        }
      }
      var hostIPv6: String? = null
      try {
        hostIPv6 = Util.normalizeIPv6(host!!)
      } catch (ignored: Exception) {
      }

      val schemeAllowed = rule.scheme == scheme

      val hostAllowed = ruleHost == null ||
        ruleHost.isEmpty() ||
        ruleHost == host ||
        (
          ruleHost.startsWith("*") && host != null &&
            host.contains(ruleHost.split("\\*".toRegex())[1])
          ) ||
        (hostIPv6 != null && iPv6 != null && hostIPv6 == iPv6)

      val portAllowed = rulePort == currentPort

      if (schemeAllowed && hostAllowed && portAllowed) {
        return true
      }
    }
    return false
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    listener = null
    replyProxy = null
    webView = null
  }

  companion object {
    protected const val LOG_TAG = "WebMessageListener"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_web_message_listener_"

    @JvmStatic
    fun fromMap(
      webView: InAppWebViewInterface,
      messenger: BinaryMessenger,
      map: Map<String, Any?>?
    ): WebMessageListener? {
      if (map == null) {
        return null
      }
      val id = map["id"] as String
      val jsObjectName = map["jsObjectName"] as String
      val allowedOriginRuleList = map["allowedOriginRules"] as List<String>
      return WebMessageListener(
        id, webView, messenger, jsObjectName, HashSet(allowedOriginRuleList)
      )
    }
  }
}
