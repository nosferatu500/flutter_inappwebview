// Pigeon schema for the per-WebView channel, `WebViewChannelDelegate`: the last hand-written
// channel (§205), migrated in five commits agreed after §205 (TODO P0a):
//   W1 (§207) sync host methods, load/navigate/state  ← this file starts here
//   W2 async host methods · W3 the remaining host methods (the settings pair as maps)
//   W4 fire-and-forget events · W5 value-returning events + the two blocking waits, which also
//   absorbs `service_worker.dart`'s WebResourceRequest/ResponseData and types the custom path
//   handler's answer.
// Between commits `WebViewChannelDelegate` serves this HostApi AND the leftover MethodChannel, and
// the Dart controller holds both (§195's split). Payloads (from W3 on): domain objects cross as maps
// through `Util.normalizeCodecInts`; scalar arguments are typed.
//
// **The suffix is the old channel name's tail**: `inappwebview_$id` for every WebView the plugin
// builds (widget, keep-alive, headless) and `inappbrowser_$id` for an in-app browser's. `id` is the
// same value both languages already interpolate into the MethodChannel name: a platform view id, a
// keep-alive id, a headless id, or a browser id. So Pigeon's channels are exactly as distinct as the
// MethodChannels were, and a keep-alive WebView, whose Kotlin delegate outlives the Dart controller,
// keeps answering the next controller built for the same id.
//
// Pre-schema checklist (§160-§165), all nine run for W1's 25 methods before writing this:
//   1. Settings payload? **None in W1.** Every argument is a string, a bool, an int or bytes.
//      `loadUrl` takes a `URLRequest` map and waits for W3 with the other map-taking methods.
//   2. `@async`? **None.** All 25 answer inline. `getContentHeight`'s JavaScript fallback runs on the
//      Dart side after the answer, as before.
//   3. A branch that never answers? **None.** A missing WebView answers what it always did: null for
//      the getters, `false` for the `can…`/`is…` queries and `prerenderUrl`, `true` for the rest.
//   4. Dart `int` -> Kotlin `Long`? **Two inbound**: `goBackOrForward` and `canGoBackOrForward`'s
//      `steps`, narrowed with `toInt()` for `WebView`'s `int`. Outbound, `getProgress` and
//      `getContentHeight` widen `Int` to `Long`; Dart reads an `int` either way.
//   5. Payload type shared? **None in W1** (no data classes).
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance? **Yes**, see the suffix above. A HostApi mismatch fails fast with a channel
//      error (§177), and every in_app_webview test would see it.
//   8. Event named after a callback? **No events in W1.**
//   9. Fields the wire carries that the platform never reads? **One, dropped: `loadData`'s
//      `allowingReadAccessTo`.** Dart sent it and the Kotlin never read it (it is iOS's). The setters
//      keep the `true` they always answered; Dart discards it (rule 12).
//
// Rule 7: none of the 25 names collides with a member of `WebViewChannelDelegate`.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/in_app_webview.dart
//   dart format lib/src/pigeons/in_app_webview.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/in_app_webview.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/InAppWebView.g.kt',
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
/// Implemented by `WebViewChannelDelegate`, registered for as long as the delegate lives.
///
/// W1 (§207): the synchronous load, navigation and state methods.
@HostApi()
abstract class InAppWebViewHostApi {
  String? getUrl();

  String? getTitle();

  int? getProgress();

  String? getOriginalUrl();

  bool postUrl(String url, Uint8List postData);

  bool loadData(
    String data,
    String? mimeType,
    String? encoding,
    String? baseUrl,
    String? historyUrl,
  );

  /// Throws the `IOException`'s message as a `FlutterError` with code `WebViewChannelDelegate`,
  /// the code and message `result.error` used.
  bool loadFile(String assetFilePath);

  bool reload();

  bool goBack();

  bool canGoBack();

  bool goForward();

  bool canGoForward();

  bool goBackOrForward(int steps);

  bool canGoBackOrForward(int steps);

  bool stopLoading();

  bool isLoading();

  bool clearHistory();

  bool clearSslPreferences();

  bool clearFormData();

  bool pause();

  bool resume();

  bool pauseTimers();

  bool resumeTimers();

  bool prerenderUrl(String url);

  int? getContentHeight();
}
