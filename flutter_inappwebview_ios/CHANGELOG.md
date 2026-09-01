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

Eleven WebKit APIs read out of the iOS 26.5 SDK:

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
- **`DownloadStartRequest.isUserInitiated` / `.originatingFrame`**, from `WKDownload`

### Fixed

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
