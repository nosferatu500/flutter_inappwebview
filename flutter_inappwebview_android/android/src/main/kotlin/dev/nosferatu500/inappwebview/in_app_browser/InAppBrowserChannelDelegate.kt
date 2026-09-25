package dev.nosferatu500.inappwebview.in_app_browser

import dev.nosferatu500.inappwebview.pigeons.InAppBrowserFlutterApi
import dev.nosferatu500.inappwebview.pigeons.InAppBrowserHostApi
import dev.nosferatu500.inappwebview.types.InAppBrowserMenuItem
import io.flutter.plugin.common.BinaryMessenger

/**
 * The browser Activity's own half of the per-instance channel, over Pigeon (§195). The WebView's
 * half is still `WebViewChannelDelegate` on the `inappbrowser_$id` MethodChannel, and so are the
 * browser's `setSettings`/`getSettings`.
 *
 * Before this, both delegates were handed the same MethodChannel and this one's `onMethodCall` was
 * empty. It only worked because the WebView's delegate registered last and answered for both.
 */
class InAppBrowserChannelDelegate(
  activity: InAppBrowserActivity,
  messenger: BinaryMessenger,
  private val suffix: String
) : InAppBrowserHostApi {

  private var activity: InAppBrowserActivity? = activity

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: InAppBrowserFlutterApi? = InAppBrowserFlutterApi(messenger, suffix)

  init {
    InAppBrowserHostApi.setUp(messenger, this, suffix)
  }

  // `activity!!` rather than an early `return false`: the HostApi is unregistered in [dispose],
  // together with the Activity reference, so a call cannot reach a missing Activity. If one ever
  // does, the old channel answered `notImplemented`, an error; Pigeon turns this throw into an
  // error reply too, rather than a quiet `false` (§182, §186).

  override fun show(): Boolean {
    activity!!.show()
    return true
  }

  override fun hide(): Boolean {
    activity!!.hide()
    return true
  }

  /**
   * `InAppBrowserActivity.close` sends `onExit`, then disposes the Activity (which disposes this
   * delegate and unregisters this handler), and only then is `true` answered, the same order the
   * hand-written channel used. The reply is unaffected by the unregistration: Pigeon has already
   * captured it for this call.
   */
  override fun close(): Boolean {
    activity!!.close()
    return true
  }

  override fun isHidden(): Boolean = activity!!.isHidden

  // --- events -----------------------------------------------------------------------------------
  // Fire-and-forget, as the hand-written `channel.invokeMethod` calls were (§165, §177, §179, §180).

  fun onBrowserCreated() {
    flutterApi?.onBrowserCreated {}
  }

  fun onMenuItemClicked(menuItem: InAppBrowserMenuItem) {
    flutterApi?.onMenuItemClicked(menuItem.id.toLong()) {}
  }

  fun onExit() {
    flutterApi?.onExit {}
  }

  fun dispose() {
    messenger?.let { InAppBrowserHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    activity = null
  }
}
