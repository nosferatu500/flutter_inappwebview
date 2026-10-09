//
//  HttpAuthenticationChallenge.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/02/21.
//

import Foundation

/// `Sendable` (immutable, every field `Sendable`) so `toMap()` can run on a global queue, which
/// `WebViewChannelDelegate` does to keep certificate extraction off the main thread (#1678).
public final class HttpAuthenticationChallenge: NSObject, Sendable {
    let protectionSpace: URLProtectionSpace
    let previousFailureCount: Int
    let failureResponse: URLResponse?
    let error: Error?
    let proposedCredential: URLCredential?
    
    public init(fromChallenge: URLAuthenticationChallenge) {
        protectionSpace = fromChallenge.protectionSpace
        previousFailureCount = fromChallenge.previousFailureCount
        failureResponse = fromChallenge.failureResponse
        error = fromChallenge.error
        proposedCredential = fromChallenge.proposedCredential
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "protectionSpace": protectionSpace.toMap(),
            "previousFailureCount": previousFailureCount,
            "failureResponse": failureResponse?.toMap(),
            "error": error?.localizedDescription,
            "proposedCredential": proposedCredential?.toMap()
        ]
    }
}
