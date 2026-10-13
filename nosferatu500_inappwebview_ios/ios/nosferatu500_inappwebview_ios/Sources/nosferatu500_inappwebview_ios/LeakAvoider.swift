//
//  LeakAvoider.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/12/2019.
//

import Foundation
import Flutter

/// `@MainActor` because it forwards straight to a `FlutterMethodCallDelegate`, which is main-actor
/// isolated. `LeakAvoider` exists only to break a retain cycle on the method-call handler, so it
/// inherits the isolation of the thing it forwards to.
@MainActor
public class LeakAvoider: NSObject {
    weak var delegate : FlutterMethodCallDelegate?
    
    init(delegate: FlutterMethodCallDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.delegate?.handle(call, result: result)
    }
    
    deinit {
        debugPrint("LeakAvoider - dealloc")
    }
}
