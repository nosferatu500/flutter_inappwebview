## 7.0.0

**A hard fork of `flutter_inappwebview` 6.2.0-beta.3, for Android and iOS only.** Everything below is
relative to 6.2.0-beta.3: 131 commits that dropped four platforms, rewrote the Android module in
Kotlin under a new namespace, moved the iOS module to Swift 6 language mode, removed **every**
deprecated API upstream carried (840 `@Deprecated` annotations in these packages — 1111 counting the
four platform packages that are also gone; **0 remain**), added 32 platform APIs, and fixed a list of
bugs that includes four on iOS which were silently swallowing events.

### Requirements — all breaking

| | 6.2.0-beta.3 | 7.0.0 |
|---|---|---|
| Flutter | `>=3.32.0` | **`>=3.44.0`** |
| Dart | `^3.8.0` | **`^3.12.0`** |
| Supported platforms | 6 | **2 — Android, iOS** |
| Android `minSdk` | 19 | **30** (Android 11) |
| **Android `compileSdk` your app must use** | (Flutter default) | **37** — `androidx.core` 1.19.0 requires it and AGP *fails* rather than warns |
| Android Gradle Plugin | 8 | **9** |
| Android implementation language | Java | **Kotlin** |
| iOS deployment target | 12.0 | **15.0** |
| iOS Swift language mode | 5.0 | **6.0** |
| **Xcode needed to build the iOS module** | 15 | **26** (Swift 6.2+) |

- **The Xcode 26 floor is the most disruptive item after `minSdk 30`, and it is not obvious from the
  version numbers.** It comes from `isolated deinit` (SE-0371), used at 32 sites so that
  `deinit { dispose() }` is legal under Swift 6. That language feature needs a Swift 6.2+ compiler.
  Flutter 3.44 itself only requires Xcode 15, so this plugin demands a newer toolchain than Flutter
  does: **a consumer on Xcode 16 cannot build it at all.** The iOS *deployment target* is unaffected
  and stays at 15.0.
- **`minSdk 30` is well above Flutter's own floor of 24** and forces every consuming app to raise its
  own `minSdk`. AGP rejects an app below its library's floor.
- **macOS, Windows, Linux and Web are gone.** The `flutter_inappwebview_macos`, `_windows`, `_linux`
  and `_web` packages no longer exist and are no longer resolved.
- **Swift Package Manager support** for the iOS module (it still builds under CocoaPods).

### BREAKING: the Android namespace and every method/event channel name changed

- Android namespace / Gradle `group`: `com.pichillilorenzo.flutter_inappwebview_android` →
  **`dev.nosferatu500.inappwebview`**
- Every method/event channel name: `com.pichillilorenzo/…` →
  **`dev.nosferatu500.inappwebview/…`**

This is invisible to anyone using the public Dart API, and it is what allows this fork to be
installed **alongside** upstream. It **breaks any app that talks to the plugin's platform channels
directly**.

- The Android FileProvider's `<provider>` block changed in all three of its parts, and apps declare
  that block themselves: `android:name` is now
  `dev.nosferatu500.inappwebview.InAppWebViewFileProvider`, the authority is
  `${applicationId}.dev.nosferatu500.inappwebview.fileprovider` (was
  `${applicationId}.flutter_inappwebview_android.fileprovider`), and the `meta-data` resource is
  `@xml/inappwebview_provider_paths` (`@xml/provider_paths` no longer exists here). The provider also
  no longer grants the entire external-storage root — see *Fixed*. **A stale authority fails
  silently**: `<input type="file" capture>` produces nothing, with no Dart error, because
  `getUriForFile`'s exception is caught and logged natively.

### Removed — the deprecated API, all of it

Upstream shipped 1111 `@Deprecated` annotations; none is left. Nothing below has a runtime
replacement that did not already exist in 6.x, so every migration is a rename.

**The whole `*Options` API** — use the matching `*Settings` class and `initialSettings` /
`getSettings` / `setSettings`:

`InAppWebViewOptions`, `InAppWebViewGroupOptions`, `AndroidInAppWebViewOptions`,
`IOSInAppWebViewOptions` → `InAppWebViewSettings` · `InAppBrowserOptions`,
`InAppBrowserClassOptions`, `AndroidInAppBrowserOptions`, `IOSInAppBrowserOptions` →
`InAppBrowserClassSettings` / `InAppBrowserSettings` · `ChromeSafariBrowserOptions`,
`ChromeSafariBrowserClassOptions`, `AndroidChromeCustomTabsOptions`, `IOSSafariOptions` →
`ChromeSafariBrowserSettings` · `ContextMenuOptions` → `ContextMenuSettings` ·
`PullToRefreshOptions` → `PullToRefreshSettings` · and the `WebViewOptions`, `BrowserOptions`,
`AndroidOptions`, `IosOptions` marker interfaces. Also removed: the `initialOptions` parameter,
`getOptions()` / `setOptions()` on `InAppWebViewController` and `InAppBrowser`,
`ContextMenu.options` and `PullToRefreshController.options`.

**The `Android*` / `IOS*` duplicate types** — use the unprefixed type:

`AndroidActionModeMenuItem` → `ActionModeMenuItem` · `AndroidCacheMode` → `CacheMode` ·
`AndroidLayoutAlgorithm` → `LayoutAlgorithm` · `AndroidLayoutInDisplayCutoutMode` →
`LayoutInDisplayCutoutMode` · `AndroidMixedContentMode` → `MixedContentMode` ·
`AndroidOverScrollMode` → `OverScrollMode` · `AndroidPullToRefreshSize` → `PullToRefreshSize` ·
`AndroidScrollBarStyle` → `ScrollBarStyle` · `AndroidVerticalScrollbarPosition` →
`VerticalScrollbarPosition` · `AndroidWebStorageOrigin` → `WebStorageOrigin` ·
`AndroidWebViewPackageInfo` → `WebViewPackageInfo` · `AndroidServiceWorkerClient` →
`ServiceWorkerClient` · `AndroidWebViewFeature` → `WebViewFeature` · `AndroidSslError` /
`IOSSslError` → `SslErrorType` · `IOSNSAttributedString` → `AttributedString` ·
`IOSNSAttributedStringTextEffectStyle` → `AttributedStringTextEffectStyle` · `IOSNSUnderlineStyle` →
`UnderlineStyle` · `IOSNSURLProtectionSpaceAuthenticationMethod` →
`URLProtectionSpaceAuthenticationMethod` · `IOSNSURLProtectionSpaceProxyType` →
`URLProtectionSpaceProxyType` · `IOSNavigationResponseAction` → `NavigationResponseAction` ·
`IOSSafariDismissButtonStyle` → `DismissButtonStyle` · `IOSShouldAllowDeprecatedTLSAction` →
`ShouldAllowDeprecatedTLSAction` · `IOSUIModalPresentationStyle` → `ModalPresentationStyle` ·
`IOSUIModalTransitionStyle` → `ModalTransitionStyle` ·
`IOSUIScrollViewContentInsetAdjustmentBehavior` → `ScrollViewContentInsetAdjustmentBehavior` ·
`IOSUIScrollViewDecelerationRate` → `ScrollViewDecelerationRate` · `IOSURLCredentialPersistence` →
`URLCredentialPersistence` · `IOSURLRequestCachePolicy` → `URLRequestCachePolicy` ·
`IOSURLRequestNetworkServiceType` → `URLRequestNetworkServiceType` · `IOSURLResponse` →
`URLResponse` · `IOSWKDataDetectorTypes` → `DataDetectorTypes` · `IOSWKFrameInfo` → `FrameInfo` ·
`IOSWKNavigationResponse` → `NavigationResponse` · `IOSWKNavigationType` → `NavigationType` ·
`IOSWKPDFConfiguration` → `PDFConfiguration` · `IOSWKSecurityOrigin` → `SecurityOrigin` ·
`IOSWKSelectionGranularity` → `SelectionGranularity` · `IOSWKWebsiteDataRecord` →
`WebsiteDataRecord` · `IOSWKWebsiteDataType` → `WebsiteDataType` · `IOSWKWindowFeatures` →
`WindowFeatures` · `PermissionRequestResponse` → `PermissionResponse` ·
`PermissionRequestResponseAction` → `PermissionResponseAction` · `JavaScriptHandlerCallback` →
`JavaScriptHandlerFunction`

Together with the deprecated `.android` / `.ios` accessors and the shim classes behind them:
`InAppWebViewController.android` / `.ios`, `CookieManager.ios`, `WebStorageManager.android` /
`.ios`, and `AndroidServiceWorkerController` / `AndroidServiceWorkerClient`.

**Event aliases** — use the unprefixed event:

`androidOnFormResubmission`, `androidOnGeolocationPermissionsHidePrompt`,
`androidOnGeolocationPermissionsShowPrompt`, `androidOnJsBeforeUnload`,
`androidOnPermissionRequest`, `androidOnReceivedIcon`, `androidOnReceivedLoginRequest`,
`androidOnReceivedTouchIconUrl`, `androidOnRenderProcessGone`, `androidOnRenderProcessResponsive`,
`androidOnRenderProcessUnresponsive`, `androidOnSafeBrowsingHit`, `androidShouldInterceptRequest`,
`iosOnDidReceiveServerRedirectForProvisionalNavigation`, `iosOnNavigationResponse`,
`iosOnWebContentProcessDidTerminate`, `iosShouldAllowDeprecatedTLS`. Plus the renamed events:
`androidOnScaleChanged` → `onZoomScaleChanged` · `onLoadError` → `onReceivedError` ·
`onLoadHttpError` → `onReceivedHttpError` · `onDownloadStart` / `onDownloadStartRequest` →
`onDownloadStarting` · `onLoadResourceCustomScheme` → `onLoadResourceWithCustomScheme` · `onPrint` →
`onPrintRequest` · `onReceivedIcon` → `onFaviconChanged` · `onFindResultReceived` →
`FindInteractionController.onFindResultReceived`

**Field / parameter aliases** — use the unprefixed field:

`URLRequest.iosAllowsCellularAccess`, `.iosAllowsConstrainedNetworkAccess`,
`.iosAllowsExpensiveNetworkAccess`, `.iosCachePolicy`, `.iosHttpShouldHandleCookies`,
`.iosHttpShouldUsePipelining`, `.iosMainDocumentURL`, `.iosNetworkServiceType`,
`.iosTimeoutInterval` · `NavigationAction.androidHasGesture`, `.androidIsRedirect`,
`.iosSourceFrame`, `.iosTargetFrame`, `.iosWKNavigationType` ·
`CreateWindowAction.androidIsDialog`, `.iosWindowFeatures` ·
`URLProtectionSpace.iosAuthenticationMethod`, `.iosDistinguishedNames`, `.iosProxyType`,
`.iosReceivesCredentialSecurely` · `URLCredential.iosCertificates`, `.iosPersistence` ·
`ClientCertChallenge.androidKeyTypes`, `.androidPrincipals` · `ClientCertResponse.androidKeyStoreType` ·
`HttpAuthenticationChallenge.iosError`, `.iosFailureResponse` ·
`JsAlertRequest.iosIsMainFrame`, `JsConfirmRequest.iosIsMainFrame`, `JsPromptRequest.iosIsMainFrame` ·
`ScreenshotConfiguration.iosAfterScreenUpdates` · `UserScript.iosForMainFrameOnly` ·
`InAppWebViewInitialData.androidHistoryUrl` · `ContextMenuItem.androidId` / `.iosId` ·
`SslError.androidError` / `.iosError` ·
`TrustedWebActivityImmersiveDisplayMode.layoutInDisplayCutoutMode` · and on the controller methods
themselves, the `iosWKPdfConfiguration` → `pdfConfiguration`, `iosAnimated` → `animated` and
`iosAllowingReadAccessTo` → `allowingReadAccessTo` parameters

**Methods** — use the replacement:

`InAppWebViewController.findAllAsync` / `.findNext` / `.clearMatches` →
`FindInteractionController.findAll` / `.findNext` / `.clearMatches` · `.clearCache()` →
`.clearAllCache()` · `.getScale()` → `.getZoomScale()` · `.setSafeBrowsingWhitelist()` →
`.setSafeBrowsingAllowlist()` · `.getTRexRunnerHtml()` / `.getTRexRunnerCss()` → the `tRexRunnerHtml`
/ `tRexRunnerCss` getters · `PullToRefreshController.setSize()` → `.setIndicatorSize()` ·
`.setAttributedTitle()` → `.setStyledTitle()`

**Settings fields and feature flags, removed outright** — these were no-ops or dead capabilities on
every supported platform, not renames:

- `InAppWebViewSettings.saveFormData` — provably a no-op at `minSdk 30`
- `InAppWebViewSettings.forceDark` / `.forceDarkStrategy` (+ the `ForceDark`, `AndroidForceDark`
  and `ForceDarkStrategy` enums and `WebViewFeature.FORCE_DARK` / `.FORCE_DARK_STRATEGY`) — use
  `algorithmicDarkeningAllowed`; a no-op at `targetSdk >= 33`
- `InAppWebViewSettings.requestedWithHeaderOriginAllowList` (+
  `WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST`) — androidx **cancelled** the header removal the
  allow-list existed for, so it does nothing
- `InAppWebViewSettings.clearCache` / `.clearSessionCache` — use
  `InAppWebViewController.clearAllCache()`
- `LayoutAlgorithm.NARROW_COLUMNS` — surveying found it was **never settable** (a `switch` with no
  `break`s); the fall-through was fixed at the same time
- `WebViewFeature.SAFE_BROWSING_WHITELIST` → `SAFE_BROWSING_ALLOWLIST`;
  `WebViewFeature.START_SAFE_BROWSING` and `InAppWebViewController.startSafeBrowsing()` — a real
  capability drop: androidx deprecated it and the fallback branch went with it

### Removed — the macOS / Windows / Linux / Web API

Everything in this section existed *solely* to serve a dropped platform: on Android and iOS it threw
`UnimplementedError`, was ignored, or could never be produced. **No behaviour changed on Android or
iOS.**

**Types** — WebView2 / WPE environment (Windows, Linux): `WebViewEnvironment`,
`PlatformWebViewEnvironment`, `WebViewEnvironmentSettings`, `EnvironmentChannelSearchKind`,
`EnvironmentReleaseChannels`, `EnvironmentScrollbarStyle`, `CustomSchemeRegistration`,
`BrowserProcessExitedDetail`, `BrowserProcessInfo`, `BrowserProcessInfosChangedDetail`,
`ProcessFailedDetail`, `ProcessFailedKind`, `ProcessFailedReason`, `FrameKind`, `CacheModel` ·
WebView2 notifications (Windows): `WebNotificationController`,
`PlatformWebNotificationController`, `WebNotification`, `NotificationReceivedRequest`,
`NotificationReceivedResponse`, `WebNotificationCloseHandler` · download policy (Windows, Linux):
`DownloadStartResponse`, `DownloadStartResponseAction` · printing (macOS): `PrintJobDisposition`,
`PrintJobPageOrder`, `PrintJobPaginationMode` · browser window (macOS, Windows): `WindowType`,
`WindowStyleMask`, `WindowTitlebarSeparatorStyle`

**Events** (Windows-only): `onAcceleratorKeyPressed`, `onContentLoading`, `onDOMContentLoaded`,
`onLaunchingExternalUriScheme`, `onNotificationReceived`, `onProcessFailed`, `onSaveAsUIShowing`,
`onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting`; and `InAppBrowser.onMainWindowWillClose`
(macOS)

**`InAppWebViewController` methods** (25): `addDevToolsProtocolEventListener`,
`callDevToolsProtocolMethod`, `getFavicon`, `getFrameId`, `getIFrameId`,
`getMemoryUsageTargetLevel`, `getScreenScale`, `getTargetRefreshRate`, `isInterfaceSupported`,
`isMuted`, `isPlayingAudio`, `isVisible`, `openDevTools`, `removeDevToolsProtocolEventListener`,
`requestEnterFullscreen`, `requestExitFullscreen`, `requestPointerLock`, `requestPointerUnlock`,
`setMemoryUsageTargetLevel`, `setMuted`, `setScreenScale`, `setTargetRefreshRate`, `setVisible`,
`showSaveAsUI`, `terminateWebProcess`. **`getFavicons` is not affected**

**`InAppWebViewSettings` properties** (54): `allowModalDialogs`, `allowTopNavigationToDataUrls`,
`browserAcceleratorKeysEnabled`, `corsAllowlist`, `cursorBlinkTime`, `darkMode`,
`disableAnimations`, `disableWebSecurity`, `doubleClickDistance`, `doubleClickTime`,
`dragThreshold`, `drawCompositingIndicators`, `enable2DCanvasAcceleration`, `enableCaretBrowsing`,
`enableEncryptedMedia`, `enableJavaScriptMarkup`, `enableMedia`, `enableMediaCapabilities`,
`enableMockCaptureDevices`, `enablePageCache`, `enableResizableTextAreas`, `enableSmoothScrolling`,
`enableSpatialNavigation`, `enableTabsToLinks`, `enableWebRTC`,
`enableWriteConsoleMessagesToStdout`, `fontAntialias`, `fontDPI`, `fontHintingStyle`,
`fontSubpixelLayout`, `generalAutofillEnabled`, `handleAcceleratorKeyPressed`,
`hiddenPdfToolbarItems`, `iframeAllow`, `iframeAllowFullscreen`, `iframeAriaHidden`, `iframeCsp`,
`iframeName`, `iframeReferrerPolicy`, `iframeRole`, `iframeSandbox`, `itpEnabled`,
`javaScriptCanAccessClipboard`, `keyRepeatDelay`, `keyRepeatInterval`,
`mediaContentTypesRequiringHardwareSupport`, `nonClientRegionSupportEnabled`,
`passwordAutosaveEnabled`, `pictographFontFamily`, `pinchZoomEnabled`, `reputationCheckingRequired`,
`scrollMultiplier`, `statusBarEnabled`, `webRTCUdpPortsRange`

**`InAppBrowserSettings` properties** (macOS, 5): `windowAlphaValue`, `windowFrame`,
`windowStyleMask`, `windowTitlebarSeparatorStyle`, `windowType`

**`PrintJobSettings` properties** (macOS, 41): `canSpawnSeparateThread`, `collate`, `copies`,
`detailedErrorReporting`, `faxNumber`, `firstPage`, `footerUri`, `headerAndFooter`, `headerTitle`,
`horizontalPagination`, `isHorizontallyCentered`, `isVerticallyCentered`, `jobDisposition`,
`jobSavingURL`, `lastPage`, `mustCollate`, `pageHeight`, `pageOrder`, `pageRanges`, `pageWidth`,
`pagesAcross`, `pagesDown`, `pagesPerSide`, `paperName`, `printDialogKind`, `printerName`,
`scalingFactor`, `shouldPrintBackgrounds`, `shouldPrintHeaderAndFooter`, `shouldPrintSelectionOnly`,
`showUI`, `showsPageRange`, `showsPageSetupAccessory`, `showsPaperSize`, `showsPreview`,
`showsPrintPanel`, `showsPrintSelection`, `showsProgressPanel`, `showsScaling`, `time`,
`verticalPagination`

**`PrintJobAttributes` properties** (macOS, 17): `detailedErrorReporting`, `faxNumber`,
`headerAndFooter`, `horizontalPagination`, `isHorizontallyCentered`, `isSelectionOnly`,
`isVerticallyCentered`, `jobDisposition`, `jobSavingURL`, `localizedPaperName`, `mustCollate`,
`pagesAcross`, `pagesDown`, `paperName`, `scalingFactor`, `time`, `verticalPagination`

**Single fields** — `PrintJobInfo.pageOrder`, `Printer.name` / `.type` / `.languageLevel`,
`PDFConfiguration.settings`

**Enum constants** — `PermissionResourceType` (Windows, 9): `AUTOPLAY`, `CLIPBOARD_READ`,
`FILE_READ_WRITE`, `GEOLOCATION`, `LOCAL_FONTS`, `MULTIPLE_AUTOMATIC_DOWNLOADS`, `NOTIFICATIONS`,
`OTHER_SENSORS`, `WINDOW_MANAGEMENT`. Its Windows-only `UNKNOWN` went with them and **came back**
as a platform-independent catch-all — see Fixed · `WebResourceErrorType` (Windows 6, Linux 11):
`CANNOT_SHOW_MIME_TYPE`, `CANNOT_SHOW_URI`, `CANNOT_USE_RESTRICTED_PORT`, `CONNECTION_ABORTED`,
`DOWNLOAD_CANCELLED_BY_USER`, `DOWNLOAD_DESTINATION_FAILED`, `DOWNLOAD_NETWORK_FAILED`,
`FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE`, `POLICY_FAILED`, `REDIRECT_FAILED`, `RESET`,
`SERVER_CERTIFICATE_BAD_IDENTITY`, `SERVER_CERTIFICATE_REVOKED`, `SERVER_UNREACHABLE`,
`TLS_CERTIFICATE_GENERIC_ERROR`, `UNEXPECTED_ERROR`, `VALID_PROXY_AUTHENTICATION_REQUIRED` ·
`SslErrorType` (Windows, 2): `COMMON_NAME_IS_INCORRECT`, `REVOKED`

**Other members** — the `webViewEnvironment` parameter of `InAppWebView`, `HeadlessInAppWebView`,
`InAppBrowser` and `CookieManager.instance()` · `CookieManager.isPropertySupported` ·
`FindInteractionController.setFindOptions` (Windows) · `WebHistoryItem.entryId` (Windows) ·
`FrameInfo.frameId` / `.kind` / `.name` (Windows) ·
`ClientCertChallenge.allowedCertificateAuthorities` / `.isProxy` / `.mutuallyTrustedCertificates`,
`ClientCertResponse.selectedCertificate`

**Changed signature** — `onDownloadStarting` now returns `FutureOr<void>` instead of
`FutureOr<DownloadStartResponse?>`. The event is Android + iOS and still fires; only its
Windows-only response type is gone, and neither native implementation ever read the returned value.
Existing handlers keep compiling.

**Also removed — seven event parameters that outlived their events.** The nine Windows events above
left `PlatformWebViewCreationParams`, but seven of them stayed on as constructor parameters of
`InAppWebView` and `HeadlessInAppWebView`, with nowhere left to forward them to: a caller passing
`onSaveAsUIShowing:` compiled and was **silently ignored**. They are gone from both widgets —
`onAcceleratorKeyPressed`, `onContentLoading`, `onDOMContentLoaded`, `onLaunchingExternalUriScheme`,
`onSaveAsUIShowing`, `onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting` — so passing one is
now a compile error instead of a no-op.

**Also removed — 25 types with no remaining user.** Their payload types
(`AcceleratorKeyPressedDetail`, `LaunchingExternalUriSchemeRequest` / `…Response`,
`SaveAsUIShowingRequest` / `…Response`, `SaveFileSecurityCheckStartingRequest` / `…Response`,
`ScreenCaptureStartingRequest` / `…Response`) and, with those, `PhysicalKeyStatus` (a Win32 LPARAM)
and `SaveAsKind` · plus 14 whose last user left with the dropped-platform members:
`BrowserProcessExitKind`, `BrowserProcessKind`, `FaviconImageFormat`, `FindOptions`,
`FontHintingStyle`, `FontSubpixelLayout`, `MemoryUsageTargetLevel`, `PdfToolbarItems`,
`PrintJobDialogKind`, `SaveAsUIResult`, `TextDirectionKind`, `WebResourceContext`,
`WebResourceRequestSourceKind`, `WebViewInterface`. `BrowserProcessExitKind` and
`BrowserProcessKind` had already lost every constant and were empty shells. **`ProxyRelayHop` was
in the same "zero references" list and is deliberately kept** — it is iOS API that the Swift side
reads, and it is unreachable only because `ProxyRule` has never carried `relayHop1` / `relayHop2`.

### Changed — `onPrintRequest` is now asked *before* the print job starts, and can suppress it

**BREAKING, on both platforms.** Returning `true` from `onPrintRequest` now means the OS print
dialog is **never raised**. It previously meant only "I will own the `PrintJobController`" — both
natives called `printCurrentPage()` *first* and asked Dart afterwards, so the dialog was already up
whatever you returned, and the return value merely decided who disposed the tracking object.

That made the return value unable to do the one thing its name implies. It is also unrecoverable:
nothing in this plugin can dismiss a dialog once it is up — on Android `PrintJob.cancel()` is a
no-op while the job is in `CREATED` state, which is exactly the state it is in while the dialog is
open. Asking Dart first is the only point at which printing can be declined.

**The third parameter is gone.** The signature is now
`FutureOr<bool?> Function(InAppWebViewController controller, WebUri? url)` — there is no print job
when the event fires, so there was no `PrintJobController` left to pass and it would have been
permanently `null`. `InAppBrowser.onPrintRequest(WebUri? url)` loses it too.

**Migration.** Handlers that ignored the third parameter only need it deleted from their signature:

```dart
// before
onPrintRequest: (controller, url, printJobController) async => false,
// after
onPrintRequest: (controller, url) async => false,
```

Handlers that *used* the controller should return `true` and start the job themselves — this also
gives you a job you actually control, instead of one that was already running:

```dart
onPrintRequest: (controller, url) async {
  final printJob = await controller.printCurrentPage(
    settings: PrintJobSettings(handledByClient: true),
  );
  // ... printJob.dispose() when done
  return true;
}
```

Returning `false`, returning `null`, and registering no handler at all are unchanged: the page is
printed and the platform's print dialog appears. `InAppWebViewController.printCurrentPage()` is also
unchanged — it is an explicit request to print, so it always raises the dialog.

Verified on device, both directions: on Android 17 / API 37 and Android 13 / API 33, returning `true`
leaves no `com.android.printspooler` process at all, while returning `false` — and registering no
handler — spawns it. iOS 26.5 and 17.5 pass the same test.

### Removed — `onFaviconChanged`, an event that can no longer fire

**BREAKING.** `onFaviconChanged` and its `FaviconChangedRequest` payload are removed from
`InAppWebView`, `HeadlessInAppWebView` and `InAppBrowser`. It was Android-only, and on a modern
Android WebView the framework callback behind it — `WebChromeClient.onReceivedIcon` — is no longer
dispatched, because the `WebIconDatabase` that fed it has been inert since API 19.

Measured on API 33 and API 37, each step ruling out the previous explanation: on API 37
`WebViewFeature.DOWNLOAD_FAVICONS_ENABLED` is not even supported; on API 33 it *is* supported,
`downloadFaviconsEnabled: true` reads back `true`, and the WebView genuinely fetches `favicon.ico`
(visible through `onLoadResource`) — and `onReceivedIcon` still never arrives. `onReceivedTitle` from
the same `WebChromeClient` works throughout, so the client is installed and this is not a wiring
problem. The event was already unsupported on iOS, so it fired on no supported platform.

**Migration:** use `InAppWebViewController.getFavicons()`, which parses the document's own
`<link rel="icon">` tags and works on both platforms. Note that it is a pull, not an event — call it
from `onLoadStop` rather than waiting to be told.

`InAppWebViewSettings.downloadFaviconsEnabled` is **kept**: it still controls whether the WebView
issues the favicon request at all, which is a real per-page network cost. Its documentation no longer
claims to gate an event.

### Added — Android

Twelve `androidx.webkit` features, each behind its own `WebViewFeature` flag, plus eight
`android.webkit` APIs the plugin had never exposed. Every one is Android-only and reports "not
implemented on the current platform" on iOS.

- **`WebViewFeature.MUTE_AUDIO`** — `InAppWebViewController.setAudioMuted()` / `.isAudioMuted()`
- **`WebViewFeature.PAYMENT_REQUEST`** — `InAppWebViewSettings.paymentRequestEnabled`
  (closes upstream #2660, supersedes #2722)
- **`WebViewFeature.WEB_AUTHENTICATION`** — passkeys, via
  `InAppWebViewSettings.webAuthenticationSupport` + the `WebAuthenticationSupport` enum
  (what upstream #2743 wanted)
- **`WebViewFeature.DOWNLOAD_FAVICONS_ENABLED`** — `InAppWebViewSettings.downloadFaviconsEnabled`,
  which also gates the existing `onReceivedIcon`
- **`WebViewFeature.BACK_FORWARD_CACHE`** — `InAppWebViewSettings.backForwardCacheEnabled`
- **`WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR`** —
  `InAppWebViewSettings.attributionRegistrationBehavior` + the `AttributionRegistrationBehavior` enum
- **`WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS`** —
  `InAppWebViewSettings.webViewMediaIntegrityApiStatus` with per-origin overrides
  (`WebViewMediaIntegrityApiStatusConfig`, `…OverrideRule`, `WebViewMediaIntegrityApiStatus`)
- **`WebViewFeature.USER_AGENT_METADATA`** (+ `…_FORM_FACTORS`) — User-Agent Client Hints, via
  `InAppWebViewSettings.userAgentMetadata`, `UserAgentMetadata`, `UserAgentBrandVersion`,
  `UserAgentFormFactor`
- **`WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING`** —
  `InAppWebViewController.setDefaultTrafficStatsTag()`
- **`WebViewFeature.DELETE_BROWSING_DATA`** — `WebStorageManager.deleteBrowsingData()` /
  `.deleteBrowsingDataForSite()`
- **`WebViewFeature.MULTI_PROFILE`** — a whole new `ProfileStore` controller surface plus
  `InAppWebViewSettings.profileName`, and the plugin's own storage APIs are now profile-aware:
  cookies, web storage, service-worker settings and geolocation all act on the profile the WebView
  is actually using. `setServiceWorkerClient` remains default-profile only
- **`WebViewFeature.PRERENDER_WITH_URL`** — `InAppWebViewController.prerenderUrl(WebUri)`
- **`GeolocationPermissions`** — a new controller surface (`allow`, `clear`, `clearAll`,
  `getAllowed`, `getOrigins`), profile-aware from the start
- **`CookieManager`** — `setAcceptCookie()`, `isAcceptCookieEnabled()`, `hasCookies()`,
  `isFileSchemeCookiesAllowed()`
- **`InAppWebViewController`** — `postVisualStateCallback()`, `documentHasImages()`,
  `flingScroll()`
- **`InAppWebViewSettings.syncCallbackTimeoutMillis`** — how long the WebView waits for your Dart
  handler to answer `shouldInterceptRequest` or `onLoadResourceWithCustomScheme` before loading the
  resource anyway. This was a fixed 10 seconds; a handler that proxies the request through Dart HTTP
  over a slow link can now be given longer, at the cost of a WebView thread parked for that long.
  `0` or less keeps the 10s default, so a mistaken `0` cannot switch interception off

### Added — iOS

Fourteen WebKit APIs read out of the iOS 26.5 SDK, plus one feature that was half-built upstream.

- **`ProxyRule.relayHop1` / `.relayHop2`** (iOS 17.0+) — route a proxy rule through a chain of
  secure relays (RFC 9298) instead of connecting to the proxy endpoint directly. `ProxyRelayHop`
  was already a public, exported type and the Swift already read these two map keys, but no Dart
  field ever produced them, so the feature was unreachable from the moment it was written. With a
  hop set, the configuration is built from the chain rather than from `url` — `url` is still
  required and must still parse, because the native parses it before it reads the hops. Two hops
  mean the first relay cannot see the destination and the second cannot see the client
- **`NavigationAction.modifierFlags` / `.buttonNumber`** (+ the `ModifierFlag` and `ButtonMask`
  enums) — which keys and mouse button triggered a navigation
- **`NavigationAction.isContentRuleListRedirect`** — whether a content rule list redirected it
- **`onShowFileChooser` now fires on iOS** (18.4+), gated on
  `InAppWebViewSettings.useOnShowFileChooser` — the iOS half of upstream #2146
- **`InAppWebViewSettings.writingToolsBehavior`** (+ `WritingToolsBehavior`)
- **`InAppWebViewSettings.preferredHTTPSNavigationPolicy`** (+ `UpgradeToHTTPSPolicy`) — applied to
  the *live* per-navigation preferences, so it responds to `setSettings`
- **`InAppWebViewSettings.securityRestrictionMode`** (+ `SecurityRestrictionMode`)
- **`InAppWebViewSettings.lockdownModeEnabled`**
- **`InAppWebViewSettings.supportsAdaptiveImageGlyph`**
- **`InAppWebViewController.isBlockedByScreenTime()`** (iOS 26.0+) — whether Screen Time
  restrictions are blocking this WebView's current content. Returns `bool?`, and the `null` is load
  bearing: it means *this OS cannot answer*, which is not the same as `false`. There is **no change
  notification** — WebKit does not document the property as KVO-compliant and no event is exposed,
  so read it where it matters (after `onLoadStop`, say). It is per-*content*, not per-WebView
- **`InAppWebViewSettings.showsSystemScreenTimeBlockingView`** (iOS 26.0+) — whether WebKit draws
  its own overlay over blocked content. Defaults to `true`, matching WebKit. Setting it `false`
  does **not** unblock anything; it only stops WebKit explaining why, so pair it with
  `isBlockedByScreenTime()` or the user sees a blank WebView. Creation-time only, like the other
  configuration-backed settings
- **`InAppWebViewSettings.obscuredContentInsets`** (iOS 26.0+) — edge insets that shrink the page's
  **layout viewport** because your app draws chrome over those areas (a translucent nav bar, a
  floating toolbar). The page still paints edge to edge; per WebKit's documentation what changes is
  where `position: fixed` and `position: sticky` elements land. **The precise page-visible effect is
  not characterised by this plugin** — an attempt to measure it gave inconsistent results, so do not
  assume a relationship to `env(safe-area-inset-*)`; measure it for the layout you ship. All four
  values must be non-negative. It is a `WKWebView` property rather than a configuration one, so —
  alone among the iOS 26.0 additions — it **does** respond to `setSettings` on a running WebView.

  **It is not a fix for the keyboard `contentInset` behaviour** and does not replace the plugin's
  `keyboardWillShow`/`keyboardWillHide` handling: it exists only from iOS 26.0, so every supported
  version below that (15, 16, 17, 18) is unchanged. Treat it as new capability for app-drawn
  overlay chrome.
- **`InAppWebViewController.setConversationContext()` / `.getConversationContext()`** (iOS 26.0+),
  with the new `ConversationContext`, `ConversationEntry` and `PersonNameComponents` types — hand the
  system keyboard the mail or messaging thread the user is replying to, and it offers **Smart
  Replies** while they type into a web text field. The conversation is your app's, not the page's:
  the WebView cannot infer it. **Set it before the keyboard appears** — WebKit reads the context when
  the keyboard comes up, so a context set while it is already open takes effect on the next
  appearance. An entry missing any of `text`, `senderIdentifier`, `sentDate` or `entryIdentifier` is
  **dropped** rather than sent half-built, because the native type declares all four non-null and a
  message with no sender or date would mis-attribute the thread. `getConversationContext()` returns
  `null` below iOS 26.0, distinct from an empty context
- **`onInsertInputSuggestion`** (iOS 26.0+), with the new `InputSuggestion` type and the
  `InAppWebViewSettings.useOnInsertInputSuggestion` gate — the other half of Smart Reply: the
  keyboard tells you which suggestion the user picked, so you can put it into the page. **The payload
  is deliberately thin, and that is the API rather than an omission**: `UIInputSuggestion` declares
  no properties at all, and its only subclass carries a single `smartReply` string, so a suggestion
  that is not a Smart Reply arrives with every field `null`.

  **Opting in makes your app responsible for inserting the text.** The setting hides the
  `WKUIDelegate` selector entirely while it is off, the same mechanism as `useOnShowFileChooser` but
  for a different reason: WebKit documents what it does when the open-panel method is unimplemented
  and documents **nothing** for this one, while calling the parameter *"the web view where the input
  suggestion should be inserted"*. Rather than guess, the plugin leaves WebKit's own handling in
  place until an app asks for the event. Supplying the handler infers the setting automatically, as
  with `onShowFileChooser`
- **`CookieManager.setAcceptCookie()` / `.isAcceptCookieEnabled()` now work on iOS too** (iOS
  17.0+), from `WKHTTPCookieStore.setCookiePolicy` / `getCookiePolicy`. They shipped Android-only
  earlier in this release; the same two methods now answer on both platforms with the same
  contract, so the cookie master switch is no longer an Android-only concept.

  **The two platforms agree, and that was measured rather than assumed.** On iOS 26.5, exactly as on
  Android 13: the default is "accepting"; turning it off deletes nothing and hides nothing —
  `getCookies()` keeps returning what is already stored; and a programmatic `setCookie()` **is still
  not blocked**, nor is `deleteCookie()`. The switch governs the WebView's own network traffic, not
  the app's reads and writes. The shared integration test runs unchanged on both.

  Two platform differences that are real: the scope — process-wide on Android, but on iOS it belongs
  to the **default data store's** cookie store, so an incognito WebView is unaffected — and the
  floor. **Below iOS 17.0 `setAcceptCookie()` returns `false` and `isAcceptCookieEnabled()` returns
  `null`**, meaning *not applied* and *could not be read*, never "cookies are rejected". That is
  asserted on an iOS 16.4 simulator, because a guard that collapses `null` to `false` is invisible
  on any simulator at or above the floor. Setting the policy is also **not** a cookie change: it does
  not notify a `CookieStoreObserver`
- **`CookieManager.setCookieStoreObserver()`** (iOS **11.0+**, so every supported version), with the
  new `CookieStoreObserver` type — be told when the cookie store changes instead of polling
  `getAllCookies()` on a timer. Fires for the plugin's own `setCookie` / `deleteCookie` /
  `deleteAllCookies` as well as for cookies the page writes — measured on iOS 17.5 and 26.5, where
  one `setCookie` fires it once, **three in a row fire it three times (nothing is coalesced)**, and
  a pure read such as `getAllCookies()` fires it not at all. A callback that re-reads the store
  therefore will not loop; a callback that writes to it will.

  **The notification carries no payload**, matching the platform: it says *that* the store changed,
  not what changed, so read the store from inside the callback if you need the new state. It
  observes the **default** cookie store only — a WebView on a non-persistent (incognito) data store
  has its own. And there is **one observer per app**, not one per `CookieManager`: the store is
  process-wide, so setting a second observer replaces the first rather than adding a listener. Pass
  `null` to stop; the plugin only registers with WebKit while an observer is set
- **`onWritingToolsActiveChanged`** (iOS 18.0+), from `WKWebView.writingToolsActive` — fired when
  the system Writing Tools UI starts or stops operating on text in the page (Rewrite, Proofread,
  Summarize). Use it to get out of the way while it runs: pause your own editing UI, suspend
  autosave, stop reloading content the user is having rewritten.

  **It is an event rather than a getter because the platform property is read-only and documented
  KVO-compliant** — the state changes without your app asking, so a getter would have to be polled.
  The value starts `false` and no event is sent for that, so a handler — which can only be installed
  when the WebView is created — cannot miss a transition and has nothing to read back first. The
  event does not say *which* tool ran or what it changed; WebKit exposes neither. What Writing Tools
  is allowed to do is `InAppWebViewSettings.writingToolsBehavior`, the other half of this API.
- **`DownloadStartRequest.isUserInitiated` / `.originatingFrame`** — from `WKDownload`

`WebsiteDataType.WKWebsiteDataTypeScreenTime` is the third member of that family and has shipped
since the `WebsiteDataType.ALL` fix below. It stays **deliberately out of `ALL`** — see that entry.

### Fixed

**iOS — the page could not be scrolled to the bottom after the on-screen keyboard had been
dismissed** (upstream `#1947`; upstream PR `#2860` fixes the same defect). While the keyboard is up
the plugin installs a negative `contentInset` to cancel the enlarged safe area; when the keyboard
went away it reset only its internal latch and left the inset behind, so the compensation
over-corrected by the height of the home-indicator safe area and the last ~34 points of the page
became unreachable, rubber-banding instead of scrolling. Nothing recovered it unless the WebView
happened to be resized — and the code path exists precisely for apps that set
`resizeToAvoidBottomInset: false`, where it is not. Measured on iOS 26.5:
`adjustedContentInset.bottom` settled at `-34` and stayed there; it now settles at `0`. **iOS 17.2+
only** — below that the plugin never installs the keyboard observers, so the behaviour there is
unchanged. Unrelated to `InAppWebViewSettings.obscuredContentInsets`, which is iOS 26.0+ and does not
replace this path.

**Android — `WebMessageListener`'s `allowedOriginRules` could admit an origin it was not written
for.** The allow-list's IPv6 comparison ran through `InetAddress.canonicalHostName`, a reverse DNS
lookup, so it compared *hostnames* rather than addresses: a rule of `[::1]` and a page origin of
`127.0.0.1` both canonicalise to `"localhost"` on a typical machine and matched. A second bug meant
the IPv6 path ran for **every** origin, not just IPv6 ones, so each check could cost a forward and a
reverse DNS lookup on the calling thread and told the resolver which host the WebView was visiting.
Both helpers are now purely syntactic and never touch the network. **This is a tightening** — if you
relied on two different origins matching because they shared a canonical name, they no longer do.

**Two long-standing iOS behaviours are now written down as permanent decisions rather than left to
look like unfinished work.**

`onDownloadStarting` is a notification, not a hook — it cannot start, alter or veto a download, and
the plugin will never download the file for you. On Android the WebView never downloads it anyway;
on **iOS the plugin actively cancels** the `WKDownload` by dropping its delegate, and it does so
**whether or not `InAppWebViewSettings.useOnDownloadStart` is `true`**. With that setting `false`
— its default unless the event is implemented — a download link therefore appears to do nothing at
all, with no event and no error. Because the download never proceeds there is no native progress,
completion or failure to surface, and none is planned. Fetch `downloadStartRequest.url` yourself,
remembering that your request shares none of the WebView's cookies, `User-Agent` or auth headers.

The **iOS find-in-page JavaScript is deliberate and permanent**, not a missing native port. WebKit's
`findString:withConfiguration:` hands back a `WKFindResult` with a single property, `matchFound`, so
it cannot produce `activeMatchOrdinal`, `numberOfMatches` or `isDoneCounting`, and it selects one
match where `findAll` promises every match highlighted. The plugin already uses the native find
where a counting API exists — `UIFindInteraction` on iOS 16+, via
`InAppWebViewSettings.isFindInteractionEnabled`.

**iOS — HTTP auth credentials were shared between WebViews, and could reach the wrong host.** The
queue of saved credentials that `HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS` walks was
process-global: two WebViews authenticating at once consumed each other's credentials, and any
WebView finishing or failing a load emptied the queue mid-challenge. It is now per WebView, and a
queue filled for one protection space is discarded rather than popped for another — so a password
saved for one host can no longer be offered to a different one. `getCertificate` also documents that
on iOS it reports a **process-wide** certificate recorded during a server-trust challenge, which
WebKit issues only once per host per process.

**iOS — 15 settings are applied only when the WebView is created, and now say so.** Changing any
of them with `setSettings` on a running WebView has never had an effect, and the plugin no longer
pretends otherwise: `WKWebView.configuration` returns a fresh copy on every access — measured, not
inferred — so writing to it is discarded. The list is `mediaPlaybackRequiresUserGesture`,
`allowsInlineMediaPlayback`, `suppressesIncrementalRendering`, `selectionGranularity`,
`ignoresViewportScaleLimits`, `dataDetectorTypes`, `allowsAirPlayForMediaPlayback`,
`allowsPictureInPictureMediaPlayback`, `applicationNameForUserAgent`,
`allowUniversalAccessFromFileURLs`, `limitsNavigationsToAppBoundDomains`,
`upgradeKnownHostsToHTTPS`, `incognito`, `cacheEnabled` and `sharedCookiesEnabled`. Each one's
dartdoc says so, and two name the live alternative: use `userAgent` instead of
`applicationNameForUserAgent`, and `preferredHTTPSNavigationPolicy` instead of
`upgradeKnownHostsToHTTPS`. **To change one of these, recreate the WebView** — as the example app
does, by keying the widget on its settings revision. Everything else keeps responding to
`setSettings` as before, including all of `preferences`-backed settings such as `minimumFontSize`,
`isTextInteractionEnabled` and `shouldPrintBackgrounds`.

**iOS — `onReceivedClientCertRequest` returning `PROCEED` can silently send no certificate, and
this is now documented.** If the PKCS#12 file cannot be loaded, iOS falls back to
`performDefaultHandling`: the navigation continues **without** a client certificate and the server
sees an unauthenticated request. Nothing reaches Dart — no error, no exception — so the only symptom
is the `401`/`403` that arrives at `onReceivedHttpError`.

The case that catches people out is **iOS 17.x**, where `SecPKCS12Import` cannot read containers
encrypted with `PBES2 / PBKDF2 / AES-256-CBC` — the *default* for `openssl pkcs12 -export` under
OpenSSL 3 — and reports the failure as *"The user name or passphrase you entered is not correct"*
for a file whose passphrase is correct. The same certificate works on iOS 26. Run
`openssl pkcs12 -info -nokeys -noout -in cert.pfx`; if it says `PBES2, PBKDF2, AES-256-CBC`,
re-export with `-legacy` to support iOS 17.x, accepting that flag's weaker encryption. No plugin
code can work around it. (This is why the suite's own `SSL request` test fails on iOS 17.5 and
passes on 26.5 — it is a platform floor, not a defect.)

**iOS — `WebsiteDataType.ALL` did not mean all, so clearing website data left data behind.**
The set held only the ten `WKWebsiteDataType*` constants that existed in iOS 9–11.3; the iOS 26.5
SDK declares fifteen. `WebStorageManager.removeDataFor` / `.removeDataModifiedSince` with
`WebsiteDataType.ALL` — the documented way to wipe a site's storage — silently left behind the
origin-private file system (`WKWebsiteDataTypeFileSystem`, iOS 16+), DRM key storage
(`WKWebsiteDataTypeMediaKeys`), search field history
(`WKWebsiteDataTypeSearchFieldRecentSearches`) and the deviceId hash salt
(`WKWebsiteDataTypeHashSalt`, all iOS 17+). All four are now constants and are in `ALL`. Nothing in
the API reported the gap, which matters because this is the call an app makes to honour a
"delete my data" request.

`WKWebsiteDataTypeScreenTime` (iOS 26+) is also added as a constant but is **deliberately kept out
of `ALL`**: passing it to `removeDataModifiedSince` terminates the app on iOS 26.5 from inside
WebKit, and an uncaught Objective-C exception there cannot be caught in Dart. Its dartdoc carries
the measurement. If you pass a hand-built set rather than `ALL`, do not add it.

**iOS — four bugs that silently swallowed events, all found by running the integration suite on a
simulator for the first time:**

- **Ten `WKUIDelegate` / `WKNavigationDelegate` methods were never called at all.** The Swift 6
  migration left them declaring plain `@escaping (…) -> Void` handlers where the SDK declares
  `WK_SWIFT_UI_ACTOR` (`@MainActor @Sendable`), so Swift never inferred `@objc`, no selector was
  exported, and WebKit fell through to its built-in defaults — **with zero compiler diagnostics.**
  The consequences were user-visible: `onJsAlert` / `onJsConfirm` / `onJsPrompt` never fired (so
  JavaScript `confirm()` always returned `false` and `prompt()` always `null`),
  **`shouldOverrideUrlLoading` could not block a navigation** (`NavigationActionPolicy.CANCEL` was
  ignored), `onNavigationResponse`, `onPermissionRequest`, `shouldAllowDeprecatedTLS`,
  `onReceivedServerTrustAuthRequest` / `onReceivedHttpAuthRequest` /
  `onReceivedClientCertRequest` and the device orientation/motion permission request were all dead.
  **11 integration tests went green on this one fix.**
- **A throwing JavaScript handler hung the caller forever.** The error path built the rejection by
  interpolating the message into a single-quoted JS string literal escaping only `'`, so any message
  containing a newline — routine for `Exception` — produced invalid JavaScript, the
  `evaluateJavaScript` failed, and the promise stayed **pending for the lifetime of the page**:
  `await window.flutter_inappwebview.callHandler(...)` never settled
- **`onPrintRequest` killed the app on iOS 26.** `UIPrintInteractionControllerDelegate` is declared
  `NS_SWIFT_UI_ACTOR`, but UIKit calls it from a background thread, so Swift 6's executor check
  trapped and took the process down
- **A DNS failure threw inside the plugin on iOS 26, so `onReceivedError` never reached app code.**
  iOS 26 returns `NSError -1006` where 17.x returned -1003; `-1006` was unmapped and the generated
  `fromMap` force-unwrapped the lookup. Both codes now resolve to `WebResourceErrorType.HOST_LOOKUP`
  (matching Android's single `ERROR_HOST_LOOKUP`), and the code generator now falls back to an
  enum's own catch-all constant instead of emitting a bare `!`
- **`onEnterFullscreen` never fired for fullscreen video on iOS 26**, and `onExitFullscreen` with it.
  The plugin detects fullscreen media from `UIWindow.didBecomeVisibleNotification` and checks the
  window's size; on iOS 26 that notification arrives **before the window is laid out**, with a zero
  frame, so a window that was about to be fullscreen was rejected. The size check now re-runs once
  the window has been laid out. iOS 17.x was unaffected
- **A leaked `WKURLSchemeTask`** in the custom-scheme handler
- **`InAppWebViewSettings.allowingReadAccessTo` is documented as *not* a security boundary**, where
  it previously told you to set it "to prevent WebView from reading any other content". Measured on
  iOS 17.5 and 26.5: a `file://` page loads a sibling directory's script even with the scope narrowed
  to a directory that excludes it, and the plugin was verified to pass the right URL to WebKit. If a
  local page must not reach a file, do not put that file where the page can name it
- **`findAll` found nothing when the search text contained an apostrophe or a backslash**, wherever
  `InAppWebViewSettings.isFindInteractionEnabled` is `false`. The term was interpolated into
  JavaScript source unescaped, so `it's` made the script invalid and it failed silently — from Dart,
  indistinguishable from a page with no matches. The remaining 20 hand-escaped interpolation sites
  went through the same helper in the same pass; **none of those was a measured defect**, but one
  changes behaviour: `UserScript.allowedOriginRules` are compiled with `new RegExp` and the old
  escaping ate backslashes, so `https://.*\.example\.com` was silently compiled as
  `https://.*.example.com` — a wider match than written

**Android:**

- **`HeadlessInAppWebView.setSize` / `getSize` did not round-trip on Android.** The size is in
  logical pixels; Android layout params are `Int` physical pixels, and the conversion **truncated**
  in one direction and divided back in the other, so `Size(600, 800)` came back as
  `Size(599.795, 800)` at density 390 and a non-integer size lost precision at every density. The
  round-trip is now exact. `getSize` also reported a `-1` ("match the screen") axis as a *physical*
  pixel count — `Size(1080, 2400)` for a screen 411.4 logical pixels wide — and now answers in
  logical pixels like every other value in the API. iOS was already correct
- **`CookieManager.flush()` never returned.** The native side never replied, so the `Future` hung
  forever
- **A blocking callback could hang the WebView forever.** The four synchronous callbacks
  (`shouldInterceptRequest`, `shouldOverrideUrlLoading`, `onJsBeforeUnload`,
  `ServiceWorkerClient.shouldInterceptRequest`) waited on a latch that was not always released; the
  wait is now always released and bounded (10s)
- **The bundled `FileProvider` granted access to the entire external-storage root.** It is now
  scoped, and ships its own `@xml/inappwebview_provider_paths` (upstream #2874 / #2873)
- **Six bugs carried through the Java → Kotlin translation**, fixed once the diff was readable:
  `MediaSizeExt` unit conversion, `HeadlessInAppWebView.setSize`, `mayLaunchUrl`, `getRealSettings`,
  a boxed-value comparison in `setSettings`, and `JsBeforeUnloadResponse.toString()`
- **AGP 9 / ProGuard** compatibility (upstream #2852, #2765, #2761)

**Both platforms / tooling:**

- **`WebResourceErrorType.HOST_LOOKUP` threw when read on Android.** The constant accepts a second
  inbound native code on iOS, and the generated closure for that returned an untyped `const []` on
  every other platform, which failed the cast in its own initialiser:
  `type 'List<dynamic>' is not a subtype of type 'List<int?>'`. Any Android code touching the
  constant crashed — including `onReceivedError` handlers comparing against it. Fixed in the
  generator, with a regression test
- **`onFaviconChanged` now documents that it does not fire on modern Android WebView**, where
  `WebChromeClient.onReceivedIcon` is no longer dispatched (`WebIconDatabase` is inert). Measured on
  API 33 and 37; `InAppWebViewController.getFavicons()` is the working alternative

- **An unmapped permission resource killed `onPermissionRequest` on both platforms.**
  `PermissionRequest` / `PermissionResponse` force-unwrapped the `PermissionResourceType` lookup, so
  a single `PermissionRequest.RESOURCE_*` string Android adds, or a `WKMediaCaptureType` raw value
  Apple adds, threw inside the channel handler and the event never reached app code — the app just
  never sees the prompt. `PermissionResourceType.UNKNOWN` is the fallback again; unlike the constant
  of that name this fork removed, it is **not** platform-annotated, describes no platform API, and
  exists only for this purpose. Treat it as "deny unless you know better" — the example does
- The code generator emitted broken code for `Map<String, SomeEnum>` fields (both directions), and
  emitted a bare `!` on every non-nullable enum lookup — both fixed, with regression tests
- Every mirrored `WebViewFeature` constant is now pinned against the real `androidx.webkit` AAR by a
  test: six of the declared flags are `@Deprecated` tombstones that `isFeatureSupported` **throws**
  for, and five others have a *value* that differs from their name
- `analysis_options.yaml` (upstream #2758), 16 KB page size (#2703 — determined not applicable: the
  plugin ships no native code of its own)
- **`WebMessageListener.allowedOriginRules`' wildcard admitted origins it did not name.** The match
  was an unanchored substring test, so `https://*.example.com` also admitted
  `foo.example.com.evil.test` — the suffix occurs in the middle of a host whose registrable domain
  belongs to somebody else. It is now anchored at the end of the host: `*.example.com` matches
  `foo.example.com` and neither bare `example.com` nor `foo.example.com.evil.test`. **A pure
  tightening** — nothing that matched before matches now — so the only rules affected are ones that
  were admitting more than they said. On iOS this is the check that decides whether the listener's
  JavaScript object exists, and it is the only gate on the Dart → page direction, so an app could
  `postMessage` into a page its allow-list never named; on Android the WebView does the matching
  natively and was never affected. The dotless spelling `*example.com` is deliberately unchanged
- **A saved password could be sent to the wrong host, on both platforms.** The `USE_SAVED_HTTP_AUTH_CREDENTIALS`
  queue is filled by matching host + scheme + realm + port, but nothing re-checked that when handing
  a credential out, so a queue filled for host A could be popped for host B — reachable from a single
  page with authenticated subresources on a second origin. Fixed on iOS in 7.0.0's earlier
  `credentialsProposed` work and now on Android. On Android the same state was additionally
  **process-global**, shared by every WebView in the app: one WebView's `onPageFinished` emptied
  another's queue mid-challenge, and one WebView's failures were reported to another's handler as
  `HttpAuthenticationChallenge.previousFailureCount`. Both are now per-WebView
- **iOS: a WebView released off the main thread could crash the app.** The crash surfaced in
  `WebViewChannelDelegate`'s deinit and presented as the app dying with no Dart error and no
  exception. Its trigger was a channel callback holding a strong reference to the WebView, which the
  Flutter engine could release on a background thread; the three authentication-challenge callbacks
  now hold it weakly. Nothing in the public API changes
- 48 dead availability checks removed on iOS — all of them at or below the new 15.0 floor — along
  with the below-iOS-14 `callAsyncJavaScript` path and the dead `SFAuthenticationSession` branches;
  and the dead ~300-line `InputAwareWebView` path deleted on Android

### Internal

- **The Android module is 100% Kotlin** (158 files translated) with ktlint 1.8 formatting and an
  opt-in `allWarningsAsErrors`; Android lint is at **0 findings**
- **The iOS module builds in Swift 6 language mode** with complete concurrency checking, 0 errors and
  0 warnings
- **Pigeon** is wired up and the `find_interaction` channel is migrated end to end as a proof; the
  other ~409 messages still use `MethodChannel`
- **412 unit tests** (from 276) — including the Android module's first native tests, which found two
  bugs on their first run — and the integration suite now runs on iOS as well as Android. Every API
  added here is pinned by a test and demonstrated in the example app

### Migration

1. Rename every `*Options` type and parameter to its `*Settings` equivalent, and
   `getOptions`/`setOptions` to `getSettings`/`setSettings`.
2. Drop the `Android` / `IOS` prefix from the duplicate types, events, fields and methods listed
   above. Every replacement already existed in 6.x.
3. Raise `minSdk` to 30 and your iOS deployment target to 15.0; build the iOS module with
   **Xcode 26 or newer**.
4. Delete any macOS / Windows / Linux / Web-only API — there is nothing to migrate to. `switch`
   chains over `WebResourceErrorType`, `SslErrorType` and `PermissionResourceType` may name
   constants that no longer exist; these are constant classes rather than Dart `enum`s, so the
   analyzer reports the missing name but never an exhaustiveness error.
5. If you declared the plugin's FileProvider, replace the whole `<provider>` block with the one in
   the `InAppWebViewFileProvider` KDoc: `android:name` →
   `dev.nosferatu500.inappwebview.InAppWebViewFileProvider`, `android:authorities` →
   `${applicationId}.dev.nosferatu500.inappwebview.fileprovider`, and the `meta-data` resource →
   `@xml/inappwebview_provider_paths`. Missing the authority is silent — `<input type="file"
   capture>` simply stops producing a file, with no Dart error.
6. If anything in your app talks to the plugin's platform channels directly, update the channel
   names to the `dev.nosferatu500.inappwebview/…` prefix.

## 6.2.0-beta.3

- Added Linux support
- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_platform_interface`: `^1.4.0-beta.2` -> `^1.4.0-beta.3`
  - `flutter_inappwebview_android`: `^1.2.0-beta.2` -> `^1.2.0-beta.3`
  - `flutter_inappwebview_ios`: `^1.2.0-beta.2` -> `^1.2.0-beta.3`
  - `flutter_inappwebview_macos`: `^1.2.0-beta.2` -> `^1.2.0-beta.3`
  - `flutter_inappwebview_web`: `^1.2.0-beta.2` -> `^1.2.0-beta.3`
  - `flutter_inappwebview_windows`: `^0.7.0-beta.2` -> `^0.7.0-beta.3`
  - `flutter_inappwebview_linux`: `^0.1.0-beta.1`
- Added `InAppWebViewController.getFavicon` wrapper with `faviconImageFormat` support.
- Fixed "When useShouldInterceptAjaxRequest is true, some ajax requests doesn't work" [#2197](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2197)
- Mapped `isClassSupported`, `isPropertySupported`, `isMethodSupported` platform interface static methods to the corresponding plugin classes such as `InAppWebViewController`, `InAppWebView`, `InAppBrowser`, etc., in order to check if a class, property, or method is supported by the platform at runtime
- Updated code generator
- Minimum Dart SDK `^3.8.0`
- Minimum Flutter SDK `>=3.32.0`

#### Platform Interface
- Updated `flutter_inappwebview_internal_annotations` dependency from `^1.2.0` to `^1.3.0`
- Added `isClassSupported`, `isPropertySupported`, `isMethodSupported` static methods for all main classes, such as `PlatformInAppWebViewController`, `InAppWebViewSettings`, `PlatformInAppBrowser`, etc., in order to check if a class, property, or method is supported by the platform at runtime
- Added `isSupported` method to all custom enum classes
- Added `saveState`, `restoreState`, `requestEnterFullscreen`, `requestExitFullscreen`, `setVisible`, `setTargetRefreshRate`, `getTargetRefreshRate`, `requestPointerLock`, `requestPointerUnlock`, `getScreenScale`, `setScreenScale`, `isVisible`, `getFrameId`, `getFavicon`, `showSaveAsUI`, `getMemoryUsageTargetLevel`, `setMemoryUsageTargetLevel` methods to `PlatformInAppWebViewController` class
- Added `useOnAjaxReadyStateChange`, `useOnAjaxProgress`, `useOnShowFileChooser`, `corsAllowlist`, `itpEnabled`, `darkMode`, `disableAnimations`, `fontAntialias`, `fontHintingStyle`, `fontSubpixelLayout`, `fontDPI`, `cursorBlinkTime`, `doubleClickDistance`, `doubleClickTime`, `dragThreshold`, `keyRepeatDelay`, `keyRepeatInterval`, `disableWebSecurity`, `enableWebRTC`, `webRTCUdpPortsRange`, `javaScriptCanAccessClipboard`, `allowModalDialogs`, `enableMedia`, `enableEncryptedMedia`, `enableMediaCapabilities`, `enableMockCaptureDevices`, `mediaContentTypesRequiringHardwareSupport`, `enableJavaScriptMarkup`, `enable2DCanvasAcceleration`, `allowTopNavigationToDataUrls` properties to `InAppWebViewSettings`
- Added `onShowFileChooser`, `onContentLoading`, `onDOMContentLoaded`,  `onLaunchingExternalUriScheme`, `onFaviconChanged`, `onNotificationReceived`, `onSaveAsUIShowing`, `onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting` WebView events
- Added `PlatformWebNotificationController` class
- Update code documentation
- Deprecated `onReceivedIcon` in favor of `onFaviconChanged`

#### Android Platform
- Updated native dependencies:
  - implementation from `'androidx.webkit:webkit:1.12.0'` to `'androidx.webkit:webkit:1.14.0'`
  - implementation from `'androidx.browser:browser:1.8.0'` to `'androidx.browser:browser:1.9.0'`
  - implementation from `'androidx.appcompat:appcompat:1.6.1'` to `'androidx.appcompat:appcompat:1.7.1'`
  - implementation from `'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'` to `'androidx.swiperefreshlayout:swiperefreshlayout:1.2.0'`
- Updated android native `compileOptions` to `JavaVersion.VERSION_17`
- Implemented `saveState`, `restoreState` InAppWebViewController methods
- Implemented `onShowFileChooser` WebView event
- Updated InAppBrowser toolbar top
- Merged "Android: implemented PlatformPrintJobController.onComplete" [#2216](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2216) (thanks to [Doflatango](https://github.com/Doflatango))
- Fixed "When useShouldInterceptAjaxRequest is true, some ajax requests doesn't work" [#2197](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2197)
- Merged "Fixed recursive calling toMap in AndroidInternalStoragePathHandler" [#2452](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2452) (thanks to [roberthofstra](https://github.com/roberthofstra))
- Fixed recursive `toMap` call for `AndroidInternalStoragePathHandler` [#2451](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2451)
- Fixed "Error when updating webview settings Android in v6.2.0-beta.2" [#2449](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2449)
- Fixed "[Android] Upgrade to AGP 9" [#2765](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2765)
- Fixed "update android apg version to 8.9.1 or higer" [#2761](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2761)
- Fixed "InAppWebViewController.goTo" implementation
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))

#### macOS and iOS Platforms
- Implemented `saveState`, `restoreState` InAppWebViewController methods
- Implemented `PlatformProxyController` class
- Add Swift Package Manager support [#2409](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2409)
- Fixed "[iOS] Webview opened with windowId does not receive javascript handler callback." [#2393](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2393)
- Fixed internal javascript callback handlers when the WebView has windowId not null
- Fixed crash of unhandled `onPrintRequest` WebView event
- Fixed "When useShouldInterceptAjaxRequest is true, some ajax requests doesn't work" [#2197](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2197)
- Fixed "iOS App rejected by apple for violating Guideline 2.5.1 - Performance - Software Requirements | Flutter 3.35.x seems to use non-public or deprecated APIs" [#2754](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2754)
- Fixed "InAppWebViewController.goTo" implementation
- Merged "Add proxy support for iOS" [#2362](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2362) (thanks to [yerkejs](https://github.com/yerkejs))
- Merged "🐛 fix MacOS: when using the `WebMessageListener` `onPostMessage` method, the message parameter is unexpectedly empty" [#2481](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2481) (thanks to [imoyakin](https://github.com/imoyakin))
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))
- Merged "Fix gesture recognition delay prevention for latest Flutter versions" [#2538](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2538) (thanks to [muccy-timeware](https://github.com/muccy-timeware))

### Windows
- Updated Microsoft.Web.WebView2 SDK version from `1.0.2849.39` to `1.0.3650.58`
- Implemented `getFrameId`, `getFavicon`, `showSaveAsUI`, `getMemoryUsageTargetLevel`, `setMemoryUsageTargetLevel` InAppWebViewController method
- Added support for `onEnterFullscreen`, `onExitFullscreen`, `onContentLoading`, `onDOMContentLoaded`,  `onLaunchingExternalUriScheme`, `onFaviconChanged`, `onNotificationReceived`, `onSaveAsUIShowing`, `onSaveFileSecurityCheckStarting`, `onScreenCaptureStarting` WebView events.
- Added native FindInteractionController implementation using WebView2 `ICoreWebView2Find`.
- Implemented `setFindOptions` FindInteractionController method
- Implemented `PlatformWebNotificationController` feature
- Merged "windows: fix WebViewEnvironment dispose crash" [#2433](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2433) (thanks to [GooRingX](https://github.com/GooRingX))
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))
- Merged "Prevent Unpredictable Close On Windows" [#2543](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2543) (thanks to [momadvisor](https://github.com/momadvisor))

### Web
- Updated `onCreateWindow` WebView event
- Implemented `onCloseWindow`, `onCallJsHandler` WebView events
- Implemented `addJavaScriptHandler`, `removeJavaScriptHandler`, `hasJavaScriptHandler`, `addUserScript`, `addUserScripts`, `removeUserScript`, `removeUserScriptsByGroupName`, `removeUserScripts`, `hasUserScript` InAppWebViewController methods
- Implemented `setJavaScriptBridgeName`, `getJavaScriptBridgeName`, `getDefaultUserAgent` InAppWebViewController static methods
- Implemented `javaScriptHandlersOriginAllowList`, `javaScriptBridgeEnabled`, `javaScriptBridgeOriginAllowList`, `hasJavaScriptHandler`, `addUserScript`, `addUserScripts`, `removeUserScript` of `InAppWebViewSettings`
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))

### Linux
- Initial implementation

## 6.2.0-beta.2

- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_platform_interface`: `^1.4.0-beta.1` -> `^1.4.0-beta.2`
  - `flutter_inappwebview_android`: `^1.2.0-beta.1` -> `^1.2.0-beta.2`
  - `flutter_inappwebview_ios`: `^1.2.0-beta.1` -> `^1.2.0-beta.2`
  - `flutter_inappwebview_macos`: `^1.2.0-beta.1` -> `^1.2.0-beta.2`
  - `flutter_inappwebview_web`: `^1.2.0-beta.1` -> `^1.2.0-beta.2`
  - `flutter_inappwebview_windows`: `^0.7.0-beta.1` -> `^0.7.0-beta.2`
- Fixed specific URLAuthenticationChallenge type for `onReceivedHttpAuthRequest`, `onReceivedServerTrustAuthRequest`, `onReceivedClientCertRequest` events of HeadlessInAppWebView
- Fixed missing return type for `InAppWebViewController.getJavaScriptBridgeName` static method

#### Platform Interface
- Updated `flutter_inappwebview_internal_annotations` dependency from `^1.1.1` to `^1.2.0`
- Updated `fromMap` static method and `toMap` method implementations
- Updated all WebView events with return type `Future` to type `FutureOr` in order to not force the usage of `async` keyword
- Added `byName`, `name`, `asNameMap` custom enum classes methods
- Added `statusBarEnabled`, `browserAcceleratorKeysEnabled`, `generalAutofillEnabled`, `passwordAutosaveEnabled`, `isPinchZoomEnabled`, `hiddenPdfToolbarItems`, `reputationCheckingRequired`, `nonClientRegionSupportEnabled`, `alpha`, `isUserInteractionEnabled` properties to `InAppWebViewSettings`
- Added `isInterfaceSupported`, `getProcessInfos`, `getFailureReportFolderPath` methods to `PlatformWebViewEnvironment` class
- Added `isInterfaceSupported`, `setInputMethodEnabled`, `hideInputMethod`, `showInputMethod` methods to `PlatformInAppWebViewController` class
- Added `exclusiveUserDataFolderAccess`, `isCustomCrashReportingEnabled`, `enableTrackingPrevention`, `areBrowserExtensionsEnabled`, `channelSearchKind`, `releaseChannels`, `scrollbarStyle` properties to `WebViewEnvironmentSettings`
- Added `onDownloadStarting` WebView event and deprecated `onDownloadStartRequest` event
- Added `onNewBrowserVersionAvailable`, `onBrowserProcessExited`, `onProcessInfosChanged` events to `PlatformWebViewEnvironment` class
- Fixed missing PrintJobOrientation android values

#### Android Platform
- Implemented `hideInputMethod`, `showInputMethod` InAppWebViewController methods
- Implemented `isUserInteractionEnabled`, `alpha` properties of `InAppWebViewSettings`
- Merged "Show / Hide / Disable / Enable soft Keyboard Input (Android & iOS)" [#2408](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2408) (thanks to [Mecharyry](https://github.com/Mecharyry))
- Fixed "[Android] PrintJobOrientation _TypeError (type 'Null' is not a subtype of type 'int')" [#2413](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2413)
- Fixed "Accessibility Android" [#1694](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1694)
- Fixed "Automatic font scale according to accessibility option 'font size' of device does not work on Android" [#540](https://github.com/pichillilorenzo/flutter_inappwebview/issues/540)
- Fixed "callHandler method is not injected into InAppBrowser" [#1973](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1973)

#### iOS Platform
- Implemented `setInputMethodEnabled`, `hideInputMethod` InAppWebViewController methods
- Implemented `isUserInteractionEnabled`, `alpha` properties of `InAppWebViewSettings`
- Merged "Show / Hide / Disable / Enable soft Keyboard Input (Android & iOS)" [#2408](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2408) (thanks to [Mecharyry](https://github.com/Mecharyry))
- Fixed "In iOS version 17.2, when moving the input focus in a WebView, an unknown area appears at the top of the screen." [#1947](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1947)

#### macOS Platform
- Implemented `alpha` property of `InAppWebViewSettings`

#### Windows Platform
- Updated Microsoft.Web.WebView2 SDK version from `1.0.2792.45` to `1.0.2849.39`
- Implemented `disableDefaultErrorPage`, `statusBarEnabled`, `browserAcceleratorKeysEnabled`, `generalAutofillEnabled`, `passwordAutosaveEnabled`, `isPinchZoomEnabled`, `allowsBackForwardNavigationGestures`, `hiddenPdfToolbarItems`, `reputationCheckingRequired`, `nonClientRegionSupportEnabled` properties of `InAppWebViewSettings`
- Implemented `isInterfaceSupported`, `getProcessInfos`, `getFailureReportFolderPath` WebViewEnvironment methods
- Implemented `isInterfaceSupported`, `getZoomScale` InAppWebViewController method
- Implemented `onDownloadStarting`, `onAcceleratorKeyPressed` WebView event
- Implemented `exclusiveUserDataFolderAccess`, `isCustomCrashReportingEnabled`, `enableTrackingPrevention`, `areBrowserExtensionsEnabled`, `channelSearchKind`, `releaseChannels`, `scrollbarStyle` properties of `WebViewEnvironmentSettings`
- Implemented `onNewBrowserVersionAvailable`, `onBrowserProcessExited`, `onProcessInfosChanged` WebViewEnvironment events
- Send mouse leave region event to native view
- Fixed wrong channel name when creating a `WebViewEnvironment` instance
- Fixed "[Windows] Has an overlay on the desktop when the application is minimized" [#2402](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2402)
- Fixed "[Windows] missing implementation of onPermissionRequest event will cause crash when requested by the webpage" [#2404](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2404)
- Fixed "Windows: getCookies return empty list" [#2314](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2314)

## 6.2.0-beta.1

- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_platform_interface`: `^1.3.0` -> `^1.4.0-beta.1`
  - `flutter_inappwebview_android`: `^1.1.3` -> `^1.2.0-beta.1`
  - `flutter_inappwebview_ios`: `^1.1.2` -> `^1.2.0-beta.1`
  - `flutter_inappwebview_macos`: `^1.1.2` -> `^1.2.0-beta.1`
  - `flutter_inappwebview_web`: `^1.1.2` -> `^1.2.0-beta.1`
  - `flutter_inappwebview_windows`: `^0.6.0` -> `^0.7.0-beta.1`
- Fixed specific URLAuthenticationChallenge type for `onReceivedHttpAuthRequest`, `onReceivedServerTrustAuthRequest`, `onReceivedClientCertRequest` events

Implemented security features to better manage access to the native javascript bridge.

#### Platform Interface
- Updated static `fromMap` implementation for some classes
- Updated `kJavaScriptHandlerForbiddenNames` list
- Added `PlatformInAppLocalhostServer.onData` parameter to set a custom on data server callback
- Added `javaScriptBridgeEnabled`, `javaScriptBridgeOriginAllowList`, `javaScriptBridgeForMainFrameOnly`, `pluginScriptsOriginAllowList`, `pluginScriptsForMainFrameOnly`, `javaScriptHandlersOriginAllowList`, `javaScriptHandlersForMainFrameOnly`, `scrollMultiplier` InAppWebViewSettings parameters
- Added `setJavaScriptBridgeName`, `getJavaScriptBridgeName` static WebView controller methods
- Added `requestFocus` WebView method
- Added `onProcessFailed` WebView event
- Added `regexToAllowSyncUrlLoading` Android-specific property to `InAppWebViewSettings`
- Added `JavaScriptHandlerFunctionData` type
- Deprecated `JavaScriptHandlerCallback` type in favor of `JavaScriptHandlerFunction` type
- Deprecated `InAppWebViewSettings.forceDark` and `InAppWebViewSettings.forceDarkStrategy` Android-only properties in favor of `InAppWebViewSettings.algorithmicDarkeningAllowed`
- Fixed X509Certificate PEM base64 decoding

#### Android Platform
- Added `InAppWebViewController.enableSlowWholeDocumentDraw` static method
- Added `CookieManager.flush` method
- Added support for `UserScript.forMainFrameOnly` parameter
- Implemented `requestFocus` WebView method
- Updated UserScript at document end implementation
- Updated `InAppWebViewController.takeScreenshot` implementation to support screenshot out of visible viewport when `InAppWebViewController.enableSlowWholeDocumentDraw` is called
- Fixed "After dispose a InAppWebViewKeepAlive using InAppWebViewController.disposeKeepAlive. NullPointerException is thrown when main activity enter destroyed state." [#2025](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2025)
- Fixed crash when trying to open InAppBrowser with R.menu.menu_main on release mode
- Fixed "android.webkit.WebSettingsWrapper cannot be cast to com.android.webview.chromium.ContentSettingsAdapter" [#2397](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2397)
- Merged "Prevent blank InAppBrowser Activity from being restored" [#1984](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1984) (thanks to [ShuheiSuzuki-07](https://github.com/ShuheiSuzuki-07))
- Merged "Update Android Cookie Expiration date format to 24-hour format (HH)" [#2389](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2389) (thanks to [takuyaaaaaaahaaaaaa](https://github.com/takuyaaaaaaahaaaaaa))
- Merged "[Android] allow sync navigation requests using a regular expression" [#2008](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2008) (thanks to [lyb5834](https://github.com/lyb5834))

#### macOS and iOS Platforms
- Implemented `requestFocus` WebView method
- Updated ConsoleLogJS internal PluginScript to main-frame only as using it on non-main frames could cause issues such as [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Moved `WKUserContentController` initialization on `preWKWebViewConfiguration` to fix possible `undefined is not an object (evaluating 'window.webkit.messageHandlers')` javascript error
- Added support for `UserScript.allowedOriginRules` parameter
- Merged "change priority of DispatchQueue" [#2322](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2322) (thanks to [nnnlog](https://github.com/nnnlog))
- ios: Fixed `show`, `hide` methods and `hidden` setting for `InAppBrowser`
- macOS: Implemented also `clearFocus` WebView method
- macOS: Implemented workaround for "[macOS] Copy Shortcut does not work if TextField outside of WebView has focus" [#2380](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2380)

#### Windows Platform
- Updated `scrollMultiplier` default value from 6 to 1
- Added support for `UserScript.allowedOriginRules` and `UserScript.forMainFrameOnly` parameters
- Implemented `onReceivedHttpAuthRequest`, `onReceivedClientCertRequest`, `onReceivedServerTrustAuthRequest`, `onRenderProcessGone`, `onRenderProcessUnresponsive`, `onWebContentProcessDidTerminate`, `onProcessFailed` WebView events
- Implemented `clearSslPreferences` WebView method
- Fixed `get_optional_fl_map_value` implementation in `utils/flutter.h`
- Fixed "Error in transparentBackground handling in Windows" [#2391](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2391)

#### Web Platform
- Merged "[web] support iframe role and aria-hidden attributes" [2293](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2293) (thanks to [p-mazhnik](https://github.com/p-mazhnik))
- Fixed 'Type 'int' is not a subtype of type 'JSValue' in type cast' when compiling/running using WASM

## 6.1.5

- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_windows`: `^0.5.0` -> `^0.6.0`

#### Windows Platform
- Updated code to support multiple flutter windows
- Fixed `InAppWebViewController.callAsyncJavaScript` not working with JSON objects
- Fixed `onLoadResourceWithCustomScheme` WebView event called every time

## 6.1.4

- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_platform_interface`: `^1.2.0` -> `^1.3.0`
  - `flutter_inappwebview_android`: `^1.1.1` -> `^1.1.3`
  - `flutter_inappwebview_ios`: `^1.1.1` -> `^1.1.2`
  - `flutter_inappwebview_macos`: `^1.1.1` -> `^1.1.2`
  - `flutter_inappwebview_web`: `^1.1.1` -> `^1.1.2`
  - `flutter_inappwebview_windows`: `^0.4.0` -> `^0.5.0`

#### Android Platform
- Removed webview/plugin_scripts_js/ConsoleLogJS.java file, use native WebChromeClient.onConsoleMessage instead

#### Windows Platform
- Implemented `shouldInterceptRequest`, `onLoadResourceWithCustomScheme` WebView events

## 6.1.3

- Updated dependencies to the latest versions for all platform implementations:
  - `flutter_inappwebview_platform_interface`: `^1.1.0` -> `^1.2.0`
  - `flutter_inappwebview_android`: `^1.1.0+4` -> `^1.1.1`
  - `flutter_inappwebview_ios`: `^1.1.0+3` -> `^1.1.1`
  - `flutter_inappwebview_macos`: `^1.1.0+3` -> `^1.1.1`
  - `flutter_inappwebview_web`: `^1.1.0+2` -> `^1.1.1`
  - `flutter_inappwebview_windows`: `^0.3.0` -> `^0.4.0`

#### Windows Platform
  - Updated `shouldOverrideUrlLoading` implementation using the Chrome DevTools Protocol API Fetch.requestPaused event

## 6.1.2

- Updated minimum platform implementation versions

#### Windows Platform

- Implemented `pause`, `resume`, `getCertificate` methods for `InAppWebViewController`
- Implemented `onPermissionRequest` WebView event
- Fixed `InAppWebViewController.evaluateJavascript` not working with JSON objects
- Fixed `InAppWebViewManager::METHOD_CHANNEL_NAME` c++ value
- Fixed `InAppWebViewController.takeScreenshot` to behave consistently with the other platforms

## 6.1.1

- Updated README
- Updated pubspec.yaml
- Updated minimum platform implementation versions

## 6.1.0+1

- Updated README

## 6.1.0

- Added initial Windows support
- Added `InAppWebView` widget MacOS support
- Added privacy manifest for MacOS
- Migrated web support to `package:web`.
- Updated minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Updated androidx.webkit:webkit:1.8.0 to androidx.webkit:webkit:1.12.0
- Updated androidx.browser:browser:1.6.0 to androidx.browser:browser:1.8.0
- Fixed "[MACOS] launching InAppBrowser with 'hidden: true' calls onExit immediately" [#1939](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1939)
- Fixed XCode 16 build
- Removed unsupported WebViewFeature.SUPPRESS_ERROR_PAGE
- Merged "Add privacy manifest for iOS" [#2029](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2029) (thanks to [ueman](https://github.com/ueman))
- Merged "Remove references to deprecated v1 Android embedding" [#2176](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2176) (thanks to [gmackall](https://github.com/gmackall))

## 6.0.0

- Updated minimum platform interface and implementation versions
- Merged "Added == operator and hashCode to WebUri" [#1941](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1941) (thanks to [daisukeueta](https://github.com/daisukeueta))

## 6.0.0-rc.3

- Updated minimum platform interface and implementation versions
- Fix typos and other code improvements (thanks to [michalsrutek](https://github.com/michalsrutek))
- Fixed "runtime issue of SecTrustCopyExceptions 'This method should not be called on the main thread as it may lead to UI unresponsiveness.' when using onReceivedServerTrustAuthRequest" [#1924](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1924)
- Merged "💥 Fix iPad crash due to missing sourceView" [#1933](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1933) (thanks to [michalsrutek](https://github.com/michalsrutek))
- Merged "💥 Fix crash - remove force unwrapping from dispose method" [#1932](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1932) (thanks to [michalsrutek](https://github.com/michalsrutek))

## 6.0.0-rc.2

- Updated minimum platform interface and implementation versions
- Added `CustomPathHandler` class to be able to implement Android custom path handlers for `WebViewAssetLoader`

## 6.0.0-rc.1

- Updated minimum platform interface and implementation versions
- Added `InAppBrowser.onMainWindowWillClose` event
- Added `WindowType.WINDOW` for `InAppBrowserSettings.windowType`
- Fixed "Cloudflare Turnstile failure" [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Fixed `InAppWebViewController.callAsyncJavaScript` Android-issue when the last line of the `functionBody` parameter includes a code comment

### BREAKING CHANGES

- Default value of `InAppBrowserSettings.windowType` is `WindowType.WINDOW`

## 6.0.0-beta.32

- Updated minimum platform interface and implementation versions
- Added `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests` [#1905](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1905)
- Added `InAppWebViewController.clearFormData` Android-specific method
- Added `InAppWebViewController.clearAllCache` static method
- Added `CookieManager.removeSessionCookies` Android-specific method
- Deprecated `InAppWebViewController.clearCache` and `InAppWebViewSettings.clearCache`. Use `InAppWebViewController.clearAllCache` static method instead
- Deprecated `InAppWebViewSettings.clearSessionCache`. Use `CookieManager.removeSessionCookies` method instead
- Updated `useShouldInterceptAjaxRequest` automatic infer logic
- Updated `CookieManager` methods return value
- Fixed "iOS crash at public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)" [#1912](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1912)
- Fixed "iOS Fatal Crash" [#1894](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1894)
- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)
- Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'
- Fixed shouldInterceptAjaxRequest javascript code when overriding XMLHttpRequest.open method parameters
- Fixed "onClosed not considering back navigation or up button / close button in ChromeSafariBrowser when using noHistory: true" [#1882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1882)
- Merged "Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'" [#1904](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1904) (thanks to [EArminjon](https://github.com/EArminjon))

### BREAKING CHANGES

- Due to Flutter platform channels async nature, using `useShouldInterceptAjaxRequest: true` would break sync ajax requests, so that the `XMLHttpRequest.send()` will not wait for the response. To fix this issue, the default value of `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests` is `true`. To intercept also sync ajax requests, this value should be `false`.

## 6.0.0-beta.31

- Updated minimum platform interface and implementation versions
- Fixed events not called on `InAppBrowser` and `ChromeSafariBrowser` opening same instance multiple times 

## 6.0.0-beta.30

- Updated minimum platform interface and implementation versions
- Fixed "Crash when starting ChromeSafariBrowser on Android java.lang.NoSuchMethodError: No virtual method isEngagementSignalsApiAvailable" [#1881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1881)

## 6.0.0-beta.29

### BREAKING CHANGES

- Plugin conversion to a [Federated Plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) to better support multiple environments and implementations.
- Dart SDK min version `>= 2.17.0`
- Android package name has been changed to `com.pichillilorenzo.flutter_inappwebview_android`. References to old package name `com.pichillilorenzo.flutter_inappwebview` should be updated, for example inside `AndroidManifest.xml` file: `<provider android:name="com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFileProvider" android:authorities="${applicationId}.flutter_inappwebview_android.fileprovider" ...`
- Web Platform: `web_support.js` file path has been changed to `packages/flutter_inappwebview_web/assets/web/web_support.js`

## 6.0.0-beta.28

- Added `ProcessGlobalConfig` for Android WebViews
- Added `disableWebView` static method on `InAppWebViewController` for Android
- Added support for Android `WebViewFeature.isStartupFeatureSupported`, `WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS`, `WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX`, `WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER`
- Added `WebMessage.type` property
- Fixed "iOS EXC_BAD_ACCESS crash on kill app with InAppWebView keyboard open" [#1837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1837)
- Fixed "Flutter Web - TypeError: Failed to execute 'observe' on 'MutationObserver': parameter 1 is not of type 'Node'. error" [#1841](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1841)

### BREAKING CHANGES

- `WebMessage.data` property is of type `dynamic`
- `JavaScriptReplyProxy.postMessage` is of type `WebMessage`
- `WebMessageListener.onPostMessage` and `WebMessagePort.setWebMessageCallback` methods signature

## 6.0.0-beta.27

- Added `requestPostMessageChannel`, `postMessage`, `isEngagementSignalsApiAvailable` methods on `ChromeSafariBrowser` for Android
- Added `onMessageChannelReady`, `onPostMessage`, `onVerticalScrollEvent`, `onGreatestScrollPercentageIncreased`, `onSessionEnded` events on `ChromeSafariBrowser` for Android
- Added `getPackageName` static method on `ChromeSafariBrowser` for Android

## 6.0.0-beta.26

- Throw an error if any controller is used after being disposed
- `CookieManager.deleteCookies` wait for all delete cookie completion handler to be completed on iOS and macOS
- Updated return value for `CookieManager.setCookie` method to be `Future<bool>`. The return value indicates whether the cookie was set successfully
- Merged "feat(ios): optional tradeoff to fix ios input delay" [#1665](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1665) (thanks to [andreasgangso](https://github.com/andreasgangso))
- Merged "Fix ios multiple flutter presenting error" [#1736](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1736) (thanks to [AlexT84](https://github.com/AlexT84))
- Merged "fix cert parsing for ios 12" [#1822](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1822) (thanks to [darkang3lz92](https://github.com/darkang3lz92))
- Merged "Fix iOS and macOS Forced unwrap null value HTTPCookie for CookieManager.setCookie" [#1677](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1677) (thanks to [maxmitz](https://github.com/maxmitz))
- Merged "android imm.isAcceptingText() crash fix" [#1827](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1827) (thanks to [AlexDochioiu](https://github.com/AlexDochioiu))
- Merged "fix: chrome tab open failed due to chrome process not running" [#1772](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1772) (thanks to [YumengNevix](https://github.com/YumengNevix))
- Merged "Android - Fix context menu position for pages with horizontal scroll" [#1504](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1504) (thanks to [lrorpilla](https://github.com/lrorpilla))
- Fixed "iOS about:blank popup not loading page" [#1500](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1500)
- Fixed "iOS macOS - This method should not be called on the main thread as it may lead to UI unresponsiveness" [#1678](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1678)
- Fixed iOS and macOS InAppWebView memory leaks

## 6.0.0-beta.25

- Updated `androidx.webkit:webkit` dependency to `1.8.0`
- Updated `androidx.browser:browser` dependency to `1.6.0`
- Merged "feat: InAppLocalhostServer decode assets url when loading them" [#1657](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1657) (thanks to [Nirajn2311](https://github.com/Nirajn2311))
- Merged "fix: xcode 15 related bug" [#1801](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1801) (thanks to [nesquikm](https://github.com/nesquikm))

## 6.0.0-beta.24+1

- Fixed "Can't compile on Android" [#1691](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1691)

## 6.0.0-beta.24

- Added InAppWebView keep alive feature
- Added InAppBrowser menu items feature
- Added `hasJavaScriptHandler`, `hasUserScript`, `hasWebMessageListener` InAppWebViewController methods
- Added `hideCloseButton`, `hideDefaultMenuItems`, `menuButtonColor` InAppBrowser settings
- `HeadlessInAppWebView.webViewController` could be `null`
- Removed `throwIfAlreadyOpened`, `throwIfNotOpened` InAppBrowser methods
- Removed `throwIfAlreadyOpened`, `throwIfNotOpened` ChromeSafariBrowser methods
- Merged "fix #1389 #1315 contextMenu ios 13" [#1575](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1575) (thanks to [heralight](https://github.com/heralight))
- Merged "fix: remove ignored flutter_export_environment.sh" [#1593](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1593) (thanks to [Sunbreak](https://github.com/Sunbreak))
- Merged "Fix AndroidX migration URL in README.md" [#1529](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1529) (thanks to [cslee](https://github.com/cslee))
- Merged "InAppBrowser Bugfix/viewgroup index crash" [#1618](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1618) (thanks to [KhatibFX](https://github.com/KhatibFX))
- Fixed old iOS versions crash "dyld: Library not loaded: /usr/lib/swift/libswiftCoreGraphics.dylib Reason: image not found" (thanks to [guide-flutter](https://github.com/guide-flutter))
- Fixed `InAppBrowser.show()` possible crash on macOS
- Fixed missing `windowTitlebarSeparatorStyle`, `windowAlphaValue`, `windowStyleMask`, `windowFrame` macOS settings updates when using `setSettings()`
- Fixed "iOS and macOS flutter multiple engine" [#1632](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1632)

## 6.0.0-beta.23

- Updated `androidx.webkit:webkit` dependency to `1.6.1`
- Updated `androidx.browser:browser` dependency to `1.5.0`
- Updated `androidx.appcompat:appcompat` dependency to `1.6.1`
- Added support for Android `WebViewFeature.GET_COOKIE_INFO`
- Added `requestedWithHeaderOriginAllowList` WebView setting for Android
- Added `isInspectable`, `shouldPrintBackgrounds` WebView settings for iOS and macOS
- Removed `WebViewFeature.REQUESTED_WITH_HEADER_CONTROL`, `ServiceWorkerController.setRequestedWithHeaderMode()`, `ServiceWorkerController.getRequestedWithHeaderMode()`, `InAppWebViewSettings.requestedWithHeaderMode`
- Fixed "Build fail with AGP 8.0" [#1643](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1643)
- Fixed "java.lang.RuntimeException: Unknown feature REQUESTED_WITH_HEADER_CONTROL" [#1611](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1611)
- Fixed "iOS 16.4 WebDebugging WKWebView.isInspectable" [#1629](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1629)
- Fixed some `@available` checks for macOS

## 6.0.0-beta.22

- Updated `window.flutter_inappwebview.callHandler` implementation: if there is an error/exception on Flutter/Dart side, the `callHandler` will reject the JavaScript promise with the error/exception message, so you can catch it also on JavaScript side
- Fixed Android Web Storage Manager `deleteAllData` and `deleteOrigin` methods implementation
- Fixed "Xiaomi store - Conflict of Privacy Permissions, android.permission.MY_READ_INSTALLED_PACKAGES" [#1462](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1462)
- Fixed "Flutter 3.0.5 compilation issue" [#1475](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1475)

## 6.0.0-beta.21

- Fixed "Android plugin version 6 - UserScripts not executing on new tabs." [#1455](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1455)

## 6.0.0-beta.20

- Using Android `WebViewClientCompat` for Chromium-based WebView if the WebView package major version is >= 73 (https://bugs.chromium.org/p/chromium/issues/detail?id=925887)
- Updated code docs
- Fixed "Unexpected addWebMessageListener behaviour" [#1422](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1422)

## 6.0.0-beta.19

- Updated code docs
- Fixed "Cannot Grant Permission at Android 21" [#1447](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1447)
- Fixed some missing macOS asserts

## 6.0.0-beta.18

- Fixed `InAppWebViewSettings` automatic infer if `initialSettings` is `null`

## 6.0.0-beta.17

- Replaced `Uri.encodeFull` with `Uri.encodeComponent` to load html data correctly on Web platform 

## 6.0.0-beta.16

- Removed Android Hybrid Composition constraint to use the pull-to-refresh feature
- Removed Android `com.squareup.okhttp3:okhttp` dependency

## 6.0.0-beta.15

- Automatically infer `useShouldOverrideUrlLoading`, `useOnLoadResource`, `useOnDownloadStart`, `useShouldInterceptAjaxRequest`, `useShouldInterceptFetchRequest`, `useShouldInterceptRequest`, `useOnRenderProcessGone`, `useOnNavigationResponse` settings if their value is `null` and the corresponding event is implemented by the WebView (`InAppWebView` and `HeadlessInAppWebView`, not `InAppBrowser`) before it's native initialization

### BREAKING CHANGES

- All `PrintJobSettings` properties are optionals
- All `PullToRefreshSettings` properties are optionals
- All `WebAuthenticationSessionSettings` properties are optionals

## 6.0.0-beta.14

- Fixed User Script remove methods
- Fixed macOS available checks for XCode 14.1

## 6.0.0-beta.13

- Added `ContentBlockerActionType.BLOCK_COOKIES` and `ContentBlockerActionType.IGNORE_PREVIOUS_RULES` for iOS and macOS platforms
- Updated `ContentBlockerTrigger.urlFilterIsCaseSensitive` for Android
- Fixed Android `ContentBlockerActionType.CSS_DISPLAY_NONE` usage

## 6.0.0-beta.12

- Removed `willSuppressErrorPage` WebView Android setting in favor of `disableDefaultErrorPage`.
- Added `isMultiProcessEnabled` static method on `InAppWebViewController` for Android
- Added `onContentSizeChanged` WebView event for iOS
- Added `onPermissionRequestCanceled`, `onRequestFocus` WebView events for Android
- Added `defaultVideoPoster` WebView setting for Android
- Added `TracingController` for Android WebViews

### BREAKING CHANGES

- Removed `willSuppressErrorPage` WebView Android setting. Use `disableDefaultErrorPage` instead.

## 6.0.0-beta.11

- Fixed "[webRTC / macOS] onPermissionRequest not called on HeadlessInAppWebView" [#1405](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1405)

## 6.0.0-beta.10

- Created `WebUri` class to replace `Uri` dart core type. Related to:
  - "Uri.tryParse will make the host to be lowercase" [#1402](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1402)
  - "An error occurs when using a specific intent" [#1328](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1328)
  - "Android shouldOverrideUrlLoading not working" [#1350](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1350)

### BREAKING CHANGES

- Replaced the usage of `Uri` type with the new `WebUri` type

## 6.0.0-beta.9

- Added `headers`, `otherLikelyURLs`, `referrer` arguments on `ChromeSafariBrowser.open` method for Android
- Added `onNavigationEvent`, `onServiceConnected`, `onRelationshipValidationResult` events on `ChromeSafariBrowser` for Android
- Added `mayLaunchUrl`, `launchUrl`, `updateActionButton`, `validateRelationship`, `setSecondaryToolbar`, `updateSecondaryToolbar` methods on `ChromeSafariBrowser` for Android
- Added `startAnimations`, `exitAnimations`, `navigationBarColor`, `navigationBarDividerColor`, `secondaryToolbarColor`, `alwaysUseBrowserUI` ChromeSafariBrowser settings for Android
- Added `getMaxToolbarItems` static method on `ChromeSafariBrowser` for Android
- Added `ChromeSafariBrowserMenuItem.image` property for iOS
- Added `didLoadSuccessfully` optional argument on `ChromeSafariBrowser.onCompletedInitialLoad` event for iOS
- Added `onInitialLoadDidRedirect`, `onWillOpenInBrowser` events on `ChromeSafariBrowser` for iOS
- Added `activityButton`, `eventAttribution` ChromeSafariBrowser settings for iOS
- Added `clearWebsiteData`, `prewarmConnections`, `invalidatePrewarmingToken` static methods on `ChromeSafariBrowser` for iOS
- Added `getVariationsHeader` WebView static method

### BREAKING CHANGES

- `ChromeSafariBrowser.onCompletedInitialLoad` event has an optional argument
- `ChromeSafariBrowserMenuItem.action` and `ChromeSafariBrowserActionButton.action` can be null
- All `ChromeSafariBrowserSettings` properties are optionals

## 6.0.0-beta.8

- Merged "Exposed "shared" property of HttpServer bind method to support more use-cases." [#1395](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1395) (thanks to [LugonjaAleksandar](https://github.com/LugonjaAleksandar))
- Fixed "ios 14.5 crash reports upgradeKnownHostsToHTTPS" [#1393](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1393)

## 6.0.0-beta.7

- Updated Android hybrid composition implementation

### BREAKING CHANGES

- Minimum Flutter version `3.0.0`

## 6.0.0-beta.6

- Added `InAppWebViewSettings.allowBackgroundAudioPlaying` for Android
- Added `WebViewAssetLoader` and `InAppWebViewSettings.webViewAssetLoader` for Android

### BREAKING CHANGES

- `WebResourceResponse.contentType` and `WebResourceResponse.contentEncoding` properties can be null

## 6.0.0-beta.5

- Merge fixes of version `5.5.0+5`

## 6.0.0-beta.4

- Added `InAppWebView.headlessWebView` property to convert an `HeadlessWebView` to `InAppWebView` widget

## 6.0.0-beta.3

- Added MacOS support
- Added `windowType`, `windowAlphaValue`, `windowStyleMask`, `windowTitlebarSeparatorStyle`, `windowFrame` for MacOS `InAppBrowserSettings`
- Added `PrintJobInfo.printer`
- Added `getContentWidth` WebView method

### BREAKING CHANGES

- Removed `PrintJobInfo.printerId`
- All `InAppWebViewSettings`, `InAppBrowserSettings` properties are optionals
- `InAppBrowser.webViewController` can be null

## 6.0.0-beta.2

- Fixed web example
- Fixed export library 

## 6.0.0-beta.1

- Deprecated old classes/properties/methods to make them eventually compatible with other Platforms and WebView engines.
- Added Web support
- Added `ProxyController` for Android
- Added `PrintJobController` to manage print jobs
- Added `WebAuthenticationSession` for iOS
- Added `FindInteractionController` for Android and iOS
- Added `pauseAllMediaPlayback`, `setAllMediaPlaybackSuspended`, `closeAllMediaPresentations`, `requestMediaPlaybackState`, `isInFullscreen`, `getCameraCaptureState`, `setCameraCaptureState`, `getMicrophoneCaptureState`, `setMicrophoneCaptureState`, `loadSimulatedRequest` WebView controller methods
- Added `underPageBackgroundColor`, `isTextInteractionEnabled`, `isSiteSpecificQuirksModeEnabled`, `upgradeKnownHostsToHTTPS`, `forceDarkStrategy`, `willSuppressErrorPage`, `algorithmicDarkeningAllowed`, `requestedWithHeaderMode`, `enterpriseAuthenticationAppLinkPolicyEnabled`, `isElementFullscreenEnabled`, `isFindInteractionEnabled`, `minimumViewportInset`, `maximumViewportInset` WebView settings
- Added `onCameraCaptureStateChanged`, `onMicrophoneCaptureStateChanged` WebView events
- Added support for `onPermissionRequest` event on iOS 15.0+
- Added `debugLoggingSettings` static property for WebView and ChromeSafariBrowser
- Added `WebViewFeature.DOCUMENT_START_SCRIPT` Android feature support
- Added `getRequestedWithHeaderMode`, `setRequestedWithHeaderMode` ServiceWorkerController methods
- Added `ContentBlockerTrigger.ifFrameUrl` and `ContentBlockerTrigger.loadContext` properties
- Added `PullToRefreshController.isEnabled` method
- Updated `getMetaThemeColor` on iOS 15.0+
- Deprecated `onLoadError` for `onReceivedError`. `onReceivedError` will be called also for subframes
- Deprecated `onLoadHttpError` for `onReceivedHttpError`. `onReceivedHttpError` will be called also for subframes

### BREAKING CHANGES

- Updated Android `minSdkVersion` to `19`
- Updated minimum iOS version to `9.0`
- On Android, the `InAppWebView` widget uses hybrid composition by default (`useHybridComposition: true`)
- All properties of `GeolocationPermissionShowPromptResponse` cannot be `null`
- Removed `URLProtectionSpace.iosIsProxy` property
- `historyUrl` and `baseUrl` of `InAppWebViewInitialData` can be `null`

## 5.8.0

- Merged "fix: xcode 15 related bug" [#1790](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1790) (thanks to [nesquikm](https://github.com/nesquikm))

## 5.7.2+3

- Fixed "Xiaomi store - Conflict of Privacy Permissions, android.permission.MY_READ_INSTALLED_PACKAGES" [#1462](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1462)

## 5.7.2+2

- Fixed "Unexpected addWebMessageListener behaviour" [#1422](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1422)

## 5.7.2+1

- Fixed "Cannot Grant Permission at Android 21" [#1447](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1447)

## 5.7.2

- Removed Android Hybrid Composition constraint to use the pull-to-refresh feature

## 5.7.1+2

- Fixed Android `NullPointerException` on `InAppBrowserActivity.dispose`

## 5.7.1+1

- Fixed User Script remove methods
- Fixed missing `break` statement on Android when parsing `ChromeCustomTabsOptions.displayMode` in Java code

## 5.7.1

- Exposed "shared" property of HttpServer bind method to support more use-cases. (thanks to [LugonjaAleksandar](https://github.com/LugonjaAleksandar))

## 5.7.0

- Added `PlatformViewsService.initExpensiveAndroidView` for Android

### BREAKING CHANGES

- Flutter minimum version `3.0.0`

## 5.6.0+2

- Revert back the usage of `PlatformViewsService.initExpensiveAndroidView`

## 5.6.0+1

- Fixed Android hybrid composition on Flutter 2

## 5.6.0

- Fixed "URLCredential.fromMap returns null for username" [#1205](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1205)
- Fixed "Compare to webview_flutter, inappwebview is significant frame dropped while page scrolling" [#1386](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1386)
- Merged "Fix hybrid composition laggy" [#1387](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1387) (thanks to [Doflatango](https://github.com/Doflatango))

## 5.5.0+5

- Fixed `HeadlessInAppWebView` default size on Android
- Fixed "🐞[Android] execution of the workmanager destroys in_app_webview library's platform channel" [#1348](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1348)
- Fixed "HeadlessInAppWebView called from WorkManager background task triggers NullPointerException on missing context" [#912](https://github.com/pichillilorenzo/flutter_inappwebview/issues/912)

## 5.5.0+4

- Fixed "Many crashes on iOS: Completion handler was not called" [#1221](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1221)
- Fixed "webView:didReceiveAuthenticationChallenge:completionHandler" [#1128](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1128)
- Merged "Fix missing import for Flutter 2.8.1" [#1381](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1381) (thanks to [chandrabezzo](https://github.com/chandrabezzo))

## 5.5.0+3

- Fixed iOS `toolbarTopTintColor` InAppBrowser option
- Fixed iOS `InAppBrowserOptions.hideProgressBar` when getting options
- Fixed missing implementation `InAppBrowser.isHidden` method on Android and iOS
- Fixed "Attempt to invoke virtual method 'java.lang.String android.webkit.WebView.getUrl()' on a null object reference" [#1324](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1324)
- Fixed "(Crash) NullPointerException at in_app_browser.InAppBrowserActivity.close' on a null object reference" [#1278](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1278)
- Fixed "ios system version parser error" [#1355](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1355)
- Removed unnamed constructors for all Singleton classes to avoid incorrect usage

## 5.5.0+2

- Fixed README

## 5.5.0+1

- Fixed README

## 5.5.0

- Added Android direct camera capture feature
- Fixed missing `PullToRefreshController.isRefreshing` iOS implementation
- Fixed Android `PullToRefreshController.setEnabled` at runtime
- Fixed iOS `findNext`
- Fixed Android `RendererPriorityPolicy.waivedWhenNotVisible` type 'Null' is not a subtype of type 'bool'
- Fixed iOS 14.0 crash when calling `callAsyncJavaScript` method
- Merged "Android fix leaking MethodChannel through anonymous class" [#1201](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1201) (thanks to [emakar](https://github.com/emakar))
- Merged "Fix RangeError: Maximum call stack size exceeded" [#1208](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1208) (thanks to [liasica](https://github.com/liasica))
- Merged "fix: try to open with Chrome if default browser app does not support custom tabs" [#1233](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1233) (thanks to [addie9000](https://github.com/addie9000))
- Merged "fix: Prevent Android java.lang.NullPointerException in InAppWebViewCl…" [#1237](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1237) (thanks to [kamilpowalowski](https://github.com/kamilpowalowski))
- Merged "Android - Load client certificate from local storage" [#1241](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1241) (thanks to [akioyamamoto1977](https://github.com/akioyamamoto1977))
- Merged "fix Theme_AppCompat_Dialog_Alert not found" [#1262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1262) (thanks to [mohenaxiba](https://github.com/mohenaxiba))
- Merged "Allow a cookie without a domain to be set on Android" [#1295](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1295) (thanks to [bagedevimo](https://github.com/bagedevimo))
- Merged "Catch and ignore utf8 format exception in getFavicons()" [#1302](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1302) (thanks to [Doflatango](https://github.com/Doflatango))
- Merged "Disable exporting activity definitions for Android" [#1313](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1313) (thanks to [daanporon](https://github.com/daanporon))
- Merged "Add directoryIndex and documentRoot to InAppLocalhostServer option" [#1319](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1319) (thanks to [fa0311](https://github.com/fa0311))
- Merged "fix(ios): invoke onBrowserCreated when viewDidLoad is called with win…" [#1344](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1344) (thanks to [perffecto](https://github.com/perffecto))

### BREAKING CHANGES

- `CookieManager.getCookie`, `CookieManager.deleteCookie` and `CookieManager.deleteCookies` have the `domain` argument optional and without a default value

## 5.4.4+3

- Removed Android unsafe trust manager

## 5.4.4+2

- Fixed LICENSE

## 5.4.4+1

- Fixed README

## 5.4.4

- Added support for Android 33
- Fixed possible null pointer exception in Android `ChromeCustomTabsActivity.java`

## 5.4.3+8

- Merged "Xcode 14 build error: Stored properties cannot be marked potentially unavailable with '@available'" [#1238](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1238) (thanks to [CodeEagle](https://github.com/CodeEagle))
- Fixed example for iOS

## 5.4.3+7

- Fixed possible Android java.lang.NullPointerException in "InAppBrowserActivity.onCreateOptionsMenu" about "webView.getTitle()"

## 5.4.3+6

- Fixed "iOS flutter_inappwebview/URLRequest.swift:13: Fatal error: Unexpectedly found nil while unwrapping an Optional value" [#1173](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1173)

## 5.4.3+5

- Fixed possible java.lang.NullPointerException in `Runnable` of `InputAwareWebView.setInputConnectionTarget` method
- Fixed "Android Crash in latest 5.4.3+4 - java.lang.NullPointerException: Attempt to invoke virtual method java.lang.String android.webkit.WebView.getUrl()" [#1168](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1168)

## 5.4.3+4

- Updated docs for `ChromeSafariBrowser.open` and throw error on iOS if the `url` parameter use a different scheme then `http` or `https`

## 5.4.3+3

- Fixed "Android error: package org.jetbrains.annotations does not exist import org.jetbrains.annotations.NotNull;" [#1166](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1166)

## 5.4.3+2

- Fixed "Latest version 5.4.3 crashes on Android" [#1159](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1159)

## 5.4.3+1

- Try to fix "Latest version 5.4.3 crashes on Android" [#1159](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1159)

## 5.4.3

- Added Bitwise OR operator support for `AndroidActionModeMenuItem` class

## 5.4.2+1

- Try to fix "Latest version 5.4.2 crashes on Android - HeadlessInAppWebView.dispose" [#1155](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1155)

## 5.4.2

- Added `setActionButton` method to `ChromeSafariBrowser` class

## 5.4.1+2

- Fixed "Android ServiceWorkerControllerCompat.setServiceWorkerClient(null) makes Webivew Plugin Crashes" [#1151](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1151)

## 5.4.1+1

- Fixed Android default context menu over custom context menu on API Level 31+ 

## 5.4.1

- Managed iOS native `detachFromEngine` flutter plugin event and updated `dispose` methods
- Updated Android native `HeadlessInAppWebViewManager.dispose` and `HeadlessInAppWebView.dispose` methods

## 5.4.0+3

- Fixed Android error in some cases when calling `setServiceWorkerClient` java method on `ServiceWorkerManager` initialization

## 5.4.0+2

- Fixed Android `ChromeCustomTabsActivity` not responding to the `ActionBroadcastReceiver`

## 5.4.0+1

- Merged "[Android] Explicitly export for the receiver defined in AndroidManifest" [#1147](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1147) (thanks to [AlexV525](https://github.com/AlexV525))

## 5.4.0

- `getOriginalUrl` method is cross-platform now
- Updated Android `compileSdkVersion` to 31
- Updated Flutter environment: sdk to `>=2.14.0 <3.0.0` and flutter version to `>=2.5.0`
- Added `singleInstance` option for Android `ChromeSafariBrowser` implementation
- Added `onDownloadStartRequest` event and deprecated old `onDownloadStart` event
- Added `shareState` Android option for `ChromeSafariBrowser` class
- Added support for Android TWA (Trusted Web Activity)
- Fixed missing `onZoomScaleChanged` call for `InAppBrowser` class
- Fixed `requestImageRef` method always `null` on iOS
- Fixed "applicationNameForUserAgent is not work in ios" [#525](https://github.com/pichillilorenzo/flutter_inappwebview/issues/525)
- Fixed "Crash when try select file from webview input on Android" [#867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/867)
- Fixed "NavigationAction.request should use toMap method" [#878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/878)
- Fixed "Missing body field in URLRequest toMap method" [#990](https://github.com/pichillilorenzo/flutter_inappwebview/issues/990)
- Fixed "iOS : createWindowAction.request.body in onCreateWindow() is NULL" [#994](https://github.com/pichillilorenzo/flutter_inappwebview/issues/994)
- Fixed "Crash at HeadlessInAppWebView dispose" [#881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/881)
- Fixed "Crash happens when HeadlessInAppWebView's dispose function is called in iOS" [#972](https://github.com/pichillilorenzo/flutter_inappwebview/issues/972)
- Fixed "In android, when click a href with img returns img src on onCreateWindow" [#951](https://github.com/pichillilorenzo/flutter_inappwebview/issues/951)
- Fixed "crash at com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView$11.run (InAppWebView.java:1307)" [#1040](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1040)
- Fixed "Unexpected behavior when using a null initialUrlRequest" [#1063](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1063)
- Fixed "Local storage & cookie didn't persist when sharedCookie and cache both enabled" [#1092](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1092)
- Fixed "ios zoomBy crash: Foundation/NSNumber.swift:467: Fatal error: Unable to bridge NSNumber to Float" [#873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/873)
- Fixed "In App Browser Crashing in Android - Action Bar is null" [#1137](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1137)
- Fixed "Cannot load Javascript on some Android devices - Uncaught TypeError: Cannot read property 'appendChild' of null" [#888](https://github.com/pichillilorenzo/flutter_inappwebview/issues/888)
- Merged "Update Options.swift" [#889](https://github.com/pichillilorenzo/flutter_inappwebview/pull/889) (thanks to [cloudygeek](https://github.com/cloudygeek))
- Merged "fix: Applicatio nNameForUserAgent is not working in iOS" [#1095](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1095) (thanks to [sunalwaysknows](https://github.com/sunalwaysknows))
- Merged "Make sure we open a new instance of a custom chrome chrome tab" [#812](https://github.com/pichillilorenzo/flutter_inappwebview/pull/812) (thanks to [savy-91](https://github.com/savy-91))
- Merged "fix bug when in String[] array come null" [#868](https://github.com/pichillilorenzo/flutter_inappwebview/pull/868) (thanks to [Ser1ous](https://github.com/Ser1ous))
- Merged "fix: use in NavigationAction request toMap method" [#879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/879) (thanks to [chreck](https://github.com/chreck))
- Merged "switch android mockserver dependency with okhttp" [#946](https://github.com/pichillilorenzo/flutter_inappwebview/pull/946) (thanks to [randysecrist](https://github.com/randysecrist))
- Merged "Adds missing body to URLRequest mapping." [#991](https://github.com/pichillilorenzo/flutter_inappwebview/pull/991) (thanks to [Miiha](https://github.com/Miiha))
- Merged "fix. Crash happens when HeadlessInAppWebView's dispose function is called in iOS" [#1017](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1017) (thanks to [hoanglm4](https://github.com/hoanglm4))
- Merged "Fixes URL returned when taping image with href in onCreateWindow [Android]" [#1042](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1042) (thanks to [Manuito83](https://github.com/Manuito83))
- Merged "Fix Android Sometimes crash after close webpage and return to platform code." [#1050](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1050) (thanks to [rsydor](https://github.com/rsydor))
- Merged "Add application/wasm MimeType with InAppLocalhostServer" [#1054](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1054) (thanks to [foxstream528](https://github.com/foxstream528))
- Merged "Fixed the unexpected behavior of InAppWebView and HeadlessInAppWebView when initialUrlRequest was set as null." [#1064](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1064) (thanks to [RodXander](https://github.com/RodXander))
- Merged "updated com.android.tools.build:gradle" [#1066](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1066) (thanks to [chownation](https://github.com/chownation))
- Merged "WIP - expose content-disposition and content-length from android" [#1088](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1088) (thanks to [ashank96](https://github.com/ashank96))
- Merged "Fix ios persistance when using sharedCookie" [#1093](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1093) (thanks to [EA-YOUHOU](https://github.com/EA-YOUHOU))
- Merged "Fixes zoomBy with floats (iOS)" [#1109](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1109) (thanks to [Manuito83](https://github.com/Manuito83))
- Merged "Build on and support Android 12 SDK 31" [#1111](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1111) (thanks to [carloserazo47](https://github.com/carloserazo47))
- Merged "Fix takeScreenshot Crash on iOS" [#1123](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1123) (thanks to [a00012025](https://github.com/a00012025))
- Merged "Feature. Possibility to disable iOS above keyboard inputAccessoryView" [#1124](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1124) (thanks to [cutzmf](https://github.com/cutzmf))

## 5.3.2

- Added `onLoad` and `onError` callbacks in `ScriptHtmlTagAttributes` class used by `InAppWebViewController.injectJavascriptFileFromUrl`
- `InAppWebViewController.injectJavascriptFileFromAsset` returns a `Future<dynamic>` type now

## 5.3.1+1

- Removed duplicate lib exports
- Fixed some rare cases when iOS WKWebView `scrollViewDidEndDragging` event blocks the scroll gesture

## 5.3.1

- Added support of `allowingReadAccessTo` iOS-specific WebView option for the WebView `initialData` parameter
- Added `iosAllowingReadAccessTo` iOS-specific parameter to the `loadData` WebView method
- Fixed "iOS webview showing blank page in specific URL" [#776](https://github.com/pichillilorenzo/flutter_inappwebview/issues/776)
- Fixed "unable to access ApplicationDocumentsDirectory in real Ios devices" [#748](https://github.com/pichillilorenzo/flutter_inappwebview/issues/748)

## 5.3.0+1

- Fixed "Android - Pull to refresh triggered when scrolling container inside a website" [#765](https://github.com/pichillilorenzo/flutter_inappwebview/issues/765)
- Fixed "InAppWebViewController.getHitTestResult" wrong type mapping

## 5.3.0

- Added `initialSize` property to the `HeadlessInAppWebView` class
- Added `setSize` and `getSize` methods to the `HeadlessInAppWebView` class
- `androidOnScaleChanged` WebView event is now deprecated. Use the new `onZoomScaleChanged` WebView event, that is available for both Android and iOS
- `getScale` WebView method is now deprecated. Use the new `getZoomScale` WebView method
- Removed `final` keyword for all `HeadlessInAppWebView` events
- Fixed wrong usage of Android WebView scale property
- Fixed "java.lang.NullPointerException: com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewRenderProcessClient$1.success(InAppWebViewRenderProcessClient.java:37)" [#757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/757)
- Fixed "In a multi-activity app, the plugin doesn't reattach to the first activity" [#732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/732)
- Fixed "ChromeSafariBrowser isn't calling its events, and not keeping track of isOpen properly" [#759](https://github.com/pichillilorenzo/flutter_inappwebview/issues/759)
- Fixed Android ChromeSafariBrowser menu item callback not called because of PendingIntents extra were cached

## 5.2.1+1

- Fixed iOS "Unexpectedly found nil while unwrapping an Optional value: file flutter_inappwebview/WKUserContentController.swift, line 36" error when `applePayAPIEnabled` iOS-specific WebView option is enabled

## 5.2.1

- Added `isRunning` method to the `HeadlessInAppWebView` class
- Added `isRunning` method to the `InAppLocalhostServer` class
- Added `allowGoBackWithBackButton` and `shouldCloseOnBackButtonPressed` Android-specific InAppBrowser options
- Fixed iOS `WebMessageListener` javascript implementation not calling event listeners when `onmessage` is set
- Fixed `onCreateContextMenu` event on Android where `hitTestResult` has always `null` values
- Fixed "java.lang.NullPointerException: Attempt to invoke virtual method 'void android.widget.SearchView.setQuery(java.lang.CharSequence, boolean)' on a null object reference" [#742](https://github.com/pichillilorenzo/flutter_inappwebview/issues/742)
- Fixed Android js error in some very rare case where `window.flutter_inappwebview` is `undefined` when loading plugin scripts

## 5.2.0

- Added `WebMessageChannel` and `WebMessageListener` features
- Added `canScrollVertically` and `canScrollHorizontally` webview methods
- Added Android pull-to-refresh `setSize` method and `size` option
- Added `onOverScrolled` WebView event
- `AndroidInAppWebViewController.getCurrentWebViewPackage` is available now starting from Android API 21+
- Updated Android Gradle distributionUrl version to `5.6.4`
- Updated Android `androidx.webkit:webkit` to `1.4.0`, `androidx.browser:browser` to `1.3.0`, `androidx.appcompat:appcompat` to `1.2.0`
- Attempt to fix "InAppBrowserActivity.onCreate NullPointerException - Attempt to invoke virtual method 'java.lang.String android.os.Bundle.getString(java.lang.String)' on a null object reference" [#665](https://github.com/pichillilorenzo/flutter_inappwebview/issues/665)
- Fixed "[iOS] Application crashes when processing onCreateWindow" [#579](https://github.com/pichillilorenzo/flutter_inappwebview/issues/579)
- Fixed wrong mapping of `NavigationAction` class on Android for `androidHasGesture` and `androidIsRedirect` properties
- Fixed "Pull to refresh creating problem in some webpages on Android" [#719](https://github.com/pichillilorenzo/flutter_inappwebview/issues/719)
- Fixed iOS sometimes `scrollView.contentSize` doesn't fit all the `frame.size` available
- Fixed ajax and fetch interceptor when the data/body sent is not a string
- Fixed "InAppLocalhostServer - Error: type 'List<dynamic>' is not a subtype of type 'List<int>' in type cast" [#724](https://github.com/pichillilorenzo/flutter_inappwebview/issues/724)
- Merged "fix proguard" [#737](https://github.com/pichillilorenzo/flutter_inappwebview/pull/737) (thanks to [myroid](https://github.com/myroid))

### BREAKING CHANGES

- `FetchRequest.body` is a dynamic type now

## 5.1.0+4

- Fixed "IOS scrolling crash the application" [#707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/707)

## 5.1.0+3

- Fixed "Unsupported operation: Platform._operatingSystem" when compiling for Web again [#507](https://github.com/pichillilorenzo/flutter_inappwebview/issues/507)

## 5.1.0+2

- Fixed missing MATCH_PARENT layout params to the WebView on Android when it is wrapped by PullToRefreshLayout

## 5.1.0+1

- Added a test for the pull-to-refresh feature when used on Android. It requires the `useHybridComposition: true` Android-specific option, otherwise it will throw an exception.

## 5.1.0

- Added support for pull-to-refresh feature [#395](https://github.com/pichillilorenzo/flutter_inappwebview/issues/395)
- Fixed issue not rendering WebView content when scrolling on iOS [#703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/703)
- Fixed `InAppBrowser.openData` method
- `InAppBrowser.initialUserScripts`, `InAppBrowser.id`, `HeadlessInAppWebView.id` properties are `final` now

## 5.0.5+3

- Fixed Android `evaluateJavascript` method when using `contentWorld: ContentWorld.PAGE`

## 5.0.5+2

- Updated docs for iOS-specific options `alwaysBounceVertical` and `alwaysBounceHorizontal`

## 5.0.5+1

- Fixed "No bounce in inappwebview iOS" [#696](https://github.com/pichillilorenzo/flutter_inappwebview/issues/696)

## 5.0.5

- Updated Android `WebChromeClient.getDefaultVideoPoster`
- Removed all the dependencies: `uuid`, `device_info`, `intl`, and `mime`

## 5.0.4-nullsafety.1

- Added `headers` and `statusCode` properties to IOSURLResponse class

## 5.0.3-nullsafety.1

- Fixed Android screenshot out of memory error
- Fixed `getFavicons` WebView method

## 5.0.2-nullsafety.1

- Fixed missing `verticalScrollbarThumbColor`, `verticalScrollbarTrackColor`, `horizontalScrollbarThumbColor`, `horizontalScrollbarTrackColor` Android-specific WebView options when calling native java `setOptions()` method on Android

## 5.0.1-nullsafety.1

- Added `verticalScrollbarThumbColor`, `verticalScrollbarTrackColor`, `horizontalScrollbarThumbColor`, `horizontalScrollbarTrackColor` Android-specific WebView options
- Fixed some null types and wrong casting

## 5.0.0-nullsafety.0

- Added support for Dart null-safety feature
- Added Android Hybrid Composition support "Use PlatformViewLink widget for Android WebView" [#462](https://github.com/pichillilorenzo/flutter_inappwebview/pull/462) (thanks to [plateaukao](https://github.com/plateaukao) and [tneotia](https://github.com/tneotia))
- Added `allowUniversalAccessFromFileURLs` and `allowFileAccessFromFileURLs` WebView options also for iOS (also thanks to [liranhao](https://github.com/liranhao))
- Added limited cookies support on iOS below 11.0 using JavaScript
- Added `IOSCookieManager` class and `CookieManager.instance().ios.getAllCookies` iOS-specific method
- Added `UserScript`, `UserScriptInjectionTime`, `ContentWorld`, `AndroidWebViewFeature`, `AndroidServiceWorkerController`, `AndroidServiceWorkerClient`, `ScreenshotConfiguration`, `IOSWKPDFConfiguration`, `URLRequest` classes
- Added `initialUserScripts` WebView option
- Added `addUserScript`, `addUserScripts`, `removeUserScript`, `removeUserScripts`, `removeUserScriptsByGroupName`, `removeAllUserScripts`, `callAsyncJavaScript`, `isSecureContext` WebView methods
- Added `contentWorld` argument to `evaluateJavascript` WebView method
- Added `isDirectionalLockEnabled`, `mediaType`, `pageZoom`, `limitsNavigationsToAppBoundDomains`, `useOnNavigationResponse`, `applePayAPIEnabled`, `allowingReadAccessTo`, `disableLongPressContextMenuOnLinks` iOS-specific WebView options
- Added `handlesURLScheme`, `createPdf`, `createWebArchiveData` iOS-specific WebView methods
- Added `iosOnNavigationResponse` and `iosShouldAllowDeprecatedTLS` iOS-specific WebView events
- Added `iosAnimated` optional argument to `zoomBy` WebView method
- Added `screenshotConfiguration` optional argument to `takeScreenshot` WebView method
- Added `scriptHtmlTagAttributes` optional argument to `injectJavascriptFileFromUrl` WebView method
- Added `cssLinkHtmlTagAttributes` optional argument to `injectCSSFileFromUrl` WebView method
- Added `iosAllowingReadAccessTo` iOS-specific optional argument to `loadUrl` WebView method
- Added new iOS-specific attributes to `ShouldOverrideUrlLoadingRequest` and `CreateWindowRequest` classes
- Added `toolbarTopTranslucent`, `toolbarTopTintColor`, `toolbarBottomTintColor`, `toolbarTopBarTintColor` ios-specific InAppBrowser options
- Updated integration tests
- Merged "Upgraded appcompat to 1.2.0-rc-02" [#465](https://github.com/pichillilorenzo/flutter_inappwebview/pull/465) (thanks to [andreidiaconu](https://github.com/andreidiaconu))
- Merged "Added missing field 'headers' which returned by WebResourceResponse.toMap()" [#490](https://github.com/pichillilorenzo/flutter_inappwebview/pull/490) (thanks to [Doflatango](https://github.com/Doflatango))
- Merged "Fix: added iOS fallback module import" [#466](https://github.com/pichillilorenzo/flutter_inappwebview/pull/466) (thanks to [Eddayy](https://github.com/Eddayy))
- Merged "Fix NullPointerException after taking a photo by a camera app on Android" [#492](https://github.com/pichillilorenzo/flutter_inappwebview/pull/492) (thanks to [AAkira](https://github.com/AAkira))
- Merged "iOS CookieManager.getCookies - Check that URL has suffix of cookie do…" [#658](https://github.com/pichillilorenzo/flutter_inappwebview/pull/658) (thanks to [arneke](https://github.com/arneke))
- Merged "Add NTLM Auth" [#634](https://github.com/pichillilorenzo/flutter_inappwebview/pull/634) (thanks to [albatrosify](https://github.com/albatrosify))
- Merged "iOS ChromeSafariBrowserManager - Fixing unnecessary casting of rootViewController to FlutterViewController" [#567](https://github.com/pichillilorenzo/flutter_inappwebview/pull/567) (thanks to [gunantosteven](https://github.com/gunantosteven))
- Merged "Fix _channel.invokeMethod name for injectCSSFileFromUrl method" [#645](https://github.com/pichillilorenzo/flutter_inappwebview/pull/645) (thanks to [omralcrt](https://github.com/omralcrt))
- Merged "Add android media intents on wildcard input accept" [#620](https://github.com/pichillilorenzo/flutter_inappwebview/pull/620) (thanks to [cbodin](https://github.com/cbodin))
- Merged "Add ChromeSafariBrowser support for Android 11" [#538](https://github.com/pichillilorenzo/flutter_inappwebview/pull/538) (thanks to [DRSchlaubi](https://github.com/DRSchlaubi))
- Merged "fix(iOS): missing implementation of method zoomBy" [#670](https://github.com/pichillilorenzo/flutter_inappwebview/pull/670) (thanks to [pcqpcq](https://github.com/pcqpcq))
- Merged "[mod] Fix all issues relate to long click in Android version 7.0 (#657, #527)" [#671](https://github.com/pichillilorenzo/flutter_inappwebview/pull/671) (thanks to [MrNinja](https://github.com/MrNinja))
- Merged "Fix ViewGroup.removeView NullPointerException (#450)" [#683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/683) (thanks to [toda-bps](https://github.com/toda-bps))
- Fixed missing properties initialization when using InAppWebViewController.fromInAppBrowser
- Fixed "Issue in Flutter web: 'Unsupported operation: Platform._operatingSystem'" [#507](https://github.com/pichillilorenzo/flutter_inappwebview/issues/507)
- Fixed "window.flutter_inappwebview.callHandler is not a function" [#218](https://github.com/pichillilorenzo/flutter_inappwebview/issues/218)
- Fixed "Android ContentBlocker - java.lang.NullPointerException ContentBlockerTrigger resource type" [#506](https://github.com/pichillilorenzo/flutter_inappwebview/issues/506)
- Fixed "Android CookieManager throws error caused by websites that are sending back illegal/invalid cookies." [#476](https://github.com/pichillilorenzo/flutter_inappwebview/issues/476)
- Fixed missing `clearHistory` webview method implementation on Android
- Fixed iOS crash when using CookieManager getCookies for an URL and the host URL is `null`
- Fixed "IOS does not support allowUniversalAccessFromFileURLs" [#654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/654)
- Fixed "Failed to load WebView provider: No WebView installed" [#642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/642)
- Fixed "java.net.MalformedURLException: unknown protocol: wss - Error using library sipml5 in flutter_inappwebview" [#614](https://github.com/pichillilorenzo/flutter_inappwebview/issues/614)
- Fixed "Android 10 clipboard not working properly" [#678](https://github.com/pichillilorenzo/flutter_inappwebview/issues/678) (thanks to [armadastate](https://github.com/armadastate))

### BREAKING CHANGES

- Minimum Flutter version required is `1.22.2` and Dart SDK `>=2.12.0-0 <3.0.0`
- iOS Xcode version `>= 12`
- `allowUniversalAccessFromFileURLs` and `allowFileAccessFromFileURLs` WebView options moved from Android-specific options to cross-platform options
- Added `callAsyncJavaScript` name to the list of javaScriptHandlerForbiddenNames
- Moved `saveWebArchive` WebView method from Android-specific to cross-platform
- Moved `progressBar` InAppBroswer from Android-specific option to cross-platform option and renamed to `hideProgressBar`
- Renamed `HttpAuthChallenge` to `URLAuthenticationChallenge`
- Updated `basicConstraints`, `subjectKeyIdentifier`, `authorityKeyIdentifier`, `certificatePolicies`, `cRLDistributionPoints`, `authorityInfoAccess` attributes type of `X509Certificate`
- Updated "WebView.storyboard" for InAppBrowser iOS representation
- Renamed `ShouldOverrideUrlLoadingAction` class to `NavigationActionPolicy`
- Renamed `ProtectionSpace` class to `URLProtectionSpace`
- Renamed `ProtectionSpaceHttpAuthCredentials` to `URLProtectionSpaceHttpAuthCredentials`
- Renamed `CreateWindowRequest` class to `CreateWindowAction`
- Renamed `initialUrl` to `initialUrlRequest` WebView attribute and made it of type `URLRequest`
- Renamed `toolbarTop` InAppBrowser cross-platform option to `hideToolbarTop`
- Renamed `toolbarBottom` InAppBrowser ios-specific option to `hideToolbarBottom`
- Removed `debuggingEnabled` WebView option; on Android you should use now the `AndroidInAppWebViewController.setWebContentsDebuggingEnabled(bool debuggingEnabled)` static method; on iOS, debugging is always enabled
- Removed `androidOnRequestFocus` event because it is never called
- Removed `initialHeaders` WebView attribute. Use `URLRequest.headers` attribute
- Removed `headers` argument from `loadFile` WebView method
- Removed `headers` argument from `openFile` InAppBrowser method
- Removed `headers` argument from `loadUrl` WebView method, renamed the `url` argument to `urlRequest` and made it of type `URLRequest`
- Removed `headers` argument from `openFile` InAppBrowser method
- Removed `headers` argument from `openUrl` InAppBrowser method, renamed the `url` argument to `urlRequest` and made it of type `URLRequest`
- Removed `fallback` argument from `ChromeSafariBrowser` constructor. Check for availability of `ChromeSafariBrowser` if you want show one or the other.
- Removed `scheme` argument from `onLoadResourceCustomScheme` WebView event. Use the `Uri url` parameter now.
- Removed `ShouldOverrideUrlLoadingRequest` class and replaced with `NavigationAction`
- Changed `zoomBy` WebView method signature
- Changed type of `urlFile` argument of `injectCSSFileFromUrl` WebView method to `Uri`
- Changed type of `urlFile` argument of `injectJavascriptFileFromUrl` WebView method to `Uri`
- Changed return type of `getOriginalUrl` Android-specific WebView method to `Uri`
- Changed return type of `getSafeBrowsingPrivacyPolicyUrl` Android-specific WebView method to `Uri`
- Changed type of `url` argument of `onLoadStart`, `onLoadStop`, `onLoadError`, `onLoadHttpError`, `onLoadResourceCustomScheme`, `onUpdateVisitedHistory`, `onPrint`, `onPageCommitVisible`, `androidOnSafeBrowsingHit`, `androidOnRenderProcessUnresponsive`, `androidOnRenderProcessResponsive`, `androidOnFormResubmission`, `androidOnReceivedTouchIconUrl` WebView events to `Uri`
- Changed type of `baseUrl` and `androidHistoryUrl` arguments of `loadData` WebView method and `openData` InAppBrowser method
- Changed `openUrl` InAppBrowser method to `openUrlRequest`
- Changed type of `url` argument of `openWithSystemBrowser` InAppBrowser method to `Uri`
- Changed all InAppBrowser color options type from `String` to `Color`
- Changed all ChromeSafariBrowser color options type from `String` to `Color`
- Updated attributes of `ShouldOverrideUrlLoadingRequest`, `ServerTrustChallenge` and `ClientCertChallenge` classes
- Changed type of `url` attribute to `Uri` for `JsAlertRequest`, `JsAlertConfirm`, `JsPromptRequest` classes

## 4.0.0+4

- Reverted calling `handler.post` on Android when a WebView is created
- Fixed iOS extra bottom padding when opening the keyboard
- Fixed "Build for web not working – The integer literal 9223372036854775807 can't be represented exactly in JavaScript" [#429](https://github.com/pichillilorenzo/flutter_inappwebview/issues/429)
- Fixed iOS userContentController didReceive WKScriptMessage event when using a WebView created with a `windowId`

## 4.0.0

- Updated `onCreateWindow`, `onJsAlert`, `onJsConfirm`, `onJsPrompt` webview events
- Added `onCloseWindow`, `onTitleChanged`, `onWindowFocus`, `onWindowBlur` webview events
- Added `androidOnRequestFocus`, `androidOnReceivedIcon`, `androidOnReceivedTouchIconUrl`, `androidOnJsBeforeUnload`, `androidOnReceivedLoginRequest` Android-specific webview events
- Added `disableDefaultErrorPage` Android-specific webview option
- Added `isAvailable` ChromeSafariBrowser static method
- Fixed "SFSafariViewController doesn't open like a native iOS modal" [#403](https://github.com/pichillilorenzo/flutter_inappwebview/issues/403)

### BREAKING CHANGES

- Updated `onCreateWindow`, `onJsAlert`, `onJsConfirm`, `onJsPrompt` webview event
- Renamed `OnCreateWindowRequest` class to `CreateWindowRequest`

## 3.4.0+2

- Reverted default `InAppWebView.gestureRecognizers` value to null on Android

## 3.4.0+1

- Updated README.md
- Updated missing docs
- Fixed pub.dev Health suggestions and Analysis suggestions

## 3.4.0

- Added `requestFocusNodeHref`, `requestImageRef`, `getMetaTags`, `getMetaThemeColor`, `getScrollX`, `getScrollY`, `getCertificate` webview methods
- Added `WebStorage`, `LocalStorage` and `SessionStorage` class to manage `window.localStorage` and `window.sessionStorage` JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
- Added `supportZoom` webview option also on iOS
- Added `HttpOnly`, `SameSite` cookie options
- Updated `Cookie` class
- Added `animated` option to `scrollTo` and `scrollBy` webview methods
- Added error and message to the `ServerTrustChallenge` class for iOS (class used by the `onReceivedServerTrustAuthRequest` event)
- Added `contentInsetAdjustmentBehavior` webview iOS-specific option
- Added `copy` methods for webview options class
- Added `SslCertificate` class and `X509Certificate` class and parser
- Added `values` property for all the custom Enums
- Updated Android workaround to hide the Keyboard when the user click outside on something not focusable such as input or a textarea.
- Fixed `zoomBy`, `setOptions` webview methods on Android
- Fixed `databaseEnabled` android webview option default value to `true`
- Fixed `verticalScrollBarEnabled` and `horizontalScrollBarEnabled` on Android
- Fixed error caused by `pauseTimers` on iOS when the WebView has been disposed
- Fixed `ignoresViewportScaleLimits`, `dataDetectorTypes`, `suppressesIncrementalRendering`, `selectionGranularity` iOS-specific option when used in `initialOptions`
- Fixed `getFavicons` method
- Fixed `HttpAuthCredentialDatabase.removeHttpAuthCredential` on Android
- Fixed some cases where `takeScreenshot` was not working on Android
- Fixed `After upgrade to Android embedding V2, still get Shared.activity is null / NullPointerException on android.content.Context.getResources()` [#390](https://github.com/pichillilorenzo/flutter_inappwebview/issues/390)

### BREAKING CHANGES

- `evaluateJavascript` webview method now returns `null` on iOS if the evaluated JavaScript source returns `null`
- `getHtml` webview method now could return `null` if it was unable to get it.
- Moved `supportZoom` webview option to cross-platform
- `builtInZoomControls` android webview options changed default value to `true`
- Updated `ServerTrustChallenge` class used by the `onReceivedServerTrustAuthRequest` event
- The method `getOptions` could return null now
- Updated `HttpAuthCredentialDatabase.getAllAuthCredentials` method return type

## 3.3.0+3

- Updated Android build.gradle version and some androidx properties
- Fixed `Multiple sessions` [#371](https://github.com/pichillilorenzo/flutter_inappwebview/issues/371)
- Fixed `incognito mode is broken swift` [#320](https://github.com/pichillilorenzo/flutter_inappwebview/issues/320)

## 3.3.0

- Updated API docs
- Updated Android context menu workaround
- Calling `onCreateContextMenu` event on iOS also when the context menu is disabled in order to have the same effect as Android
- Added `options` attribute to `ContextMenu` class and created `ContextMenuOptions` class
- Added Android keyboard workaround to hide the keyboard when clicking other HTML elements, losing the focus on the previous input
- Added `onEnterFullscreen`, `onExitFullscreen` webview events [#275](https://github.com/pichillilorenzo/flutter_inappwebview/issues/275)
- Added Android support to use camera on HTML inputs that requires it, such as `<input type="file" accept="image/*" capture>` [#353](https://github.com/pichillilorenzo/flutter_inappwebview/issues/353)
- Added `overScrollMode`, `networkAvailable`, `scrollBarStyle`, `verticalScrollbarPosition`, `scrollBarDefaultDelayBeforeFade`, `scrollbarFadingEnabled`, `scrollBarFadeDuration`, `rendererPriorityPolicy`, `useShouldInterceptRequest`, `useOnRenderProcessGone` webview options on Android
- Added `pageDown`, `pageUp`, `saveWebArchive`, `zoomIn`, `zoomOut`, `clearHistory` webview methods on Android
- Added `getCurrentWebViewPackage` static webview method on Android
- Added `setContextMenu`, `clearFocus` methods to webview controller
- Added `onPageCommitVisible` webview event
- Added `androidShouldInterceptRequest`, `androidOnRenderProcessUnresponsive`, `androidOnRenderProcessResponsive`, `androidOnRenderProcessGone`, `androidOnFormResubmission`, `androidOnScaleChanged` Android events
- Added `toString()` method to various classes in order to have a better output instead of simply `Instance of ...`
- Fixed `Print preview is not working? java.lang.IllegalStateException: Can print only from an activity` [#128](https://github.com/pichillilorenzo/flutter_inappwebview/issues/128)
- Fixed `onJsAlert`, `onJsConfirm`, `onJsPrompt` for `InAppBrowser` on Android
- Fixed `onActivityResult` for `InAppBrowser` on Android
- Fixed `InAppBrowser.openWithSystemBrowser crash on iOS` [#358](https://github.com/pichillilorenzo/flutter_inappwebview/issues/358)
- Fixed `Attempt to invoke virtual method 'java.util.Set java.util.HashMap.entrySet()' on a null object reference` [#367](https://github.com/pichillilorenzo/flutter_inappwebview/issues/367)
- Fixed missing `allowsAirPlayForMediaPlayback` iOS webview options implementation

### BREAKING CHANGES

- Android `clearClientCertPreferences`, `getSafeBrowsingPrivacyPolicyUrl`, `setSafeBrowsingWhitelist` webview methods are static now
- Removed iOS event `onDidCommit`; it has been renamed to `onPageCommitVisible` and made cross-platform
- `contextMenu` webview attribute is `final` now

## 3.2.0

- Added `ContextMenu` and `ContextMenuItem` classes [#235](https://github.com/pichillilorenzo/flutter_inappwebview/issues/235)
- Added `onCreateContextMenu`, `onHideContextMenu`, `onContextMenuActionItemClicked` context menu events
- Added `contextMenu` to WebView
- Added `disableContextMenu` WebView option
- Added `getSelectedText`, `getHitTestResult` methods to WebView Controller
- Fixed `Confirmation dialog (onbeforeunload) displayed after popped from webview page` [#337](https://github.com/pichillilorenzo/flutter_inappwebview/issues/337)
- Fixed `CookieManager.setCookie` `expiresDate` option
- Fixed `Scrolling not smooth on iOS` [#341](https://github.com/pichillilorenzo/flutter_inappwebview/issues/341)

### BREAKING CHANGES

- Renamed `LongPressHitTestResult` to `InAppWebViewHitTestResult`.
- Renamed `LongPressHitTestResultType` to `InAppWebViewHitTestResultType`.

## 3.1.0

- Added `HeadlessInAppWebView` class to be able to use WebView in headless mode
- Added `close`, `addMenuItem`, `addMenuItems` methods to `ChromeSafariBrowser`
- Added `ChromeSafariBrowserMenuItem` class in order to create custom menu item for `ChromeSafariBrowser`
- Fixed `InAppWebView.channel` null when used by `InAppBrowserActivity` on android
- Fixed iOS presentationStyle affecting only dismiss animation [#305](https://github.com/pichillilorenzo/flutter_inappwebview/issues/305)

### BREAKING CHANGES

- Renamed `InAppWebViewWidgetOptions` to `InAppWebViewGroupOptions`.

## 3.0.0

- Added `Promise` javascript [polyfill](https://github.com/tildeio/rsvp.js) for webviews that doesn't support it for `window.flutter_inappwebview.callHandler`
- Added `getDefaultUserAgent` static method to `InAppWebViewController`
- Added `onUpdateVisitedHistory`, `onPrint`, `onLongPressHitTestResult` event
- Added `androidOnGeolocationPermissionsHidePrompt` event for Android webview
- Added `iosOnWebContentProcessDidTerminate`, `iosOnDidCommit`, `iosOnDidReceiveServerRedirectForProvisionalNavigation` events for iOS webview
- Added `supportMultipleWindows` webview option for Android
- Added `regexToCancelSubFramesLoading` webview option for Android to cancel subframe requests on `shouldOverrideUrlLoading` event based on a Regular Expression
- Added `getContentHeight`, `zoomBy`, `printCurrentPage`, `getScale` methods
- Added `getOriginalUrl` webview method for Android
- Added `reloadFromOrigin`, `hasOnlySecureContent` webview methods for iOS
- Added `automaticallyAdjustsScrollIndicatorInsets`, `accessibilityIgnoresInvertColors`, `decelerationRate`, `alwaysBounceVertical`, `alwaysBounceHorizontal`, `scrollsToTop`, `isPagingEnabled`, `maximumZoomScale`, `minimumZoomScale` webview options for iOS
- Added `WebStorageManager` class which manages the web storage used by WebView instances
- Added `packageName` [#229](https://github.com/pichillilorenzo/flutter_inappwebview/issues/229) and `keepAliveEnabled` ChromeCustomTab options for Android
- Updated for Flutter 1.12 new Java Embedding API (Android)
- Updated `clearCache` for Android
- Updated default value for `domStorageEnabled` and `databaseEnabled` options to `true` for Android
- Merged "Fixes null error when calling getOptions for InAppBrowser class" [#214](https://github.com/pichillilorenzo/flutter_inappwebview/pull/214) (thanks to [panndoraBoo](https://github.com/panndoraBoo))
- Merged "Fixes crash onConsoleMessage iOS forced unwrapping" [#228](https://github.com/pichillilorenzo/flutter_inappwebview/pull/228) (thanks to [tokonu](https://github.com/tokonu))
- Merged "Fix HTTPCookie.secure" [#311](https://github.com/pichillilorenzo/flutter_inappwebview/pull/311) (thanks to [xtyxtyx](https://github.com/xtyxtyx))
- Merged "Fix config options for Android release builds" [#295](https://github.com/pichillilorenzo/flutter_inappwebview/pull/295) (thanks to [wwwdata](https://github.com/wwwdata))
- Merged "fix scrollbar on iOS always show if not disable scroll" [#256](https://github.com/pichillilorenzo/flutter_inappwebview/pull/256) (thanks to [phamnhuvu-dev](https://github.com/phamnhuvu-dev))
- Merged "Fix crash on nil/invalid URL (iOS)" [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/262) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merged "Fix crash when `prompt` was called on Android Q." [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/263) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Fix for Android and iOS `InAppBrowser` for some controller methods not exposed.
- Fixed "App Crashes after clicking on dropdown (Using inappwebview)" [#182](https://github.com/pichillilorenzo/flutter_inappwebview/issues/182)
- Fixed "webview can not be released when in ios" [#225](https://github.com/pichillilorenzo/flutter_inappwebview/issues/225). Now the iOS WebView is released from memory when it is disposed from Flutter.
- Fixed "Setting of presentationStyle not working on iOS" [#213](https://github.com/pichillilorenzo/flutter_inappwebview/issues/213)
- Fixed "Android zoom issues" [#270](https://github.com/pichillilorenzo/flutter_inappwebview/issues/270)

### BREAKING CHANGES

- Updated `shouldOverrideUrlLoading` event: 
  - the `url` parameter has been moved inside an instance of `ShouldOverrideUrlLoadingRequest` class
  - it has a return type `ShouldOverrideUrlLoadingAction` to allow or cancel navigation instead of cancel every time the request
- Renamed `onTargetBlank` to `onCreateWindow`
- Deleted `useOnTargetBlank` webview option
- Making methods available only for the specific platform more explicit: moved all the webview's controller methods for Android inside `controller.android` and all the webview's controller methods for iOS inside `controller.ios`
- Making events available only for the specific platform more explicit:
  - Renamed `onSafeBrowsingHit` to `androidOnSafeBrowsingHit`
  - Renamed `onGeolocationPermissionsShowPrompt` to `androidOnGeolocationPermissionsShowPrompt` 
  - Renamed `onPermissionRequest` to `androidOnPermissionRequest`  
- Updated attribute names for `InAppWebViewWidgetOptions`, `InAppBrowserClassOptions` and `ChromeSafariBrowserClassOptions` classes
- Renamed and updated `onNavigationStateChange` to `onUpdateVisitedHistory`
- Renamed all iOS and Android webview options class
- Renamed Chrome Custom Tab `addShareButton` option to `addDefaultShareMenuItem`
- Renamed ChromeSafariBrowser `onLoaded` to `onCompletedInitialLoad`

## 2.1.0+1

- Fix docs

## 2.1.0

- Added `pause` and `resume` methods for Android.
- Added `pauseTimers` and `resumeTimers` methods.
- Added new `historyUrl` optional parameter for `loadData` and `openData` methods and `InAppWebViewInitialData` class. It is used only on Android.
- Fix "problems with onReceivedHttpAuthRequest when initialData is used" [#201](https://github.com/pichillilorenzo/flutter_inappwebview/issues/201)
- Fix "System ui (status bar and navigation bar) doesn't hide automatically" [#202](https://github.com/pichillilorenzo/flutter_inappwebview/issues/202)

## 2.0.1+1

- Fixed error "java.lang.ClassCastException: $Proxy1 cannot be cast to android.view.WindowManagerImpl" on Android when using native alert dialogs

## 2.0.1

- Added `onPermissionRequest` event. This event is fired when the webview is requesting permission to access the specified resources and the permission currently isn't granted or denied (available only on Android).

## 2.0.0

- Merged "Avoid null pointer exception after webview is disposed" [#116](https://github.com/pichillilorenzo/flutter_inappwebview/pull/116) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merged "Remove async call in close" [#119](https://github.com/pichillilorenzo/flutter_inappwebview/pull/119) (thanks to [benfingo](https://github.com/benfingo))
- Merged "Android takeScreenshot does not work properly." [#122](https://github.com/pichillilorenzo/flutter_inappwebview/pull/122) (thanks to [PauloMelo](https://github.com/PauloMelo))
- Merged "Resolving gradle error." [#144](https://github.com/pichillilorenzo/flutter_inappwebview/pull/144) (thanks to [Klingens13](https://github.com/Klingens13))
- Merged "Create issue and pull request templates" [#150](https://github.com/pichillilorenzo/flutter_inappwebview/pull/150) (thanks to [deandreamatias](https://github.com/deandreamatias))
- Merged "Fix abstract method error && swift version error" [#155](https://github.com/pichillilorenzo/flutter_inappwebview/pull/155) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merged "migrating to swift 5.0" [#162](https://github.com/pichillilorenzo/flutter_inappwebview/pull/162) (thanks to [fattiger00](https://github.com/fattiger00))
- Merged "Update readme example" [#178](https://github.com/pichillilorenzo/flutter_inappwebview/pull/178) (thanks to [SebastienBtr](https://github.com/SebastienBtr))
- Merged "handle choose file callback in android" [#183](https://github.com/pichillilorenzo/flutter_inappwebview/pull/183) (thanks to [crazecoder](https://github.com/crazecoder))
- Merged "add initialScale in android" [#186](https://github.com/pichillilorenzo/flutter_inappwebview/pull/186) (thanks to [crazecoder](https://github.com/crazecoder))
- Added `horizontalScrollBarEnabled` and `verticalScrollBarEnabled` options to enable/disable the corresponding scrollbar of the WebView [#165](https://github.com/pichillilorenzo/flutter_inappwebview/issues/165)
- Added `onDownloadStart` event and `useOnDownloadStart` option: event fires when the WebView recognizes and starts a downloadable file.
- Added `onLoadResourceCustomScheme` event and `resourceCustomSchemes` option to set custom schemes that WebView must handle to load resources
- Added `onTargetBlank` event and `useOnTargetBlank` option to manage links with `target="_blank"`
- Added `ContentBlocker`, `ContentBlockerTrigger` and `ContentBlockerAction` classes and the `contentBlockers` option that allows to define a set of rules to use to block content in the WebView
- Added new WebView options: `minimumFontSize`, `debuggingEnabled`, `preferredContentMode`, `applicationNameForUserAgent`, `incognito`, `cacheEnabled`, `disableVerticalScroll`, `disableHorizontalScroll`
- Added new Android WebView options: `allowContentAccess`, `allowFileAccess`, `allowFileAccessFromFileURLs`, `allowUniversalAccessFromFileURLs`, `appCachePath`, `blockNetworkImage`, `blockNetworkLoads`, `cacheMode`, `cursiveFontFamily`, `defaultFixedFontSize`, `defaultFontSize`, `defaultTextEncodingName`, `disabledActionModeMenuItems`, `fantasyFontFamily`, `fixedFontFamily`, `forceDark`, `geolocationEnabled`, `layoutAlgorithm`, `loadWithOverviewMode`, `loadsImagesAutomatically`, `minimumLogicalFontSize`, `needInitialFocus`, `offscreenPreRaster`, `sansSerifFontFamily`, `serifFontFamily`, `standardFontFamily`, `saveFormData`, `thirdPartyCookiesEnabled`, `hardwareAcceleration`
- Added new iOS WebView options: `isFraudulentWebsiteWarningEnabled`, `selectionGranularity`, `dataDetectorTypes`, `sharedCookiesEnabled`
- Added `onGeolocationPermissionsShowPrompt` event and `GeolocationPermissionShowPromptResponse` class (available only for Android)
- Added `startSafeBrowsing`, `setSafeBrowsingWhitelist` and `getSafeBrowsingPrivacyPolicyUrl` methods (available only for Android)
- Added `clearSslPreferences` and `clearClientCertPreferences` methods (available only for Android)
- Added `onSafeBrowsingHit` event (available only for Android)
- Added `onJsAlert`, `onJsConfirm` and `onJsPrompt` events to manage javascript popup dialogs
- Added `onReceivedHttpAuthRequest` event
- Added `clearCache`, `scrollTo`, `scrollBy`, `getHtml`, `injectJavascriptFileFromAsset` and `injectCSSFileFromAsset` methods method
- Added `HttpAuthCredentialDatabase` class
- Added `onReceivedServerTrustAuthRequest` and `onReceivedClientCertRequest` events to manage SSL requests
- Added `onFindResultReceived` event, `findAllAsync`, `findNext` and `clearMatches` methods 
- Added `shouldInterceptAjaxRequest`, `onAjaxReadyStateChange`, `onAjaxProgress` and `shouldInterceptFetchRequest` events with `useShouldInterceptAjaxRequest` and `useShouldInterceptFetchRequest` webview options
- Added `onNavigationStateChange` and `onLoadHttpError` events
- Fun: added `getTRexRunnerHtml` and `getTRexRunnerCss` methods to get html (with javascript) and css to recreate the Chromium's t-rex runner game 

### BREAKING CHANGES
- Deleted `WebResourceRequest` class
- Updated `WebResourceResponse` class
- Updated `ConsoleMessage` class
- Updated `ConsoleMessageLevel` class
- Updated `onLoadResource` event
- Updated `CookieManager` class
- WebView options are now available with the new corresponding classes: `InAppWebViewOptions`, `AndroidInAppWebViewOptions`, `iOSInAppWebViewOptions`, `InAppBrowserOptions`, `AndroidInAppBrowserOptions`, `iOSInAppBrowserOptions`, `AndroidChromeCustomTabsOptions` and `iOSSafariOptions`
- Renamed `getFavicon` to `getFavicons`, now it returns a list of all favicons (`List<Favicon>`) found
- Renamed `injectScriptFile` to `injectJavascriptFileFromUrl`
- Renamed `injectScriptCode` to `evaluateJavascript`
- Renamed `injectStyleCode` to `injectCSSCode`
- Renamed `injectStyleFile` to `injectCSSFileFromUrl`

## 1.2.2

- Merged "added a shared WKProcessPool for webview instances" [#198](https://github.com/pichillilorenzo/flutter_inappwebview/pull/198) (thanks to [robertcnst](https://github.com/robertcnst))
- Fixed iOS setCookie.

## 1.2.1

- Merged "Add new option to control the contentMode in Android platform" [#101](https://github.com/pichillilorenzo/flutter_inappwebview/pull/101) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Merged "Fix crash on xcode 10.2" [#107](https://github.com/pichillilorenzo/flutter_inappwebview/pull/107) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merged "Remove headers_build_phase from example's Podfile" [#108](https://github.com/pichillilorenzo/flutter_inappwebview/pull/108) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Fixed "Make html5 video fullscreen" for Android [#43](https://github.com/pichillilorenzo/flutter_inappwebview/issues/43)
- Fixed "AllowsInlineMediaPlayback not working" for iOS [#73](https://github.com/pichillilorenzo/flutter_inappwebview/issues/73)

## 1.2.0

- Merged "Adds a transparentBackground option for iOS and Android" [#86](https://github.com/pichillilorenzo/flutter_inappwebview/pull/86) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merged "The 'open' method requires an options dictionary" [#87](https://github.com/pichillilorenzo/flutter_inappwebview/pull/87) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merged "iOS: Call setNeedsLayout() in scrollViewDidScroll()" [#88](https://github.com/pichillilorenzo/flutter_inappwebview/pull/88) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Fixed "java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread." [#98](https://github.com/pichillilorenzo/flutter_inappwebview/issues/98) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Fixed "app force close/crash when enabling zoom and repeatedly changing orientation and zoomin zoomout" [#93](https://github.com/pichillilorenzo/flutter_inappwebview/issues/93)
- Added `displayZoomControls` webview option for Android
- Fixed "Compatibility with other plugins" [#80](https://github.com/pichillilorenzo/flutter_inappwebview/issues/80)

## 1.1.3

- Merged "Add null checks around calls to InAppWebView callbacks" [#85](https://github.com/pichillilorenzo/flutter_inappwebview/pull/85) (thanks to [matthewlloyd](https://github.com/matthewlloyd))

## 1.1.2

- Fix InAppBrowser crashes the app when i change the page "Lost connection" [#74](https://github.com/pichillilorenzo/flutter_inappwebview/issues/74)
- Fix javascript `...args` parameter of `window.flutter_inappwebview.callHandler()`
- Merged Enable setTextZoom function of Android WebViewSetting [#81](https://github.com/pichillilorenzo/flutter_inappwebview/pull/81) (thanks to [YouCii](https://github.com/YouCii))
- Merged bug fix for android build: Android dependency 'androidx.core:core' has different version for the compile (1.0.0) and runtime (1.0.1) classpath [#83](https://github.com/pichillilorenzo/flutter_inappwebview/pull/83) (thanks to [cinos1](https://github.com/cinos1))

## 1.1.1

- Fixed README.md and `addJavaScriptHandler` method documentation

## 1.1.0

- Breaking change for `addJavaScriptHandler` and `removeJavaScriptHandler` methods.
- `addJavaScriptHandler` method can return data to JavaScript using `Promise` [#46](https://github.com/pichillilorenzo/flutter_inappwebview/issues/46)
- added `flutterInAppBrowserPlatformReady` JavaScript event to wait until the platform is ready [#64](https://github.com/pichillilorenzo/flutter_inappwebview/issues/64)

## 1.0.1

- Fixed Unable to load initialFile on iOS #56
- Some code cleanup

## 1.0.0

Breaking changes:
- Fixed [Flutter AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), the latest version that doesn't use `AndroidX` is `0.6.0` (thanks to [juicycleff](https://github.com/juicycleff)).

## 0.6.0

- added support for **iOS** inline native WebView integrated in the flutter widget tree
- updated example folder (thanks to [marquesinijatinha](https://github.com/marquesinijatinha))
- Fixed bug where passing null to expiresDate failed (thanks to [Sense545](https://github.com/Sense545)) 
- Fixed iOS error: encode resourceURL (thanks to [igtm](https://github.com/igtm))
- Fixed iOS error: Double value cannot be converted to Int because the result would be greater than Int.max in 32-bit devices (thanks to [huzhiren](https://github.com/huzhiren))
- Fixed iOS error: problem in ChromeSafariBrowser (thanks to [marquesinijatinha](https://github.com/marquesinijatinha))
- Fixed Android build error caused by gradle and build gradle versions (thanks to [tje3d](https://github.com/tje3d))
- Updated `uuid` dependency to `^2.0.0`

## 0.5.51

- updated `pubspec.yaml`
- updated `README.md`

## 0.5.5

- added `getUrl` method for the `InAppWebViewController` class
- added `getTitle` method for the `InAppWebViewController` class
- added `getProgress` method for the `InAppWebViewController` class
- added `getFavicon` method for the `InAppWebViewController` class
- added `onScrollChanged` event for the `InAppWebViewController` and `InAppBrowser` class
- added `onBrowserCreated` event for the `InAppBrowser` class
- added `openData` method for the `InAppBrowser` class
- added `initialData` property for the `InAppWebView` widget

## 0.5.4

- added `WebHistory` and `WebHistoryItem` class
- added `getCopyBackForwardList`, `goBackOrForward`, `canGoBackOrForward` and `goTo` methods for the `InAppWebViewController` class

## 0.5.3

- added `CookieManager` class

## 0.5.2

- fixed some missing `result.success()` on Android and iOS
- added `postUrl()` method for the `InAppWebViewController` class
- added `loadData()` method for the `InAppWebViewController` class

## 0.5.1

- updated README.md

## 0.5.0

- added initial support for Inline WebViews using the `InAppWebView` widget
- added `InAppBrowser.openFile()` method
- added `InAppBrowser.onProgressChanged()` event
- moved `InAppBrowser` WebView related functions on the `InAppWebViewController` class
- added `InAppLocalhostServer` class
- added `InAppWebView.canGoBack()` and `InAppWebView.canGoForward()` methods
- removed `openWithSystemBrowser` and `isLocalFile` option. Now use the corresponding method
- code refactoring

## 0.4.1

- added `InAppBrowser.takeScreenshot()`
- added `InAppBrowser.setOptions()`
- added `InAppBrowser.getOptions()`

## 0.4.0

- removed `target` parameter to `InAppBrowser.open()` method. To open the url on the system browser, use the `openWithSystemBrowser: true` option
- fixes for the `_ChannelManager` private class
- fixed `EXC_BAD_INSTRUCTION` onLoadStart in Swift
- added `openWithSystemBrowser` and `isLocalFile` options
- added `InAppBrowser.openWithSystemBrowser` method
- added `InAppBrowser.openOnLocalhost` method
- added `InAppBrowser.loadFile` method
- added `InAppBrowser.isOpened` method

## 0.3.2

- fixed WebView.storyboard path for iOS

## 0.3.1

- fixed README.md example

## 0.3.0

- fixed WebView.storyboard to deployment target 8.0
- added `InAppBrowser.onLoadResource()` method. The event fires when the InAppBrowser webview loads a resource
- added `InAppBrowser.addJavaScriptHandler()` and `InAppBrowser.removeJavaScriptHandler()` methods to add/remove javascript message handlers
- removed `keyboardDisplayRequiresUserAction` from iOS available options
- now the `url` parameter of `InAppBrowser.open()` is optional. The default value is `about:blank`

## 0.2.1

- added `InAppBrowser.onConsoleMessage()` method to manage console messages
- fixed `InAppBrowser.injectScriptCode()` method when there is not a return value

## 0.2.0

- added support of Chrome CustomTabs for Android
- added support of SFSafariViewController for iOS
- added the ability to create multiple instances of browsers

## 0.1.1

- updated/added new methods
- updated UI of android/iOS in-app browser
- code cleanup
- added new options when opening the in-app browser

## 0.0.1

Initial release.
