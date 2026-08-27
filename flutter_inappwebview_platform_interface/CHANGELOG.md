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

### Added

- `PlatformProfileStore` (+ `…CreationParams`) and `PlatformGeolocationPermissions`
  (+ `…CreationParams`), with `createPlatformProfileStore` / `…Static` and
  `createPlatformGeolocationPermissions` / `…Static` on `InAppWebViewPlatform`
- `PlatformInAppWebViewController`: `setAudioMuted`, `isAudioMuted`, `setDefaultTrafficStatsTag`,
  `prerenderUrl`, `postVisualStateCallback`, `documentHasImages`, `flingScroll`
- `PlatformCookieManager`: `setAcceptCookie`, `isAcceptCookieEnabled`, `hasCookies`,
  `isFileSchemeCookiesAllowed`
- `PlatformWebStorageManager`: `deleteBrowsingData`, `deleteBrowsingDataForSite`
- `InAppWebViewSettings` (13): `attributionRegistrationBehavior`, `backForwardCacheEnabled`,
  `downloadFaviconsEnabled`, `lockdownModeEnabled`, `paymentRequestEnabled`,
  `preferredHTTPSNavigationPolicy`, `profileName`, `securityRestrictionMode`,
  `supportsAdaptiveImageGlyph`, `userAgentMetadata`, `webAuthenticationSupport`,
  `webViewMediaIntegrityApiStatus`, `writingToolsBehavior`
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

- **A DNS failure on iOS 26 threw inside the plugin.** `WebResourceErrorType` mapped only NSError
  -1003, iOS 26 reports -1006, and the generated `fromMap` force-unwrapped the lookup — so
  `onReceivedError` never reached app code. Both codes now resolve to `HOST_LOOKUP`, matching
  Android's single `ERROR_HOST_LOOKUP`
- **The code generator no longer emits a bare `!` on a non-nullable enum lookup** where the enum has
  a catch-all constant; it degrades to that constant instead. It also emitted code broken in both
  directions for `Map<String, SomeEnum>` fields. Both have regression tests
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
- `onLoadStop` now documents that it is **not** guaranteed after every navigation: a page that
  cancels its own load — single-page apps intercepting history changes, typically after `goBack` /
  `goForward` — ends in `onReceivedError` with `WebResourceErrorType.CANCELLED` and no `onLoadStop`
  at all, while the back-forward list still moves correctly. `onUpdateVisitedHistory` fires in both
  cases and is the signal to await

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
