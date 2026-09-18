// Pigeon schema for the per-instance headless-webview channel.
//
// Fourteenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175), print_job (§177)
// and chrome_custom_tabs (§179).
//
// **This migrates the per-instance delegate only.** `AndroidHeadlessInAppWebView` talks to *two*
// channels: this one, and a separate static `HeadlessInAppWebViewManager` channel carrying `run`.
// After this commit the Dart class holds a Pigeon HostApi *and* a raw `MethodChannel` for the
// manager; that is deliberate and the two are independent — the same split §179 left behind for
// `ChromeSafariBrowserManager`.
//
// 🚨 **CORRECTION (§181).** This header originally claimed that manager was "not blocked" because
// `run` carries an `initialSize` rather than a settings payload. **That is wrong.** `run` forwards
// an opaque `HashMap<String, Any?>` straight into `FlutterWebView`, which reads `initialSettings`,
// `pullToRefreshSettings`, `contextMenu`, `initialUserScripts`, `initialUrlRequest`, `initialData`,
// `windowId` and `keepAliveId` out of it — the entire webview creation payload. It is blocked by
// settings exactly as `InAppBrowserManager` (§163) and `ChromeSafariBrowserManager` are.
//
// The claim came from the TODO table's "mentions of settings" column, where that file scores 0 and
// genuinely never says the word. A 0 there means the file does not *name* settings, never that the
// channel does not *carry* them. When the manager is finally unblocked, its HostApi still belongs
// in this file so it reuses [Size2DData].
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No, on this channel.** The three methods are `dispose`, `setSize` and
//      `getSize`; `initialSettings` travels on the manager's `run`, not here. Checked by reading the
//      delegate, not by grepping the count (§175: that count's one hit was a comment).
//   2. `@async`? **None of the three.** Every host method answers inline, so Pigeon's own
//      `try`/`catch` around the synchronous handlers is the only error path and §172's
//      `replyingOnThrow` has nothing to wrap.
//   3. A branch that never calls `result`? **None** -- all three audited. Each has an explicit
//      null-webview arm that answers (`false`, `false` and `null` respectively).
//   4. Dart `int` -> Kotlin `Long`? **No integers cross this wire at all.** A size is two `Double`s
//      in both directions, and `Size2D` already stores them as `Double`. So §162's `[WrongConstant]`
//      narrowing trap has nothing to fire on here — the first migrated channel where that question
//      is vacuous rather than merely answered.
//   5. Payload type shared with another channel? **Yes — `Size2D`, and this schema is where it first
//      crosses a Pigeon wire.** `HeadlessInAppWebViewManager.run` reads an `initialSize` from the
//      same `Size2D.fromMap`, so migrating the manager will want a `Size2DData` too, and Pigeon
//      emits unprefixed names into one shared Kotlin package. That is §165's collision exactly.
//      **Resolution, recorded now so the next commit does not rediscover it: add the manager's
//      HostApi to *this* file** rather than creating `headless_webview_manager.dart`. One file, one
//      declaration, no duplicate type — which is why this schema is named for the feature and not
//      for the delegate class.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes** -- `messageChannelSuffix` carries the headless webview id, the
//      value `METHOD_CHANNEL_NAME_PREFIX + id` used to encode. §177 and §179 measured what a
//      mismatch costs and it differs by direction: a HostApi mismatch fails in ~2s naming the
//      channel, a FlutterApi one hangs silently for 60s with no error. **Both halves are covered
//      here**: the three host methods by `set and get custom size`, and the single event by
//      `run and dispose`, which awaits the controller `onWebViewCreated` hands it and therefore
//      hangs if the event half of the suffix is wrong.
//   8. Event named after a callback? **Yes -- and this is the first channel where that collision
//      does *not* fire.** §14's rule has landed three times because the generated method name
//      matched a *getter on the same class* (`onFindResultReceived`, and the ChromeCustomTabs
//      events). Here the callback is `params.onWebViewCreated` — a field on the creation-params
//      object, not a member of `AndroidHeadlessInAppWebView` — so the class could legally implement
//      the FlutterApi itself. It still does not: see `_HeadlessWebViewFlutterApiImpl`, where the
//      reason is readability rather than the compiler.
//   9. Fields the wire carries that the platform never reads? **Yes, two, and they are kept.**
//      `dispose` and `setSize` have always answered a `bool` that the Dart side discards without
//      binding it. Preserved rather than flattened to `void`, following §177: the bool distinguishes
//      "the webview had already gone away" from "done", and a migration is the wrong commit in which
//      to drop a value from the wire. Recorded here so it is a decision and not an oversight.
//
// 🚨 **The Kotlin `dispose` collision (§177) is live on this channel and is not a compile error.**
// The generated interface contributes `fun dispose(): Boolean`, which cannot coexist with
// `Disposable.dispose(): Unit`. `HeadlessWebViewChannelDelegate` therefore stops implementing
// `ChannelDelegateImpl` and names its teardown `disposeDelegate()`. The trap is the call site:
// `HeadlessInAppWebView.dispose()` used to call `channelDelegate?.dispose()`, which after this
// migration resolves to the *host* method, which calls `webView.dispose()` — an infinite recursion
// that compiles cleanly. See the delegate.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/headless_webview.dart
//   dart format lib/src/pigeons/headless_webview.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/headless_webview.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/HeadlessWebView.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.nosferatu500.inappwebview.pigeons',
      // Every Pigeon Kotlin output declares its own `FlutterError` by default, and all of this
      // plugin's outputs share one package -- so a second declarer stops the module compiling
      // ("Redeclaration: FlutterError"). `find_interaction` is the designated declarer; every
      // other schema in this package must opt out here. See §157.
      includeErrorClass: false,
    ),
    dartPackageName: 'flutter_inappwebview_android',
  ),
)
/// Mirrors the native `Size2D`, which is what both directions of this channel already carry.
///
/// Named for the native type rather than for this channel on purpose: `initialSize` on the
/// manager's `run` is the same `Size2D`, and the next commit is meant to reuse this declaration
/// instead of emitting a second, identical one into the shared Kotlin package (checklist item 5).
///
/// Both axes are logical pixels, Flutter's own unit — the conversion to a `View`'s `Int` physical
/// pixels happens in `HeadlessWebViewSize`, well inside the platform side, and never on the wire.
/// A `-1` on either axis means "match the screen on this axis"; it is a sentinel the platform
/// resolves, not a size, which is why this stays two plain doubles rather than a nullable pair.
class Size2DData {
  Size2DData({required this.width, required this.height});

  final double width;
  final double height;
}

@HostApi()
abstract class HeadlessWebViewHostApi {
  /// Disposes the headless webview.
  ///
  /// `false` means the webview had already gone away, not that disposal failed. The Dart side has
  /// never bound this value (checklist item 9).
  ///
  /// 🚨 Do **not** rename the delegate's teardown to match this — see the file header.
  bool dispose();

  /// Applies a new size, in logical pixels.
  ///
  /// The hand-written channel took a `Map` and ran it through `Size2D.fromMap`, so a malformed or
  /// absent map silently applied nothing and still answered `true`. Typed transport makes that
  /// unrepresentable: the size either arrives well-formed or the codec rejects the call.
  bool setSize(Size2DData size);

  /// The current size in logical pixels, or null if the webview has gone away.
  Size2DData? getSize();
}

@FlutterApi()
abstract class HeadlessWebViewFlutterApi {
  /// Fired once, from the manager's `run`, after the webview exists.
  ///
  /// Ordering matters and is load-bearing: the Dart side registers this handler in `_init()`,
  /// *before* it invokes `run` on the manager channel, because the platform fires this event while
  /// handling that very call. Registering it afterwards would be a race the tests would see as a
  /// 60-second hang rather than an error (checklist item 7).
  void onWebViewCreated();
}
