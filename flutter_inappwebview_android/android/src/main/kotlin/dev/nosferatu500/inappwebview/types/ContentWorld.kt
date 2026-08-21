package dev.nosferatu500.inappwebview.types

class ContentWorld private constructor(var name: String) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    return name == (other as ContentWorld).name
  }

  override fun hashCode(): Int = name.hashCode()

  override fun toString(): String = "ContentWorld{name='$name'}"

  companion object {
    @JvmField
    val PAGE: ContentWorld = ContentWorld("page")

    @JvmField
    val DEFAULT_CLIENT: ContentWorld = ContentWorld("defaultClient")

    @JvmStatic
    fun world(name: String): ContentWorld = ContentWorld(name)

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ContentWorld? {
      if (map == null) {
        return null
      }
      val name = map["name"] as String
      return ContentWorld(name)
    }
  }
}
