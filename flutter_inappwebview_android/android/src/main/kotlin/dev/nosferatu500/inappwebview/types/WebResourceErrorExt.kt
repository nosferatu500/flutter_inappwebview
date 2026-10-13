package dev.nosferatu500.inappwebview.types

import android.webkit.WebResourceError
import androidx.webkit.WebResourceErrorCompat
import androidx.webkit.WebViewFeature

class WebResourceErrorExt(var type: Int, var description: String) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "type" to type,
    "description" to description
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebResourceErrorExt
    if (type != other.type) return false
    return description == other.description
  }

  override fun hashCode(): Int {
    var result = type
    result = 31 * result + description.hashCode()
    return result
  }

  override fun toString(): String =
    "WebResourceErrorExt{type=$type, description='$description'}"

  companion object {
    @JvmStatic
    fun fromWebResourceError(error: WebResourceError): WebResourceErrorExt =
      WebResourceErrorExt(error.errorCode, error.description.toString())

    @JvmStatic
    fun fromWebResourceError(error: WebResourceErrorCompat): WebResourceErrorExt {
      var type = -1
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE)) {
        type = error.errorCode
      }
      var description = ""
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION)) {
        description = error.description.toString()
      }
      return WebResourceErrorExt(type, description)
    }
  }
}
