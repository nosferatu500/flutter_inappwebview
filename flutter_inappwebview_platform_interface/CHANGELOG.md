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
  `isBlockedByScreenTime`, `setConversationContext`, `getConversationContext`
- **`PlatformInAppWebViewController.isBlockedByScreenTime`** returns `Future<bool?>`, and the
  nullability is part of the contract rather than defensive: `null` means *the platform cannot
  answer* — every platform but iOS, and iOS below 26.0, where
  `WKWebView.isBlockedByScreenTime` does not exist. `false` means *asked, and not blocked*. There is
  no change event for it: WebKit does not document the property as KVO-compliant, so it is a getter
  a caller polls, and it describes the current *content* rather than the WebView
- `PlatformCookieManager`: `setAcceptCookie`, `isAcceptCookieEnabled`, `hasCookies`,
  `isFileSchemeCookiesAllowed`
- `PlatformWebStorageManager`: `deleteBrowsingData`, `deleteBrowsingDataForSite`
- `InAppWebViewSettings` (15): `attributionRegistrationBehavior`, `backForwardCacheEnabled`,
  `downloadFaviconsEnabled`, `lockdownModeEnabled`, `obscuredContentInsets`,
  `paymentRequestEnabled`, `preferredHTTPSNavigationPolicy`, `profileName`,
  `securityRestrictionMode`, `showsSystemScreenTimeBlockingView`, `supportsAdaptiveImageGlyph`,
  `userAgentMetadata`, `webAuthenticationSupport`, `webViewMediaIntegrityApiStatus`,
  `writingToolsBehavior`
- **`InAppWebViewSettings.obscuredContentInsets`** (iOS 26.0+), typed `EdgeInsets?`. Insets that
  shrink the page's layout viewport where the app draws its own chrome. The constructor **asserts
  all four sides are non-negative**, which is WebKit's stated requirement; an assert is debug-only,
  so the dartdoc states the requirement as well. It is the **only** iOS 26.0 setting that responds
  to `setSettings` — a `WKWebView` property, not a `WKWebViewConfiguration` one. What the page
  observes is **not** characterised: the integration suite could not measure it consistently, so the
  dartdoc reports WebKit's own description and explicitly declines to claim a relationship to
  `env(safe-area-inset-*)`
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
- **`ConversationContext`, `ConversationEntry` and `PersonNameComponents`** (iOS 26.0+), for
  `PlatformInAppWebViewController.setConversationContext`. `ConversationEntry` types its four
  natively-required fields as nullable on purpose — a malformed map must not crash the bridge, and
  the **native side drops** an incomplete entry rather than sending it half-built.
  `PersonNameComponents` models the six flat name parts and deliberately omits
  `NSPersonNameComponents.phoneticRepresentation`, which is recursive and unread on this path
- **Generator fix, found by the first field to need it:** a `Map<K, V>` whose value is an
  exchangeable type emitted a `fromMap` that **threw at runtime** — `map['x'].entries.map(...)` is a
  *dynamic* dispatch, so the closure's return type was discarded and `Map.fromEntries` received a
  `MappedIterable<..., dynamic>`. The emitter now casts the source and gives `.map` an explicit type
  argument. The branch had existed since the enum-valued-map fix and had **no production user at
  all** until `ConversationContext.participantNameByIdentifier`; a generator test now covers it
- **`PlatformWebViewCreationParams.onInsertInputSuggestion`** and the matching
  `PlatformInAppBrowserEvents.onInsertInputSuggestion` (iOS 26.0+), with the **`InputSuggestion`**
  type and **`InAppWebViewSettings.useOnInsertInputSuggestion`**. `InputSuggestion` has exactly one
  field, `smartReply`, because `UIInputSuggestion` has none and its single subclass has one; a unit
  test pins the field set so that growing it is a deliberate act. The setting is a **selector gate**
  rather than an event filter — while it is off the native side reports that it does not implement
  the delegate method, leaving WebKit's own behaviour untouched — and it is inferred as `true` when
  the event handler is supplied and the setting is `null`, except on `PlatformInAppBrowser`
- **`PlatformWebViewCreationParams.shouldGoToBackForwardListItem`** and the matching
  `PlatformInAppBrowserEvents.shouldGoToBackForwardListItem` (iOS 26.0+), with the new
  **`ShouldGoToBackForwardListItemAction`** enum (`CANCEL` = 0, `ALLOW` = 1, matching the `BOOL`
  completion handler) and **`InAppWebViewSettings.useShouldGoToBackForwardListItem`**. The payload
  reuses the existing `WebHistoryItem` rather than adding a type; its `index`/`offset` are nullable
  because the native side has to *locate* the item in the current back/forward list and may not find
  it. The gate follows `useShouldOverrideUrlLoading`, not `useOnInsertInputSuggestion`: it is checked
  inside the delegate rather than hiding the selector, because answering `true` immediately is
  already identical to not implementing the method
- **`PlatformWebViewCreationParams.onWritingToolsActiveChanged`** and the matching
  `PlatformInAppBrowserEvents.onWritingToolsActiveChanged` (iOS 18.0+), from
  `WKWebView.writingToolsActive`. Payload is a bare `bool active` — no new type, because WebKit
  exposes no reason, no range and no tool identity. **Modelled as an event, not a getter**: the
  property is read-only and documented KVO-compliant, so the plugin observes it and pushes, rather
  than offering something a caller would have to poll. The native side sends only on a real change
  (KVO fires on every set, not only on sets that alter the value), so the old value is always the
  negation of the new one and is not carried. **No `InAppWebViewSettings` gate**, unlike
  `useOnInsertInputSuggestion`: a KVO observer is passive and changes nothing about WebKit's own
  behaviour, so §46's all-or-nothing hazard does not apply here
- **`PlatformWebViewCreationParams.onNavigationStarted` / `.onNavigationRedirected` /
  `.onNavigationCompleted`** and the matching `PlatformInAppBrowserEvents` methods (Android), from
  `androidx.webkit.NavigationListener`, with the new **`WebViewNavigation`** type,
  **`InAppWebViewSettings.useNavigationListener`** and the **`WebViewFeature.NAVIGATION_LISTENER`**
  and **`WebViewFeature.NAVIGATION_GET_WEB_RESOURCE_ERROR`** constants.

  `WebViewNavigation` is a **snapshot**, and it has to be: androidx hands the same `Navigation`
  object to all three callbacks — the peers are interned by `getOrCreatePeer`, so object identity is
  what ties them together — and mutates it in place, so `url`, `didCommit` and `statusCode` answer
  differently at different points in one navigation. Object identity cannot cross a method channel,
  so the Kotlin side synthesises **`WebViewNavigation.id`** from an identity map and it is that id,
  not the object, that connects the three events. `pageId` is synthesised the same way but has a
  different lifetime: a navigation id is released at `onNavigationCompleted`, a page id only when
  the page is deleted, which for a back/forward-cached page may never happen.

  `statusCode` is the single biggest addition: it is the **only** way to see the HTTP status of a
  navigation that *succeeded*, since `onReceivedHttpError` fires only for error responses. It is
  `null` until the navigation commits rather than a fabricated `0`. `webResourceError` sits behind
  its own second feature check, finer than the one gating the events themselves
- **`PlatformWebViewCreationParams.onPageLoadEvent` / `.onPageDomContentLoadedEvent` /
  `.onPageDeleted` / `.onFirstContentfulPaintMillis` / `.onLargestContentfulPaintMillis` /
  `.onPerformanceMarkMillis`** and the matching `PlatformInAppBrowserEvents` methods (Android), from
  the same `androidx.webkit.NavigationListener`, with the new **`WebViewPage`** type and
  **`InAppWebViewSettings.useOnPerformanceMarkMillis`**.

  `WebViewPage` is a *document*, not a navigation: several navigations can share one page, and a
  back/forward-cached page outlives the navigation that created it.
  `WebViewPage.id` is synthesised from the same identity map as
  `WebViewNavigation.pageId`, and those two numbers are how a page event is correlated with the
  navigation that produced it. Its lifetime is different too — a navigation id is released at
  `onNavigationCompleted`, a page id only at `onPageDeleted`, which for a cached page may never
  arrive.

  **`onPerformanceMarkMillis` is the only event in the family with a gate of its own**, and the
  reason is frequency rather than safety: every other event here is bounded at roughly one per page,
  while `performance.mark()` is called by the page as often as it likes. Supplying a handler for any
  of the other eight infers `useNavigationListener` and **not** this one, so opting into
  `DOMContentLoaded` cannot silently start charging a channel message per mark. An integration test
  asserts the suppression with the handler present and the gate explicitly off, which is the only
  configuration in which the gate is the sole thing standing in the way.

  Two platform details the parameter names carry: `onFirstContentfulPaintMillis` and
  `onLargestContentfulPaintMillis` report a **duration** (`durationMillis`) while
  `onPerformanceMarkMillis` reports a **time** (`markTimeMillis`); and LCP can fire **more than
  once** per page, since it is defined against the largest element painted so far
- **`PlatformWebViewCreationParams.onRequestVisitedHistory`** and the matching
  `PlatformInAppBrowserEvents.onRequestVisitedHistory` (Android), from
  `WebChromeClient.getVisitedHistory`. A reply-shaped event: return
  `FutureOr<List<WebUri>?>` and the engine uses it for `:visited` link styling.

  **The three return states are distinct and the platform acts on each differently.** A list is
  forwarded as a `String[]`; **`null` keeps the platform default**, where the engine's callback is
  left unanswered exactly as it is for a `WebView` without this plugin; an **empty list** is a real
  answer meaning "nothing has been visited". Collapsing `null` into `[]` anywhere would erase that
  difference invisibly — both render identically — so unit tests pin it on the Dart side and on the
  Kotlin decode.

  Named `onRequestVisitedHistory` rather than mirroring the platform's `getVisitedHistory`: this is
  a callback the app implements, and a `getX` name sitting among a controller full of real `getX()`
  methods would read as something the app calls
- **`PlatformInAppWebViewController.saveState` gained `maxSize` and `includeForwardState`**
  (Android), from `WebViewCompat.saveState`, plus the `WebViewFeature.SAVE_STATE` mirror that gates
  them. Both are optional and additive: **called with neither, the method is unchanged** and still
  uses the framework `WebView.saveState`, which requires no feature.

  The reason to have them is that the existing call is **unbounded**, which nothing said. Measured
  on Android 13 and Android 17 (WebView 151 / 149), a 9-entry history of large `data:` URLs
  serialised to **2.0 MB**, growing linearly with no ceiling and never failing — awkward if the
  bytes then have to cross something with a limit of its own, such as an Android `Bundle` in a
  Binder transaction.

  Three measured behaviours the androidx javadoc does not state, all pinned by tests:
  **back history is kept in preference to forward history** (with `maxSize` set, forward entries go
  first even when `includeForwardState` is `true`); **if not even the current entry fits, nothing is
  saved and the call returns `null`** rather than a smaller state; and **`maxSize` is not a hard cap
  on the returned array** — it bounds the WebView's own state, which is then wrapped in a marshalled
  `Bundle`, so the result can be a few dozen bytes over (measured at 602900 for a requested 602860).

  Where `SAVE_STATE` is unsupported, passing either argument returns `null` instead of falling back
  to an unconstrained state: a caller that asked for a bound never silently receives an unbounded
  one. `WebViewCompat.saveState` with no effective limits was verified byte-for-byte identical to
  the framework call, which is why the unconstrained path was left alone rather than routed through
  the compat API.

- **`InAppWebViewSettings.includeCookiesOnShouldInterceptRequest` and
  `WebResourceResponse.cookies`** (Android), from `androidx.webkit`'s `COOKIE_INTERCEPT` — plus the
  `WebViewFeature.COOKIE_INTERCEPT` mirror. One switch covers **both directions** of an intercept:

  - **in** — `WebResourceRequest.headers` gains the `Cookie` entry the WebView would have sent.
    Nothing else can supply this: `CookieManager.getCookies` answers about a *url*, not about a
    request, so it cannot know the request's own context and can return the wrong set.
  - **out** — `WebResourceResponse.cookies` is a list of `Set-Cookie` values applied as if the
    intercepted response had carried them. It is a **list** because `headers` is a `Map` and cannot
    hold a repeated header name, so a single `Set-Cookie` entry there can only ever set one cookie.

  **With the switch off, `cookies` is silently ignored** — nothing throws and nothing is logged, so
  both halves are pinned by paired integration tests that differ by one argument.

  The setting is nullable and defaults to `null` ("leave the WebView's own value"), because androidx
  documents no default. The default was **measured** as `false` on WebView 149 and 151, and
  `getSettings()` reports what the WebView actually has rather than what was requested.

  This covers the `WebView` only. The service-worker half of the same androidx feature is a separate
  switch and is not in this entry.

- **`PlatformServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled` /
  `.getIncludeCookiesOnShouldInterceptRequestEnabled`** (Android), completing `COOKIE_INTERCEPT`.
  The Service Worker twin of `InAppWebViewSettings.includeCookiesOnShouldInterceptRequest`, and a
  **separate switch** — enabling one does nothing for the other.

  The getter returns `bool?`, deliberately unlike its neighbours `getAllowContentAccess` /
  `getAllowFileAccess` / `getBlockNetworkLoads`, which collapse "unavailable" into `false`. Here
  `null` has **two** causes and there is also a real `false`, so flattening them would lose a state:
  the feature may be unsupported by the installed WebView, **or** a `profileName` was given.

  **The switch does not exist for a named profile, structurally rather than by version.** The whole
  cookie-intercept API is `androidx`-only, and a named profile's Service Worker settings are
  reachable only through the framework's `android.webkit.ServiceWorkerWebSettings`, which declares
  exactly the four older settings and nothing else. No future WebView opens this — there is nothing
  to call — so the getter answers `null` and the setter is a no-op there.

- **The custom-request-header family on `PlatformProfileStore`** (Android), from `androidx.webkit`'s
  `CUSTOM_REQUEST_HEADERS`, plus the new `CustomHeader` type and the
  `WebViewFeature.CUSTOM_REQUEST_HEADERS` mirror: `addCustomHeader`, `hasCustomHeader`,
  `getCustomHeaders`, `clearCustomHeader`, `clearAllCustomHeaders`, each taking the optional
  `profileName` every profile-scoped surface here takes.

  **These are not per-request headers.** They are attached to a *browsing profile* and sent on every
  request it makes to an origin matching the header's `originRules` — subresources, prefetches and
  service-worker requests included, `WebSocket` excluded. That is a different thing from
  `URLRequest.headers`, which apply to one load. Headers added this way also appear in the request
  handed to `shouldInterceptRequest`.

  `originRules` uses the same format as `addWebMessageListener`'s allowed origin rules. A header
  whose rules match nothing is simply never sent; nothing throws.

  **The androidx methods live on `Profile`, which this plugin does not expose as an object** — every
  profile-scoped surface here (`CookieManager`, `WebStorageManager`, `ServiceWorkerController`,
  `GeolocationPermissions`) instead takes a profile *name*. These follow that, so the mapping to
  androidx is by capability rather than by class. androidx's eight methods become five: its three
  `getCustomHeaders` and two `clearCustomHeader` overloads become optional named arguments, which is
  what Dart has instead of overloading. No capability is dropped, and the filtering is still done by
  the platform — its name matching is case-insensitive and its value matching is not, so a Dart-side
  `where` would not be equivalent.

- **`PlatformCookieManager.setCookies`** (Android and iOS) and the new **`CookieToSet`** type —
  `Future<List<bool>> setCookies({required List<CookieToSet> cookies, webViewController,
  profileName})`, one answer per input cookie in input order.

  **`CookieToSet` is deliberately not `Cookie`.** `Cookie` is the return type of `getCookies` and
  does not fit as an input: it has no `url` and no `maxAge`, both of which `setCookie` takes, and
  it reports `isSessionOnly`, which is not something a caller sets. Reusing it would have meant two
  fields that are silently ignored in one direction each. Every field on `CookieToSet` mirrors a
  parameter of `setCookie` exactly, so the singular and plural calls cannot drift.

  The saving is the **channel round trip**, measured rather than assumed: on iOS 26.5, 100 cookies
  cost 84 ms one `setCookie` at a time and ~12–16 ms in one call, and ~94% of that is per-call
  overhead rather than the cookie store. Hence both platforms, not just the one with a native batch
  API.

  The `List<bool>` carries the same platform asymmetry `setCookie` already documents: a real
  per-cookie result on Android, and on iOS only whether the cookie could be **constructed**, since
  WebKit's completion handlers are `void` and never report storage success.

- **`PlatformWebMessageListenerCreationParams.contentWorld`** (iOS), a `ContentWorld?` defaulting to
  `null` — the page world, so nothing existing changes. It places the injected JavaScript object in
  an isolated content world: page scripts cannot see it, and only code naming the same world can.
  The DOM is shared; only the JavaScript scope differs. The Swift side passes it to the
  `PluginScript` it already builds, and `JavaScriptBridgeJS`'s script is `requiredInAllContentWorlds`,
  so `callHandler` reaches the new world with no further wiring. `windowId` namespaces a
  `window.open` child's worlds from its opener's, exactly as `UserScript.fromMap` does it.

  **Annotated iOS-only on purpose.** `ContentWorld` means two different things on the two platforms:
  a real `WKContentWorld` on iOS, and on Android an `<iframe>` emulation shared by
  `evaluateJavascript` and `UserScript`. `androidx`'s real worlds are a third mechanism, and it
  offers no "evaluate in world" entry point — only injection-time scripts and
  `JavaScriptReplyProxy.executeJavaScript`, which runs in the frame and world that sent a message.
  Honouring the field on Android would register a listener in a scope no Dart code could reach.
  Android ignores it.

- **`WebViewFeature.JS_INJECTION_IN_FRAME_AND_WORLD`** (Android), the mirror for `androidx.webkit`'s
  `JS_INJECTION_IN_FRAME_AND_WORLD`. **Nothing in this package consumes it** — it is exposed for
  feature detection and to make the gap above visible. Verified `true` on API 33 / WebView 151 and
  API 37 / WebView 149, and present in androidx's own `@StringDef`, so it needs no lint suppression.

- **`PlatformCookieManager.setAcceptCookie` / `.isAcceptCookieEnabled` gained iOS** (17.0+), from
  `WKHTTPCookieStore.setCookiePolicy` / `getCookiePolicy`. No signature change and no new method —
  two `@SupportedPlatforms` entries and an iOS implementation, so the pair stops being Android-only.
  The existing `bool` / `bool?` contract already said the right thing and now carries a second
  cause: `false` from the setter and `null` from the getter mean *not applied* and *could not be
  read*, which below iOS 17.0 is "there is no cookie policy on this OS" rather than Android's
  "the cookie store could not be resolved". Neither ever means "cookies are rejected". `profileName`
  is accepted and dropped on iOS like every other method on this class (§29)
- **`PlatformCookieManager.setCookieStoreObserver` / `.cookieStoreObserver`** (iOS 11.0+), with the
  new **`CookieStoreObserver`** type, from `WKHTTPCookieStore.addObserver`. `CookieStoreObserver`
  has one field, `onCookiesChanged`, taking **no arguments** — `WKHTTPCookieStoreObserver` declares
  one method and it carries no payload beyond the store itself, which has no Dart counterpart; a
  unit test pins the property set. Modelled as a client object rather than a bare callback for the
  same reason as `ServiceWorkerClient`: the platform models it as a protocol.

  `cookieStoreObserver` is a **concrete** getter returning `null`, not an abstract one, so
  implementers that cannot register an observer need no override — Android's
  `android.webkit.CookieManager` has no change notification at all. The state is **shared by every
  instance**, because the cookie store is: on iOS it is held statically, which is load-bearing
  rather than a shortcut — `createPlatformCookieManager` returns a new implementation object per
  call and `.static()` is another, yet all of them attach a handler to the same `const
  MethodChannel`, so an observer held per instance would stop firing as soon as anything constructed
  a further one (`CookieManager.isMethodSupported` does)
- New types: `AttributionRegistrationBehavior`, `ButtonMask`, `ModifierFlag`,
  `SecurityRestrictionMode`, `UpgradeToHTTPSPolicy`, `UserAgentMetadata`, `UserAgentBrandVersion`,
  `UserAgentFormFactor`, `WebAuthenticationSupport`, `WebViewMediaIntegrityApiStatus`,
  `WebViewMediaIntegrityApiStatusConfig`, `WebViewMediaIntegrityApiStatusOverrideRule`,
  `WritingToolsBehavior`, `JavaScriptHandlerFunction`

### Fixed

- **`loadUrl`'s dartdoc now documents that `allowingReadAccessTo` discards the rest of the
  `URLRequest` on iOS.** No code change — this is WebKit's behaviour and it had never been written
  down. `loadFileURL:allowingReadAccessToURL:` accepts a URL and nothing else, so a `file://` load
  scoped for read access loses the request's headers and `timeoutInterval`, while **the same Dart
  call without `allowingReadAccessTo` keeps them** — one API, two behaviours, selected by an
  argument that is otherwise only about filesystem scope. Measured on iOS 17.5 and 26.5 against an
  `http://` control, and pinned by an integration test so a future WebKit change fails loudly
  instead of outdating the doc. **There is no way to have both**: iOS 15's
  `loadFileRequest:allowingReadAccessToURL:` takes an `NSURLRequest` and produces a byte-identical
  navigation, so it was measured and deliberately **not** adopted. Serve local content over
  `http://` if you need headers on it
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
