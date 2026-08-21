package dev.nosferatu500.inappwebview.types

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class CustomTabsSecondaryToolbar(
  var layout: AndroidResource,
  var clickableIDs: List<AndroidResource>
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as CustomTabsSecondaryToolbar
    if (layout != other.layout) return false
    return clickableIDs == other.clickableIDs
  }

  override fun hashCode(): Int {
    var result = layout.hashCode()
    result = 31 * result + clickableIDs.hashCode()
    return result
  }

  override fun toString(): String =
    "CustomTabsSecondaryToolbar{layout=$layout, clickableIDs=$clickableIDs}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): CustomTabsSecondaryToolbar? {
      if (map == null) {
        return null
      }
      val layout = AndroidResource.fromMap(map["layout"] as Map<String, Any?>?)!!
      val clickableIDs = mutableListOf<AndroidResource>()
      val clickableIDList = map["clickableIDs"] as List<Map<String, Any?>>?
      if (clickableIDList != null) {
        for (clickableIDMap in clickableIDList) {
          val clickableID = AndroidResource.fromMap(clickableIDMap["id"] as Map<String, Any?>?)
          if (clickableID != null) {
            clickableIDs.add(clickableID)
          }
        }
      }
      return CustomTabsSecondaryToolbar(layout, clickableIDs)
    }
  }
}
