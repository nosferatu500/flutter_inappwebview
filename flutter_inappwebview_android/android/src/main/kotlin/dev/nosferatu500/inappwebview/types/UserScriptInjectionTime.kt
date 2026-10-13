package dev.nosferatu500.inappwebview.types

enum class UserScriptInjectionTime(private val value: Int) {
  AT_DOCUMENT_START(0),
  AT_DOCUMENT_END(1);

  fun equalsValue(otherValue: Int): Boolean = value == otherValue

  fun toValue(): Int = value

  companion object {
    @JvmStatic
    fun fromValue(value: Int): UserScriptInjectionTime =
      entries.firstOrNull { value == it.toValue() }
        ?: throw IllegalArgumentException("No enum constant: $value")
  }
}
