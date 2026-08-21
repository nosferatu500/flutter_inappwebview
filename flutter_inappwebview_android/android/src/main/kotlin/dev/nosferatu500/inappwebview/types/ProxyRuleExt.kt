package dev.nosferatu500.inappwebview.types

import androidx.webkit.ProxyConfig

class ProxyRuleExt(
  @get:ProxyConfig.ProxyScheme var schemeFilter: String?,
  var url: String
) {

  fun toMap(): MutableMap<String, String?> = hashMapOf(
    "url" to url,
    "schemeFilter" to schemeFilter
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ProxyRuleExt
    if (schemeFilter != other.schemeFilter) return false
    return url == other.url
  }

  override fun hashCode(): Int {
    var result = schemeFilter?.hashCode() ?: 0
    result = 31 * result + url.hashCode()
    return result
  }

  override fun toString(): String = "ProxyRuleExt{schemeFilter='$schemeFilter', url='$url'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, String>?): ProxyRuleExt? {
      if (map == null) {
        return null
      }
      val url = map["url"]!!
      val schemeFilter = map["schemeFilter"]
      return ProxyRuleExt(schemeFilter, url)
    }
  }
}
