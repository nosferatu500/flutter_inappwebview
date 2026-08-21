package dev.nosferatu500.inappwebview.types

import android.webkit.WebResourceRequest
import androidx.webkit.WebResourceRequestCompat
import androidx.webkit.WebViewFeature

class WebResourceRequestExt(
  var url: String,
  var headers: Map<String, String>?,
  var isRedirect: Boolean,
  var hasGesture: Boolean,
  var isForMainFrame: Boolean,
  var method: String?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "url" to url,
    "headers" to headers,
    "isRedirect" to isRedirect,
    "hasGesture" to hasGesture,
    "isForMainFrame" to isForMainFrame,
    "method" to method
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebResourceRequestExt
    if (isRedirect != other.isRedirect) return false
    if (hasGesture != other.hasGesture) return false
    if (isForMainFrame != other.isForMainFrame) return false
    if (url != other.url) return false
    if (headers != other.headers) return false
    return method == other.method
  }

  override fun hashCode(): Int {
    var result = url.hashCode()
    result = 31 * result + (headers?.hashCode() ?: 0)
    result = 31 * result + (if (isRedirect) 1 else 0)
    result = 31 * result + (if (hasGesture) 1 else 0)
    result = 31 * result + (if (isForMainFrame) 1 else 0)
    result = 31 * result + (method?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "WebResourceRequestExt{url=$url, headers=$headers, isRedirect=$isRedirect, " +
      "hasGesture=$hasGesture, isForMainFrame=$isForMainFrame, method='$method'}"

  companion object {
    @JvmStatic
    fun fromWebResourceRequest(request: WebResourceRequest): WebResourceRequestExt {
      val isRedirect =
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT)) {
          WebResourceRequestCompat.isRedirect(request)
        } else {
          request.isRedirect
        }
      return WebResourceRequestExt(
        request.url.toString(),
        request.requestHeaders,
        isRedirect,
        request.hasGesture(),
        request.isForMainFrame,
        request.method
      )
    }
  }
}
