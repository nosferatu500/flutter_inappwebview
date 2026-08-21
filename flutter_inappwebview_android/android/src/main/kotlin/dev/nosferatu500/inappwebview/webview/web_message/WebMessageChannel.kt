package dev.nosferatu500.inappwebview.webview.web_message

import android.webkit.ValueCallback
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.types.WebMessagePort
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodChannel

// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class WebMessageChannel(
  @JvmField var id: String,
  webView: InAppWebViewInterface
) : Disposable {

  @JvmField
  var channelDelegate: WebMessageChannelChannelDelegate?

  @JvmField
  val compatPorts: MutableList<WebMessagePortCompat>

  @JvmField
  val ports: List<WebMessagePort>

  @JvmField
  var webView: InAppWebViewInterface? = webView

  init {
    val channel = MethodChannel(
      webView.getPlugin()!!.messenger, METHOD_CHANNEL_NAME_PREFIX + id
    )
    channelDelegate = WebMessageChannelChannelDelegate(this, channel)
    if (webView is InAppWebView) {
      compatPorts = WebViewCompat.createWebMessageChannel(webView).toMutableList()
      ports = ArrayList()
    } else {
      ports = listOf(WebMessagePort("port1", this), WebMessagePort("port2", this))
      compatPorts = ArrayList()
    }
  }

  fun initJsInstance(
    webView: InAppWebViewInterface?,
    callback: ValueCallback<WebMessageChannel>
  ) {
    if (webView != null) {
      webView.evaluateJavascript(
        "(function() {" +
          JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + id +
          "'] = new MessageChannel();" +
          "})();",
        null
      ) { callback.onReceiveValue(this) }
    } else {
      callback.onReceiveValue(this)
    }
  }

  fun setWebMessageCallbackForInAppWebView(index: Int, result: MethodChannel.Result) {
    if (webView != null && compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)
    ) {
      val webMessagePort = compatPorts[index]
      try {
        webMessagePort.setWebMessageCallback(
          object : WebMessagePortCompat.WebMessageCallbackCompat() {
            override fun onMessage(port: WebMessagePortCompat, message: WebMessageCompat?) {
              super.onMessage(port, message)
              onMessage(
                index,
                message?.let { WebMessageCompatExt.fromMapWebMessageCompat(it) }
              )
            }
          }
        )
        result.success(true)
      } catch (e: Exception) {
        result.error(LOG_TAG, e.message, null)
      }
    } else {
      result.success(true)
    }
  }

  fun postMessageForInAppWebView(
    index: Int,
    message: WebMessageCompatExt,
    result: MethodChannel.Result
  ) {
    val view = webView
    if (view != null && compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)
    ) {
      val port = compatPorts[index]
      val webMessagePorts = mutableListOf<WebMessagePortCompat>()
      message.ports?.forEach { portExt ->
        val webMessageChannel = view.getWebMessageChannels()?.get(portExt.webMessageChannelId)
        if (webMessageChannel != null) {
          webMessagePorts.add(webMessageChannel.compatPorts[portExt.index])
        }
      }
      val data = message.data
      try {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
          data != null && message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
        ) {
          port.postMessage(
            WebMessageCompat(data as ByteArray, webMessagePorts.toTypedArray())
          )
        } else {
          port.postMessage(
            WebMessageCompat(data?.toString(), webMessagePorts.toTypedArray())
          )
        }
        result.success(true)
      } catch (e: Exception) {
        result.error(LOG_TAG, e.message, null)
      }
    } else {
      result.success(true)
    }
  }

  fun closeForInAppWebView(index: Int, result: MethodChannel.Result) {
    if (webView != null && compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)
    ) {
      try {
        compatPorts[index].close()
        result.success(true)
      } catch (e: Exception) {
        result.error(LOG_TAG, e.message, null)
      }
    } else {
      result.success(true)
    }
  }

  fun onMessage(index: Int, message: WebMessageCompatExt?) {
    channelDelegate?.onMessage(index, message)
  }

  fun toMap(): MutableMap<String, Any?> = hashMapOf("id" to id)

  override fun dispose() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
      for (port in compatPorts) {
        try {
          port.close()
        } catch (ignored: Exception) {
        }
      }
    }
    channelDelegate?.dispose()
    channelDelegate = null
    compatPorts.clear()
    webView = null
  }

  companion object {
    protected const val LOG_TAG = "WebMessageChannel"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_web_message_channel_"
  }
}
