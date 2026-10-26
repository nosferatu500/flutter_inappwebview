package dev.nosferatu500.inappwebview.types

enum class NavigationActionPolicy(private val value: Int) {
  CANCEL(0),
  ALLOW(1);

  fun equalsValue(otherValue: Int): Boolean = value == otherValue

  override fun toString(): String = value.toString()

  companion object {
    @JvmStatic
    fun fromValue(value: Int): NavigationActionPolicy =
      entries.firstOrNull { value == it.value }
        ?: throw IllegalArgumentException("No enum constant: $value")
  }
}
