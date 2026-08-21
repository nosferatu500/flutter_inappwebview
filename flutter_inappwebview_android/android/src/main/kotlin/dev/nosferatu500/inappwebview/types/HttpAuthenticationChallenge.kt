package dev.nosferatu500.inappwebview.types

class HttpAuthenticationChallenge(
  protectionSpace: URLProtectionSpace,
  var previousFailureCount: Int,
  @JvmField var proposedCredential: URLCredential?
) : URLAuthenticationChallenge(protectionSpace) {

  override fun toMap(): MutableMap<String, Any?> {
    val challengeMap = super.toMap()
    challengeMap["previousFailureCount"] = previousFailureCount
    challengeMap["proposedCredential"] = proposedCredential?.toMap()
    challengeMap["failureResponse"] = null
    challengeMap["error"] = null
    return challengeMap
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    if (!super.equals(other)) return false

    other as HttpAuthenticationChallenge
    if (previousFailureCount != other.previousFailureCount) return false
    return proposedCredential == other.proposedCredential
  }

  override fun hashCode(): Int {
    var result = super.hashCode()
    result = 31 * result + previousFailureCount
    result = 31 * result + (proposedCredential?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "HttpAuthenticationChallenge{previousFailureCount=$previousFailureCount, " +
      "proposedCredential=$proposedCredential} ${super.toString()}"
}
