//
//  WebMessageChannelJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation

/// `@MainActor`: builds JS source that embeds the runtime-settable bridge name, and is only ever
/// called while configuring a `WKUserContentController` on the main thread.
@MainActor
public class WebMessageChannelJS {
    
    public static func WEB_MESSAGE_CHANNELS_VARIABLE_NAME() -> String {
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._webMessageChannels"
    }
    
}
