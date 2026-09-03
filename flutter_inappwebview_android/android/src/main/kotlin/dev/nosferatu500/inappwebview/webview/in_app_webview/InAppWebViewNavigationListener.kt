package dev.nosferatu500.inappwebview.webview.in_app_webview

import androidx.webkit.Navigation
import androidx.webkit.NavigationListener
import androidx.webkit.Page
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebViewNavigationExt
import dev.nosferatu500.inappwebview.types.WebViewPageExt
import java.util.WeakHashMap

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
 * Neither [Navigation] nor [Page] overrides `equals`/`hashCode`, so a [WeakHashMap] keyed by them
 * has exactly the identity semantics required — and, unlike an `IdentityHashMap`, it also drops
 * entries whose key the platform has released, which matters because the two lifetimes are
 * different and one of them has no guaranteed end:
 *
 * - a **navigation** id is released at `onNavigationCompleted`, which always arrives;
 * - a **page** id is released only at `onPageDeleted`, which may arrive much later or, for a page
 *   living in the back/forward cache, never.
 *
 * Releasing them the other way round would leak one entry per navigation for the lifetime of the
 * `WebView`.
 *
 * Callbacks arrive on the main thread — `WebViewCompat.addNavigationListener(WebView,
 * NavigationListener)` posts through a `Handler` on the main `Looper` — so no synchronisation is
 * needed here, in common with every other client callback in this plugin.
 */
class InAppWebViewNavigationListener(
  private var webView: InAppWebView?
) : NavigationListener, Disposable {

  private val navigationIds = WeakHashMap<Navigation, Long>()
  private val pageIds = WeakHashMap<Page, Long>()
  private var nextNavigationId = 1L
  private var nextPageId = 1L

  private fun navigationId(navigation: Navigation): Long =
    navigationIds.getOrPut(navigation) { nextNavigationId++ }

  private fun pageId(page: Page?): Long? =
    page?.let { pageIds.getOrPut(it) { nextPageId++ } }

  private fun pageSnapshot(page: Page): WebViewPageExt =
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

  override fun dispose() {
    navigationIds.clear()
    pageIds.clear()
    webView = null
  }
}
