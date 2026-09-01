## 7.0.0

The platform-interface half of a hard fork of 6.2.0-beta.3 / `1.4.0-beta.3`, **Android and iOS
only**. The `flutter_inappwebview` 7.0.0 entry carries the full user-facing list with every old → new
rename; this entry is the API-owner's view.

- Minimum Dart `^3.12.0`, minimum Flutter `>=3.44.0`
- **Every method/event channel name changed**: `com.pichillilorenzo/…` →
  **`dev.nosferatu500.inappwebview/…`**. Invisible through the public API, breaking for anything
  talking to the channels directly, and what lets this fork coexist with upstream
- **All 840 `@Deprecated` annotations are gone; 0 remain.** Every deprecated class, event, field,
  parameter and method upstream carried has been removed, including the whole `*Options` surface
  (18 classes, `initialOptions`, `getOptions`/`setOptions`), the 42 `Android*` / `IOS*` duplicate
  types, the 27 `androidOn*` / `iosOn*` event aliases, the `ios*` / `android*` field aliases, and
  `JavaScriptHandlerCallback`
- **All macOS / Windows / Linux / Web-only API is gone** — ~1950 annotation entries across 62 files,
  231 dropped-platform-only members, 81 files deleted

### Removed — Platform API

- `PlatformWebViewEnvironment` (+ `…CreationParams`) and `PlatformWebNotificationController`
  (+ `…CreationParams`, `WebNotificationCloseHandler`), and the
  `InAppWebViewPlatform.createPlatformWebViewEnvironment` /
  `createPlatformWebViewEnvironmentStatic` / `createPlatformWebNotificationController` factories
- `PlatformInAppWebViewController` (36 methods): the 25 dropped-platform ones
  (`addDevToolsProtocolEventListener`, `callDevToolsProtocolMethod`, `getFavicon`, `getFrameId`,
  `getIFrameId`, `getMemoryUsageTargetLevel`, `getScreenScale`, `getTargetRefreshRate`,
  `isInterfaceSupported`, `isMuted`, `isPlayingAudio`, `isVisible`, `openDevTools`,
  `removeDevToolsProtocolEventListener`, `requestEnterFullscreen`, `requestExitFullscreen`,
  `requestPointerLock`, `requestPointerUnlock`, `setMemoryUsageTargetLevel`, `setMuted`,
  `setScreenScale`, `setTargetRefreshRate`, `setVisible`, `showSaveAsUI`, `terminateWebProcess`)
  plus the 11 deprecated ones (`clearCache`, `clearMatches`, `findAllAsync`, `findNext`,
  `getOptions`, `getScale`, `getTRexRunnerCss`, `getTRexRunnerHtml`, `setOptions`,
  `setSafeBrowsingWhitelist`, `startSafeBrowsing`)
- `PlatformWebViewCreationParams`: 9 Windows-only events (`onAcceleratorKeyPressed`,
  `onContentLoading`, `onDOMContentLoaded`, `onLaunchingExternalUriScheme`,
  `onNotificationReceived`, `onProcessFailed`, `onSaveAsUIShowing`,
  `onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting`) and `initialOptions`
- `PlatformInAppBrowserEvents`: the same 9, `onMainWindowWillClose` (macOS) and the 17 deprecated
  aliases
- `webViewEnvironment` on `PlatformInAppWebViewWidgetCreationParams`,
  `PlatformHeadlessInAppWebViewCreationParams`, `PlatformInAppBrowserCreationParams` and
  `PlatformCookieManagerCreationParams`; `PlatformCookieManager.isPropertySupported` (its
  creation-params class has no properties left, so the generated property enum is gone too)
- `PlatformFindInteractionController.setFindOptions` (Windows) ·
  `PlatformPullToRefreshController.options` / `.setSize` / `.setAttributedTitle` ·
  `PlatformInAppBrowser.getOptions` / `.setOptions` / `.webViewEnvironment`
- `InAppWebViewSettings`: **60 properties** — the 54 dropped-platform ones plus `clearCache`,
  `clearSessionCache`, `forceDark`, `forceDarkStrategy`, `requestedWithHeaderOriginAllowList` and
  `saveFormData`
- `InAppBrowserSettings` (5, macOS), `PrintJobSettings` (41, macOS), `PrintJobAttributes`
  (17, macOS), and single fields on `PrintJobInfo`, `Printer`, `PDFConfiguration`, `WebHistoryItem`,
  `FrameInfo`, `ClientCertChallenge`, `ClientCertResponse`
- Enum constants: `PermissionResourceType` (9 — its Windows-only `UNKNOWN` went too, and came back
  as a platform-independent catch-all; see Fixed), `WebResourceErrorType` (17), `SslErrorType` (2),
  `LayoutAlgorithm.NARROW_COLUMNS`, and `WebViewFeature.FORCE_DARK` / `.FORCE_DARK_STRATEGY` /
  `.REQUESTED_WITH_HEADER_ALLOW_LIST` / `.SAFE_BROWSING_WHITELIST` / `.START_SAFE_BROWSING`
- Types removed with their features: `WebViewEnvironmentSettings`, `EnvironmentChannelSearchKind`,
  `EnvironmentReleaseChannels`, `EnvironmentScrollbarStyle`, `CustomSchemeRegistration`,
  `BrowserProcessExitedDetail`, `BrowserProcessInfo`, `BrowserProcessInfosChangedDetail`,
  `ProcessFailedDetail`, `ProcessFailedKind`, `ProcessFailedReason`, `FrameKind`, `CacheModel`,
  `WebNotification`, `NotificationReceivedRequest`, `NotificationReceivedResponse`,
  `DownloadStartResponse`, `DownloadStartResponseAction`, `PrintJobDisposition`,
  `PrintJobPageOrder`, `PrintJobPaginationMode`, `WindowType`, `WindowStyleMask`,
  `WindowTitlebarSeparatorStyle`
- **Changed signature**: `onDownloadStarting` returns `FutureOr<void>` instead of
  `FutureOr<DownloadStartResponse?>`. The event is Android + iOS and unaffected; neither native
  implementation ever read the return value
- **25 further types, removed with their last user** — the payload types of the nine removed
  Windows events (`AcceleratorKeyPressedDetail`, `LaunchingExternalUriSchemeRequest` / `…Response`,
  `SaveAsUIShowingRequest` / `…Response`, `SaveFileSecurityCheckStartingRequest` / `…Response`,
  `ScreenCaptureStartingRequest` / `…Response`) and the two types only they used
  (`PhysicalKeyStatus`, `SaveAsKind`); plus `BrowserProcessExitKind`, `BrowserProcessKind`,
  `FaviconImageFormat`, `FindOptions`, `FontHintingStyle`, `FontSubpixelLayout`,
  `MemoryUsageTargetLevel`, `PdfToolbarItems`, `PrintJobDialogKind`, `SaveAsUIResult`,
  `TextDirectionKind`, `WebResourceContext`, `WebResourceRequestSourceKind`, `WebViewInterface`.
  All 25 exports are gone from `src/types/main.dart`. **`ProxyRelayHop` was equally unreferenced and
  is kept**: it is `@SupportedPlatforms([IOSPlatform()])` and `ProxyManager.swift` reads it — the
  gap is that `ProxyRule` has no `relayHop1` / `relayHop2` field to carry it, and never has
- **`PlatformWebViewCreationParams.onPrintRequest`'s `printJobController` parameter**, and the same
  parameter on `PlatformInAppBrowserEvents.onPrintRequest`. The event is now asked *before* the
  print job is created — that is what lets a `true` return suppress the OS print dialog — so there
  is no `PlatformPrintJobController` in existence when it fires. Signatures become
  `FutureOr<bool?> Function(T controller, WebUri? url)` and
  `FutureOr<bool?>? onPrintRequest(WebUri? url)`. To obtain a controller, return `true` and call
  `PlatformInAppWebViewController.printCurrentPage(settings: PrintJobSettings(handledByClient:
  true))`. The event's `@SupportedPlatforms` loses its now-empty `parameterPlatforms` entry
- **`onFaviconChanged`, an event that can no longer fire on any supported platform.** Gone from
  `PlatformWebViewCreationParams` and `PlatformInAppBrowserEvents`, along with the
  `FaviconChangedRequest` type and its export from `src/types/main.dart`. It was
  `@SupportedPlatforms([AndroidPlatform(apiName: 'WebChromeClient.onReceivedIcon')])`, and that
  callback is no longer dispatched by a modern Android WebView — `WebIconDatabase`, which fed it, has
  been inert since API 19. Measured on API 33 and API 37: the icon really is downloaded (visible
  through `onLoadResource`) and the callback still never arrives, while `onReceivedTitle` from the
  same client works. Use `PlatformInAppWebViewController.getFavicons()` instead. Removing the event
  also drops it from `PlatformInAppWebViewController.debugLoggingSettings`' default `excludeFilter`,
  which now excludes only `onScrollChanged` and `onOverScrolled`

### Added

- **`ProxyRule.relayHop1` / `.relayHop2`** (iOS 17.0+), typed `ProxyRelayHop?`. This makes
  `ProxyRelayHop` reachable for the first time: the type was exported and iOS-annotated, and
  `ProxyManager.swift` has always read `map["relayHop1"]` / `map["relayHop2"]` and built
  `ProxyConfiguration(relayHops:)` from them — but `ProxyRule_` had no field of that type, so those
  keys were never sent and the Swift branch was unreachable. §77 nearly deleted `ProxyRelayHop` as
  dead before finding the native half complete and waiting. Setting a hop switches the rule to a
  relay chain (RFC 9298) instead of a direct proxy endpoint; `url` remains required and must still
  parse, because the Swift parses it in a guard *before* it looks at the hops
- **`InAppWebViewSettings.syncCallbackTimeoutMillis`** (Android). The bound on how long a WebView
  worker thread blocks waiting for a Dart answer to `shouldInterceptRequest` or
  `onLoadResourceWithCustomScheme`, which was a hardcoded 10s constant. Raise it for a handler that
  legitimately needs longer — one proxying the request through Dart HTTP over a slow link — knowing
  that every millisecond is a parked WebView thread. `0` or less is refused natively and the 10s
  default stands, so a mistaken `0` cannot silently turn interception into a no-op. It does **not**
  govern the two blocking waits that cannot read a WebView's settings: a custom `WebViewAssetLoader`
  `PathHandler.handle`, and `ServiceWorkerClient.shouldInterceptRequest` on the process-wide
  `ServiceWorkerController`
- `PlatformProfileStore` (+ `…CreationParams`) and `PlatformGeolocationPermissions`
  (+ `…CreationParams`), with `createPlatformProfileStore` / `…Static` and
  `createPlatformGeolocationPermissions` / `…Static` on `InAppWebViewPlatform`
- `PlatformInAppWebViewController`: `setAudioMuted`, `isAudioMuted`, `setDefaultTrafficStatsTag`,
  `prerenderUrl`, `postVisualStateCallback`, `documentHasImages`, `flingScroll`,
  `isBlockedByScreenTime`
- **`PlatformInAppWebViewController.isBlockedByScreenTime`** returns `Future<bool?>`, and the
  nullability is part of the contract rather than defensive: `null` means *the platform cannot
  answer* — every platform but iOS, and iOS below 26.0, where
  `WKWebView.isBlockedByScreenTime` does not exist. `false` means *asked, and not blocked*. There is
  no change event for it: WebKit does not document the property as KVO-compliant, so it is a getter
  a caller polls, and it describes the current *content* rather than the WebView
- `PlatformCookieManager`: `setAcceptCookie`, `isAcceptCookieEnabled`, `hasCookies`,
  `isFileSchemeCookiesAllowed`
- `PlatformWebStorageManager`: `deleteBrowsingData`, `deleteBrowsingDataForSite`
- `InAppWebViewSettings` (14): `attributionRegistrationBehavior`, `backForwardCacheEnabled`,
  `downloadFaviconsEnabled`, `lockdownModeEnabled`, `paymentRequestEnabled`,
  `preferredHTTPSNavigationPolicy`, `profileName`, `securityRestrictionMode`,
  `showsSystemScreenTimeBlockingView`, `supportsAdaptiveImageGlyph`, `userAgentMetadata`,
  `webAuthenticationSupport`, `webViewMediaIntegrityApiStatus`, `writingToolsBehavior`
- **`InAppWebViewSettings.showsSystemScreenTimeBlockingView`** (iOS 26.0+) defaults to `true`, not
  `null`, unlike most of the settings above it: WebKit documents its own default as `YES`, so the
  constructor mirrors that and the value always reaches the wire. It is a `WKWebViewConfiguration`
  property and therefore **creation-only** — `setSettings` cannot change it. Turning it off hides
  WebKit's blocking overlay without unblocking the content, so it belongs with a
  `PlatformInAppWebViewController.isBlockedByScreenTime` check
- `NavigationAction`: `modifierFlags`, `buttonNumber`, `isContentRuleListRedirect` ·
  `DownloadStartRequest`: `isUserInitiated`, `originatingFrame`
- `WebViewFeature` (13): `ATTRIBUTION_REGISTRATION_BEHAVIOR`, `BACK_FORWARD_CACHE`,
  `DEFAULT_TRAFFICSTATS_TAGGING`, `DELETE_BROWSING_DATA`, `DOWNLOAD_FAVICONS_ENABLED`,
  `MULTI_PROFILE`, `MUTE_AUDIO`, `PAYMENT_REQUEST`, `PRERENDER_WITH_URL`, `USER_AGENT_METADATA`,
  `USER_AGENT_METADATA_FORM_FACTORS`, `WEBVIEW_MEDIA_INTEGRITY_API_STATUS`, `WEB_AUTHENTICATION`
- New types: `AttributionRegistrationBehavior`, `ButtonMask`, `ModifierFlag`,
  `SecurityRestrictionMode`, `UpgradeToHTTPSPolicy`, `UserAgentMetadata`, `UserAgentBrandVersion`,
  `UserAgentFormFactor`, `WebAuthenticationSupport`, `WebViewMediaIntegrityApiStatus`,
  `WebViewMediaIntegrityApiStatusConfig`, `WebViewMediaIntegrityApiStatusOverrideRule`,
  `WritingToolsBehavior`, `JavaScriptHandlerFunction`

### Fixed

- **Documented two permanent iOS design decisions, so they stop reading as gaps.**
  `onDownloadStarting` is a **notification and nothing more**: Android never downloads the file
  (that is what `setDownloadListener` means), and iOS *actively cancels* the `WKDownload` by
  dropping its delegate — **unconditionally**, whether or not
  `InAppWebViewSettings.useOnDownloadStart` is set, so with that setting `false` a download is
  cancelled with no event at all. There is consequently no native progress/completion/failure to
  expose and none is planned; the app does its own downloading, carrying over cookies, `User-Agent`
  and auth headers itself. Separately, **the iOS JavaScript find implementation is permanent**:
  WebKit's `findString:withConfiguration:` returns a `WKFindResult` with exactly one property,
  `matchFound`, so it cannot supply `activeMatchOrdinal`, `numberOfMatches` or `isDoneCounting`, and
  it selects one match where `findAll` promises all of them highlighted. The native path is already
  used where a counting API exists (`UIFindInteraction`, iOS 16+)
- **Documented that `onReceivedClientCertRequest` can silently send no certificate.** Returning
  `ClientCertResponseAction.PROCEED` is a request, not a guarantee: if iOS cannot load the PKCS#12
  file it falls back to `performDefaultHandling` and the navigation continues **unauthenticated**,
  with no error, no exception and no change to the event's return value — the symptom is a
  `401`/`403` at `onReceivedHttpError`. A missing file and an unreadable file take the same branch.
  The note also records the **iOS 17.x limitation**: `SecPKCS12Import` there cannot read a container
  using `PBES2 / PBKDF2 / AES-256-CBC`, which is OpenSSL 3's *default* export format, and reports it
  as `errSecAuthFailed` — *"The user name or passphrase you entered is not correct"* — for a
  container whose passphrase is perfectly correct. The same file works on iOS 26. `ClientCertResponse
  .certificatePath` and `.certificatePassword` carry the short version, including the
  `openssl pkcs12 -info` command to tell the two causes apart
- **`WebsiteDataType.ALL` was missing four data types, so "clear everything" did not.** The set
  listed only the ten `WKWebsiteDataType*` constants that existed in iOS 9–11.3, while the iOS 26.5
  SDK declares fifteen. `WKWebsiteDataTypeFileSystem` (iOS 16+, the origin-private file system),
  `WKWebsiteDataTypeSearchFieldRecentSearches`, `WKWebsiteDataTypeMediaKeys` and
  `WKWebsiteDataTypeHashSalt` (all iOS 17+) are now constants and are in `ALL`, so
  `removeDataFor` / `removeDataModifiedSince` with `WebsiteDataType.ALL` really does clear them.
  Previously an app honouring a "delete my data" request left OPFS contents, DRM key storage,
  search history and the deviceId hash salt behind, with nothing in the API to indicate it
- **`WKWebsiteDataTypeScreenTime` (iOS 26+) is a new constant but is deliberately NOT in `ALL`.**
  Passing it to `removeDataModifiedSince` **terminates the app** on iOS 26.5 with an uncaught
  `NSGenericException` — *"Start date cannot be later in time than end date!"* — thrown inside
  WebKit's `ScreenTimeWebsiteDataSupport::removeScreenTimeDataWithInterval` while it builds an
  `NSDateInterval` from the `modifiedSince` value. No Dart `catch` and no plugin guard can contain
  an Objective-C exception raised there, so the only defence is to keep it out of the default set.
  `fetchDataRecords` with it is fine. Measured both ways on iOS 26.5 and pinned by an integration
  test; the constant's dartdoc carries the stack trace
- **`PlatformInAppBrowserEvents.onPrintRequest` documented the wrong platform APIs.** Its
  `@SupportedPlatforms` named `View.scrollBy` and `UIScrollView.setContentOffset` — copied from
  `onScrollChanged` — so the generated "Officially Supported Platforms" block in the published
  dartdoc pointed readers of a *print* event at the scrolling APIs. Now `PrintManager.print` and
  `UIPrintInteractionController.present`, matching
  `PlatformInAppWebViewController.printCurrentPage`. An unresolvable or wrong `apiName` is invisible
  to `flutter analyze`, so nothing flagged it
- **A DNS failure on iOS 26 threw inside the plugin.** `WebResourceErrorType` mapped only NSError
  -1003, iOS 26 reports -1006, and the generated `fromMap` force-unwrapped the lookup — so
  `onReceivedError` never reached app code. Both codes now resolve to `HOST_LOOKUP`, matching
  Android's single `ERROR_HOST_LOOKUP`
- **The code generator no longer emits a bare `!` on a non-nullable enum lookup** where the enum has
  a catch-all constant; it degrades to that constant instead. It also emitted code broken in both
  directions for `Map<String, SomeEnum>` fields. Both have regression tests
- **Reading `WebResourceErrorType.HOST_LOOKUP` threw on Android.** The generated
  `_alsoAcceptsNativeValues` closure — added so one constant can accept several inbound native codes
  — ended its fall-through branch with a bare `const []`, which infers `List<dynamic>`, while
  `_internalMultiPlatform` casts the result to `List<int?>`. Every platform taking that branch got
  `type 'List<dynamic>' is not a subtype of type 'List<int?>' in type cast` **from the constant's own
  initialiser**, so the crash landed wherever the constant was first touched. The generator now emits
  the type argument on both list literals. Regression test included, and it fails on the old output
- **`onFaviconChanged` is documented as not firing on modern Android WebView.** Its source,
  `WebChromeClient.onReceivedIcon`, was fed by the long-inert `WebIconDatabase`. Measured on API 33
  and 37 — on API 33 the WebView does fetch `favicon.ico` and the callback still never arrives, while
  `onReceivedTitle` from the same client works. `getFavicons()` is the working alternative
- **An unmapped permission resource killed `onPermissionRequest`.** `PermissionResourceType` had no
  catch-all left, so `PermissionRequest.fromMap` and `PermissionResponse.fromMap` force-unwrapped the
  lookup: one `PermissionRequest.RESOURCE_*` string (Android) or `WKMediaCaptureType` raw value (iOS)
  this enum does not know threw inside the channel handler, and the event never reached app code —
  a permission prompt that silently never appears. `PermissionResourceType.UNKNOWN` is back as the
  fallback, with a regression test that fails on the `!`
- Every mirrored `WebViewFeature` constant is pinned against the real `androidx.webkit` AAR by a
  test: six declared flags are `@Deprecated` tombstones that `isFeatureSupported` **throws** for,
  and five more have a native *value* that differs from their name
- `PlatformInAppWebViewWidgetCreationParams.preventGestureDelay` is documented under its own dartdoc
  template id again. It had inherited the deleted `webViewEnvironment` block's id, and its
  `{@macro …supported_platforms}` pointed at a template the generator no longer emits
- **`InAppWebViewSettings.allowingReadAccessTo` no longer claims to be a sandbox.** Its doc said to
  set it "to prevent WebView from reading any other content"; measured on iOS 17.5 and 26.5, a
  `file://` page loads a sibling directory's script even when the scope is narrowed to a directory
  that does not contain it. The plugin was verified to pass the right URL through to
  `WKWebView.loadFileURL(_:allowingReadAccessTo:)`, so this is WebKit's behaviour — but the promise
  was ours, and it is now a warning that this is **not a security boundary**
- **`PlatformHeadlessInAppWebView.setSize` / `getSize` document their unit: logical pixels**, the
  same unit as Flutter's `Size`, rather than the ambiguous "pixels". `getSize` states that it returns
  the size last requested — so the round-trip is exact — and that a `-1` axis resolves to the
  screen's own logical size. The Android note now explains the physical-pixel conversion (multiplied
  by the display density, rounded to the nearest `int` pixel) instead of saying only that `double`
  values become `int`
- **15 `InAppWebViewSettings` properties now say they are creation-only on iOS.** Their
  `IOSPlatform` notes state that changing them with `setSettings` on a running WebView has no
  effect, because `WKWebView.configuration` hands out a fresh copy on every access. Measured on iOS
  17.5 and 26.5 by setting each one and reading it back through `getSettings`, which re-reads the
  real configuration: `mediaPlaybackRequiresUserGesture`, `allowsInlineMediaPlayback`,
  `suppressesIncrementalRendering`, `selectionGranularity`, `ignoresViewportScaleLimits`,
  `dataDetectorTypes`, `allowsAirPlayForMediaPlayback`, `allowsPictureInPictureMediaPlayback`,
  `applicationNameForUserAgent`, `allowUniversalAccessFromFileURLs`,
  `limitsNavigationsToAppBoundDomains`, `upgradeKnownHostsToHTTPS`, `incognito`, `cacheEnabled`,
  `sharedCookiesEnabled`. Two carry the live alternative: `userAgent` for
  `applicationNameForUserAgent`, and `preferredHTTPSNavigationPolicy` for `upgradeKnownHostsToHTTPS`.
  The other iOS settings are unaffected: writes through `WKPreferences` and `WKWebpagePreferences`
  reach the live WebView, and eight of them were measured doing so in the same run
- **`getCertificate` documents what it actually reports on iOS.** WebKit has no equivalent API, so
  the plugin answers from the certificate it recorded during a server-trust challenge — and WebKit
  issues that challenge **once per host per process**. Measured: of three WebViews loading the same
  https URL in turn, only the first is challenged. So the value is process-wide, can predate the
  current page load and even the WebView asking for it, and is `null` until the process has been
  challenged for that host at least once
- `onLoadStop` now documents that it is **not** guaranteed after every navigation: a page that
  cancels its own load — single-page apps intercepting history changes, typically after `goBack` /
  `goForward` — ends in `onReceivedError` with `WebResourceErrorType.CANCELLED` and no `onLoadStop`
  at all, while the back-forward list still moves correctly. `onUpdateVisitedHistory` fires in both
  cases and is the signal to await
- **`HttpAuthenticationChallenge.previousFailureCount` now documents its scope and a platform
  divergence.** It is per WebView and per protection space, and resets when the page finishes or
  fails and when you answer `CANCEL`. **The first challenge reports `1` on Android and `0` on
  iOS** — Android counts the challenges, iOS forwards `URLAuthenticationChallenge`'s count — so
  code that gives up after N attempts must not test against a literal

### Internal

- Pigeon is wired up and the `find_interaction` channel is migrated end to end as a proof
  (`FindInteractionHostApi` / `FindInteractionFlutterApi`, `FindSessionData`); the other ~409
  messages still use `MethodChannel`
- 29 unit tests — this package shipped none before

## 1.4.0-beta.3

- Updated `flutter_inappwebview_internal_annotations` dependency from `^1.2.0` to `^1.3.0`
- Added `isClassSupported`, `isPropertySupported`, `isMethodSupported` static methods for all main classes, such as `PlatformInAppWebViewController`, `InAppWebViewSettings`, `PlatformInAppBrowser`, etc., in order to check if a class, property, or method is supported by the platform at runtime
- Added `isSupported` method to all custom enum classes
- Added `saveState`, `restoreState`, `requestEnterFullscreen`, `requestExitFullscreen`, `setVisible`, `setTargetRefreshRate`, `getTargetRefreshRate`, `requestPointerLock`, `requestPointerUnlock`, `getScreenScale`, `setScreenScale`, `isVisible`, `getFrameId`, `getFavicon`, `showSaveAsUI`, `getMemoryUsageTargetLevel`, `setMemoryUsageTargetLevel` methods to `PlatformInAppWebViewController` class
- Added `useOnAjaxReadyStateChange`, `useOnAjaxProgress`, `useOnShowFileChooser`, `corsAllowlist`, `itpEnabled`, `darkMode`, `disableAnimations`, `fontAntialias`, `fontHintingStyle`, `fontSubpixelLayout`, `fontDPI`, `cursorBlinkTime`, `doubleClickDistance`, `doubleClickTime`, `dragThreshold`, `keyRepeatDelay`, `keyRepeatInterval`, `disableWebSecurity`, `enableWebRTC`, `webRTCUdpPortsRange`, `javaScriptCanAccessClipboard`, `allowModalDialogs`, `enableMedia`, `enableEncryptedMedia`, `enableMediaCapabilities`, `enableMockCaptureDevices`, `mediaContentTypesRequiringHardwareSupport`, `enableJavaScriptMarkup`, `enable2DCanvasAcceleration`, `allowTopNavigationToDataUrls` properties to `InAppWebViewSettings`
- Added `onShowFileChooser`, `onContentLoading`, `onDOMContentLoaded`,  `onLaunchingExternalUriScheme`, `onFaviconChanged`, `onNotificationReceived`, `onSaveAsUIShowing`, `onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting` WebView events
- Added `PlatformWebNotificationController` class
- Update code documentation
- Deprecated `onReceivedIcon` in favor of `onFaviconChanged`

## 1.4.0-beta.2

- Updated `flutter_inappwebview_internal_annotations` dependency from `^1.1.1` to `^1.2.0`
- Updated `fromMap` static method and `toMap` method implementations
- Updated all WebView events with return type `Future` to type `FutureOr` in order to not force the usage of `async` keyword
- Added `byName`, `name`, `asNameMap` custom enum classes methods
- Added `statusBarEnabled`, `browserAcceleratorKeysEnabled`, `generalAutofillEnabled`, `passwordAutosaveEnabled`, `isPinchZoomEnabled`, `hiddenPdfToolbarItems`, `reputationCheckingRequired`, `nonClientRegionSupportEnabled`, `alpha`, `isUserInteractionEnabled`, `handleAcceleratorKeyPressed` properties to `InAppWebViewSettings`
- Added `isInterfaceSupported`, `getProcessInfos`, `getFailureReportFolderPath` methods to `PlatformWebViewEnvironment` class
- Added `isInterfaceSupported`, `setInputMethodEnabled`, `hideInputMethod`, `showInputMethod` methods to `PlatformInAppWebViewController` class
- Added `exclusiveUserDataFolderAccess`, `isCustomCrashReportingEnabled`, `enableTrackingPrevention`, `areBrowserExtensionsEnabled`, `channelSearchKind`, `releaseChannels`, `scrollbarStyle` properties to `WebViewEnvironmentSettings`
- Added `onDownloadStarting` WebView event and deprecated `onDownloadStartRequest` event
- Added `onNewBrowserVersionAvailable`, `onBrowserProcessExited`, `onProcessInfosChanged` events to `PlatformWebViewEnvironment` class
- Added `onAcceleratorKeyPressed` WebView event
- Fixed missing PrintJobOrientation android values

## 1.4.0-beta.1

- Updated static `fromMap` implementation for some classes
- Updated `kJavaScriptHandlerForbiddenNames` list
- Added `PlatformInAppLocalhostServer.onData` parameter to set a custom on data server callback
- Added `javaScriptBridgeEnabled`, `javaScriptBridgeOriginAllowList`, `javaScriptBridgeForMainFrameOnly`, `pluginScriptsOriginAllowList`, `pluginScriptsForMainFrameOnly`, `javaScriptHandlersOriginAllowList`, `javaScriptHandlersForMainFrameOnly`, `scrollMultiplier` InAppWebViewSettings parameters
- Added `setJavaScriptBridgeName`, `getJavaScriptBridgeName` static WebView controller methods
- Added `onProcessFailed` WebView event
- Added `regexToAllowSyncUrlLoading` Android-specific property to `InAppWebViewSettings`
- Added `JavaScriptHandlerFunctionData` type
- Deprecated `JavaScriptHandlerCallback` type in favor of `JavaScriptHandlerFunction` type
- Deprecated `InAppWebViewSettings.forceDark` and `InAppWebViewSettings.forceDarkStrategy` Android-only properties in favor of `InAppWebViewSettings.algorithmicDarkeningAllowed`
- Fixed X509Certificate PEM base64 decoding

## 1.3.0+1

- Fixed `X509Certificate.toMap` method

## 1.3.0

- Added `WebViewEnvironment.customSchemeRegistrations` parameter for Windows
- Added `CustomSchemeRegistration` type
- Updated docs

## 1.2.0

- Updated `Uint8List` conversion inside `fromMap` methods

## 1.1.1

- Updated permission models for Windows platform

## 1.1.0+1

- Updated docs and pubspec.yaml

## 1.1.0

- Added `PlatformWebViewEnvironment` class
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Removed unsupported feature `WebViewFeature.SUPPRESS_ERROR_PAGE`

## 1.0.10

- Merged "Added == operator and hashCode to WebUri" [#1941](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1941) (thanks to [daisukeueta](https://github.com/daisukeueta))

## 1.0.9

- Fix typos (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.8

- Added `PlatformCustomPathHandler` class to be able to implement custom path handlers for `WebViewAssetLoader`

## 1.0.7

- Added `InAppBrowser.onMainWindowWillClose` event
- Added `WindowType.WINDOW` for `InAppBrowserSettings.windowType`

## 1.0.6

- Added `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests` [#1905](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1905)
- Added `PlatformInAppWebViewController.clearFormData` method
- Added `PlatformCookieManager.removeSessionCookies` method
- Updated `InAppWebViewSettings.useShouldInterceptAjaxRequest` docs
- Updated `PlatformCookieManager` methods return value

## 1.0.5

- Must call super `dispose` method for `PlatformInAppBrowser` and `PlatformChromeSafariBrowser` 

## 1.0.4

- Expose missing `InAppBrowserSettings.menuButtonColor` option

## 1.0.3

- Expose missing old `AndroidInAppWebViewOptions` and `IOSInAppWebViewOptions` classes

## 1.0.2

- Added `PlatformPrintJobController.onComplete` setter

## 1.0.1

- Updated README 

## 1.0.0

Initial release.
