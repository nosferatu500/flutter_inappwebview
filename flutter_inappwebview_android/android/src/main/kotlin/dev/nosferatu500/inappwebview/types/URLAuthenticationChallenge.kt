package dev.nosferatu500.inappwebview.types

open class URLAuthenticationChallenge(var protectionSpace: URLProtectionSpace) {

  open fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "protectionSpace" to protectionSpace.toMap()
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false
    return protectionSpace == (other as URLAuthenticationChallenge).protectionSpace
  }

  override fun hashCode(): Int = protectionSpace.hashCode()

  override fun toString(): String =
    "URLAuthenticationChallenge{protectionSpace=$protectionSpace}"
}
