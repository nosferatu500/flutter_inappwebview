package dev.nosferatu500.inappwebview.webview.in_app_webview

import androidx.webkit.Navigation
import androidx.webkit.NavigationListener
import androidx.webkit.Page
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebViewNavigationExt
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

  /**
   * Overridden purely to release the page id.
   *
   * There is no Dart `onPageDeleted` event yet — it belongs with the rest of the page lifecycle —
   * but the eviction has to exist from the moment page ids are handed out, otherwise the map grows
   * by one entry per page for as long as the `WebView` lives.
   */
  override fun onPageDeleted(page: Page) {
    pageIds.remove(page)
  }

  override fun dispose() {
    navigationIds.clear()
    pageIds.clear()
    webView = null
  }
}
