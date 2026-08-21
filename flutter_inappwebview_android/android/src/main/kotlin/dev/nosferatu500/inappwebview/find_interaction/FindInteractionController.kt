package dev.nosferatu500.inappwebview.find_interaction

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.FindInteractionFlutterApi
import dev.nosferatu500.inappwebview.pigeons.FindInteractionHostApi
import dev.nosferatu500.inappwebview.pigeons.FindSessionData
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.FindSession
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import io.flutter.plugin.common.BinaryMessenger

/**
 * First channel migrated to Pigeon. There is no `FindInteractionChannelDelegate` any more: the
 * controller implements the generated [FindInteractionHostApi] directly, and pushes events through
 * the generated [FindInteractionFlutterApi].
 *
 * The channel name is no longer built here. Pigeon derives one channel per method from the schema
 * and appends [messageChannelSuffix], which carries the per-WebView id that
 * `METHOD_CHANNEL_NAME_PREFIX + id` used to encode.
 */
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class FindInteractionController(
  webView: InAppWebViewInterface,
  plugin: InAppWebViewFlutterPlugin,
  id: Any,
  @JvmField var settings: FindInteractionSettings?
) : Disposable, FindInteractionHostApi {

  @JvmField
  var webView: InAppWebViewInterface? = webView

  @JvmField
  var activeFindSession: FindSession? = null

  @JvmField
  var searchText: String? = null

  private val messageChannelSuffix: String = id.toString()
  private var messenger: BinaryMessenger? = plugin.messenger
  private var flutterApi: FindInteractionFlutterApi? =
    FindInteractionFlutterApi(plugin.messenger, messageChannelSuffix)

  init {
    FindInteractionHostApi.setUp(plugin.messenger, this, messageChannelSuffix)
  }

  fun prepare() {
  }

  override fun findAll(find: String?) {
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

  override fun findNext(forward: Boolean) {
    webView?.findNext(forward)
  }

  override fun clearMatches() {
    webView?.clearMatches()
  }

  override fun setSearchText(searchText: String?) {
    this.searchText = searchText
  }

  override fun getSearchText(): String? = searchText

  override fun getActiveFindSession(): FindSessionData? =
    activeFindSession?.let {
      FindSessionData(
        resultCount = it.resultCount.toLong(),
        highlightedResultIndex = it.highlightedResultIndex.toLong(),
        searchResultDisplayStyle = it.searchResultDisplayStyle.toLong()
      )
    }

  /**
   * Called by [dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView]'s
   * find listener. Was `channelDelegate.onFindResultReceived`.
   */
  fun onFindResultReceived(
    activeMatchOrdinal: Int,
    numberOfMatches: Int,
    isDoneCounting: Boolean
  ) {
    if (isDoneCounting && webView != null) {
      activeFindSession = FindSession(numberOfMatches, activeMatchOrdinal)
    }

    // Fire-and-forget, matching MethodChannel.invokeMethod without a result handler. Pigeon
    // always hands back a Result so a codec failure is reportable; there is nothing to do with
    // one here beyond not crashing, since the event is advisory.
    flutterApi?.onFindResultReceived(
      activeMatchOrdinal.toLong(),
      numberOfMatches.toLong(),
      isDoneCounting
    ) { }
  }

  override fun dispose() {
    // Unregisters every generated handler for this suffix. Skipping it would leave the handlers
    // bound to a disposed controller for the life of the messenger.
    messenger?.let { FindInteractionHostApi.setUp(it, null, messageChannelSuffix) }
    messenger = null
    flutterApi = null
    webView = null
    activeFindSession = null
    searchText = null
  }

  companion object {
    const val LOG_TAG = "FindInteractionController"
  }
}
