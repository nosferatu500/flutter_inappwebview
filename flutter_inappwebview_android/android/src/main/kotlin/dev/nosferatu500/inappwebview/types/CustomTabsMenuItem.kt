package dev.nosferatu500.inappwebview.types

class CustomTabsMenuItem(var id: Int, var label: String) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as CustomTabsMenuItem
    if (id != other.id) return false
    return label == other.label
  }

  override fun hashCode(): Int {
    var result = id
    result = 31 * result + label.hashCode()
    return result
  }

  override fun toString(): String = "CustomTabsMenuItem{id=$id, label='$label'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): CustomTabsMenuItem? {
      if (map == null) {
        return null
      }
      val id = map["id"] as Int
      val label = map["label"] as String
      return CustomTabsMenuItem(id, label)
    }
  }
}
