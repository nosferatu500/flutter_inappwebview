package dev.nosferatu500.inappwebview.print_job

import dev.nosferatu500.inappwebview.ISettings
import dev.nosferatu500.inappwebview.types.MediaSizeExt
import dev.nosferatu500.inappwebview.types.ResolutionExt

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class PrintJobSettings : ISettings<PrintJobController> {

  @JvmField var handledByClient: Boolean = false
  @JvmField var jobName: String? = null
  @JvmField var orientation: Int? = null

  // @JvmField var margins: MarginsExt? = null
  @JvmField var mediaSize: MediaSizeExt? = null
  @JvmField var colorMode: Int? = null
  @JvmField var duplexMode: Int? = null
  @JvmField var resolution: ResolutionExt? = null

  override fun parse(settings: Map<String, Any?>): PrintJobSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "handledByClient" -> handledByClient = value as Boolean
        "jobName" -> jobName = value as String
        "orientation" -> orientation = value as Int
        // "margins" -> margins = MarginsExt.fromMap(value as Map<String, Any?>)
        "mediaSize" -> mediaSize = MediaSizeExt.fromMap(value as Map<String, Any?>)
        "colorMode" -> colorMode = value as Int
        "duplexMode" -> duplexMode = value as Int
        "resolution" -> resolution = ResolutionExt.fromMap(value as Map<String, Any?>)
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "handledByClient" to handledByClient,
    "jobName" to jobName,
    "orientation" to orientation,
    // "margins" to margins?.toMap(),
    "mediaSize" to mediaSize?.toMap(),
    "colorMode" to colorMode,
    "duplexMode" to duplexMode,
    "resolution" to resolution?.toMap()
  )

  override fun getRealSettings(obj: PrintJobController): MutableMap<String, Any?> = toMap()

  companion object {
    const val LOG_TAG = "PrintJobSettings"
  }
}
