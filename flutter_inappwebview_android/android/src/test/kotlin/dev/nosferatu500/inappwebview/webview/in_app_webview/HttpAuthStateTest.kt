package dev.nosferatu500.inappwebview.webview.in_app_webview

import dev.nosferatu500.inappwebview.types.URLCredential
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * [HttpAuthState] — the per-WebView replacement for two statics on [InAppWebViewClient] and
 * [InAppWebViewClientCompat].
 *
 * The cross-WebView half of the defect cannot be asserted here (it was fixed by *where* the state
 * lives, not by what it does), and cannot be asserted on a device either: two WebViews
 * authenticating at once are not drivable from `WidgetTester`. What is testable is the guard that
 * makes the state safe within one WebView — the protection space — and that half was a real bug in
 * its own right.
 */
class HttpAuthStateTest {

  private fun credential(user: String) = URLCredential(user, "pw-$user")

  @Test
  fun `a queue filled for one space is not handed out for another`() {
    // The security case, and it needs no second WebView: one page with authenticated subresources
    // on a second origin reaches it. Before the fix nothing re-checked the space between filling
    // the queue and popping it, so host B was offered a password saved for host A.
    val state = HttpAuthState()

    state.beginChallenge("a.example.com", "https", "realm", 443)
    assertTrue(state.needsCredentials())
    state.setCredentials(listOf(credential("alice")))
    assertEquals("alice", state.peekCredential()?.username)

    state.beginChallenge("b.example.com", "https", "realm", 443)
    assertTrue("the queue must be refetched for the new space", state.needsCredentials())
    assertNull("host B must not be offered host A's credential", state.peekCredential())
    assertNull(state.popCredential())
  }

  @Test
  fun `every component of the protection space is part of its identity`() {
    // Host is the obvious one; realm and port are not, and a rule that ignored them would still
    // pass the test above.
    val base = listOf("host", "https", "realm", 443)
    val others = listOf(
      listOf("other", "https", "realm", 443),
      listOf("host", "http", "realm", 443),
      listOf("host", "https", "other", 443),
      listOf("host", "https", "realm", 8443)
    )
    for (other in others) {
      val state = HttpAuthState()
      state.beginChallenge(base[0] as String, base[1] as String, base[2] as String, base[3] as Int)
      state.setCredentials(listOf(credential("alice")))
      state.beginChallenge(
        other[0] as String, other[1] as String, other[2] as String, other[3] as Int
      )
      assertTrue("space differing by $other must discard the queue", state.needsCredentials())
    }
  }

  @Test
  fun `the same space keeps its queue across challenges`() {
    // The other half: a repeated challenge for one space must walk the queue rather than refetch
    // it, or every attempt would offer the same credential forever.
    val state = HttpAuthState()

    state.beginChallenge("host", "https", "realm", 443)
    state.setCredentials(listOf(credential("alice"), credential("bob")))

    assertEquals("alice", state.popCredential()?.username)
    state.beginChallenge("host", "https", "realm", 443)
    assertFalse(state.needsCredentials())
    assertEquals("bob", state.popCredential()?.username)
  }

  @Test
  fun `the failure count is per space and does not leak between hosts`() {
    // This is what reaches Dart as HttpAuthenticationChallenge.previousFailureCount, which apps
    // use to stop retrying. Being process-global, one host's failures could make another host's
    // handler give up.
    val state = HttpAuthState()

    assertEquals(1, state.beginChallenge("a.example.com", "https", "realm", 443))
    assertEquals(2, state.beginChallenge("a.example.com", "https", "realm", 443))
    assertEquals(3, state.beginChallenge("a.example.com", "https", "realm", 443))

    assertEquals(
      "a fresh space starts its own count",
      1,
      state.beginChallenge("b.example.com", "https", "realm", 443)
    )
  }

  @Test
  fun `the first challenge of a space reports one, not zero`() {
    // Pinned deliberately rather than corrected: the statics incremented before dispatching, so
    // this is Android's existing behaviour, and iOS reports URLAuthenticationChallenge's count
    // which starts at 0. The platforms disagree by one; reconciling them is filed as its own row.
    // If that decision is ever taken, this assertion is the one to change.
    assertEquals(1, HttpAuthState().beginChallenge("host", "https", "realm", 443))
  }

  @Test
  fun `reset forgets the queue, the space and the count`() {
    val state = HttpAuthState()
    state.beginChallenge("host", "https", "realm", 443)
    state.setCredentials(listOf(credential("alice")))

    state.reset()

    assertTrue(state.needsCredentials())
    assertNull(state.peekCredential())
    assertEquals(1, state.beginChallenge("host", "https", "realm", 443))
  }

  @Test
  fun `peek does not consume, so the proposed credential survives to be popped`() {
    // peekCredential is what travels to Dart as `proposedCredential`; if it consumed, a
    // USE_SAVED_HTTP_AUTH_CREDENTIALS answer would offer the *second* credential.
    val state = HttpAuthState()
    state.beginChallenge("host", "https", "realm", 443)
    state.setCredentials(listOf(credential("alice"), credential("bob")))

    assertEquals("alice", state.peekCredential()?.username)
    assertEquals("alice", state.peekCredential()?.username)
    assertEquals("alice", state.popCredential()?.username)
  }

  @Test
  fun `popping an empty or unfilled queue is null rather than a throw`() {
    val state = HttpAuthState()
    // Never filled: this is the path taken when the app answers USE_SAVED without the database
    // having been consulted, and it must cancel rather than crash.
    assertNull(state.popCredential())

    state.beginChallenge("host", "https", "realm", 443)
    state.setCredentials(emptyList())
    assertFalse("an empty fetch still counts as fetched", state.needsCredentials())
    assertNull(state.popCredential())
  }

  @Test
  fun `a null host is a protection space like any other`() {
    // `onReceivedHttpAuthRequest` declares host and realm nullable, and the old code passed them
    // straight through. A null host must not collide with a real one.
    val state = HttpAuthState()
    state.beginChallenge(null, "https", null, 443)
    state.setCredentials(listOf(credential("alice")))

    state.beginChallenge("host", "https", null, 443)
    assertTrue(state.needsCredentials())
  }
}
