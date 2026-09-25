// Pigeon schema for the in-app-webview manager channel — the process-wide static methods of
// `InAppWebViewController`.
//
// Seventeenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175), print_job
// (§177), chrome_custom_tabs (§179), headless_webview (§180), pull_to_refresh (§182) and
// service_worker (§186).
//
// Its device coverage was written first, as its own item (§187): seven of the fifteen methods had
// never run on a device. 🚨 **Two of the gates are outside the aggregate runner**:
// `integration_test/process_isolated/disable_webview.dart` and `enable_slow_whole_document_draw.dart`
// each have to be run by hand as their own process, or `disableWebView` and
// `enableSlowWholeDocumentDraw` are untested by this migration.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No.** The table's two "settings" mentions are the `WebSettings` class
//      name. Followed to where arguments are read, per §181: every one is a primitive or a list of
//      strings.
//   2. `@async`? **Two of fifteen**: `clearClientCertPreferences` and `setSafeBrowsingAllowlist`
//      answer from a platform callback. Both are wrapped in §172's `replyingOnThrow`. The other
//      thirteen answer inline and are wrapped by Pigeon itself (read in the generated output).
//   3. A branch that never calls `result`? **None** — all fifteen audited, including the
//      feature-gated arms of the two `@async` methods, which answer synchronously.
//   4. Dart `int` -> Kotlin `Long`? **One inbound**: `setDefaultTrafficStatsTag`. The hand-written
//      channel read it as `Number` and called `toInt()`, because the standard codec encodes a Dart
//      int above `Int32.MAX` as an int64 and the androidx javadoc writes the reserved tags in
//      unsigned hex (`0xFFFFFF00`). Pigeon always hands a `Long`; `toInt()` keeps the same low
//      32 bits, so the unsigned form still maps to the same tag. `TrafficStats` takes a plain `int`,
//      not an `@IntDef`.
//   5. Payload type shared with another channel? **No.** `WebViewPackageInfoData` is this channel's
//      alone.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No** — process-wide statics. No `messageChannelSuffix`.
//   8. Event named after a callback? **No events.**
//   9. Fields the wire carries that the platform never reads? **None.** The eight methods that
//      answered `true` with nothing to report keep a `bool` answer, preserved and discarded by Dart
//      as §177, §180, §182 and §186 did.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/in_app_webview_manager.dart
//   dart format lib/src/pigeons/in_app_webview_manager.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/in_app_webview_manager.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/InAppWebViewManager.g.kt',
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
/// Mirrors the two fields the Kotlin side reads off `PackageInfo`, which is also all the public
/// `WebViewPackageInfo` has. Both nullable, as `PackageInfo`'s are.
class WebViewPackageInfoData {
  WebViewPackageInfoData({this.versionName, this.packageName});

  final String? versionName;
  final String? packageName;
}

@HostApi()
abstract class InAppWebViewManagerHostApi {
  /// Null only when the plugin has gone away; the Dart side answers `?? ''`, as before.
  String? getDefaultUserAgent();

  /// `@async`: the platform reports completion through a `Runnable`.
  @async
  bool clearClientCertPreferences();

  /// Null where `SAFE_BROWSING_PRIVACY_POLICY_URL` is unsupported.
  String? getSafeBrowsingPrivacyPolicyUrl();

  /// `@async`: the platform answers through a `ValueCallback<Boolean>`. `false`, synchronously, where
  /// `SAFE_BROWSING_ALLOWLIST` is unsupported.
  @async
  bool setSafeBrowsingAllowlist(List<String> hosts);

  WebViewPackageInfoData? getCurrentWebViewPackage();

  bool setWebContentsDebuggingEnabled(bool debuggingEnabled);

  /// Null where `GET_VARIATIONS_HEADER` is unsupported.
  String? getVariationsHeader();

  /// `false` also where `MULTI_PROCESS` is unsupported.
  bool isMultiProcessEnabled();

  /// `false` where `DEFAULT_TRAFFICSTATS_TAGGING` is unsupported — the platform call throws
  /// `UnsupportedOperationException` there, so the gate is required. See checklist item 4 for the
  /// 32-bit narrowing.
  bool setDefaultTrafficStatsTag(int tag);

  bool disableWebView();

  bool disposeKeepAlive(String keepAliveId);

  bool clearAllCache(bool includeDiskFiles);

  bool enableSlowWholeDocumentDraw();

  bool setJavaScriptBridgeName(String bridgeName);

  String getJavaScriptBridgeName();
}
