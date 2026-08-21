package dev.nosferatu500.inappwebview.webview

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Message
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class InAppWebViewManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  // Values go null rather than being removed: disposeKeepAlive() nulls the slot so the id stays
  // known.
  @JvmField
  val keepAliveWebViews: MutableMap<String, FlutterWebView?> = HashMap()

  @JvmField
  val windowWebViewMessages: MutableMap<Int, Message> = HashMap()

  @JvmField
  var windowAutoincrementId = 0

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getDefaultUserAgent" -> {
        val currentPlugin = plugin
        if (currentPlugin != null) {
          result.success(WebSettings.getDefaultUserAgent(currentPlugin.applicationContext))
        } else {
          result.success(null)
        }
      }

      "clearClientCertPreferences" -> WebView.clearClientCertPreferences { result.success(true) }

      "getSafeBrowsingPrivacyPolicyUrl" -> {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL)) {
          result.success(WebViewCompat.getSafeBrowsingPrivacyPolicyUrl().toString())
        } else {
          result.success(null)
        }
      }

      "setSafeBrowsingAllowlist" -> {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ALLOWLIST)) {
          val hosts = HashSet(call.argument<List<String>>("hosts")!!)
          WebViewCompat.setSafeBrowsingAllowlist(hosts) { value -> result.success(value) }
        } else {
          result.success(false)
        }
      }

      "getCurrentWebViewPackage" -> {
        val context = plugin?.let { it.activity ?: it.applicationContext }
        val packageInfo = context?.let { WebViewCompat.getCurrentWebViewPackage(it) }
        result.success(packageInfo?.let { convertWebViewPackageToMap(it) })
      }

      "setWebContentsDebuggingEnabled" -> {
        WebView.setWebContentsDebuggingEnabled(call.argument<Boolean>("debuggingEnabled")!!)
        result.success(true)
      }

      "getVariationsHeader" -> {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_VARIATIONS_HEADER)) {
          result.success(WebViewCompat.getVariationsHeader())
        } else {
          result.success(null)
        }
      }

      "isMultiProcessEnabled" -> {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROCESS)) {
          result.success(WebViewCompat.isMultiProcessEnabled())
        } else {
          result.success(false)
        }
      }

      "disableWebView" -> {
        WebView.disableWebView()
        result.success(true)
      }

      "disposeKeepAlive" -> {
        call.argument<String>("keepAliveId")?.let { disposeKeepAlive(it) }
        result.success(true)
      }

      "clearAllCache" -> {
        val context = plugin?.let { it.activity ?: it.applicationContext }
        if (context != null) {
          clearAllCache(context, call.argument<Boolean>("includeDiskFiles")!!)
        }
        result.success(true)
      }

      "enableSlowWholeDocumentDraw" -> {
        WebView.enableSlowWholeDocumentDraw()
        result.success(true)
      }

      "setJavaScriptBridgeName" -> {
        JavaScriptBridgeJS.set_JAVASCRIPT_BRIDGE_NAME(call.argument("bridgeName")!!)
        result.success(true)
      }

      "getJavaScriptBridgeName" ->
        result.success(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())

      else -> result.notImplemented()
    }
  }

  fun convertWebViewPackageToMap(webViewPackageInfo: PackageInfo): Map<String, Any?> = hashMapOf(
    "versionName" to webViewPackageInfo.versionName,
    "packageName" to webViewPackageInfo.packageName
  )

  fun disposeKeepAlive(keepAliveId: String) {
    val flutterWebView = keepAliveWebViews[keepAliveId]
    if (flutterWebView != null) {
      flutterWebView.keepAliveId = null
      // be sure to remove the view from the previous parent.
      val view = flutterWebView.getView()
      (view?.parent as ViewGroup?)?.removeView(view)
      flutterWebView.dispose()
    }
    if (keepAliveWebViews.containsKey(keepAliveId)) {
      keepAliveWebViews[keepAliveId] = null
    }
  }

  fun clearAllCache(context: Context, includeDiskFiles: Boolean) {
    val tempWebView = WebView(context)
    tempWebView.clearCache(includeDiskFiles)
    tempWebView.destroy()
  }

  override fun dispose() {
    super.dispose()
    for (flutterWebView in keepAliveWebViews.values.toList()) {
      flutterWebView?.keepAliveId?.let { disposeKeepAlive(it) }
    }
    keepAliveWebViews.clear()
    windowWebViewMessages.clear()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "InAppWebViewManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_manager"
  }
}
