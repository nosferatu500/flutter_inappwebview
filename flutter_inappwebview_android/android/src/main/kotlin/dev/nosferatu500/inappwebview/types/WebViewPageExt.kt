package dev.nosferatu500.inappwebview.types

import androidx.webkit.Page

/**
 * A serialisable snapshot of an [androidx.webkit.Page].
 *
 * Like [WebViewNavigationExt] this exists because androidx models "the same page" as object
 * identity — the peer is interned by `getOrCreatePeer` — and identity cannot cross a method
 * channel. The [id] is synthesised by the caller, which owns the identity map.
 *
 * Unlike [androidx.webkit.Navigation], [Page] has **no** feature-gated method: `getUrl()` is a
 * plain boundary call, even though `WebViewFeature.PAGE_GET_URL` exists and is one of the six
 * deprecated, unregistered navigation flags that make `isFeatureSupported` throw. The flag is a
 * tombstone; the method is not, and must not be guarded by it.
 */
class WebViewPageExt(var id: Long, var url: String?) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "id" to id,
    "url" to url
  )

  override fun toString(): String = "WebViewPageExt{id=$id, url='$url'}"

  companion object {
    @JvmStatic
    fun fromPage(page: Page, id: Long): WebViewPageExt = WebViewPageExt(id, page.url)
  }
}
