package dev.nosferatu500.inappwebview.print_job

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.PrintJobInfoExt

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
    // The job id is the Pigeon `messageChannelSuffix`, so both halves must derive it from the same
    // place. §165 measured what a disagreement costs here: no error, just a call that never arrives
    // and a 60-second timeout at the caller.
    channelDelegate = PrintJobChannelDelegate(this, plugin.messenger, id)
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

  override fun dispose() {
    // `disposeDelegate()`, not `dispose()`: the delegate now implements a *channel* method called
    // `dispose`, and calling that one from here would recurse. See PrintJobChannelDelegate's doc.
    channelDelegate?.disposeDelegate()
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
    // METHOD_CHANNEL_NAME_PREFIX is gone: Pigeon derives the channel name from the API class plus
    // the `messageChannelSuffix` (the job id), so there is no name for this side to build. Nothing
    // outside this class ever read it -- measured.
  }
}
