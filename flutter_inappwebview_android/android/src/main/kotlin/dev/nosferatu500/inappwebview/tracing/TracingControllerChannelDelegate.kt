package dev.nosferatu500.inappwebview.tracing

import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.util.concurrent.Executors

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class TracingControllerChannelDelegate(
  tracingControllerManager: TracingControllerManager,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var tracingControllerManager: TracingControllerManager? = tracingControllerManager

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    TracingControllerManager.init()
    val tracingController = TracingControllerManager.tracingController

    when (call.method) {
      "isTracing" -> {
        if (tracingController != null) {
          result.success(tracingController.isTracing)
        } else {
          result.success(false)
        }
      }

      "start" -> {
        if (tracingController != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
        ) {
          val settingsMap = call.argument<Map<String, Any?>>("settings")
          val settings = TracingSettings()
          settings.parse(settingsMap!!)
          tracingController.start(TracingControllerManager.buildTracingConfig(settings))
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "stop" -> {
        if (tracingController != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
        ) {
          val filePath = call.argument<String>("filePath")
          try {
            result.success(
              tracingController.stop(
                if (filePath != null) FileOutputStream(filePath) else null,
                Executors.newSingleThreadExecutor()
              )
            )
          } catch (e: FileNotFoundException) {
            e.printStackTrace()
            result.success(false)
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
    tracingControllerManager = null
  }
}
