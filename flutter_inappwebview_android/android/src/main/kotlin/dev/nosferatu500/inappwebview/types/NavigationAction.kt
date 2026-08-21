package dev.nosferatu500.inappwebview.types

open class NavigationAction(
  @JvmField var request: URLRequest,
  @JvmField var isForMainFrame: Boolean,
  @JvmField var hasGesture: Boolean,
  @JvmField var isRedirect: Boolean
) {

  open fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "request" to request.toMap(),
    "isForMainFrame" to isForMainFrame,
    "hasGesture" to hasGesture,
    "isRedirect" to isRedirect,
    "navigationType" to null,
    "sourceFrame" to null,
    "targetFrame" to null,
    "shouldPerformDownload" to null
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as NavigationAction
    if (isForMainFrame != other.isForMainFrame) return false
    if (hasGesture != other.hasGesture) return false
    if (isRedirect != other.isRedirect) return false
    return request == other.request
  }

  override fun hashCode(): Int {
    var result = request.hashCode()
    result = 31 * result + (if (isForMainFrame) 1 else 0)
    result = 31 * result + (if (hasGesture) 1 else 0)
    result = 31 * result + (if (isRedirect) 1 else 0)
    return result
  }

  override fun toString(): String =
    "NavigationAction{request=$request, isForMainFrame=$isForMainFrame, " +
      "hasGesture=$hasGesture, isRedirect=$isRedirect}"
}
