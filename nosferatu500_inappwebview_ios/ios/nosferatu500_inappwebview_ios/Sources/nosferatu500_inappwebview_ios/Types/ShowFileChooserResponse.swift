//
//  ShowFileChooserResponse.swift
//  flutter_inappwebview_ios
//

import Foundation

/// The iOS half of the Dart `ShowFileChooserResponse`.
///
/// `filePaths` are file URI strings (`file:///...`), as the Dart doc requires. They are converted
/// with `URL(string:)` rather than `URL(fileURLWithPath:)` precisely because the contract is a URI
/// and not a bare path — a bare path would produce a relative URL that WebKit rejects.
public class ShowFileChooserResponse: NSObject {
    var handledByClient: Bool
    var filePaths: [String]?

    public init(handledByClient: Bool, filePaths: [String]? = nil) {
        self.handledByClient = handledByClient
        self.filePaths = filePaths
    }

    public static func fromMap(map: [String:Any?]?) -> ShowFileChooserResponse? {
        guard let map = map else {
            return nil
        }
        let handledByClient = map["handledByClient"] as? Bool ?? false
        let filePaths = map["filePaths"] as? [String]
        return ShowFileChooserResponse(handledByClient: handledByClient, filePaths: filePaths)
    }

    /// The selected files as URLs, or `nil` to cancel.
    ///
    /// Entries that are not parseable as URLs are dropped rather than failing the whole selection;
    /// a `nil` return is reserved for "cancel", so returning an empty array for a malformed input
    /// would silently look like a successful empty selection.
    public func toURLs() -> [URL]? {
        guard let filePaths = filePaths else {
            return nil
        }
        return filePaths.compactMap { URL(string: $0) }
    }
}
