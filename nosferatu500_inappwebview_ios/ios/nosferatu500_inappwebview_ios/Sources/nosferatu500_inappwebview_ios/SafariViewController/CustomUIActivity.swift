//
//  CustomUIActivity.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/05/22.
//

import Foundation
import UIKit

/// `@MainActor` because `perform()` reaches through the plugin to a `ChromeSafariBrowserManager`
/// and calls a channel delegate — both main-actor isolated now.
///
/// `UIActivity`'s overridable members are nonisolated, so an override can't use the class's
/// isolation. The three the getters read (`type`, `label`, `image`) are `let`s of `Sendable` types,
/// which a nonisolated getter may read, and `perform()` asserts the main actor (UIKit calls it on
/// the main thread).
@MainActor
class CustomUIActivity: UIActivity {
    let plugin: InAppWebViewFlutterPlugin
    let viewId: String
    let id: Int64
    let url: URL
    let title: String?
    let type: UIActivity.ActivityType?
    let label: String?
    let image: UIImage?
    
    init(plugin: InAppWebViewFlutterPlugin, viewId: String, id: Int64, url: URL, title: String?, label: String?, type: UIActivity.ActivityType?, image: UIImage?) {
        self.plugin = plugin
        self.viewId = viewId
        self.id = id
        self.url = url
        self.title = title
        self.label = label
        self.type = type
        self.image = image
    }

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return type
    }

    override var activityTitle: String? {
        return label
    }

    override var activityImage: UIImage? {
        return image
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        // Copied out first: the class isn't `Sendable` (`UIActivity` isn't), so the closure must not
        // capture `self`.
        let plugin = plugin, viewId = viewId, id = id, url = url, title = title
        MainActor.assumeIsolated {
            let browser = plugin.chromeSafariBrowserManager?.browsers[viewId]
            browser??.channelDelegate?.onItemActionPerform(id: id, url: url, title: title)
        }
    }
}
