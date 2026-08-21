package dev.nosferatu500.inappwebview.tracing

import androidx.webkit.TracingController
import dev.nosferatu500.inappwebview.ISettings

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class TracingSettings : ISettings<TracingController> {

  @JvmField
  var categories: List<Any?> = ArrayList()

  @JvmField
  var tracingMode: Int? = null

  override fun parse(settings: Map<String, Any?>): TracingSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "categories" -> categories = value as List<Any?>
        "tracingMode" -> tracingMode = value as Int
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "categories" to categories,
    "tracingMode" to tracingMode
  )

  override fun getRealSettings(obj: TracingController): MutableMap<String, Any?> = toMap()

  companion object {
    const val LOG_TAG = "TracingSettings"
  }
}
