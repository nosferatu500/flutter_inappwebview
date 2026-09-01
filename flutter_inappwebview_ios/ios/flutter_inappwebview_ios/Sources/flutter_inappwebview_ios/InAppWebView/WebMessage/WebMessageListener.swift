//
//  WebMessageListener.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation
import WebKit
import Flutter

public class WebMessageListener: FlutterMethodCallDelegate {
    static let METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappwebview_web_message_listener_"
    var id: String
    var jsObjectName: String
    var allowedOriginRules: Set<String>
    var channelDelegate: WebMessageListenerChannelDelegate?
    weak var webView: InAppWebView?
    var plugin: InAppWebViewFlutterPlugin?
    
    public init(plugin: InAppWebViewFlutterPlugin, id: String, jsObjectName: String, allowedOriginRules: Set<String>) {
        self.id = id
        self.plugin = plugin
        self.jsObjectName = jsObjectName
        self.allowedOriginRules = allowedOriginRules
        super.init()
        let channel = FlutterMethodChannel(name: WebMessageListener.METHOD_CHANNEL_NAME_PREFIX + self.id + "_" + self.jsObjectName,
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = WebMessageListenerChannelDelegate(webMessageListener: self, channel: channel)
    }
    
    public func assertOriginRulesValid() throws {
        for (index, originRule) in allowedOriginRules.enumerated() {
            if originRule.isEmpty {
                throw NSError(domain: "allowedOriginRules[\(index)] is empty", code: 0)
            }
            if originRule == "*" {
                continue
            }
            if let url = URL(string: originRule) {
                guard let scheme = url.scheme else {
                    throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                }
                if scheme == "http" || scheme == "https", url.host == nil || url.host!.isEmpty {
                    throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                }
                if scheme != "http", scheme != "https", url.host != nil || url.port != nil {
                    throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                }
                if url.host == nil || url.host!.isEmpty, url.port != nil {
                    throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                }
                if !url.path.isEmpty {
                    throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                }
                if let hostname = url.host {
                    if let firstIndex = hostname.firstIndex(of: "*") {
                        let distance = hostname.distance(from: hostname.startIndex, to: firstIndex)
                        if distance != 0 || (distance == 0 && hostname.prefix(2) != "*.") {
                            throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                        }
                    }
                    if hostname.hasPrefix("[") {
                        if !hostname.hasSuffix("]") {
                            throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                        }
                        let fromIndex = hostname.index(hostname.startIndex, offsetBy: 1)
                        let toIndex = hostname.index(hostname.startIndex, offsetBy: hostname.count - 1)
                        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
                        let ipv6 = String(hostname[indexRange])
                        if !Util.isIPv6(address: ipv6) {
                            throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
                        }
                    }
                }
            } else {
                throw NSError(domain: "allowedOriginRules \(originRule) is invalid", code: 0)
            }
        }
    }
    
    public func initJsInstance(webView: InAppWebView) {
        self.webView = webView
        if let webView = self.webView {
            let jsObjectNameLiteral = Util.jsStringLiteral(jsObjectName)
            let allowedOriginRulesString = allowedOriginRules.map { (allowedOriginRule) -> String in
                if allowedOriginRule == "*" {
                    return "'*'"
                }
                let rule = URL(string: allowedOriginRule)!
                // `host` sits in an expression position, so its quotes are part of the value.
                let host = rule.host != nil ? Util.jsStringLiteral(rule.host!) : "null"
                return """
                {scheme: \(Util.jsStringLiteral(rule.scheme!)), host: \(host), port: \(rule.port != nil ? String(rule.port!) : "null")}
                """
            }.joined(separator: ", ")
            let source = """
            (function() {
                \(WebMessageListener.isOriginAllowedJs)
            
                var allowedOriginRules = [\(allowedOriginRulesString)];
                var isPageBlank = window.location.href === "about:blank";
                var scheme = !isPageBlank ? window.location.protocol.replace(":", "") : null;
                var host = !isPageBlank ? window.location.hostname : null;
                var port = !isPageBlank ? window.location.port : null;
                if (_isOriginAllowed(allowedOriginRules, scheme, host, port)) {
                    window[\(jsObjectNameLiteral)] = new FlutterInAppWebViewWebMessageListener(\(jsObjectNameLiteral));
                }
            })();
            """
            
            let allowedOriginRules = webView.settings?.pluginScriptsOriginAllowList
            let forMainFrameOnly = webView.settings?.pluginScriptsForMainFrameOnly ?? true
            
            webView.configuration.userContentController.addPluginScript(PluginScript(
                groupName: "WebMessageListener-" + id + "-" + jsObjectName,
                source: source,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: forMainFrameOnly,
                allowedOriginRules: allowedOriginRules,
                requiredInAllContentWorlds: false,
                messageHandlerNames: []
            ))
            webView.configuration.userContentController.sync(scriptMessageHandler: webView)
        }
    }
    
    public static func fromMap(plugin: InAppWebViewFlutterPlugin, map: [String:Any?]?) -> WebMessageListener? {
        guard let map = map else {
            return nil
        }
        return WebMessageListener(
            plugin: plugin,
            id: map["id"] as! String,
            jsObjectName: map["jsObjectName"] as! String,
            allowedOriginRules: Set(map["allowedOriginRules"] as! [String])
        )
    }
    
    /**
     Whether a page origin may reach this listener, per `allowedOriginRules`.

     This is one of **two** gates and it is not the outer one. `initJsInstance` injects a JavaScript
     copy of this rule that decides whether `window[jsObjectName]` is created at all, and that copy
     is the only check on the Dart → page direction: `WebMessageListenerChannelDelegate.postMessage`
     evaluates against whatever `window[jsObjectName]` it finds. So the two must agree, and
     `isOriginAllowedJs` below is kept a line-for-line mirror of the `hostAllowed` expression here.

     The wildcard match is anchored at the end of the host — `*.example.com` matches
     `foo.example.com`, and neither bare `example.com` nor `foo.example.com.evil.test`.
     */
    public func isOriginAllowed(scheme: String?, host: String?, port: Int?) -> Bool {
        for allowedOriginRule in allowedOriginRules {
            if allowedOriginRule == "*" {
                return true
            }
            if scheme == nil || scheme!.isEmpty {
                continue
            }
            if scheme == nil || scheme!.isEmpty, host == nil || host!.isEmpty, port == nil || port == 0 {
                continue
            }
            if let rule = URL(string: allowedOriginRule) {
                let rulePort = rule.port == nil || rule.port == 0 ? (rule.scheme == "https" ? 443 : 80) : rule.port!
                let currentPort = port == nil || port == 0 ? (scheme == "https" ? 443 : 80) : port!
                var IPv6: String? = nil
                if let hostname = rule.host, hostname.hasPrefix("[") {
                    let fromIndex = hostname.index(hostname.startIndex, offsetBy: 1)
                    let toIndex = hostname.index(hostname.startIndex, offsetBy: hostname.count - 1)
                    let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
                    do {
                        IPv6 = try Util.normalizeIPv6(address: String(hostname[indexRange]))
                    } catch {}
                }
                var hostIPv6: String? = nil
                if let host = host, Util.isIPv6(address: host) {
                    do {
                        hostIPv6 = try Util.normalizeIPv6(address: host)
                    } catch {}
                }
                
                let schemeAllowed = scheme != nil && !scheme!.isEmpty && scheme == rule.scheme
                
                let hostAllowed = rule.host == nil ||
                    rule.host!.isEmpty ||
                    host == rule.host ||
                    (rule.host!.hasPrefix("*") && host != nil && host!.hasSuffix(rule.host!.split(separator: "*", omittingEmptySubsequences: false)[1])) ||
                    (hostIPv6 != nil && IPv6 != nil && hostIPv6 == IPv6)
                
                let portAllowed = rulePort == currentPort
                
                if schemeAllowed, hostAllowed, portAllowed {
                    return true
                }
            }
        }
        return false
    }
    
    /// The page-side copy of `isOriginAllowed`, injected at document start.
    ///
    /// Every line of its `hostAllowed` expression mirrors the Swift one above, and the mirroring is
    /// load-bearing rather than cosmetic — see that method's note. In particular the wildcard arm
    /// uses `endsWith`, mirroring `hasSuffix`. It was `host.indexOf(suffix) >= 0`, an unanchored
    /// substring test, which admitted `foo.example.com.evil.test` under a rule of `*.example.com`.
    ///
    /// This string is injected into every page the listener is registered for, so it carries no
    /// commentary of its own.
    private static let isOriginAllowedJs = """
        var _normalizeIPv6 = function(ip_string) {
            // replace ipv4 address if any
            var ipv4 = ip_string.match(/(.*:)([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$)/);
            if (ipv4) {
                ip_string = ipv4[1];
                ipv4 = ipv4[2].match(/[0-9]+/g);
                for (var i = 0;i < 4;i ++) {
                    var byte = parseInt(ipv4[i],10);
                    ipv4[i] = ("0" + byte.toString(16)).substr(-2);
                }
                ip_string += ipv4[0] + ipv4[1] + ':' + ipv4[2] + ipv4[3];
            }
        
            // take care of leading and trailing ::
            ip_string = ip_string.replace(/^:|:$/g, '');
        
            var ipv6 = ip_string.split(':');
        
            for (var i = 0; i < ipv6.length; i ++) {
                var hex = ipv6[i];
                if (hex != "") {
                    // normalize leading zeros
                    ipv6[i] = ("0000" + hex).substr(-4);
                }
                else {
                    // normalize grouped zeros ::
                    hex = [];
                    for (var j = ipv6.length; j <= 8; j ++) {
                        hex.push('0000');
                    }
                    ipv6[i] = hex.join(':');
                }
            }
        
            return ipv6.join(':');
        };
        
        var _isOriginAllowed = function(allowedOriginRules, scheme, host, port) {
            for (var rule of allowedOriginRules) {
                if (rule === "*") {
                    return true;
                }
                if (scheme == null || scheme === "") {
                    continue;
                }
                if ((scheme == null || scheme === "") && (host == null || host === "") && (port === 0 || port === "" || port == null)) {
                    continue;
                }
                var rulePort = rule.port == null || rule.port === 0 ? (rule.scheme == "https" ? 443 : 80) : rule.port;
                var currentPort = port === 0 || port === "" || port == null ? (scheme == "https" ? 443 : 80) : port;
                var IPv6 = null;
                if (rule.host != null && rule.host[0] === "[") {
                    try {
                        IPv6 = _normalizeIPv6(rule.host.substring(1, rule.host.length - 1));
                    } catch {}
                }
                var hostIPv6 = null;
                try {
                    hostIPv6 = _normalizeIPv6(host);
                } catch {}
        
                var schemeAllowed = scheme == rule.scheme;
                
                var hostAllowed = rule.host == null ||
                    rule.host === "" ||
                    host === rule.host ||
                    (rule.host[0] === "*" && host != null && host.endsWith(rule.host.split("*")[1])) ||
                    (hostIPv6 != null && IPv6 != null && hostIPv6 === IPv6);
        
                var portAllowed = rulePort === currentPort;
        
                if (schemeAllowed && hostAllowed && portAllowed) {
                    return true;
                }
            }
            return false;
        };
    """

    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        webView = nil
        plugin = nil
    }
    
    isolated deinit {
        debugPrint("WebMessageListener - dealloc")
        dispose()
    }
}
