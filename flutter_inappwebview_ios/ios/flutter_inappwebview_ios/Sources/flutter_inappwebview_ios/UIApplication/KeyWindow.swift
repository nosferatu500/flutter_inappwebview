//
//  KeyWindow.swift
//  flutter_inappwebview
//

import UIKit

extension UIApplication {

    /// The app's key window, found in a way that works in apps adopting the UIScene lifecycle.
    ///
    /// **`UIApplication.shared.keyWindow` returns `nil` in a scene-based app.** It has been
    /// deprecated since iOS 13 — below this plugin's own iOS 15.0 floor — and the plugin used it in
    /// three places, so each of those silently did nothing as soon as the host app adopted scenes.
    /// That is not a hypothetical: Flutter now migrates new and existing apps to
    /// `FlutterSceneDelegate` by default, and iOS will require the scene lifecycle.
    ///
    /// The failure was measured, not reasoned about. With the example app migrated to UIScene, the
    /// `headless_in_app_webview` suite collapses — `HeadlessInAppWebView` attaches its web view to
    /// the key window precisely because an offscreen `WKWebView` runs JavaScript unreliably, so a
    /// nil key window means the JavaScript those tests wait on never runs. Reverting only the
    /// migration made the same suite pass.
    ///
    /// Prefers the foreground-active scene, then any connected window scene, so it still answers
    /// while the app is launching or in the background.
    ///
    /// **It must also keep working in an app that has *not* adopted scenes**, where
    /// `connectedScenes` is empty and the deprecated API is the only source. Answering `nil` there
    /// breaks exactly the same things the scene case breaks: a first version of this property was
    /// scene-only and collapsed the `headless_in_app_webview` suite on an unmigrated example, which
    /// is how the two-sided requirement was found.
    var keyWindowCompat: UIWindow? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }

        if let active = windowScenes.first(where: { $0.activationState == .foregroundActive }),
           let key = active.keyWindow {
            return key
        }
        if let key = windowScenes.compactMap({ $0.keyWindow }).first {
            return key
        }
        if let any = windowScenes.flatMap({ $0.windows }).first {
            return any
        }

        return legacyKeyWindow
    }

    /// The pre-scene key window.
    ///
    /// Marked deprecated itself so that reaching for the deprecated `windows` does not warn: this
    /// is the deliberate fallback for apps with no scenes, not an oversight.
    @available(iOS, deprecated: 13.0, message: "Only reached when the app has no connected scenes.")
    private var legacyKeyWindow: UIWindow? {
        windows.first { $0.isKeyWindow } ?? windows.first
    }
}
