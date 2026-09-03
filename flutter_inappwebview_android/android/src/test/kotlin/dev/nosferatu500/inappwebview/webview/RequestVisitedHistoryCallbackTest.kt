package dev.nosferatu500.inappwebview.webview

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * `WebViewChannelDelegate.RequestVisitedHistoryCallback.decodeResult` is the one piece of D4 that
 * is pure data and therefore unit-testable: the callback class is nested rather than inner, so it
 * needs no `WebView` and no Android framework (this module leaves `returnDefaultValues` off — see
 * trap 23 — so anything touching `android.*` would throw `Stub!` here).
 *
 * What it protects is the **null / empty distinction**, which the whole design of the event rests
 * on and which is invisible on a device:
 *
 *  * `null` reaching `decodeResult` means Dart declined, and the caller falls through to
 *    `super.getVisitedHistory` — the platform default, where the engine is never answered;
 *  * an **empty** list is a real answer, "nothing has been visited", and must survive as a non-null
 *    empty list rather than collapsing to `null`.
 *
 * Both render identically in a page, so nothing downstream could catch a regression.
 */
class RequestVisitedHistoryCallbackTest {

  private val callback = WebViewChannelDelegate.RequestVisitedHistoryCallback()

  @Test
  fun `a list of strings decodes verbatim`() {
    assertEquals(
      listOf("https://example.com/one", "https://example.com/two"),
      callback.decodeResult(listOf("https://example.com/one", "https://example.com/two"))
    )
  }

  @Test
  fun `an empty list stays an empty list and does not become null`() {
    val decoded = callback.decodeResult(emptyList<String>())

    assertTrue(
      "an empty answer must remain distinguishable from a declined one",
      decoded != null
    )
    assertTrue(decoded!!.isEmpty())
  }

  @Test
  fun `null decodes to null, which is what selects the platform default`() {
    assertNull(callback.decodeResult(null))
  }

  @Test
  fun `a non-list decodes to null rather than throwing`() {
    // The codec boundary is unverifiable by construction, and this callback runs on the platform
    // thread; a wrong shape should select the platform default, not take the process down.
    assertNull(callback.decodeResult("not a list"))
  }

  @Test
  fun `stray non-string elements are dropped rather than throwing`() {
    // `filterIsInstance` rather than a cast of the element type: a Dart list that somehow carried
    // a non-string would otherwise throw a ClassCastException deep in the callback.
    assertEquals(
      listOf("https://example.com/"),
      callback.decodeResult(listOf("https://example.com/", 42, null))
    )
  }

  @Test
  fun `nullSuccess runs the default behaviour`() {
    // The contract `BaseCallbackResultImpl` gives the Kotlin override: a null result must reach
    // `defaultBehaviour`, which is where the fall-through to `super` lives.
    var defaulted = false
    val probe = object : WebViewChannelDelegate.RequestVisitedHistoryCallback() {
      override fun defaultBehaviour(result: List<String>?) {
        defaulted = true
      }
    }

    probe.success(null)

    assertTrue("a declined answer must reach defaultBehaviour", defaulted)
  }

  @Test
  fun `a non-null result can suppress the default behaviour`() {
    // The mirror of the test above: the real override returns false from `nonNullSuccess` after
    // answering the engine, and that must stop `defaultBehaviour` from also running -- otherwise
    // every answered request would additionally fall through to `super`.
    var defaulted = false
    val probe = object : WebViewChannelDelegate.RequestVisitedHistoryCallback() {
      override fun nonNullSuccess(result: List<String>): Boolean = false

      override fun defaultBehaviour(result: List<String>?) {
        defaulted = true
      }
    }

    probe.success(listOf("https://example.com/"))

    assertTrue("answering must not also run the default behaviour", !defaulted)
  }
}
