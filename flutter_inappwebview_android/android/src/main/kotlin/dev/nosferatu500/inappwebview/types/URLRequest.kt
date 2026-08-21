package dev.nosferatu500.inappwebview.types

import java.util.Arrays

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class URLRequest(
  var url: String?,
  var method: String?,
  var body: ByteArray?,
  var headers: Map<String, String>?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "url" to url,
    "method" to method,
    "headers" to headers,
    "body" to body,
    "allowsCellularAccess" to null,
    "allowsConstrainedNetworkAccess" to null,
    "allowsExpensiveNetworkAccess" to null,
    "cachePolicy" to null,
    "httpShouldHandleCookies" to null,
    "httpShouldUsePipelining" to null,
    "networkServiceType" to null,
    "timeoutInterval" to null,
    "mainDocumentURL" to null,
    "assumesHTTP3Capable" to null,
    "attribution" to null
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as URLRequest
    if (url != other.url) return false
    if (method != other.method) return false
    if (!body.contentEquals(other.body)) return false
    return headers == other.headers
  }

  override fun hashCode(): Int {
    var result = url?.hashCode() ?: 0
    result = 31 * result + (method?.hashCode() ?: 0)
    result = 31 * result + body.contentHashCode()
    result = 31 * result + (headers?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "URLRequest{url='$url', method='$method', body=${Arrays.toString(body)}, headers=$headers}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): URLRequest? {
      if (map == null) {
        return null
      }
      val url = map["url"] as String? ?: "about:blank"
      val method = map["method"] as String?
      val body = map["body"] as ByteArray?
      val headers = map["headers"] as Map<String, String>?
      return URLRequest(url, method, body, headers)
    }
  }
}
