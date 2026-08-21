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
class WebMessageChannelChannelDelegate(
  webMessageChannel: WebMessageChannel,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var webMessageChannel: WebMessageChannel? = webMessageChannel

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val messageChannel = webMessageChannel
    val isInAppWebView = messageChannel?.webView is InAppWebView

    when (call.method) {
      "setWebMessageCallback" -> {
        if (messageChannel != null && isInAppWebView) {
          messageChannel.setWebMessageCallbackForInAppWebView(
            call.argument<Int>("index")!!, result
          )
        } else {
          result.success(false)
        }
      }

      "postMessage" -> {
        if (messageChannel != null && isInAppWebView) {
          val message = WebMessageCompatExt.fromMap(
            call.argument<Map<String, Any?>>("message")
          )!!
          messageChannel.postMessageForInAppWebView(
            call.argument<Int>("index")!!, message, result
          )
        } else {
          result.success(false)
        }
      }

      "close" -> {
        if (messageChannel != null && isInAppWebView) {
          messageChannel.closeForInAppWebView(call.argument<Int>("index")!!, result)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onMessage(index: Int, message: WebMessageCompatExt?) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onMessage",
      hashMapOf<String, Any?>("index" to index, "message" to message?.toMap())
    )
  }

  override fun dispose() {
    super.dispose()
    webMessageChannel = null
  }
}
