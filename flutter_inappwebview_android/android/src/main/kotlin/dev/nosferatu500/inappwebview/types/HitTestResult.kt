package dev.nosferatu500.inappwebview.types

import android.webkit.WebView

class HitTestResult(var type: Int, var extra: String?) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "type" to type,
    "extra" to extra
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as HitTestResult
    if (type != other.type) return false
    return extra == other.extra
  }

  override fun hashCode(): Int {
    var result = type
    result = 31 * result + (extra?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "HitTestResultMap{type=$type, extra='$extra'}"

  companion object {
    @JvmStatic
    fun fromWebViewHitTestResult(hitTestResult: WebView.HitTestResult?): HitTestResult? {
      if (hitTestResult == null) {
        return null
      }
      return HitTestResult(hitTestResult.type, hitTestResult.extra)
    }
  }
}
