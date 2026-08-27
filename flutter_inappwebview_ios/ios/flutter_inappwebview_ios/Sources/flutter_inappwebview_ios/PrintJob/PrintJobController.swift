//
//  PrintJob.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 09/05/22.
//

import Foundation
import UIKit
import Flutter

public enum PrintJobState: Int {
    case created = 1
    case started = 3
    case completed = 5
    case failed = 6
    case canceled = 7
}

public class PrintJobController: NSObject, Disposable, UIPrintInteractionControllerDelegate {
    static let METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappwebview_printjobcontroller_"
    var id: String
    var plugin: InAppWebViewFlutterPlugin?
    var job: UIPrintInteractionController?
    var settings: PrintJobSettings?
    var printFormatter: UIPrintFormatter?
    var printPageRenderer: UIPrintPageRenderer?
    var channelDelegate: PrintJobChannelDelegate?
    var state = PrintJobState.created
    var creationTime = Int64(Date().timeIntervalSince1970 * 1000)
    
    public init(plugin: InAppWebViewFlutterPlugin, id: String, job: UIPrintInteractionController? = nil, settings: PrintJobSettings? = nil) {
        self.id = id
        self.plugin = plugin
        super.init()
        self.job = job
        self.settings = settings
        self.printFormatter = job?.printFormatter
        self.printPageRenderer = job?.printPageRenderer
        self.job?.delegate = self
        let channel = FlutterMethodChannel(name: PrintJobController.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = PrintJobChannelDelegate(printJobController: self, channel: channel)
    }
    
    /// `UIPrintInteractionControllerDelegate` is `NS_SWIFT_UI_ACTOR`, so this witness would inherit
    /// `@MainActor` and Swift 6 would emit an executor check on entry. **UIKit does not honour that
    /// here**: `-[UIPrintPagesController generateWebKitThumbnailsWithCompletionBlock:]` runs on a
    /// background `NSThread` and calls the delegate from `createWebKitPDFForAllPages`, so the check
    /// traps and the process dies with `EXC_BREAKPOINT` in `_dispatch_assert_queue_fail`.
    ///
    /// Declared `nonisolated` to accept the call on whatever thread UIKit uses, then hopped to the
    /// main actor to mutate `state`, which every other accessor touches from there.
    public nonisolated func printInteractionControllerWillStartJob(_ printInteractionController: UIPrintInteractionController) {
        Task { @MainActor [weak self] in
            self?.state = .started
        }
    }
    
    public func present(animated: Bool, completionHandler: UIPrintInteractionController.CompletionHandler? = nil) {
        guard let job = job else {
            return
        }
        
        job.present(animated: animated, completionHandler: { [weak self] (printController, completed, error) in
            if !completed {
                if let _ = error {
                    self?.state = .failed
                } else {
                    self?.state = .canceled
                }
            } else {
                self?.state = .completed
            }
            self?.channelDelegate?.onComplete(completed: completed, error: error)
            if let completionHandler = completionHandler {
                completionHandler(printController, completed, error)
            }
        })
    }
    
    public func getInfo() -> PrintJobInfo? {
        guard let _ = job else {
            return nil
        }
        
        return PrintJobInfo.init(fromPrintJobController: self)
    }
    
    public func disposeNoDismiss() {
        channelDelegate?.dispose()
        channelDelegate = nil
        printFormatter = nil
        printPageRenderer = nil
        job?.delegate = nil
        job = nil
        plugin?.printJobManager?.jobs[id] = nil
        plugin = nil
    }
    
    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        printFormatter = nil
        printPageRenderer = nil
        job?.delegate = nil
        job?.dismiss(animated: false)
        job = nil
        plugin?.printJobManager?.jobs[id] = nil
        plugin = nil
    }
    
    deinit {
        debugPrint("PrintJobController - dealloc")
    }
}
