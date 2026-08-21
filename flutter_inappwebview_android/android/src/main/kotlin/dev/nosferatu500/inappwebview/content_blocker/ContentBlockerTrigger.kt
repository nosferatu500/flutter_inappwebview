package dev.nosferatu500.inappwebview.content_blocker

import java.util.regex.Pattern

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class ContentBlockerTrigger(
  var urlFilter: String,
  urlFilterIsCaseSensitive: Boolean?,
  resourceType: List<ContentBlockerTriggerResourceType>?,
  ifDomain: List<String>?,
  unlessDomain: List<String>?,
  loadType: List<String>?,
  ifTopUrl: List<String>?,
  unlessTopUrl: List<String>?
) {
  var urlFilterIsCaseSensitive: Boolean = urlFilterIsCaseSensitive ?: false

  var urlFilterPatternCompiled: Pattern = Pattern.compile(
    urlFilter,
    if (urlFilterIsCaseSensitive == true) 0 else Pattern.CASE_INSENSITIVE
  )

  var resourceType: MutableList<ContentBlockerTriggerResourceType> =
    resourceType?.toMutableList() ?: mutableListOf()

  var ifDomain: List<String> = ifDomain ?: ArrayList()
  var unlessDomain: List<String> = unlessDomain ?: ArrayList()
  var loadType: List<String> = loadType ?: ArrayList()
  var ifTopUrl: List<String> = ifTopUrl ?: ArrayList()
  var unlessTopUrl: List<String> = unlessTopUrl ?: ArrayList()

  init {
    if (!(this.ifDomain.isEmpty() || this.unlessDomain.isEmpty())) throw AssertionError()
    if (this.loadType.size > 2) throw AssertionError()
    if (!(this.ifTopUrl.isEmpty() || this.unlessTopUrl.isEmpty())) throw AssertionError()
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ContentBlockerTrigger
    if (urlFilter != other.urlFilter) return false
    if (urlFilterPatternCompiled != other.urlFilterPatternCompiled) return false
    if (urlFilterIsCaseSensitive != other.urlFilterIsCaseSensitive) return false
    if (resourceType != other.resourceType) return false
    if (ifDomain != other.ifDomain) return false
    if (unlessDomain != other.unlessDomain) return false
    if (loadType != other.loadType) return false
    if (ifTopUrl != other.ifTopUrl) return false
    return unlessTopUrl == other.unlessTopUrl
  }

  override fun hashCode(): Int {
    var result = urlFilter.hashCode()
    result = 31 * result + urlFilterPatternCompiled.hashCode()
    result = 31 * result + urlFilterIsCaseSensitive.hashCode()
    result = 31 * result + resourceType.hashCode()
    result = 31 * result + ifDomain.hashCode()
    result = 31 * result + unlessDomain.hashCode()
    result = 31 * result + loadType.hashCode()
    result = 31 * result + ifTopUrl.hashCode()
    result = 31 * result + unlessTopUrl.hashCode()
    return result
  }

  override fun toString(): String =
    "ContentBlockerTrigger{urlFilter='$urlFilter', " +
      "urlFilterPatternCompiled=$urlFilterPatternCompiled, " +
      "urlFilterIsCaseSensitive=$urlFilterIsCaseSensitive, resourceType=$resourceType, " +
      "ifDomain=$ifDomain, unlessDomain=$unlessDomain, loadType=$loadType, " +
      "ifTopUrl=$ifTopUrl, unlessTopUrl=$unlessTopUrl}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>): ContentBlockerTrigger {
      val urlFilter = map["url-filter"] as String
      val urlFilterIsCaseSensitive = map["url-filter-is-case-sensitive"] as Boolean?
      val resourceTypeStringList = map["resource-type"] as List<String>?
      val resourceType = mutableListOf<ContentBlockerTriggerResourceType>()
      if (resourceTypeStringList != null) {
        for (type in resourceTypeStringList) {
          resourceType.add(ContentBlockerTriggerResourceType.fromValue(type))
        }
      } else {
        resourceType.addAll(ContentBlockerTriggerResourceType.entries)
      }
      return ContentBlockerTrigger(
        urlFilter,
        urlFilterIsCaseSensitive,
        resourceType,
        map["if-domain"] as List<String>?,
        map["unless-domain"] as List<String>?,
        map["load-type"] as List<String>?,
        map["if-top-url"] as List<String>?,
        map["unless-top-url"] as List<String>?
      )
    }
  }
}
