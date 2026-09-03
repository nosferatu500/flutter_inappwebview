package dev.nosferatu500.inappwebview.types

import androidx.webkit.Navigation
import androidx.webkit.WebViewFeature

/**
 * A serialisable snapshot of an [androidx.webkit.Navigation].
 *
 * A snapshot is not a convenience here, it is the only correct shape. androidx hands the *same*
 * [Navigation] object to `onNavigationStarted`, `onNavigationRedirected` and
 * `onNavigationCompleted` — the peer is interned by `getOrCreatePeer`, so object identity is what
 * ties the callbacks together — and it mutates in place: `getUrl()`, `didCommit()` and
 * `getStatusCode()` all answer differently at different points in the same navigation. Nothing of
 * that identity survives a method channel, so the Kotlin side reads the values at the instant of
 * each callback and carries a synthesised [id] instead.
 */
class WebViewNavigationExt(
  var id: Long,
  var pageId: Long?,
  var url: String?,
  var wasInitiatedByPage: Boolean,
  var isSameDocument: Boolean,
  var isReload: Boolean,
  var isHistory: Boolean,
  var isBack: Boolean,
  var isForward: Boolean,
  var isRestore: Boolean,
  var didCommit: Boolean,
  var didCommitErrorPage: Boolean,
  var statusCode: Int?,
  var webResourceError: WebResourceErrorExt?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "id" to id,
    "pageId" to pageId,
    "url" to url,
    "wasInitiatedByPage" to wasInitiatedByPage,
    "isSameDocument" to isSameDocument,
    "isReload" to isReload,
    "isHistory" to isHistory,
    "isBack" to isBack,
    "isForward" to isForward,
    "isRestore" to isRestore,
    "didCommit" to didCommit,
    "didCommitErrorPage" to didCommitErrorPage,
    "statusCode" to statusCode,
    "webResourceError" to webResourceError?.toMap()
  )

  override fun toString(): String =
    "WebViewNavigationExt{id=$id, pageId=$pageId, url='$url', didCommit=$didCommit, " +
      "statusCode=$statusCode}"

  companion object {
    /**
     * Reads [navigation] into a snapshot.
     *
     * [id] and [pageId] are supplied by the caller because they are plugin-synthesised identities
     * that must outlive a single callback; this class deliberately keeps no map of its own.
     *
     * Two fields are conditional, for different reasons:
     * - `statusCode` is reported only when the navigation has committed **and** the code is
     *   positive. `didCommit` alone is not enough, and that was measured rather than reasoned:
     *   a same-document navigation (`history.pushState`, a fragment jump) *does* commit, and
     *   `getStatusCode()` then answers **0** — there was no HTTP response to have a status. The
     *   same is true of a `data:` or `file:` URL. `0` is not a valid HTTP status, and letting it
     *   through would break the obvious `statusCode >= 400` test at the call site, so it is mapped
     *   to `null` like every other "no status to report" case. This is a plugin choice, not a
     *   platform one.
     * - `getWebResourceError()` is the single method on [Navigation] that androidx guards with its
     *   own feature check, and calling it unsupported throws `UnsupportedOperationException`
     *   rather than returning null.
     */
    @JvmStatic
    fun fromNavigation(navigation: Navigation, id: Long, pageId: Long?): WebViewNavigationExt {
      val didCommit = navigation.didCommit()
      return WebViewNavigationExt(
        id = id,
        pageId = pageId,
        url = navigation.url,
        wasInitiatedByPage = navigation.wasInitiatedByPage(),
        isSameDocument = navigation.isSameDocument,
        isReload = navigation.isReload,
        isHistory = navigation.isHistory,
        isBack = navigation.isBack,
        isForward = navigation.isForward,
        isRestore = navigation.isRestore,
        didCommit = didCommit,
        didCommitErrorPage = navigation.didCommitErrorPage(),
        statusCode = if (didCommit) navigation.statusCode.takeIf { it > 0 } else null,
        webResourceError = if (
          WebViewFeature.isFeatureSupported(WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR)
        ) {
          navigation.webResourceError?.let { WebResourceErrorExt.fromWebResourceError(it) }
        } else {
          null
        }
      )
    }
  }
}
