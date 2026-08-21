package dev.nosferatu500.inappwebview.content_blocker

enum class ContentBlockerActionType(private val value: String) {
  BLOCK("block"),
  CSS_DISPLAY_NONE("css-display-none"),
  MAKE_HTTPS("make-https");

  fun equalsValue(otherValue: String): Boolean = value == otherValue

  override fun toString(): String = value

  companion object {
    @JvmStatic
    fun fromValue(value: String): ContentBlockerActionType =
      entries.firstOrNull { value == it.value }
        ?: throw IllegalArgumentException("No enum constant: $value")
  }
}
