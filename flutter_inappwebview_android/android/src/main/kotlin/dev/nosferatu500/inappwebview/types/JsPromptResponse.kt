package dev.nosferatu500.inappwebview.types

class JsPromptResponse(
  var message: String?,
  var defaultValue: String?,
  var confirmButtonTitle: String?,
  var cancelButtonTitle: String?,
  var isHandledByClient: Boolean,
  var value: String?,
  var action: Int?
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as JsPromptResponse
    if (isHandledByClient != other.isHandledByClient) return false
    if (message != other.message) return false
    if (defaultValue != other.defaultValue) return false
    if (confirmButtonTitle != other.confirmButtonTitle) return false
    if (cancelButtonTitle != other.cancelButtonTitle) return false
    if (value != other.value) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = message?.hashCode() ?: 0
    result = 31 * result + (defaultValue?.hashCode() ?: 0)
    result = 31 * result + (confirmButtonTitle?.hashCode() ?: 0)
    result = 31 * result + (cancelButtonTitle?.hashCode() ?: 0)
    result = 31 * result + (if (isHandledByClient) 1 else 0)
    result = 31 * result + (value?.hashCode() ?: 0)
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "JsPromptResponse{message='$message', defaultValue='$defaultValue', " +
      "confirmButtonTitle='$confirmButtonTitle', cancelButtonTitle='$cancelButtonTitle', " +
      "handledByClient=$isHandledByClient, value='$value', action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): JsPromptResponse? {
      if (map == null) {
        return null
      }
      val message = map["message"] as String?
      val defaultValue = map["defaultValue"] as String?
      val confirmButtonTitle = map["confirmButtonTitle"] as String?
      val cancelButtonTitle = map["cancelButtonTitle"] as String?
      val handledByClient = map["handledByClient"] as Boolean
      val value = map["value"] as String?
      val action = map["action"] as Int?
      return JsPromptResponse(
        message, defaultValue, confirmButtonTitle, cancelButtonTitle, handledByClient, value, action
      )
    }
  }
}
