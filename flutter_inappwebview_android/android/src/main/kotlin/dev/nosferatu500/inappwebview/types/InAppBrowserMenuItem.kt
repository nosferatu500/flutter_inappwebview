package dev.nosferatu500.inappwebview.types

import dev.nosferatu500.inappwebview.Util
import java.util.Objects

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class InAppBrowserMenuItem(
  var id: Int,
  var title: String,
  var order: Int?,
  var icon: Any?,
  var iconColor: String?,
  var isShowAsAction: Boolean
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as InAppBrowserMenuItem
    if (id != other.id) return false
    if (isShowAsAction != other.isShowAsAction) return false
    if (title != other.title) return false
    if (order != other.order) return false
    if (icon != other.icon) return false
    return iconColor == other.iconColor
  }

  override fun hashCode(): Int {
    var result = id
    result = 31 * result + title.hashCode()
    result = 31 * result + (order?.hashCode() ?: 0)
    result = 31 * result + (icon?.hashCode() ?: 0)
    result = 31 * result + (iconColor?.hashCode() ?: 0)
    result = 31 * result + (if (isShowAsAction) 1 else 0)
    return result
  }

  override fun toString(): String =
    "InAppBrowserMenuItem{id=$id, title='$title', order=$order, icon=$icon, " +
      "iconColor='$iconColor', showAsAction=$isShowAsAction}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): InAppBrowserMenuItem? {
      if (map == null) {
        return null
      }
      val id = map["id"] as Int
      val title = map["title"] as String
      val order = map["order"] as Int?
      var icon = map["icon"]
      icon = when (icon) {
        is Map<*, *> -> AndroidResource.fromMap(icon as Map<String, Any?>)
        is ByteArray -> icon
        else -> null
      }
      val iconColor = map["iconColor"] as String?
      val showAsAction = Util.getOrDefault(map, "showAsAction", false)
      return InAppBrowserMenuItem(id, title, order, icon, iconColor, showAsAction)
    }
  }
}
