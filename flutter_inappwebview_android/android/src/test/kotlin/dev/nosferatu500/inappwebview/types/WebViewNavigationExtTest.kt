package dev.nosferatu500.inappwebview.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * [WebViewNavigationExt] is the wire type behind `onNavigationStarted`, `onNavigationRedirected`
 * and `onNavigationCompleted`.
 *
 * Only [WebViewNavigationExt.toMap] is exercised here, deliberately: `fromNavigation` takes an
 * `androidx.webkit.Navigation`, which is `final`, has a private constructor and can only be
 * obtained from a real WebView provider through `getOrCreatePeer`. There is no way to build one in
 * a JVM unit test, and this module leaves `returnDefaultValues` off on purpose (trap 23), so a
 * stubbed `android.*`/androidx call throws `Stub!` rather than answering. The conditional logic
 * inside `fromNavigation` — the `didCommit` gate on `statusCode` and the feature gate on
 * `webResourceError` — is therefore covered by the integration suite, not here.
 *
 * What this file protects is the half that is pure data and that fails silently: the fourteen key
 * names, which `WebViewNavigation.fromMap` on the Dart side reads by literal string.
 */
class WebViewNavigationExtTest {

  private fun navigation(
    id: Long = 7L,
    pageId: Long? = 3L,
    url: String? = "https://example.com/",
    didCommit: Boolean = true,
    statusCode: Int? = 200,
    webResourceError: WebResourceErrorExt? = null
  ) = WebViewNavigationExt(
    id = id,
    pageId = pageId,
    url = url,
    wasInitiatedByPage = true,
    isSameDocument = false,
    isReload = false,
    isHistory = false,
    isBack = false,
    isForward = false,
    isRestore = false,
    didCommit = didCommit,
    didCommitErrorPage = false,
    statusCode = statusCode,
    webResourceError = webResourceError
  )

  @Test
  fun `toMap uses the keys the Dart side reads`() {
    val map = navigation().toMap()

    assertEquals(
      setOf(
        "id", "pageId", "url", "wasInitiatedByPage", "isSameDocument", "isReload", "isHistory",
        "isBack", "isForward", "isRestore", "didCommit", "didCommitErrorPage", "statusCode",
        "webResourceError"
      ),
      map.keys
    )
    assertEquals(7L, map["id"])
    assertEquals(3L, map["pageId"])
    assertEquals("https://example.com/", map["url"])
    assertEquals(200, map["statusCode"])
    assertEquals(true, map["didCommit"])
  }

  @Test
  fun `the nine classification flags do not get transposed`() {
    // Deliberately asymmetric: a test where every flag is false, or every flag is true, survives
    // any mix-up between two of them.
    val map = WebViewNavigationExt(
      id = 1L,
      pageId = null,
      url = null,
      wasInitiatedByPage = true,
      isSameDocument = false,
      isReload = true,
      isHistory = false,
      isBack = true,
      isForward = false,
      isRestore = true,
      didCommit = false,
      didCommitErrorPage = true,
      statusCode = null,
      webResourceError = null
    ).toMap()

    assertEquals(true, map["wasInitiatedByPage"])
    assertEquals(false, map["isSameDocument"])
    assertEquals(true, map["isReload"])
    assertEquals(false, map["isHistory"])
    assertEquals(true, map["isBack"])
    assertEquals(false, map["isForward"])
    assertEquals(true, map["isRestore"])
    assertEquals(false, map["didCommit"])
    assertEquals(true, map["didCommitErrorPage"])
  }

  @Test
  fun `a null status code stays absent rather than becoming zero`() {
    // An uncommitted navigation reports no status. Sending `0` instead would be indistinguishable
    // from a real response to a Dart caller doing arithmetic on it.
    val map = navigation(didCommit = false, statusCode = null).toMap()

    assertTrue(map.containsKey("statusCode"))
    assertNull(map["statusCode"])
  }

  @Test
  fun `the nested error is flattened to its own map, not left as an object`() {
    // The standard message codec cannot encode a WebResourceErrorExt, so a regression here is a
    // channel-encoding failure on a device rather than a compile error.
    val map = navigation(
      webResourceError = WebResourceErrorExt(-2, "net::ERR_NAME_NOT_RESOLVED")
    ).toMap()

    assertEquals(
      mapOf("type" to -2, "description" to "net::ERR_NAME_NOT_RESOLVED"),
      map["webResourceError"]
    )
  }

  @Test
  fun `a null error stays null rather than becoming an empty map`() {
    // Dart's `WebResourceError.fromMap` returns null for a null map; an empty map would instead
    // throw, because both of its fields are required.
    assertNull(navigation().toMap()["webResourceError"])
  }
}
