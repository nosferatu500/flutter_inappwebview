package dev.nosferatu500.inappwebview.webview.web_message

import android.net.Uri
import android.webkit.WebView
import androidx.webkit.JavaScriptReplyProxy
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.WebMessageData
import dev.nosferatu500.inappwebview.pigeons.WebMessageListenerFlutterApi
import dev.nosferatu500.inappwebview.pigeons.WebMessageListenerHostApi
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([WebMessageListenerHostApi] / [WebMessageListenerFlutterApi])
 * rather than a hand-written `MethodChannel`; migrated in §165 together with [WebMessageChannel],
 * which shares its `WebMessageData` payload.
 *
 * `WebMessageListenerChannelDelegate` is folded in here, and the class-level
 * `@Suppress("UNCHECKED_CAST")` went with the `Map<String, Any?>` parse step it covered.
 *
 * **Per-instance channel**: the suffix is `<id>_<jsObjectName>`, matching the name the
 * hand-written channel built.
 */
// `this` is published to a platform-thread-only dispatcher during construction, as before.
class WebMessageListener(
  @JvmField var id: String,
  webView: InAppWebViewInterface,
  messenger: BinaryMessenger,
  @JvmField var jsObjectName: String,
  @JvmField var allowedOriginRules: Set<String>
) : Disposable, WebMessageListenerHostApi {

  @JvmField
  var listener: WebViewCompat.WebMessageListener? = null

  @JvmField
  var replyProxy: JavaScriptReplyProxy? = null

  @JvmField
  var webView: InAppWebViewInterface? = webView

  private var boundMessenger: BinaryMessenger? = messenger

  private var flutterApi: WebMessageListenerFlutterApi?

  init {
    val suffix = channelSuffix(id, jsObjectName)
    flutterApi = WebMessageListenerFlutterApi(messenger, suffix)
    WebMessageListenerHostApi.setUp(messenger, this, suffix)

    if (webView is InAppWebView) {
      listener = WebViewCompat.WebMessageListener {
          _: WebView,
          message: WebMessageCompat,
          sourceOrigin: Uri,
          isMainFrame: Boolean,
          javaScriptReplyProxy: JavaScriptReplyProxy
        ->
        replyProxy = javaScriptReplyProxy
        flutterApi?.onPostMessage(
          WebMessageCompatExt.fromMapWebMessageCompat(message).toPigeon(),
          if (sourceOrigin.toString() == "null") null else sourceOrigin.toString(),
          isMainFrame
        ) {}
      }
    }
  }

  /**
   * Always answers true when the view is an `InAppWebView`.
   *
   * The hand-written channel called `result.success(true)` unconditionally at the end -- including
   * when there was no reply proxy or `WEB_MESSAGE_LISTENER` was unsupported -- so true means "no
   * error", not "delivered". Preserved deliberately; see the schema.
   */
  override fun postMessage(message: WebMessageData): Boolean {
    if (webView !is InAppWebView) {
      return false
    }
    val proxy = replyProxy
    if (proxy != null && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
      val ext = WebMessageCompatExt.fromPigeon(message)
      val data = ext.data
      if (data != null) {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
          ext.type == WebMessageCompat.TYPE_ARRAY_BUFFER
        ) {
          // No cast: the schema carries array-buffer payloads as a real ByteArray.
          proxy.postMessage(data as ByteArray)
        } else {
          proxy.postMessage(data.toString())
        }
      }
    }
    return true
  }

  /**
   * Whether a page origin may reach this listener, per [allowedOriginRules].
   *
   * **Nothing in this module calls this**, and that is not an oversight worth relying on either
   * way. Android registers listeners through `WebViewCompat.addWebMessageListener`, which does the
   * origin matching inside the WebView, so this is the Kotlin half of a rule whose live copies are
   * iOS's `WebMessageListener.isOriginAllowed` and the JavaScript it injects. It is kept in step
   * with them — a fork that ships two spellings of one security rule has the worse of both — and
   * the wildcard half is unit-tested through [Util.hostMatchesWildcardRule].
   */
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
        Util.hostMatchesWildcardRule(ruleHost, host) ||
        (hostIPv6 != null && iPv6 != null && hostIPv6 == iPv6)

      val portAllowed = rulePort == currentPort

      if (schemeAllowed && hostAllowed && portAllowed) {
        return true
      }
    }
    return false
  }

  override fun dispose() {
    // Unregisters the generated handler for this suffix.
    boundMessenger?.let {
      WebMessageListenerHostApi.setUp(it, null, channelSuffix(id, jsObjectName))
    }
    boundMessenger = null
    flutterApi = null
    listener = null
    replyProxy = null
    webView = null
  }

  companion object {
    protected const val LOG_TAG = "WebMessageListener"

    /**
     * The `messageChannelSuffix` for a listener, matching the id the hand-written channel name
     * embedded. Built in one place so `init` and `dispose` cannot drift apart -- an unregister
     * against the wrong suffix silently leaves the handler bound.
     */
    @JvmStatic
    fun channelSuffix(id: String, jsObjectName: String): String = id + "_" + jsObjectName

    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_web_message_listener_"

    /**
     * Builds a listener from the untyped map the **WebView channel** still sends.
     *
     * The suppression is scoped to this function rather than the class: the Pigeon migration
     * removed every other cast site, and `addWebMessageListener` lives on
     * `WebViewChannelDelegate`, which is not migrated yet. When that channel moves, this and the
     * suppression go with it.
     */
    @Suppress("UNCHECKED_CAST")
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
