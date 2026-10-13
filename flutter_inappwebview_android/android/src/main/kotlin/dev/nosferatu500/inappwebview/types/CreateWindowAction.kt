package dev.nosferatu500.inappwebview.types

class CreateWindowAction(
  request: URLRequest,
  isForMainFrame: Boolean,
  hasGesture: Boolean,
  isRedirect: Boolean,
  var windowId: Int,
  var isDialog: Boolean
) : NavigationAction(request, isForMainFrame, hasGesture, isRedirect) {

  override fun toMap(): MutableMap<String, Any?> {
    val createWindowActionMap = super.toMap()
    createWindowActionMap["windowId"] = windowId
    createWindowActionMap["isDialog"] = isDialog
    createWindowActionMap["windowFeatures"] = null
    return createWindowActionMap
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    if (!super.equals(other)) return false

    other as CreateWindowAction
    if (windowId != other.windowId) return false
    return isDialog == other.isDialog
  }

  override fun hashCode(): Int {
    var result = super.hashCode()
    result = 31 * result + windowId
    result = 31 * result + (if (isDialog) 1 else 0)
    return result
  }

  override fun toString(): String =
    "CreateWindowAction{windowId=$windowId, isDialog=$isDialog, request=$request, " +
      "isForMainFrame=$isForMainFrame, hasGesture=$hasGesture, isRedirect=$isRedirect}"
}
