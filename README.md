<div align="center">

# Flutter InAppWebView Plugin

![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/195422744-bdcfed16-73f0-4bc9-94ab-ecf10771a1c4.png)

[![nosferatu500_inappwebview version](https://img.shields.io/pub/v/nosferatu500_inappwebview?include_prereleases)](https://pub.dev/packages/nosferatu500_inappwebview)
[![Pub Points](https://img.shields.io/pub/points/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![Pub Likes](https://img.shields.io/pub/likes/nosferatu500_inappwebview)](https://pub.dev/packages/nosferatu500_inappwebview/score)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

###### Supported Platforms

[![nosferatu500_inappwebview_platform_interface version](https://img.shields.io/pub/v/nosferatu500_inappwebview_platform_interface?include_prereleases&label=Platform%20Interface)](https://pub.dev/packages/nosferatu500_inappwebview_platform_interface)
[![nosferatu500_inappwebview_android version](https://img.shields.io/pub/v/nosferatu500_inappwebview_android?include_prereleases&label=Android)](https://pub.dev/packages/nosferatu500_inappwebview_android)
[![nosferatu500_inappwebview_ios version](https://img.shields.io/pub/v/nosferatu500_inappwebview_ios?include_prereleases&label=iOS)](https://pub.dev/packages/nosferatu500_inappwebview_ios)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

</div>

## Why this fork

This is a fork of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview) by
Lorenzo Pichilli, carrying its full git history. It diverges at upstream's newest published
version, the prerelease **`6.2.0-beta.3` (February 2026)** — upstream's last *stable* release is
`6.1.5` — and the comparison below is against that. The public Dart API is recognisably the same;
what changed is the scope, the two native implementations, and what the plugin still carries.

|                        | upstream `6.2.0-beta.3`                      | this fork `7.1.0`                                                    |
| ---------------------- | -------------------------------------------- | -------------------------------------------------------------------- |
| Platforms              | 6 — Android, iOS, macOS, Windows, Linux, Web | **2 — Android, iOS**                                                 |
| Android implementation | Java                                         | **100% Kotlin**, all 157 sources translated                          |
| iOS implementation     | Swift 5                                      | **Swift 6 language mode**, complete concurrency checking             |
| Deprecated API         | 1111 `@Deprecated` (all 6 packages)          | **0** — every deprecated class, event, field and method gone         |
| Android `minSdk` / AGP | 19 / 8                                       | **30 / 9**                                                           |
| iOS deployment target  | 12.0                                         | **15.0**                                                             |
| Flutter / Dart floor   | 3.32 / `^3.8.0`                              | **3.47 / `^3.13.0`**                                                 |
| Unit tests             | 276, all in the example app                  | **412**, incl. the Android module's first native tests               |
| Android lint           | 27 findings                                  | **0**                                                                |
| New platform APIs      | —                                            | **50+** — see the table below                                        |
| Alongside upstream     | —                                            | **yes** — own Android namespace and channel names                    |

What the narrower scope bought, beyond the table: the first iOS device runs in the project's
history found **four defects that no compiler, linter or unit test could see** — ten
`WKUIDelegate`/`WKNavigationDelegate` methods the Swift 6 migration had silently unhooked (so
`onJsAlert`/`onJsConfirm`/`onJsPrompt` never fired and `shouldOverrideUrlLoading` could not block a
navigation), a throwing JavaScript handler that hung its caller forever, `onPrintRequest` killing
the app on iOS 26, and a DNS failure throwing inside the plugin so `onReceivedError` never reached
app code. Android got its blocking-callback hang and its `CookieManager.flush()` hang fixed, and a
`FileProvider` that had been granting access to the entire external-storage root scoped down.

**What it cost, stated plainly.** macOS, Windows, Linux and Web support is gone, and so is every
API that only served them. `minSdk 30` is well above Flutter's own floor of 24 and forces every
consuming app to raise its own. Most disruptive, and invisible in the version numbers: the iOS
module needs **Xcode 27** to build: it uses iOS 27 WebKit API, which only the iOS 27 SDK declares, and
`isolated deinit` (SE-0371) at 32 sites. A consumer on Xcode 26 or older cannot build this plugin at all.

**Migrating from upstream?** Every removal is a rename with a replacement that already existed in
6.x: `*Options` → `*Settings`, `getOptions`/`setOptions` → `getSettings`/`setSettings`, and the
`Android`/`IOS`-prefixed duplicate types, events and fields → their unprefixed originals. Drop any
macOS/Windows/Linux/Web-only API — there is nothing to migrate to. If you declared the plugin's
`FileProvider`, replace that whole `<provider>` block: its class, its authority
(`${applicationId}.dev.nosferatu500.inappwebview.fileprovider`) and its paths resource
(`@xml/inappwebview_provider_paths`) all changed, and a stale authority fails silently. The full
old → new list, name by name, is in
[`flutter_inappwebview/CHANGELOG.md`](./flutter_inappwebview/CHANGELOG.md).

## New APIs added by this fork

Everything below is callable from Dart and exists only in this fork. Each entry says which platform
implements it; on the other platform the call reports "not implemented on the current platform"
(methods) or is simply ignored (settings), so it is always safe to write cross-platform code and
guard with `isMethodSupported` / `isPropertySupported` / `WebViewFeature.isFeatureSupported`.

**Version numbers are the OS floor**, not the plugin's. Below the floor an iOS getter returns `null`
and a setter reports `false` — never a wrong value — and an Android feature is reported unsupported
by its `WebViewFeature` flag.

### `InAppWebViewSettings`

| Property | Platform | What it does |
| --- | --- | --- |
| `paymentRequestEnabled` | Android | Enables the W3C Payment Request API in the WebView |
| `webAuthenticationSupport` | Android | Enables passkeys / WebAuthn, scoped to the app or to the whole browser |
| `downloadFaviconsEnabled` | Android | Whether the WebView downloads favicons at all — a real per-page network cost |
| `backForwardCacheEnabled` | Android | Turns on the back/forward cache so back navigations restore instantly |
| `attributionRegistrationBehavior` | Android | Chooses between app- and web-source attribution registration |
| `webViewMediaIntegrityApiStatus` | Android | Media Integrity API status, with per-origin overrides |
| `userAgentMetadata` | Android | User-Agent Client Hints — brands, platform, form factors |
| `profileName` | Android | Puts this WebView on a named browsing profile with its own cookies and storage |
| `syncCallbackTimeoutMillis` | Android | How long the WebView waits for your Dart `shouldInterceptRequest` answer before loading the resource anyway (was a fixed 10s) |
| `useNavigationListener` | Android | Opt in to the nine navigation/page/Web-Vitals events. Inferred from supplying any of their handlers |
| `useOnPerformanceMarkMillis` | Android | Opt in to `onPerformanceMarkMillis` specifically. Separate because a page can call `performance.mark()` hundreds of times per load — the other eight events never infer it |
| `includeCookiesOnShouldInterceptRequest` | Android | Puts the `Cookie` header on the request handed to `shouldInterceptRequest`, and makes `WebResourceResponse.cookies` on your reply take effect. Both directions, one switch. `CookieManager` cannot substitute — it answers about a *url*, not about a request, so it can return the wrong set |
| `writingToolsBehavior` | iOS 18.0+ | How much of Apple's Writing Tools the WebView offers |
| `preferredHTTPSNavigationPolicy` | iOS 18.0+ | Automatic HTTP→HTTPS upgrading; applied per navigation, so it responds to `setSettings` |
| `securityRestrictionMode` | iOS 18.4+ | WebKit's built-in security restriction level |
| `globalPrivacyControlEnabled` | iOS 27.0+ | Sends the Global Privacy Control signal (`navigator.globalPrivacyControl`; the `Sec-GPC: 1` header only from a secure context); applied per navigation, so it responds to `setSettings` |
| `lockdownModeEnabled` | iOS 17.0+ | Forces Lockdown Mode on or off for this WebView; leave `null` to follow the system setting |
| `supportsAdaptiveImageGlyph` | iOS 18.0+ | Allows inline Genmoji / adaptive image glyphs in editable content |
| `showsSystemScreenTimeBlockingView` | iOS 26.0+ | Whether WebKit draws its own overlay over Screen-Time-blocked content. Creation-time only |
| `obscuredContentInsets` | iOS 26.0+ | Shrinks the page's layout viewport where your app draws chrome over it |
| `useOnShowFileChooser` | iOS 18.4+ | Opt in to `onShowFileChooser`; while off, WebKit's own file picker is left untouched |
| `useOnInsertInputSuggestion` | iOS 26.0+ | Opt in to `onInsertInputSuggestion`; opting in makes your app responsible for inserting the text |
| `useShouldGoToBackForwardListItem` | iOS 26.0+ | Opt in to `shouldGoToBackForwardListItem`. Off by default because every back/forward navigation then waits for your answer |

### `InAppWebViewController`

| Method | Platform | What it does |
| --- | --- | --- |
| `setAudioMuted()` / `isAudioMuted()` | Android | Mutes or unmutes all audio playing in the WebView |
| `setDefaultTrafficStatsTag()` | Android | Tags the WebView's network traffic for `TrafficStats` accounting |
| `prerenderUrl()` | Android | Pre-renders a URL so a later navigation to it is instant |
| `postVisualStateCallback()` | Android | Awaits the point at which everything drawn so far is on screen |
| `documentHasImages()` | Android | Whether the current document contains any images |
| `flingScroll()` | Android | Starts a fling scroll at a velocity in device pixels per second |
| `saveState()` — the `maxSize` / `includeForwardState` arguments | Android | Bounds the saved state. `saveState()` has always been **unbounded** (measured at 2.0 MB for a 9-entry history), which matters if you persist it somewhere with a limit of its own. `includeForwardState: false` drops entries only reachable by going forward. Returns `null` — not a smaller state — if `maxSize` is too small for even the current page |
| `isBlockedByScreenTime()` | iOS 26.0+ | Whether Screen Time is blocking the current content. Returns `null` below iOS 26 — not `false` |
| `setConversationContext()` / `getConversationContext()` | iOS 26.0+ | Hands the keyboard the mail/message thread being replied to, so it can offer Smart Replies in web text fields |

### Events

| Event | Platform | What it does |
| --- | --- | --- |
| `onShowFileChooser` | Android, **iOS 18.4+** | Take over the file picker for `<input type="file">`. Existed for Android; now fires on iOS too |
| `onInsertInputSuggestion` | iOS 26.0+ | Reports which keyboard Smart Reply the user picked, so you can insert it into the page |
| `shouldGoToBackForwardListItem` | iOS 26.0+ | Veto a back/forward navigation before it happens, and see WebKit's instant-back flag. **The veto binds navigations the page starts (`history.back()`); it does not stop your own `goBack()`** |
| `onWritingToolsActiveChanged` | iOS 18.0+ | Fires when the system Writing Tools UI starts or stops operating on the page (see the note below) |
| `onNavigationStarted` | Android | Every navigation the WebView begins — including fragment jumps, `history.pushState`, back/forward and reloads, which no other event here reports |
| `onNavigationRedirected` | Android | Every redirect hop. Unlike `NavigationAction.isRedirect`, not limited to navigations `shouldOverrideUrlLoading` was offered |
| `onNavigationCompleted` | Android | A navigation finished. **Carries `statusCode` — the only way to see the HTTP status of a navigation that *succeeded*** |
| `onPageDomContentLoadedEvent` | Android | `DOMContentLoaded` **without injecting any JavaScript** — no user script, nothing for a strict CSP to block |
| `onPageLoadEvent` | Android | A page's `load` event has run. About a *document*, so it can still arrive for a page that is no longer on screen |
| `onPageDeleted` | Android | A page was destroyed — **the only way to observe back/forward-cache eviction**, which `backForwardCacheEnabled` had no counterpart for |
| `onFirstContentfulPaintMillis` | Android | First Contentful Paint straight from the engine, no `PerformanceObserver` needed |
| `onLargestContentfulPaintMillis` | Android | Largest Contentful Paint. **Can fire repeatedly per page** — LCP is revised as bigger content arrives |
| `onPerformanceMarkMillis` | Android | Every `performance.mark()` the page makes. Needs its own `useOnPerformanceMarkMillis` opt-in |
| `onRequestVisitedHistory` | Android | The engine asks **you** which URLs the user has visited, so pages can style `:visited` links. Nothing else in the plugin can answer it — a WebView cannot know what the user visited elsewhere in your app. Fires once per WebView |

### Managers and controllers

| API | Platform | What it does |
| --- | --- | --- |
| `ProfileStore` | Android | A whole new surface for creating, listing and deleting named browsing profiles |
| `GeolocationPermissions` | Android | Grant, clear and list per-origin geolocation permissions; profile-aware |
| `WebStorageManager.deleteBrowsingData()` / `.deleteBrowsingDataForSite()` | Android | Delete browsing data wholesale or for one site |
| `CookieManager.hasCookies()` | Android | Whether the store holds any cookie at all, without enumerating |
| `CookieManager.isFileSchemeCookiesAllowed()` | Android | Whether `file://` cookies are accepted. Read-only — the platform setter is deprecated |
| `CookieManager.setAcceptCookie()` / `.isAcceptCookieEnabled()` | Android, **iOS 17.0+** | The cookie master switch. Governs the WebView's own traffic — it does **not** block `setCookie()` on either platform |
| `CookieManager.setCookies()` | Android, iOS | Write many cookies in **one** platform round trip, each `CookieToSet` carrying its own `url` so a batch can span several origins. Measured on iOS 26.5: 100 cookies cost 84 ms one `setCookie()` at a time and ~12–16 ms in one call, and ~94% of that gap is channel overhead rather than the cookie store — which is why it is on both platforms and not only where a native batch API exists. Returns one `bool` per cookie, in order; on iOS `false` means only that the cookie could not be *constructed*, because WebKit never reports storage success |
| `CookieManager.setCookieStoreObserver()` | iOS | Be told when the cookie store changes instead of polling. Carries no payload — re-read the store in the callback |
| `ServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled()` / getter | Android | The Service Worker twin of `includeCookiesOnShouldInterceptRequest`, and a **separate switch** — turning on the WebView one does nothing here. The getter returns `bool?`: `null` means the feature is missing **or** you passed a `profileName`, for which this setting does not exist at all |
| `ProfileStore.addCustomHeader()` / `.hasCustomHeader()` / `.getCustomHeaders()` / `.clearCustomHeader()` / `.clearAllCustomHeaders()` | Android | Headers attached to a **browsing profile**, sent on every request it makes to an origin matching the header's `originRules` — subresources, prefetches and service-worker requests included, `WebSocket` excluded. Not the same thing as `URLRequest.headers`, which apply to a single load. Profile state, so clear it when you are done |
| `PathHandler.dispose()` | Android | Release a `WebViewAssetLoader` path handler once no WebView's settings use it. The plugin never disposes one itself, because one handler can serve several WebViews and be passed to `setSettings` again. Safe to repeat; a disposed handler can't be reused, and its path then fails to load like a URL nothing serves |

### New fields on existing types

| Field | Platform | What it does |
| --- | --- | --- |
| `ProxyRule.relayHop1` / `.relayHop2` | iOS 17.0+ | Route a proxy rule through a chain of secure relays (RFC 9298) instead of a direct proxy endpoint |
| `NavigationAction.modifierFlags` / `.buttonNumber` | iOS | Which modifier keys and mouse button triggered a navigation |
| `NavigationAction.isContentRuleListRedirect` | iOS 26.0+ | Whether a content rule list redirected this navigation |
| `DownloadStartRequest.isUserInitiated` / `.originatingFrame` | iOS | Whether the user started the download, and which frame it came from |
| `WebViewPage` (new type) | Android | The payload of the page and Web-Vitals events: a synthesised `id` matching `WebViewNavigation.pageId`, plus the page's `url`. A page is a *document*, not a navigation — several navigations can share one |
| `WebViewNavigation` (new type) | Android | The payload of the three `onNavigation*` events: `statusCode`, `isBack`/`isForward`/`isReload`/`isRestore`/`isSameDocument`, `didCommit`, and a plugin-synthesised `id` tying the three events together |
| `WebsiteDataType.WKWebsiteDataTypeScreenTime` | iOS 26.0+ | Screen Time data. Deliberately **not** part of `WebsiteDataType.ALL` — passing it to a bulk delete terminates the app |
| `CustomHeader` (new type) | Android | The name/value/`originRules` triple `ProfileStore.addCustomHeader()` takes. `originRules` uses the same format as `addWebMessageListener`; a header whose rules match nothing is silently never sent |
| `WebResourceResponse.cookies` | Android | A list of `Set-Cookie` values applied as if the intercepted response had carried them. A **list**, because `headers` is a `Map` and cannot hold a repeated header name. **Silently ignored** unless cookie interception is enabled — nothing throws and nothing is logged |
| `CookieToSet` (new type) | Android, iOS | The input counterpart of `Cookie`, for `CookieManager.setCookies()`. A separate type on purpose: a cookie being written has a `url` and a `maxAge`, a cookie being read has neither and reports `isSessionOnly` instead |
| `WebMessageListener.contentWorld` | iOS | Creates the injected JavaScript object in an isolated `ContentWorld` instead of the page world, so page scripts cannot see or tamper with it. Defaults to the page world. Android **ignores** it: there `ContentWorld` is an `<iframe>` emulation, and `androidx`'s real isolated worlds have no "evaluate in world" entry point, so a listener placed in one would be unreachable from Dart |

> **One caveat, stated rather than buried.** `onWritingToolsActiveChanged` is implemented and its
> plumbing is verified, but it has **not yet been observed to fire on a real device**, and the cause
> is still being investigated — WebKit documents the underlying property as KVO-compliant, and this
> plugin already carries a note that a neighbouring KVO-compliant WebKit property does not reliably
> notify on iOS 26. Do not build on it until this line is removed.

## Resources

- The [API reference](https://pub.dev/documentation/nosferatu500_inappwebview/latest/) on pub.dev.
- The [integration tests](flutter_inappwebview/example/integration_test/), which exercise most of the API on Android and iOS.

## Requirements

- Dart sdk: "^3.13.0"
- Flutter: ">=3.47.0"
- Android: `minSdk >= 30`, [AGP](https://developer.android.com/build/releases/gradle-plugin) version `>= 9.0.0` (AGP 8 and lower are not supported), Gradle `>= 9.1.0`, JDK `>= 17`, Kotlin Gradle Plugin `>= 2.2.20` on the app's build classpath (Flutter 3.47's own minimum; AGP 9.3.0 through 9.4.1 bring 2.2.10, so declare it, as Flutter 3.47's app template does: `id("org.jetbrains.kotlin.android") version "2.4.0" apply false` in `settings.gradle(.kts)`) (use [Android Studio - Android Gradle plugin Upgrade Assistant](https://developer.android.com/build/agp-upgrade-assistant) for help)
- iOS 15.0+, **Xcode version `>= 27`** — the iOS module uses iOS 27 WebKit API, which only the iOS 27 SDK declares (on older iOS versions those features are skipped at runtime), and `isolated deinit` (SE-0371). Both need a newer toolchain than Flutter itself requires

## Installation

Add `nosferatu500_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/):

```sh
flutter pub add nosferatu500_inappwebview
```

Coming from upstream `flutter_inappwebview` 6.x? Follow the [migration guide](flutter_inappwebview/MIGRATION.md).

### Platform setup

See [Requirements](#requirements) above. The [migration guide](flutter_inappwebview/MIGRATION.md) lists the Android and iOS build settings in detail.

## Credits

This is a fork of [`flutter_inappwebview`](https://github.com/pichillilorenzo/flutter_inappwebview) by Lorenzo Pichilli. Thanks to him and to [upstream's contributors](https://github.com/pichillilorenzo/flutter_inappwebview#contributors-), whose work this fork carries.
