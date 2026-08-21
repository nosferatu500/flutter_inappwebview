package dev.nosferatu500.inappwebview.types

import android.print.PrintAttributes

class PrintAttributesExt {
  var colorMode: Int = 0
  var duplex: Int? = null
  var orientation: Int? = null
  var mediaSize: MediaSizeExt? = null
  var resolution: ResolutionExt? = null
  var margins: MarginsExt? = null

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "colorMode" to colorMode,
    "duplex" to duplex,
    "orientation" to orientation,
    "mediaSize" to mediaSize?.toMap(),
    "resolution" to resolution?.toMap(),
    "margins" to margins?.toMap()
  )

  companion object {
    @JvmStatic
    fun fromPrintAttributes(attributes: PrintAttributes?): PrintAttributesExt? {
      if (attributes == null) {
        return null
      }
      val attributesExt = PrintAttributesExt()
      attributesExt.colorMode = attributes.colorMode
      attributesExt.duplex = attributes.duplexMode

      val mediaSize = attributes.mediaSize
      if (mediaSize != null) {
        attributesExt.mediaSize = MediaSizeExt.fromMediaSize(mediaSize)
        attributesExt.orientation = if (mediaSize.isPortrait) 0 else 1
      }
      attributesExt.resolution = ResolutionExt.fromResolution(attributes.resolution)
      attributesExt.margins = MarginsExt.fromMargins(attributes.minMargins)
      return attributesExt
    }
  }
}
