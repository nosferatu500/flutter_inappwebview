//
//  PermissionRequest.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 21/04/22.
//

import Foundation
import WebKit

/// `@MainActor` because `toMap()` calls `WKFrameInfo.toMap()`, an extension on a main-actor WebKit
/// type. Same shape as `CreateWindowAction`.
@MainActor
public class PermissionRequest: NSObject {
    var origin: String
    var resources: [StringOrInt]
    var frame: WKFrameInfo
    
    public init(origin: String, resources: [StringOrInt], frame: WKFrameInfo) {
        self.origin = origin
        self.resources = resources
        self.frame = frame
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "origin": origin,
            "resources": resources,
            "frame": frame.toMap()
        ]
    }
}
