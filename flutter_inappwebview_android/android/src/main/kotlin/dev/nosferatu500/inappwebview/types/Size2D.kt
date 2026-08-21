package dev.nosferatu500.inappwebview.types

class Size2D(var width: Double, var height: Double) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "width" to width,
    "height" to height
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as Size2D
    if (width.compareTo(other.width) != 0) return false
    return height.compareTo(other.height) == 0
  }

  override fun hashCode(): Int {
    var result: Int
    var temp = java.lang.Double.doubleToLongBits(width)
    result = (temp xor (temp ushr 32)).toInt()
    temp = java.lang.Double.doubleToLongBits(height)
    result = 31 * result + (temp xor (temp ushr 32)).toInt()
    return result
  }

  override fun toString(): String = "Size{width=$width, height=$height}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): Size2D? {
      if (map == null) {
        return null
      }
      val width = map["width"] as Double
      val height = map["height"] as Double
      return Size2D(width, height)
    }
  }
}
