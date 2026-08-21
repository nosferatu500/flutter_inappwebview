package dev.nosferatu500.inappwebview.types

class JavaScriptHandlerFunctionData(
  var origin: String,
  var requestUrl: String,
  var isMainFrame: Boolean,
  var args: String
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "origin" to origin,
    "requestUrl" to requestUrl,
    "isMainFrame" to isMainFrame,
    "args" to args
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as JavaScriptHandlerFunctionData
    return isMainFrame == other.isMainFrame &&
      origin == other.origin &&
      requestUrl == other.requestUrl &&
      args == other.args
  }

  override fun hashCode(): Int {
    var result = origin.hashCode()
    result = 31 * result + requestUrl.hashCode()
    result = 31 * result + isMainFrame.hashCode()
    result = 31 * result + args.hashCode()
    return result
  }

  override fun toString(): String =
    "JavaScriptHandlerFunctionData{origin='$origin', requestUrl='$requestUrl', " +
      "isMainFrame=$isMainFrame, args='$args'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): JavaScriptHandlerFunctionData? {
      if (map == null) {
        return null
      }
      val origin = map["origin"] as String
      val requestUrl = map["requestUrl"] as String
      val isMainFrame = map["isMainFrame"] as Boolean
      val args = map["args"] as String
      return JavaScriptHandlerFunctionData(origin, requestUrl, isMainFrame, args)
    }
  }
}
