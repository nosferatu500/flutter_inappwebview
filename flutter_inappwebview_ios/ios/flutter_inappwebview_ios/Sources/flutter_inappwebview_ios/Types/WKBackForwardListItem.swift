//
//  WKBackForwardListItem.swift
//  flutter_inappwebview
//

import Foundation
import WebKit

extension WKBackForwardListItem {
    /// The `WebHistoryItem` map Dart expects.
    ///
    /// Extracted so the two producers cannot drift: `InAppWebView.getCopyBackForwardList()` builds a
    /// whole list of these, and `shouldGoToBackForwardListItem` builds exactly one for an item it has
    /// to locate first. Both must agree on the five keys — nothing compiles Swift against the Dart
    /// `WebHistoryItem`, so a rename on one side is only caught by a test naming the keys.
    ///
    /// `index` and `offset` are nullable because the second caller may not find the item: WebKit
    /// hands the delegate a `WKBackForwardListItem` and says nothing about it still being in the
    /// list by the time it is looked up.
    public func toMap(index: Int?, currentIndex: Int?) -> [String: Any?] {
        var offset: Int? = nil
        if let index = index, let currentIndex = currentIndex {
            offset = index - currentIndex
        }
        return [
            "originalUrl": initialURL.absoluteString,
            "title": title,
            "url": url.absoluteString,
            "index": index,
            "offset": offset
        ]
    }
}
