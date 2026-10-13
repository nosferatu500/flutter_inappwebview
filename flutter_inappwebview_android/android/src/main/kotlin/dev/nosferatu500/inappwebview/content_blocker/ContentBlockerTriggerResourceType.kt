package dev.nosferatu500.inappwebview.content_blocker

enum class ContentBlockerTriggerResourceType(private val value: String) {
  DOCUMENT("document"),
  IMAGE("image"),
  STYLE_SHEET("style-sheet"),
  SCRIPT("script"),
  FONT("font"),
  SVG_DOCUMENT("svg-document"),
  MEDIA("media"),
  POPUP("popup"),
  RAW("raw");

  fun equalsValue(otherValue: String): Boolean = value == otherValue

  override fun toString(): String = value

  companion object {
    @JvmStatic
    fun fromValue(value: String): ContentBlockerTriggerResourceType =
      entries.firstOrNull { value == it.value }
        ?: throw IllegalArgumentException("No enum constant: $value")
  }
}
