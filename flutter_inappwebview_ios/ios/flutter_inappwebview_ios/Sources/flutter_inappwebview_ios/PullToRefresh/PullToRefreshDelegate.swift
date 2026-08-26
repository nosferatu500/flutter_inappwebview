//
//  PullToRefreshDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 04/03/21.
//

import Foundation

/// `@MainActor`: implemented by `InAppWebView` (a `WKWebView`) and driven by `PullToRefreshControl`
/// (a `UIRefreshControl`). Both are main-actor types, so the protocol has to be too.
@MainActor
public protocol PullToRefreshDelegate {
    func enablePullToRefresh()
    func disablePullToRefresh()
    func isPullToRefreshEnabled() -> Bool
}
