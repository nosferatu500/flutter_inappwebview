package dev.nosferatu500.inappwebview.print_job

import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PrintJobChannelDelegate(
  printJobController: PrintJobController,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var printJobController: PrintJobController? = printJobController

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val controller = printJobController
    when (call.method) {
      "cancel" -> {
        if (controller != null) {
          controller.cancel()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "restart" -> {
        if (controller != null) {
          controller.restart()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "getInfo" -> result.success(controller?.getInfo()?.toMap())

      "dispose" -> {
        if (controller != null) {
          controller.dispose()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onComplete(completed: Boolean, error: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onComplete",
      hashMapOf<String, Any?>("completed" to completed, "error" to error)
    )
  }

  override fun dispose() {
    super.dispose()
    printJobController = null
  }
}
