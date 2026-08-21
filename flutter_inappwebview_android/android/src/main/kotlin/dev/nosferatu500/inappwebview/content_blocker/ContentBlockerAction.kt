package dev.nosferatu500.inappwebview.content_blocker

class ContentBlockerAction internal constructor(
  var type: ContentBlockerActionType,
  var selector: String?
) {
  init {
    if (type == ContentBlockerActionType.CSS_DISPLAY_NONE) {
      assert(selector != null)
    }
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ContentBlockerAction
    if (type !== other.type) return false
    return selector == other.selector
  }

  override fun hashCode(): Int {
    var result = type.hashCode()
    result = 31 * result + (selector?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "ContentBlockerAction{type=$type, selector='$selector'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>): ContentBlockerAction {
      val type = ContentBlockerActionType.fromValue(map["type"] as String)
      val selector = map["selector"] as String?
      return ContentBlockerAction(type, selector)
    }
  }
}
