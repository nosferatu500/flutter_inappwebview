package dev.nosferatu500.inappwebview.types

enum class PreferredContentModeOptionType(private val value: Int) {
  RECOMMENDED(0),
  MOBILE(1),
  DESKTOP(2);

  fun equalsValue(otherValue: Int): Boolean = value == otherValue

  fun toValue(): Int = value

  companion object {
    @JvmStatic
    fun fromValue(value: Int): PreferredContentModeOptionType =
      entries.firstOrNull { value == it.toValue() }
        ?: throw IllegalArgumentException("No enum constant: $value")
  }
}
