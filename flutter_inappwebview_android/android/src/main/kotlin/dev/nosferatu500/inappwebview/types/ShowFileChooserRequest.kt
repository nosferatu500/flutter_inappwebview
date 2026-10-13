package dev.nosferatu500.inappwebview.types

import android.webkit.WebChromeClient
import java.util.Objects

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class ShowFileChooserRequest(
  var mode: Int,
  var acceptTypes: List<String>,
  var isCaptureEnabled: Boolean,
  var title: String?,
  var filenameHint: String?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "mode" to mode,
    "acceptTypes" to acceptTypes,
    "isCaptureEnabled" to isCaptureEnabled,
    "title" to title,
    "filenameHint" to filenameHint
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ShowFileChooserRequest
    return mode == other.mode &&
      isCaptureEnabled == other.isCaptureEnabled &&
      acceptTypes == other.acceptTypes &&
      title == other.title &&
      filenameHint == other.filenameHint
  }

  override fun hashCode(): Int {
    var result = mode
    result = 31 * result + acceptTypes.hashCode()
    result = 31 * result + isCaptureEnabled.hashCode()
    result = 31 * result + Objects.hashCode(title)
    result = 31 * result + Objects.hashCode(filenameHint)
    return result
  }

  override fun toString(): String =
    "ShowFileChooserRequest{mode=$mode, acceptTypes=$acceptTypes, " +
      "isCaptureEnabled=$isCaptureEnabled, title='$title', filenameHint='$filenameHint'}"

  companion object {
    @JvmStatic
    fun fromFileChooserParams(
      fileChooserParams: WebChromeClient.FileChooserParams
    ): ShowFileChooserRequest = ShowFileChooserRequest(
      fileChooserParams.mode,
      fileChooserParams.acceptTypes.asList(),
      fileChooserParams.isCaptureEnabled,
      fileChooserParams.title?.toString(),
      fileChooserParams.filenameHint
    )

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ShowFileChooserRequest? {
      if (map == null) {
        return null
      }
      val mode = map["mode"] as Int
      val acceptTypes = map["acceptTypes"] as List<String>
      val isCaptureEnabled = map["isCaptureEnabled"] as Boolean
      val title = map["title"] as String?
      val filenameHint = map["filenameHint"] as String?
      return ShowFileChooserRequest(mode, acceptTypes, isCaptureEnabled, title, filenameHint)
    }
  }
}
