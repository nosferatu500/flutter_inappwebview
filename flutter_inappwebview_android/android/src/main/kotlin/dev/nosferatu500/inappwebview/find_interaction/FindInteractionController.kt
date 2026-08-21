package dev.nosferatu500.inappwebview.find_interaction

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.FindSession
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import io.flutter.plugin.common.MethodChannel

// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class FindInteractionController(
  webView: InAppWebViewInterface,
  plugin: InAppWebViewFlutterPlugin,
  id: Any,
  @JvmField var settings: FindInteractionSettings?
) : Disposable {

  @JvmField
  var webView: InAppWebViewInterface? = webView

  @JvmField
  var activeFindSession: FindSession? = null

  @JvmField
  var channelDelegate: FindInteractionChannelDelegate?

  @JvmField
  var searchText: String? = null

  init {
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = FindInteractionChannelDelegate(this, channel)
  }

  fun prepare() {
  }

  fun findAll(find: String?) {
    val target: String?
    if (find == null) {
      target = searchText
    } else {
      // updated searchText
      searchText = find
      target = find
    }
    if (target != null) {
      webView?.findAllAsync(target)
    }
  }

  fun findNext(forward: Boolean) {
    webView?.findNext(forward)
  }

  fun clearMatches() {
    webView?.clearMatches()
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    webView = null
    activeFindSession = null
    searchText = null
  }

  companion object {
    const val LOG_TAG = "FindInteractionController"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/inappwebview_find_interaction_"
  }
}
