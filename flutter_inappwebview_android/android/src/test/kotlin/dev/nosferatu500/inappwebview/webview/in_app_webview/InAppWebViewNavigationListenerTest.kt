package dev.nosferatu500.inappwebview.webview.in_app_webview

import androidx.webkit.Page
import org.chromium.support_lib_boundary.WebViewPageBoundaryInterface
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.lang.ref.WeakReference
import java.lang.reflect.Proxy

/**
 * [InAppWebViewNavigationListener] must keep each [Page] it has given an id until `onPageDeleted`.
 *
 * A [Page] is identified by the instance, and Chromium doesn't keep that instance alive: once it
 * is garbage-collected, the same document's next event arrives as a new [Page], which the listener
 * would number as a new page. Measured on API 37 (§260): with weak maps, a GC posted after
 * `onNavigationCompleted` made every page event of the document arrive under a second id, 3 / 3;
 * with strong maps, 0 / 3. A GC can't be forced from a device test, so the retention is pinned
 * here.
 *
 * A real [Page] is built by reflection around a proxy of its boundary interface, which is all the
 * listener reads (`getUrl`). Navigations are held the same way until `onNavigationCompleted`, but a
 * navigation snapshot calls `WebViewFeature.isFeatureSupported`, which needs a WebView provider, so
 * that half isn't reachable on the JVM.
 */
class InAppWebViewNavigationListenerTest {

  private fun page(url: String): Page {
    val impl = Proxy.newProxyInstance(
      javaClass.classLoader,
      arrayOf(WebViewPageBoundaryInterface::class.java)
    ) { _, method, _ -> if (method.name == "getUrl") url else null } as WebViewPageBoundaryInterface
    val constructor =
      Page::class.java.getDeclaredConstructor(WebViewPageBoundaryInterface::class.java)
    constructor.isAccessible = true
    return constructor.newInstance(impl)
  }

  /** Whether [ref]'s referent was collected within a few GC cycles. */
  private fun collected(ref: WeakReference<*>): Boolean {
    repeat(20) {
      System.gc()
      System.runFinalization()
      if (ref.get() == null) return true
      Thread.sleep(10)
    }
    return false
  }

  /**
   * Gives a fresh page an id, as every page event does, and keeps only a weak reference to it.
   * `pageSnapshot` is called directly: the events reach it through `webView?.`, which skips it
   * when there is no WebView.
   */
  private fun numberedPage(listener: InAppWebViewNavigationListener): WeakReference<Page> {
    val page = page("https://example.com/")
    listener.pageSnapshot(page)
    return WeakReference(page)
  }

  @Test
  fun `a page is kept alive until onPageDeleted, then released`() {
    val listener = InAppWebViewNavigationListener(null)
    val ref = numberedPage(listener)

    assertFalse(
      "the listener must hold the page, or the next event for it arrives as a new id",
      collected(ref)
    )

    listener.onPageDeleted(ref.get()!!)
    assertTrue("onPageDeleted must release the page", collected(ref))
  }

  @Test
  fun `dispose releases every page`() {
    val listener = InAppWebViewNavigationListener(null)
    val ref = numberedPage(listener)
    assertFalse(collected(ref))

    listener.dispose()
    assertTrue("a page whose onPageDeleted never came is released at dispose", collected(ref))
  }

  @Test
  fun `the control - an unheld page is collected`() {
    // Without this, `collected` returning false above could mean the JVM never collects anything.
    val ref = WeakReference(page("https://example.com/"))
    assertTrue(collected(ref))
  }
}
