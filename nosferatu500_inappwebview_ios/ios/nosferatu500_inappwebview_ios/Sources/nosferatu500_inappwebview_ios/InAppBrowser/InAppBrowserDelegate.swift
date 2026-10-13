//
//  InAppBrowserDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 14/02/21.
//

import Foundation

/// `@MainActor` for the same reason as `Disposable`: the only conformer is
/// `InAppBrowserWebViewController`, a `UIViewController`, and every callback here is driven from a
/// `WKNavigationDelegate` method. Leaving the protocol nonisolated made the conformance illegal
/// under Swift 6 — *"crosses into main actor-isolated code and can cause data races"*.
@MainActor
public protocol InAppBrowserDelegate {
    func didChangeTitle(title: String?)
    func didStartNavigation(url: URL?)
    func didUpdateVisitedHistory(url: URL?)
    func didFinishNavigation(url: URL?)
    func didFailNavigation(url: URL?, error: Error)
    func didChangeProgress(progress: Double)
}
