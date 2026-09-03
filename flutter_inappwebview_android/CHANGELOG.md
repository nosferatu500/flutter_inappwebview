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
- **The bundled `FileProvider`'s `<provider>` block changed in all three of its parts.** Apps declare
  it themselves, because the authority derives from their own `applicationId`, so all three are
  breaking:
  - `android:name`: `com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFileProvider` →
    **`dev.nosferatu500.inappwebview.InAppWebViewFileProvider`**
  - `android:authorities`: `${applicationId}.flutter_inappwebview_android.fileprovider` →
    **`${applicationId}.dev.nosferatu500.inappwebview.fileprovider`**
  - the `meta-data` resource: `@xml/provider_paths` → **`@xml/inappwebview_provider_paths`**, which
    is scoped to the app's own external files directory (see *Fixed*); `@xml/provider_paths` no
    longer exists here

  **A stale authority is silent.** `FileProvider.getUriForFile` throws `IllegalArgumentException`,
  `InAppWebViewChromeClient.getOutputUri()` logs it and returns null, and
  `<input type="file" capture>` then produces nothing — no Dart error and no event. Copy the whole
  block from the `InAppWebViewFileProvider` KDoc rather than editing one line of the 6.x one
- **Consuming apps must now compile against API 37+.** The module declares
  `androidx.core:core:1.19.0`, whose AAR metadata requires it, and AGP **fails** the build rather
  than warning when it is unmet. Add `compileSdk = 37` to your app's `android/app/build.gradle`
  until Flutter's own default reaches 37 (it is 36 on Flutter 3.44). `minSdk` and `targetSdk` are
  unaffected — this only governs which SDK your app compiles against
- Native dependencies: `androidx.webkit` 1.14.0 → **1.17.0**, `androidx.browser` 1.9.0 → **1.10.0**,
  `androidx.appcompat` 1.7.1 → **1.8.0**, and **`androidx.core` is now declared directly at
  1.19.0** — it was used directly (`ContextCompat`, `ViewCompat`, `WindowCompat`,
  `WindowInsetsCompat`, `WindowInsetsControllerCompat`, `BundleCompat`, `FileProvider`) while
  reaching the classpath only transitively through appcompat
- **New Dart dependency: `meta` (`^1.15.0`).** Required by the Pigeon-generated
  `lib/src/pigeons/*.g.dart`, which import `package:meta/meta.dart`. It was previously reaching the
  package only transitively, which `flutter pub publish` rejects outright — an undeclared import
  from `lib/` is a validation **error**, not a warning

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
  `InAppWebViewSettings.profileName`, and the plugin's own storage APIs are now profile-aware:
  cookies, web storage, service-worker settings and geolocation all act on the profile the WebView is
  actually using, instead of silently acting on the default profile. `setServiceWorkerClient` remains
  default-profile only
- **`PRERENDER_WITH_URL`** — `InAppWebViewController.prerenderUrl(WebUri)`
- **`GeolocationPermissions`** — a new controller surface (`AndroidGeolocationPermissions`: `allow`,
  `clear`, `clearAll`, `getAllowed`, `getOrigins`), profile-aware from the start
- **`CookieManager`** — `setAcceptCookie()`, `isAcceptCookieEnabled()`, `hasCookies()`,
  `isFileSchemeCookiesAllowed()`
- **`InAppWebViewController`** — `postVisualStateCallback()`, `documentHasImages()`, `flingScroll()`
- **`InAppWebViewSettings.syncCallbackTimeoutMillis`** — the bound on how long a WebView worker
  thread blocks waiting for Dart to answer `shouldInterceptRequest` or
  `onLoadResourceWithCustomScheme`, previously the hardcoded `Util.SYNC_CALLBACK_TIMEOUT_MILLIS`
  (10s). Read live from `customSettings` on each callback, so `setSettings` takes effect
  immediately; `0` or less falls back to the default rather than being honoured, because
  `latch.await(0)` would make every synchronous callback a silent no-op. The two blocking waits that
  have no WebView settings to read — a custom `WebViewAssetLoader` `PathHandler.handle` and
  `ServiceWorkerClient.shouldInterceptRequest` — keep the fixed 10s

- **`NAVIGATION_LISTENER`** (+ **`NAVIGATION_GET_WEB_RESOURCE_ERROR`**) —
  `onNavigationStarted` / `onNavigationRedirected` / `onNavigationCompleted`, carrying the new
  `WebViewNavigation` type, behind `InAppWebViewSettings.useNavigationListener`.

  **`Navigation.getStatusCode()` is the reason to want this**: it reports the HTTP status of a
  navigation that succeeded, which no existing event could — `onReceivedHttpError` fires only for
  error responses. It is reported as `null` until the navigation commits rather than as `0`. The
  events also see navigations nothing else in the plugin does: same-document navigations
  (`history.pushState`, fragment jumps), back/forward traversals and reloads, each classified by
  `isBack`/`isForward`/`isReload`/`isRestore`/`isSameDocument`/`wasInitiatedByPage`. And
  `onNavigationRedirected` is the first redirect event here that is not conditional on the app's own
  choices — `NavigationAction.isRedirect` only ever reported redirects for navigations
  `shouldOverrideUrlLoading` was offered.

  Two implementation notes worth knowing. **The id is synthesised by the plugin**, from a
  `WeakHashMap` keyed on androidx's interned peer: androidx says "same navigation" with object
  identity, which no method channel can carry. Neither `Navigation` nor `Page` overrides
  `equals`/`hashCode`, so a `WeakHashMap` gives identity semantics *and* drops entries the platform
  has released. **The listener is registered only when the setting is on**, and the setting is
  inferred from any of the three handlers being supplied; it can also be toggled through
  `setSettings` at runtime, which starts a fresh id sequence. `addNavigationListener` throws
  `UnsupportedOperationException` rather than degrading, so the feature check is not optional.

  `Navigation.getWebResourceError()` is the **only** method on `Navigation` that androidx guards with
  a feature check of its own, and `Page` has no gated method at all — `Page.getUrl()` is callable
  even though `WebViewFeature.PAGE_GET_URL` is one of the six tombstones below

Every mirrored `WebViewFeature` constant is now pinned against the real AAR by a test: six of the
flags `WebViewFeature` declares are `@Deprecated` tombstones that `isFeatureSupported` **throws**
for, and five others have a native *value* that differs from their name.

### Changed

- **`onPrintRequest` is asked before the print job starts.** `JavaScriptBridgeInterface`'s
  `window.print()` handler no longer calls `printCurrentPage()` up front; it invokes the Dart event
  first and only prints from the callback's `defaultBehaviour`, so returning `true` means
  `PrintManager.print` is never called and no print dialog appears. Returning `false`, `null`, an
  error, and having no handler at all all still print. The job is now created with
  `handledByClient = false`, so no `PrintJobController` is allocated on this path.
  `WebViewChannelDelegate.onPrintRequest` drops its `printJobId` argument and no longer sends that
  map key. Measured on API 37 and API 33: `true` leaves no `com.android.printspooler` process,
  `false` and no-handler both spawn one

### Fixed

- **`WebMessageListener`'s origin allow-list compared reverse-DNS hostnames, and could match an
  origin it was not written for.** Both helpers behind it were wrong.

  `Util.isIPv6` was `Inet6Address.getByName(address); true`. `Inet6Address` declares no
  `getByName`, so that resolved to the inherited `InetAddress.getByName` — which parses IPv4
  literals **and resolves hostnames** — and nothing type-checked the result. It therefore answered
  *"is this resolvable"*: `127.0.0.1` and `example.com` both returned `true`.

  `Util.normalizeIPv6` returned `canonicalHostName`, a **reverse DNS lookup** producing a hostname
  rather than a normalized address — `::1` came back as `"localhost"`. Combined with the bug above
  it ran on **every** origin check rather than only IPv6 ones, so each check could cost a forward
  and a reverse lookup **on the calling thread** and disclosed the visited host to the resolver.

  The security consequence is that the allow-list's IPv6 comparison was made between canonical
  *names*: an allowed-origin rule of `[::1]` and a page origin of `127.0.0.1` both canonicalise to
  `"localhost"` on a typical machine and compared **equal**, so a listener could be reached from an
  origin the rule did not name. `isIPv6` is now purely syntactic and never touches the network, and
  `normalizeIPv6` returns `hostAddress`. **This is a tightening**: origins that previously matched
  only through a shared canonical name no longer match. Both spellings `::1` and `[::1]` are
  accepted, since `Uri.getHost()` keeps the brackets. Covered by 8 unit tests (23 → 28), each
  verified to fail against the old implementation

- **`HeadlessInAppWebView.setSize` / `getSize` did not round-trip, and a `-1` axis was reported in
  the wrong unit.** The Dart API is in logical pixels; a `View`'s layout params are `Int` physical
  pixels. `setSize` **truncated** the conversion and `getSize` divided the result back, so on any
  device whose density makes the product fractional you did not get out what you put in —
  `Size(600, 800)` came back as `Size(599.795, 800)` at density 390, and a non-integer size such as
  `Size(600.25, 800.75)` lost precision at every density. `setSize` now rounds, and `getSize`
  answers from the size last requested for as long as those are still the layout params on the view,
  so the round-trip is exact.

  Separately, `getSize` reported a `-1` ("match the screen") axis as a **physical** pixel count:
  `Size(-1, -1)` on a density-420 device answered `Size(1080, 2400)` for a screen 411.4 logical
  pixels wide. It now answers in logical pixels, like every other value the API accepts or returns.
  iOS was unaffected — UIKit points are logical pixels and no conversion happens there.
  Covered by 7 new unit tests (28 → 35) and two integration assertions, all verified to fail against
  the old code
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
- **`WebMessageListener.isOriginAllowed`'s wildcard was an unanchored substring test** —
  `*.example.com` matched `foo.example.com.evil.test`. Now anchored at the end of the host, so it is
  subdomains only. **Not user-visible on Android**: listeners are registered through
  `WebViewCompat.addWebMessageListener`, which matches origins inside the WebView, and nothing in
  this module calls the Kotlin copy. It is fixed and unit-tested (`Util.hostMatchesWildcardRule`)
  because the same rule is live on iOS and a fork should not ship two spellings of one security check
- **The HTTP-auth state was process-global, and one WebView could be given another's password.**
  `previousAuthRequestFailureCount` and `credentialsProposed` were `companion object` vars on
  **both** `InAppWebViewClient` and `InAppWebViewClientCompat`, so every WebView in the app shared
  one credential queue and one failure counter, and any WebView's `onPageFinished` /
  `onReceivedError` emptied them mid-challenge for the others. Worse, the queue is *fetched* by
  matching host + protocol + realm + port but nothing re-checked that on the way out, so **a queue
  filled for one host could be popped for another** — one page with authenticated subresources on a
  second origin is enough, no second WebView required. Both are now per-WebView instance state in a
  new `HttpAuthState`, which also discards the queue and the counter when the protection space
  changes. 9 unit tests
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
- **`PrintJobController.disposeNoCancel()`**, whose only caller was the old `onPrintRequest`
  path — it dropped the plugin's tracking while leaving the OS job running, and there is no longer
  a job the plugin owns but has not handed to Dart
- **`onFaviconChanged`**, with its `WebChromeClient.onReceivedIcon` override in
  `InAppWebViewChromeClient.kt` and the `onFaviconChanged` sender in `WebViewChannelDelegate.kt`. The
  framework no longer dispatches `onReceivedIcon` — `WebIconDatabase`, its source, has been inert
  since API 19 — so the event could not fire. Measured on API 33 and API 37: with
  `downloadFaviconsEnabled: true` reading back `true`, the WebView does fetch `favicon.ico`
  (confirmed through `onLoadResource`) and `onReceivedIcon` is still never called, while
  `onReceivedTitle` from the same client is. Use `InAppWebViewController.getFavicons()`.
  `InAppWebViewSettings.downloadFaviconsEnabled` is kept — it still controls whether the request is
  issued, which is a real network cost per page

### Internal

- **ktlint 1.8** formatting (`npm run format:kotlin`) plus `allWarningsAsErrors` behind an opt-in
  `inappwebview.strictKotlin` flag — opt-in on purpose, since the module compiles inside the
  consumer's build and an unconditional `-Werror` would break their app over a future Kotlin warning.
  Five ktlint naming rules are disabled with the reason inline: `enum-entry-name-case` wanted to
  rename the 77 `WebViewChannelDelegateMethods` entries that **are** the channel wire strings
- **Android lint: 0 findings** (from 27), with three documented suppressions
- **The module's first native unit tests** — 23 across 4 test classes, no device or Robolectric
  needed (~4s). They found two real bugs on their first run
- 60 Dart-side unit tests, covering the channel argument maps of every method added here — the
  package previously shipped a single empty placeholder test file

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
