package dev.nosferatu500.inappwebview.types

import java.security.Principal
import java.util.Arrays

class ClientCertChallenge(
  protectionSpace: URLProtectionSpace,
  var principals: Array<Principal>?,
  var keyTypes: Array<String>?
) : URLAuthenticationChallenge(protectionSpace) {

  override fun toMap(): MutableMap<String, Any?> {
    val challengeMap = super.toMap()
    challengeMap["principals"] = principals?.map { it.name }
    challengeMap["keyTypes"] = keyTypes?.toList()
    return challengeMap
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    if (!super.equals(other)) return false

    other as ClientCertChallenge
    if (!principals.contentEquals(other.principals)) return false
    return keyTypes.contentEquals(other.keyTypes)
  }

  override fun hashCode(): Int {
    var result = super.hashCode()
    result = 31 * result + principals.contentHashCode()
    result = 31 * result + keyTypes.contentHashCode()
    return result
  }

  override fun toString(): String =
    "ClientCertChallenge{principals=${Arrays.toString(principals)}, " +
      "keyTypes=${Arrays.toString(keyTypes)}} ${super.toString()}"
}
