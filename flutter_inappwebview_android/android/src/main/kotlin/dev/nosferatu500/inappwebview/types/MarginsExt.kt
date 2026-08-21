package dev.nosferatu500.inappwebview.types

import android.print.PrintAttributes

class MarginsExt(
  var top: Double = 0.0,
  var right: Double = 0.0,
  var bottom: Double = 0.0,
  var left: Double = 0.0
) {

  fun toMargins(): PrintAttributes.Margins = PrintAttributes.Margins(
    pixelsToMils(left),
    pixelsToMils(top),
    pixelsToMils(right),
    pixelsToMils(bottom)
  )

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "top" to top,
    "right" to right,
    "bottom" to bottom,
    "left" to left
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as MarginsExt
    if (other.top.compareTo(top) != 0) return false
    if (other.right.compareTo(right) != 0) return false
    if (other.bottom.compareTo(bottom) != 0) return false
    return other.left.compareTo(left) == 0
  }

  override fun hashCode(): Int {
    var result: Int
    var temp = java.lang.Double.doubleToLongBits(top)
    result = (temp xor (temp ushr 32)).toInt()
    temp = java.lang.Double.doubleToLongBits(right)
    result = 31 * result + (temp xor (temp ushr 32)).toInt()
    temp = java.lang.Double.doubleToLongBits(bottom)
    result = 31 * result + (temp xor (temp ushr 32)).toInt()
    temp = java.lang.Double.doubleToLongBits(left)
    result = 31 * result + (temp xor (temp ushr 32)).toInt()
    return result
  }

  override fun toString(): String =
    "MarginsExt{top=$top, right=$right, bottom=$bottom, left=$left}"

  companion object {
    // from mils to pixels
    private fun milsToPixels(mils: Int): Double = mils * 0.09600001209449

    // from pixels to mils
    private fun pixelsToMils(pixels: Double): Int = Math.round(pixels * 10.416665354331).toInt()

    @JvmStatic
    fun fromMargins(margins: PrintAttributes.Margins?): MarginsExt? {
      if (margins == null) {
        return null
      }
      return MarginsExt(
        milsToPixels(margins.topMils),
        milsToPixels(margins.rightMils),
        milsToPixels(margins.bottomMils),
        milsToPixels(margins.leftMils)
      )
    }

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): MarginsExt? {
      if (map == null) {
        return null
      }
      return MarginsExt(
        map["top"] as Double,
        map["right"] as Double,
        map["bottom"] as Double,
        map["left"] as Double
      )
    }
  }
}
