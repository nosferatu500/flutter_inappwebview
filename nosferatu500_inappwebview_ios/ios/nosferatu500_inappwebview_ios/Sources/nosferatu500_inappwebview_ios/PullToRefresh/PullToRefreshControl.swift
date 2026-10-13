//
//  File.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 03/03/21.
//

import Foundation
import Flutter

public class PullToRefreshControl: UIRefreshControl, Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappwebview_pull_to_refresh_"

    var plugin: InAppWebViewFlutterPlugin?
    var channelDelegate: PullToRefreshChannelDelegate?
    var settings: PullToRefreshSettings?
    var shouldCallOnRefresh = false
    var delegate: PullToRefreshDelegate?
    
    public init(plugin: InAppWebViewFlutterPlugin, id: Any, settings: PullToRefreshSettings?) {
        super.init()
        self.plugin = plugin
        self.settings = settings
        let channel = FlutterMethodChannel(name: PullToRefreshControl.METHOD_CHANNEL_NAME_PREFIX + String(describing: id),
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = PullToRefreshChannelDelegate(pullToRefreshControl: self, channel: channel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func prepare() {
        if let settings = settings {
            if settings.enabled {
                delegate?.enablePullToRefresh()
            }
            if let color = settings.color, !color.isEmpty {
                tintColor = UIColor(hexString: color)
            }
            if let backgroundTintColor = settings.backgroundColor, !backgroundTintColor.isEmpty {
                backgroundColor = UIColor(hexString: backgroundTintColor)
            }
            if let attributedTitleMap = settings.attributedTitle {
                attributedTitle = NSAttributedString.fromMap(map: attributedTitleMap)
            }
        }
        addTarget(self, action: #selector(updateShouldCallOnRefresh), for: .valueChanged)
    }
    
    public func onRefresh() {
        shouldCallOnRefresh = false
        channelDelegate?.onRefresh()
    }

    /// A `beginRefreshing()` made while the control isn't in a window. UIKit ignores one then, and the
    /// control doesn't refresh when the window arrives either (measured §288: the WebView loaded but
    /// not yet composited, `isRefreshing` false before and after). So it is remembered, reported by
    /// `isRefreshing`, and applied in `didMoveToWindow`; `endRefreshing()` drops it. Android's
    /// `setRefreshing(true)` takes effect whether or not the view is attached. `isRefreshing` reports
    /// the pending call only until there is a window; from then on it is UIKit's own state.
    private var pendingBeginRefreshing = false

    override public func beginRefreshing() {
        guard window != nil else {
            pendingBeginRefreshing = true
            return
        }
        pendingBeginRefreshing = false
        super.beginRefreshing()
    }

    override public func endRefreshing() {
        pendingBeginRefreshing = false
        super.endRefreshing()
    }

    override public var isRefreshing: Bool {
        return (window == nil && pendingBeginRefreshing) || super.isRefreshing
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if pendingBeginRefreshing, window != nil {
            pendingBeginRefreshing = false
            super.beginRefreshing()
        }
    }
    
    @objc public func updateShouldCallOnRefresh() {
        shouldCallOnRefresh = true
    }
    
    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        removeTarget(self, action: #selector(updateShouldCallOnRefresh), for: .valueChanged)
        delegate = nil
        plugin = nil
    }
    
    isolated deinit {
        debugPrint("PullToRefreshControl - dealloc")
        dispose()
    }
}
