package dev.nosferatu500.inappwebview.types

import android.graphics.Rect

class InAppWebViewRect(
  var height: Double,
  var width: Double,
  var x: Double,
  var y: Double
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "height" to height,
    "width" to width,
    "x" to x,
    "y" to y
  )

  fun toRect(): Rect = Rect(x.toInt(), y.toInt(), (x + width).toInt(), (y + height).toInt())

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as InAppWebViewRect
    return height.compareTo(other.height) == 0 &&
      width.compareTo(other.width) == 0 &&
      x.compareTo(other.x) == 0 &&
      y.compareTo(other.y) == 0
  }

  override fun hashCode(): Int {
    var result = height.hashCode()
    result = 31 * result + width.hashCode()
    result = 31 * result + x.hashCode()
    result = 31 * result + y.hashCode()
    return result
  }

  override fun toString(): String =
    "InAppWebViewRect{height=$height, width=$width, x=$x, y=$y}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): InAppWebViewRect? {
      if (map == null) {
        return null
      }
      val height = map["height"] as Double
      val width = map["width"] as Double
      val x = map["x"] as Double
      val y = map["y"] as Double
      return InAppWebViewRect(height, width, x, y)
    }
  }
}
