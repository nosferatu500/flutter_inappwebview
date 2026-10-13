//
//  FlutterMethodNotImplementedSentinel.swift
//  flutter_inappwebview_ios
//

import Foundation
// `@preconcurrency` is required *here and only here*: without it the read of Flutter's mis-declared
// global on the last line is itself the diagnostic, so the shim cannot express its own workaround.
// Scoped to this one file so no other Flutter API silently loses its concurrency checking.
@preconcurrency import Flutter

/// The `FlutterMethodNotImplemented` sentinel, rebound so it can be used under Swift 6.
///
/// Flutter's own header declares it as
///
/// ```objc
/// extern NSObject const* FlutterMethodNotImplemented;   // FlutterChannels.h:213
/// ```
///
/// which is *pointer-to-const-NSObject*, not *const-pointer-to-NSObject*. The `const` binds to the
/// pointee rather than the pointer, so Clang reports the global itself as mutable and Swift imports
/// it as a `var`. Under Swift 6 every single reference is then rejected with
/// "reference to var 'FlutterMethodNotImplemented' is not concurrency-safe because it involves
/// shared mutable state" — 24 of them in this package, all of the form `result(...)`.
///
/// Had the header said `extern NSObject* const FlutterMethodNotImplemented;` Swift would import a
/// `let` and none of this would be needed. That is a defect in the Flutter engine header, not in
/// this plugin, and it cannot be fixed from here.
///
/// `nonisolated(unsafe)` is accurate rather than a shrug: the engine assigns this global once
/// during framework initialisation and never writes it again — it is a singleton identity used only
/// for `==` comparison and for handing back to Flutter. There is no write to race with.
///
/// Remove this shim, and prefer the global directly, if Flutter ever corrects the header.
nonisolated(unsafe) let flutterMethodNotImplemented = FlutterMethodNotImplemented
