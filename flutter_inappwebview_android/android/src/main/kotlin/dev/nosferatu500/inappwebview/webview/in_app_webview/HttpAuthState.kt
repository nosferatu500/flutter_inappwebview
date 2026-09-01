package dev.nosferatu500.inappwebview.webview.in_app_webview

import dev.nosferatu500.inappwebview.types.URLCredential

/**
 * The `onReceivedHttpAuthRequest` state of **one** WebView: the saved credentials still to try, the
 * protection space they were fetched for, and how many times this space has challenged.
 *
 * This used to be two `private var`s in the `companion object` of [InAppWebViewClient] *and* of
 * [InAppWebViewClientCompat] — process-global, so every WebView in the app shared one queue and one
 * counter. Two defects came out of that, and a third out of the queue itself:
 *
 * - **A queue filled for one host could be popped for another.** The list is *fetched* by matching
 *   host + protocol + realm + port, but only when it is null; nothing re-checked that a credential
 *   being handed out belonged to the space now being challenged. One page with authenticated
 *   subresources on a second origin is enough — no second WebView required. That sends a password
 *   saved for host A to host B.
 * - **Any WebView's `onPageFinished` / `onReceivedError` emptied the queue**, mid-challenge, for
 *   every other WebView.
 * - **The failure count is reported to Dart** as `HttpAuthenticationChallenge.previousFailureCount`,
 *   which apps use to stop retrying, so one WebView's failures could make another WebView's handler
 *   give up.
 *
 * Holding the space alongside the queue fixes the first; being an instance field of a per-WebView
 * client fixes the second and third.
 *
 * Its state changes only from `WebViewClient` callbacks, which are delivered on the UI thread, so
 * it is deliberately unsynchronised — the same assumption the two statics made.
 *
 * It is a plain object with no `android.*` in it **so that a JVM unit test can reach it**: this
 * module leaves `returnDefaultValues` off, so anything touching `WebView`, `Context` or
 * `CredentialDatabase` throws `Stub!` in a unit test. Same reason [HeadlessWebViewSize] exists.
 */
class HttpAuthState {

  private data class ProtectionSpaceKey(
    val host: String?,
    val protocol: String?,
    val realm: String?,
    val port: Int
  )

  private var space: ProtectionSpaceKey? = null
  private var credentials: MutableList<URLCredential>? = null
  private var failureCount = 0

  /**
   * Records that [host] / [protocol] / [realm] / [port] has challenged, and returns the value to
   * report as `previousFailureCount`.
   *
   * A challenge from a **different** protection space than the one currently held discards
   * everything first: the queue must not be popped for a space it was not filled for, and a
   * failure count belonging to another host must not be reported for this one.
   *
   * The returned count is 1 on a space's first challenge, not 0. That is the behaviour the two
   * statics had (the increment preceded the dispatch) and it is deliberately unchanged here —
   * iOS reports `URLAuthenticationChallenge.previousFailureCount`, which starts at 0, so the two
   * platforms disagree by one. Reconciling them is a separate decision and is filed.
   */
  fun beginChallenge(host: String?, protocol: String?, realm: String?, port: Int): Int {
    val challenged = ProtectionSpaceKey(host, protocol, realm, port)
    if (space != challenged) {
      reset()
      space = challenged
    }
    failureCount++
    return failureCount
  }

  /** Whether the credential queue still has to be fetched for the current space. */
  fun needsCredentials(): Boolean = credentials == null

  /** Fills the queue for the space named by the last [beginChallenge]. */
  fun setCredentials(fetched: List<URLCredential>) {
    credentials = fetched.toMutableList()
  }

  /**
   * The credential that would be offered next, without consuming it.
   *
   * This is what travels to Dart as `HttpAuthenticationChallenge.proposedCredential`, so it must
   * not remove anything: the app may answer with something else entirely.
   */
  fun peekCredential(): URLCredential? = credentials?.firstOrNull()

  /** Takes the next credential to try, or null when the queue is empty or was never filled. */
  fun popCredential(): URLCredential? {
    val queue = credentials
    if (queue == null || queue.isEmpty()) {
      return null
    }
    return queue.removeAt(0)
  }

  /**
   * Forgets the queue, the space and the failure count.
   *
   * Called when the page finishes or fails, and when the app answers `CANCEL` — all three mean the
   * current authentication conversation is over.
   */
  fun reset() {
    space = null
    credentials = null
    failureCount = 0
  }
}
