package dev.nosferatu500.inappwebview.types

class JsBeforeUnloadResponse(
  var message: String?,
  var confirmButtonTitle: String?,
  var cancelButtonTitle: String?,
  var isHandledByClient: Boolean,
  var action: Int?
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as JsBeforeUnloadResponse
    if (isHandledByClient != other.isHandledByClient) return false
    if (message != other.message) return false
    if (confirmButtonTitle != other.confirmButtonTitle) return false
    if (cancelButtonTitle != other.cancelButtonTitle) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = message?.hashCode() ?: 0
    result = 31 * result + (confirmButtonTitle?.hashCode() ?: 0)
    result = 31 * result + (cancelButtonTitle?.hashCode() ?: 0)
    result = 31 * result + (if (isHandledByClient) 1 else 0)
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  // Says JsConfirmResponse; kept verbatim from the Java to avoid changing logged output.
  override fun toString(): String =
    "JsConfirmResponse{message='$message', confirmButtonTitle='$confirmButtonTitle', " +
      "cancelButtonTitle='$cancelButtonTitle', handledByClient=$isHandledByClient, action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): JsBeforeUnloadResponse? {
      if (map == null) {
        return null
      }
      val message = map["message"] as String?
      val confirmButtonTitle = map["confirmButtonTitle"] as String?
      val cancelButtonTitle = map["cancelButtonTitle"] as String?
      val handledByClient = map["handledByClient"] as Boolean
      val action = map["action"] as Int?
      return JsBeforeUnloadResponse(
        message, confirmButtonTitle, cancelButtonTitle, handledByClient, action
      )
    }
  }
}
