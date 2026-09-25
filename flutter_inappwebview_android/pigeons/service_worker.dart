// Pigeon schema for the service-worker channel.
//
// Sixteenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175), print_job
// (§177), chrome_custom_tabs (§179), headless_webview (§180) and pull_to_refresh (§182).
//
// Its device group was extended first, as its own item (§185): seven of the eleven methods had never
// run on a device and no response had ever crossed the event. `intercept_response.dart` is the gate
// for this migration — it is the only test anywhere in which a `WebResourceResponse` crosses.
//
// 🚨 **The first FlutterApi in this plugin that returns a value.** `shouldInterceptRequest` is an
// event whose *answer* is the payload that matters, and the platform side cannot wait for it
// asynchronously: `ServiceWorkerClientCompat.shouldInterceptRequest` runs on a Chromium worker
// thread and must return a `WebResourceResponse?` synchronously. So the Kotlin side blocks on a latch
// around the generated FlutterApi's reply callback — the Pigeon twin of
// `Util.invokeMethodAndWaitResult`, which cannot be reused because it takes a raw `MethodChannel`
// and is shared with two `WebViewChannelDelegate` calls and `WebViewAssetLoaderExt`.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No.** The "12 mentions of settings" are the *native*
//      `ServiceWorkerWebSettings` object; every argument on the wire is a primitive or `profileName`.
//   2. `@async`? **No host method is** — each answers inline. The **FlutterApi** method is `@async`,
//      which on a FlutterApi changes only the Dart side: the handler returns a `Future`, because the
//      app's `ServiceWorkerClient.shouldInterceptRequest` is async.
//   3. A branch that never calls `result`? **None** among the host methods. For the event, every
//      path out of the Kotlin wait releases the latch — see the delegate.
//   4. Dart `int` -> Kotlin `Long`? **Two inbound.** `setCacheMode` narrows into
//      `WebSettings`'s `@CacheMode` `@IntDef` (§162's shape; `lintDebug` decides, as for §179 and
//      §182), and a response's `statusCode` narrows into `WebResourceResponse`'s plain `int`.
//   5. Payload type shared with another channel? **Yes, both data classes.**
//      `WebResourceRequestExt` and `WebResourceResponseExt` are also what `WebViewChannelDelegate`'s
//      own `shouldInterceptRequest` carries. Named for the shared native types, as §179 did with
//      `AndroidResourceData` and §180 with `Size2DData`: when the 80-method webview channel migrates
//      it will want exactly these two, and a second declaration in the shared Kotlin package is
//      §165's collision. **Recorded resolution: that migration moves these two classes (and this
//      schema's APIs) into its schema file rather than redeclaring them.**
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No** — the first non-per-instance channel with an event since
//      web_storage_manager. One process-wide `ServiceWorkerControllerCompat`, one native client
//      registration, one Dart client held statically. No `messageChannelSuffix`.
//   8. Event named after a callback? **No collision**: `shouldInterceptRequest` is a member of
//      `ServiceWorkerClient`, not of the controller. A private forwarder is used anyway, because the
//      client it forwards to is *static* — see the controller.
//   9. Fields the wire carries that the platform never reads? **None on the request.** On the
//      response, all seven fields are read by `WebResourceResponseExt`. The setters' `bool` answers
//      are preserved and discarded by Dart, as §177, §180 and §182.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/service_worker.dart
//   dart format lib/src/pigeons/service_worker.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/service_worker.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/ServiceWorker.g.kt',
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
/// Mirrors the native `WebResourceRequestExt` field for field (checklist item 5).
class WebResourceRequestData {
  WebResourceRequestData({
    required this.url,
    required this.headers,
    required this.isRedirect,
    required this.hasGesture,
    required this.isForMainFrame,
    required this.method,
  });

  final String url;
  final Map<String, String>? headers;
  final bool isRedirect;
  final bool hasGesture;
  final bool isForMainFrame;
  final String? method;
}

/// Mirrors the native `WebResourceResponseExt` field for field (checklist item 5).
///
/// Every field is nullable because every field of the public `WebResourceResponse` is, and
/// `WebResourceResponseExt.toWebResourceResponse` branches on which ones are present: a missing
/// `statusCode` or `reasonPhrase` selects the three-argument framework constructor, and non-empty
/// `cookies` select the compat path. Defaulting any of them here would change that choice.
class WebResourceResponseData {
  WebResourceResponseData({
    this.contentType,
    this.contentEncoding,
    this.statusCode,
    this.reasonPhrase,
    this.headers,
    this.data,
    this.cookies,
  });

  final String? contentType;
  final String? contentEncoding;
  final int? statusCode;
  final String? reasonPhrase;
  final Map<String, String>? headers;
  final Uint8List? data;
  final List<String>? cookies;
}

/// Every method but [setServiceWorkerClient] takes a `profileName`: null is the default profile
/// (androidx `ServiceWorkerWebSettingsCompat`), a name is that profile's framework
/// `ServiceWorkerWebSettings`. [setServiceWorkerClient] deliberately takes none — the intercept event
/// carries no profile identity, so a per-profile client could not be told apart in Dart.
@HostApi()
abstract class ServiceWorkerHostApi {
  /// `false` only when the native manager has gone away.
  bool setServiceWorkerClient(bool isNull);

  /// `false` also when the settings are unreachable, as before — unlike the cookie-intercept getter.
  bool getAllowContentAccess(String? profileName);

  bool getAllowFileAccess(String? profileName);

  bool getBlockNetworkLoads(String? profileName);

  int? getCacheMode(String? profileName);

  /// **Nullable, and must stay so**: null is a real answer (feature unsupported, or a named profile,
  /// whose framework settings have no such API). §126 depends on the three states staying apart.
  bool? getIncludeCookiesOnShouldInterceptRequestEnabled(String? profileName);

  bool setAllowContentAccess(bool allow, String? profileName);

  bool setAllowFileAccess(bool allow, String? profileName);

  bool setBlockNetworkLoads(bool flag, String? profileName);

  /// A native `WebSettings` cache-mode constant, narrowed into an `@IntDef` (checklist item 4).
  bool setCacheMode(int mode, String? profileName);

  bool setIncludeCookiesOnShouldInterceptRequestEnabled(
    bool enabled,
    String? profileName,
  );
}

@FlutterApi()
abstract class ServiceWorkerFlutterApi {
  /// The app's answer to a Service Worker's request. **Null means "not handled"** and the request
  /// goes to the network — measured in §185 (a mutant that decoded every answer as null made the
  /// replacement test read `from-server`). So the return type is nullable by necessity, not
  /// convenience.
  ///
  /// `@async` because the app's handler is async; on a FlutterApi that affects only the Dart side.
  @async
  WebResourceResponseData? shouldInterceptRequest(
    WebResourceRequestData request,
  );
}
