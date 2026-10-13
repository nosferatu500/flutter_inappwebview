//
//  WKNavigationAction.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation
import WebKit

extension WKNavigationAction {
    public func toMap () -> [String:Any?] {
        var shouldPerformDownload: Bool? = nil
        shouldPerformDownload = self.shouldPerformDownload

        // Both stay `nil` below iOS 18.4, which the Dart side reads as "not reported by this
        // platform". That is deliberately distinct from an empty array, which means "reported, and
        // no modifier / no button was involved".
        var modifierFlags: [String]? = nil
        var buttonNumber: [String]? = nil
        if #available(iOS 18.4, *) {
            modifierFlags = Util.getModifierFlagsString(flags: self.modifierFlags)
            buttonNumber = Util.getButtonMaskString(mask: self.buttonNumber)
        }

        // `nil` below iOS 26.0 means "not reported by this platform", which the Dart side keeps
        // distinct from `false` ("reported, and this navigation was not rule-list driven").
        var isContentRuleListRedirect: Bool? = nil
        if #available(iOS 26.0, *) {
            isContentRuleListRedirect = self.isContentRuleListRedirect
        }

        return [
            "request": request.toMap(),
            "isForMainFrame": targetFrame?.isMainFrame ?? false,
            "hasGesture": nil,
            "isRedirect": nil,
            "navigationType": navigationType.rawValue,
            "sourceFrame": sourceFrame.toMap(),
            "targetFrame": targetFrame?.toMap(),
            "shouldPerformDownload": shouldPerformDownload,
            "isContentRuleListRedirect": isContentRuleListRedirect,
            "modifierFlags": modifierFlags,
            "buttonNumber": buttonNumber
        ]
    }
}
