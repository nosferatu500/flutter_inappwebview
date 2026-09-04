<div align="center">

# Flutter InAppWebView Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappwebview&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappwebview)

![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/195422744-bdcfed16-73f0-4bc9-94ab-ecf10771a1c4.png)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-100-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![flutter_inappwebview version](https://img.shields.io/pub/v/flutter_inappwebview?include_prereleases)](https://pub.dartlang.org/packages/flutter_inappwebview)
[![Pub Points](https://img.shields.io/pub/points/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter-inappwebview)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project](https://img.shields.io/badge/support-donate-yellow.svg)](https://inappwebview.dev/donate/)
[![GitHub forks](https://img.shields.io/github/forks/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)
[![GitHub stars](https://img.shields.io/github/stars/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)

###### Supported Platforms

[![flutter_inappwebview_platform_interface version](https://img.shields.io/pub/v/flutter_inappwebview_platform_interface?include_prereleases&label=Platform%20Interface)](https://pub.dartlang.org/packages/flutter_inappwebview_platform_interface)
[![flutter_inappwebview_android version](https://img.shields.io/pub/v/flutter_inappwebview_android?include_prereleases&label=Android)](https://pub.dartlang.org/packages/flutter_inappwebview_android)
[![flutter_inappwebview_ios version](https://img.shields.io/pub/v/flutter_inappwebview_ios?include_prereleases&label=iOS)](https://pub.dartlang.org/packages/flutter_inappwebview_ios)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

</div>

## Why this fork

This is a fork of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview) by
Lorenzo Pichilli, carrying its full git history. It diverges at upstream's newest published
version, the prerelease **`6.2.0-beta.3` (February 2026)** — upstream's last *stable* release is
`6.1.5` — and the comparison below is against that. The public Dart API is recognisably the same;
what changed is the scope, the two native implementations, and what the plugin still carries.

|                        | upstream `6.2.0-beta.3`                      | this fork `7.0.0`                                                    |
| ---------------------- | -------------------------------------------- | -------------------------------------------------------------------- |
| Platforms              | 6 — Android, iOS, macOS, Windows, Linux, Web | **2 — Android, iOS**                                                 |
| Android implementation | Java                                         | **100% Kotlin**, all 157 sources translated                          |
| iOS implementation     | Swift 5                                      | **Swift 6 language mode**, complete concurrency checking             |
| Deprecated API         | 1111 `@Deprecated` (all 6 packages)          | **0** — every deprecated class, event, field and method gone         |
| Android `minSdk` / AGP | 19 / 8                                       | **30 / 9**                                                           |
| iOS deployment target  | 12.0                                         | **15.0**                                                             |
| Flutter / Dart floor   | 3.32 / `^3.8.0`                              | **3.44 / `^3.12.0`**                                                 |
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
module needs **Xcode 26 / Swift 6.2+** to build, because `isolated deinit` (SE-0371) is used at 32
sites — a consumer on Xcode 16 cannot build this plugin at all.

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
| `CookieManager.setCookieStoreObserver()` | iOS | Be told when the cookie store changes instead of polling. Carries no payload — re-read the store in the callback |
| `ServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled()` / getter | Android | The Service Worker twin of `includeCookiesOnShouldInterceptRequest`, and a **separate switch** — turning on the WebView one does nothing here. The getter returns `bool?`: `null` means the feature is missing **or** you passed a `profileName`, for which this setting does not exist at all |
| `ProfileStore.addCustomHeader()` / `.hasCustomHeader()` / `.getCustomHeaders()` / `.clearCustomHeader()` / `.clearAllCustomHeaders()` | Android | Headers attached to a **browsing profile**, sent on every request it makes to an origin matching the header's `originRules` — subresources, prefetches and service-worker requests included, `WebSocket` excluded. Not the same thing as `URLRequest.headers`, which apply to a single load. Profile state, so clear it when you are done |

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

> **One caveat, stated rather than buried.** `onWritingToolsActiveChanged` is implemented and its
> plumbing is verified, but it has **not yet been observed to fire on a real device**, and the cause
> is still being investigated — WebKit documents the underlying property as KVO-compliant, and this
> plugin already carries a note that a neighbouring KVO-compliant WebKit property does not reliably
> notify on iOS 26. Do not build on it until this line is removed.

## Articles/Resources

- [Official documentation: inappwebview.dev/docs](https://inappwebview.dev/docs/intro)
- Read the online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/) to get the **full API documentation**.
- [Official blog: inappwebview.dev/blog](https://inappwebview.dev/blog/)
- Find open source projects on the [Official Showcase page: inappwebview.dev/showcase](https://inappwebview.dev/showcase/)
- Check the [flutter_inappwebview_examples](https://github.com/pichillilorenzo/flutter_inappwebview_examples) repository for project examples
- Check the [flutter_inappwebview/example/integration_test/webview_flutter_test.dart](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/flutter_inappwebview/example/integration_test/webview_flutter_test.dart) file for other code examples
- [Flutter Browser App](https://github.com/pichillilorenzo/flutter_browser_app): A Full-Featured Mobile Browser App (such as the Google Chrome mobile browser) created using Flutter and the features offered by the flutter_inappwebview plugin

## Showcase - Who use it

Check the [Showcase](https://inappwebview.dev/showcase/) page to see an open list of Apps built with **Flutter** and **Flutter InAppWebView**.

#### Are you using the **Flutter InAppWebView** plugin and would you like to add your App there?

Send a submission request to the [Submit App](https://inappwebview.dev/submit-app/) page!

## Requirements

- Dart sdk: "^3.12.0"
- Flutter: ">=3.44.0"
- Android: `minSdk >= 30`, [AGP](https://developer.android.com/build/releases/gradle-plugin) version `>= 9.0.0` (AGP 8 and lower are not supported), Gradle `>= 9.1.0`, JDK `>= 17` (use [Android Studio - Android Gradle plugin Upgrade Assistant](https://developer.android.com/build/agp-upgrade-assistant) for help)
- iOS 15.0+, **Xcode version `>= 26`** — the iOS module uses `isolated deinit` (SE-0371) and needs a Swift 6.2+ compiler, which is a newer toolchain than Flutter itself requires

## Installation

Add `flutter_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### Platform Installation Setup:
- [Android](https://inappwebview.dev/docs/intro/#setup-android)
- [iOS](https://inappwebview.dev/docs/intro/#setup-ios)

## Support

Did you find this plugin useful? Please consider to [make a donation](https://inappwebview.dev/donate/) to help improve it!

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://blog.alexv525.com/"><img src="https://avatars.githubusercontent.com/u/15884415?v=4?s=100" width="100px;" alt="Alex Li"/><br /><sub><b>Alex Li</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AlexV525" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/crazecoder"><img src="https://avatars.githubusercontent.com/u/18387906?v=4?s=100" width="100px;" alt="1/2"/><br /><sub><b>1/2</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=crazecoder" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cbodin"><img src="https://avatars.githubusercontent.com/u/220255?v=4?s=100" width="100px;" alt="Christofer Bodin"/><br /><sub><b>Christofer Bodin</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cbodin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/matthewlloyd"><img src="https://avatars.githubusercontent.com/u/2041996?v=4?s=100" width="100px;" alt="Matthew Lloyd"/><br /><sub><b>Matthew Lloyd</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=matthewlloyd" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/carloserazo47"><img src="https://avatars.githubusercontent.com/u/83635384?v=4?s=100" width="100px;" alt="C E"/><br /><sub><b>C E</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=carloserazo47" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/robsonmeemo"><img src="https://avatars.githubusercontent.com/u/47990393?v=4?s=100" width="100px;" alt="Robson Araujo"/><br /><sub><b>Robson Araujo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=robsonmeemo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ryanhz"><img src="https://avatars.githubusercontent.com/u/1142612?v=4?s=100" width="100px;" alt="Ryan"/><br /><sub><b>Ryan</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ryanhz" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://codeeagle.github.io/"><img src="https://avatars.githubusercontent.com/u/2311352?v=4?s=100" width="100px;" alt="CodeEagle"/><br /><sub><b>CodeEagle</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=CodeEagle" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tneotia"><img src="https://avatars.githubusercontent.com/u/50850142?v=4?s=100" width="100px;" alt="Tanay Neotia"/><br /><sub><b>Tanay Neotia</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=tneotia" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/panndoraBoo"><img src="https://avatars.githubusercontent.com/u/8928207?v=4?s=100" width="100px;" alt="Jamie Joost"/><br /><sub><b>Jamie Joost</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=panndoraBoo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://deandreamatias.com/"><img src="https://avatars.githubusercontent.com/u/21011641?v=4?s=100" width="100px;" alt="Matias de Andrea"/><br /><sub><b>Matias de Andrea</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=deandreamatias" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://blog.csdn.net/j550341130"><img src="https://avatars.githubusercontent.com/u/17899073?v=4?s=100" width="100px;" alt="YouCii"/><br /><sub><b>YouCii</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=YouCii" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cutzmf"><img src="https://avatars.githubusercontent.com/u/1662033?v=4?s=100" width="100px;" alt="Salnikov Sergey"/><br /><sub><b>Salnikov Sergey</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cutzmf" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/a00012025"><img src="https://avatars.githubusercontent.com/u/12824216?v=4?s=100" width="100px;" alt="Po-Jui Chen"/><br /><sub><b>Po-Jui Chen</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=a00012025" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Manuito83"><img src="https://avatars.githubusercontent.com/u/4816367?v=4?s=100" width="100px;" alt="Manuito"/><br /><sub><b>Manuito</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Manuito83" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/setcy"><img src="https://avatars.githubusercontent.com/u/86180691?v=4?s=100" width="100px;" alt="setcy"/><br /><sub><b>setcy</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=setcy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/EArminjon2"><img src="https://avatars.githubusercontent.com/u/92172436?v=4?s=100" width="100px;" alt="EArminjon"/><br /><sub><b>EArminjon</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=EArminjon2" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/ashank-bharati-497989127/"><img src="https://avatars.githubusercontent.com/u/22197948?v=4?s=100" width="100px;" alt="Ashank Bharati"/><br /><sub><b>Ashank Bharati</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ashank96" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://dart.art/"><img src="https://avatars.githubusercontent.com/u/1755207?v=4?s=100" width="100px;" alt="Michael Chow"/><br /><sub><b>Michael Chow</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chownation" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RodXander"><img src="https://avatars.githubusercontent.com/u/23609784?v=4?s=100" width="100px;" alt="Osvaldo Saez"/><br /><sub><b>Osvaldo Saez</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=RodXander" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rsydor"><img src="https://avatars.githubusercontent.com/u/79581663?v=4?s=100" width="100px;" alt="rsydor"/><br /><sub><b>rsydor</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=rsydor" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hoanglm4"><img src="https://avatars.githubusercontent.com/u/7067757?v=4?s=100" width="100px;" alt="Le Minh Hoang"/><br /><sub><b>Le Minh Hoang</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=hoanglm4" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Miiha"><img src="https://avatars.githubusercontent.com/u/3897167?v=4?s=100" width="100px;" alt="Michael Kao"/><br /><sub><b>Michael Kao</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Miiha" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cloudygeek"><img src="https://avatars.githubusercontent.com/u/6059542?v=4?s=100" width="100px;" alt="cloudygeek"/><br /><sub><b>cloudygeek</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cloudygeek" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/chreck"><img src="https://avatars.githubusercontent.com/u/8030398?v=4?s=100" width="100px;" alt="Christoph Eck"/><br /><sub><b>Christoph Eck</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chreck" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Ser1ous"><img src="https://avatars.githubusercontent.com/u/4497968?v=4?s=100" width="100px;" alt="Ser1ous"/><br /><sub><b>Ser1ous</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Ser1ous" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://spacelaunchnow.me/"><img src="https://avatars.githubusercontent.com/u/4519230?v=4?s=100" width="100px;" alt="Caleb Jones"/><br /><sub><b>Caleb Jones</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ItsCalebJones" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://sungazer.io/"><img src="https://avatars.githubusercontent.com/u/6215122?v=4?s=100" width="100px;" alt="Saverio Murgia"/><br /><sub><b>Saverio Murgia</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=savy-91" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tranductam2802"><img src="https://avatars.githubusercontent.com/u/4957579?v=4?s=100" width="100px;" alt="Trần Đức Tâm"/><br /><sub><b>Trần Đức Tâm</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=tranductam2802" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://pcqpcq.me/"><img src="https://avatars.githubusercontent.com/u/1411571?v=4?s=100" width="100px;" alt="Joker"/><br /><sub><b>Joker</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=pcqpcq" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/ycv005/"><img src="https://avatars.githubusercontent.com/u/26734819?v=4?s=100" width="100px;" alt="Yash Chandra Verma"/><br /><sub><b>Yash Chandra Verma</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ycv005" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arneke"><img src="https://avatars.githubusercontent.com/u/425235?v=4?s=100" width="100px;" alt="Arne Kepp"/><br /><sub><b>Arne Kepp</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=arneke" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://omralcrt.github.io/"><img src="https://avatars.githubusercontent.com/u/12418327?v=4?s=100" width="100px;" alt="Ömral Cörüt"/><br /><sub><b>Ömral Cörüt</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=omralcrt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/albatrosify"><img src="https://avatars.githubusercontent.com/u/64252708?v=4?s=100" width="100px;" alt="LrdHelmchen"/><br /><sub><b>LrdHelmchen</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=albatrosify" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://ungapps.com/"><img src="https://avatars.githubusercontent.com/u/8141036?v=4?s=100" width="100px;" alt="Steven Gunanto"/><br /><sub><b>Steven Gunanto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=gunantosteven" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://schlau.bi/"><img src="https://avatars.githubusercontent.com/u/16060205?v=4?s=100" width="100px;" alt="Michael Rittmeister"/><br /><sub><b>Michael Rittmeister</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=DRSchlaubi" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://aakira.app/"><img src="https://avatars.githubusercontent.com/u/3386962?v=4?s=100" width="100px;" alt="Akira Aratani"/><br /><sub><b>Akira Aratani</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AAkira" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Doflatango"><img src="https://avatars.githubusercontent.com/u/3091033?v=4?s=100" width="100px;" alt="Doflatango"/><br /><sub><b>Doflatango</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Doflatango" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Eddayy"><img src="https://avatars.githubusercontent.com/u/17043852?v=4?s=100" width="100px;" alt="Edmund Tay"/><br /><sub><b>Edmund Tay</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Eddayy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://andreidiaconu.com/"><img src="https://avatars.githubusercontent.com/u/1402046?v=4?s=100" width="100px;" alt="Andrei Diaconu"/><br /><sub><b>Andrei Diaconu</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=andreidiaconu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/plateaukao"><img src="https://avatars.githubusercontent.com/u/4084738?v=4?s=100" width="100px;" alt="Daniel Kao"/><br /><sub><b>Daniel Kao</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=plateaukao" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xtyxtyx"><img src="https://avatars.githubusercontent.com/u/15033141?v=4?s=100" width="100px;" alt="xuty"/><br /><sub><b>xuty</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=xtyxtyx" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://bieker.ninja/"><img src="https://avatars.githubusercontent.com/u/818880?v=4?s=100" width="100px;" alt="Ben Bieker"/><br /><sub><b>Ben Bieker</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=wwwdata" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/phamnhuvu-dev"><img src="https://avatars.githubusercontent.com/u/22906656?v=4?s=100" width="100px;" alt="Phạm Như Vũ"/><br /><sub><b>Phạm Như Vũ</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=phamnhuvu-dev" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SebastienBtr"><img src="https://avatars.githubusercontent.com/u/18089010?v=4?s=100" width="100px;" alt="SebastienBtr"/><br /><sub><b>SebastienBtr</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=SebastienBtr" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fattiger00"><img src="https://avatars.githubusercontent.com/u/38494401?v=4?s=100" width="100px;" alt="NeZha"/><br /><sub><b>NeZha</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=fattiger00" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/klydra"><img src="https://avatars.githubusercontent.com/u/40038209?v=4?s=100" width="100px;" alt="Jan Klinge"/><br /><sub><b>Jan Klinge</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=klydra" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/PauloDurrerMelo"><img src="https://avatars.githubusercontent.com/u/29310557?v=4?s=100" width="100px;" alt="PauloDurrerMelo"/><br /><sub><b>PauloDurrerMelo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=PauloDurrerMelo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/benmeemo"><img src="https://avatars.githubusercontent.com/u/47991706?v=4?s=100" width="100px;" alt="benmeemo"/><br /><sub><b>benmeemo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=benmeemo" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cinos1"><img src="https://avatars.githubusercontent.com/u/19343437?v=4?s=100" width="100px;" alt="cinos"/><br /><sub><b>cinos</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cinos1" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://xraph.com/"><img src="https://avatars.githubusercontent.com/u/11243590?v=4?s=100" width="100px;" alt="Rex Raphael"/><br /><sub><b>Rex Raphael</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=juicycleff" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Sense545"><img src="https://avatars.githubusercontent.com/u/769406?v=4?s=100" width="100px;" alt="Jan Henrik Høiland"/><br /><sub><b>Jan Henrik Høiland</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Sense545" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/igtm"><img src="https://avatars.githubusercontent.com/u/6331737?v=4?s=100" width="100px;" alt="Iguchi Tomokatsu"/><br /><sub><b>Iguchi Tomokatsu</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=igtm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://uekoetter.dev/"><img src="https://avatars.githubusercontent.com/u/1270149?v=4?s=100" width="100px;" alt="Jonas Uekötter"/><br /><sub><b>Jonas Uekötter</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ueman" title="Documentation">📖</a> <a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ueman" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/emakar"><img src="https://avatars.githubusercontent.com/u/7767193?v=4?s=100" width="100px;" alt="emakar"/><br /><sub><b>emakar</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=emakar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://weibo.com/magicrolan"><img src="https://avatars.githubusercontent.com/u/671431?v=4?s=100" width="100px;" alt="liasica"/><br /><sub><b>liasica</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=liasica" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/addie9000"><img src="https://avatars.githubusercontent.com/u/2036910?v=4?s=100" width="100px;" alt="Eiichiro Adachi"/><br /><sub><b>Eiichiro Adachi</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=addie9000" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kamilpowalowski"><img src="https://avatars.githubusercontent.com/u/83073?v=4?s=100" width="100px;" alt="Kamil Powałowski"/><br /><sub><b>Kamil Powałowski</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=kamilpowalowski" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/akioyamamoto1977"><img src="https://avatars.githubusercontent.com/u/429219?v=4?s=100" width="100px;" alt="Akio Yamamoto"/><br /><sub><b>Akio Yamamoto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=akioyamamoto1977" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mohenaxiba"><img src="https://avatars.githubusercontent.com/u/7977540?v=4?s=100" width="100px;" alt="mohenaxiba"/><br /><sub><b>mohenaxiba</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=mohenaxiba" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.acidic.co.nz"><img src="https://avatars.githubusercontent.com/u/1319813?v=4?s=100" width="100px;" alt="Ben Anderson"/><br /><sub><b>Ben Anderson</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=bagedevimo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/daanporon"><img src="https://avatars.githubusercontent.com/u/71901?v=4?s=100" width="100px;" alt="Daan Poron"/><br /><sub><b>Daan Poron</b></sub></a><br /><a href="#security-daanporon" title="Security">🛡️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://yuki0311.com"><img src="https://avatars.githubusercontent.com/u/34892635?v=4?s=100" width="100px;" alt="ふぁ"/><br /><sub><b>ふぁ</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=fa0311" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/perffecto"><img src="https://avatars.githubusercontent.com/u/2116618?v=4?s=100" width="100px;" alt="perffecto"/><br /><sub><b>perffecto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=perffecto" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/chandra-abdul-fattah"><img src="https://avatars.githubusercontent.com/u/16184998?v=4?s=100" width="100px;" alt="Chandra Abdul Fattah"/><br /><sub><b>Chandra Abdul Fattah</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chandrabezzo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.bebilica.rs/"><img src="https://avatars.githubusercontent.com/u/41632269?v=4?s=100" width="100px;" alt="Aleksandar Lugonja"/><br /><sub><b>Aleksandar Lugonja</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=LugonjaAleksandar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.hera.cc"><img src="https://avatars.githubusercontent.com/u/534840?v=4?s=100" width="100px;" alt="Alexandre Richonnier"/><br /><sub><b>Alexandre Richonnier</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=heralight" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Sunbreak"><img src="https://avatars.githubusercontent.com/u/7928961?v=4?s=100" width="100px;" alt="Sunbreak"/><br /><sub><b>Sunbreak</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Sunbreak" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cslee"><img src="https://avatars.githubusercontent.com/u/590752?v=4?s=100" width="100px;" alt="Eric Lee"/><br /><sub><b>Eric Lee</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cslee" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KhatibFX"><img src="https://avatars.githubusercontent.com/u/5616640?v=4?s=100" width="100px;" alt="KhatibFX"/><br /><sub><b>KhatibFX</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=KhatibFX" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.guide.inc"><img src="https://avatars.githubusercontent.com/u/106543148?v=4?s=100" width="100px;" alt="Guide.inc"/><br /><sub><b>Guide.inc</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=guide-flutter" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Nirajn2311"><img src="https://avatars.githubusercontent.com/u/36357875?v=4?s=100" width="100px;" alt="Niraj Nandish"/><br /><sub><b>Niraj Nandish</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Nirajn2311" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nesquikm"><img src="https://avatars.githubusercontent.com/u/3867874?v=4?s=100" width="100px;" alt="nesquikm"/><br /><sub><b>nesquikm</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=nesquikm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/andreasgangso"><img src="https://avatars.githubusercontent.com/u/727125?v=4?s=100" width="100px;" alt="Andreas Gangsø"/><br /><sub><b>Andreas Gangsø</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=andreasgangso" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AlexT84"><img src="https://avatars.githubusercontent.com/u/80742383?v=4?s=100" width="100px;" alt="Alexandru Terente"/><br /><sub><b>Alexandru Terente</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AlexT84" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/darkang3lz92"><img src="https://avatars.githubusercontent.com/u/33158127?v=4?s=100" width="100px;" alt="Dango Mango"/><br /><sub><b>Dango Mango</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=darkang3lz92" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://medium.com/@m-zimmermann1"><img src="https://avatars.githubusercontent.com/u/72440045?v=4?s=100" width="100px;" alt="Max Zimmermann"/><br /><sub><b>Max Zimmermann</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=maxmitz" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/alexandru-dochioiu/"><img src="https://avatars.githubusercontent.com/u/38853913?v=4?s=100" width="100px;" alt="Alexandru Dochioiu"/><br /><sub><b>Alexandru Dochioiu</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AlexDochioiu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/YumengNevix"><img src="https://avatars.githubusercontent.com/u/137131451?v=4?s=100" width="100px;" alt="YumengNevix"/><br /><sub><b>YumengNevix</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=YumengNevix" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lrorpilla"><img src="https://avatars.githubusercontent.com/u/11363922?v=4?s=100" width="100px;" alt="lrorpilla"/><br /><sub><b>lrorpilla</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=lrorpilla" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/michalsrutek"><img src="https://avatars.githubusercontent.com/u/35694712?v=4?s=100" width="100px;" alt="Michal Šrůtek"/><br /><sub><b>Michal Šrůtek</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=michalsrutek" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/daisukeueta"><img src="https://avatars.githubusercontent.com/u/122339799?v=4?s=100" width="100px;" alt="daisukeueta"/><br /><sub><b>daisukeueta</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=daisukeueta" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gmackall"><img src="https://avatars.githubusercontent.com/u/34871572?v=4?s=100" width="100px;" alt="Gray Mackall"/><br /><sub><b>Gray Mackall</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=gmackall" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/p-mazhnik"><img src="https://avatars.githubusercontent.com/u/25964451?v=4?s=100" width="100px;" alt="Pavel Mazhnik"/><br /><sub><b>Pavel Mazhnik</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=p-mazhnik" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://nlog.dev"><img src="https://avatars.githubusercontent.com/u/20399222?v=4?s=100" width="100px;" alt="nlog (solrin)"/><br /><sub><b>nlog (solrin)</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=nnnlog" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Murmurl912"><img src="https://avatars.githubusercontent.com/u/36264246?v=4?s=100" width="100px;" alt="Murmurl912"/><br /><sub><b>Murmurl912</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Murmurl912" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bschulz87"><img src="https://avatars.githubusercontent.com/u/30199362?v=4?s=100" width="100px;" alt="Benjamin Schulz"/><br /><sub><b>Benjamin Schulz</b></sub></a><br /><a href="#ideas-bschulz87" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ShuheiSuzuki-07"><img src="https://avatars.githubusercontent.com/u/118415919?v=4?s=100" width="100px;" alt="seal-app"/><br /><sub><b>seal-app</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ShuheiSuzuki-07" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/takuyaaaaaaahaaaaaa"><img src="https://avatars.githubusercontent.com/u/31458194?v=4?s=100" width="100px;" alt="Takuya Tominaga"/><br /><sub><b>Takuya Tominaga</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=takuyaaaaaaahaaaaaa" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/yamaha252"><img src="https://avatars.githubusercontent.com/u/4444068?v=4?s=100" width="100px;" alt="Sergey"/><br /><sub><b>Sergey</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=yamaha252" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lyb5834"><img src="https://avatars.githubusercontent.com/u/16265810?v=4?s=100" width="100px;" alt="yuanbo li"/><br /><sub><b>yuanbo li</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=lyb5834" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Mecharyry"><img src="https://avatars.githubusercontent.com/u/3380092?v=4?s=100" width="100px;" alt="Ryan Feline"/><br /><sub><b>Ryan Feline</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Mecharyry" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://fuzzybinary.com"><img src="https://avatars.githubusercontent.com/u/249982?v=4?s=100" width="100px;" alt="Jeff Ward"/><br /><sub><b>Jeff Ward</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=fuzzybinary" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://hero.io"><img src="https://avatars.githubusercontent.com/u/33483071?v=4?s=100" width="100px;" alt="Yelzhan Yerkebulan"/><br /><sub><b>Yelzhan Yerkebulan</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=yerkejs" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GooRingX"><img src="https://avatars.githubusercontent.com/u/167741400?v=4?s=100" width="100px;" alt="GooRingX"/><br /><sub><b>GooRingX</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=GooRingX" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/roberthofstra"><img src="https://avatars.githubusercontent.com/u/1643242?v=4?s=100" width="100px;" alt="Robodoh"/><br /><sub><b>Robodoh</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=roberthofstra" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/imoyakin"><img src="https://avatars.githubusercontent.com/u/7473806?v=4?s=100" width="100px;" alt="imoyakin"/><br /><sub><b>imoyakin</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=imoyakin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/laishere"><img src="https://avatars.githubusercontent.com/u/23557738?v=4?s=100" width="100px;" alt="laishere"/><br /><sub><b>laishere</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=laishere" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/muccy-timeware"><img src="https://avatars.githubusercontent.com/u/74927063?v=4?s=100" width="100px;" alt="Marco Muccinelli"/><br /><sub><b>Marco Muccinelli</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=muccy-timeware" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/momadvisor"><img src="https://avatars.githubusercontent.com/u/77181890?v=4?s=100" width="100px;" alt="momadvisor"/><br /><sub><b>momadvisor</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=momadvisor" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
