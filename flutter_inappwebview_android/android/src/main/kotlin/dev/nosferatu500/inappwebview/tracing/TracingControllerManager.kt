package dev.nosferatu500.inappwebview.tracing

import androidx.webkit.TracingConfig
import androidx.webkit.TracingController
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.MethodChannel

// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class TracingControllerManager(plugin: InAppWebViewFlutterPlugin) : Disposable {

  @JvmField
  var channelDelegate: TracingControllerChannelDelegate?

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  init {
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)
    channelDelegate = TracingControllerChannelDelegate(this, channel)
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "TracingControllerMan"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_tracingcontroller"

    @JvmField
    var tracingController: TracingController? = null

    @JvmStatic
    fun init() {
      if (tracingController == null &&
        WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
      ) {
        tracingController = TracingController.getInstance()
      }
    }

    @JvmStatic
    fun buildTracingConfig(settings: TracingSettings): TracingConfig {
      val builder = TracingConfig.Builder()
      for (category in settings.categories) {
        if (category is String) {
          builder.addCategories(category)
        }
        if (category is Int) {
          builder.addCategories(category)
        }
      }
      settings.tracingMode?.let { builder.setTracingMode(it) }
      return builder.build()
    }
  }
}
