//
//  CustomSchemeHandler.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 25/10/2019.
//

import Flutter
import Foundation
import WebKit

public class CustomSchemeHandler: NSObject, WKURLSchemeHandler {
    var schemeHandlers: [Int: WKURLSchemeTask] = [:]
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        schemeHandlers[urlSchemeTask.hash] = urlSchemeTask
        let inAppWebView = webView as! InAppWebView
        let request = WebResourceRequest.init(fromURLRequest: urlSchemeTask.request)
        let callback = WebViewChannelDelegate.LoadResourceWithCustomSchemeCallback()

        // A WKURLSchemeTask must be completed exactly once: leaving it open hangs the resource
        // load and leaks the entry in schemeHandlers, while completing it twice (or after
        // `stop`) raises an NSException and takes the app down. Membership of schemeHandlers is
        // the single source of truth for "still owed a completion" -- every path below checks it
        // and removes the entry, and `stop` removes it when WebKit cancels first.
        let finish: (CustomSchemeResponse?) -> Void = { response in
            guard self.schemeHandlers.removeValue(forKey: urlSchemeTask.hash) != nil else {
                return
            }
            if let response = response {
                let urlResponse = URLResponse(url: request.url, mimeType: response.contentType, expectedContentLength: -1, textEncodingName: response.contentEncoding)
                urlSchemeTask.didReceive(urlResponse)
                urlSchemeTask.didReceive(response.data)
                urlSchemeTask.didFinish()
            } else {
                // No response to substitute. Previously nothing happened here at all, so the task
                // stayed pending forever and the page waited on a resource that would never
                // arrive. Failing it lets WebKit finish the load.
                urlSchemeTask.didFailWithError(NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorResourceUnavailable,
                    userInfo: [NSLocalizedDescriptionKey:
                        "No response was returned for the custom scheme URL \(request.url.absoluteString)"]
                ))
            }
        }

        callback.nonNullSuccess = { (response: CustomSchemeResponse) in
            finish(response)
            return false
        }
        callback.defaultBehaviour = { (response: CustomSchemeResponse?) in
            finish(response)
        }
        callback.error = { (code: String, message: String?, details: Any?) in
            print(code + ", " + (message ?? ""))
            finish(nil)
        }

        if let channelDelegate = inAppWebView.channelDelegate {
            channelDelegate.onLoadResourceWithCustomScheme(request: request, callback: callback)
        } else {
            callback.defaultBehaviour(nil)
        }
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        schemeHandlers.removeValue(forKey: urlSchemeTask.hash)
    }
}
