//
//  ChromeSafariBrowserManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 18/12/2019.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation
import SafariServices

public class ChromeSafariBrowserManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/chromesafaribrowser"
    var plugin: InAppWebViewFlutterPlugin?
    var browsers: [String: SafariViewController?] = [:]
    var prewarmingTokens: [String: Any?] = [:]
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: ChromeSafariBrowserManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "open":
                let id = arguments!["id"] as! String
                let url = arguments!["url"] as! String
                let settings = arguments!["settings"] as! [String: Any?]
                let menuItemList = arguments!["menuItemList"] as! [[String: Any]]
                open(id: id, url: url, settings: settings,  menuItemList: menuItemList, result: result)
                break
            case "isAvailable":
                result(true)

                break
            case "clearWebsiteData":
                if #available(iOS 16.0, *) {
                    SFSafariViewController.DataStore.default.clearWebsiteData {
                        result(true)
                    }
                } else {
                    result(false)
                }
            case "prewarmConnections":
                let stringURLs = arguments!["URLs"] as! [String]
                var URLs: [URL] = []
                for stringURL in stringURLs {
                    if let url = URL(string: stringURL) {
                        URLs.append(url)
                    }
                }
                let prewarmingToken = SFSafariViewController.prewarmConnections(to: URLs)
                let prewarmingTokenId = NSUUID().uuidString
                prewarmingTokens[prewarmingTokenId] = prewarmingToken
                result([
                    "id": prewarmingTokenId
                ])

            case "invalidatePrewarmingToken":
                let prewarmingToken = arguments!["prewarmingToken"] as! [String:Any?]
                if let prewarmingTokenId = prewarmingToken["id"] as? String,
                   let prewarmingToken = prewarmingTokens[prewarmingTokenId] as? SFSafariViewController.PrewarmingToken? {
                    prewarmingToken?.invalidate()
                    prewarmingTokens[prewarmingTokenId] = nil
                }
                result(true)

            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func open(id: String, url: String, settings: [String: Any?], menuItemList: [[String: Any]], result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        
        if let plugin = plugin {
            
            if let flutterViewController = UIApplication.shared.visibleViewController {
                // flutterViewController could be casted to FlutterViewController if needed
                
                let safariSettings = SafariBrowserSettings()
                let _ = safariSettings.parse(settings: settings)
                
                let safari: SafariViewController
                
                let config = SFSafariViewController.Configuration()
                safari = SafariViewController(plugin: plugin, id: id, url: absoluteUrl, configuration: config,
                                              menuItemList: menuItemList, safariSettings: safariSettings)

                
                safari.prepareSafariBrowser()
                
                flutterViewController.present(safari, animated: true) {
                    result(true)
                }
                
                browsers[id] = safari
            }
            return
        }
        
        result(FlutterError.init(code: "ChromeSafariBrowserManager", message: "SafariViewController is not available!", details: nil))
    }
    
    public override func dispose() {
        super.dispose()
        let browserValues = browsers.values
        browserValues.forEach { (browser: SafariViewController?) in
            browser?.close(result: nil)
            browser?.dispose()
        }
        browsers.removeAll()
        let prewarmingTokensValues = prewarmingTokens.values
        prewarmingTokensValues.forEach { (prewarmingToken: Any?) in
            if let prewarmingToken = prewarmingToken as? SFSafariViewController.PrewarmingToken? {
                prewarmingToken?.invalidate()
            }
        }
        prewarmingTokens.removeAll()

        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
