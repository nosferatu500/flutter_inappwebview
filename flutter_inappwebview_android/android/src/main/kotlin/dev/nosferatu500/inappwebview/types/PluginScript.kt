package dev.nosferatu500.inappwebview.types

class PluginScript(
  groupName: String?,
  source: String,
  injectionTime: UserScriptInjectionTime,
  contentWorld: ContentWorld?,
  var isRequiredInAllContentWorlds: Boolean,
  allowedOriginRules: Set<String>?,
  forMainFrameOnly: Boolean
) : UserScript(
  groupName,
  source,
  injectionTime,
  contentWorld,
  allowedOriginRules,
  forMainFrameOnly
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    if (!super.equals(other)) return false
    return isRequiredInAllContentWorlds == (other as PluginScript).isRequiredInAllContentWorlds
  }

  override fun hashCode(): Int {
    var result = super.hashCode()
    result = 31 * result + (if (isRequiredInAllContentWorlds) 1 else 0)
    return result
  }

  override fun toString(): String =
    "PluginScript{requiredInContentWorld=$isRequiredInAllContentWorlds} ${super.toString()}"
}
