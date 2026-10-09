//
//  ClientCertChallenge.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/02/21.
//

import Foundation

/// `Sendable` for the same reason as `HttpAuthenticationChallenge`.
public final class ClientCertChallenge: NSObject, Sendable {
    let protectionSpace: URLProtectionSpace
    
    public init(fromChallenge: URLAuthenticationChallenge) {
        protectionSpace = fromChallenge.protectionSpace
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "protectionSpace": protectionSpace.toMap(),
        ]
    }
}
