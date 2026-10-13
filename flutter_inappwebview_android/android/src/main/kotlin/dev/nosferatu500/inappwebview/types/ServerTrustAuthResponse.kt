package dev.nosferatu500.inappwebview.types

class ServerTrustAuthResponse(var action: Int?) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    return action == (other as ServerTrustAuthResponse).action
  }

  override fun hashCode(): Int = action?.hashCode() ?: 0

  override fun toString(): String = "ServerTrustAuthResponse{action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): ServerTrustAuthResponse? {
      if (map == null) {
        return null
      }
      return ServerTrustAuthResponse(map["action"] as Int?)
    }
  }
}
