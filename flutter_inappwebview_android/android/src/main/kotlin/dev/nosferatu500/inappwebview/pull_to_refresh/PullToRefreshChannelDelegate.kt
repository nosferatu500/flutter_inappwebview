package dev.nosferatu500.inappwebview.pull_to_refresh

import android.graphics.Color
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import dev.nosferatu500.inappwebview.pigeons.PullToRefreshFlutterApi
import dev.nosferatu500.inappwebview.pigeons.PullToRefreshHostApi
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([PullToRefreshHostApi] / [PullToRefreshFlutterApi]) rather than a
 * hand-written `MethodChannel`; the fifteenth channel migrated, at **ten host methods plus one
 * event**.
 *
 * **Per-instance**: the `messageChannelSuffix` is the owning webview's id, passed once into this
 * constructor and from there into both `setUp` and the FlutterApi constructor so the halves cannot
 * drift. It is constructed in **two** places: [PullToRefreshLayout]'s programmatic constructor
 * (used by `FlutterWebView`, i.e. the `InAppWebView` widget and `HeadlessInAppWebView`), and
 * `InAppBrowserActivity`, which inflates the layout from XML and wires the delegate by hand. The
 * device group (§181) drives the widget path only.
 *
 * ⚠️ **Only the host half of the suffix is covered.** [onRefresh] fires on a real drag, which no
 * automated test here can deliver, so a wrong FlutterApi suffix would be §179's silent 60 seconds and
 * no test would see it — the same position print_job was in (§177).
 *
 * **None of the ten host methods is `@async`**: each answers inline, so Pigeon's own `try`/`catch`
 * around the synchronous handlers is the only error path and §172's `replyingOnThrow` has nothing to
 * wrap. Verified by reading the generated output (ten wrapped handlers).
 *
 * **No `dispose` host method**, so unlike §177 and §180 this class keeps `Disposable` and its
 * teardown keeps the name `dispose` — there is nothing for it to recurse into.
 */
class PullToRefreshChannelDelegate(
  pullToRefreshView: PullToRefreshLayout,
  messenger: BinaryMessenger,
  private val suffix: String
) : Disposable, PullToRefreshHostApi {

  private var pullToRefreshView: PullToRefreshLayout? = pullToRefreshView

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: PullToRefreshFlutterApi? = PullToRefreshFlutterApi(messenger, suffix)

  init {
    PullToRefreshHostApi.setUp(messenger, this, suffix)
  }

  override fun setEnabled(enabled: Boolean): Boolean {
    val view = pullToRefreshView ?: return false
    view.settings.enabled = enabled // used by InAppWebView.onOverScrolled
    view.isEnabled = enabled
    return true
  }

  override fun isEnabled(): Boolean = pullToRefreshView?.isEnabled ?: false

  override fun setRefreshing(refreshing: Boolean): Boolean {
    val view = pullToRefreshView ?: return false
    view.isRefreshing = refreshing
    return true
  }

  override fun isRefreshing(): Boolean = pullToRefreshView?.isRefreshing ?: false

  /**
   * ⚠️ This and the four setters after it have **no payload coverage**: `SwipeRefreshLayout` has no
   * getter for any of them, and §181 measured a mutant that hard-codes the colour surviving the whole
   * group.
   */
  override fun setColor(color: String): Boolean {
    val view = pullToRefreshView ?: return false
    view.setColorSchemeColors(Color.parseColor(color))
    return true
  }

  override fun setBackgroundColor(color: String): Boolean {
    val view = pullToRefreshView ?: return false
    view.setProgressBackgroundColorSchemeColor(Color.parseColor(color))
    return true
  }

  // The three narrowings below are Pigeon's `Long` into the `Int`s `SwipeRefreshLayout` takes.
  // `setSize` is the one that lands in an `@IntDef` (`@Size`) — §162's shape. Settled at the gate,
  // not pre-emptively worked around: `lintDebug` reports **0 errors, no `WrongConstant`**. The
  // second measurement (after §179's `@Relation`) that a single narrowed value passes; §162's
  // failure needs a flag-`@IntDef` varargs array.

  override fun setDistanceToTriggerSync(distanceToTriggerSync: Long): Boolean {
    val view = pullToRefreshView ?: return false
    view.setDistanceToTriggerSync(distanceToTriggerSync.toInt())
    return true
  }

  override fun setSlingshotDistance(slingshotDistance: Long): Boolean {
    val view = pullToRefreshView ?: return false
    view.setSlingshotDistance(slingshotDistance.toInt())
    return true
  }

  override fun getDefaultSlingshotDistance(): Long =
    SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE.toLong()

  override fun setSize(size: Long): Boolean {
    val view = pullToRefreshView ?: return false
    view.setSize(size.toInt())
    return true
  }

  /**
   * Fire-and-forget, as the hand-written `channel.invokeMethod` was: Pigeon's generated FlutterApi
   * reports delivery through a callback, and discarding it keeps the previous behaviour rather than
   * inventing error handling for an event nothing awaits. Same shape as §165, §177, §179 and §180.
   */
  fun onRefresh() {
    flutterApi?.onRefresh {}
  }

  override fun dispose() {
    // Unregisters the generated handler for *this suffix*. Skipping it would leave a disposed
    // layout's handler bound to the messenger for the life of the engine.
    messenger?.let { PullToRefreshHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    pullToRefreshView = null
  }
}
