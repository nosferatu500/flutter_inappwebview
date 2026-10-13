package dev.nosferatu500.inappwebview.types

import android.text.TextUtils
import android.webkit.ValueCallback
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageChannel

class WebMessagePort(
  @JvmField var name: String,
  @JvmField var webMessageChannel: WebMessageChannel?
) {
  @JvmField
  var isClosed = false

  @JvmField
  var isTransferred = false

  @JvmField
  var isStarted = false

  @Throws(Exception::class)
  fun setWebMessageCallback(callback: ValueCallback<Void?>?) {
    if (isClosed || isTransferred) {
      throw Exception("Port is already closed or transferred")
    }
    isStarted = true
    val channel = webMessageChannel
    val webView = channel?.webView
    if (channel != null && webView != null) {
      val index = if (name == "port1") 0 else 1
      webView.evaluateJavascript(
        "(function() {" +
          "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channel.id + "'];" +
          "  if (webMessageChannel != null) {" +
          "      webMessageChannel." + name + ".onmessage = function (event) {" +
          "          window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('onWebMessagePortMessageReceived', {" +
          "              'webMessageChannelId': '" + channel.id + "'," +
          "              'index': " + index + "," +
          "              'message': event.data" +
          "          });" +
          "      }" +
          "  }" +
          "})();",
        null
      ) { callback?.onReceiveValue(null) }
    } else {
      callback?.onReceiveValue(null)
    }
  }

  @Throws(Exception::class)
  fun postMessage(message: WebMessage, callback: ValueCallback<Void?>) {
    if (isClosed || isTransferred) {
      throw Exception("Port is already closed or transferred")
    }
    val channel = webMessageChannel
    val webView = channel?.webView
    if (channel != null && webView != null) {
      var portsString = "null"
      val ports = message.ports
      if (ports != null) {
        val portArrayString = mutableListOf<String>()
        for (port in ports) {
          if (port === this) {
            throw Exception("Source port cannot be transferred")
          }
          if (port.isStarted) {
            throw Exception("Port is already started")
          }
          if (port.isClosed || port.isTransferred) {
            throw Exception("Port is already closed or transferred")
          }
          port.isTransferred = true
          portArrayString.add(
            JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channel.id + "']." + port.name
          )
        }
        portsString = "[" + TextUtils.join(", ", portArrayString) + "]"
      }
      val data = message.data?.let { Util.replaceAll(it, "'", "\\'") } ?: "null"
      val source = "(function() {" +
        "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channel.id + "'];" +
        "  if (webMessageChannel != null) {" +
        "      webMessageChannel." + name + ".postMessage('" + data + "', " + portsString + ");" +
        "  }" +
        "})();"
      webView.evaluateJavascript(source, null) { callback.onReceiveValue(null) }
    } else {
      callback.onReceiveValue(null)
    }
    message.dispose()
  }

  @Throws(Exception::class)
  fun close(callback: ValueCallback<Void?>) {
    if (isTransferred) {
      throw Exception("Port is already transferred")
    }
    isClosed = true
    val channel = webMessageChannel
    val webView = channel?.webView
    if (channel != null && webView != null) {
      val source = "(function() {" +
        "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channel.id + "'];" +
        "  if (webMessageChannel != null) {" +
        "      webMessageChannel." + name + ".close();" +
        "  }" +
        "})();"
      webView.evaluateJavascript(source, null) { callback.onReceiveValue(null) }
    } else {
      callback.onReceiveValue(null)
    }
  }

  fun dispose() {
    isClosed = true
    webMessageChannel = null
  }
}
