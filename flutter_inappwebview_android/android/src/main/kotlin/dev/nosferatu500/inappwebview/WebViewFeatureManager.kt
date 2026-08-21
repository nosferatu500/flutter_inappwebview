package dev.nosferatu500.inappwebview

import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WebViewFeatureManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "isFeatureSupported" -> {
        val feature = call.argument<String>("feature")
        result.success(WebViewFeature.isFeatureSupported(feature!!))
      }

      "isStartupFeatureSupported" -> {
        val activity = plugin?.activity
        if (activity != null) {
          val startupFeature = call.argument<String>("startupFeature")
          result.success(WebViewFeature.isStartupFeatureSupported(activity, startupFeature!!))
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "WebViewFeatureManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_webviewfeature"
  }
}
