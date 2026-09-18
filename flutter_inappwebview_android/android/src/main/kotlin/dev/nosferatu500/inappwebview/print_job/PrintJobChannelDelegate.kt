package dev.nosferatu500.inappwebview.print_job

import dev.nosferatu500.inappwebview.pigeons.PrintJobAttributesData
import dev.nosferatu500.inappwebview.pigeons.PrintJobControllerFlutterApi
import dev.nosferatu500.inappwebview.pigeons.PrintJobControllerHostApi
import dev.nosferatu500.inappwebview.pigeons.PrintJobInfoData
import dev.nosferatu500.inappwebview.pigeons.PrintJobMarginsData
import dev.nosferatu500.inappwebview.pigeons.PrintJobMediaSizeData
import dev.nosferatu500.inappwebview.pigeons.PrintJobResolutionData
import dev.nosferatu500.inappwebview.types.MarginsExt
import dev.nosferatu500.inappwebview.types.MediaSizeExt
import dev.nosferatu500.inappwebview.types.PrintAttributesExt
import dev.nosferatu500.inappwebview.types.PrintJobInfoExt
import dev.nosferatu500.inappwebview.types.ResolutionExt
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([PrintJobControllerHostApi] / [PrintJobControllerFlutterApi])
 * rather than a hand-written `MethodChannel`; the twelfth channel migrated.
 *
 * **Per-instance**: the `messageChannelSuffix` is the job id, as on both web_message channels, and
 * it is threaded from one place ([PrintJobController]) into both `setUp` and the FlutterApi
 * constructor here so the two halves cannot drift apart.
 *
 * 🚨 **§165's "a mismatched suffix fails silently" is true of the *event* direction only** —
 * measured here, not inherited. A mismatch on the **HostApi** direction fails in about two seconds
 * with the offending channel named in full:
 *
 * ```
 * PlatformException(channel-error, Unable to establish connection on channel:
 *   "dev.flutter.pigeon.…PrintJobControllerHostApi.getInfo.<suffix>".)
 * ```
 *
 * because the caller is awaiting a reply that never comes and Pigeon turns the null into that error.
 * A mismatch on the **FlutterApi** direction has nothing awaiting it, so the event simply never
 * arrives — which is the silent 60-second hang §165 recorded. Only the HostApi half is covered by a
 * test here; [onComplete] is unreachable from an automated test (see §176), so the event half of
 * this suffix is **uncovered** and the silent mode is live for it.
 *
 * **None of the four host methods is `@async`**: each answers inline, so Pigeon's own `try`/`catch`
 * around the synchronous handlers is the only error path and §172's `replyingOnThrow` has nothing to
 * wrap. `onComplete` is an *event*, not a completion signal for any call.
 *
 * 🚨 **This class deliberately does not implement `Disposable`, and its teardown is called
 * [disposeDelegate].** The channel has a method named `dispose`, so the generated interface
 * contributes `fun dispose(): Boolean` — which cannot coexist with `Disposable.dispose(): Unit`
 * (same name, different return type). That is the §14 name collision again, on the **Kotlin** side
 * this time; the Dart side hits its own version of it on `onComplete`, see the schema.
 *
 * Getting this wrong is not a compile error but an **infinite recursion**: the obvious fix is to
 * keep `dispose()` as the teardown, and then `PrintJobController.dispose()` calls
 * `channelDelegate?.dispose()`, which resolves to the *host* method, which calls
 * `controller.dispose()` again. Hence the separate name.
 */
class PrintJobChannelDelegate(
  printJobController: PrintJobController,
  messenger: BinaryMessenger,
  private val suffix: String
) : PrintJobControllerHostApi {

  private var printJobController: PrintJobController? = printJobController

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: PrintJobControllerFlutterApi? =
    PrintJobControllerFlutterApi(messenger, suffix)

  init {
    PrintJobControllerHostApi.setUp(messenger, this, suffix)
  }

  /**
   * `false` means the controller has already been disposed — **not** that the job was not
   * cancelled. `android.print.PrintJob.cancel()` is a no-op while the job is `CREATED`, which is
   * every state a test can reach (§176 measured `getInfo().state` staying `CREATED` across a
   * `cancel()`). Preserved from the hand-written channel.
   */
  override fun cancel(): Boolean {
    val controller = printJobController ?: return false
    controller.cancel()
    return true
  }

  /** See [cancel]; `PrintJob.restart()` applies to a failed job and is likewise inert here. */
  override fun restart(): Boolean {
    val controller = printJobController ?: return false
    controller.restart()
    return true
  }

  override fun getInfo(): PrintJobInfoData? = printJobController?.getInfo()?.toPigeon()

  override fun dispose(): Boolean {
    val controller = printJobController ?: return false
    controller.dispose()
    return true
  }

  /**
   * Fire-and-forget, as the hand-written `channel.invokeMethod` was: Pigeon's generated FlutterApi
   * reports delivery through a callback, and discarding it keeps the previous behaviour rather than
   * inventing error handling for an event nothing awaits. Same shape as §165's `onMessage`.
   */
  fun onComplete(completed: Boolean, error: String?) {
    flutterApi?.onComplete(completed, error) {}
  }

  /**
   * Releases this delegate's channel registration. **Not** called `dispose` — see the class doc:
   * that name belongs to the host method above, and reusing it here recurses.
   */
  fun disposeDelegate() {
    // Unregisters the generated handler for *this suffix*. Skipping it would leave a disposed job's
    // handler bound to the messenger for the life of the engine.
    messenger?.let { PrintJobControllerHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    printJobController = null
  }
}

// --- PrintJobInfoExt -> Pigeon ------------------------------------------------------------------
//
// These live here rather than on the `…Ext` types because those also serve the *inbound* settings
// path (`PrintJobSettings` builds a `MediaSizeExt` and a `ResolutionExt` from Dart), and this
// conversion is outbound only. Keeping it local leaves `types/` untouched by the migration.
//
// Every `Int` widens to `Long` because Pigeon maps Dart `int` to Kotlin `Long`. That is the safe
// direction: §162's bug was the inbound narrowing, where an androidx API demanded an `Int` and the
// obvious `.toInt()` failed `lintDebug` rather than the compiler. Nothing here takes a number from
// Dart, so nothing narrows.

private fun PrintJobInfoExt.toPigeon(): PrintJobInfoData = PrintJobInfoData(
  state = state.toLong(),
  copies = copies.toLong(),
  numberOfPages = numberOfPages?.toLong(),
  // Already a Long; the only number on this channel that needs no widening.
  creationTime = creationTime,
  label = label,
  // Flattened out of the one-key `"printer"` map the hand-written channel sent; the Dart side
  // rebuilds a non-null `Printer` from it either way. See the schema.
  printerId = printerId,
  attributes = attributes?.toPigeon()
)

private fun PrintAttributesExt.toPigeon(): PrintJobAttributesData = PrintJobAttributesData(
  colorMode = colorMode.toLong(),
  duplex = duplex?.toLong(),
  orientation = orientation?.toLong(),
  mediaSize = mediaSize?.toPigeon(),
  resolution = resolution?.toPigeon(),
  margins = margins?.toPigeon()
)

private fun MediaSizeExt.toPigeon(): PrintJobMediaSizeData = PrintJobMediaSizeData(
  id = id,
  label = label,
  widthMils = widthMils.toLong(),
  heightMils = heightMils.toLong()
)

private fun ResolutionExt.toPigeon(): PrintJobResolutionData = PrintJobResolutionData(
  id = id,
  label = label,
  verticalDpi = verticalDpi.toLong(),
  horizontalDpi = horizontalDpi.toLong()
)

private fun MarginsExt.toPigeon(): PrintJobMarginsData = PrintJobMarginsData(
  top = top,
  right = right,
  bottom = bottom,
  left = left
)
