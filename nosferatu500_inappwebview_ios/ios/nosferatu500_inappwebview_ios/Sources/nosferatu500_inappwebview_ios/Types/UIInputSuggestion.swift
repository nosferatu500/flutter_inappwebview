//
//  UIInputSuggestion.swift
//  flutter_inappwebview_ios
//

import Foundation
import UIKit

/// The iOS half of the Dart `InputSuggestion`.
///
/// `UIInputSuggestion` is a base class with **no properties at all** — the SDK header says so
/// literally ("No properties at this time"). Everything a suggestion currently carries lives on its
/// one subclass, `UISmartReplySuggestion`, so this map is built by downcasting and is empty for any
/// other kind. That is not a gap in the port: there is nothing else to read.
///
/// Annotated at 18.4 because that is where the UIKit types land; the `WKUIDelegate` method that
/// produces one is 26.0+, and that gate sits at the call site.
@available(iOS 18.4, *)
extension UIInputSuggestion {
    public func toMap() -> [String: Any?] {
        return [
            // The only concrete payload Apple exposes today. `as?` rather than a type check so a
            // future third subclass simply reports `nil` instead of crashing.
            "smartReply": (self as? UISmartReplySuggestion)?.smartReply
        ]
    }
}
