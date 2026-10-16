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
| Android `minSdk` / AGP | 19 / 8                                       | **26 / 9**                                                           |
| iOS deployment target  | 12.0                                         | **15.0**                                                             |
| Flutter / Dart floor   | 3.32 / `^3.8.0`                              | **3.47 / `^3.13.0`**                                                 |
| Unit tests             | 276, all in the example app                  | **412**, incl. the Android module's first native tests               |
| Android lint           | 27 findings                                  | **0**                                                                |
| New platform APIs      | —                                            | **85**, marked ★ in the [API reference](#api-reference)              |
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
API that only served them. `minSdk 26` is above Flutter's own floor of 24 and forces every
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

## API reference

Every API the plugin exposes from Dart, grouped by class, with the platforms that implement it and
the OS version it needs. Expand a class to see its table.

**How to read the tables**

| Mark | Meaning |
| --- | --- |
| ★ before a name | Added by this fork: not in upstream `6.2.0-beta.3` |
| ★ after a version | The API existed upstream, and this fork added that platform |
| ✓ | Available on every version the plugin supports: Android 8.0 (API 26) and newer, iOS 15.0 and newer |
| `API 29+`, `18.2+` | The minimum Android API level or iOS version. Below it, an iOS getter returns `null` and a setter reports `false`, never a wrong value; on Android the setting is ignored or the call does nothing |
| `` `FEATURE_NAME` `` | Android also needs a WebView that supports this feature: check `WebViewFeature.isFeatureSupported(WebViewFeature.FEATURE_NAME)` |
| — | Not available on that platform: methods report "not implemented on the current platform", settings are ignored |

Guard cross-platform code with `isMethodSupported` / `isPropertySupported`, which answer from the
same data as these tables. Descriptions are the first sentence of each API's doc comment; the full
documentation is on [pub.dev](https://pub.dev/documentation/nosferatu500_inappwebview/latest/).
`InAppBrowser` also has every `InAppWebView` event, so its table lists only the browser-only ones.

The tables are generated from the platform interface by `dart tool/readme_api_tables.dart`;
`--check` fails when they are out of date.

<!-- api-reference:start -->
<!-- Generated by tool/readme_api_tables.dart from the platform interface. Do not edit by hand. -->

<details>
<summary><b><code>InAppWebView</code></b> — 82 APIs, 15 ★</summary>

#### InAppWebView — Events and parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `contextMenu` | ✓ | ✓ | Context menu which contains custom menu items to be shown when `ContextMenu` is presented. |
| `findInteractionController` | ✓ | ✓ | Represents the find interaction feature controller. |
| `initialData` | ✓ | ✓ | Initial `InAppWebViewInitialData` that will be loaded. |
| `initialFile` | ✓ | ✓ | Initial asset file that will be loaded. |
| `initialSettings` | ✓ | ✓ | Initial settings that will be used. |
| `initialUrlRequest` | ✓ | ✓ | Initial url request that will be loaded. |
| `initialUserScripts` | ✓ | ✓ | Initial list of user scripts to be loaded at start or end of a page loading. |
| `onAjaxProgress` | ✓ · `DOCUMENT_START_SCRIPT` | ✓ | Event fired as an `XMLHttpRequest` progress. |
| `onAjaxReadyStateChange` | ✓ · `DOCUMENT_START_SCRIPT` | ✓ | Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes. |
| `onCameraCaptureStateChanged` | — | ✓ | Event fired when a change in the camera capture state occurred. |
| `onCloseWindow` | ✓ | ✓ | Event fired when the host application should close the given WebView and remove it from the view system if necessary. |
| `onConsoleMessage` | ✓ | ✓ | Event fired when the `WebView` receives a `ConsoleMessage`. |
| `onContentSizeChanged` | — | ✓ | Event fired when the content size of the `WebView` changes. |
| `onCreateWindow` | ✓ | ✓ | Event fired when the `WebView` requests the host application to create a new window, for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side. |
| `onDidReceiveServerRedirectForProvisionalNavigation` | — | ✓ | Called when a web view receives a server redirect. |
| `onDownloadStarting` | ✓ | ✓ | Event fired when `WebView` recognizes a downloadable file. |
| `onEnterFullscreen` | ✓ | ✓ | Event fired when the current page has entered full screen mode. |
| `onExitFullscreen` | ✓ | ✓ | Event fired when the current page has exited full screen mode. |
| ★ `onFirstContentfulPaintMillis` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when the page's First Contentful Paint happens. |
| `onFormResubmission` | ✓ | — | As the host application if the browser should resend data as the requested page was a result of a POST. |
| `onGeolocationPermissionsHidePrompt` | ✓ | — | Notify the host application that a request for Geolocation permissions, made with a previous call to `onGeolocationPermissionsShowPrompt` has been canceled. |
| `onGeolocationPermissionsShowPrompt` | ✓ | 27.0+ ★ | Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin. |
| ★ `onInsertInputSuggestion` | — | 26.0+ | Event fired when the system keyboard delivers an input suggestion the user selected — in practice a **Smart Reply**, offered because the WebView was given a conversation with `setConversationContext`. |
| `onJsAlert` | ✓ | ✓ | Event fired when javascript calls the `alert()` method to display an alert dialog. |
| `onJsBeforeUnload` | ✓ | — | Event fired when the client should display a dialog to confirm navigation away from the current page. |
| `onJsConfirm` | ✓ | ✓ | Event fired when javascript calls the `confirm()` method to display a confirm dialog. |
| `onJsPrompt` | ✓ | ✓ | Event fired when javascript calls the `prompt()` method to display a prompt dialog. |
| ★ `onLargestContentfulPaintMillis` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when the page's Largest Contentful Paint happens. |
| `onLoadResource` | ✓ | ✓ | Event fired when the `WebView` loads a resource. |
| `onLoadResourceWithCustomScheme` | ✓ | ✓ | Event fired when the `WebView` finds the `custom-scheme` while loading a resource. |
| `onLoadStart` | ✓ | ✓ | Event fired when the `WebView` starts to load an `url`. |
| `onLoadStop` | ✓ | ✓ | Event fired when the `WebView` finishes loading an `url`. |
| `onLongPressHitTestResult` | ✓ | ✓ | Event fired when an HTML element of the webview has been clicked and held. |
| `onMicrophoneCaptureStateChanged` | — | ✓ | Event fired when a change in the microphone capture state occurred. |
| ★ `onNavigationCompleted` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a navigation finishes, whether or not it succeeded. |
| ★ `onNavigationRedirected` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a navigation is redirected to another URL. |
| `onNavigationResponse` | — | ✓ | Called when a web view asks for permission to navigate to new content after the response to the navigation request is known. |
| ★ `onNavigationStarted` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a navigation starts. |
| `onOverScrolled` | ✓ | ✓ | Event fired to respond to the results of an over-scroll operation. |
| `onPageCommitVisible` | ✓ | ✓ | Called when the web view begins to receive web content. |
| ★ `onPageDeleted` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a page is destroyed and will never be shown again. |
| ★ `onPageDomContentLoadedEvent` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a page's `DOMContentLoaded` event has run. |
| ★ `onPageLoadEvent` | ✓ · `NAVIGATION_LISTENER` | — | Event fired when a page's `load` event has run. |
| ★ `onPerformanceMarkMillis` | ✓ · `NAVIGATION_LISTENER` | — | Event fired once for every `performance.mark()` the page makes. |
| `onPermissionRequest` | ✓ | ✓ | Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied. |
| `onPermissionRequestCanceled` | ✓ | — | Notify the host application that the given permission request has been canceled. |
| `onPrintRequest` | ✓ | ✓ | Event fired when `window.print()` is called from JavaScript side. |
| `onProgressChanged` | ✓ | ✓ | Event fired when the current `progress` of loading a page is changed. |
| `onReceivedClientCertRequest` | ✓ | ✓ | Notify the host application to handle an SSL client certificate request. |
| `onReceivedError` | ✓ | ✓ | Event fired when the `WebView` encounters an `error` loading a `request`. |
| `onReceivedHttpAuthRequest` | ✓ | ✓ | Event fired when the WebView received an HTTP authentication request. |
| `onReceivedHttpError` | ✓ | ✓ | Event fired when the `WebView` receives an HTTP error. |
| `onReceivedLoginRequest` | ✓ | — | Event fired when a request to automatically log in the user has been processed. |
| `onReceivedServerTrustAuthRequest` | ✓ | ✓ | Event fired when the WebView need to perform server trust authentication (certificate validation). |
| `onReceivedTouchIconUrl` | ✓ | — | Event fired when there is an url for an apple-touch-icon. |
| `onRenderProcessGone` | ✓ | — | Event fired when the given WebView's render process has exited. |
| `onRenderProcessResponsive` | API 29+ | — | Event called once when an unresponsive renderer currently associated with the WebView becomes responsive. |
| `onRenderProcessUnresponsive` | API 29+ | — | Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript. |
| `onRequestFocus` | ✓ | — | Request display and focus for this WebView. |
| ★ `onRequestVisitedHistory` | ✓ | — | Event fired when the `WebView` asks your app which URLs the user has already visited, so that the page can style its `:visited` links. |
| `onSafeBrowsingHit` | API 27+ | — | Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing. |
| `onScrollChanged` | ✓ | ✓ | Event fired when the `WebView` scrolls. |
| `onShowFileChooser` | ✓ | 18.4+ ★ | Tell the client to show a file chooser. |
| `onTitleChanged` | ✓ | ✓ | Event fired when a change in the document title occurred. |
| `onUpdateVisitedHistory` | ✓ | ✓ | Event fired when the host application updates its visited links database. |
| `onWebContentProcessDidTerminate` | — | ✓ | Invoked when the web view's web content process is terminated. |
| `onWebViewCreated` | ✓ | ✓ | Event fired when the `WebView` is created. |
| `onWindowBlur` | ✓ | ✓ | Event fired when the JavaScript `window` object of the WebView has lost focus. |
| `onWindowFocus` | ✓ | ✓ | Event fired when the JavaScript `window` object of the WebView has received focus. |
| ★ `onWritingToolsActiveChanged` | — | 18.0+ | Event fired when Writing Tools becomes active or inactive for the `WebView`. |
| `onZoomScaleChanged` | ✓ | ✓ | Event fired when the zoom scale of the WebView has changed. |
| `pullToRefreshController` | ✓ | ✓ | Represents the pull-to-refresh feature controller. |
| `shouldAllowDeprecatedTLS` | — | ✓ | Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1). |
| ★ `shouldGoToBackForwardListItem` | — | 26.0+ | Gives the app the chance to veto a back or forward navigation before it happens. |
| `shouldInterceptAjaxRequest` | ✓ · `DOCUMENT_START_SCRIPT` | ✓ | Event fired when an `XMLHttpRequest` is sent to a server. |
| `shouldInterceptFetchRequest` | ✓ · `DOCUMENT_START_SCRIPT` | ✓ | Event fired when a request is sent to a server through Fetch API. |
| `shouldInterceptRequest` | ✓ | — | Notify the host application of a resource request and allow the application to return the data. |
| `shouldOverrideUrlLoading` | ✓ | ✓ | Give the host application a chance to take control when a URL is about to be loaded in the current WebView. |
| `windowId` | ✓ | ✓ | The window id of a `windowId`. |

#### InAppWebView — Widget-only parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `headlessWebView` | ✓ | ✓ | The `PlatformHeadlessInAppWebView` to use to initialize this widget. |
| `keepAlive` | ✓ | ✓ | Used to keep alive this WebView. |
| `preventGestureDelay` | — | ✓ | Used to prevent gesture delay on iOS caused by Flutter's gestures handling between native/platform views. |

</details>

<details>
<summary><b><code>InAppWebViewController</code></b> — 128 APIs, 10 ★</summary>

#### InAppWebViewController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `addJavaScriptHandler` | ✓ | ✓ | Adds a JavaScript message handler `callback` (`JavaScriptHandlerFunction`) that listen to post messages sent from JavaScript by the handler with name `handlerName`. |
| `addUserScript` | ✓ | ✓ | Injects the specified `userScript` into the webpage’s content. |
| `addUserScripts` | ✓ | ✓ | Injects the `userScripts` into the webpage’s content. |
| `addWebMessageListener` | ✓ · `WEB_MESSAGE_LISTENER` | ✓ | Adds a `PlatformWebMessageListener` to the WebView and injects a JavaScript object into each frame that the `PlatformWebMessageListener` will listen on. |
| `callAsyncJavaScript` | ✓ | ✓ | Executes the specified string as an asynchronous JavaScript function. |
| `canGoBack` | ✓ | ✓ | Returns a boolean value indicating whether the WebView can move backward. |
| `canGoBackOrForward` | ✓ | ✓ | Returns a boolean value indicating whether the WebView can go back or forward the given number of `steps`. |
| `canGoForward` | ✓ | ✓ | Returns a boolean value indicating whether the WebView can move forward. |
| `canScrollHorizontally` | ✓ | ✓ | Returns `true` if the webpage can scroll horizontally, otherwise `false`. |
| `canScrollVertically` | ✓ | ✓ | Returns `true` if the webpage can scroll vertically, otherwise `false`. |
| `clearAllCache` | ✓ | ✓ | Clears the resource cache. |
| `clearClientCertPreferences` | ✓ | — | Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests. |
| `clearFocus` | ✓ | ✓ | Clears the current focus. |
| `clearFormData` | ✓ | — | Removes the autocomplete popup from the currently focused form field, if present. |
| `clearHistory` | ✓ | — | Clears the internal back/forward list. |
| `clearSslPreferences` | ✓ | — | Clears the SSL preferences table stored in response to proceeding with SSL certificate errors. |
| `closeAllMediaPresentations` | — | ✓ | Closes all media the web view is presenting, including picture-in-picture video and fullscreen video. |
| `createPdf` | — | ✓ | Generates PDF data from the web view’s contents asynchronously. |
| `createWebArchiveData` | — | ✓ | Creates a web archive of the web view’s current contents asynchronously. |
| `createWebMessageChannel` | ✓ · `CREATE_WEB_MESSAGE_CHANNEL` | ✓ | Creates a message channel to communicate with JavaScript and returns the message channel with ports that represent the endpoints of this message channel. |
| `disableWebView` | API 28+ | — | Indicate that the current process does not intend to use WebView, and that an exception should be thrown if a WebView is created or any other methods in the `android.webkit` package are used. |
| `dispose` | ✓ | ✓ | Disposes the controller. |
| `disposeKeepAlive` | ✓ | ✓ | Disposes the WebView that is using the `keepAlive` instance for the keep alive feature. |
| ★ `documentHasImages` | ✓ | — | Returns whether the currently loaded document references any image at all. |
| `enableSlowWholeDocumentDraw` | ✓ | — | For apps targeting the L release, WebView has a new default behavior that reduces memory footprint and increases performance by intelligently choosing the portion of the HTML document that needs to be drawn. |
| `evaluateJavascript` | ✓ | ✓ | Evaluates JavaScript `source` code into the WebView and returns the result of the evaluation. |
| ★ `flingScroll` | ✓ | — | Starts a fling — a scroll that is thrown with an initial velocity and then decelerates on its own, the way a flick of the finger does. |
| `getCameraCaptureState` | — | ✓ | Returns a `MediaCaptureState` that indicates whether the webpage is using the camera to capture images or video. |
| `getCertificate` | ✓ | ✓ | Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure). |
| `getContentHeight` | ✓ | ✓ | Gets the height of the HTML content. |
| `getContentWidth` | ✓ | ✓ | Gets the width of the HTML content. |
| ★ `getConversationContext` | — | 26.0+ | Returns the conversation currently handed to the keyboard, or `null` when the platform cannot answer — every platform but iOS, and iOS below 26.0. |
| `getCopyBackForwardList` | ✓ | ✓ | Gets the WebHistory for this WebView. |
| `getCurrentWebViewPackage` | ✓ | — | If WebView has already been loaded into the current process this method will return the package that was used to load it. |
| `getDefaultUserAgent` | ✓ | ✓ | Gets the default user agent. |
| `getFavicons` | ✓ | ✓ | Gets the list of all favicons for the current page. |
| `getHitTestResult` | ✓ | ✓ | Gets the hit result for hitting an HTML elements. |
| `getHtml` | ✓ | ✓ | Gets the content html of the page. |
| `getJavaScriptBridgeName` | ✓ | ✓ | Gets the name of the JavaScript Bridge object that is used to interact with the WebView. |
| `getMetaTags` | ✓ | ✓ | Returns the list of `<meta>` tags of the current WebView. |
| `getMetaThemeColor` | ✓ | ✓ | Returns an instance of `Color` representing the `content` value of the `<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`. |
| `getMicrophoneCaptureState` | — | ✓ | Returns a `MediaCaptureState` that indicates whether the webpage is using the microphone to capture audio. |
| `getOriginalUrl` | ✓ | ✓ | Gets the URL that was originally requested for the current page. |
| `getProgress` | ✓ | ✓ | Gets the progress for the current page. |
| `getSafeBrowsingPrivacyPolicyUrl` | ✓ · `SAFE_BROWSING_PRIVACY_POLICY_URL` | — | Returns a URL pointing to the privacy policy for Safe Browsing reporting. |
| `getScrollX` | ✓ | ✓ | Returns the scrolled left position of the current WebView. |
| `getScrollY` | ✓ | ✓ | Returns the scrolled top position of the current WebView. |
| `getSelectedText` | ✓ | ✓ | Gets the selected text. |
| `getSettings` | ✓ | ✓ | Gets the current WebView settings. |
| `getTitle` | ✓ | ✓ | Gets the title for the current page. |
| `getUrl` | ✓ | ✓ | Gets the URL for the current page. |
| `getVariationsHeader` | ✓ · `GET_VARIATIONS_HEADER` | — | Gets the WebView variations encoded to be used as the X-Client-Data HTTP header. |
| `getViewId` | ✓ | ✓ | View ID used internally. |
| `getZoomScale` | ✓ | ✓ | Gets the current zoom scale of the WebView. |
| `goBack` | ✓ | ✓ | Goes back in the history of the WebView. |
| `goBackOrForward` | ✓ | ✓ | Goes to the history item that is the number of `steps` away from the current item. |
| `goForward` | ✓ | ✓ | Goes forward in the history of the WebView. |
| `goTo` | ✓ | ✓ | Navigates to a `WebHistoryItem` from the back-forward `list` and sets it as the current item. |
| `handlesURLScheme` | — | ✓ | Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme. |
| `hasJavaScriptHandler` | ✓ | ✓ | Returns `true` if a JavaScript handler with `handlerName` already exists, otherwise `false`. |
| `hasOnlySecureContent` | — | ✓ | A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections. |
| `hasUserScript` | ✓ | ✓ | Returns `true` if the `userScript` has been already added, otherwise `false`. |
| `hasWebMessageListener` | ✓ | ✓ | Returns `true` if the `webMessageListener` has been already added, otherwise `false`. |
| `hideInputMethod` | ✓ | ✓ | Request to hide the soft input view from the context of the view that is currently accepting input. |
| `injectCSSCode` | ✓ | ✓ | Injects CSS into the WebView. |
| `injectCSSFileFromAsset` | ✓ | ✓ | Injects a CSS file into the WebView from the flutter assets directory. |
| `injectCSSFileFromUrl` | ✓ | ✓ | Injects an external CSS file into the WebView from a defined url. |
| `injectJavascriptFileFromAsset` | ✓ | ✓ | Evaluates the content of a JavaScript file into the WebView from the flutter assets directory. |
| `injectJavascriptFileFromUrl` | ✓ | ✓ | Injects an external JavaScript file into the WebView from a defined url. |
| ★ `isAudioMuted` | ✓ · `MUTE_AUDIO` | — | Returns whether audio output from this WebView is currently muted. |
| ★ `isBlockedByScreenTime` | — | 26.0+ | Returns whether Screen Time restrictions are currently blocking the content of this WebView. |
| `isInFullscreen` | ✓ | ✓ | Returns `true` if the `WebView` is in fullscreen mode, otherwise `false`. |
| `isLoading` | ✓ | ✓ | Check if the WebView instance is in a loading state. |
| `isMultiProcessEnabled` | ✓ · `MULTI_PROCESS` | — | Returns `true` if WebView is running in multi process mode. |
| `isSecureContext` | ✓ | ✓ | Indicates whether the webpage context is capable of using features that require secure contexts. |
| `loadData` | ✓ | ✓ | Loads the given `data` into this WebView, using `baseUrl` as the base URL for the content. |
| `loadFile` | ✓ | ✓ | Loads the given `assetFilePath`. |
| `loadSimulatedRequest` | — | ✓ | Loads the web content from the data you provide as if the data were the response to the request. |
| `loadUrl` | ✓ | ✓ | Loads the given `urlRequest`. |
| `pageDown` | ✓ | — | Scrolls the contents of this WebView down by half the page size. |
| `pageUp` | ✓ | — | Scrolls the contents of this WebView up by half the view size. |
| `pause` | ✓ | — | Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. |
| `pauseAllMediaPlayback` | — | ✓ | Pauses playback of all media in the web view. |
| `pauseTimers` | ✓ | ✓ | On Android native WebView, it pauses all layout, parsing, and JavaScript timers for all WebViews. |
| `postUrl` | ✓ | ✓ | Loads the given `url` with `postData` (x-www-form-urlencoded) using `POST` method into this WebView. |
| ★ `postVisualStateCallback` | ✓ | — | Completes once the DOM **as it exists at the moment of this call** has been drawn to the screen. |
| `postWebMessage` | ✓ · `POST_WEB_MESSAGE` | ✓ | Post a message to main frame. |
| ★ `prerenderUrl` | ✓ · `PRERENDER_WITH_URL` | — | Asks this WebView to prerender `url`, so that a later navigation to it is instant. |
| `printCurrentPage` | ✓ | ✓ | Prints the current page. |
| `reload` | ✓ | ✓ | Reloads the WebView. |
| `reloadFromOrigin` | — | ✓ | Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible. |
| `removeAllUserScripts` | ✓ | ✓ | Removes all the user scripts from the webpage’s content. |
| `removeJavaScriptHandler` | ✓ | ✓ | Removes a JavaScript message handler previously added with the `addJavaScriptHandler` associated to `handlerName` key. |
| `removeUserScript` | ✓ | ✓ | Removes the specified `userScript` from the webpage’s content. |
| `removeUserScripts` | ✓ | ✓ | Removes the `userScripts` from the webpage’s content. |
| `removeUserScriptsByGroupName` | ✓ | ✓ | Removes all the `UserScript`s with `groupName` as group name from the webpage’s content. |
| `requestFocus` | ✓ | ✓ | Call this method when you want to try the WebView to be the first responder. |
| `requestFocusNodeHref` | ✓ | ✓ | Requests the anchor or image element URL at the last tapped point. |
| `requestImageRef` | ✓ | ✓ | Requests the URL of the image last touched by the user. |
| `requestMediaPlaybackState` | — | ✓ | Requests the playback status of media in the web view. |
| `restoreState` | ✓ | ✓ | Restores the state of this WebView from the given `state` returned by the `saveState` method. |
| `resume` | ✓ | — | Resumes a WebView after a previous call to `pause`. |
| `resumeTimers` | ✓ | ✓ | On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. |
| `saveState` | ✓ · `SAVE_STATE` | ✓ | Returns the current state of interaction in a web view so that you can restore that state later to another web view using the `restoreState` method. |
| `saveWebArchive` | ✓ | ✓ | Saves the current WebView as a web archive. |
| `scrollBy` | ✓ | ✓ | Moves the scrolled position of the WebView. |
| `scrollTo` | ✓ | ✓ | Scrolls the WebView to the position. |
| `setAllMediaPlaybackSuspended` | — | ✓ | Changes whether the webpage is suspending playback of all media in the page. |
| ★ `setAudioMuted` | ✓ · `MUTE_AUDIO` | — | Mutes or unmutes all audio output from this WebView. |
| `setCameraCaptureState` | — | ✓ | Changes whether the webpage is using the camera to capture images or video. |
| `setContextMenu` | ✓ | ✓ | Sets or updates the WebView context menu to be used next time it will appear. |
| ★ `setConversationContext` | — | 26.0+ | Gives the system keyboard the conversation the user is replying to, so it can offer **Smart Replies** while they type into a web text field. |
| ★ `setDefaultTrafficStatsTag` | ✓ · `DEFAULT_TRAFFICSTATS_TAGGING` | — | Sets the default `TrafficStats` tag used to account for the socket traffic caused by WebView. |
| `setInputMethodEnabled` | — | ✓ | Enables/Disables the input method (system-supplied keyboard) whilst interacting with the webview. |
| `setJavaScriptBridgeName` | ✓ | ✓ | Sets the name of the JavaScript Bridge object that will be used to interact with the WebView. |
| `setMicrophoneCaptureState` | — | ✓ | Changes whether the webpage is using the microphone to capture audio. |
| `setSafeBrowsingAllowlist` | ✓ · `SAFE_BROWSING_ALLOWLIST` | — | Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. |
| `setSettings` | ✓ | ✓ | Sets the WebView settings with the new `settings` and evaluates them. |
| `setWebContentsDebuggingEnabled` | ✓ | — | Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application. |
| `showInputMethod` | ✓ | — | Explicitly request that the current input method's soft input area be shown to the user, if needed. |
| `stopLoading` | ✓ | ✓ | Stops the WebView from loading. |
| `takeScreenshot` | ✓ | ✓ | Takes a screenshot of the WebView's visible viewport and returns a `Uint8List`. |
| `zoomBy` | ✓ | ✓ | Performs a zoom operation in this WebView. |
| `zoomIn` | ✓ | — | Performs zoom in in this WebView. |
| `zoomOut` | ✓ | — | Performs zoom out in this WebView. |

#### InAppWebViewController — Properties

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `tRexRunnerCss` | ✓ | ✓ | Gets the css of the Chromium's t-rex runner game. |
| `tRexRunnerHtml` | ✓ | ✓ | Gets the html (with javascript) of the Chromium's t-rex runner game. |
| `webStorage` | ✓ | ✓ | Provides access to the JavaScript Web Storage API: `window.sessionStorage` and `window.localStorage`. |

</details>

<details>
<summary><b><code>InAppWebViewSettings</code></b> — 159 APIs, 23 ★</summary>

#### InAppWebViewSettings — Settings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `accessibilityIgnoresInvertColors` | — | ✓ | A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors. |
| `algorithmicDarkeningAllowed` | API 29+ · `ALGORITHMIC_DARKENING` | — | Control whether algorithmic darkening is allowed. |
| `allowBackgroundAudioPlaying` | ✓ | — | Set to `true` to allow audio playing when the app goes in background or the screen is locked or another app is opened. |
| `allowContentAccess` | ✓ | — | Enables or disables content URL access within WebView. |
| `allowFileAccess` | ✓ | — | Enables or disables file access within WebView. |
| `allowFileAccessFromFileURLs` | ✓ | ✓ | Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs. |
| `allowingReadAccessTo` | — | ✓ | Used in combination with `initialUrlRequest` or `initialData` (using the `file://` scheme), it represents the URL from which to read the web content. |
| `allowsAirPlayForMediaPlayback` | — | ✓ | Set to `true` to allow AirPlay. |
| `allowsBackForwardNavigationGestures` | — | ✓ | Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. |
| `allowsInlineMediaPlayback` | — | ✓ | Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls. |
| `allowsLinkPreview` | — | ✓ | Set to `true` to allow that pressing on a link displays a preview of the destination for the link. |
| `allowsPictureInPictureMediaPlayback` | — | ✓ | Set to `true` to allow HTML5 videos play picture-in-picture. |
| `allowUniversalAccessFromFileURLs` | ✓ | ✓ | Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin. |
| `alpha` | ✓ | ✓ | The view’s alpha value. |
| `alwaysBounceHorizontal` | — | ✓ | A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view. |
| `alwaysBounceVertical` | — | ✓ | A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content. |
| `appCachePath` | ✓ | — | Sets the path to the Application Caches files. |
| `applePayAPIEnabled` | — | ✓ | Set to `true` to enable Apple Pay API for the `WebView` at its first page load or on the next page load (using `setOptions`). |
| `applicationNameForUserAgent` | ✓ | ✓ | Append to the existing user-agent. |
| ★ `attributionRegistrationBehavior` | ✓ · `ATTRIBUTION_REGISTRATION_BEHAVIOR` | — | Sets how this WebView registers sources and triggers for the Attribution Reporting API. |
| `automaticallyAdjustsScrollIndicatorInsets` | — | ✓ | Configures whether the scroll indicator insets are automatically adjusted by the system. |
| ★ `backForwardCacheEnabled` | ✓ · `BACK_FORWARD_CACHE` | — | Sets whether this WebView uses the back/forward cache. |
| `blockNetworkImage` | ✓ | — | Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). |
| `blockNetworkLoads` | ✓ | — | Sets whether the WebView should not load resources from the network. |
| `builtInZoomControls` | ✓ | — | Set to `true` if the WebView should use its built-in zoom mechanisms. |
| `cacheEnabled` | ✓ | ✓ | Sets whether WebView should use browser caching. |
| `cacheMode` | ✓ | — | Overrides the way the cache is used. |
| `contentBlockers` | ✓ | ✓ | List of `ContentBlocker` that are a set of rules used to block content in the browser window. |
| `contentInsetAdjustmentBehavior` | — | ✓ | Configures how safe area insets are added to the adjusted content inset. |
| `cursiveFontFamily` | ✓ | — | Sets the cursive font family name. |
| `databaseEnabled` | ✓ | — | Set to `true` if you want the database storage API is enabled. |
| `dataDetectorTypes` | — | ✓ | Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value. |
| `decelerationRate` | — | ✓ | A `ScrollViewDecelerationRate` value that determines the rate of deceleration after the user lifts their finger. |
| `defaultFixedFontSize` | ✓ | — | Sets the default fixed font size. |
| `defaultFontSize` | ✓ | — | Sets the default font size. |
| `defaultTextEncodingName` | ✓ | — | Sets the default text encoding name to use when decoding html pages. |
| `defaultVideoPoster` | ✓ | — | When not playing, video elements are represented by a 'poster' image. |
| `disableContextMenu` | ✓ | ✓ | Set to `true` to disable context menu. |
| `disabledActionModeMenuItems` | ✓ | — | Disables the action mode menu items according to menuItems flag. |
| `disableDefaultErrorPage` | ✓ | — | Sets whether the default Android WebView’s internal error page should be suppressed or displayed for bad navigations. |
| `disableHorizontalScroll` | ✓ | ✓ | Set to `true` to disable horizontal scroll. |
| `disableInputAccessoryView` | — | ✓ | Set to `true` to disable the inputAccessoryView above system keyboard. |
| `disableLongPressContextMenuOnLinks` | — | ✓ | Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link. |
| `disableVerticalScroll` | ✓ | ✓ | Set to `true` to disable vertical scroll. |
| `disallowOverScroll` | — | ✓ | Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. |
| `displayZoomControls` | ✓ | — | Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. |
| `domStorageEnabled` | ✓ | — | Set to `true` if you want the DOM storage API is enabled. |
| ★ `downloadFaviconsEnabled` | ✓ · `DOWNLOAD_FAVICONS_ENABLED` | — | Sets whether this WebView downloads the favicons declared by the pages it loads. |
| `enableViewportScale` | — | ✓ | Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. |
| `enterpriseAuthenticationAppLinkPolicyEnabled` | ✓ · `ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY` | — | Sets whether EnterpriseAuthenticationAppLinkPolicy if set by admin is allowed to have any effect on WebView. |
| `fantasyFontFamily` | ✓ | — | Sets the fantasy font family name. |
| `fixedFontFamily` | ✓ | — | Sets the fixed font family name. |
| `geolocationEnabled` | ✓ | — | Sets whether Geolocation is enabled. |
| ★ `globalPrivacyControlEnabled` | — | 27.0+ | Whether the WebView sends the Global Privacy Control (GPC) signal, the user's request that sites not sell or share their data. |
| `hardwareAcceleration` | ✓ | — | Boolean value to enable Hardware Acceleration in the WebView. |
| `horizontalScrollBarEnabled` | ✓ | ✓ | Define whether the horizontal scrollbar should be drawn or not. |
| `horizontalScrollbarThumbColor` | API 29+ | — | Sets the horizontal scrollbar thumb color. |
| `horizontalScrollbarTrackColor` | API 29+ | — | Sets the horizontal scrollbar track color. |
| `ignoresViewportScaleLimits` | — | ✓ | Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent. |
| ★ `includeCookiesOnShouldInterceptRequest` | ✓ · `COOKIE_INTERCEPT` | — | Whether the request passed to `shouldInterceptRequest` carries the `Cookie` header that the WebView would have sent, and whether `cookies` on the response you return is honoured. |
| `incognito` | ✓ | ✓ | Set to `true` to open a browser window with incognito mode. |
| `initialScale` | ✓ | — | Sets the initial scale for this WebView. 0 means default. |
| `interceptOnlyAsyncAjaxRequests` | ✓ | ✓ | Set to `false` to be able to listen to also sync `XMLHttpRequest`s at the `shouldInterceptAjaxRequest` event. |
| `isDirectionalLockEnabled` | — | ✓ | A Boolean value that determines whether scrolling is disabled in a particular direction. |
| `isElementFullscreenEnabled` | — | 15.4+ | Sets whether fullscreen API is enabled or not. |
| `isFindInteractionEnabled` | — | 16.0+ | Sets whether the web view's built-in find interaction native UI is enabled or not. |
| `isFraudulentWebsiteWarningEnabled` | — | ✓ | A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware. |
| `isInspectable` | — | 16.4+ | Controls whether this WebView is inspectable in Web Inspector. |
| `isPagingEnabled` | — | ✓ | A Boolean value that determines whether paging is enabled for the scroll view. |
| `isSiteSpecificQuirksModeEnabled` | — | 15.4+ | A Boolean value indicating whether WebKit will apply built-in workarounds (quirks) to improve compatibility with certain known websites. |
| `isTextInteractionEnabled` | — | ✓ | A Boolean value indicating whether text interaction is enabled or not. |
| `isUserInteractionEnabled` | ✓ | ✓ | A Boolean value that determines whether user events are ignored and removed from the event queue. |
| `javaScriptBridgeEnabled` | ✓ | ✓ | Set to `false` to disable the JavaScript Bridge completely. |
| `javaScriptBridgeForMainFrameOnly` | ✓ | ✓ | Set to `true` to allow the JavaScript Bridge only on the main frame. |
| `javaScriptBridgeOriginAllowList` | ✓ | ✓ | A `Set` of patterns that will be used to match the allowed origins where the JavaScript Bridge could be used. |
| `javaScriptCanOpenWindowsAutomatically` | ✓ | ✓ | Set to `true` to allow JavaScript open windows without user interaction. |
| `javaScriptEnabled` | ✓ | ✓ | Set to `true` to enable JavaScript. |
| `javaScriptHandlersForMainFrameOnly` | ✓ | ✓ | Set to `true` to allow to execute the JavaScript Handlers only on the main frame. |
| `javaScriptHandlersOriginAllowList` | ✓ | ✓ | A `Set` of Regular Expression Patterns that will be used on native side to match the allowed origins that are able to execute the JavaScript Handlers defined for the current WebView. |
| `layoutAlgorithm` | ✓ | — | Sets the underlying layout algorithm. |
| `limitsNavigationsToAppBoundDomains` | — | ✓ | A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain. |
| `loadsImagesAutomatically` | ✓ | — | Sets whether the WebView should load image resources. |
| `loadWithOverviewMode` | ✓ | — | Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width. |
| ★ `lockdownModeEnabled` | — | 16.0+ | Whether Lockdown Mode is enabled for this WebView's navigations. |
| `maximumViewportInset` | — | 15.5+ | Set maximum viewport inset to the largest inset a webpage may experience in your app's maximally expanded UI configuration. |
| `maximumZoomScale` | — | ✓ | A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content. |
| `mediaPlaybackRequiresUserGesture` | ✓ | ✓ | Set to `true` to prevent HTML5 audio or video from autoplaying. |
| `mediaType` | — | ✓ | The media type for the contents of the web view. |
| `minimumFontSize` | ✓ | ✓ | Sets the minimum font size. |
| `minimumLogicalFontSize` | ✓ | — | Sets the minimum logical font size. |
| `minimumViewportInset` | — | 15.5+ | Set minimum viewport inset to the smallest inset a webpage may experience in your app's maximally collapsed UI configuration. |
| `minimumZoomScale` | — | ✓ | A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content. |
| `mixedContentMode` | ✓ | — | Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin. |
| `needInitialFocus` | ✓ | — | Tells the WebView whether it needs to set a node. |
| `networkAvailable` | ✓ | — | Informs WebView of the network state. |
| ★ `obscuredContentInsets` | — | 26.0+ | Edge insets, relative to the WebView's own coordinate space, that shrink the **layout viewport** because your app draws something over those areas — a translucent navigation bar, a floating toolbar, a set of overlay… |
| `offscreenPreRaster` | ✓ | — | Sets whether this WebView should raster tiles when it is offscreen but attached to a window. |
| `overScrollMode` | ✓ | — | Sets the WebView's over-scroll mode. |
| `pageZoom` | — | ✓ | The scale factor by which the web view scales content relative to its bounds. |
| ★ `paymentRequestEnabled` | ✓ · `PAYMENT_REQUEST` | — | Sets whether the Payment Request API is enabled in this WebView. |
| `pluginScriptsForMainFrameOnly` | ✓ | ✓ | Set to `true` to allow internal plugin `UserScript`s only on the main frame. |
| `pluginScriptsOriginAllowList` | ✓ | ✓ | A `Set` of patterns that will be used to match the allowed origins that are able to load all the internal plugin `UserScript`s used by the plugin itself. |
| `preferredContentMode` | ✓ | ✓ | Sets the content mode that the WebView needs to use when loading and rendering a webpage. |
| ★ `preferredHTTPSNavigationPolicy` | — | 18.2+ | Whether a top-level navigation should be upgraded to HTTPS, and what should happen when the upgrade fails. |
| ★ `profileName` | ✓ · `MULTI_PROFILE` | — | Runs this WebView on the named browsing profile, creating the profile if it does not exist. |
| `regexToAllowSyncUrlLoading` | ✓ | — | Regular expression used on native side by the `shouldOverrideUrlLoading` event to allow navigation requests synchronously. |
| `regexToCancelSubFramesLoading` | ✓ | — | Regular expression used on native side by the `shouldOverrideUrlLoading` event to cancel navigation requests for frames that are not the main frame. |
| `rendererPriorityPolicy` | ✓ | — | Sets the renderer priority policy for this WebView. |
| `resourceCustomSchemes` | ✓ | ✓ | List of custom schemes that the WebView must handle. |
| `safeBrowsingEnabled` | ✓ | — | Sets whether Safe Browsing is enabled. |
| `sansSerifFontFamily` | ✓ | — | Sets the sans-serif font family name. |
| `scrollBarDefaultDelayBeforeFade` | ✓ | — | Defines the delay in milliseconds that a scrollbar waits before fade out. |
| `scrollBarFadeDuration` | ✓ | — | Defines the scrollbar fade duration in milliseconds. |
| `scrollbarFadingEnabled` | ✓ | — | Defines whether scrollbars will fade when the view is not scrolling. |
| `scrollBarStyle` | ✓ | — | Specifies the style of the scrollbars. |
| `scrollsToTop` | — | ✓ | A Boolean value that controls whether the scroll-to-top gesture is enabled. |
| ★ `securityRestrictionMode` | — | 26.5+ | How much additional security hardening the WebView should apply to a navigation. |
| `serifFontFamily` | ✓ | — | Sets the serif font family name. |
| `sharedCookiesEnabled` | — | ✓ | Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView. |
| `shouldPrintBackgrounds` | — | 16.4+ | A Boolean value that indicates whether to include any background color or graphics when printing content. |
| ★ `showsSystemScreenTimeBlockingView` | — | 26.0+ | Whether WebKit draws its own Screen Time blocking view over the WebView when Screen Time restrictions block the loaded content. |
| `standardFontFamily` | ✓ | — | Sets the standard font family name. |
| `supportMultipleWindows` | ✓ | — | Sets whether the WebView supports multiple windows. |
| ★ `supportsAdaptiveImageGlyph` | — | 18.0+ | Whether the WebView allows insertion of **adaptive image glyphs** — the inline, text-sized images Apple Intelligence produces, most visibly Genmoji — into editable content. |
| `supportZoom` | ✓ | ✓ | Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. |
| `suppressesIncrementalRendering` | — | ✓ | Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. |
| ★ `syncCallbackTimeoutMillis` | ✓ | — | How long, **in milliseconds**, the WebView will wait for your Dart handler to answer a *synchronous* callback before continuing without it. |
| `textZoom` | ✓ | — | Sets the text zoom of the page in percent. |
| `thirdPartyCookiesEnabled` | ✓ | — | Boolean value to enable third party cookies in the WebView. |
| `transparentBackground` | ✓ | ✓ | Set to `true` to make the background of the WebView transparent. |
| `underPageBackgroundColor` | — | ✓ | The color the web view displays behind the active page, visible when the user scrolls beyond the bounds of the page. |
| `upgradeKnownHostsToHTTPS` | — | ✓ | A Boolean value indicating whether HTTP requests to servers known to support HTTPS should be automatically upgraded to HTTPS requests. |
| `useHybridComposition` | ✓ | — | Set to `false` to disable Flutter Hybrid Composition. |
| ★ `useNavigationListener` | ✓ | — | Set to `true` to be able to listen at the `onNavigationStarted`, `onNavigationRedirected` and `onNavigationCompleted` events. |
| `useOnAjaxProgress` | ✓ | ✓ | Set to `true` to be able to listen at the `onAjaxProgress` event. |
| `useOnAjaxReadyStateChange` | ✓ | ✓ | Set to `true` to be able to listen at the `onAjaxReadyStateChange` event. |
| `useOnDownloadStart` | ✓ | ✓ | Set to `true` to be able to listen at the `onDownloadStarting` event. |
| ★ `useOnInsertInputSuggestion` | — | 26.0+ | Set to `true` to be able to listen at the `onInsertInputSuggestion` event. |
| `useOnLoadResource` | ✓ | ✓ | Set to `true` to be able to listen at the `onLoadResource` event. |
| `useOnNavigationResponse` | — | ✓ | Set to `true` to be able to listen to the `onNavigationResponse` event. |
| ★ `useOnPerformanceMarkMillis` | ✓ | — | Set to `true` to be able to listen at the `onPerformanceMarkMillis` event. |
| `useOnRenderProcessGone` | ✓ | — | Set to `true` to be able to listen at the `onRenderProcessGone` event. |
| `useOnShowFileChooser` | ✓ | 18.4+ ★ | Set to `true` to be able to listen at the `onShowFileChooser` event. |
| `userAgent` | ✓ | ✓ | Sets the user-agent for the WebView. |
| ★ `userAgentMetadata` | ✓ · `USER_AGENT_METADATA`, `USER_AGENT_METADATA_FORM_FACTORS` | — | Overrides the User-Agent Client Hints this WebView reports. |
| ★ `useShouldGoToBackForwardListItem` | — | 26.0+ | Set to `true` to be able to listen at the `shouldGoToBackForwardListItem` event. |
| `useShouldInterceptAjaxRequest` | ✓ | ✓ | Set to `true` to be able to listen at the `shouldInterceptAjaxRequest` event. |
| `useShouldInterceptFetchRequest` | ✓ | ✓ | Set to `true` to be able to listen at the `shouldInterceptFetchRequest` event. |
| `useShouldInterceptRequest` | ✓ | — | Set to `true` to be able to listen at the `shouldInterceptRequest` event. |
| `useShouldOverrideUrlLoading` | ✓ | ✓ | Set to `true` to be able to listen at the `shouldOverrideUrlLoading` event. |
| `useWideViewPort` | ✓ | — | Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport. |
| `verticalScrollBarEnabled` | ✓ | ✓ | Define whether the vertical scrollbar should be drawn or not. |
| `verticalScrollbarPosition` | ✓ | — | Sets the position of the vertical scroll bar. |
| `verticalScrollbarThumbColor` | API 29+ | — | Sets the vertical scrollbar thumb color. |
| `verticalScrollbarTrackColor` | API 29+ | — | Sets the vertical scrollbar track color. |
| ★ `webAuthenticationSupport` | ✓ · `WEB_AUTHENTICATION` | — | Sets the level of Web Authentication API support this WebView provides, i.e. whether web content may create and use passkeys. |
| `webViewAssetLoader` | ✓ | — | Use a `WebViewAssetLoader` instance to load local files including application's static assets and resources using http(s):// URLs. |
| ★ `webViewMediaIntegrityApiStatus` | ✓ · `WEBVIEW_MEDIA_INTEGRITY_API_STATUS` | — | Sets the WebView Media Integrity API configuration for this WebView. |
| ★ `writingToolsBehavior` | — | 18.0+ | How much of the Apple Intelligence Writing Tools UI this WebView should offer for editable content. |

</details>

<details>
<summary><b><code>HeadlessInAppWebView</code></b> — 6 APIs</summary>

#### HeadlessInAppWebView — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `dispose` | ✓ | ✓ | Disposes the headless WebView. |
| `getSize` | ✓ | ✓ | Gets the current size in logical pixels of the WebView — the same unit `setSize` accepts. |
| `isRunning` | ✓ | ✓ | Indicates if the headless WebView is running or not. |
| `run` | ✓ | ✓ | Runs the headless WebView. |
| `setSize` | ✓ | ✓ | Set the size of the WebView in logical pixels — the same unit as Flutter's own `Size`, not physical device pixels. |

#### HeadlessInAppWebView — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `initialSize` | ✓ | ✓ | The WebView initial size in pixels. |

</details>

<details>
<summary><b><code>InAppBrowser</code></b> — 50 APIs</summary>

#### InAppBrowser — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `addMenuItem` | ✓ | ✓ | Adds a `InAppBrowserMenuItem` to the menu. |
| `addMenuItems` | ✓ | ✓ | Adds a list of `InAppBrowserMenuItem` to the menu. |
| `close` | ✓ | ✓ | Closes the `PlatformInAppBrowser` window. |
| `dispose` | ✓ | ✓ | Disposes the channel and controllers. |
| `getSettings` | ✓ | ✓ | Gets the current `PlatformInAppBrowser` settings. |
| `hasMenuItem` | ✓ | ✓ | Returns `true` if the `menuItem` has been already added, otherwise `false`. |
| `hide` | ✓ | ✓ | Hides the `PlatformInAppBrowser` window. |
| `isHidden` | ✓ | ✓ | Check if the Web View of the `PlatformInAppBrowser` instance is hidden. |
| `isOpened` | ✓ | ✓ | Returns `true` if the `PlatformInAppBrowser` instance is opened, otherwise `false`. |
| `openData` | ✓ | ✓ | Opens the `PlatformInAppBrowser` instance with `data` as a content, using `baseUrl` as the base URL for it. |
| `openFile` | ✓ | ✓ | Opens the `PlatformInAppBrowser` instance with the given `assetFilePath` file. |
| `openUrlRequest` | ✓ | ✓ | Opens the `PlatformInAppBrowser` instance with an `urlRequest`. |
| `openWithSystemBrowser` | ✓ | ✓ | This is a static method that opens an `url` in the system browser. |
| `removeAllMenuItem` | ✓ | ✓ | Removes all the menu items from the list. |
| `removeMenuItem` | ✓ | ✓ | Removes the `menuItem` from the list. |
| `removeMenuItems` | ✓ | ✓ | Removes a list of `menuItems` from the list. |
| `setSettings` | ✓ | ✓ | Sets the `PlatformInAppBrowser` settings with the new `settings` and evaluates them. |
| `show` | ✓ | ✓ | Displays a `PlatformInAppBrowser` window that was opened hidden. |

#### InAppBrowser — Properties

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `contextMenu` | ✓ | ✓ | Context menu which contains custom menu items to be shown when `ContextMenu` is presented. |
| `findInteractionController` | ✓ | ✓ | Represents the find interaction feature controller. |
| `id` | ✓ | ✓ | View ID used internally. |
| `initialUserScripts` | ✓ | ✓ | Initial list of user scripts to be loaded at start or end of a page loading. |
| `pullToRefreshController` | ✓ | ✓ | Represents the pull-to-refresh feature controller. |
| `windowId` | ✓ | ✓ | The window id of a `windowId`. |

#### InAppBrowser — Browser-only events

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `onBrowserCreated` | ✓ | ✓ | Event fired when the `PlatformInAppBrowser` is created. |
| `onExit` | ✓ | ✓ | Event fired when the `PlatformInAppBrowser` window is closed. |

#### InAppBrowser — InAppBrowserSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `allowGoBackWithBackButton` | ✓ | — | Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. |
| `closeButtonCaption` | — | ✓ | Set the custom text for the close button. |
| `closeButtonColor` | — | ✓ | Set the custom color for the close button. |
| `closeOnCannotGoBack` | ✓ | — | Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. |
| `hidden` | ✓ | ✓ | Set to `true` to create the browser and load the page, but not show it. |
| `hideCloseButton` | — | ✓ | Set to `true` to hide the close button. |
| `hideDefaultMenuItems` | ✓ | ✓ | Set to `true` to hide the default menu items. |
| `hideProgressBar` | ✓ | ✓ | Set to `true` to hide the progress bar when the WebView is loading a page. |
| `hideTitleBar` | ✓ | — | Set to `true` if you want the title should be displayed. |
| `hideToolbarBottom` | — | ✓ | Set to `true` to hide the toolbar at the bottom of the WebView. |
| `hideToolbarTop` | ✓ | ✓ | Set to `true` to hide the toolbar at the top of the WebView. |
| `hideUrlBar` | ✓ | ✓ | Set to `true` to hide the url bar on the toolbar at the top. |
| `menuButtonColor` | — | ✓ | Set the custom color for the menu button. |
| `presentationStyle` | — | ✓ | Set the custom modal presentation style when presenting the WebView. |
| `shouldCloseOnBackButtonPressed` | ✓ | — | Set to `true` to close the InAppBrowser when the user click on the Android back button. |
| `toolbarBottomBackgroundColor` | — | ✓ | Set the custom background color of the toolbar at the bottom. |
| `toolbarBottomTintColor` | — | ✓ | Set the tint color to apply to the bar button items. |
| `toolbarBottomTranslucent` | — | ✓ | Set to `true` to set the toolbar at the bottom translucent. |
| `toolbarTopBackgroundColor` | ✓ | ✓ | Set the custom background color of the toolbar at the top. |
| `toolbarTopBarTintColor` | — | ✓ | Set the tint color to apply to the navigation bar background. |
| `toolbarTopFixedTitle` | ✓ | — | Set the action bar's title. |
| `toolbarTopTintColor` | — | ✓ | Set the tint color to apply to the navigation items and bar button items. |
| `toolbarTopTranslucent` | — | ✓ | Set to `true` to set the toolbar at the top translucent. |
| `transitionStyle` | — | ✓ | Set to the custom transition style when presenting the WebView. |

</details>

<details>
<summary><b><code>ChromeSafariBrowser</code></b> — 63 APIs</summary>

#### ChromeSafariBrowser — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `addMenuItem` | ✓ | ✓ | Adds a `ChromeSafariBrowserMenuItem` to the menu. |
| `addMenuItems` | ✓ | ✓ | Adds a list of `ChromeSafariBrowserMenuItem` to the menu. |
| `clearWebsiteData` | — | 16.0+ | Clear associated website data accrued from browsing activity within your app. |
| `close` | ✓ | ✓ | Closes the `PlatformChromeSafariBrowser` instance. |
| `dispose` | ✓ | ✓ | Disposes the channel and event handler. |
| `getMaxToolbarItems` | ✓ | — | The maximum number of allowed secondary toolbar items. |
| `getPackageName` | ✓ | — | Returns the preferred package to use for Custom Tabs. |
| `invalidatePrewarmingToken` | — | ✓ | Ends all prewarmed connections associated with the token, except for connections that are also kept alive by other tokens. |
| `isAvailable` | ✓ | ✓ | On Android, returns `true` if Chrome Custom Tabs is available. |
| `isEngagementSignalsApiAvailable` | ✓ | — | Returns whether the Engagement Signals API is available. |
| `isOpened` | ✓ | ✓ | Returns `true` if the `PlatformChromeSafariBrowser` instance is opened, otherwise `false`. |
| `launchUrl` | ✓ | — | Tells the browser to launch with `url`. |
| `mayLaunchUrl` | ✓ | — | Tells the browser of a likely future navigation to a URL. |
| `open` | ✓ | ✓ | Opens the `PlatformChromeSafariBrowser` instance with an `url`. |
| `postMessage` | ✓ | — | Sends a postMessage request using the origin communicated via `requestPostMessageChannel`. |
| `prewarmConnections` | — | ✓ | Prewarms a connection to each URL. |
| `requestPostMessageChannel` | ✓ | — | Sends a request to create a two way postMessage channel between the client and the browser. |
| `setActionButton` | ✓ | — | Set a custom action button. |
| `setSecondaryToolbar` | ✓ | — | Sets the remote views displayed in the secondary toolbar in a custom tab. |
| `updateActionButton` | ✓ | — | Updates the `icon` and `description`. |
| `updateSecondaryToolbar` | ✓ | — | Sets or updates (if already present) the Remote Views of the secondary toolbar in an existing custom tab session. |
| `validateRelationship` | ✓ | — | Requests to validate a relationship between the application and an origin. |

#### ChromeSafariBrowser — Events

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `onClosed` | ✓ | ✓ | Event fired when the `PlatformChromeSafariBrowser` is closed. |
| `onCompletedInitialLoad` | ✓ | ✓ | Event fired when the initial URL load is complete. |
| `onGreatestScrollPercentageIncreased` | ✓ | — | Called when a user has reached a greater scroll percentage on the page. |
| `onInitialLoadDidRedirect` | — | ✓ | Event fired when the initial URL load is complete. |
| `onMessageChannelReady` | ✓ | — | Called when the `PlatformChromeSafariBrowser` has requested a postMessage channel through `requestPostMessageChannel` and the channel is ready for sending and receiving messages on both ends. |
| `onNavigationEvent` | ✓ | — | Event fired when a navigation event happens. |
| `onOpened` | ✓ | ✓ | Event fired when the `PlatformChromeSafariBrowser` is opened. |
| `onPostMessage` | ✓ | — | Called when a tab controlled by this `PlatformChromeSafariBrowser` has sent a postMessage. |
| `onRelationshipValidationResult` | ✓ | — | Event fired when a relationship validation result is available. |
| `onServiceConnected` | ✓ | — | Event fired when the when connecting from Android Custom Tabs Service. |
| `onSessionEnded` | ✓ | — | Called when a `CustomTabsSession` is ending or when no further Engagement Signals callbacks are expected to report whether any user action has occurred during the session. |
| `onVerticalScrollEvent` | ✓ | — | Called when a user scrolls the tab. |
| `onWillOpenInBrowser` | — | ✓ | Event fired when the user opens the current page in the default browser by tapping the toolbar button. |

#### ChromeSafariBrowser — ChromeSafariBrowserSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `activityButton` | — | ✓ | An additional button to be shown in `SFSafariViewController`'s toolbar. |
| `additionalTrustedOrigins` | ✓ | — | Sets a list of additional trusted origins that the user may navigate or be redirected to from the starting uri. |
| `alwaysUseBrowserUI` | ✓ | — | Adds the necessary flags and extras to signal any browser supporting custom tabs to use the browser UI at all times and avoid showing custom tab like UI. |
| `barCollapsingEnabled` | — | ✓ | Set to `true` to enable bar collapsing. |
| `dismissButtonStyle` | — | ✓ | Set the custom style for the dismiss button. |
| `displayMode` | ✓ | — | Sets a display mode of a Trusted Web Activity. |
| `enableUrlBarHiding` | ✓ | — | Set to `true` to enable the url bar to hide as the user scrolls down on the page. |
| `entersReaderIfAvailable` | — | ✓ | Set to `true` if Reader mode should be entered automatically when it is available for the webpage. |
| `eventAttribution` | — | 15.2+ | An event attribution associated with a click that caused this `SFSafariViewController` to be opened. |
| `exitAnimations` | ✓ | — | Sets the exit animations. |
| `instantAppsEnabled` | ✓ | — | Set to `true` to enable Instant Apps. |
| `isSingleInstance` | ✓ | — | Set to `true` to launch the Android activity in `singleInstance` mode. |
| `isTrustedWebActivity` | ✓ | — | Set to `true` to launch the Custom Tab as a Trusted Web Activity. |
| `keepAliveEnabled` | ✓ | — | Set to `true` to enable Keep Alive. |
| `navigationBarColor` | ✓ | — | Sets the navigation bar color. |
| `navigationBarDividerColor` | ✓ | — | Sets the navigation bar divider color. |
| `noHistory` | ✓ | — | Set to `true` to launch the Android intent with the flag `FLAG_ACTIVITY_NO_HISTORY`. |
| `packageName` | ✓ | — | Set an explicit application package name that limits the components this Intent will resolve to. |
| `preferredBarTintColor` | — | ✓ | Set the custom background color of the navigation bar and the toolbar. |
| `preferredControlTintColor` | — | ✓ | Set the custom color of the control buttons on the navigation bar and the toolbar. |
| `presentationStyle` | — | ✓ | Set the custom modal presentation style when presenting the WebView. |
| `screenOrientation` | ✓ | — | Sets a screen orientation. |
| `secondaryToolbarColor` | ✓ | — | Sets the color of the secondary toolbar. |
| `shareState` | ✓ | — | The share state that should be applied to the custom tab. |
| `showTitle` | ✓ | — | Set to `false` if the title shouldn't be shown in the custom tab. |
| `startAnimations` | ✓ | — | Sets the start animations. |
| `toolbarBackgroundColor` | ✓ | — | Set the custom background color of the toolbar. |
| `transitionStyle` | — | ✓ | Set to the custom transition style when presenting the WebView. |

</details>

<details>
<summary><b><code>WebAuthenticationSession</code></b> — 12 APIs</summary>

#### WebAuthenticationSession — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `cancel` | — | ✓ | Cancels the web authentication session. |
| `canStart` | — | ✓ | Indicates whether the session can begin. |
| `create` | — | ✓ | Used to create and initialize a session. |
| `dispose` | — | ✓ | Disposes the web authentication session. |
| `isAvailable` | — | ✓ | Returns `true` if ASWebAuthenticationSession or SFAuthenticationSession is available. |
| `start` | — | ✓ | Starts the web authentication session. |

#### WebAuthenticationSession — Properties

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `callbackURLScheme` | — | ✓ | The custom URL scheme that the app expects in the callback URL. |
| `id` | — | ✓ | ID used internally. |
| `initialSettings` | — | ✓ | Initial settings. |
| `onComplete` | — | ✓ | A completion handler the session calls when it completes successfully, or when the user cancels the session. |
| `url` | — | ✓ | A URL with the `http` or `https` scheme pointing to the authentication webpage. |

#### WebAuthenticationSession — WebAuthenticationSessionSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `prefersEphemeralWebBrowserSession` | — | ✓ | A Boolean value that indicates whether the session should ask the browser for a private authentication session. |

</details>

<details>
<summary><b><code>CookieManager</code></b> — 16 APIs, 7 ★</summary>

#### CookieManager — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `deleteAllCookies` | ✓ | ✓ | Removes all cookies. |
| `deleteCookie` | ✓ | ✓ | Removes a cookie by its `name` for the given `url`, `domain` and `path`. |
| `deleteCookies` | ✓ | ✓ | Removes all cookies for the given `url`, `domain` and `path`. |
| `flush` | ✓ | — | Ensures all cookies currently accessible through the getCookie API are written to persistent storage. |
| `getAllCookies` | — | ✓ | Fetches all stored cookies. |
| `getCookie` | ✓ | ✓ | Gets a cookie by its `name` for the given `url`. |
| `getCookies` | ✓ | ✓ | Gets the cookies a request to `url` would send: those whose domain (or host, for a host-only cookie) and path match it, and Secure cookies only for an `https` `url`. |
| ★ `hasCookies` | ✓ | — | Returns whether the cookie store holds any cookie at all. |
| ★ `isAcceptCookieEnabled` | ✓ | 17.0+ | Returns whether the cookie store currently accepts cookies, as last set by `setAcceptCookie`. |
| ★ `isFileSchemeCookiesAllowed` | ✓ | — | Returns whether the WebView sends and accepts cookies for `file://` URLs. |
| `removeSessionCookies` | ✓ | — | Removes all session cookies, which are cookies without an expiration date. |
| ★ `setAcceptCookie` | ✓ | 17.0+ | Sets whether the cookie store accepts cookies at all. |
| `setCookie` | ✓ | ✓ | Sets a cookie for the given `url`. |
| ★ `setCookies` | ✓ | ✓ | Sets several cookies in one call. |
| ★ `setCookieStoreObserver` | — | ✓ | Registers an `observer` that is notified whenever the cookie store changes, or removes the current one when `observer` is `null`. |

#### CookieManager — CookieStoreObserver

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| ★ `onCookiesChanged` | — | ✓ | Notifies that the cookies in the store changed. |

</details>

<details>
<summary><b><code>WebStorageManager</code></b> — 10 APIs, 2 ★</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `deleteAllData` | ✓ | — | Clears every origin's IndexedDB, origin-private file system and `localStorage` data. |
| ★ `deleteBrowsingData` | ✓ · `DELETE_BROWSING_DATA` | — | Deletes all the data stored by websites. |
| ★ `deleteBrowsingDataForSite` | ✓ · `DELETE_BROWSING_DATA` | — | Deletes the data stored by websites for the given `site`. |
| `deleteOrigin` | ✓ | — | Clears the IndexedDB and origin-private file system data of the given `origin`, specified using its string representation (with or without a trailing `/`). |
| `fetchDataRecords` | — | ✓ | Fetches data records containing the given website data types. |
| `getOrigins` | ✓ | — | Gets the origins that hold quota-managed storage, each with its usage and quota. |
| `getQuotaForOrigin` | ✓ | — | Gets the storage quota for the given `origin`, in bytes. |
| `getUsageForOrigin` | ✓ | — | Gets the amount of storage the given `origin` currently uses, in bytes. |
| `removeDataFor` | — | ✓ | Removes website data of the given types for the given data records. |
| `removeDataModifiedSince` | — | ✓ | Removes all website data of the given types that has been modified since the given date. |

</details>

<details>
<summary><b><code>WebStorage</code></b> — 23 APIs</summary>

#### WebStorage — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `dispose` | ✓ | ✓ | Disposes the web storage. |

#### WebStorage — Properties

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `localStorage` | ✓ | ✓ | Represents `window.localStorage`. |
| `sessionStorage` | ✓ | ✓ | Represents `window.sessionStorage`. |

#### WebStorage — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `localStorage` | ✓ | ✓ | Represents `window.localStorage`. |
| `sessionStorage` | ✓ | ✓ | Represents `window.sessionStorage`. |

#### WebStorage — LocalStorage

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `clear` | ✓ | ✓ | Clears all keys stored in a given Storage object. |
| `dispose` | ✓ | ✓ | Disposes the web storage. |
| `getItem` | ✓ | ✓ | When passed a `key` name, will return that key's value, or `null` if the key does not exist, in the given Storage object. |
| `getItems` | ✓ | ✓ | Returns the list of all items from the given Storage object. |
| `key` | ✓ | ✓ | When passed a number `index`, returns the name of the nth key in a given Storage object. |
| `length` | ✓ | ✓ | Returns an integer representing the number of data items stored in the Storage object. |
| `removeItem` | ✓ | ✓ | When passed a `key` name, will remove that key from the given Storage object if it exists. |
| `setItem` | ✓ | ✓ | When passed a `key` name and `value`, will add that key to the storage, or update that key's value if it already exists. |

#### WebStorage — SessionStorage

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `clear` | ✓ | ✓ | Clears all keys stored in a given Storage object. |
| `dispose` | ✓ | ✓ | Disposes the web storage. |
| `getItem` | ✓ | ✓ | When passed a `key` name, will return that key's value, or `null` if the key does not exist, in the given Storage object. |
| `getItems` | ✓ | ✓ | Returns the list of all items from the given Storage object. |
| `key` | ✓ | ✓ | When passed a number `index`, returns the name of the nth key in a given Storage object. |
| `length` | ✓ | ✓ | Returns an integer representing the number of data items stored in the Storage object. |
| `removeItem` | ✓ | ✓ | When passed a `key` name, will remove that key from the given Storage object if it exists. |
| `setItem` | ✓ | ✓ | When passed a `key` name and `value`, will add that key to the storage, or update that key's value if it already exists. |

#### WebStorage — Storage parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `controller` | ✓ | ✓ | Controller used to interact with storage. |
| `webStorageType` | ✓ | ✓ | The web storage type: `window.sessionStorage` or `window.localStorage`. |

</details>

<details>
<summary><b><code>ProfileStore</code></b> — 8 APIs, 8 ★</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| ★ `addCustomHeader` | ✓ · `MULTI_PROFILE`, `CUSTOM_REQUEST_HEADERS` | — | Adds a `CustomHeader` sent on every request this profile makes to an origin matching the header's `originRules`. |
| ★ `clearAllCustomHeaders` | ✓ · `MULTI_PROFILE`, `CUSTOM_REQUEST_HEADERS` | — | Removes every custom header from this profile. |
| ★ `clearCustomHeader` | ✓ · `MULTI_PROFILE`, `CUSTOM_REQUEST_HEADERS` | — | Removes custom headers with the given `headerName` (case-insensitive). |
| ★ `deleteProfile` | ✓ · `MULTI_PROFILE` | — | Deletes the profile called `name` and the data it owns. |
| ★ `getAllProfileNames` | ✓ · `MULTI_PROFILE` | — | Returns the names of every profile that currently exists, including `defaultProfileName`. |
| ★ `getCustomHeaders` | ✓ · `MULTI_PROFILE`, `CUSTOM_REQUEST_HEADERS` | — | All custom headers set on this profile. |
| ★ `getOrCreateProfile` | ✓ · `MULTI_PROFILE` | — | Creates the profile called `name` if it does not exist yet, and returns its name. |
| ★ `hasCustomHeader` | ✓ · `MULTI_PROFILE`, `CUSTOM_REQUEST_HEADERS` | — | Whether this profile has any custom header with the given `headerName`, **case-insensitively**. |

</details>

<details>
<summary><b><code>GeolocationPermissions</code></b> — 5 APIs, 5 ★</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| ★ `allow` | ✓ | — | Stores a decision allowing `origin` to use the Geolocation API. |
| ★ `clear` | ✓ | — | Removes any stored decision for `origin`, so the next request from it prompts again. |
| ★ `clearAll` | ✓ | — | Removes every stored decision, so all origins prompt again. |
| ★ `getAllowed` | ✓ | — | Returns whether `origin` has a stored decision allowing the Geolocation API. |
| ★ `getOrigins` | ✓ | — | Returns the origins that have a stored decision allowing the Geolocation API. |

</details>

<details>
<summary><b><code>HttpAuthCredentialDatabase</code></b> — 6 APIs</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `clearAllAuthCredentials` | ✓ | ✓ | Removes all the HTTP auth credentials saved in the database. |
| `getAllAuthCredentials` | ✓ | ✓ | Gets a map list of all HTTP auth credentials saved. |
| `getHttpAuthCredentials` | ✓ | ✓ | Gets all the HTTP auth credentials saved for that `protectionSpace`. |
| `removeHttpAuthCredential` | ✓ | ✓ | Removes an HTTP auth `credential` for that `protectionSpace`. |
| `removeHttpAuthCredentials` | ✓ | ✓ | Removes all the HTTP auth credentials saved for that `protectionSpace`. |
| `setHttpAuthCredential` | ✓ | ✓ | Saves an HTTP auth `credential` for that `protectionSpace`. |

</details>

<details>
<summary><b><code>ServiceWorkerController</code></b> — 12 APIs, 2 ★</summary>

#### ServiceWorkerController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `getAllowContentAccess` | ✓ | — | Gets whether Service Workers support content URL access. |
| `getAllowFileAccess` | ✓ | — | Gets whether Service Workers support file access. |
| `getBlockNetworkLoads` | ✓ | — | Gets whether Service Workers are prohibited from loading any resources from the network. |
| `getCacheMode` | ✓ | — | Gets the current setting for overriding the cache mode. |
| ★ `getIncludeCookiesOnShouldInterceptRequestEnabled` | ✓ · `COOKIE_INTERCEPT` | — | Gets whether requests intercepted for a Service Worker carry the `Cookie` header, and whether `cookies` on the response is honoured. |
| `setAllowContentAccess` | ✓ | — | Enables or disables content URL access from Service Workers. |
| `setAllowFileAccess` | ✓ | — | Enables or disables file access within Service Workers. |
| `setBlockNetworkLoads` | ✓ | — | Sets whether Service Workers should not load resources from the network. |
| `setCacheMode` | ✓ | — | Overrides the way the cache is used. |
| ★ `setIncludeCookiesOnShouldInterceptRequestEnabled` | ✓ · `COOKIE_INTERCEPT` | — | Enables or disables cookie access for requests intercepted on behalf of a Service Worker. |
| `setServiceWorkerClient` | ✓ | — | Sets the client to capture service worker related callbacks. |

#### ServiceWorkerController — ServiceWorkerClient

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `shouldInterceptRequest` | ✓ | — | Notify the host application of a resource request and allow the application to return the data. |

</details>

<details>
<summary><b><code>ProxyController</code></b> — 8 APIs</summary>

#### ProxyController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `clearProxyOverride` | ✓ | 17.0+ | Clears the proxy settings. |
| `setProxyOverride` | ✓ | 17.0+ | Sets `ProxySettings` which will be used by all `WebView`s in the app. |

#### ProxyController — ProxySettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `bypassRules` | ✓ | — | List of bypass rules. |
| `bypassSimpleHostnames` | ✓ | — | Hostnames without a period in them (and that are not IP literals) will skip proxy settings and be connected to directly instead. |
| `directs` | ✓ | — | List of scheme filters. |
| `proxyRules` | ✓ | ✓ | List of proxy rules to be used for all URLs. |
| `removeImplicitRules` | ✓ | — | By default, certain hostnames implicitly bypass the proxy if they are link-local IPs, or localhost addresses. |
| `reverseBypassEnabled` | ✓ | — | Reverse the bypass list. |

</details>

<details>
<summary><b><code>TracingController</code></b> — 4 APIs</summary>

#### TracingController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `isTracing` | ✓ | — | Returns whether the WebView framework is tracing. |
| `start` | ✓ | — | Starts tracing all `WebView`s. |
| `stop` | ✓ | — | Stops tracing and flushes tracing data to the specified output stream. |

#### TracingController — TracingSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `tracingMode` | ✓ | — | The tracing mode for this configuration. |

</details>

<details>
<summary><b><code>ProcessGlobalConfig</code></b> — 3 APIs</summary>

#### ProcessGlobalConfig — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `apply` | ✓ | — | Applies the configuration to be used by `WebView` on loading. |

#### ProcessGlobalConfig — ProcessGlobalConfigSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `dataDirectorySuffix` | ✓ · `STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX` | — | The directory name suffix to be used for the current process. |
| `directoryBasePaths` | ✓ · `STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS` | — | Set the base directories that `WebView` will use for the current process. |

</details>

<details>
<summary><b><code>WebViewFeature</code></b> — 2 APIs</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `isFeatureSupported` | ✓ | — | Return whether a feature is supported at run-time. |
| `isStartupFeatureSupported` | ✓ | — | Return whether a startup feature is supported at run-time. |

</details>

<details>
<summary><b><code>FindInteractionController</code></b> — 12 APIs</summary>

#### FindInteractionController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `clearMatches` | ✓ | ✓ | Clears the highlighting surrounding text matches created by `findAll`. |
| `dismissFindNavigator` | — | ✓ | Dismisses the find panel, if present. |
| `dispose` | ✓ | ✓ | Disposes the controller. |
| `findAll` | ✓ | ✓ | Finds all instances of find on the page and highlights them. |
| `findNext` | ✓ | ✓ | Highlights and scrolls to the next match found by `findAll`. |
| `getActiveFindSession` | ✓ | ✓ | If there's a currently active find session, returns the active find session. |
| `getSearchText` | ✓ | ✓ | Get the search text used. |
| `isFindNavigatorVisible` | — | ✓ | A Boolean value that indicates when the find panel displays onscreen. |
| `presentFindNavigator` | — | ✓ | Begins a search, displaying the find panel. |
| `setSearchText` | ✓ | ✓ | Pre-populate the search text to be used. |
| `updateResultCount` | — | ✓ | Updates the results the interface displays for the active search. |

#### FindInteractionController — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `onFindResultReceived` | ✓ | ✓ | Event fired as find-on-page operations progress. |

</details>

<details>
<summary><b><code>PullToRefreshController</code></b> — 22 APIs</summary>

#### PullToRefreshController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `beginRefreshing` | ✓ | ✓ | Tells the controller that a refresh operation was started programmatically. |
| `dispose` | ✓ | ✓ | Disposes the controller. |
| `endRefreshing` | ✓ | ✓ | Tells the controller that a refresh operation has ended. |
| `getDefaultSlingshotDistance` | ✓ | — | Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture. |
| `isEnabled` | ✓ | ✓ | Returns `true` is pull-to-refresh feature is enabled, otherwise `false`. |
| `isRefreshing` | ✓ | ✓ | Returns whether a refresh operation has been triggered and is in progress. |
| `setBackgroundColor` | ✓ | ✓ | Sets the background color of the refresh control. |
| `setColor` | ✓ | ✓ | Sets the color of the refresh control. |
| `setDistanceToTriggerSync` | ✓ | — | Set the distance to trigger a sync in dips. |
| `setEnabled` | ✓ | ✓ | Sets whether the pull-to-refresh feature is enabled or not. |
| `setIndicatorSize` | ✓ | — | Sets the size of the refresh indicator. |
| `setSlingshotDistance` | ✓ | — | Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture. |
| `setStyledTitle` | — | ✓ | Sets the styled title text to display in the refresh control. |

#### PullToRefreshController — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `onRefresh` | ✓ | ✓ | Event called when a swipe gesture triggers a refresh. |
| `settings` | ✓ | ✓ | Initial settings. |

#### PullToRefreshController — PullToRefreshSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `attributedTitle` | — | ✓ | The title text to display in the refresh control. |
| `backgroundColor` | ✓ | ✓ | The background color of the refresh control. |
| `color` | ✓ | ✓ | The color of the refresh control. |
| `distanceToTriggerSync` | ✓ | — | The distance to trigger a sync in dips. |
| `enabled` | ✓ | ✓ | Sets whether the pull-to-refresh feature is enabled or not. |
| `size` | ✓ | — | The size of the refresh indicator. |
| `slingshotDistance` | ✓ | — | The distance in pixels that the refresh indicator can be pulled beyond its resting position. |

</details>

<details>
<summary><b><code>PrintJobController</code></b> — 26 APIs</summary>

#### PrintJobController — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `cancel` | ✓ | — | Cancels this print job. |
| `dismiss` | — | ✓ | Dismisses the printing-options sheet or popover. |
| `dispose` | ✓ | ✓ | Disposes the print job. |
| `getInfo` | ✓ | ✓ | Gets the `PrintJobInfo` that describes this job. |
| `restart` | ✓ | — | Restarts this print job. |

#### PrintJobController — Properties

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `onComplete` | ✓ | ✓ | A completion handler used to handle the conclusion of the print job (for instance, to reset state) and to handle any errors encountered in printing. |

#### PrintJobController — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `id` | ✓ | ✓ | Print job ID. |

#### PrintJobController — PrintJobSettings

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `animated` | — | ✓ | `true` to animate the display of the sheet, `false` to display the sheet immediately. |
| `colorMode` | ✓ | — | The color mode. |
| `duplexMode` | ✓ | ✓ | The duplex mode to use for the print job. |
| `footerHeight` | — | ✓ | The height of the page footer. |
| `forceRenderingQuality` | — | ✓ | Force rendering quality. |
| `handledByClient` | ✓ | ✓ | Set this to `true` to handle the `PlatformPrintJobController`. |
| `headerHeight` | — | ✓ | The height of the page header. |
| `jobName` | ✓ | ✓ | The name of the print job. |
| `margins` | — | ✓ | The margins for each printed page. |
| `maximumContentHeight` | — | ✓ | The maximum height of the content area. |
| `maximumContentWidth` | — | ✓ | The maximum width of the content area. |
| `mediaSize` | ✓ | — | The media size. |
| `numberOfPages` | — | ✓ | The number of pages to render. |
| `orientation` | ✓ | ✓ | The orientation of the printed content, portrait or landscape. |
| `outputType` | — | ✓ | The kind of printable content. |
| `resolution` | ✓ | — | The supported resolution in DPI (dots per inch). |
| `showsNumberOfCopies` | — | ✓ | A Boolean value that determines whether the printing options include the number of copies. |
| `showsPaperOrientation` | — | ✓ | A Boolean value that determines whether the printing options include the paper orientation control when available. |
| `showsPaperSelectionForLoadedPapers` | — | ✓ | A Boolean value that determines whether the paper selection menu displays. |

</details>

<details>
<summary><b><code>WebMessageChannel</code></b> — 4 APIs</summary>

#### WebMessageChannel — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `dispose` | ✓ | ✓ | Disposes the web message channel. |

#### WebMessageChannel — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `id` | ✓ | ✓ | Message Channel ID used internally. |
| `port1` | ✓ | ✓ | The first `PlatformWebMessagePort` object of the channel. |
| `port2` | ✓ | ✓ | The second `PlatformWebMessagePort` object of the channel. |

</details>

<details>
<summary><b><code>WebMessageListener</code></b> — 5 APIs, 1 ★</summary>

#### WebMessageListener — Methods

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `dispose` | ✓ | ✓ | Disposes the channel. |

#### WebMessageListener — Parameters

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `allowedOriginRules` | ✓ | ✓ | A set of matching rules for the allowed origins. |
| ★ `contentWorld` | — | ✓ | The scope of execution the injected JavaScript object is created in. |
| `jsObjectName` | ✓ | ✓ | The name for the injected JavaScript object. |
| `onPostMessage` | ✓ | ✓ | Event that receives a message sent by a `postMessage()` on the injected JavaScript object. |

</details>

<details>
<summary><b><code>InAppLocalhostServer</code></b> — 3 APIs</summary>

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| `close` | ✓ | ✓ | Closes the server. |
| `isRunning` | ✓ | ✓ | Indicates if the server is running or not. |
| `start` | ✓ | ✓ | Starts the server on `http://localhost:`port`/`. |

</details>

<!-- api-reference:end -->

### Added by this fork, outside the tables above

| API | Android | iOS | Description |
| --- | --- | --- | --- |
| ★ `saveState()`: `maxSize` / `includeForwardState` arguments | ✓ | — | Bound the saved state. `saveState()` has always been unbounded (measured at 2.0 MB for a 9-entry history); `includeForwardState: false` drops entries only reachable by going forward. Returns `null`, not a smaller state, if `maxSize` is too small for even the current page |
| ★ `PathHandler.dispose()` | ✓ | — | Releases a `WebViewAssetLoader` path handler once no WebView's settings use it. Safe to repeat; a disposed handler can't be reused |
| ★ `ProxyRule.relayHop1` / `.relayHop2` | — | 17.0+ | Route a proxy rule through a chain of secure relays (RFC 9298) instead of a direct proxy endpoint |
| ★ `NavigationAction.modifierFlags` / `.buttonNumber` | — | ✓ | Which modifier keys and mouse button triggered a navigation |
| ★ `NavigationAction.isContentRuleListRedirect` | — | 26.0+ | Whether a content rule list redirected this navigation |
| ★ `DownloadStartRequest.isUserInitiated` / `.originatingFrame` | — | ✓ | Whether the user started the download, and which frame it came from |
| ★ `WebViewPage` (type) | ✓ | — | The payload of the page and Web Vitals events: a synthesised `id` matching `WebViewNavigation.pageId`, plus the page's `url` |
| ★ `WebViewNavigation` (type) | ✓ | — | The payload of the three `onNavigation*` events: `statusCode`, `isBack` / `isForward` / `isReload` / `isRestore` / `isSameDocument`, `didCommit`, and an `id` tying the three events together |
| ★ `WebsiteDataType.WKWebsiteDataTypeScreenTime` | — | 26.0+ | Screen Time data. Deliberately not part of `WebsiteDataType.ALL`: passing it to a bulk delete terminates the app |
| ★ `CustomHeader` (type) | ✓ | — | The name / value / `originRules` triple `ProfileStore.addCustomHeader()` takes. A header whose rules match nothing is silently never sent |
| ★ `WebResourceResponse.cookies` | ✓ | — | `Set-Cookie` values applied as if the intercepted response had carried them. Silently ignored unless `includeCookiesOnShouldInterceptRequest` is on |
| ★ `CookieToSet` (type) | ✓ | ✓ | The input to `CookieManager.setCookies()`: a cookie being written, with its own `url` and `maxAge` |

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
