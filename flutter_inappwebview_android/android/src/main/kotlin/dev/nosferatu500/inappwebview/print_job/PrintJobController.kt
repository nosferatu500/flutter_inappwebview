package dev.nosferatu500.inappwebview.print_job

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.PrintJobInfoExt
import io.flutter.plugin.common.MethodChannel

// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class PrintJobController(
  @JvmField var id: String,
  @JvmField var settings: PrintJobSettings?,
  plugin: InAppWebViewFlutterPlugin
) : Disposable {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var channelDelegate: PrintJobChannelDelegate?

  @JvmField
  var job: android.print.PrintJob? = null

  init {
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = PrintJobChannelDelegate(this, channel)
  }

  fun setJob(job: android.print.PrintJob?) {
    this.job = job
  }

  fun cancel() {
    job?.cancel()
  }

  fun restart() {
    job?.restart()
  }

  fun getInfo(): PrintJobInfoExt? = job?.let { PrintJobInfoExt.fromPrintJobInfo(it.info) }

  fun disposeNoCancel() {
    channelDelegate?.dispose()
    channelDelegate = null
    clearManagerSlot()
    job = null
    plugin = null
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    clearManagerSlot()
    job?.cancel()
    job = null
    plugin = null
  }

  private fun clearManagerSlot() {
    val printJobManager = plugin?.printJobManager ?: return
    if (printJobManager.jobs.containsKey(id)) {
      printJobManager.jobs[id] = null
    }
  }

  fun onComplete(completed: Boolean, error: String?) {
    channelDelegate?.onComplete(completed, error)
  }

  companion object {
    protected const val LOG_TAG = "PrintJob"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_printjobcontroller_"
  }
}
