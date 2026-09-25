// Pigeon schema for the in-app browser's per-instance channel: the four methods that act on the
// browser Activity itself, and its three events.
//
// Eighteenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175), print_job
// (§177), chrome_custom_tabs (§179), headless_webview (§180), pull_to_refresh (§182),
// service_worker (§186) and in_app_webview_manager (§188).
//
// 🚨 **This is half of a shared channel, split out (§189).** The browser's WebView has no channel of
// its own: `InAppBrowserActivity` hands one `inappbrowser_$id` MethodChannel to both the browser
// delegate and the WebView's `WebViewChannelDelegate`, which registered last and so answered every
// call, `show`/`hide`/`close`/`isHidden` included. Those four move here. What stays on the
// MethodChannel is the WebView's own surface plus the browser's `setSettings`/`getSettings`, which
// carry the settings map (decision B, §194) and move in a later commit.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No.** All four methods take no arguments; the only event payload is a
//      menu item id.
//   2. `@async`? **None.** `close` answers inline, after sending `onExit` and disposing the Activity,
//      in that order, and the order is kept.
//   3. A branch that never calls `result`? **None.** A missing Activity used to answer
//      `notImplemented`; now the HostApi is unregistered with the Activity, so there is no handler to
//      answer, which is an error either way.
//   4. Dart `int` -> Kotlin `Long`? **One, outbound**: `onMenuItemClicked`'s id. Kotlin's menu item
//      id is an `Int` and widens to `Long` on the way out; Dart reads an `int` either way.
//   5. Payload type shared with another channel? **No.** No data classes at all.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes.** `messageChannelSuffix` is the browser id: Dart's
//      `AndroidInAppBrowser.id`, which is the Bundle's `"id"` on the Kotlin side.
//   8. Event named after a callback? **Yes, all three.** The Dart side forwards through a private
//      class rather than implementing the FlutterApi on the browser itself (§14).
//   9. Fields the wire carries that the platform never reads? **None.** `show`, `hide` and `close`
//      keep the `bool` they have always answered (`true`); Dart discards it, as §177, §180, §182,
//      §186 and §188 preserved.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/in_app_browser.dart
//   dart format lib/src/pigeons/in_app_browser.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/in_app_browser.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/InAppBrowser.g.kt',
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
/// Implemented by `InAppBrowserChannelDelegate`, registered for as long as its Activity lives.
@HostApi()
abstract class InAppBrowserHostApi {
  /// Brings the browser Activity to the front. Always `true`.
  bool show();

  /// Brings the Activity that opened the browser back to the front. Always `true`, and a no-op when
  /// the browser does not know which Activity opened it.
  bool hide();

  /// Sends `onExit`, disposes the Activity, then answers `true`, in that order.
  bool close();

  bool isHidden();
}

/// Implemented on the Dart side by a private forwarding class.
@FlutterApi()
abstract class InAppBrowserFlutterApi {
  void onBrowserCreated();

  void onMenuItemClicked(int id);

  void onExit();
}
