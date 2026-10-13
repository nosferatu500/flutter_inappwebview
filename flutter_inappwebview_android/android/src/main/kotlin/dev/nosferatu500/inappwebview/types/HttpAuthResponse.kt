package dev.nosferatu500.inappwebview.types

class HttpAuthResponse(
  var username: String,
  var password: String,
  var isPermanentPersistence: Boolean,
  var action: Int?
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as HttpAuthResponse
    if (isPermanentPersistence != other.isPermanentPersistence) return false
    if (username != other.username) return false
    if (password != other.password) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = username.hashCode()
    result = 31 * result + password.hashCode()
    result = 31 * result + (if (isPermanentPersistence) 1 else 0)
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "HttpAuthResponse{username='$username', password='$password', " +
      "permanentPersistence=$isPermanentPersistence, action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): HttpAuthResponse? {
      if (map == null) {
        return null
      }
      val username = map["username"] as String
      val password = map["password"] as String
      val permanentPersistence = map["permanentPersistence"] as Boolean
      val action = map["action"] as Int?
      return HttpAuthResponse(username, password, permanentPersistence, action)
    }
  }
}
