## 7.0.0

The iOS half of a hard fork of 6.2.0-beta.3 / `1.2.0-beta.3`. The `flutter_inappwebview` 7.0.0 entry
carries the full user-facing list; this entry is what changed in this package.

### Requirements — all breaking

- **Deployment target 12.0 → 15.0**, in the podspec, `Package.swift` and the example's Podfile
- **The module builds in Swift 6 language mode** (`swift_version` 5.0 → 6.0 in both the podspec and
  the SPM manifest) with complete concurrency checking, 0 errors and 0 warnings
- **Xcode 26 / Swift 6.2+ is now required to build the module.** This is the most disruptive change
  here and it is not visible in the version numbers: `isolated deinit` (SE-0371) is used at 32 sites
  so that `deinit { dispose() }` is legal under Swift 6, and that feature needs a Swift 6.2+
  compiler. Flutter 3.44 itself only requires Xcode 15, so this plugin demands a newer toolchain
  than Flutter does — **a consumer on Xcode 16 cannot build it.** The alternatives were a runtime
  trap or dropping the teardown safety net
- **Swift Package Manager support**; CocoaPods still works
- Every method/event channel name changed to the `dev.nosferatu500.inappwebview/…` prefix

### Added

- **`ProxyRule.relayHop1` / `.relayHop2` are now reachable** (iOS 17.0+). No Swift changed:
  `ProxyManager.swift` has always parsed `map["relayHop1"]` / `map["relayHop2"]` into
  `ProxyRelayHop` and built `ProxyConfiguration(relayHops:)` from them, and
  `ProxyRule.toProxyConfiguration()` has always preferred that branch over the plain endpoint. What
  was missing was on the Dart side — `ProxyRule_` had no field of that type, so the keys were never
  sent. A wire test in this package now pins the map shape against what the Swift reads

Fourteen WebKit APIs read out of the iOS 26.5 SDK:

- **`NavigationAction.modifierFlags` / `.buttonNumber`** (+ `ModifierFlag`, `ButtonMask`) — which
  keys and mouse button triggered a navigation
- **`NavigationAction.isContentRuleListRedirect`** — whether a content rule list redirected it
- **`onShowFileChooser` now fires on iOS** (18.4+), gated on
  `InAppWebViewSettings.useOnShowFileChooser` — the iOS half of upstream #2146
- **`InAppWebViewSettings.writingToolsBehavior`** (+ `WritingToolsBehavior`)
- **`InAppWebViewSettings.preferredHTTPSNavigationPolicy`** (+ `UpgradeToHTTPSPolicy`), applied to
  the *live* per-navigation `WKWebpagePreferences`, so unlike the other creation-time settings it
  genuinely responds to `setSettings`
- **`InAppWebViewSettings.securityRestrictionMode`** (+ `SecurityRestrictionMode`)
- **`InAppWebViewSettings.lockdownModeEnabled`**
- **`InAppWebViewSettings.supportsAdaptiveImageGlyph`**
- **`isBlockedByScreenTime` on the controller** (26.0+), from `WKWebView.isBlockedByScreenTime`.
  The Swift answers `nil` below iOS 26.0 rather than `false` — the `hasOnlySecureContent` handler
  immediately above it collapses its optional to `false`, and doing the same here would report
  "not blocked" for an OS that has no such property
- **`InAppWebViewSettings.showsSystemScreenTimeBlockingView`** (26.0+), from
  `WKWebViewConfiguration.showsSystemScreenTimeBlockingView`. Applied in
  `preWKWebViewConfiguration` only, and read back in `getRealSettings` under
  `#available(iOS 26.0, *)` — so below that floor `getSettings()` reports whatever Dart last sent,
  the same boundary the 18.0 configuration settings already have
- **`InAppWebViewSettings.obscuredContentInsets`** (26.0+), from
  `WKWebView.obscuredContentInsets`. An `EdgeInsets` setting, so it needs the explicit pre-pass in
  `InAppWebViewSettings.parse` that `minimumViewportInset` uses — KVC cannot carry an optional
  value type — and an explicit `getRealSettings` override under `#available(iOS 26.0, *)`. Applied
  in **two** places, unlike the rest of the 26.0 additions: at creation *and* in `setSettings`,
  because it is a `WKWebView` property and therefore not subject to §95's copy-on-access rule
- **`setConversationContext` / `getConversationContext` on the controller** (26.0+), from
  `WKWebView.conversationContext`, with `Types/UIConversationContext.swift` mapping the Dart maps to
  `UIConversationContext`, its nested `Entry` and `PersonNameComponents`. Three notes for anyone
  touching that file: the entry type is **`UIConversationContext.Entry` in Swift**, not
  `UIConversationEntry` — the ObjC header renames it with `NS_SWIFT_NAME` and the ObjC spelling is a
  hard error; `sentDate` crosses the channel as **milliseconds** while `Date(timeIntervalSince1970:)`
  takes seconds; and `NSSet` has no wire form, so the sets travel as arrays. The types are iOS 18.4+
  even though the WebKit property is 26.0+, so the extensions are annotated at 18.4 and the 26.0 gate
  sits at the call site
- **`onInsertInputSuggestion`** (26.0+), from `WKUIDelegate.webView(_:insertInputSuggestion:)`,
  gated by `InAppWebViewSettings.useOnInsertInputSuggestion` through the same `responds(to:)`
  override that gates the open panel — and re-assigning `uiDelegate` in `setSettings` when either
  gate flips, because WebKit caches the delegate's selector support. `Types/UIInputSuggestion.swift`
  builds the payload by downcasting to `UISmartReplySuggestion`; the base class has no properties.
  **The `@objc` thunk was verified present** with `nm | swift-demangle` on both architectures rather
  than inferred from a green build — an optional protocol requirement only gets `@objc` when the
  signature matches exactly, which is how §68's ten dead delegate methods happened
- **`shouldGoToBackForwardListItem`** (26.0+), from
  `WKNavigationDelegate.webView(_:shouldGoTo:willUseInstantBack:completionHandler:)`. **Note the
  Swift selector**: the header spells it `shouldGoToBackForwardListItem:` and Swift renames it to
  `shouldGoTo:`, so the obvious transcription compiles, analyzes clean and is **never called** —
  `@objc` is only inferred for an exact signature match. Caught by `nm | swift-demangle` on both
  architectures, which is the only evidence an optional delegate method is installed.

  A second trap sat on top of it: the header's completion handler is a **plain block**, unlike every
  other `WKNavigationDelegate` handler, which carry `WK_SWIFT_UI_ACTOR`. Copying the neighbours'
  `@escaping @MainActor @Sendable (Bool) -> Void` made the signature not match — and *that*
  suppressed the compiler's "has been renamed to" diagnostic, so one wrong annotation turned a hard
  error into silence. Dropping it produced the error that named the real selector.

  `Types/WKBackForwardListItem.swift` maps the item, and `getCopyBackForwardList()` now uses the same
  mapper so the two producers of a `WebHistoryItem` map cannot drift. The item is located in the list
  by **identity** (`firstIndex(where:{ $0 === item })`), since `WKBackForwardListItem` defines no
  value equality and two entries for one URL are distinct
- **`onWritingToolsActiveChanged`** (18.0+), from `WKWebView.writingToolsActive` — the first event
  this fork adds on the **KVO** path rather than a delegate. Registered in `prepare()` under
  `#available(iOS 18.0, *)` and removed under the identical guard in `dispose()`: an unbalanced KVO
  removal throws, so the two `#available`s have to agree exactly. Registered **without** `.initial`,
  deliberately — the property starts `false`, so an initial callback would report a change on every
  WebView creation. The `observeValue` branch compares old against new before sending, because KVO
  fires on every set rather than only on sets that change the value. The Swift spelling is
  `#keyPath(WKWebView.isWritingToolsActive)` (the header's `getter=isWritingToolsActive`), which is
  compiler-checked — unlike a delegate method, there is no `nm` question here
- **`setAcceptCookie` / `isAcceptCookieEnabled` on the cookie manager** (17.0+), from
  `WKHTTPCookieStore.setCookiePolicy` / `getCookiePolicy`. Answers to the wire names the Kotlin
  already uses, so one Dart method reaches both platforms. In Swift the enum is
  **`WKHTTPCookieStore.CookiePolicy`** (`NS_SWIFT_NAME`), not the header's `WKCookiePolicy`. Below
  the 17.0 floor the setter reports **`false`** and the getter **`nil`** rather than the platform
  default — collapsing that `nil` to `false` would claim cookies are rejected on an OS with no
  policy at all, and an integration test on an **iOS 16.4** simulator was proved to go red against
  exactly that mistake
- **`setCookieStoreObserver` on the cookie manager** (11.0+, so unconditional at this deployment
  target), from `WKHTTPCookieStore.addObserver` / `WKHTTPCookieStoreObserver`. `MyCookieManager`
  conforms to the protocol itself and forwards `cookiesDidChange(in:)` to Dart as
  `onCookiesChanged` with an empty argument map. Two native details worth knowing: `addObserver:`
  **does not retain** the observer and documents unregistration as the caller's job, so the
  registration is tracked by a flag that guarantees one `removeObserver:` per `addObserver:` and
  `dispose()` unregisters before the channel is dropped; and registration is driven from Dart rather
  than done at plugin start-up, so an app that never sets an observer pays no channel traffic for
  the WebView's cookie writes. **The `@objc` thunk was verified present** with `nm | swift-demangle`
  on both architectures rather than inferred from a green build. One further spelling trap, of the
  same kind as `UIConversationContext.Entry`: in Swift the methods are **`add(_:)` / `remove(_:)`**,
  and writing the header's `addObserver:` / `removeObserver:` is a hard error, not a deprecation
- **`DownloadStartRequest.isUserInitiated` / `.originatingFrame`**, from `WKDownload`
- **`WebMessageListener.contentWorld`** (14.0+, so unconditional at this deployment target) — the
  `WKContentWorld` the injected JavaScript object is created in, defaulting to `.page`, which is what
  every earlier release did. `WebMessageListener.fromMap` now decodes a `contentWorld` map and
  `initJsInstance` builds its `PluginScript` with `in:` that world. **Nothing else was needed**: the
  world is registered on the controller by `addPluginScript`, and `JavaScriptBridgeJS`'s script is
  already `requiredInAllContentWorlds`, so `FlutterInAppWebViewWebMessageListener` and the
  `callHandler` message handler both reach the new world through the existing `sync` path.
  `fromMap` gained a `windowId` parameter, passed from the channel delegate, because
  `WKContentWorld.fromMap` uses it to namespace a `window.open` child's worlds from its opener's —
  without it two windows asking for the world `"a"` would share one scope. This is the same
  treatment `UserScript.fromMap` has always had

### Fixed

- **`InAppBrowser`'s bars were drawn with pre-iOS-13 API and were visibly broken on iOS 26.**
  `UINavigationBar.backgroundColor` / `.barTintColor` / `.isTranslucent` have not driven the bar
  background since iOS 13 — only `UINavigationBarAppearance` / `UIToolbarAppearance` do — so
  `toolbarTopBackgroundColor` and friends left the status-bar area unpainted, which showed as a black
  strip above the bar. Both bars are now configured through a `UIBarAppearance`, and
  `getSettings()` reads the colours and translucency **back** off the appearance objects instead of
  the legacy properties, so it no longer reports values the bar is not using.

  Four further problems fixed with it:

  - **the three flexible spaces in the bottom toolbar were one `UIBarButtonItem` instance reused
    three times.** A bar button item can only appear once in `toolbarItems`, so the spacing
    collapsed; each spacer is now its own item
  - **the web view was pinned to `view.topAnchor` unconditionally**, so with the top bar visible the
    URL field and close button sat on top of the page's own header. It now pins to the safe-area
    guide when the top bar is shown and stays full-bleed when it is hidden, and the progress bar
    always stays clear of the top bar
  - **a translucent bar with no explicit colour now uses `configureWithTransparentBackground()`**, so
    the page shows through it edge-to-edge instead of being covered by a default material; the
    controller paints itself and the navigation controller with the page's own
    `underPageBackgroundColor` so the strip behind the bar does not read as a border
  - the back/forward buttons were `‹` and `›` glyphs set at 50pt with a baseline offset; they are now
    the `chevron.backward` / `chevron.forward` SF Symbols, and the search bar's own background image
    is dropped so only the field floats over the page

- **`keyboardWillHide` left a stale negative `scrollView.contentInset` behind, so the page could not
  scroll to the bottom after the keyboard had been dismissed** (upstream issue `#1947`, which the
  observers in `prepare()` were added to fix in the first place; upstream PR `#2860` fixes the same
  thing). `keyboardWillShow` installs a negative `contentInset` to cancel the enlarged safe-area
  contribution; `keyboardWillHide` reset only its `_scrollViewContentInsetAdjusted` latch and left
  the inset in place, so once the keyboard was gone the compensation over-corrected by the size of
  the home-indicator safe area. Measured on iOS 26.5 with
  `contentInsetAdjustmentBehavior: .always`: `adjustedContentInset.bottom` settled at **-34** and
  stayed there. Only the `frame` setter ever recomputed it, so a WebView recovered only if something
  resized it — and with `resizeToAvoidBottomInset: false` on the Flutter side the frame does not
  change when the keyboard appears, which is exactly the configuration the `keyboardWillShow` code
  is written for. `keyboardWillHide` now restores the invariant asynchronously, from the settled safe
  area, skipping the restore if focus has already moved to another input. The zero-then-negate
  computation the `frame` setter has always used is now a single `neutralizeAdjustedContentInset()`
  rather than a second copy. Affects iOS 17.2+ only, where the observers are registered.

The first iOS integration runs in this fork's history found four defects that no compiler, linter or
unit test could see. All four are fixed and proved both ways on a simulator.

- **HTTP auth retry state was shared by every WebView in the process, and could send a saved
  password to the wrong host.** `InAppWebView.credentialsProposed` — the queue of saved credentials
  tried one per challenge when `onReceivedHttpAuthRequest` returns
  `HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS` — was a `private static`. Two WebViews
  authenticating at the same time popped from the same queue, and **any** WebView's `didFinish` or
  `didFail` emptied it mid-challenge; an SSL challenge on one WebView cleared another's queue too.
  It is now per WebView.

  Per-WebView alone was not enough: nothing checked that a popped credential belonged to the
  challenge being answered, so a queue filled for one host could be popped for another — a page with
  authenticated subresources on a second origin is enough, without any second WebView. The queue now
  records the protection space (host, protocol, realm, port) it was filled for and is discarded when
  that changes
- **Ten `WKUIDelegate` / `WKNavigationDelegate` methods were never called at all.** The Swift 6
  migration left them declaring plain `@escaping (…) -> Void` handlers where the SDK declares
  `WK_SWIFT_UI_ACTOR` (`@MainActor @Sendable`); Swift only infers `@objc` for an optional protocol
  requirement when the signature matches exactly, so no selector was exported and WebKit fell
  through to its built-in defaults — **with zero compiler diagnostics, `flutter analyze` at 0 and
  every unit test passing.** What was dead: `onJsAlert` / `onJsConfirm` / `onJsPrompt` (so JavaScript
  `confirm()` always returned `false` and `prompt()` always `null`), **`shouldOverrideUrlLoading`
  could not block a navigation** — `NavigationActionPolicy.CANCEL` was ignored and every navigation
  was allowed — `onNavigationResponse`, `onPermissionRequest`, `shouldAllowDeprecatedTLS`,
  `onReceivedServerTrustAuthRequest` / `onReceivedHttpAuthRequest` / `onReceivedClientCertRequest`,
  and the device orientation/motion permission request. **11 integration tests went green on this
  one fix.**
- **`loadUrl` with `allowingReadAccessTo` silently discarded the rest of the request — documented,
  not changed, because it cannot be.** `loadFileURL:allowingReadAccessToURL:` takes only a URL, so
  the caller's headers and `timeoutInterval` go nowhere; the same call *without*
  `allowingReadAccessTo` goes through `WKWebView.load(_:)` and keeps them. Measured on iOS 17.5 and
  26.5 against an `http://` control and pinned by an integration test. iOS 15's
  `loadFileRequest:allowingReadAccessToURL:` looks like the fix and is not: it takes an
  `NSURLRequest` and was measured to produce a **byte-identical** navigation, so it was tried and
  deliberately not adopted rather than shipped as a change that does nothing
- **`callHandler` from a cross-origin iframe silently returned `undefined`.** The injected bridge
  kept its `{resolve, reject}` table on `window.top`; in a cross-origin frame that property access
  **throws**, and the `catch` called `resolve()` with no argument — so the promise settled
  immediately, with no value, while the Dart handler was still running and its result was discarded.
  Any page embedding third-party content, or embedded *as* third-party content, got this. With
  `WKScriptMessageHandlerWithReply` the promise belongs to the frame that called `postMessage`, so
  there is no table and nothing to throw. **Android still has this defect** — its bridge keys the
  same table off `(isMainFrame ? window : window.top)` behind the same `catch (e) { resolve(); }`,
  and there is no equivalent API to port, so the fix there is a different design
- **A throwing JavaScript handler hung the caller forever.** The rejection was built by interpolating
  the error message into a single-quoted JS string literal escaping only `'`, so any message
  containing a newline — routine for `Exception` — produced invalid JavaScript, the
  `evaluateJavaScript` failed, and the promise stayed **pending for the lifetime of the page**:
  `await window.flutter_inappwebview.callHandler(...)` never settled
- **`onPrintRequest` killed the app on iOS 26.** `UIPrintInteractionControllerDelegate` is declared
  `NS_SWIFT_UI_ACTOR`, so the witness inherited `@MainActor` and Swift 6 emitted an executor
  assertion — but UIKit calls it from a background `NSThread`, so the assertion trapped and took the
  whole process down
- **A DNS failure threw inside the plugin on iOS 26, so `onReceivedError` never reached app code.**
  iOS 26 returns `NSError -1006` where 17.x returned -1003, and -1006 was unmapped
- **`onEnterFullscreen` never fired for fullscreen video on iOS 26.** Fullscreen media detection
  reads the new window's frame from `UIWindow.didBecomeVisibleNotification`, and on iOS 26 that
  notification arrives **before the window is laid out** — frame `(0, 0, 0, 0)` — so the
  "is it fullscreen-sized?" half of the heuristic rejected a window that was about to be exactly
  that. Every other property (scene, level, class) is already final at that point, so the size check
  is now re-evaluated on the next main-actor turn when the frame is empty. Unchanged on iOS 17.x,
  where the frame is already correct. **`onExitFullscreen` was collateral**: it is guarded on
  `inFullscreen`, which enter never set
- **A leaked `WKURLSchemeTask`** in the custom-scheme handler
- **`InAppWebViewSettings.allowingReadAccessTo` documented as not a security boundary.** No code
  change and no defect: instrumenting `InAppWebView.loadUrl` on iOS 17.5 and 26.5 shows the plugin
  hands `WKWebView.loadFileURL(_:allowingReadAccessTo:)` the correct file URL, and a `file://` page
  still loads a sibling directory's script when the scope is narrowed to a directory that excludes
  it. The doc used to promise the opposite
- **`findAll` found nothing when the search text contained an apostrophe or a backslash.** Below the
  `UIFindInteraction` path — i.e. whenever `InAppWebViewSettings.isFindInteractionEnabled` is
  `false` — the search term was interpolated into JavaScript source **with no escaping at all**, so
  `it's` closed the string literal early, the script was invalid and `evaluateJavaScript` failed
  silently. From Dart that is indistinguishable from a page with no matches. Now escaped; three
  integration tests cover `it's`, `"hello"` and `C:\path`
- **Every remaining hand-escaped JS interpolation now goes through `Util.jsStringLiteral`** — 18
  sites that escaped only `'` (the `script.*` / `link.*` attributes of `injectJavascriptFileFromUrl`
  and `injectCSSFileFromUrl`, `UserScript`'s allowed-origin rules, `WebMessage` data, the
  `WebMessageListener` object name and origin rules) plus three that escaped nothing
  (`postWebMessage`'s target origin, an origin rule's scheme, and the find text above). Only the
  find one had a plausible user-facing trigger; **the rest are hygiene, not measured defects** — but
  they all carry app-developer values, and the same idiom is what caused the JS-handler hang above.
  One of them changes behaviour: `UserScript.allowedOriginRules` are compiled with `new RegExp`, and
  the old escaping ate backslashes, so a rule like `https://.*\.example\.com` was silently compiled
  as `https://.*.example.com` — a *wider* match than written
- **`WebMessageListener.allowedOriginRules`' wildcard was an unanchored substring test in the
  injected JavaScript**, so a rule of `https://*.example.com` also admitted
  `foo.example.com.evil.test` — a host whose registrable domain belongs to whoever registered
  `evil.test`. That JavaScript decides whether `window[jsObjectName]` is created, and it is the
  **only** check on the Dart → page direction: `postMessage` from Dart evaluates against whatever
  object it finds, so an app could post to a page its allow-list never named. Now anchored at the
  end of the host, matching the Swift `isOriginAllowed` — which already was, and was the second gate
  that kept the page → Dart direction sound throughout. `*.example.com` matches `foo.example.com`
  and neither `example.com` nor `foo.example.com.evil.test`; nothing that matched before matches now
- **A WebView released off the main thread could crash the app**, in
  `WebViewChannelDelegate.__deallocating_deinit` — `isolated deinit` does not save it, because the
  class is released through Objective-C, so the executor check traps instead of hopping. The trigger
  is a channel callback that captures `self` strongly: the closure is retained by the reply
  machinery and the Flutter engine can destroy that block on a dispatch worker thread, taking the
  last reference to the WebView with it. All three `didReceive challenge` branches (HTTP auth,
  server trust, client certificate) now capture `self` weakly and fall through to their default
  behaviour if the WebView is gone. Observed twice in this repo's own test runs before the fix, both
  times as the app dying mid-suite with no Dart error
- 48 dead availability checks removed — all at or below the new 15.0 floor — along with the
  below-iOS-14 `callAsyncJavaScript` path and the dead `SFAuthenticationSession` branches

Known platform limitation, worth recording rather than working around: on **iOS 17.x**,
`SecPKCS12Import` cannot read a PKCS#12 container using modern encryption (`PBES2` / `AES-256-CBC`,
OpenSSL 3's default) and reports `errSecAuthFailed` — *"the passphrase is not correct"* — which is a
lie. `onReceivedClientCertRequest` then silently presents no certificate. The same file works on iOS
26.5. Check container algorithms with `openssl pkcs12 -info -nokeys -noout` before believing that
error.

### Removed

- All deprecated API: `IOSInAppWebViewOptions` / `IOSInAppBrowserOptions` / `IOSSafariOptions` → the
  `*Settings` classes, the 30 `IOS*` duplicate types, the `iosOn*` event aliases, the `ios*` field
  aliases, `getOptions`/`setOptions`, `findAllAsync` / `findNext` / `clearMatches` (→
  `FindInteractionController`), `clearCache()` (→ `clearAllCache`), `getScale()` (→ `getZoomScale`),
  `getTRexRunnerHtml()` / `getTRexRunnerCss()` (→ the getters),
  `PullToRefreshController.setAttributedTitle()` (→ `setStyledTitle`)
- The `createPlatformWebViewEnvironment` / `createPlatformWebViewEnvironmentStatic` overrides —
  `PlatformWebViewEnvironment` was Windows/Linux-only and no longer exists
- `onDownloadStarting` no longer serializes a response back to the native side: the event returns
  `FutureOr<void>`, and `WebViewChannelDelegate.swift` never read the returned value
- **`PrintJobController.disposeNoDismiss()`**, whose only caller was the old `onPrintRequest`
  path — it dropped the plugin's tracking while leaving the presented print controller alone, and
  there is no longer a job the plugin owns but has not handed to Dart

### Changed

- **`saveState` accepts `maxSize` and `includeForwardState` and ignores them.** They are Android
  arguments on a cross-platform method; `WKWebView.interactionState` is an opaque blob with no size
  or forward-history control, so there is nothing to forward them to and nothing to emulate them
  with. They are not sent over the channel, and the dartdoc says so rather than leaving a caller to
  discover it.
- **The JavaScript bridge now uses `WKScriptMessageHandlerWithReply` (iOS 14.0+).**
  `window.flutter_inappwebview.callHandler(...)` used to return a promise the plugin settled itself:
  the injected script minted a callback id, stashed `{resolve, reject}` in a table on `window.top`,
  and the native side later ran a generated `evaluateJavaScript` snippet that looked the entry up
  and called `resolve(<the handler's JSON>)` or `reject(new Error('<message>'))`. `postMessage` now
  returns WebKit's own promise and the native side settles it by calling a reply block, so the
  callback-id table, the generated snippets and the string escaping around them are all gone. **No
  Dart or JavaScript API changed** — `addJavaScriptHandler` and `callHandler` are called exactly as
  before, and the JS-visible **type** of a handler's result is unchanged (an object stays an object,
  `null` stays `null` rather than becoming `undefined`; an integration test pins all seven cases and
  is proved red against the naive port that replies with the JSON text instead of its parsed value).
  Three consequences are visible:
  - `callHandler` from a **cross-origin iframe** now returns the handler's result — see Fixed
  - a handler call that the plugin cannot forward at all (bridge disabled, wrong bridge secret,
    origin not on `javaScriptHandlersOriginAllowList`, no method channel) now **rejects the promise**
    instead of leaving it pending forever. The two security refusals share one deliberately
    uninformative message
  - the plugin no longer creates `window.flutter_inappwebview[<number>]` entries. These were never
    documented or supported, but page code could observe them
- **15 dead `configuration` writes removed from `setSettings`, and the settings they belong to now
  document that they are creation-only.** `WKWebView.configuration` returns a **fresh copy on every
  access** — measured on iOS 17.5 and 26.5, where `configuration === configuration` is `false` — so
  a `configuration.x = y` on a running WebView wrote to an object that was discarded immediately.
  Its four object-valued properties (`preferences`, `defaultWebpagePreferences`,
  `userContentController`, `websiteDataStore`) *are* shared by reference across those copies, which
  is why writing *through* one of them has always worked and is untouched here.

  Nothing changes at runtime — the removed lines never had an effect, and every one of these
  settings is still applied at creation by `preWKWebViewConfiguration`. What changes is that
  `setSettings` no longer looks as though it applies them: `mediaPlaybackRequiresUserGesture`,
  `allowsInlineMediaPlayback`, `suppressesIncrementalRendering`, `selectionGranularity`,
  `ignoresViewportScaleLimits`, `dataDetectorTypes`, `allowsAirPlayForMediaPlayback`,
  `allowsPictureInPictureMediaPlayback`, `applicationNameForUserAgent`,
  `allowUniversalAccessFromFileURLs`, `limitsNavigationsToAppBoundDomains`,
  `upgradeKnownHostsToHTTPS`, and the `WKWebsiteDataStore` replacement behind `incognito`,
  `cacheEnabled` and `sharedCookiesEnabled`. `sharedCookiesEnabled` keeps the half that does work:
  it still copies `HTTPCookieStorage.shared` into the WebView's existing data store
- **`InAppWebView.gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:)` is now `nonisolated`.**
  Hardening, not a bug fix — no misbehaviour was observed. `UIGestureRecognizerDelegate` is
  `NS_SWIFT_UI_ACTOR`, so the witness inherited `@MainActor` and Swift 6 emits an executor assertion
  on entry; that assertion **traps and kills the process** if UIKit ever calls it off the main
  thread, which is exactly how the printing delegate failed on iOS 26.5. This method's body reads no
  isolated state (`return true`), so dropping the inherited isolation costs nothing and removes the
  failure mode. It is also the one delegate witness the integration suite never reaches — measured:
  0 calls across both simulators — so a trap there would go unnoticed
- **`onPrintRequest` is asked before the print job starts.** `InAppWebView`'s `window.print()`
  bridge handler no longer calls `printCurrentPage(settings:)` up front; it invokes the Dart event
  first and only prints from the callback's `defaultBehaviour`, so returning `true` means the print
  controller is never presented. Returning `false`, `null`, an error, and having no handler at all
  all still print. The job is created with `handledByClient = false`, so no `PrintJobController` is
  allocated on this path. `WebViewChannelDelegate.onPrintRequest` drops its `printJobId` argument
  and no longer sends that map key. Verified on the iOS 26.5 and 17.5 simulators

### Internal

- **`WKContentWorld.windowId` is stored as an associated object instead of in a static dictionary
  keyed by the world's pointer address.** No behaviour change — the values, and the JS `windowId`
  variable they drive, are identical. The old `[String: Int64?]` static grew by one entry per
  distinct content-world name for the life of the process with no removal anywhere in the package,
  and its correctness rested on an undocumented WebKit behaviour. Measured on iOS 17.5 and 26.5:
  `WKContentWorld.world(name:)` interns by name and the world stays alive after the plugin drops
  every reference to it, so the keys were stable — which means the recorded fear that "the allocator
  eventually hands that address to a different `WKContentWorld`, which silently inherits the dead
  one's `windowId`" **could not happen and is retracted**. An associated object removes both the
  growth and the dependency on that behaviour
- 49 Dart-side unit tests, covering the channel argument maps and the settings surface — the package
  previously shipped a single empty placeholder test file
- The integration suite now runs on iOS: **106 pass / 6 fail / 1 skip** on iOS 17.5 and
  **107 / 5 / 1** on iOS 26.5, with the fixture server up. Both remaining failure sets are
  characterised and none is claimed as a plugin defect yet

## 1.2.0-beta.3

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.3
- Implemented `saveState`, `restoreState` InAppWebViewController methods
- Implemented `PlatformProxyController` class
- Add Swift Package Manager support [#2409](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2409)
- Merged "Add proxy support for iOS" [#2362](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2362) (thanks to [yerkejs](https://github.com/yerkejs))
- Fixed "[iOS] Webview opened with windowId does not receive javascript handler callback." [#2393](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2393)
- Fixed internal javascript callback handlers when the WebView has windowId not null
- Fixed "When useShouldInterceptAjaxRequest is true, some ajax requests doesn't work" [#2197](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2197)
- Fixed "iOS App rejected by apple for violating Guideline 2.5.1 - Performance - Software Requirements | Flutter 3.35.x seems to use non-public or deprecated APIs" [#2754](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2754)
- Fixed "InAppWebViewController.goTo" implementation
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))
- Merged "Fix gesture recognition delay prevention for latest Flutter versions" [#2538](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2538) (thanks to [muccy-timeware](https://github.com/muccy-timeware))

## 1.2.0-beta.2

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.2
- Implemented `setInputMethodEnabled`, `hideInputMethod` InAppWebViewController methods
- Implemented `isUserInteractionEnabled`, `alpha` properties of `InAppWebViewSettings`
- Merged "Show / Hide / Disable / Enable soft Keyboard Input (Android & iOS)" [#2408](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2408) (thanks to [Mecharyry](https://github.com/Mecharyry))
- Fixed "In iOS version 17.2, when moving the input focus in a WebView, an unknown area appears at the top of the screen." [#1947](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1947)

## 1.2.0-beta.1

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.1
- Implemented `requestFocus` WebView method
- Updated ConsoleLogJS internal PluginScript to main-frame only as using it on non-main frames could cause issues such as [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Added support for `UserScript.allowedOriginRules` parameter
- Moved `WKUserContentController` initialization on `preWKWebViewConfiguration` to fix possible `undefined is not an object (evaluating 'window.webkit.messageHandlers')` javascript error
- Merged "change priority of DispatchQueue" [#2322](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2322) (thanks to [nnnlog](https://github.com/nnnlog))
- Fixed `show`, `hide` methods and `hidden` setting for `InAppBrowser`

## 1.1.2

- Updated flutter_inappwebview_platform_interface version to ^1.3.0

## 1.1.1

- Updated flutter_inappwebview_platform_interface version to ^1.2.0

## 1.1.0+3

- Updated flutter_inappwebview_platform_interface version

## ## 1.1.0+2

- Updated pubspec.yaml

## 1.1.0+1 

- Fixed "v6.1.0 fails to compile on Xcode 15" [#2288](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2288)

## 1.1.0

- Fixed XCode 16 build
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Merged "Add privacy manifest for iOS" [#2029](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2029) (thanks to [ueman](https://github.com/ueman))

## 1.0.13

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.10`

## 1.0.12

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.9`
- Fix typos and other code improvements (thanks to [michalsrutek](https://github.com/michalsrutek))
- Fixed "runtime issue of SecTrustCopyExceptions 'This method should not be called on the main thread as it may lead to UI unresponsiveness.' when using onReceivedServerTrustAuthRequest" [#1924](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1924)
- Merged "💥 Fix iPad crash due to missing sourceView" [#1933](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1933) (thanks to [michalsrutek](https://github.com/michalsrutek))
- Merged "💥 Fix crash - remove force unwrapping from dispose method" [#1932](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1932) (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.11

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.8`

## 1.0.10

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.7`

## 1.0.9

- Implemented `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests`
- Updated `useShouldInterceptAjaxRequest` automatic infer logic
- Updated `CookieManager` methods return value
- Fixed "iOS crash at public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)" [#1912](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1912)

## 1.0.8

- Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'
- Fixed shouldInterceptAjaxRequest javascript code when overriding XMLHttpRequest.open method parameters

## 1.0.7

- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)

## 1.0.6

- Possible fix for "iOS Fatal Crash" [#1894](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1894)

## 1.0.5

- Call `super.dispose();` on `InAppBrowser` and `ChromeSafari` implementations

## 1.0.4

- Fixed "Cloudflare Turnstile failure" [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)

## 1.0.3

- Fixed `InAppBrowserMenuItem.iconColor` not working

## 1.0.2

- Added `PlatformPrintJobController.onComplete` setter
- Updated `flutter_inappwebview_platform_interface` version dependency to `1.0.2`

## 1.0.1

- Updated README

## 1.0.0

Initial release.
