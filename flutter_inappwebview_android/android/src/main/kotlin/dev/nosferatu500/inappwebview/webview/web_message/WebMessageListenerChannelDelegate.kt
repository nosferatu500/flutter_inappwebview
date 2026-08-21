package dev.nosferatu500.inappwebview.webview.web_message

import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class WebMessageListenerChannelDelegate(
  webMessageListener: WebMessageListener,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var webMessageListener: WebMessageListener? = webMessageListener

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val listener = webMessageListener

    when (call.method) {
      "postMessage" -> {
        if (listener != null && listener.webView is InAppWebView) {
          val message = WebMessageCompatExt.fromMap(
            call.argument<Map<String, Any?>>("message")
          )!!
          listener.postMessageForInAppWebView(message, result)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onPostMessage(message: WebMessageCompatExt?, sourceOrigin: String?, isMainFrame: Boolean) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onPostMessage",
      hashMapOf<String, Any?>(
        "message" to message?.toMap(),
        "sourceOrigin" to sourceOrigin,
        "isMainFrame" to isMainFrame
      )
    )
  }

  override fun dispose() {
    super.dispose()
    webMessageListener = null
  }
}
