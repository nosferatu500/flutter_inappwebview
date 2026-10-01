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
// W2 (§210), the nine methods that answer from a callback, checklist run again:
//   1. Settings payload? None, but three **maps**: `contentWorld` (two methods), `callAsyncJavaScript`'s
//      `arguments` and `takeScreenshot`'s configuration. All go through `Util.normalizeCodecInts`.
//      The configuration's `quality` is the one read `as Int`, inside a posted runnable that catches
//      only `IllegalArgumentException`, so without normalization it would crash the app.
//   2. `@async`? **All nine**, each wrapped in `replyingOnThrow` (see the generated handlers).
//   3. A branch that never answers? **Three, unchanged by the migration.** `callAsyncJavaScript`, and
//      `evaluateJavascript` in a non-page content world, wait for the page's bridge, and a page that
//      never answers never replies. `postVisualStateCallback` never replies if the WebView is
//      destroyed first (the platform's contract). A missing WebView answers at once, as before:
//      null, or `false` for `isSecureContext` and `documentHasImages`.
//   4. Dart `int` -> Kotlin `Long`? `quality` (above) and any int inside `arguments`. Outbound,
//      `getContentWidth` widens `Int` to `Long`.
//   5. Payload type shared? None (maps).
//   9. Fields the wire carries that the platform never reads? **`afterScreenUpdates`**, in the
//      configuration map; it's iOS's. It stays in the map: the map is `toMap()`'s, unfiltered.
// Rule 7: none of the nine names collides with a member of `WebViewChannelDelegate`, which
// implements the HostApi. `InAppWebView`'s methods of the same names are the callees.
//
// W3 (§212), the last 42 host methods, checklist run a third time. After W3 the MethodChannel
// carries only Kotlin -> Dart events (W4, W5):
//   1. Settings payload? **Yes**: `setSettings` / `getSettings` cross as untyped maps (decision B,
//      §194), and `parse` stays the single definition. Other inbound maps: `URLRequest`, the two
//      inject attribute maps, `PrintJobSettings`, the focus rect, the context menu, `UserScript`, the
//      web message and listener. All go through `Util.normalizeCodecInts`. The int readers among
//      them (18 in settings, 7 in print settings, the menu item id, `injectionTime`, the message
//      `type` and port `index`) are each asserted on a device (§211's table).
//   2. `@async`? **None.** All 42 answer inline.
//   3. A branch that never answers? None. A missing WebView answers what it always did: `true` for
//      the commands, `false` for the queries and for `pageDown`/`pageUp`/`zoomIn`/`zoomOut`/
//      `requestFocus`/`addUserScript`/`removeUserScript`/`restoreState`/the input-method pair/
//      `setAudioMuted`, null for the getters and `printCurrentPage`.
//   4. Dart `int` -> Kotlin `Long`: `scrollTo`/`scrollBy`'s x and y, `flingScroll`'s velocities,
//      `requestFocus`'s direction, `removeUserScript`'s index and `saveState`'s `maxSize`, each
//      narrowed with `toInt()`. Outbound, `getScrollX`/`getScrollY` widen to `Long`, and
//      `getZoomScale`'s `Float` widens to `Double`.
//   5. Payload type shared? None (maps).
//   9. Fields the wire carries that Android never reads? **Two, dropped**: `loadUrl`'s
//      `allowingReadAccessTo` (iOS's, like W1's `loadData`) and `zoomBy`'s `animated`.
// W4 (§214), the 35 fire-and-forget events, on `InAppWebViewFlutterApi`:
//   1. Payloads: scalars are typed; domain objects (hit test result, download request, resource
//      request / error / response, navigation, page) cross as their `toMap()` maps, read by the same
//      `fromMap`s as before. Kotlin -> Dart, so no `normalizeCodecInts`: a Kotlin `Int` arrives as a
//      Dart `int` either way.
//   2. `@async`? **All 35, on the Dart side only** (a FlutterApi is callback-based in Kotlin anyway).
//      The Dart handler re-enters the controller's `_handleMethod`, which is async; `@async` lets
//      Pigeon await it, so a throw (a user callback, or a payload `fromMap` can't read) becomes an
//      error reply that Kotlin ignores, exactly as the MethodChannel did. A plain `void` would leave
//      that Future unawaited and turn the same throw into an unhandled zone error.
//   3. Never answers? Fire-and-forget: Kotlin passes an empty callback, as `invokeMethod` had none.
//   5. Shared types? None.
//   7. Per-instance: the same suffix as the HostApi. A FlutterApi mismatch is **silent** (rule 5):
//      every event would vanish, and every device test waiting for `onLoadStop` would time out.
//   8. Event named after a callback? The names are the MethodChannel's, unchanged.
// The Dart handler rebuilds the exact arguments Kotlin used to send and dispatches them through
// `_handleMethod`, so each event keeps its one definition there (and the unit tests that drive
// `handleMethod` directly stay valid). W5 moves the value-returning events the same way.
//
// W5 (§216), the 19 value-returning events and the two blocking waits, on the same FlutterApi. After
// W5 nothing uses the per-WebView MethodChannel. Checklist:
//   1. Payloads: arguments as W4 (scalars typed, domain objects as `toMap()` maps), except the two
//      waits' request, which is the typed `WebResourceRequestData`. Answers are what Dart always
//      returned: response maps (`toMap()`), an int policy/action, a bool, the visited URLs, the JS
//      handler's JSON text, and for `shouldInterceptRequest` the typed `WebResourceResponseData`.
//   2. `@async`? **All 21, Dart side**, as W4: the handler returns `_handleMethod`'s value.
//   3. Never answers? As before: a Dart callback that never completes leaves the event pending, and
//      the two waits are bounded by `syncCallbackTimeoutMillis`.
//   4. Dart `int` -> Kotlin `Long`: **every int answer, and every int inside an answer map**
//      (policies, dialog/permission/auth/safe-browsing actions, form resubmission, render process).
//      Each reply goes through `Util.normalizeCodecInts` before the old `decodeResult`, so each
//      decoder reads what it always did.
//   5. Shared types: **`WebResourceRequestData` and `WebResourceResponseData` move here** with the
//      service-worker APIs (§186's recorded resolution: Pigeon can't share a type across schema
//      files), and the custom path handler's answer is typed with them (§205). `service_worker.dart`
//      and `custom_path_handler.dart` are deleted.
//   7. Per-instance: the WebView events use the HostApi's suffix. The service-worker APIs have none
//      (one process-wide client) and the path handler's is its id, both unchanged.
//   8. Names: the MethodChannel's, unchanged.
//   9. Never read on Android: `isMainFrame` (the JS dialogs) and `frame` (permission requests) are
//      always null here. Kept, as the MethodChannel carried them, so the Dart maps stay key for key.
// Errors: a Dart throw arrives as a `FlutterError` and goes to each callback's `error`, as the
// MethodChannel's error envelope did. **A missing Dart handler** (`channel-error`) goes to
// `notImplemented`, which is what the MethodChannel answered then, so each event takes its old
// default rather than its error branch (they differ for the JS dialogs and the JS handler, §215).
//
// The service-worker APIs (§186) and the custom path handler (§205) keep their own headers below.
//
// Errors: `postWebMessage` and `addWebMessageListener` threw `result.error(LOG_TAG, e.message)`,
// so they throw a `FlutterError` with the same code and message. Any other throw (an invalid print
// colour mode, `restoreState(null)`) now arrives under the exception's class name instead of the
// MethodChannel's `error` (rule 26).
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
/// W1 (§207): the synchronous load, navigation and state methods. W2 (§210): the nine methods that
/// answer from a callback.
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

  // W2 (§210): the methods that answer from a callback.

  /// The script's result as WebView reports it: JSON text, which Dart decodes. A non-page
  /// `contentWorld` answers through the page's bridge.
  @async
  String? evaluateJavascript(
    String source,
    Map<String?, Object?>? contentWorld,
  );

  /// The same JSON text as before: `{"value": …, "error": …}`, which Dart decodes.
  @async
  String? callAsyncJavaScript(
    String functionBody,
    Map<String?, Object?> arguments,
    Map<String?, Object?>? contentWorld,
  );

  /// `screenshotConfiguration` is `ScreenshotConfiguration.toMap()`. Null when the capture throws
  /// `IllegalArgumentException` (for example a 0 × 0 WebView).
  @async
  Uint8List? takeScreenshot(Map<String?, Object?>? screenshotConfiguration);

  @async
  int? getContentWidth();

  @async
  String? getSelectedText();

  /// The saved file's path, or null when WebView couldn't save.
  @async
  String? saveWebArchive(String filePath, bool autoname);

  @async
  bool isSecureContext();

  /// Answers once the next frame is on screen: that is the feature.
  @async
  void postVisualStateCallback();

  @async
  bool documentHasImages();

  // W3 (§212): the rest. Maps are the domain objects' `toMap()`, unfiltered.

  bool loadUrl(Map<String?, Object?> urlRequest);

  bool injectJavascriptFileFromUrl(
    String urlFile,
    Map<String?, Object?>? scriptHtmlTagAttributes,
  );

  bool injectCSSCode(String source);

  bool injectCSSFileFromUrl(
    String urlFile,
    Map<String?, Object?>? cssLinkHtmlTagAttributes,
  );

  /// `InAppWebViewSettings.toMap()`, parsed by `InAppWebViewSettings.parse` (decision B, §194).
  bool setSettings(Map<String?, Object?> settings);

  Map<String?, Object?>? getSettings();

  Map<String?, Object?>? getCopyBackForwardList();

  bool scrollTo(int x, int y, bool animated);

  bool scrollBy(int x, int y, bool animated);

  /// The new job's id when `handledByClient`, otherwise null.
  String? printCurrentPage(Map<String?, Object?>? settings);

  bool zoomBy(double zoomFactor);

  double? getZoomScale();

  Map<String?, Object?>? getHitTestResult();

  bool pageDown(bool bottom);

  bool pageUp(bool top);

  bool zoomIn();

  bool zoomOut();

  bool clearFocus();

  bool requestFocus(
    int? direction,
    Map<String?, Object?>? previouslyFocusedRect,
  );

  bool setContextMenu(Map<String?, Object?>? contextMenu);

  Map<String?, Object?>? requestFocusNodeHref();

  Map<String?, Object?>? requestImageRef();

  int? getScrollX();

  int? getScrollY();

  Map<String?, Object?>? getCertificate();

  bool addUserScript(Map<String?, Object?> userScript);

  bool removeUserScript(int index, Map<String?, Object?> userScript);

  bool removeUserScriptsByGroupName(String groupName);

  bool removeAllUserScripts();

  Map<String?, Object?>? createWebMessageChannel();

  /// Throws the platform's failure as a `FlutterError` with code `WebViewChannelDelegate`.
  bool postWebMessage(Map<String?, Object?> message, String targetOrigin);

  /// Throws the platform's failure as a `FlutterError` with code `WebViewChannelDelegate`.
  bool addWebMessageListener(Map<String?, Object?> webMessageListener);

  bool canScrollVertically();

  bool canScrollHorizontally();

  bool isInFullscreen();

  bool hideInputMethod();

  bool showInputMethod();

  /// Null bounds mean "no constraint": the framework `WebView.saveState`, no feature needed (§124).
  Uint8List? saveState(int? maxSize, bool? includeForwardState);

  /// A null `state` throws, as it did on the MethodChannel.
  bool restoreState(Uint8List? state);

  bool setAudioMuted(bool muted);

  bool isAudioMuted();

  bool flingScroll(int velocityX, int velocityY);
}

/// Implemented by the Dart controller, registered under the same suffix as [InAppWebViewHostApi].
///
/// W4 (§214): the fire-and-forget events. Maps are the domain objects' `toMap()`.
@FlutterApi()
abstract class InAppWebViewFlutterApi {
  @async
  void onLoadStart(String? url);

  @async
  void onLoadStop(String? url);

  @async
  void onReceivedError(
    Map<String?, Object?> request,
    Map<String?, Object?> error,
  );

  @async
  void onReceivedHttpError(
    Map<String?, Object?> request,
    Map<String?, Object?> errorResponse,
  );

  @async
  void onProgressChanged(int progress);

  @async
  void onConsoleMessage(String? message, int messageLevel);

  @async
  void onScrollChanged(int x, int y);

  @async
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY);

  /// `DownloadStartRequest.toMap()`.
  @async
  void onDownloadStarting(Map<String?, Object?> downloadStartRequest);

  @async
  void onCloseWindow();

  @async
  void onTitleChanged(String? title);

  @async
  void onGeolocationPermissionsHidePrompt();

  @async
  void onReceivedTouchIconUrl(String? url, bool precomposed);

  @async
  void onPermissionRequestCanceled(String? origin, List<String?>? resources);

  @async
  void onUpdateVisitedHistory(String? url, bool isReload);

  @async
  void onZoomScaleChanged(double oldScale, double newScale);

  @async
  void onPageCommitVisible(String? url);

  /// `HitTestResult.toMap()`, or null.
  @async
  void onLongPressHitTestResult(Map<String?, Object?>? hitTestResult);

  /// `HitTestResult.toMap()`, or null.
  @async
  void onCreateContextMenu(Map<String?, Object?>? hitTestResult);

  @async
  void onHideContextMenu();

  @async
  void onContextMenuActionItemClicked(int id, String? title);

  @async
  void onEnterFullscreen();

  @async
  void onExitFullscreen();

  @async
  void onRequestFocus();

  @async
  void onRenderProcessGone(bool didCrash, int rendererPriorityAtExit);

  @async
  void onReceivedLoginRequest(String? realm, String? account, String? args);

  @async
  void onNavigationStarted(Map<String?, Object?> navigation);

  @async
  void onNavigationRedirected(Map<String?, Object?> navigation);

  @async
  void onNavigationCompleted(Map<String?, Object?> navigation);

  @async
  void onPageLoadEvent(Map<String?, Object?> page);

  @async
  void onPageDomContentLoadedEvent(Map<String?, Object?> page);

  @async
  void onPageDeleted(Map<String?, Object?> page);

  @async
  void onFirstContentfulPaintMillis(
    Map<String?, Object?> page,
    int durationMillis,
  );

  @async
  void onLargestContentfulPaintMillis(
    Map<String?, Object?> page,
    int durationMillis,
  );

  @async
  void onPerformanceMarkMillis(
    Map<String?, Object?> page,
    String markName,
    int markTimeMillis,
  );

  // W5 (§216): the events whose answer the platform acts on. Null is "no answer" for each, the same
  // value the Dart side returned on the MethodChannel when no callback was set.

  /// `JsAlertResponse.toMap()`.
  @async
  Map<String?, Object?>? onJsAlert(
    String? url,
    String? message,
    bool? isMainFrame,
  );

  /// `JsConfirmResponse.toMap()`.
  @async
  Map<String?, Object?>? onJsConfirm(
    String? url,
    String? message,
    bool? isMainFrame,
  );

  /// `JsPromptResponse.toMap()`.
  @async
  Map<String?, Object?>? onJsPrompt(
    String? url,
    String? message,
    String? defaultValue,
    bool? isMainFrame,
  );

  /// `JsBeforeUnloadResponse.toMap()`.
  @async
  Map<String?, Object?>? onJsBeforeUnload(String? url, String? message);

  /// `createWindowAction` is `CreateWindowAction.toMap()`. `true` means the app handles the window.
  @async
  bool? onCreateWindow(Map<String?, Object?> createWindowAction);

  /// `GeolocationPermissionShowPromptResponse.toMap()`.
  @async
  Map<String?, Object?>? onGeolocationPermissionsShowPrompt(String? origin);

  /// `PermissionResponse.toMap()`.
  @async
  Map<String?, Object?>? onPermissionRequest(
    String? origin,
    List<String?>? resources,
    Object? frame,
  );

  /// `navigationAction` is `NavigationAction.toMap()`; the answer a `NavigationActionPolicy` value.
  @async
  int? shouldOverrideUrlLoading(Map<String?, Object?> navigationAction);

  /// `challenge` is `HttpAuthenticationChallenge.toMap()`; the answer `HttpAuthResponse.toMap()`.
  @async
  Map<String?, Object?>? onReceivedHttpAuthRequest(
    Map<String?, Object?> challenge,
  );

  /// `challenge` is `ServerTrustChallenge.toMap()`; the answer `ServerTrustAuthResponse.toMap()`.
  @async
  Map<String?, Object?>? onReceivedServerTrustAuthRequest(
    Map<String?, Object?> challenge,
  );

  /// `challenge` is `ClientCertChallenge.toMap()`; the answer `ClientCertResponse.toMap()`.
  @async
  Map<String?, Object?>? onReceivedClientCertRequest(
    Map<String?, Object?> challenge,
  );

  /// `SafeBrowsingResponse.toMap()`.
  @async
  Map<String?, Object?>? onSafeBrowsingHit(String? url, int threatType);

  /// A `FormResubmissionAction` value.
  @async
  int? onFormResubmission(String? url);

  /// A `WebViewRenderProcessAction` value.
  @async
  int? onRenderProcessUnresponsive(String? url);

  /// A `WebViewRenderProcessAction` value.
  @async
  int? onRenderProcessResponsive(String? url);

  /// `data` is `JavaScriptHandlerFunctionData.toMap()`. The answer is the handler's result as JSON
  /// text, which Kotlin splices into the page's `resolve(…)`; null resolves with `null`.
  @async
  String? onCallJsHandler(String? handlerName, Map<String?, Object?> data);

  /// `true` means the app prints itself, so the plugin doesn't.
  @async
  bool? onPrintRequest(String? url);

  /// The visited URLs. Null keeps the platform default; an empty list says nothing was visited.
  @async
  List<String?>? onRequestVisitedHistory();

  /// `request` is `ShowFileChooserRequest.toMap()`; the answer `ShowFileChooserResponse.toMap()`.
  @async
  Map<String?, Object?>? onShowFileChooser(Map<String?, Object?> request);

  /// **Blocking**: Kotlin waits for this on a WebView worker thread, up to the WebView's
  /// `syncCallbackTimeoutMillis`. Null, a throw, no handler and a timeout all mean "load it
  /// normally".
  @async
  WebResourceResponseData? shouldInterceptRequest(
    WebResourceRequestData request,
  );

  /// **Blocking**, as [shouldInterceptRequest]. The answer is `CustomSchemeResponse.toMap()`.
  @async
  Map<String?, Object?>? onLoadResourceWithCustomScheme(
    WebResourceRequestData request,
  );
}

/// Mirrors the native `WebResourceRequestExt` field for field. Moved here from
/// `service_worker.dart` in W5 (§216): the service worker's intercept and the WebView's carry the
/// same request.
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

/// Mirrors the native `WebResourceResponseExt` field for field. Moved here with
/// [WebResourceRequestData].
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

// --- The service-worker channel (§186), moved from `service_worker.dart` in W5 ------------------
//
// 🚨 The first FlutterApi in this plugin that returned a value. `shouldInterceptRequest` runs on a
// Chromium worker thread and must return a `WebResourceResponse?` synchronously, so Kotlin blocks on
// a latch around the generated reply callback.
//
// §186's checklist, unchanged by the move:
//   1. Settings payload? **No.** The "settings" are the native `ServiceWorkerWebSettings`; every
//      argument is a primitive or `profileName`.
//   2. `@async`? No host method. The FlutterApi method is, Dart side only.
//   3. A branch that never answers? None among the host methods; every path out of the Kotlin wait
//      releases the latch.
//   4. Dart `int` -> Kotlin `Long`? `setCacheMode` narrows into `@CacheMode`, and a response's
//      `statusCode` into `WebResourceResponse`'s `int`.
//   5. Shared types: the two data classes above.
//   7. Per-instance? **No**: one process-wide controller and client, no suffix.
//   8. `shouldInterceptRequest` is a member of `ServiceWorkerClient`, not the controller; a private
//      forwarder is used anyway, because the client it forwards to is static.
//   9. Fields never read: none on the request; all seven read on the response.

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

// --- The custom `WebViewAssetLoader` path handler (§205), moved from `custom_path_handler.dart` --
//
// One event and no host methods: `WebViewAssetLoader` calls `PathHandlerExt.handle(path)` on a
// Chromium worker thread, so Kotlin **blocks** on the Dart answer (§186's shape), bounded by
// `Util.SYNC_CALLBACK_TIMEOUT_MILLIS` (a path handler holds no WebView settings). A timeout, a Dart
// throw, no Dart handler or a null answer all mean "not handled", so the request goes to the
// network. Per-instance: the suffix is the handler's id, Dart's `AndroidPathHandler._id`, read by
// `WebViewAssetLoaderExt.fromMap`; a mismatch is silent (the wait times out). The name `handle` is
// `PlatformPathHandlerEvents.handle`, so the Dart side forwards through a private class.
//
// **W5 types the answer** (§205 left it a map until the shared response type had a home):
// `WebResourceResponseData`, so `statusCode` no longer needs `normalizeCodecInts`. `cookies` still
// crosses and is still unused by `PathHandlerExt.handle`.

/// Implemented on the Dart side by a private forwarding class, one per path handler, suffixed by
/// its id.
@FlutterApi()
abstract class CustomPathHandlerFlutterApi {
  /// The response for [path], the part of the URL after the handler's prefix, with no query. Null
  /// means "not handled": the request goes to the network.
  @async
  WebResourceResponseData? handle(String path);
}
