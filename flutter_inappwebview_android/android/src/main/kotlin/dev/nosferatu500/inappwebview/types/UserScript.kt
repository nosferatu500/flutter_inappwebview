package dev.nosferatu500.inappwebview.types

import java.util.Objects

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
open class UserScript(
  var groupName: String?,
  var source: String,
  var injectionTime: UserScriptInjectionTime,
  contentWorld: ContentWorld?,
  allowedOriginRules: Set<String>?,
  var isForMainFrameOnly: Boolean
) {
  var contentWorld: ContentWorld = contentWorld ?: ContentWorld.PAGE

  var allowedOriginRules: Set<String> = allowedOriginRules ?: hashSetOf("*")

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as UserScript
    return isForMainFrameOnly == other.isForMainFrameOnly &&
      groupName == other.groupName &&
      source == other.source &&
      injectionTime == other.injectionTime &&
      contentWorld == other.contentWorld &&
      allowedOriginRules == other.allowedOriginRules
  }

  override fun hashCode(): Int {
    var result = Objects.hashCode(groupName)
    result = 31 * result + source.hashCode()
    result = 31 * result + injectionTime.hashCode()
    result = 31 * result + contentWorld.hashCode()
    result = 31 * result + allowedOriginRules.hashCode()
    result = 31 * result + isForMainFrameOnly.hashCode()
    return result
  }

  override fun toString(): String =
    "UserScript{groupName='$groupName', source='$source', injectionTime=$injectionTime, " +
      "contentWorld=$contentWorld, allowedOriginRules=$allowedOriginRules, " +
      "forMainFrameOnly=$isForMainFrameOnly}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): UserScript? {
      if (map == null) {
        return null
      }
      val groupName = map["groupName"] as String?
      val source = map["source"] as String
      val injectionTime = UserScriptInjectionTime.fromValue(map["injectionTime"] as Int)
      val contentWorld = ContentWorld.fromMap(map["contentWorld"] as Map<String, Any?>?)
      val allowedOriginRules = HashSet(map["allowedOriginRules"] as List<String>)
      val forMainFrameOnly = map["forMainFrameOnly"] as Boolean
      return UserScript(
        groupName, source, injectionTime, contentWorld, allowedOriginRules, forMainFrameOnly
      )
    }
  }
}
