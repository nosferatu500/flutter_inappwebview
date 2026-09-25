// Pigeon schema for the in-app browser manager channel: `open` and `openWithSystemBrowser`.
//
// Nineteenth channel migrated off hand-written MethodChannel dispatch, and the first under §194's
// decision B: **payloads that end up in a settings `parse(Map)` cross as untyped maps.** Every
// field of `open` goes into the browser Activity's `Bundle`. The six that go in as `Serializable`
// (the URL request, settings, context menu, user scripts, pull-to-refresh settings, menu items)
// stay maps here too, so the Activity reads exactly what it read before. The rest are typed.
//
// Device coverage came first, as its own item (§196): every field is asserted on a value only the
// right field produces. The one exception is `encoding`, which has no observable effect.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **Yes, by design, as a map (§194, B).** The settings map, like the other
//      five `Serializable` fields, is passed through untouched into the Bundle; the Activity's
//      `parse(Map)` stays its only reader. 🚨 One question B leaves open: whether an int nested in
//      an untyped Pigeon map still decodes as Kotlin `Int`, which the parser's `value as Int` casts
//      need. §196's `initial settings arrive with their ints and colors intact` answers it on the
//      device.
//   2. `@async`? **None.** `open` starts an Activity and answers; `openWithSystemBrowser` starts an
//      intent and answers, or throws.
//   3. A branch that never calls `result`? **None.** A missing host Activity answers `false` on
//      both, as it did.
//   4. Dart `int` -> Kotlin `Long`? **One inbound**: `windowId`, narrowed with `toInt()` for
//      `Bundle.putInt`. Ints *inside* the maps are not Pigeon-typed and keep whatever the standard
//      codec decodes them as (item 1).
//   5. Payload type shared with another channel? **No, and a predicted one is avoided.**
//      `ChromeCustomTabs.g.kt` records that `AndroidResourceData` would collide "when
//      `InAppBrowserManager` migrates", because menu items carry an `AndroidResource` icon. Menu
//      items stay a map here, so no second declaration exists. `InAppBrowserOpenRequestData` is
//      this channel's own.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** One manager per plugin instance, on its own messenger.
//   8. Event named after a callback? **No events.**
//   9. Fields the wire carries that the platform never reads? **None.** Kotlin reads every key Dart
//      sends; `encoding` is read and handed to the WebView, which ignores it (§196).
//
// The error path: `openWithSystemBrowser` answered `result.error("InAppBrowserManager", "<url>
// cannot be opened!", null)`. It now throws `FlutterError` with the same code, message and
// details, which Pigeon delivers to Dart as the same `PlatformException` (§196 asserts it).
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/in_app_browser_manager.dart
//   dart format lib/src/pigeons/in_app_browser_manager.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/in_app_browser_manager.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/InAppBrowserManager.g.kt',
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
/// Everything `InAppBrowserManager.open` puts into the browser Activity's `Bundle`.
///
/// Exactly one of [urlRequest], [assetFilePath] and [data] is set, by `openUrlRequest`, `openFile`
/// and `openData` respectively.
class InAppBrowserOpenRequestData {
  InAppBrowserOpenRequestData({
    required this.id,
    this.urlRequest,
    this.assetFilePath,
    this.data,
    this.mimeType,
    this.encoding,
    this.baseUrl,
    this.historyUrl,
    required this.settings,
    required this.contextMenu,
    this.windowId,
    required this.initialUserScripts,
    required this.pullToRefreshSettings,
    required this.menuItems,
  });

  /// The browser id: also the suffix of `InAppBrowserHostApi` / `InAppBrowserFlutterApi` (§195).
  final String id;

  /// `URLRequest.toMap()`, passed through as a map. It goes into the Bundle as `Serializable`.
  final Map<String?, Object?>? urlRequest;

  final String? assetFilePath;
  final String? data;
  final String? mimeType;

  /// Handed to `loadDataWithBaseURL`, which ignores it on API 37 (§196).
  final String? encoding;

  final String? baseUrl;
  final String? historyUrl;

  /// `InAppBrowserClassSettings.toMap()`: decision B, a map for the Activity's `parse(Map)`.
  final Map<String?, Object?> settings;

  /// `ContextMenu.toMap()`, or an empty map when there is none, as before.
  final Map<String?, Object?> contextMenu;

  /// Null when the browser was not opened for a window a page asked for. Kotlin stores it with
  /// `putInt`, so it is narrowed there (checklist item 4).
  final int? windowId;

  final List<Map<String?, Object?>?> initialUserScripts;
  final Map<String?, Object?> pullToRefreshSettings;

  /// Each `InAppBrowserMenuItem.toMap()`. A map, which is also what avoids the
  /// `AndroidResourceData` collision (checklist item 5).
  final List<Map<String?, Object?>?> menuItems;
}

/// Implemented by `InAppBrowserManager`.
@HostApi()
abstract class InAppBrowserManagerHostApi {
  /// Starts the browser Activity. `false` when there is no host Activity to start it from.
  bool open(InAppBrowserOpenRequestData request);

  /// Opens [url] in another app. `false` when there is no host Activity; throws when no app can
  /// open it.
  bool openWithSystemBrowser(String url);
}
