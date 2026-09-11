package dev.nosferatu500.inappwebview.webview.web_message

import android.webkit.ValueCallback
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.pigeons.WebMessageChannelFlutterApi
import dev.nosferatu500.inappwebview.pigeons.WebMessageChannelHostApi
import dev.nosferatu500.inappwebview.pigeons.WebMessageData
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.types.WebMessagePort
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([WebMessageChannelHostApi] / [WebMessageChannelFlutterApi])
 * rather than a hand-written `MethodChannel`; migrated in §165 together with [WebMessageListener],
 * which shares its `WebMessageData` payload.
 *
 * `WebMessageChannelChannelDelegate` is folded in here -- the generated interface *is* the
 * dispatcher -- as `TracingControllerChannelDelegate` was in §162.
 *
 * **Per-instance channel.** The channel id is the `messageChannelSuffix`, the mechanism the pilot
 * proved in §14 and the first use of it since.
 *
 * No method is `@async`: all three complete inline. `setWebMessageCallback` registers an androidx
 * callback, but that feeds the [onMessage] *event*, it does not signal completion of the call.
 */
// `this` is published to a platform-thread-only dispatcher during construction, as before.
class WebMessageChannel(
  @JvmField var id: String,
  webView: InAppWebViewInterface
) : Disposable, WebMessageChannelHostApi {

  private var messenger: BinaryMessenger? = webView.getPlugin()?.messenger

  private var flutterApi: WebMessageChannelFlutterApi?

  @JvmField
  val compatPorts: MutableList<WebMessagePortCompat>

  @JvmField
  val ports: List<WebMessagePort>

  @JvmField
  var webView: InAppWebViewInterface? = webView

  init {
    val messenger = webView.getPlugin()!!.messenger
    flutterApi = WebMessageChannelFlutterApi(messenger, id)
    WebMessageChannelHostApi.setUp(messenger, this, id)
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

  /**
   * Returns false only when the view is not an `InAppWebView`.
   *
   * It answers **true** when `WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK` is unsupported and nothing was
   * registered, so true means "no error" rather than "the callback is live". That is what the
   * hand-written channel did and it is preserved deliberately -- see the schema.
   */
  override fun setWebMessageCallback(index: Long): Boolean {
    webView as? InAppWebView ?: return false
    if (compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)
    ) {
      val portIndex = index.toInt()
      compatPorts[portIndex].setWebMessageCallback(
        object : WebMessagePortCompat.WebMessageCallbackCompat() {
          override fun onMessage(port: WebMessagePortCompat, message: WebMessageCompat?) {
            super.onMessage(port, message)
            onMessage(
              portIndex,
              message?.let { WebMessageCompatExt.fromMapWebMessageCompat(it) }
            )
          }
        }
      )
    }
    return true
  }

  /** Same `true`-when-unsupported caveat as [setWebMessageCallback]. */
  override fun postMessage(index: Long, message: WebMessageData): Boolean {
    val view = webView as? InAppWebView ?: return false
    if (compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)
    ) {
      val ext = WebMessageCompatExt.fromPigeon(message)
      val port = compatPorts[index.toInt()]
      val webMessagePorts = mutableListOf<WebMessagePortCompat>()
      ext.ports?.forEach { portExt ->
        val webMessageChannel = view.getWebMessageChannels()?.get(portExt.webMessageChannelId)
        if (webMessageChannel != null) {
          webMessagePorts.add(webMessageChannel.compatPorts[portExt.index])
        }
      }
      val data = ext.data
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
        data != null && ext.type == WebMessageCompat.TYPE_ARRAY_BUFFER
      ) {
        // No cast: the schema carries array-buffer payloads as a real ByteArray.
        port.postMessage(
          WebMessageCompat(data as ByteArray, webMessagePorts.toTypedArray())
        )
      } else {
        port.postMessage(
          WebMessageCompat(data?.toString(), webMessagePorts.toTypedArray())
        )
      }
    }
    return true
  }

  /** Same `true`-when-unsupported caveat as [setWebMessageCallback]. */
  override fun close(index: Long): Boolean {
    webView as? InAppWebView ?: return false
    if (compatPorts.isNotEmpty() &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)
    ) {
      compatPorts[index.toInt()].close()
    }
    return true
  }

  fun onMessage(index: Int, message: WebMessageCompatExt?) {
    flutterApi?.onMessage(index.toLong(), message?.toPigeon()) {}
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
    // Unregisters the generated handler for this suffix. Skipping it would leave it bound to a
    // disposed channel for the life of the messenger.
    messenger?.let { WebMessageChannelHostApi.setUp(it, null, id) }
    messenger = null
    flutterApi = null
    compatPorts.clear()
    webView = null
  }

  companion object {
    protected const val LOG_TAG = "WebMessageChannel"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_web_message_channel_"
  }
}
