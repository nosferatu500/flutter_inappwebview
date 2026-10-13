//
//  Disposable.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 04/05/22.
//

import Foundation

/// Something with an explicit teardown step, driven from Dart over a method channel.
///
/// `@MainActor` is load-bearing, not decoration. Every one of the eleven conformers is a UIKit or
/// WebKit type — `SafariViewController`, `InAppBrowserWebViewController`, `PullToRefreshControl`,
/// `FlutterWebViewController`, the `ChannelDelegate` hierarchy — so each inherits main-actor
/// isolation from its superclass, while the protocol itself was non-isolated. Swift 6 rejects that
/// combination outright: *"conformance of 'PrintJobController' to protocol 'Disposable' crosses into
/// main actor-isolated code and can cause data races"*.
///
/// Isolating the protocol rather than un-isolating the conformers is the direction that matches
/// reality: `dispose()` is always called from a method-channel handler on the platform thread, and
/// it tears down UIKit views. There is no conformer for which a non-main-actor `dispose()` would be
/// correct.
@MainActor
public protocol Disposable {
    func dispose() -> Void
}
