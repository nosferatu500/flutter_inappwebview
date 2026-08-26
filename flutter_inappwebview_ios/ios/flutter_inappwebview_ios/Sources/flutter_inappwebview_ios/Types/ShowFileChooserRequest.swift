//
//  ShowFileChooserRequest.swift
//  flutter_inappwebview_ios
//

import Foundation
import WebKit

/// The iOS half of the Dart `ShowFileChooserRequest`, built from `WKOpenPanelParameters`.
///
/// `WKOpenPanelParameters` carries far less than Android's `FileChooserParams`: it has
/// `allowsMultipleSelection` and — only since iOS 18.4 — `allowsDirectories`, and nothing else.
/// So `acceptTypes`, `isCaptureEnabled`, `title` and `filenameHint` are sent as empty/false/nil
/// rather than guessed. That is a real capability gap, not an oversight: WebKit does not expose the
/// `accept` attribute of the `<input type="file">` element to the delegate at all, so a Dart handler
/// on iOS cannot filter by MIME type the way it can on Android.
@MainActor
public class ShowFileChooserRequest: NSObject {
    /// Mirrors the Dart `ShowFileChooserRequestMode` native values:
    /// `OPEN = 0`, `OPEN_MULTIPLE = 1`, `OPEN_FOLDER = 2`, `SAVE = 3`.
    var mode: Int
    var acceptTypes: [String]
    var isCaptureEnabled: Bool
    var title: String?
    var filenameHint: String?

    public init(mode: Int,
                acceptTypes: [String] = [],
                isCaptureEnabled: Bool = false,
                title: String? = nil,
                filenameHint: String? = nil) {
        self.mode = mode
        self.acceptTypes = acceptTypes
        self.isCaptureEnabled = isCaptureEnabled
        self.title = title
        self.filenameHint = filenameHint
    }

    /// Derives the Dart mode from what `WKOpenPanelParameters` actually reports.
    ///
    /// `@available(iOS 18.4)` is on the initialiser because **the whole `WKOpenPanelParameters`
    /// class** is iOS 18.4+, not just its properties — it existed on macOS from 10.12 but was only
    /// brought to iOS in 18.4. `allowsDirectories` carries `macos(10.13.4)`, which is a *later*
    /// macOS version than the class, so on macOS it needs its own check; on iOS both arrive together
    /// and one annotation covers them.
    ///
    /// `SAVE` is never produced — WebKit has no save-panel equivalent on iOS.
    @available(iOS 18.4, *)
    public convenience init(fromOpenPanelParameters parameters: WKOpenPanelParameters) {
        var mode = parameters.allowsMultipleSelection ? 1 : 0
        if parameters.allowsDirectories {
            mode = 2
        }
        self.init(mode: mode)
    }

    public func toMap() -> [String: Any?] {
        return [
            "mode": mode,
            "acceptTypes": acceptTypes,
            "isCaptureEnabled": isCaptureEnabled,
            "title": title,
            "filenameHint": filenameHint
        ]
    }
}
