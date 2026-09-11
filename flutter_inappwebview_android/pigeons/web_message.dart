// Pigeon schema for the two web-message channels.
//
// Seventh migration off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162)
// and credential_database (§163).
//
// 🚨 **This schema covers TWO channels, deliberately.** P0a says one channel per commit, and the
// exception is forced: `WebMessageChannel` and `WebMessageListener` both carry a `WebMessage`
// payload, and Pigeon emits **unprefixed** class names into a single shared Kotlin package
// (`dev.nosferatu500.inappwebview.pigeons`). Two schemas would each declare a `WebMessageData` and
// the module would stop compiling with `Redeclaration:` -- the same failure mode as the
// `FlutterError` collision in §157. Naming them apart (`WebMessageChannelMessageData`,
// `WebMessageListenerMessageData`) would duplicate an identical type forever. One schema, two
// HostApis, two FlutterApis.
//
// Both channels are **per-instance**: `messageChannelSuffix` carries the channel/listener id, the
// mechanism the pilot proved in §14 and the first use of it since. Every remaining per-WebView
// channel needs it, so this migration is also the rehearsal for those.
//
// Pre-schema checks from §160/§161/§162/§163, all applied:
//   * `@async`? **No.** Every host method completes `result` inline. `setWebMessageCallback`
//     registers a `WebMessagePortCompat.WebMessageCallbackCompat`, but that is the *event* source
//     feeding `onMessage` -- not a completion signal for the call, which returns immediately. Same
//     distinction as `TracingController.stop` in §162, and the reason the rule is "`@async` iff
//     completion is signalled by a callback" rather than "iff a callback appears".
//   * A branch that never calls `result`? **None**; every arm of both delegates answered.
//   * Dart `int` -> Kotlin `Long`? **Yes** -- `index` and `type` both need `.toInt()` (§162).
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/web_message.dart
//   dart format lib/src/pigeons/web_message.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/web_message.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/WebMessage.g.kt',
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
/// Mirrors the platform interface's `IWebMessagePort` as it crosses this boundary.
///
/// The Dart `toMap()` sends exactly these two fields, and the Kotlin `WebMessagePortCompatExt`
/// reads exactly these two, so nothing is lost by naming them.
class WebMessagePortData {
  WebMessagePortData({required this.index, required this.webMessageChannelId});

  /// 0 or 1 — which end of the channel. Crosses as a Dart `int`, i.e. Kotlin `Long`, so the
  /// manager narrows it with `.toInt()` (§162).
  final int index;

  final String webMessageChannelId;
}

/// Mirrors the platform interface's `WebMessage`.
///
/// **The payload is split into two typed fields rather than one `Object?`.** `WebMessage.data` is
/// declared `dynamic` and holds either a `String` or a `Uint8List`, keyed by [type]; the old wire
/// carried it untyped and the Kotlin side recovered it with an unchecked cast:
///
/// ```kotlin
/// port.postMessage(WebMessageCompat(data as ByteArray, ports))   // or data?.toString()
/// ```
///
/// Naming the two shapes separately deletes that cast and lets Pigeon carry the bytes as a real
/// `ByteArray` instead of an `Any?` that happens to be one. Same treatment as §162's category
/// split, and for the same reason: a heterogeneous field is a runtime type test waiting to happen.
///
/// The pairing is **already an invariant of the public type** — `WebMessage`'s constructor asserts
/// that `data` is null-or-`String` exactly when `type` is `STRING`, and a `Uint8List` exactly when
/// it is `ARRAY_BUFFER` — so splitting the field records a rule that already held rather than
/// inventing one.
class WebMessageData {
  WebMessageData({
    required this.type,
    this.stringData,
    this.arrayBufferData,
    this.ports,
  });

  /// `WebMessageType`'s native value: `0` = `STRING`, `1` = `ARRAY_BUFFER`.
  ///
  /// Kept even though [stringData] and [arrayBufferData] are separately typed, because it is the
  /// field the public API carries and it is the only thing that distinguishes a `STRING` message
  /// whose data is **null** from an absent payload. Inferring the type from which field is
  /// non-null would silently change that case.
  ///
  /// Stays an `int` rather than a Pigeon enum, as in §160/§161: the platform interface's
  /// `WebMessageType` is an open `_internal(int)` class, not a closed enum, so a generated enum
  /// would reject values the public API accepts.
  final int type;

  /// Set when [type] is `STRING`. Null is legal here and means a `STRING` message with no data,
  /// which androidx forwards as a null `String`.
  final String? stringData;

  /// Set when [type] is `ARRAY_BUFFER`. Arrives on the Kotlin side as a real `ByteArray`, so
  /// `WebMessageCompat(ByteArray, …)` needs no cast.
  final Uint8List? arrayBufferData;

  /// **Inbound only.** The Kotlin `WebMessageCompatExt.toMap()` omits `ports` entirely, so an
  /// event coming *from* the platform never carries them; only messages Dart posts do. Nullable
  /// rather than a required empty list so that asymmetry stays visible on the type.
  final List<WebMessagePortData>? ports;
}

/// Dart -> platform, one channel per `WebMessageChannel` instance via `messageChannelSuffix`.
@HostApi()
abstract class WebMessageChannelHostApi {
  /// Registers the port's message callback, which is what makes
  /// [WebMessageChannelFlutterApi.onMessage] start firing.
  ///
  /// Returns false only when the underlying view is not an `InAppWebView`. Note it answers
  /// **true** when `WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK` is unsupported and nothing was
  /// registered — "true" here means "no error", not "the callback is live". That is the
  /// hand-written channel's behaviour, preserved deliberately; changing it is a separate decision.
  bool setWebMessageCallback(int index);

  /// Posts [message] through the port at [index].
  ///
  /// Same `true`-when-unsupported caveat as [setWebMessageCallback].
  bool postMessage(int index, WebMessageData message);

  /// Closes the port at [index]. Same caveat again.
  bool close(int index);
}

/// Platform -> Dart, on the same per-instance channel.
@FlutterApi()
abstract class WebMessageChannelFlutterApi {
  /// [message] is nullable because androidx's `WebMessageCallbackCompat.onMessage` may deliver a
  /// null `WebMessageCompat`; the Dart side forwards null to the port's `onMessage` callback.
  void onMessage(int index, WebMessageData? message);
}

/// Dart -> platform, one channel per `WebMessageListener` instance.
@HostApi()
abstract class WebMessageListenerHostApi {
  /// Posts [message] back through the listener's `JavaScriptReplyProxy`.
  ///
  /// Always answers true when the view is an `InAppWebView`: the hand-written channel called
  /// `result.success(true)` unconditionally at the end, including when there was no reply proxy
  /// or `WEB_MESSAGE_LISTENER` was unsupported. Preserved.
  bool postMessage(WebMessageData message);
}

/// Platform -> Dart, on the same per-instance channel.
@FlutterApi()
abstract class WebMessageListenerFlutterApi {
  void onPostMessage(
    WebMessageData? message,
    String? sourceOrigin,
    bool isMainFrame,
  );
}
