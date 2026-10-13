package dev.nosferatu500.inappwebview.types

import android.net.http.SslError

// Namespace for the SslError -> Map conversion only; never instantiated.
object SslErrorExt {
  @JvmStatic
  fun toMap(sslError: SslError?): MutableMap<String, Any?>? {
    if (sslError == null) {
      return null
    }

    val primaryError = sslError.primaryError

    val message = when (primaryError) {
      SslError.SSL_DATE_INVALID -> "The date of the certificate is invalid"
      SslError.SSL_EXPIRED -> "The certificate has expired"
      SslError.SSL_IDMISMATCH -> "Hostname mismatch"
      SslError.SSL_INVALID -> "A generic error occurred"
      SslError.SSL_NOTYETVALID -> "The certificate is not yet valid"
      SslError.SSL_UNTRUSTED -> "The certificate authority is not trusted"
      else -> null
    }

    return hashMapOf(
      "code" to if (primaryError >= 0) primaryError else null,
      "message" to message
    )
  }
}
