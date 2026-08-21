package dev.nosferatu500.inappwebview.types

class DownloadStartRequest(
  var url: String,
  var userAgent: String,
  var contentDisposition: String,
  var mimeType: String,
  var contentLength: Long,
  var suggestedFilename: String?,
  var textEncodingName: String?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "url" to url,
    "userAgent" to userAgent,
    "contentDisposition" to contentDisposition,
    "mimeType" to mimeType,
    "contentLength" to contentLength,
    "suggestedFilename" to suggestedFilename,
    "textEncodingName" to textEncodingName
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as DownloadStartRequest
    if (contentLength != other.contentLength) return false
    if (url != other.url) return false
    if (userAgent != other.userAgent) return false
    if (contentDisposition != other.contentDisposition) return false
    if (mimeType != other.mimeType) return false
    if (suggestedFilename != other.suggestedFilename) return false
    return textEncodingName == other.textEncodingName
  }

  override fun hashCode(): Int {
    var result = url.hashCode()
    result = 31 * result + userAgent.hashCode()
    result = 31 * result + contentDisposition.hashCode()
    result = 31 * result + mimeType.hashCode()
    result = 31 * result + (contentLength xor (contentLength ushr 32)).toInt()
    result = 31 * result + (suggestedFilename?.hashCode() ?: 0)
    result = 31 * result + (textEncodingName?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "DownloadStartRequest{url='$url', userAgent='$userAgent', " +
      "contentDisposition='$contentDisposition', mimeType='$mimeType', " +
      "contentLength=$contentLength, suggestedFilename='$suggestedFilename', " +
      "textEncodingName='$textEncodingName'}"
}
