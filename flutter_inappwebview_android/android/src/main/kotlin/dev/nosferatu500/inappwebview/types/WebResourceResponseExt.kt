package dev.nosferatu500.inappwebview.types

import android.webkit.WebResourceResponse
import androidx.webkit.WebResourceResponseCompat
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.WebResourceResponseData
import java.io.ByteArrayInputStream
import java.util.Arrays

class WebResourceResponseExt(
  var contentType: String?,
  var contentEncoding: String?,
  var statusCode: Int?,
  var reasonPhrase: String?,
  var headers: Map<String, String>?,
  var data: ByteArray?,
  var cookies: List<String>? = null
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "contentType" to contentType,
    "contentEncoding" to contentEncoding,
    "statusCode" to statusCode,
    "reasonPhrase" to reasonPhrase,
    "headers" to headers,
    "data" to data,
    "cookies" to cookies
  )

  /**
   * Builds the platform response to hand back from `shouldInterceptRequest`.
   *
   * This lives on the type rather than at the call sites because there are **three** of them --
   * [InAppWebViewClient], [InAppWebViewClientCompat] (the one that actually runs on Chromium >= 73)
   * and the service-worker client -- and the first two are byte-identical copies. Every previous
   * change to this shape had to be made three times or silently applied to two thirds of the
   * plugin.
   *
   * [cookies] is applied through [WebResourceResponseCompat], which does not produce a different
   * kind of response: `toWebResourceResponse()` folds the values into a private multi-cookie header
   * that the WebView unpacks. So the return type is unchanged and callers are unaffected.
   *
   * The `COOKIE_INTERCEPT` guard is not optional -- `setCookies` **throws**
   * `UnsupportedOperationException` where the feature is missing, rather than returning false.
   * Cookies are then dropped, which is the same thing the platform does when the feature is present
   * but the intercept switch is off.
   */
  fun toWebResourceResponse(): WebResourceResponse {
    val inputStream = data?.let { ByteArrayInputStream(it) }
    val statusCode = statusCode
    val reasonPhrase = reasonPhrase
    val cookies = cookies

    if (cookies.isNullOrEmpty() ||
      !Util.isCookieInterceptSupported()
    ) {
      return if (statusCode != null && reasonPhrase != null) {
        WebResourceResponse(
          contentType, contentEncoding, statusCode, reasonPhrase, headers, inputStream
        )
      } else {
        WebResourceResponse(contentType, contentEncoding, inputStream)
      }
    }

    // The compat constructor requires a non-null reason phrase and a status code >= 100, where the
    // 3-argument framework constructor allows neither to be set. Mirror what the compat class does
    // for itself in that case rather than refusing to carry the cookies.
    val compat = WebResourceResponseCompat(
      contentType ?: "",
      contentEncoding,
      statusCode ?: 200,
      reasonPhrase ?: "OK",
      headers,
      inputStream
    )
    compat.setCookies(cookies)
    return compat.toWebResourceResponse()
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebResourceResponseExt
    if (contentType != other.contentType) return false
    if (contentEncoding != other.contentEncoding) return false
    if (statusCode != other.statusCode) return false
    if (reasonPhrase != other.reasonPhrase) return false
    if (headers != other.headers) return false
    if (cookies != other.cookies) return false
    return data.contentEquals(other.data)
  }

  override fun hashCode(): Int {
    var result = contentType?.hashCode() ?: 0
    result = 31 * result + (contentEncoding?.hashCode() ?: 0)
    result = 31 * result + (statusCode?.hashCode() ?: 0)
    result = 31 * result + (reasonPhrase?.hashCode() ?: 0)
    result = 31 * result + (headers?.hashCode() ?: 0)
    result = 31 * result + (cookies?.hashCode() ?: 0)
    result = 31 * result + data.contentHashCode()
    return result
  }

  override fun toString(): String =
    "WebResourceResponseExt{contentType='$contentType', contentEncoding='$contentEncoding', " +
      "statusCode=$statusCode, reasonPhrase='$reasonPhrase', headers=$headers, " +
      "cookies=$cookies, data=${Arrays.toString(data)}}"

  companion object {
    @JvmStatic
    fun fromWebResourceResponse(response: WebResourceResponse): WebResourceResponseExt =
      WebResourceResponseExt(
        response.mimeType,
        response.encoding,
        response.statusCode,
        response.reasonPhrase,
        response.responseHeaders,
        Util.readAllBytes(response.data)
      )

    /**
     * From the Pigeon form: the service worker's intercept, and since W5 (§216) the WebView's
     * intercept and the custom path handler. It replaces `fromMap`, whose last two callers (the
     * WebView's intercept and the path handler) W5 moved here. `statusCode` narrows from Pigeon's `Long` to the `Int`
     * `WebResourceResponse` takes, a plain `int`, not an `@IntDef`. Every other field crosses
     * unchanged, nullability included, because [toWebResourceResponse] branches on which are present.
     */
    @JvmStatic
    fun fromPigeon(data: WebResourceResponseData): WebResourceResponseExt = WebResourceResponseExt(
      contentType = data.contentType,
      contentEncoding = data.contentEncoding,
      statusCode = data.statusCode?.toInt(),
      reasonPhrase = data.reasonPhrase,
      headers = data.headers,
      data = data.data,
      cookies = data.cookies
    )
  }
}
