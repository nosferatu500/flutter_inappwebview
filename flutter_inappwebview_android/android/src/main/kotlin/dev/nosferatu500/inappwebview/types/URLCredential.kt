package dev.nosferatu500.inappwebview.types

class URLCredential(
  var id: Long?,
  var username: String?,
  var password: String?,
  var protectionSpaceId: Long?
) {
  constructor(username: String?, password: String?) : this(null, username, password, null)

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "username" to username,
    "password" to password,
    "certificates" to null,
    "persistence" to null
  )

  // Deliberately narrower than the field set: identity here is the credential itself, not the
  // database row it came from, so id and protectionSpaceId are excluded.
  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as URLCredential
    if (username != other.username) return false
    return password == other.password
  }

  override fun hashCode(): Int {
    var result = username?.hashCode() ?: 0
    result = 31 * result + (password?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "URLCredential{username='$username', password='$password'}"
}
