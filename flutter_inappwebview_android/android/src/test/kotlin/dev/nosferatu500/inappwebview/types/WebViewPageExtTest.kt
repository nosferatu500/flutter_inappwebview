package dev.nosferatu500.inappwebview.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * [WebViewPageExt] is the wire type behind the page-lifecycle and Web-Vitals events.
 *
 * As in [WebViewNavigationExtTest], only `toMap()` is exercised: `fromPage` takes an
 * `androidx.webkit.Page`, which is `final` with a private constructor and reachable only from a
 * real WebView provider through `getOrCreatePeer`. What is protected here is the pair of key names
 * that `WebViewPage.fromMap` reads by literal string on the Dart side.
 */
class WebViewPageExtTest {

  @Test
  fun `toMap uses the keys the Dart side reads`() {
    val map = WebViewPageExt(4L, "https://example.com/").toMap()

    assertEquals(setOf("id", "url"), map.keys)
    assertEquals(4L, map["id"])
    assertEquals("https://example.com/", map["url"])
  }

  @Test
  fun `a null url stays present and null`() {
    // `WebViewPage.url` is nullable on the Dart side, so an absent url must arrive as an explicit
    // null rather than a missing key or an empty string.
    val map = WebViewPageExt(1L, null).toMap()

    assertTrue(map.containsKey("url"))
    assertNull(map["url"])
  }

  @Test
  fun `the id is carried as a Long, matching the navigation page id`() {
    // `WebViewNavigationExt.pageId` and this `id` are the same synthesised counter and must stay
    // the same width on the wire; a mismatch would only show up as a failed correlation at runtime.
    val page = WebViewPageExt(7L, null).toMap()
    val navigation = WebViewNavigationExt(
      id = 1L,
      pageId = 7L,
      url = null,
      wasInitiatedByPage = false,
      isSameDocument = false,
      isReload = false,
      isHistory = false,
      isBack = false,
      isForward = false,
      isRestore = false,
      didCommit = true,
      didCommitErrorPage = false,
      statusCode = 200,
      webResourceError = null
    ).toMap()

    assertEquals(page["id"], navigation["pageId"])
  }
}
