//
//  InAppBrowserWebViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 17/09/18.
//

import Flutter
import UIKit
import WebKit
import Foundation

public class InAppBrowserWebViewController: UIViewController, InAppBrowserDelegate, UIScrollViewDelegate, UISearchBarDelegate, Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappbrowser_"
    
    var closeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    var progressBar: UIProgressView!
    var menuButton: UIBarButtonItem?
    private var _menu: Any?
    var menu: UIMenu? {
        set {
            _menu = newValue
        }
        get {
            return _menu as? UIMenu
        }
    }
    
    var tmpWindow: UIWindow?
    var id: String = ""
    var plugin: InAppWebViewFlutterPlugin?
    var windowId: Int64?
    var webView: InAppWebView?
    var channelDelegate: InAppBrowserChannelDelegate?
    var initialUrlRequest: URLRequest?
    var initialFile: String?
    var contextMenu: [String: Any]?
    var browserSettings: InAppBrowserSettings?
    var webViewSettings: InAppWebViewSettings?
    var initialData: String?
    var initialMimeType: String?
    var initialEncoding: String?
    var initialBaseUrl: String?
    var initialUserScripts: [[String: Any]] = []
    var pullToRefreshInitialSettings: [String: Any?] = [:]
    var isHidden = false
    var menuItems: [InAppBrowserMenuItem] = []

    public override func loadView() {
        guard let plugin = plugin else {
            return
        }
        
        let channel = FlutterMethodChannel(name: InAppBrowserWebViewController.METHOD_CHANNEL_NAME_PREFIX + id, binaryMessenger: plugin.registrar.messenger())
        channelDelegate = InAppBrowserChannelDelegate(channel: channel)
        
        var userScripts: [UserScript] = []
        for initialUserScript in initialUserScripts {
            userScripts.append(UserScript.fromMap(map: initialUserScript, windowId: windowId)!)
        }
        
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(settings: webViewSettings)
        if let wId = windowId, let webViewTransport = plugin.inAppWebViewManager?.windowWebViews[wId] {
            webView = webViewTransport.webView
            webView!.contextMenu = contextMenu
            webView!.initialUserScripts = userScripts
        } else {
            webView = InAppWebView(id: nil,
                                   plugin: nil,
                                   frame: .zero,
                                   configuration: preWebviewConfiguration,
                                   contextMenu: contextMenu,
                                   userScripts: userScripts)
        }
        
        guard let webView = webView else {
            return
        }
        
        webView.inAppBrowserDelegate = self
        webView.id = id
        webView.plugin = plugin
        webView.channelDelegate = WebViewChannelDelegate(webView: webView, channel: channel)
        
        let pullToRefreshSettings = PullToRefreshSettings()
        let _ = pullToRefreshSettings.parse(settings: pullToRefreshInitialSettings)
        let pullToRefreshControl = PullToRefreshControl(plugin: plugin, id: id, settings: pullToRefreshSettings)
        webView.pullToRefreshControl = pullToRefreshControl
        pullToRefreshControl.delegate = webView
        pullToRefreshControl.prepare()
        
        let findInteractionController = FindInteractionController(
            plugin: plugin,
            id: id, webView: webView, settings: nil)
        webView.findInteractionController = findInteractionController
        findInteractionController.prepare()
        
        prepareWebView()
        webView.windowCreated = true
        
        progressBar = UIProgressView(progressViewStyle: .bar)
        
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.insertSubview(progressBar, aboveSubview: webView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        webView?.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        webView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        webView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        webView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        webView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true

        progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true

        
        if windowId != nil {
            channelDelegate?.onBrowserCreated()
            webView?.runWindowBeforeCreatedCallbacks()
        } else {
            if let contentBlockers = webView?.settings?.contentBlockers, contentBlockers.count > 0 {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: contentBlockers, options: [])
                    let blockRules = String(data: jsonData, encoding: .utf8)
                    WKContentRuleListStore.default().compileContentRuleList(
                        forIdentifier: "ContentBlockingRules",
                        encodedContentRuleList: blockRules) { (contentRuleList, error) in

                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }

                            let configuration = self.webView!.configuration
                            configuration.userContentController.add(contentRuleList!)

                            self.initLoad()
                    }
                    return
                } catch {
                    print(error.localizedDescription)
                }
            }

            
            initLoad()
        }
    }
    
    public func initLoad() {
        if let initialFile = initialFile {
            do {
                try webView?.loadFile(assetFilePath: initialFile)
            }
            catch let error as NSError {
                dump(error)
            }
        }
        else if let initialData = initialData {
            let baseUrl = URL(string: initialBaseUrl ?? "about:blank")!
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.settings?.allowingReadAccessTo, baseUrl.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView?.loadData(data: initialData, mimeType: initialMimeType!, encoding: initialEncoding!, baseUrl: baseUrl, allowingReadAccessTo: allowingReadAccessToURL)
        }
        else if let initialUrlRequest = initialUrlRequest {
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.settings?.allowingReadAccessTo, let url = initialUrlRequest.url, url.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView?.loadUrl(urlRequest: initialUrlRequest, allowingReadAccessTo: allowingReadAccessToURL)
        }
        
        channelDelegate?.onBrowserCreated()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        if !isHidden {
            dispose()
        }
        super.viewDidDisappear(animated)
    }
    
    public override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func prepareNavigationControllerBeforeViewWillAppear() {
        if let browserOptions = browserSettings {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: browserOptions.presentationStyle)!
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: browserOptions.transitionStyle)!
        }
    }
    
    public func prepareWebView() {
        webView?.settings = webViewSettings
        webView?.prepare()
              
        searchBar = UISearchBar()
        searchBar.keyboardType = .URL
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(goForward))
        forwardButton.isEnabled = false
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(goBack))
        backButton.isEnabled = false

        // a UIBarButtonItem instance can appear only once in `toolbarItems`,
        // so every flexible space needs to be its own item
        toolbarItems = [
            backButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            forwardButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            shareButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            reloadButton
        ]

        // the navigation controller view is what shows up behind the translucent
        // bars, inside the status bar and home indicator safe areas
        navigationController?.view.backgroundColor = .systemBackground

        if let browserSettings = browserSettings {
            if !browserSettings.hideToolbarTop {
                navigationController?.navigationBar.isHidden = false
                if browserSettings.hideUrlBar {
                    searchBar.isHidden = true
                }
                if let tintColor = browserSettings.toolbarTopTintColor, !tintColor.isEmpty {
                    navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
                }
                applyToolbarTopAppearance()
            }
            else {
                navigationController?.navigationBar.isHidden = true
            }

            if !browserSettings.hideToolbarBottom {
                navigationController?.isToolbarHidden = false
                if let tintColor = browserSettings.toolbarBottomTintColor, !tintColor.isEmpty {
                    navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
                }
                applyToolbarBottomAppearance()
            }
            else {
                navigationController?.isToolbarHidden = true
            }

            if let closeButtonCaption = browserSettings.closeButtonCaption, !closeButtonCaption.isEmpty {
                closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
            } else {
                setDefaultCloseButton()
            }
            
            if let closeButtonColor = browserSettings.closeButtonColor, !closeButtonColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: closeButtonColor)
            }
            
            if browserSettings.hideProgressBar {
                progressBar.isHidden = true
            }
            
            navigationItem.rightBarButtonItems = []
            
            if !browserSettings.hideCloseButton {
                navigationItem.rightBarButtonItems = [closeButton]
            }
            
            if !menuItems.isEmpty {
                var uiActions: [UIAction] = []
                menuItems = menuItems.sorted(by: {$0.order ?? 0 < $1.order ?? 0})
                for menuItem in menuItems {
                    let uiAction = UIAction(title: menuItem.title, image: menuItem.icon, handler: {_ in
                        self.channelDelegate?.onMenuItemClicked(menuItem: menuItem)
                    })
                    if !menuItem.showAsAction {
                        uiActions.append(uiAction)
                    } else {
                        let buttonItem = UIBarButtonItem(primaryAction: uiAction)
                        buttonItem.tintColor = menuItem.iconColor
                        navigationItem.rightBarButtonItems?.append(buttonItem)
                    }
                }
                if !uiActions.isEmpty {
                    menu = UIMenu(title: "", options: .displayInline, children: uiActions)
                    menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
                    if let menuButtonColor = browserSettings.menuButtonColor, !menuButtonColor.isEmpty {
                        menuButton?.tintColor = UIColor(hexString: menuButtonColor)
                    }
                    let index = browserSettings.hideCloseButton ? 0 : 1
                    navigationItem.rightBarButtonItems?.insert(menuButton!, at: index)
                }
            }
        }
    }
    
    private func configureBarAppearance<T: UIBarAppearance>(_ appearance: T, translucent: Bool, backgroundColor: UIColor?) -> T {
        if translucent {
            appearance.configureWithDefaultBackground()
        } else {
            appearance.configureWithOpaqueBackground()
        }
        if let backgroundColor = backgroundColor {
            appearance.backgroundColor = backgroundColor
        }
        return appearance
    }

    /// Since iOS 13, `UINavigationBar.backgroundColor`/`barTintColor`/`isTranslucent` no longer drive
    /// the bar background: only `UINavigationBarAppearance` does. Setting them leaves the status bar
    /// area uncolored, which shows up as a black strip above the bar.
    func applyToolbarTopAppearance() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        var backgroundColor: UIColor? = nil
        if let bgColor = browserSettings?.toolbarTopBackgroundColor, !bgColor.isEmpty {
            backgroundColor = UIColor(hexString: bgColor)
        }
        if let barTintColor = browserSettings?.toolbarTopBarTintColor, !barTintColor.isEmpty {
            backgroundColor = UIColor(hexString: barTintColor)
        }
        let appearance = configureBarAppearance(UINavigationBarAppearance(),
                                                translucent: browserSettings?.toolbarTopTranslucent ?? true,
                                                backgroundColor: backgroundColor)
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
    }

    /// Same as `applyToolbarTopAppearance`, for the bottom toolbar: without an explicit
    /// `UIToolbarAppearance` the home indicator area stays uncolored.
    func applyToolbarBottomAppearance() {
        guard let toolbar = navigationController?.toolbar else {
            return
        }
        var backgroundColor: UIColor? = nil
        if let bgColor = browserSettings?.toolbarBottomBackgroundColor, !bgColor.isEmpty {
            backgroundColor = UIColor(hexString: bgColor)
        }
        let appearance = configureBarAppearance(UIToolbarAppearance(),
                                                translucent: browserSettings?.toolbarBottomTranslucent ?? true,
                                                backgroundColor: backgroundColor)
        toolbar.standardAppearance = appearance
        toolbar.compactAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.compactScrollEdgeAppearance = appearance
    }

    func setDefaultCloseButton() {
        if closeButton != nil {
            closeButton.target = nil
            closeButton.action = nil
        }
        var barButtonSystemItem = UIBarButtonItem.SystemItem.cancel
        barButtonSystemItem = UIBarButtonItem.SystemItem.close

        closeButton = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: self, action: #selector(close))
    }
    
    public func didChangeTitle(title: String?) {
        guard let _ = title else {
            return
        }
    }
    
    public func didStartNavigation(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didUpdateVisitedHistory(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFinishNavigation(url: URL?) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFailNavigation(url: URL?, error: Error) {
        forwardButton.isEnabled = webView?.canGoForward ?? false
        backButton.isEnabled = webView?.canGoBack ?? false
        progressBar.setProgress(0.0, animated: false)
    }
    
    public func didChangeProgress(progress: Double) {
        progressBar.setProgress(Float(progress), animated: true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              let urlEncoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlEncoded) else {
            return
        }
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    public func show(completion: (() -> Void)? = nil) {
        if let visibleViewController = UIApplication.shared.visibleViewController,
           let navigationController = navigationController {
            isHidden = false
            visibleViewController.present(navigationController, animated: true) {
                completion?()
            }
        } else {
            completion?()
        }
    }

    public func hide(completion: (() -> Void)? = nil) {
        if let navigationController = navigationController {
            isHidden = true
            navigationController.dismiss(animated: true) {
                completion?()
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
        } else {
            completion?()
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        }
    }
    
    @objc public func reload() {
        webView?.reload()
        didUpdateVisitedHistory(url: webView?.url)
    }
    
    @objc public func share() {
        let vc = UIActivityViewController(activityItems: [webView?.url?.absoluteString ?? ""], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    public func close(completion: (() -> Void)? = nil) {
        if (navigationController?.responds(to: #selector(getter: navigationController?.presentingViewController)))! {
            if let presentingViewController = navigationController?.presentingViewController {
                presentingViewController.dismiss(animated: true, completion: {() -> Void in
                    completion?()
                    self.dispose()
                })
            } else {
                completion?()
                dispose()
            }
        }
        else {
            if let parent = navigationController?.parent {
                parent.dismiss(animated: true, completion: {() -> Void in
                    completion?()
                    self.dispose()
                })
            } else {
                completion?()
                dispose()
            }
        }
    }
    
    @objc public func close() {
        close(completion: nil)
    }
    
    @objc public func goBack() {
        if let webView = webView, webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc public func goForward() {
        if let webView = webView, webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc public func goBackOrForward(steps: Int) {
        webView?.goBackOrForward(steps: steps)
    }

    public func setSettings(newSettings: InAppBrowserSettings, newSettingsMap: [String: Any]) {
        let newInAppWebViewSettings = InAppWebViewSettings()
        let _ = newInAppWebViewSettings.parse(settings: newSettingsMap)
        webView?.setSettings(newSettings: newInAppWebViewSettings, newSettingsMap: newSettingsMap)
        
        if newSettingsMap["hidden"] != nil, browserSettings?.hidden != newSettings.hidden {
            if newSettings.hidden {
                hide()
            }
            else {
                show()
            }
        }

        if newSettingsMap["hideUrlBar"] != nil, browserSettings?.hideUrlBar != newSettings.hideUrlBar {
            searchBar.isHidden = newSettings.hideUrlBar
        }

        if newSettingsMap["hideToolbarTop"] != nil, browserSettings?.hideToolbarTop != newSettings.hideToolbarTop {
            navigationController?.navigationBar.isHidden = newSettings.hideToolbarTop
        }

        let topAppearanceChanged =
            (newSettingsMap["toolbarTopBackgroundColor"] != nil && browserSettings?.toolbarTopBackgroundColor != newSettings.toolbarTopBackgroundColor) ||
            (newSettingsMap["toolbarTopBarTintColor"] != nil && browserSettings?.toolbarTopBarTintColor != newSettings.toolbarTopBarTintColor) ||
            (newSettingsMap["toolbarTopTranslucent"] != nil && browserSettings?.toolbarTopTranslucent != newSettings.toolbarTopTranslucent)

        let bottomAppearanceChanged =
            (newSettingsMap["toolbarBottomBackgroundColor"] != nil && browserSettings?.toolbarBottomBackgroundColor != newSettings.toolbarBottomBackgroundColor) ||
            (newSettingsMap["toolbarBottomTranslucent"] != nil && browserSettings?.toolbarBottomTranslucent != newSettings.toolbarBottomTranslucent)

        if newSettingsMap["toolbarTopTintColor"] != nil, browserSettings?.toolbarTopTintColor != newSettings.toolbarTopTintColor {
            if let tintColor = newSettings.toolbarTopTintColor, !tintColor.isEmpty {
                navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.navigationBar.tintColor = nil
            }
        }

        if newSettingsMap["hideToolbarBottom"] != nil, browserSettings?.hideToolbarBottom != newSettings.hideToolbarBottom {
            navigationController?.isToolbarHidden = !newSettings.hideToolbarBottom
        }

        if newSettingsMap["toolbarBottomTintColor"] != nil, browserSettings?.toolbarBottomTintColor != newSettings.toolbarBottomTintColor {
            if let tintColor = newSettings.toolbarBottomTintColor, !tintColor.isEmpty {
                navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.toolbar.tintColor = nil
            }
        }

        if newSettingsMap["closeButtonCaption"] != nil, browserSettings?.closeButtonCaption != newSettings.closeButtonCaption {
            if let closeButtonCaption = newSettings.closeButtonCaption, !closeButtonCaption.isEmpty {
                if let oldTitle = closeButton.title, !oldTitle.isEmpty {
                    closeButton.title = closeButtonCaption
                } else {
                    closeButton.target = nil
                    closeButton.action = nil
                    closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
                }
            } else {
                setDefaultCloseButton()
            }
        }

        if newSettingsMap["closeButtonColor"] != nil, browserSettings?.closeButtonColor != newSettings.closeButtonColor {
            if let tintColor = newSettings.closeButtonColor, !tintColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: tintColor)
            } else {
                closeButton.tintColor = nil
            }
        }
        
        if newSettingsMap["hideCloseButton"] != nil, browserSettings?.hideCloseButton != newSettings.hideCloseButton {
            if !newSettings.hideCloseButton {
                navigationItem.rightBarButtonItems = [closeButton]
            } else {
                navigationItem.rightBarButtonItems = []
            }
        }
        
        if newSettingsMap["presentationStyle"] != nil, browserSettings?.presentationStyle != newSettings.presentationStyle {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: newSettings.presentationStyle)!
        }
        
        if newSettingsMap["transitionStyle"] != nil, browserSettings?.transitionStyle != newSettings.transitionStyle {
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: newSettings.transitionStyle)!
        }
        
        if newSettingsMap["hideProgressBar"] != nil, browserSettings?.hideProgressBar != newSettings.hideProgressBar {
            progressBar.isHidden = newSettings.hideProgressBar
        }
        
        if newSettingsMap["menuButtonColor"] != nil, browserSettings?.menuButtonColor != newSettings.menuButtonColor {
            if let tintColor = newSettings.menuButtonColor, !tintColor.isEmpty {
                menuButton?.tintColor = UIColor(hexString: tintColor)
            } else {
                menuButton?.tintColor = nil
            }
        }
        
        browserSettings = newSettings
        webViewSettings = newInAppWebViewSettings

        // the appearance helpers read from `browserSettings`, so they run once it is up to date
        if topAppearanceChanged {
            applyToolbarTopAppearance()
        }
        if bottomAppearanceChanged {
            applyToolbarBottomAppearance()
        }
    }
    
    public func getSettings() -> [String: Any?]? {
        let webViewSettingsMap = webView?.getSettings()
        if (self.browserSettings == nil || webViewSettingsMap == nil) {
            return nil
        }
        var settingsMap = self.browserSettings!.getRealSettings(obj: self)
        settingsMap.merge(webViewSettingsMap!, uniquingKeysWith: { (current, _) in current })
        return settingsMap
    }
    
    public func dispose() {
        channelDelegate?.onExit()
        channelDelegate?.dispose()
        channelDelegate = nil
        webView?.dispose()
        webView?.removeFromSuperview()
        webView = nil
        view = nil
        transitioningDelegate = nil
        searchBar?.delegate = nil
        closeButton?.target = nil
        forwardButton?.target = nil
        backButton?.target = nil
        reloadButton?.target = nil
        shareButton?.target = nil
        menuButton?.target = nil
        plugin?.inAppBrowserManager?.navControllers[id] = nil
        plugin = nil
    }
    
    isolated deinit {
        debugPrint("InAppBrowserWebViewController - dealloc")
        dispose()
    }
}
