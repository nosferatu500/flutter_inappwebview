package dev.nosferatu500.inappwebview.types

import java.util.Arrays

class CustomSchemeResponse(
  var data: ByteArray,
  var contentType: String,
  var contentEncoding: String
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as CustomSchemeResponse
    if (!data.contentEquals(other.data)) return false
    if (contentType != other.contentType) return false
    return contentEncoding == other.contentEncoding
  }

  override fun hashCode(): Int {
    var result = data.contentHashCode()
    result = 31 * result + contentType.hashCode()
    result = 31 * result + contentEncoding.hashCode()
    return result
  }

  override fun toString(): String =
    "CustomSchemeResponse{data=${Arrays.toString(data)}, contentType='$contentType', " +
      "contentEncoding='$contentEncoding'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): CustomSchemeResponse? {
      if (map == null) {
        return null
      }
      val data = map["data"] as ByteArray
      val contentType = map["contentType"] as String
      val contentEncoding = map["contentEncoding"] as String
      return CustomSchemeResponse(data, contentType, contentEncoding)
    }
  }
}
