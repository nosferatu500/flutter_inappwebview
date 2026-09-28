// Pigeon schema for the Custom Tabs manager channel: `open`, `isAvailable`, `getMaxToolbarItems`
// and `getPackageName`.
//
// Twentieth channel migrated off hand-written MethodChannel dispatch, and the second under §194's
// decision B, after `InAppBrowserManager` (§197), whose shape this copies. Every field of `open`
// goes into the Custom Tabs Activity's `Bundle`. The four the Activity reads back as maps or lists
// of maps (settings, action button, secondary toolbar, menu items) stay maps here too, so the
// Activity reads exactly what it read before. The rest are typed.
//
// Device coverage came first, as its own item (§200): what a test can observe of each field is
// asserted, and what it cannot (referrer, otherLikelyURLs, the single-instance target class, the
// no-history flag) is listed there with the measurement that showed it.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **Yes, by design, as a map (§194, B).** Followed to where it is read:
//      the manager itself reads `isSingleInstance`, `isTrustedWebActivity` and `noHistory` by key
//      *presence* (`Util.getOrDefault`), then the Activity reads the Bundle copy with
//      `ChromeCustomTabsSettings.parse`, `CustomTabsActionButton.fromMap`,
//      `CustomTabsSecondaryToolbar.fromMap` and `CustomTabsMenuItem.fromMap`. 🚨 Pigeon delivers
//      nested ints as `Long` (§197), and the parsers cast five of them `as Int`: `shareState`,
//      `screenOrientation`, `displayMode.displayCutoutMode` (nested one level deeper),
//      `actionButton.id` and each menu item's `id`. So Kotlin passes every map through
//      `Util.normalizeCodecInts`, which keeps null-valued keys: §200's null-key test depends on it.
//   2. `@async`? **None.** `open` starts an Activity and answers, or throws; the other three answer
//      inline.
//   3. A branch that never calls `result`? **None.** A missing host Activity answers `false` for
//      `open` and `isAvailable` and `null` for `getPackageName`, as before.
//   4. Dart `int` -> Kotlin `Long`? **Outbound only**: `getMaxToolbarItems`' `Int` widens to `Long`.
//      Inbound ints exist only *inside* the maps (item 1).
//   5. Payload type shared with another channel? **No, and one is avoided.** The secondary toolbar
//      and menu items carry `AndroidResource`s, which `chrome_custom_tabs.dart` already declares as
//      `AndroidResourceData`. They stay maps here, so no second declaration exists (§165).
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** One manager per plugin instance. The browser's own
//      per-instance channel is `chrome_custom_tabs.dart`, suffixed by the same `id` this sends.
//   8. Event named after a callback? **No events.**
//   9. Fields the wire carries that the platform never reads? **None.** Every field is put into
//      the Bundle and read by the Activity; `settings` is also read by the manager (item 1).
//
// Two answers change shape, not value:
//   * `open`'s "not available" error was `result.error("ChromeBrowserManager", "ChromeCustomTabs is
//     not available!", null)`. It is now a thrown `FlutterError` with the same code, message and
//     details, so Dart sees the same `PlatformException`.
//   * An *unexpected* exception (e.g. the NPE a null launch setting causes, §200) used to reach Dart
//     as code `error` with the exception's message. Pigeon's `wrapError` sends the exception's class
//     name (`NullPointerException`) as the code and its `toString()` as the message.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/chrome_safari_browser_manager.dart
//   dart format lib/src/pigeons/chrome_safari_browser_manager.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/chrome_safari_browser_manager.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/ChromeSafariBrowserManager.g.kt',
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
/// Everything `ChromeSafariBrowserManager.open` puts into the Custom Tabs Activity's `Bundle`.
class ChromeSafariBrowserOpenRequestData {
  ChromeSafariBrowserOpenRequestData({
    required this.id,
    this.url,
    this.headers,
    this.referrer,
    this.otherLikelyURLs,
    required this.settings,
    this.actionButton,
    this.secondaryToolbar,
    required this.menuItemList,
  });

  /// The browser id: also the suffix of `ChromeCustomTabsHostApi` / `ChromeCustomTabsFlutterApi`.
  final String id;

  /// Null opens the tab without a page, for `mayLaunchUrl` / `launchUrl` to use later.
  final String? url;

  final Map<String?, String?>? headers;

  /// Sent as the Intent's referrer. Chrome replaces it with the app's own (§200).
  final String? referrer;

  final List<String?>? otherLikelyURLs;

  /// `ChromeSafariBrowserSettings.toMap()`: decision B, a map for the manager's presence reads and
  /// the Activity's `parse(Map)`.
  final Map<String?, Object?> settings;

  /// `ChromeSafariBrowserActionButton.toMap()`, icon bytes included.
  final Map<String?, Object?>? actionButton;

  /// `ChromeSafariBrowserSecondaryToolbar.toMap()`. A map, which is also what avoids a second
  /// `AndroidResourceData` (checklist item 5).
  final Map<String?, Object?>? secondaryToolbar;

  /// Each `ChromeSafariBrowserMenuItem.toMap()`.
  final List<Map<String?, Object?>?> menuItemList;
}

/// Implemented by `ChromeSafariBrowserManager`.
@HostApi()
abstract class ChromeSafariBrowserManagerHostApi {
  /// Starts the Custom Tabs Activity. `false` when there is no host Activity; throws when Custom
  /// Tabs are not available.
  bool open(ChromeSafariBrowserOpenRequestData request);

  /// `false` when there is no host Activity.
  bool isAvailable();

  /// `CustomTabsIntent.getMaxToolbarItems()`.
  int getMaxToolbarItems();

  /// `CustomTabsClient.getPackageName`. Null when there is no host Activity.
  String? getPackageName(List<String>? packages, bool ignoreDefault);
}
