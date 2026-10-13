package dev.nosferatu500.inappwebview.types

class JsAlertResponse(
  var message: String?,
  var confirmButtonTitle: String?,
  var isHandledByClient: Boolean,
  var action: Int?
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as JsAlertResponse
    if (isHandledByClient != other.isHandledByClient) return false
    if (message != other.message) return false
    if (confirmButtonTitle != other.confirmButtonTitle) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = message?.hashCode() ?: 0
    result = 31 * result + (confirmButtonTitle?.hashCode() ?: 0)
    result = 31 * result + (if (isHandledByClient) 1 else 0)
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "JsAlertResponse{message='$message', confirmButtonTitle='$confirmButtonTitle', " +
      "handledByClient=$isHandledByClient, action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): JsAlertResponse? {
      if (map == null) {
        return null
      }
      val message = map["message"] as String?
      val confirmButtonTitle = map["confirmButtonTitle"] as String?
      val handledByClient = map["handledByClient"] as Boolean
      val action = map["action"] as Int?
      return JsAlertResponse(message, confirmButtonTitle, handledByClient, action)
    }
  }
}
