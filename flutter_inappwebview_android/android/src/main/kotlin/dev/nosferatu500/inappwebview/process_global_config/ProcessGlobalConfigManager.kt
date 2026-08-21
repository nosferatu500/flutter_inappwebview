package dev.nosferatu500.inappwebview.process_global_config

import androidx.webkit.ProcessGlobalConfig
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class ProcessGlobalConfigManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "apply" -> {
        val activity = this.plugin?.activity
        if (activity != null) {
          val settings = ProcessGlobalConfigSettings()
            .parse(call.argument<Map<String, Any?>>("settings")!!)
          try {
            ProcessGlobalConfig.apply(settings.toProcessGlobalConfig(activity))
            result.success(true)
          } catch (e: Exception) {
            result.error(LOG_TAG, "", e)
          }
        } else {
          result.success(false)
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
    protected const val LOG_TAG = "ProcessGlobalConfigM"
    const val METHOD_CHANNEL_NAME =
      "dev.nosferatu500.inappwebview/inappwebview_processglobalconfig"
  }
}
