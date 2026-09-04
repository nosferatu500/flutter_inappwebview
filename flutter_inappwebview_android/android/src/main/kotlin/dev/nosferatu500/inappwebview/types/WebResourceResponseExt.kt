package dev.nosferatu500.inappwebview.types

import android.webkit.WebResourceResponse
import androidx.webkit.WebResourceResponseCompat
import dev.nosferatu500.inappwebview.Util
import java.io.ByteArrayInputStream
import java.util.Arrays

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
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

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): WebResourceResponseExt? {
      if (map == null) {
        return null
      }
      val contentType = map["contentType"] as String?
      val contentEncoding = map["contentEncoding"] as String?
      val statusCode = map["statusCode"] as Int?
      val reasonPhrase = map["reasonPhrase"] as String?
      val headers = map["headers"] as Map<String, String>?
      val data = map["data"] as ByteArray?
      val cookies = map["cookies"] as List<String>?
      return WebResourceResponseExt(
        contentType, contentEncoding, statusCode, reasonPhrase, headers, data, cookies
      )
    }
  }
}
