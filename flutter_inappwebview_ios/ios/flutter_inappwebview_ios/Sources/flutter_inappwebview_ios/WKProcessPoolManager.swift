//
//  WKProcessPoolManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/11/2019.
//

import Foundation
import WebKit

public class WKProcessPoolManager {
    /// `@MainActor` because `WKProcessPool.init()` is main-actor isolated in SDK 26.5, so the
    /// default value expression cannot be evaluated from a nonisolated static.
    @MainActor
    static let sharedProcessPool = WKProcessPool()
}
