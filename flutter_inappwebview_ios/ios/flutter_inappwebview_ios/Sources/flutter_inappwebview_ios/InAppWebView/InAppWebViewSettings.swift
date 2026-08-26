//
//  InAppWebViewSettings.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Foundation
import WebKit

@objcMembers
public class InAppWebViewSettings: ISettings<InAppWebView> {
    
    var useShouldOverrideUrlLoading = false
    var useOnLoadResource = false
    var useOnDownloadStart = false
    /// Gates the `WKUIDelegate` open-panel method, and it is **load-bearing rather than an
    /// optimisation**: WebKit runs its own Safari-style file picker only while the delegate does
    /// *not* respond to `webView(_:runOpenPanelWith:initiatedByFrame:completionHandler:)`. There is
    /// no "do the default" call once it is implemented, so `InAppWebView.responds(to:)` hides the
    /// selector unless this is `true`. Leaving it `false` keeps file upload behaving exactly as it
    /// does today.
    var useOnShowFileChooser = false
    var userAgent = ""
    var applicationNameForUserAgent = ""
    var javaScriptEnabled = true
    var javaScriptCanOpenWindowsAutomatically = false
    var mediaPlaybackRequiresUserGesture = true
    var verticalScrollBarEnabled = true
    var horizontalScrollBarEnabled = true
    var resourceCustomSchemes: [String] = []
    var contentBlockers: [[String: [String : Any]]] = []
    var minimumFontSize = 0
    var useShouldInterceptAjaxRequest = false
    var useOnAjaxReadyStateChange = false
    var useOnAjaxProgress = false
    var interceptOnlyAsyncAjaxRequests = true
    var useShouldInterceptFetchRequest = false
    var incognito = false
    var cacheEnabled = true
    var transparentBackground = false
    var disableVerticalScroll = false
    var disableHorizontalScroll = false
    var disableContextMenu = false
    var supportZoom = true
    var allowUniversalAccessFromFileURLs = false
    var allowFileAccessFromFileURLs = false

    var disallowOverScroll = false
    var enableViewportScale = false
    var suppressesIncrementalRendering = false
    var allowsAirPlayForMediaPlayback = true
    var allowsBackForwardNavigationGestures = true
    var allowsLinkPreview = true
    var ignoresViewportScaleLimits = false
    var allowsInlineMediaPlayback = false
    var allowsPictureInPictureMediaPlayback = true
    var isFraudulentWebsiteWarningEnabled = true
    var selectionGranularity = 0
    var dataDetectorTypes: [String] = ["NONE"] // WKDataDetectorTypeNone
    var preferredContentMode = 0
    var sharedCookiesEnabled = false
    var automaticallyAdjustsScrollIndicatorInsets = false
    var accessibilityIgnoresInvertColors = false
    var decelerationRate = "NORMAL" // UIScrollView.DecelerationRate.normal
    var alwaysBounceVertical = false
    var alwaysBounceHorizontal = false
    var scrollsToTop = true
    var isPagingEnabled = false
    var maximumZoomScale = 1.0
    var minimumZoomScale = 1.0
    var contentInsetAdjustmentBehavior = 2 // UIScrollView.ContentInsetAdjustmentBehavior.never
    /// `UIWritingToolsBehavior` raw value, or `nil` to leave WebKit's own default alone.
    ///
    /// Nullable on purpose, following §18's rule: WebKit documents its default as equivalent to
    /// `.limited` (`2`), but `UIWritingToolsBehaviorDefault` is `0` and means "let the system
    /// decide". Defaulting this field to either one would silently change behaviour for callers who
    /// never asked — `0` would hand the choice to the system, `2` would pin it. So it stays `nil`
    /// and is applied with an `if let`.
    ///
    /// **The `_`-prefixed `NSNumber?` is load-bearing, not a style choice.** `ISettings.parse` is
    /// KVC-based (`responds(to: Selector(key))`, then `Selector("_" + key)`), and Swift **cannot
    /// expose an optional value type such as `Int?` to Objective-C at all** — measured, not assumed:
    /// an `@objcMembers` class with `var x: Int?` reports `responds(to: "x") == false` and is absent
    /// from `class_copyPropertyList`, so a bare `Int?` would compile, lint and pass every gate while
    /// never once receiving the value Dart sent.
    ///
    /// There are two working idioms in this package for that problem, and this uses the better one.
    /// The `parse` override below handles `alpha` and the two viewport insets by hand — its comment
    /// says *"nullable values with primitive type must be handled here as super.parse will not
    /// work"* — which fixes reading but leaves the field out of `toMap()`, since `toMap` enumerates
    /// ObjC properties. `PrintJobSettings`' `_x: NSNumber?` + computed-`Int?` pair fixes **both**:
    /// KVC's ivar fallback resolves key `writingToolsBehavior` to the `_writingToolsBehavior` ivar in
    /// each direction, so `parse` needs no special case and `toMap` reports the requested value for
    /// free. `getRealSettings` then overwrites it with what WebKit actually resolved.
    ///
    /// Verified with a standalone probe rather than assumed: naive `Int?` came back `nil` after
    /// `parse` and missing from `toMap`; this pattern round-tripped.
    public var _writingToolsBehavior: NSNumber?
    public var writingToolsBehavior: Int? {
        get {
            return _writingToolsBehavior?.intValue
        }
        set {
            if let newValue = newValue {
                _writingToolsBehavior = NSNumber.init(value: newValue)
            } else {
                _writingToolsBehavior = nil
            }
        }
    }
    var isDirectionalLockEnabled = false
    var mediaType: String? = nil
    var pageZoom = 1.0
    var limitsNavigationsToAppBoundDomains = false
    var useOnNavigationResponse = false
    var applePayAPIEnabled = false
    var allowingReadAccessTo: String? = nil
    var disableLongPressContextMenuOnLinks = false
    var disableInputAccessoryView = false
    var underPageBackgroundColor: String?
    var isTextInteractionEnabled = true
    var isSiteSpecificQuirksModeEnabled = true
    var upgradeKnownHostsToHTTPS = true
    var isElementFullscreenEnabled = true
    var isFindInteractionEnabled = false
    var minimumViewportInset: UIEdgeInsets? = nil
    var maximumViewportInset: UIEdgeInsets? = nil
    var isInspectable = false
    var shouldPrintBackgrounds = false
    var javaScriptHandlersOriginAllowList: [String]? = nil
    var javaScriptBridgeEnabled = true
    var javaScriptBridgeOriginAllowList: [String]? = nil
    var javaScriptBridgeForMainFrameOnly = false
    var pluginScriptsOriginAllowList: [String]? = nil
    var pluginScriptsForMainFrameOnly = false
    var isUserInteractionEnabled = true
    var alpha: Double? = nil
    
    override init(){
        super.init()
    }
    
    override func parse(settings: [String: Any?]) -> InAppWebViewSettings {
        var settings = settings // re-assing to be able to use removeValue
        if let minimumViewportInsetMap = settings["minimumViewportInset"] as? [String : Double] {
            minimumViewportInset = UIEdgeInsets.fromMap(map: minimumViewportInsetMap)
            settings.removeValue(forKey: "minimumViewportInset")
        }
        if let maximumViewportInsetMap = settings["maximumViewportInset"] as? [String : Double] {
            maximumViewportInset = UIEdgeInsets.fromMap(map: maximumViewportInsetMap)
            settings.removeValue(forKey: "maximumViewportInset")
        }
        // nullable values with primitive type (Int, Double, etc.)
        // must be handled here as super.parse will not work
        if let alphaValue = settings["alpha"] as? Double {
            alpha = alphaValue
            settings.removeValue(forKey: "alpha")
        }
        let _ = super.parse(settings: settings)
        return self
    }
    
    override func getRealSettings(obj: InAppWebView?) -> [String: Any?] {
        var realSettings: [String: Any?] = toMap()
        if let webView = obj {
            realSettings["isUserInteractionEnabled"] = webView.isUserInteractionEnabled
            realSettings["alpha"] = Double(webView.alpha)
            let configuration = webView.configuration
            realSettings["userAgent"] = webView.customUserAgent
            realSettings["applicationNameForUserAgent"] = configuration.applicationNameForUserAgent
            realSettings["allowsAirPlayForMediaPlayback"] = configuration.allowsAirPlayForMediaPlayback
            realSettings["allowsLinkPreview"] = webView.allowsLinkPreview
            realSettings["allowsPictureInPictureMediaPlayback"] = configuration.allowsPictureInPictureMediaPlayback

            realSettings["javaScriptCanOpenWindowsAutomatically"] = configuration.preferences.javaScriptCanOpenWindowsAutomatically
            realSettings["mediaPlaybackRequiresUserGesture"] = configuration.mediaTypesRequiringUserActionForPlayback == .all
            realSettings["ignoresViewportScaleLimits"] = configuration.ignoresViewportScaleLimits
            realSettings["dataDetectorTypes"] = Util.getDataDetectorTypeString(type: configuration.dataDetectorTypes)

            realSettings["minimumFontSize"] = Int(configuration.preferences.minimumFontSize)
            realSettings["suppressesIncrementalRendering"] = configuration.suppressesIncrementalRendering
            realSettings["allowsBackForwardNavigationGestures"] = webView.allowsBackForwardNavigationGestures
            realSettings["allowsInlineMediaPlayback"] = configuration.allowsInlineMediaPlayback
            realSettings["isFraudulentWebsiteWarningEnabled"] = configuration.preferences.isFraudulentWebsiteWarningEnabled
            realSettings["preferredContentMode"] = configuration.defaultWebpagePreferences.preferredContentMode.rawValue
            realSettings["automaticallyAdjustsScrollIndicatorInsets"] = webView.scrollView.automaticallyAdjustsScrollIndicatorInsets

            realSettings["selectionGranularity"] = configuration.selectionGranularity.rawValue
            realSettings["accessibilityIgnoresInvertColors"] = webView.accessibilityIgnoresInvertColors
            realSettings["contentInsetAdjustmentBehavior"] = webView.scrollView.contentInsetAdjustmentBehavior.rawValue

            realSettings["decelerationRate"] = Util.getDecelerationRateString(type: webView.scrollView.decelerationRate)
            realSettings["alwaysBounceVertical"] = webView.scrollView.alwaysBounceVertical
            realSettings["alwaysBounceHorizontal"] = webView.scrollView.alwaysBounceHorizontal
            realSettings["scrollsToTop"] = webView.scrollView.scrollsToTop
            realSettings["isPagingEnabled"] = webView.scrollView.isPagingEnabled
            realSettings["maximumZoomScale"] = webView.scrollView.maximumZoomScale
            realSettings["minimumZoomScale"] = webView.scrollView.minimumZoomScale
            realSettings["allowUniversalAccessFromFileURLs"] = configuration.value(forKey: "allowUniversalAccessFromFileURLs")
            realSettings["allowFileAccessFromFileURLs"] = configuration.preferences.value(forKey: "allowFileAccessFromFileURLs")
            realSettings["isDirectionalLockEnabled"] = webView.scrollView.isDirectionalLockEnabled
            realSettings["javaScriptEnabled"] = configuration.preferences.javaScriptEnabled
            realSettings["mediaType"] = webView.mediaType
            realSettings["pageZoom"] = Float(webView.pageZoom)
            realSettings["limitsNavigationsToAppBoundDomains"] = configuration.limitsNavigationsToAppBoundDomains
            realSettings["javaScriptEnabled"] = configuration.defaultWebpagePreferences.allowsContentJavaScript

            realSettings["isTextInteractionEnabled"] = configuration.preferences.isTextInteractionEnabled
            realSettings["upgradeKnownHostsToHTTPS"] = configuration.upgradeKnownHostsToHTTPS
            // Reading the configuration copy is sound even though writing to it is not: the copy
            // faithfully reflects the values the WebView was initialised with. This is the only way
            // a caller can discover what WebKit actually resolved the behaviour to.
            if #available(iOS 18.0, *) {
                realSettings["writingToolsBehavior"] = configuration.writingToolsBehavior.rawValue
            }
            realSettings["underPageBackgroundColor"] = webView.underPageBackgroundColor.hexString

            if #available(iOS 15.4, *) {
                realSettings["isSiteSpecificQuirksModeEnabled"] = configuration.preferences.isSiteSpecificQuirksModeEnabled
                realSettings["isElementFullscreenEnabled"] = configuration.preferences.isElementFullscreenEnabled
            }
            if #available(iOS 15.5, *) {
                realSettings["minimumViewportInset"] = webView.minimumViewportInset.toMap()
                realSettings["maximumViewportInset"] = webView.maximumViewportInset.toMap()
            }
            if #available(iOS 16.0, *) {
                realSettings["isFindInteractionEnabled"] = webView.isFindInteractionEnabled
            }
            if #available(iOS 16.4, *) {
                realSettings["isInspectable"] = webView.isInspectable
                realSettings["shouldPrintBackgrounds"] = configuration.preferences.shouldPrintBackgrounds
            }
        }
        return realSettings
    }
}
