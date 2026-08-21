package dev.nosferatu500.inappwebview.types

import java.util.Objects

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class ShowFileChooserResponse(var isHandledByClient: Boolean, var filePaths: List<String>?) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ShowFileChooserResponse
    return isHandledByClient == other.isHandledByClient && filePaths == other.filePaths
  }

  override fun hashCode(): Int {
    var result = isHandledByClient.hashCode()
    result = 31 * result + Objects.hashCode(filePaths)
    return result
  }

  override fun toString(): String =
    "ShowFileChooserResponse{handledByClient=$isHandledByClient, filePaths=$filePaths}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ShowFileChooserResponse? {
      if (map == null) {
        return null
      }
      val handledByClient = map["handledByClient"] as Boolean
      val filePaths = map["filePaths"] as List<String>?
      return ShowFileChooserResponse(handledByClient, filePaths)
    }
  }
}
