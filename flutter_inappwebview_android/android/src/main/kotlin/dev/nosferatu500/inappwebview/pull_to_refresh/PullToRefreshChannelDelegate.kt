package dev.nosferatu500.inappwebview.pull_to_refresh

import android.graphics.Color
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PullToRefreshChannelDelegate(
  pullToRefreshView: PullToRefreshLayout,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var pullToRefreshView: PullToRefreshLayout? = pullToRefreshView

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val view = pullToRefreshView
    when (call.method) {
      "setEnabled" -> {
        if (view != null) {
          val enabled = call.argument<Boolean>("enabled")!!
          view.settings.enabled = enabled // used by InAppWebView.onOverScrolled
          view.isEnabled = enabled
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "isEnabled" -> {
        if (view != null) {
          result.success(view.isEnabled)
        } else {
          result.success(false)
        }
      }

      "setRefreshing" -> {
        if (view != null) {
          view.isRefreshing = call.argument<Boolean>("refreshing")!!
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "isRefreshing" -> result.success(view != null && view.isRefreshing)

      "setColor" -> {
        if (view != null) {
          view.setColorSchemeColors(Color.parseColor(call.argument("color")))
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "setBackgroundColor" -> {
        if (view != null) {
          view.setProgressBackgroundColorSchemeColor(Color.parseColor(call.argument("color")))
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "setDistanceToTriggerSync" -> {
        if (view != null) {
          view.setDistanceToTriggerSync(call.argument<Int>("distanceToTriggerSync")!!)
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "setSlingshotDistance" -> {
        if (view != null) {
          view.setSlingshotDistance(call.argument<Int>("slingshotDistance")!!)
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "getDefaultSlingshotDistance" -> result.success(SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE)

      "setSize" -> {
        if (view != null) {
          view.setSize(call.argument<Int>("size")!!)
          result.success(true)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onRefresh() {
    val channel = this.channel ?: return
    channel.invokeMethod("onRefresh", hashMapOf<String, Any?>())
  }

  override fun dispose() {
    super.dispose()
    pullToRefreshView = null
  }
}
