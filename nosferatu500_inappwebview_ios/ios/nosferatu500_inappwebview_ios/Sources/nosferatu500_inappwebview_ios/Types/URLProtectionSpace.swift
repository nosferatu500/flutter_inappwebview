//
//  URLProtectionSpace.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation

extension URLProtectionSpace {
    
    var x509Certificate: Data? {
        guard let serverTrust = serverTrust else {
            return nil
        }
        
        // Evaluated first, as before, so the chain is built; the verdict is ignored on purpose. The
        // leaf is wanted for an untrusted certificate too (a self-signed server's), which is what the
        // deprecated `SecTrustEvaluate` gave: its status reported the call, not the trust.
        _ = SecTrustEvaluateWithError(serverTrust, nil)
        if let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
           let serverCertificate = chain.first {
            return serverCertificate.data
        }
        return nil
    }
    
    var sslCertificate: SslCertificate? {
        var sslCertificate: SslCertificate? = nil
        if let x509Certificate = x509Certificate {
            sslCertificate = SslCertificate(x509Certificate: x509Certificate)
        }
        return sslCertificate
    }
    
    var sslError: SslError? {
        guard let serverTrust = serverTrust else {
            return nil
        }
        
        // `SecTrustGetTrustResult` reads back the result type the evaluation stored, which is what
        // the deprecated `SecTrustEvaluate` returned. A trusted certificate gives `.unspecified`,
        // not `.proceed`, so it is reported as an `SslError` too, as before.
        _ = SecTrustEvaluateWithError(serverTrust, nil)
        var secResult = SecTrustResultType.invalid
        SecTrustGetTrustResult(serverTrust, &secResult)

        guard let sslErrorType = secResult != SecTrustResultType.proceed ? secResult : nil else {
            return nil
        }
        
        return SslError(errorType: sslErrorType)
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "host": host,
            "protocol": self.protocol,
            "realm": realm,
            "port": port,
            "sslCertificate": sslCertificate?.toMap(),
            "sslError": sslError?.toMap(),
            "authenticationMethod": authenticationMethod,
            "distinguishedNames": distinguishedNames,
            "receivesCredentialSecurely": receivesCredentialSecurely,
            "proxyType": proxyType
        ]
    }
}
