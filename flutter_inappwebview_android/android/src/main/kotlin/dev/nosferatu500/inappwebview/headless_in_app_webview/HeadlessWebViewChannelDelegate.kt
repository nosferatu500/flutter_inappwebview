package dev.nosferatu500.inappwebview.headless_in_app_webview

import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.Size2D
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class HeadlessWebViewChannelDelegate(
  headlessWebView: HeadlessInAppWebView,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var headlessWebView: HeadlessInAppWebView? = headlessWebView

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val webView = headlessWebView

    when (call.method) {
      "dispose" -> {
        if (webView != null) {
          webView.dispose()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "setSize" -> {
        if (webView != null) {
          Size2D.fromMap(call.argument<Map<String, Any?>>("size"))?.let { webView.setSize(it) }
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "getSize" -> {
        if (webView != null) {
          result.success(webView.getSize()?.toMap())
        } else {
          result.success(null)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onWebViewCreated() {
    val channel = this.channel ?: return
    channel.invokeMethod("onWebViewCreated", hashMapOf<String, Any?>())
  }

  override fun dispose() {
    super.dispose()
    headlessWebView = null
  }
}
