package dev.nosferatu500.inappwebview.types

import android.webkit.WebResourceResponse
import dev.nosferatu500.inappwebview.Util
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
  var data: ByteArray?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "contentType" to contentType,
    "contentEncoding" to contentEncoding,
    "statusCode" to statusCode,
    "reasonPhrase" to reasonPhrase,
    "headers" to headers,
    "data" to data
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebResourceResponseExt
    if (contentType != other.contentType) return false
    if (contentEncoding != other.contentEncoding) return false
    if (statusCode != other.statusCode) return false
    if (reasonPhrase != other.reasonPhrase) return false
    if (headers != other.headers) return false
    return data.contentEquals(other.data)
  }

  override fun hashCode(): Int {
    var result = contentType?.hashCode() ?: 0
    result = 31 * result + (contentEncoding?.hashCode() ?: 0)
    result = 31 * result + (statusCode?.hashCode() ?: 0)
    result = 31 * result + (reasonPhrase?.hashCode() ?: 0)
    result = 31 * result + (headers?.hashCode() ?: 0)
    result = 31 * result + data.contentHashCode()
    return result
  }

  override fun toString(): String =
    "WebResourceResponseExt{contentType='$contentType', contentEncoding='$contentEncoding', " +
      "statusCode=$statusCode, reasonPhrase='$reasonPhrase', headers=$headers, " +
      "data=${Arrays.toString(data)}}"

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
      return WebResourceResponseExt(
        contentType, contentEncoding, statusCode, reasonPhrase, headers, data
      )
    }
  }
}
