//
//  FlutterMethodCallDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/12/2019.
//

import Foundation
import Flutter

/// Base class for everything that answers a Flutter method channel.
///
/// This is **the plugin's own type**, not Flutter's — a detail that decides the whole isolation
/// model. Because it is ours, `@MainActor` can be applied at the root and inherited by all 22
/// subclasses (the 20 `ChannelDelegate` subclasses plus `WebMessageChannel` and
/// `WebMessageListener`), instead of being repeated on each one or worked around with
/// `assumeIsolated`.
///
/// The annotation states a fact that was already true: Flutter invokes method-call handlers on the
/// platform thread, which on iOS is the main thread, and these handlers go straight on to touch
/// `WKWebView`, `UIViewController` and `UIPrintInteractionController` — all main-actor types in
/// SDK 26.5. Nothing here ever ran anywhere else; Swift 6 simply requires it to be written down.
@MainActor
public class FlutterMethodCallDelegate: NSObject {
    public override init() {
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    }
}
