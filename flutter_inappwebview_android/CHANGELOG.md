## 7.0.0

The Android half of a hard fork of 6.2.0-beta.3 / `1.2.0-beta.3`. The `flutter_inappwebview` 7.0.0
entry carries the full user-facing list; this entry is what changed in this package.

### Requirements and packaging — all breaking

- **`minSdk` 19 → 30** (Android 11). Well above Flutter's own floor of 24; AGP rejects an app below
  its library's floor, so every consuming app must raise its `minSdk`
- **Android Gradle Plugin 9 required.** The module declares no AGP classpath of its own and uses the
  AGP 9-only `enableKotlin` DSL; AGP 8 is no longer supported
- **The module is 100% Kotlin** — all 157 sources translated from Java, 0 `.java` files left
- **Namespace / Gradle `group`: `com.pichillilorenzo.flutter_inappwebview_android` →
  `dev.nosferatu500.inappwebview`**, and `pluginClass` with it
- **Every method/event channel name: `com.pichillilorenzo/…` →
  `dev.nosferatu500.inappwebview/…`.** Invisible through the public Dart API, breaking for anything
  talking to the channels directly, and what lets this fork be installed alongside upstream
- **The bundled `FileProvider` now ships `@xml/inappwebview_provider_paths`.** Apps that followed the
  documented setup and referenced `@xml/provider_paths` must switch — that resource no longer exists
  here. The authority suffix (`flutter_inappwebview_android.fileprovider`) is deliberately unchanged
- Native dependencies: `androidx.webkit` 1.14.0 → **1.17.0**, `androidx.browser` 1.9.0 → **1.10.0**,
  `androidx.appcompat` 1.7.1 → **1.8.0**

### Added

Twelve `androidx.webkit` features, each behind its own `WebViewFeature` flag, and eight
`android.webkit` APIs the plugin had never exposed:

- **`MUTE_AUDIO`** — `InAppWebViewController.setAudioMuted()` / `.isAudioMuted()`
- **`PAYMENT_REQUEST`** — `InAppWebViewSettings.paymentRequestEnabled` (upstream #2660, #2722)
- **`WEB_AUTHENTICATION`** — passkeys, via `InAppWebViewSettings.webAuthenticationSupport`
  (upstream #2743)
- **`DOWNLOAD_FAVICONS_ENABLED`** — `InAppWebViewSettings.downloadFaviconsEnabled`, which also gates
  the existing `onReceivedIcon`
- **`BACK_FORWARD_CACHE`** — `InAppWebViewSettings.backForwardCacheEnabled`
- **`ATTRIBUTION_REGISTRATION_BEHAVIOR`** — `InAppWebViewSettings.attributionRegistrationBehavior`
- **`WEBVIEW_MEDIA_INTEGRITY_API_STATUS`** — `InAppWebViewSettings.webViewMediaIntegrityApiStatus`,
  with per-origin overrides
- **`USER_AGENT_METADATA`** (+ `…_FORM_FACTORS`) — User-Agent Client Hints, via
  `InAppWebViewSettings.userAgentMetadata`
- **`DEFAULT_TRAFFICSTATS_TAGGING`** — `InAppWebViewController.setDefaultTrafficStatsTag()`
- **`DELETE_BROWSING_DATA`** — `WebStorageManager.deleteBrowsingData()` /
  `.deleteBrowsingDataForSite()`
- **`MULTI_PROFILE`** — a `ProfileStore` controller (`AndroidProfileStore`) plus
  `InAppWebViewSettings.profileName`, and the
  plugin's own storage APIs are now profile-aware: cookies, web storage, service-worker settings and
  geolocation all act on the profile the WebView is actually using, instead of silently acting on
  the default profile. `setServiceWorkerClient` remains default-profile only
- **`PRERENDER_WITH_URL`** — `InAppWebViewController.prerenderUrl(WebUri)`
- **`GeolocationPermissions`** — a new controller surface (`AndroidGeolocationPermissions`: `allow`,
  `clear`, `clearAll`, `getAllowed`, `getOrigins`), profile-aware from the start
- **`CookieManager`** — `setAcceptCookie()`, `isAcceptCookieEnabled()`, `hasCookies()`,
  `isFileSchemeCookiesAllowed()`
- **`InAppWebViewController`** — `postVisualStateCallback()`, `documentHasImages()`, `flingScroll()`

Every mirrored `WebViewFeature` constant is now pinned against the real AAR by a test: six of the
flags `WebViewFeature` declares are `@Deprecated` tombstones that `isFeatureSupported` **throws**
for, and five others have a native *value* that differs from their name.

### Fixed

- **`CookieManager.flush()` never returned.** The native side never replied on the channel, so the
  `Future` hung forever. Fixed and verified on a device
- **A blocking callback could hang the WebView forever.** The four synchronous callbacks
  (`shouldInterceptRequest`, `shouldOverrideUrlLoading`, `onJsBeforeUnload`,
  `ServiceWorkerClient.shouldInterceptRequest`) waited on a latch that was not always released. The
  wait is now always released and bounded at 10s; a handler that legitimately takes longer will stop
  intercepting and log a warning
- **The bundled `FileProvider` granted read access to the entire external-storage root** (upstream
  #2874 / #2873). It is now scoped to the plugin's own directories
- **Six bugs carried through the Java → Kotlin translation**, fixed once the diff was small enough to
  review: `MediaSizeExt` unit conversion, `HeadlessInAppWebView.setSize`, `mayLaunchUrl`,
  `getRealSettings`, a boxed-value comparison in `setSettings` that made settings updates no-ops, and
  `JsBeforeUnloadResponse.toString()`
- **AGP 9 / ProGuard** compatibility (upstream #2852, #2765, #2761)
- Deleted the dead ~300-line `InputAwareWebView` path

### Removed

- All deprecated API: `AndroidWebViewFeature` → `WebViewFeature`, `AndroidInAppWebViewOptions` /
  `AndroidInAppBrowserOptions` / `AndroidChromeCustomTabsOptions` → the `*Settings` classes, the
  `androidOn*` event aliases, the `android*` field aliases, `getOptions`/`setOptions`,
  `InAppWebViewController.setSafeBrowsingWhitelist()` (→ `setSafeBrowsingAllowlist`),
  `.startSafeBrowsing()`, `.clearCache()` (→ `clearAllCache`), `.getScale()` (→ `getZoomScale`),
  `PullToRefreshController.setSize()` (→ `setIndicatorSize`)
- Settings that were provably no-ops at `minSdk 30` / `targetSdk 33+`:
  `InAppWebViewSettings.saveFormData`, `.forceDark`, `.forceDarkStrategy` (use
  `algorithmicDarkeningAllowed`), `.requestedWithHeaderOriginAllowList` (androidx cancelled the
  header removal it existed for), and `LayoutAlgorithm.NARROW_COLUMNS`, which surveying found was
  **never settable** — a `switch` with no `break`s, fixed at the same time
- `WebViewFeature.FORCE_DARK`, `.FORCE_DARK_STRATEGY`, `.REQUESTED_WITH_HEADER_ALLOW_LIST`,
  `.SAFE_BROWSING_WHITELIST` (→ `SAFE_BROWSING_ALLOWLIST`) and `.START_SAFE_BROWSING`
- The `createPlatformWebViewEnvironment` / `createPlatformWebViewEnvironmentStatic` overrides —
  `PlatformWebViewEnvironment` was Windows/Linux-only and no longer exists
- `onDownloadStarting` no longer serializes a response back to the native side: the event returns
  `FutureOr<void>`, and `WebViewChannelDelegate.kt` never read the returned value

### Internal

- **ktlint 1.8** formatting (`npm run format:kotlin`) plus `allWarningsAsErrors` behind an opt-in
  `inappwebview.strictKotlin` flag — opt-in on purpose, since the module compiles inside the
  consumer's build and an unconditional `-Werror` would break their app over a future Kotlin warning.
  Five ktlint naming rules are disabled with the reason inline: `enum-entry-name-case` wanted to
  rename the 77 `WebViewChannelDelegateMethods` entries that **are** the channel wire strings
- **Android lint: 0 findings** (from 27), with three documented suppressions
- **The module's first native unit tests** — 23 across 4 test classes, no device or Robolectric
  needed (~4s). They found two real bugs on their first run
- 33 Dart-side unit tests, covering the channel argument maps — the package previously shipped a
  single empty placeholder test file

## 1.2.0-beta.3

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.3
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

## 1.2.0-beta.2

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.2
- Implemented `hideInputMethod`, `showInputMethod` InAppWebViewController methods
- Implemented `isUserInteractionEnabled`, `alpha` properties of `InAppWebViewSettings`
- Merged "Show / Hide / Disable / Enable soft Keyboard Input (Android & iOS)" [#2408](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2408) (thanks to [Mecharyry](https://github.com/Mecharyry))
- Fixed "[Android] PrintJobOrientation _TypeError (type 'Null' is not a subtype of type 'int')" [#2413](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2413)
- Fixed "Accessibility Android" [#1694](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1694)
- Fixed "Automatic font scale according to accessibility option 'font size' of device does not work on Android" [#540](https://github.com/pichillilorenzo/flutter_inappwebview/issues/540)
- Fixed "callHandler method is not injected into InAppBrowser" [#1973](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1973)

## 1.2.0-beta.1

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.1
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

## 1.1.3

- Updated flutter_inappwebview_platform_interface version to ^1.3.0

## 1.1.2

- Removed webview/plugin_scripts_js/ConsoleLogJS.java file, use native WebChromeClient.onConsoleMessage instead

## 1.1.1

- Updated flutter_inappwebview_platform_interface version to ^1.2.0

## 1.1.0+4

- Updated flutter_inappwebview_platform_interface version

## 1.1.0+3

- Fixed compilation error

## 1.1.0+2

- Updated pubspec.yaml

## 1.1.0+1

- Downgraded androidx.appcompat:appcompat:1.7.0 to androidx.appcompat:appcompat:1.6.1
- Added `-dontwarn android.window.BackEvent` proguard rule

## 1.1.0

- Updated androidx.webkit:webkit:1.8.0 to androidx.webkit:webkit:1.12.0
- Updated androidx.browser:browser:1.6.0 to androidx.browser:browser:1.8.0
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Removed unsupported WebViewFeature.SUPPRESS_ERROR_PAGE
- Merged "Remove references to deprecated v1 Android embedding" [#2176](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2176) (thanks to [gmackall](https://github.com/gmackall))

## 1.0.13

- Fixed "Android emulator using API 34 fails to draw on resume sometimes" [#1981](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1981)

## 1.0.12

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.10`

## 1.0.11

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.9`
- Fix typos (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.10

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.8`
- Implemented `PlatformCustomPathHandler` class

## 1.0.9

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.7`
- Fixed "Cloudflare Turnstile failure" [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Fixed `InAppWebViewController.callAsyncJavaScript` issue when the last line of the `functionBody` parameter includes a code comment

## 1.0.8

- Implemented `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests`
- Implemented `PlatformInAppWebViewController.clearFormData` method
- Implemented `PlatformCookieManager.removeSessionCookies` method
- Updated `useShouldInterceptAjaxRequest` automatic infer logic
- Updated `CookieManager` methods return value

## 1.0.7

- Merged "Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'" [#1904](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1904) (thanks to [EArminjon](https://github.com/EArminjon))
- Fixed shouldInterceptAjaxRequest javascript code when overriding XMLHttpRequest.open method parameters

## 1.0.6

- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)
- Fixed "onClosed not considering back navigation or up button / close button in ChromeSafariBrowser when using noHistory: true" [#1882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1882)

## 1.0.5

- Call `super.dispose();` on `InAppBrowser` and `ChromeSafari` implementations 

## 1.0.4

- Throw platform exception when ProcessGlobalConfig.apply throws an error on the native side to be able to catch it on Flutter side

## 1.0.3

- Updated `ContentBlockerHandler` CSS_DISPLAY_NONE action type and `JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_SOURCE` javascript implementation code

## 1.0.2

- Updated `flutter_inappwebview_platform_interface` version dependency to `1.0.2` 
- Fixed "Crash when starting ChromeSafariBrowser on Android java.lang.NoSuchMethodError: No virtual method isEngagementSignalsApiAvailable" [#1881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1881)

## 1.0.1

- Updated README

## 1.0.0

Initial release.
