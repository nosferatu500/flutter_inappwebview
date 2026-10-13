package dev.nosferatu500.inappwebview.types

import android.print.PrintAttributes

class MediaSizeExt(
  var id: String,
  var label: String?,
  var widthMils: Int,
  var heightMils: Int
) {

  fun toMediaSize(): PrintAttributes.MediaSize =
    PrintAttributes.MediaSize(id, "Custom", widthMils, heightMils)

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "id" to id,
    "label" to label,
    "heightMils" to heightMils,
    "widthMils" to widthMils
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as MediaSizeExt
    if (widthMils != other.widthMils) return false
    if (heightMils != other.heightMils) return false
    if (id != other.id) return false
    return label == other.label
  }

  override fun hashCode(): Int {
    var result = id.hashCode()
    result = 31 * result + (label?.hashCode() ?: 0)
    result = 31 * result + widthMils
    result = 31 * result + heightMils
    return result
  }

  override fun toString(): String =
    "MediaSizeExt{id='$id', label='$label', widthMils=$widthMils, heightMils=$heightMils}"

  companion object {
    @JvmStatic
    fun fromMediaSize(mediaSize: PrintAttributes.MediaSize?): MediaSizeExt? {
      if (mediaSize == null) {
        return null
      }
      // The constructor is (id, label, widthMils, heightMils). Upstream passed height into the
      // width slot and vice versa, so every media size crossed the channel transposed; fixed here
      // (TODO.md P0b.1).
      return MediaSizeExt(
        mediaSize.id,
        null,
        mediaSize.widthMils,
        mediaSize.heightMils
      )
    }

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): MediaSizeExt? {
      if (map == null) {
        return null
      }
      val id = map["id"] as String
      val label = map["label"] as String?
      val widthMils = map["widthMils"] as Int
      val heightMils = map["heightMils"] as Int
      return MediaSizeExt(id, label, widthMils, heightMils)
    }
  }
}
