package dev.nosferatu500.inappwebview.types

import android.print.PrintAttributes

class ResolutionExt(
  var id: String,
  var label: String,
  var verticalDpi: Int,
  var horizontalDpi: Int
) {

  fun toResolution(): PrintAttributes.Resolution =
    PrintAttributes.Resolution(id, label, horizontalDpi, verticalDpi)

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "id" to id,
    "label" to label,
    "verticalDpi" to verticalDpi,
    "horizontalDpi" to horizontalDpi
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ResolutionExt
    if (verticalDpi != other.verticalDpi) return false
    if (horizontalDpi != other.horizontalDpi) return false
    if (id != other.id) return false
    return label == other.label
  }

  override fun hashCode(): Int {
    var result = id.hashCode()
    result = 31 * result + label.hashCode()
    result = 31 * result + verticalDpi
    result = 31 * result + horizontalDpi
    return result
  }

  override fun toString(): String =
    "ResolutionExt{id='$id', label='$label', verticalDpi=$verticalDpi, " +
      "horizontalDpi=$horizontalDpi}"

  companion object {
    @JvmStatic
    fun fromResolution(resolution: PrintAttributes.Resolution?): ResolutionExt? {
      if (resolution == null) {
        return null
      }
      return ResolutionExt(
        resolution.id,
        resolution.label,
        resolution.verticalDpi,
        resolution.horizontalDpi
      )
    }

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ResolutionExt? {
      if (map == null) {
        return null
      }
      val id = map["id"] as String
      val label = map["label"] as String
      val verticalDpi = map["verticalDpi"] as Int
      val horizontalDpi = map["horizontalDpi"] as Int
      return ResolutionExt(id, label, verticalDpi, horizontalDpi)
    }
  }
}
