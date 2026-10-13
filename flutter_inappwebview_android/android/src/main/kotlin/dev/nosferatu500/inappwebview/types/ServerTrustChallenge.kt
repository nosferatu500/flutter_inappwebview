package dev.nosferatu500.inappwebview.types

class ServerTrustChallenge(protectionSpace: URLProtectionSpace) :
  URLAuthenticationChallenge(protectionSpace) {

  override fun toString(): String = "ServerTrustChallenge{} ${super.toString()}"
}
