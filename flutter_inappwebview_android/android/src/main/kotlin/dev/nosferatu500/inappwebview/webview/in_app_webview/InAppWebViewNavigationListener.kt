package dev.nosferatu500.inappwebview.webview.in_app_webview

import androidx.webkit.Navigation
import androidx.webkit.NavigationListener
import androidx.webkit.Page
import androidx.webkit.WebViewCompat
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebViewNavigationExt
import dev.nosferatu500.inappwebview.types.WebViewPageExt

/**
 * Forwards `androidx.webkit` navigation callbacks to Dart, turning androidx's *object identities*
 * into ids that can cross a method channel.
 *
 * ### Why the maps exist
 *
 * androidx models "the same navigation" and "the same page" as object identity: the peers are
 * interned by `getOrCreatePeer`, so `onNavigationStarted`, `onNavigationRedirected` and
 * `onNavigationCompleted` all receive the *same* [Navigation] instance, mutated in place between
 * calls. Serialising a snapshot per callback is the only thing that can cross the channel, but on
 * its own it would leave Dart unable to tell which snapshots belong together. So each identity is
 * assigned a counter value here and the value travels with every snapshot.
 *
 * Neither [Navigation] nor [Page] overrides `equals`/`hashCode`: the instance is the key. But the
 * instance is only stable while something holds it. Chromium's `getOrCreatePeer` doesn't keep the
 * peer alive, so once it is garbage-collected the same page arrives as a **new** [Page] object.
 * Measured on API 37 (§260): with a weak map the page events of a document reached Dart under a
 * second id, so they no longer matched the `pageId` of the navigation that created it. So the maps
 * hold their keys **strongly**, which keeps androidx handing back the same peer, and each entry is
 * released at the event that ends it:
 *
 * - a **navigation** at `onNavigationCompleted`;
 * - a **page** at `onPageDeleted`, which may arrive much later (a page in the back/forward cache
 *   outlives its navigation).
 *
 * A page whose `onPageDeleted` never arrives stays until [dispose], so the maps are bounded by the
 * `WebView`'s lifetime.
 *
 * ### Why it is registered with a direct executor ([register])
 *
 * A snapshot reads androidx's [Navigation] **when the callback runs**, and Chromium mutates that
 * object as the navigation moves on. The two-argument `WebViewCompat.addNavigationListener` posts
 * every callback to the main `Looper`, so by the time one ran the navigation could already be
 * further along. Measured on API 37 (§265): in 1 run of 6 the redirect navigation's
 * `onNavigationStarted` already had the final url and both `onNavigationRedirected` callbacks
 * already had `didCommit() == true` and status 200, which is the device test's intermittent
 * failure. With a direct executor, 0 of 6, and every callback still ran on the main thread (60 / 60),
 * so no synchronisation is needed here, in common with every other client callback in this plugin.
 */
class InAppWebViewNavigationListener(
  private var webView: InAppWebView?
) : NavigationListener, Disposable {

  private val navigationIds = HashMap<Navigation, Long>()
  private val pageIds = HashMap<Page, Long>()
  private var nextNavigationId = 1L
  private var nextPageId = 1L

  private fun navigationId(navigation: Navigation): Long =
    navigationIds.getOrPut(navigation) { nextNavigationId++ }

  private fun pageId(page: Page?): Long? =
    page?.let { pageIds.getOrPut(it) { nextPageId++ } }

  // `internal` for `InAppWebViewNavigationListenerTest`: every caller passes it through
  // `webView?.`, which skips it when there is no WebView, and the JVM test has none.
  internal fun pageSnapshot(page: Page): WebViewPageExt =
    WebViewPageExt.fromPage(page, pageIds.getOrPut(page) { nextPageId++ })

  private fun snapshot(navigation: Navigation): WebViewNavigationExt =
    WebViewNavigationExt.fromNavigation(
      navigation,
      navigationId(navigation),
      pageId(navigation.page)
    )

  override fun onNavigationStarted(navigation: Navigation) {
    webView?.channelDelegate?.onNavigationStarted(snapshot(navigation))
  }

  override fun onNavigationRedirected(navigation: Navigation) {
    webView?.channelDelegate?.onNavigationRedirected(snapshot(navigation))
  }

  override fun onNavigationCompleted(navigation: Navigation) {
    // The snapshot is taken before the id is released, so the completed event still carries the id
    // that ties it to the started/redirected events.
    val ext = snapshot(navigation)
    navigationIds.remove(navigation)
    webView?.channelDelegate?.onNavigationCompleted(ext)
  }

  override fun onPageLoadEvent(page: Page) {
    webView?.channelDelegate?.onPageLoadEvent(pageSnapshot(page))
  }

  override fun onPageDomContentLoadedEvent(page: Page) {
    webView?.channelDelegate?.onPageDomContentLoadedEvent(pageSnapshot(page))
  }

  /**
   * Reports the page as destroyed **and** releases its id.
   *
   * The order matters: the snapshot is taken first, so the event Dart receives still carries the id
   * it has been keying on, and only then is the entry dropped. This is the one place a page id can
   * be released — a page in the back/forward cache outlives the navigation that created it and may
   * never arrive here at all.
   */
  override fun onPageDeleted(page: Page) {
    val ext = pageSnapshot(page)
    pageIds.remove(page)
    webView?.channelDelegate?.onPageDeleted(ext)
  }

  override fun onFirstContentfulPaintMillis(page: Page, durationMillis: Long) {
    webView?.channelDelegate?.onFirstContentfulPaintMillis(pageSnapshot(page), durationMillis)
  }

  override fun onLargestContentfulPaintMillis(page: Page, durationMillis: Long) {
    webView?.channelDelegate?.onLargestContentfulPaintMillis(pageSnapshot(page), durationMillis)
  }

  /**
   * The only callback in this family gated by a second setting.
   *
   * A page calls `performance.mark()` as often as it likes — an instrumented one makes hundreds of
   * calls during a single load — so forwarding this unconditionally would put a channel message on
   * the hot path of every page load. The native callback still arrives; what the setting buys is
   * that it stops here instead of crossing the channel.
   */
  override fun onPerformanceMarkMillis(page: Page, markName: String, markTimeMillis: Long) {
    val webView = this.webView ?: return
    if (!webView.customSettings.useOnPerformanceMarkMillis) {
      return
    }
    webView.channelDelegate?.onPerformanceMarkMillis(
      pageSnapshot(page), markName, markTimeMillis
    )
  }

  companion object {
    /** Registers [listener] on [webView] so each callback runs as Chromium makes it (see above). */
    fun register(webView: InAppWebView, listener: InAppWebViewNavigationListener) {
      WebViewCompat.addNavigationListener(webView, { it.run() }, listener)
    }
  }

  override fun dispose() {
    navigationIds.clear()
    pageIds.clear()
    webView = null
  }
}
