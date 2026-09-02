//
//  MyCookieManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 26/10/18.
//

import Foundation
import WebKit
import Flutter

public class MyCookieManager: ChannelDelegate, WKHTTPCookieStoreObserver {
    static let METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_cookiemanager"
    static let httpCookieStore = WKWebsiteDataStore.default().httpCookieStore

    private var plugin: InAppWebViewFlutterPlugin?

    /// Whether `self` is currently registered with `httpCookieStore` as a `WKHTTPCookieStoreObserver`.
    ///
    /// `addObserver:` is documented as **not retaining** the observer and as leaving unregistration
    /// to the caller, so this flag exists to guarantee exactly one `removeObserver:` for every
    /// `addObserver:` — a second `addObserver:` would deliver the callback twice, and a missed
    /// `removeObserver:` would leave WebKit holding an unowned pointer to a deallocated delegate.
    private var isObservingCookieStore = false

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: MyCookieManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "setCookie":
                let url = arguments!["url"] as! String
                let name = arguments!["name"] as! String
                let value = arguments!["value"] as! String
                let path = arguments!["path"] as! String
                
                var expiresDate: Int64?
                if let expiresDateString = arguments!["expiresDate"] as? String {
                    expiresDate = Int64(expiresDateString)
                }
                
                let maxAge = arguments!["maxAge"] as? Int64
                let isSecure = arguments!["isSecure"] as? Bool
                let isHttpOnly = arguments!["isHttpOnly"] as? Bool
                let sameSite = arguments!["sameSite"] as? String
                let domain = arguments!["domain"] as? String
                
                MyCookieManager.setCookie(url: url,
                                          name: name,
                                          value: value,
                                          path: path,
                                          domain: domain,
                                          expiresDate: expiresDate,
                                          maxAge: maxAge,
                                          isSecure: isSecure,
                                          isHttpOnly: isHttpOnly,
                                          sameSite: sameSite,
                                          result: result)
                break
            case "getCookies":
                let url = arguments!["url"] as! String
                MyCookieManager.getCookies(url: url, result: result)
                break
            case "getAllCookies":
                MyCookieManager.getAllCookies(result: result)
                break
            case "deleteCookie":
                let url = arguments!["url"] as! String
                let name = arguments!["name"] as! String
                let path = arguments!["path"] as! String
                let domain = arguments!["domain"] as? String
                MyCookieManager.deleteCookie(url: url, name: name, path: path, domain: domain, result: result)
                break
            case "deleteCookies":
                let url = arguments!["url"] as! String
                let path = arguments!["path"] as! String
                let domain = arguments!["domain"] as? String
                MyCookieManager.deleteCookies(url: url, path: path, domain: domain, result: result)
                break
            case "deleteAllCookies":
                MyCookieManager.deleteAllCookies(result: result)
                break
            case "setAcceptCookie":
                let accept = arguments!["accept"] as! Bool
                MyCookieManager.setAcceptCookie(accept: accept, result: result)
                break
            case "isAcceptCookieEnabled":
                MyCookieManager.isAcceptCookieEnabled(result: result)
                break
            case "setCookieStoreObserver":
                let isNull = arguments!["isNull"] as! Bool
                setCookieStoreObserverEnabled(!isNull)
                result(true)
                break
            default:
                result(flutterMethodNotImplemented)
                break
        }
    }
    
    public static func setCookie(url: String,
                          name: String,
                          value: String,
                          path: String,
                          domain: String?,
                          expiresDate: Int64?,
                          maxAge: Int64?,
                          isSecure: Bool?,
                          isHttpOnly: Bool?,
                          sameSite: String?,
                          result: @escaping FlutterResult) {
        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[.originURL] = url
        properties[.name] = name
        properties[.value] = value
        properties[.path] = path
        
        if domain != nil {
            properties[.domain] = domain
        }
        
        if expiresDate != nil {
            // convert from milliseconds
            properties[.expires] = Date(timeIntervalSince1970: TimeInterval(Double(expiresDate!)/1000))
        }
        if maxAge != nil {
            properties[.maximumAge] = String(maxAge!)
        }
        if isSecure != nil && isSecure! {
            properties[.secure] = "TRUE"
        }
        if isHttpOnly != nil && isHttpOnly! {
            properties[.init("HttpOnly")] = "YES"
        }
        if sameSite != nil {
            var sameSiteValue = HTTPCookieStringPolicy(rawValue: "None")
            switch sameSite {
            case "Lax":
                sameSiteValue = HTTPCookieStringPolicy.sameSiteLax
            case "Strict":
                sameSiteValue = HTTPCookieStringPolicy.sameSiteStrict
            default:
                break
            }
            properties[.sameSitePolicy] = sameSiteValue

        }
        
        
        if let cookie = HTTPCookie(properties: properties) {
            MyCookieManager.httpCookieStore.setCookie(cookie, completionHandler: {() in
                result(true)
            })
        } else {
            result(false)
        }
    }
    
    public static func getCookies(url: String, result: @escaping FlutterResult) {
        var cookieList: [[String: Any?]] = []
        
        if let urlHost = URL(string: url)?.host {
            MyCookieManager.httpCookieStore.getAllCookies { (cookies) in
                for cookie in cookies {
                    if urlHost.hasSuffix(cookie.domain) || ".\(urlHost)".hasSuffix(cookie.domain) {
                        var sameSite: String? = nil
                        if let sameSiteValue = cookie.sameSitePolicy?.rawValue {
                            sameSite = sameSiteValue.prefix(1).capitalized + sameSiteValue.dropFirst()
                        }

                        
                        var expiresDateTimestamp: Int64 = -1
                        if let expiresDate = cookie.expiresDate?.timeIntervalSince1970 {
                            // convert to milliseconds
                            expiresDateTimestamp = Int64(expiresDate * 1000)
                        }
                        
                        cookieList.append([
                            "name": cookie.name,
                            "value": cookie.value,
                            "expiresDate": expiresDateTimestamp != -1 ? expiresDateTimestamp : nil,
                            "isSessionOnly": cookie.isSessionOnly,
                            "domain": cookie.domain,
                            "sameSite": sameSite,
                            "isSecure": cookie.isSecure,
                            "isHttpOnly": cookie.isHTTPOnly,
                            "path": cookie.path,
                        ])
                    }
                }
                result(cookieList)
            }
            return
        } else {
            print("Cannot get WebView cookies. No HOST found for URL: \(url)")
        }
        
        result(cookieList)
    }
    
    public static func getAllCookies(result: @escaping FlutterResult) {
        var cookieList: [[String: Any?]] = []
        
        MyCookieManager.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var sameSite: String? = nil
                if let sameSiteValue = cookie.sameSitePolicy?.rawValue {
                    sameSite = sameSiteValue.prefix(1).capitalized + sameSiteValue.dropFirst()
                }

                
                var expiresDateTimestamp: Int64 = -1
                if let expiresDate = cookie.expiresDate?.timeIntervalSince1970 {
                    // convert to milliseconds
                    expiresDateTimestamp = Int64(expiresDate * 1000)
                }
                
                cookieList.append([
                    "name": cookie.name,
                    "value": cookie.value,
                    "expiresDate": expiresDateTimestamp != -1 ? expiresDateTimestamp : nil,
                    "isSessionOnly": cookie.isSessionOnly,
                    "domain": cookie.domain,
                    "sameSite": sameSite,
                    "isSecure": cookie.isSecure,
                    "isHttpOnly": cookie.isHTTPOnly,
                    "path": cookie.path,
                ])
            }
            result(cookieList)
        }
    }
    
    public static func deleteCookie(url: String, name: String, path: String, domain: String?, result: @escaping FlutterResult) {
        var domain = domain
        MyCookieManager.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = url
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL {
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if domain == nil, let domainUrl = URL(string: originURL) {
                    if #available(iOS 16.0, *) {
                        domain = domainUrl.host()
                    } else {
                        domain = domainUrl.host
                    }
                }
                if let domain = domain, cookie.domain == domain, cookie.name == name, cookie.path == path {
                    MyCookieManager.httpCookieStore.delete(cookie, completionHandler: {
                        result(true)
                    })
                    return
                }
            }
            result(false)
        }
    }
    
    public static func deleteCookies(url: String, path: String, domain: String?, result: @escaping FlutterResult) {
        var domain = domain
        let dispatchGroup = DispatchGroup()
        MyCookieManager.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = url
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL {
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if domain == nil, let domainUrl = URL(string: originURL) {
                    if #available(iOS 16.0, *) {
                        domain = domainUrl.host()
                    } else {
                        domain = domainUrl.host
                    }
                }
                if let domain = domain, cookie.domain == domain, cookie.path == path {
                    dispatchGroup.enter()
                    MyCookieManager.httpCookieStore.delete(cookie) {
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                result(true)
            }
        }
    }
    
    public static func deleteAllCookies(result: @escaping FlutterResult) {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeCookies])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{
            result(true)
        })
    }
    
    /// The iOS half of the cookie master switch, from `WKHTTPCookieStore.setCookiePolicy`.
    ///
    /// Reports `false` below iOS 17.0 — the switch could not be applied, which is what the Dart
    /// contract means by a `false` return. It is **not** "cookies are now rejected".
    public static func setAcceptCookie(accept: Bool, result: @escaping FlutterResult) {
        if #available(iOS 17.0, *) {
            // Swift spells the enum `WKHTTPCookieStore.CookiePolicy` (NS_SWIFT_NAME), not
            // `WKCookiePolicy` as the header declares it.
            MyCookieManager.httpCookieStore.setCookiePolicy(accept ? .allow : .disallow) {
                result(true)
            }
        } else {
            result(false)
        }
    }

    /// Reports `nil` below iOS 17.0, matching the Dart contract's "could not be read" rather than
    /// claiming the platform default — the property does not exist there to be read.
    public static func isAcceptCookieEnabled(result: @escaping FlutterResult) {
        if #available(iOS 17.0, *) {
            MyCookieManager.httpCookieStore.getCookiePolicy { policy in
                result(policy == .allow)
            }
        } else {
            result(nil)
        }
    }

    /// Registers or unregisters `self` as the cookie store's observer.
    ///
    /// Registration is driven from Dart rather than done once at plugin start-up: an app that never
    /// sets an observer should not pay a channel message for every cookie the WebView writes.
    func setCookieStoreObserverEnabled(_ enabled: Bool) {
        guard enabled != isObservingCookieStore else {
            return
        }
        // `add(_:)` / `remove(_:)` in Swift; the ObjC selectors are `addObserver:` / `removeObserver:`
        // and using those spellings is a hard error, not a deprecation.
        if enabled {
            MyCookieManager.httpCookieStore.add(self)
        } else {
            MyCookieManager.httpCookieStore.remove(self)
        }
        isObservingCookieStore = enabled
    }

    /// `WKHTTPCookieStoreObserver`. Carries no payload because the protocol declares none — it
    /// reports that the store changed, and Dart re-reads it if it cares.
    @objc public func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onCookiesChanged", arguments: arguments)
    }

    public override func dispose() {
        // Before `super.dispose()`, which drops the channel: WebKit does not retain the observer,
        // so leaving it registered would leave a dangling unowned reference behind this object.
        setCookieStoreObserverEnabled(false)
        super.dispose()
        plugin = nil
    }
    
    isolated deinit {
        dispose()
    }
}
