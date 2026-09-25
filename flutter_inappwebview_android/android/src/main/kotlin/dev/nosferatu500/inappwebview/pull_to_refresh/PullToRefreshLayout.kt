package dev.nosferatu500.inappwebview.pull_to_refresh

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView

class PullToRefreshLayout : SwipeRefreshLayout, Disposable {

  @JvmField
  var channelDelegate: PullToRefreshChannelDelegate? = null

  @JvmField
  var settings: PullToRefreshSettings = PullToRefreshSettings()

  // See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
  constructor(
    context: Context,
    plugin: InAppWebViewFlutterPlugin,
    id: Any,
    settings: PullToRefreshSettings
  ) : super(context) {
    this.settings = settings
    // Pigeon derives one channel per method from the schema and appends this suffix, so the id that
    // used to be interpolated into a single channel name is passed as the suffix instead. It must
    // stringify the same way Dart's `'$id'` does — for the widget's int view id and for the
    // headless / InAppBrowser string ids alike.
    channelDelegate = PullToRefreshChannelDelegate(this, plugin.messenger, id.toString())
  }

  constructor(context: Context) : super(context)

  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

  fun prepare() {
    isFocusable = true

    isEnabled = settings.enabled
    setOnChildScrollUpCallback { _, child ->
      if (child is InAppWebView) {
        (child.canScrollVertically() && child.scrollY > 0) ||
          (!child.canScrollVertically() && child.scrollY == 0)
      } else {
        true
      }
    }
    setOnRefreshListener {
      val delegate = channelDelegate
      if (delegate == null) {
        isRefreshing = false
      } else {
        delegate.onRefresh()
      }
    }
    settings.color?.let { setColorSchemeColors(Color.parseColor(it)) }
    settings.backgroundColor?.let { setProgressBackgroundColorSchemeColor(Color.parseColor(it)) }
    settings.distanceToTriggerSync?.let { setDistanceToTriggerSync(it) }
    settings.slingshotDistance?.let { setSlingshotDistance(it) }
    settings.size?.let { setSize(it) }
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    removeAllViews()
  }

  companion object {
    const val LOG_TAG = "PullToRefreshLayout"
    // METHOD_CHANNEL_NAME_PREFIX is gone with the migration: Pigeon derives its own channel names
    // from the schema and the id travels as the messageChannelSuffix. Its one other user,
    // InAppBrowserActivity, now passes the suffix too.
  }
}
