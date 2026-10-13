package dev.nosferatu500.inappwebview.types

class ClientCertResponse(
  var certificatePath: String,
  var certificatePassword: String?,
  var keyStoreType: String,
  var action: Int?
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ClientCertResponse
    if (certificatePath != other.certificatePath) return false
    if (certificatePassword != other.certificatePassword) return false
    if (keyStoreType != other.keyStoreType) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = certificatePath.hashCode()
    result = 31 * result + (certificatePassword?.hashCode() ?: 0)
    result = 31 * result + keyStoreType.hashCode()
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "ClientCertResponse{certificatePath='$certificatePath', " +
      "certificatePassword='$certificatePassword', keyStoreType='$keyStoreType', action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ClientCertResponse? {
      if (map == null) {
        return null
      }
      val certificatePath = map["certificatePath"] as String
      val certificatePassword = map["certificatePassword"] as String?
      val keyStoreType = map["keyStoreType"] as String
      val action = map["action"] as Int?
      return ClientCertResponse(certificatePath, certificatePassword, keyStoreType, action)
    }
  }
}
