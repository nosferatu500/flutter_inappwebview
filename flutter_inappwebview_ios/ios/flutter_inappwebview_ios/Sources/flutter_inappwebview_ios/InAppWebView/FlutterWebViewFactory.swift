//
//  FlutterWebViewFactory.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Flutter
import Foundation

/// `@MainActor` with an **isolated conformance** to Flutter's `FlutterPlatformViewFactory`
/// (SE-0470): `create(withFrame:viewIdentifier:arguments:)` builds a `FlutterWebViewController`,
/// touches `InAppWebViewManager.keepAliveWebViews` and calls `webView()` — all main-actor. Flutter
/// creates platform views on the platform thread, so this was already true.
@MainActor
public class FlutterWebViewFactory: NSObject, @MainActor FlutterPlatformViewFactory {
    static let VIEW_TYPE_ID = "dev.nosferatu500.inappwebview/inappwebview"
    
    private var plugin: InAppWebViewFlutterPlugin
    
    init(plugin: InAppWebViewFlutterPlugin) {
        self.plugin = plugin
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary
        var flutterWebView: FlutterWebViewController?
        var id: Any = viewId
        
        let keepAliveId = arguments?["keepAliveId"] as? String
        let headlessWebViewId = arguments?["headlessWebViewId"] as? String
        let preventGestureDelay = arguments?["preventGestureDelay"] as? Bool ?? false
        
        if let headlessWebViewId = headlessWebViewId,
           let headlessWebView = plugin.headlessInAppWebViewManager?.webViews[headlessWebViewId],
           let platformView = headlessWebView?.disposeAndGetFlutterWebView(withFrame: frame) {
            flutterWebView = platformView
            flutterWebView?.keepAliveId = keepAliveId
        }
        
        if let keepAliveId = keepAliveId,
           flutterWebView == nil,
           let keepAliveWebView = plugin.inAppWebViewManager?.keepAliveWebViews[keepAliveId] {
            flutterWebView = keepAliveWebView
            if let view = flutterWebView?.view() {
                // remove from parent
                view.removeFromSuperview()
            }
        }
        
        let shouldMakeInitialLoad = flutterWebView == nil
        if flutterWebView == nil {
            if let keepAliveId = keepAliveId {
                id = keepAliveId
            }
            flutterWebView = FlutterWebViewController(plugin: plugin,
                                                      withFrame: frame,
                                                      viewIdentifier: id,
                                                      params: arguments!)
        }
        
        if let keepAliveId = keepAliveId {
            plugin.inAppWebViewManager?.keepAliveWebViews[keepAliveId] = flutterWebView!
        }
        
        flutterWebView?.webView()?.preventGestureDelay = preventGestureDelay
        
        if shouldMakeInitialLoad {
            flutterWebView?.makeInitialLoad(params: arguments!)
        }
        
        return flutterWebView!
    }
}
