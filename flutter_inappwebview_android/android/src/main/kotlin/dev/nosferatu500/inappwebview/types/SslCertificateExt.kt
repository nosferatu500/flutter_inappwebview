package dev.nosferatu500.inappwebview.types

import android.net.http.SslCertificate
import java.security.cert.CertificateEncodingException

// Namespace for the SslCertificate -> Map conversion only; never instantiated. The Java version
// extended SslCertificate with a private constructor purely to reach the nested DName type.
object SslCertificateExt {
  @JvmStatic
  fun toMap(sslCertificate: SslCertificate?): MutableMap<String, Any?>? {
    if (sslCertificate == null) {
      return null
    }

    val issuedByName: SslCertificate.DName? = sslCertificate.issuedBy
    var issuedBy: MutableMap<String, Any?>? = null
    if (issuedByName != null) {
      issuedBy = hashMapOf(
        "CName" to issuedByName.cName,
        "DName" to issuedByName.dName,
        "OName" to issuedByName.oName,
        "UName" to issuedByName.uName
      )
    }

    val issuedToName: SslCertificate.DName? = sslCertificate.issuedTo
    var issuedTo: MutableMap<String, Any?>? = null
    if (issuedToName != null) {
      issuedTo = hashMapOf(
        "CName" to issuedToName.cName,
        "DName" to issuedToName.dName,
        "OName" to issuedToName.oName,
        "UName" to issuedToName.uName
      )
    }

    var x509CertificateData: ByteArray? = null
    try {
      x509CertificateData = sslCertificate.x509Certificate?.encoded
    } catch (e: CertificateEncodingException) {
      e.printStackTrace()
    }

    return hashMapOf(
      "issuedBy" to issuedBy,
      "issuedTo" to issuedTo,
      "validNotAfterDate" to sslCertificate.validNotAfterDate.time,
      "validNotBeforeDate" to sslCertificate.validNotBeforeDate.time,
      "x509Certificate" to x509CertificateData
    )
  }
}
