//
//  UIConversationContext.swift
//  flutter_inappwebview_ios
//

import Foundation
import UIKit

/// The iOS half of the Dart `ConversationContext`, `ConversationEntry` and `PersonNameComponents`.
///
/// `UIConversationContext` and its nested `Entry` are iOS **18.4+** types even though the WebKit
/// property that consumes them (`WKWebView.conversationContext`) is 26.0+ — so these extensions are
/// annotated at 18.4 and the 26.0 gate lives at the call site, where the property is.
///
/// **The entry type is `UIConversationContext.Entry` in Swift, not `UIConversationEntry`.** The
/// ObjC header declares `UIConversationEntry` and then renames it with
/// `NS_SWIFT_NAME(UIConversationContext.Entry)`; using the ObjC spelling is a hard error, not a
/// deprecation warning.
///
/// Every property of both native types is `readwrite` and neither declares a designated
/// initialiser, so they are built with `init()` plus assignment. There is nothing to fail: the maps
/// are validated on the way in and a malformed entry is dropped rather than half-built.
@available(iOS 18.4, *)
extension UIConversationContext {
    /// Builds a context from the Dart map, or `nil` if there is no map at all.
    ///
    /// Absent keys leave the native default in place rather than writing an empty value, so a caller
    /// that sends only `entries` does not silently blank the participant names.
    public static func fromMap(map: [String: Any?]?) -> UIConversationContext? {
        guard let map = map else {
            return nil
        }
        let context = UIConversationContext()
        if let threadIdentifier = map["threadIdentifier"] as? String {
            context.threadIdentifier = threadIdentifier
        }
        if let entries = map["entries"] as? [[String: Any?]] {
            // `compactMap`: an entry missing one of the four fields the native type declares
            // non-null is dropped. Sending it half-built would put a message with no sender or no
            // date into the thread the keyboard reasons about, which is worse than omitting it --
            // the same reasoning as `ShowFileChooserResponse.toURLs()`.
            context.entries = entries.compactMap { UIConversationContext.Entry.fromMap(map: $0) }
        }
        if let selfIdentifiers = map["selfIdentifiers"] as? [String] {
            context.selfIdentifiers = Set(selfIdentifiers)
        }
        if let recipients = map["responsePrimaryRecipientIdentifiers"] as? [String] {
            context.responsePrimaryRecipientIdentifiers = Set(recipients)
        }
        if let names = map["participantNameByIdentifier"] as? [String: [String: Any?]] {
            context.participantNameByIdentifier = names.compactMapValues {
                PersonNameComponents.fromMap(map: $0)
            }
        }
        return context
    }

    public func toMap() -> [String: Any?] {
        return [
            "threadIdentifier": threadIdentifier,
            "entries": entries.map { $0.toMap() },
            // Sets go over the channel as arrays; the Dart side is typed `Set<String>` and rebuilds
            // them, so the round trip is lossless.
            "selfIdentifiers": Array(selfIdentifiers),
            "responsePrimaryRecipientIdentifiers": Array(responsePrimaryRecipientIdentifiers),
            "participantNameByIdentifier": participantNameByIdentifier.mapValues { $0.toMap() }
        ]
    }
}

@available(iOS 18.4, *)
extension UIConversationContext.Entry {
    /// Returns `nil` unless all four required fields are present -- see the note in
    /// `UIConversationContext.fromMap`.
    public static func fromMap(map: [String: Any?]?) -> UIConversationContext.Entry? {
        guard let map = map,
              let text = map["text"] as? String,
              let senderIdentifier = map["senderIdentifier"] as? String,
              let sentDate = map["sentDate"] as? Int64,
              let entryIdentifier = map["entryIdentifier"] as? String else {
            return nil
        }
        let entry = UIConversationContext.Entry()
        entry.text = text
        entry.senderIdentifier = senderIdentifier
        // Dart sends `DateTime.millisecondsSinceEpoch`; `Date` takes seconds.
        entry.sentDate = Date(timeIntervalSince1970: TimeInterval(Double(sentDate) / 1000))
        entry.entryIdentifier = entryIdentifier
        entry.replyThreadIdentifier = map["replyThreadIdentifier"] as? String
        if let recipients = map["primaryRecipientIdentifiers"] as? [String] {
            entry.primaryRecipientIdentifiers = Set(recipients)
        }
        return entry
    }

    public func toMap() -> [String: Any?] {
        return [
            "text": text,
            "senderIdentifier": senderIdentifier,
            "sentDate": Int64(sentDate.timeIntervalSince1970 * 1000),
            "entryIdentifier": entryIdentifier,
            "replyThreadIdentifier": replyThreadIdentifier,
            "primaryRecipientIdentifiers": Array(primaryRecipientIdentifiers)
        ]
    }
}

extension PersonNameComponents {
    /// Every field is optional on both sides, so this cannot fail -- but it still returns an
    /// optional, so `compactMapValues` above reads the same as the entry case.
    public static func fromMap(map: [String: Any?]?) -> PersonNameComponents? {
        guard let map = map else {
            return nil
        }
        var components = PersonNameComponents()
        components.namePrefix = map["namePrefix"] as? String
        components.givenName = map["givenName"] as? String
        components.middleName = map["middleName"] as? String
        components.familyName = map["familyName"] as? String
        components.nameSuffix = map["nameSuffix"] as? String
        components.nickname = map["nickname"] as? String
        return components
    }

    public func toMap() -> [String: Any?] {
        return [
            "namePrefix": namePrefix,
            "givenName": givenName,
            "middleName": middleName,
            "familyName": familyName,
            "nameSuffix": nameSuffix,
            "nickname": nickname
        ]
    }
}
