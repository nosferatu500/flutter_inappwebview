package dev.nosferatu500.inappwebview.proxy

import androidx.webkit.ProxyConfig
import dev.nosferatu500.inappwebview.ISettings
import dev.nosferatu500.inappwebview.types.ProxyRuleExt

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class ProxySettings : ISettings<ProxyConfig> {
  @JvmField var bypassRules: List<String> = ArrayList()
  @JvmField var directs: List<String> = ArrayList()
  @JvmField var proxyRules: MutableList<ProxyRuleExt> = ArrayList()
  @JvmField var bypassSimpleHostnames: Boolean? = null
  @JvmField var removeImplicitRules: Boolean? = null
  @JvmField var reverseBypassEnabled: Boolean? = false

  override fun parse(settings: Map<String, Any?>): ProxySettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "bypassRules" -> bypassRules = value as List<String>
        "directs" -> directs = value as List<String>
        "proxyRules" -> {
          proxyRules = ArrayList()
          for (proxyRuleMap in value as List<Map<String, String>>) {
            ProxyRuleExt.fromMap(proxyRuleMap)?.let { proxyRules.add(it) }
          }
        }
        "bypassSimpleHostnames" -> bypassSimpleHostnames = value as Boolean
        "removeImplicitRules" -> removeImplicitRules = value as Boolean
        "reverseBypassEnabled" -> reverseBypassEnabled = value as Boolean
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "bypassRules" to bypassRules,
    "directs" to directs,
    "proxyRules" to proxyRules.map { it.toMap() },
    "bypassSimpleHostnames" to bypassSimpleHostnames,
    "removeImplicitRules" to removeImplicitRules,
    "reverseBypassEnabled" to reverseBypassEnabled
  )

  override fun getRealSettings(obj: ProxyConfig): MutableMap<String, Any?> {
    val realSettings = toMap()
    realSettings["bypassRules"] = obj.bypassRules
    realSettings["proxyRules"] = obj.proxyRules.map { proxyRule ->
      hashMapOf("url" to proxyRule.url, "schemeFilter" to proxyRule.schemeFilter)
    }
    realSettings["reverseBypassEnabled"] = obj.isReverseBypassEnabled
    return realSettings
  }
}
