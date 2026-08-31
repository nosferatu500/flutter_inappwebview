//
//  WKContentWorld.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation
import ObjectiveC
import WebKit

extension WKContentWorld {
    // `windowId` cannot be a stored property: an extension of a WebKit class cannot add storage. It
    // is an associated object, so the value lives on the world itself and dies with it.
    //
    // This replaced a `[String: Int64?]` static keyed by the world's **pointer address**, formatted
    // with `String(format: "%p", ...)`. Measured before replacing it (`DEPRECATION_CLEANUP.md` §96),
    // on iOS 17.5 and 26.5: `WKContentWorld.world(name:)` interns by name, and the world it returns
    // stays alive after every reference the plugin holds is gone -- so those keys really were stable
    // and unique, and `TODO.md` P4c's "the allocator eventually hands that address to a different
    // WKContentWorld, which silently inherits the dead one's windowId" **could not happen**. That
    // claim is retracted rather than fixed.
    //
    // What the dictionary did do was grow by one entry per distinct world name for the life of the
    // process -- every `window.open` window gets its own world names -- with no removal anywhere in
    // the package, and make correctness depend on an *undocumented* WebKit behaviour. An associated
    // object has neither property.
    private static var windowIdKey: UInt8 = 0

    var windowId: Int64? {
        get {
            (objc_getAssociatedObject(self, &WKContentWorld.windowIdKey) as? NSNumber)?.int64Value
        }
        set {
            objc_setAssociatedObject(
                self,
                &WKContentWorld.windowIdKey,
                newValue.map { NSNumber(value: $0) },
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public static func fromMap(map: [String:Any?]?, windowId: Int64?) -> WKContentWorld? {
        guard let map = map else {
            return nil
        }
        var name = map["name"] as! String
        name = windowId != nil && name != "page" ?
            WKUserContentController.WINDOW_ID_PREFIX + String(windowId!) + "-" + name :
            name
        let contentWorld = Util.getContentWorld(name: name)
        contentWorld.windowId = name != "page" ? windowId : nil
        return contentWorld
    }
}
