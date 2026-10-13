package dev.nosferatu500.inappwebview.types

import java.util.Arrays

class CustomTabsActionButton(
  var id: Int,
  var icon: ByteArray,
  var description: String,
  var isShouldTint: Boolean
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as CustomTabsActionButton
    if (id != other.id) return false
    if (isShouldTint != other.isShouldTint) return false
    if (!icon.contentEquals(other.icon)) return false
    return description == other.description
  }

  override fun hashCode(): Int {
    var result = id
    result = 31 * result + icon.contentHashCode()
    result = 31 * result + description.hashCode()
    result = 31 * result + (if (isShouldTint) 1 else 0)
    return result
  }

  override fun toString(): String =
    "CustomTabsActionButton{id=$id, icon=${Arrays.toString(icon)}, " +
      "description='$description', shouldTint=$isShouldTint}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): CustomTabsActionButton? {
      if (map == null) {
        return null
      }
      val id = map["id"] as Int
      val icon = map["icon"] as ByteArray
      val description = map["description"] as String
      val shouldTint = map["shouldTint"] as Boolean
      return CustomTabsActionButton(id, icon, description, shouldTint)
    }
  }
}
