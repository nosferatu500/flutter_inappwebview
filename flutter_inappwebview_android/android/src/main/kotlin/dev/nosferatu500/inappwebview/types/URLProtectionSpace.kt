package dev.nosferatu500.inappwebview.types

import android.net.http.SslCertificate
import android.net.http.SslError

class URLProtectionSpace(
  var id: Long?,
  var host: String,
  var protocol: String,
  var realm: String?,
  var port: Int,
  var sslCertificate: SslCertificate?,
  var sslError: SslError?
) {
  constructor(
    host: String,
    protocol: String,
    realm: String?,
    port: Int,
    sslCertificate: SslCertificate?,
    sslError: SslError?
  ) : this(null, host, protocol, realm, port, sslCertificate, sslError)

  constructor(id: Long?, host: String, protocol: String, realm: String?, port: Int) :
    this(id, host, protocol, realm, port, null, null)

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "host" to host,
    "protocol" to protocol,
    "realm" to realm,
    "port" to port,
    "sslCertificate" to SslCertificateExt.toMap(sslCertificate),
    "sslError" to SslErrorExt.toMap(sslError),
    "authenticationMethod" to null,
    "distinguishedNames" to null,
    "receivesCredentialSecurely" to null,
    "isProxy" to null,
    "proxyType" to null
  )

  // id is excluded on purpose: it is the credential-database row id, not part of the identity
  // of the protection space itself.
  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as URLProtectionSpace
    if (port != other.port) return false
    if (host != other.host) return false
    if (protocol != other.protocol) return false
    if (realm != other.realm) return false
    if (sslCertificate != other.sslCertificate) return false
    return sslError == other.sslError
  }

  override fun hashCode(): Int {
    var result = host.hashCode()
    result = 31 * result + protocol.hashCode()
    result = 31 * result + (realm?.hashCode() ?: 0)
    result = 31 * result + port
    result = 31 * result + (sslCertificate?.hashCode() ?: 0)
    result = 31 * result + (sslError?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "URLProtectionSpace{host='$host', protocol='$protocol', realm='$realm', port=$port, " +
      "sslCertificate=$sslCertificate, sslError=$sslError}"
}
