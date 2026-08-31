import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../find_interaction/platform_find_interaction_controller.dart';
import '../pull_to_refresh/platform_pull_to_refresh_controller.dart';
import '../context_menu/context_menu.dart';
import '../types/main.dart';
import '../web_uri.dart';
import 'in_app_webview_settings.dart';
import 'platform_inappwebview_controller.dart';
import '../print_job/main.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_headless_in_app_webview.dart';
import '../platform_webview_feature.dart';
import '../in_app_browser/platform_in_app_browser.dart';

part 'platform_webview.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
///Class that represents a WebView. Used by [PlatformInAppWebViewWidget],
///[PlatformHeadlessInAppWebView] and the WebView of [PlatformInAppBrowser].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
@SupportedPlatforms(
  ignoreParameterNames: ['controller'],
  platforms: [AndroidPlatform(), IOSPlatform()],
)
class PlatformWebViewCreationParams<T> {
  final T Function(PlatformInAppWebViewController controller)?
  controllerFromPlatform;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///The window id of a [CreateWindowAction.windowId].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final int? windowId;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebViewCreated}
  ///Event fired when the `WebView` is created.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebViewCreated.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final void Function(T controller)? onWebViewCreated;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart}
  ///Event fired when the `WebView` starts to load an [url].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStart.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageStarted',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageStarted(android.webkit.WebView,%20java.lang.String,%20android.graphics.Bitmap)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455621-webview',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onLoadStart;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop}
  ///Event fired when the `WebView` finishes loading an [url].
  ///
  ///**Do not treat this as guaranteed after every navigation.** A page can cancel its own
  ///navigation — single-page apps that intercept history changes are the common case — and the
  ///load then ends in [PlatformWebViewCreationParams.onReceivedError] with
  ///[WebResourceErrorType.CANCELLED] instead. On iOS that is `NSURLErrorCancelled` (-999) and
  ///WebKit never calls `didFinishNavigation`, so **no `onLoadStop` arrives at all**.
  ///
  ///This is most visible after [PlatformInAppWebViewController.goBack] /
  ///[PlatformInAppWebViewController.goForward]: the back-forward list still moves correctly
  ///(`currentIndex`, `canGoBack`, `canGoForward` and [PlatformInAppWebViewController.getUrl] are
  ///all right), but awaiting `onLoadStop` to know the navigation landed will wait forever on such
  ///a page. Await [PlatformWebViewCreationParams.onUpdateVisitedHistory] instead, which fires in
  ///both cases, or handle `CANCELLED` in `onReceivedError`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadStop.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageFinished',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageFinished(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onLoadStop;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError}
  ///Event fired when the `WebView` encounters an [error] loading a [request].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceError)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455623-webview',
      ),
    ],
  )
  final void Function(
    T controller,
    WebResourceRequest request,
    WebResourceError error,
  )?
  onReceivedError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError}
  ///Event fired when the `WebView` receives an HTTP error.
  ///
  ///[request] represents the originating request.
  ///
  ///[errorResponse] represents the information about the error occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpError.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpError(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20android.webkit.WebResourceResponse)',
        available: '23',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
    ],
  )
  final void Function(
    T controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  )?
  onReceivedHttpError;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged}
  ///Event fired when the current [progress] of loading a page is changed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onProgressChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onProgressChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onProgressChanged(android.webkit.WebView,%20int)',
      ),
      IOSPlatform(),
    ],
  )
  final void Function(T controller, int progress)? onProgressChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage}
  ///Event fired when the `WebView` receives a [ConsoleMessage].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onConsoleMessage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onConsoleMessage',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onConsoleMessage(android.webkit.ConsoleMessage)',
      ),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, ConsoleMessage consoleMessage)?
  onConsoleMessage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading}
  ///Give the host application a chance to take control when a URL is about to be loaded in the current WebView.
  ///
  ///[navigationAction] represents an object that contains information about an action that causes navigation to occur.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useShouldOverrideUrlLoading] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldOverrideUrlLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.shouldOverrideUrlLoading',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)',
        note:
            """There isn't any way to load an URL for a frame that is not the main frame, so if the request is not for the main frame, the navigation is allowed by default.
However, if you want to cancel requests for subframes, you can use the [InAppWebViewSettings.regexToCancelSubFramesLoading] setting
to write a Regular Expression that, if the url request of a subframe matches, then the request of that subframe is canceled.
Instead, the [InAppWebViewSettings.regexToAllowSyncUrlLoading] setting could
be used to allow navigation requests synchronously, as this event is synchronous on native side
and the current plugin implementation will always cancel the current request and load a new request if
this event returns [NavigationActionPolicy.ALLOW] because Flutter method channels work only asynchronously.
Also, this event is not called for POST requests and is not called on the first page load.""",
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455641-webview',
      ),
    ],
  )
  final FutureOr<NavigationActionPolicy?> Function(
    T controller,
    NavigationAction navigationAction,
  )?
  shouldOverrideUrlLoading;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource}
  ///Event fired when the `WebView` loads a resource.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnLoadResource] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResource.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This event is implemented using JavaScript.'),
      IOSPlatform(note: 'This event is implemented using JavaScript.'),
    ],
  )
  final void Function(T controller, LoadedResource resource)? onLoadResource;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged}
  ///Event fired when the `WebView` scrolls.
  ///
  ///[x] represents the current horizontal scroll origin in pixels.
  ///
  ///[y] represents the current vertical scroll origin in pixels.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onScrollChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onScrollChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onScrollChanged(int,%20int,%20int,%20int)',
      ),
      IOSPlatform(
        apiName: 'UIScrollViewDelegate.scrollViewDidScroll',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll',
      ),
    ],
  )
  final void Function(T controller, int x, int y)? onScrollChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting}
  ///Event fired when `WebView` recognizes a downloadable file.
  ///To download the file, you can use the [flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin.
  ///
  ///[downloadStartRequest] represents the request of the file to download.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnDownloadStart] setting documentation.
  ///
  ///**This event is a notification, not a hook. It cannot start, alter or veto a download, and
  ///nothing in the plugin will download the file for you** — that is by design on both platforms
  ///and is not going to change:
  ///
  ///- **Android** never downloads it in the first place. `WebView.setDownloadListener` exists
  ///  precisely because the WebView hands the URL to the app and stops there.
  ///- **iOS actively cancels it.** When a navigation response becomes a `WKDownload`, the plugin
  ///  drops the download's delegate, which leaves it with no destination and WebKit tears it down.
  ///  **The cancellation is unconditional** — it happens whether or not
  ///  [InAppWebViewSettings.useOnDownloadStart] is `true`. With that setting `false` (its default
  ///  unless this event is implemented) the download is therefore cancelled *silently*: no event,
  ///  no error, and a link that simply appears to do nothing.
  ///
  ///Because iOS never lets the `WKDownload` proceed, there is **no native progress, completion or
  ///failure reporting to expose**, and none is planned. Downloading is the app's job: take
  ///`downloadStartRequest.url` and fetch it yourself, for example with the
  ///[flutter_downloader](https://pub.dev/packages/flutter_downloader) plugin. Remember to carry
  ///over whatever the WebView had — cookies (via `CookieManager`), the `User-Agent`, and any auth
  ///headers — since your download is a separate request that shares none of the WebView's state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDownloadStarting.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.setDownloadListener',
        apiUrl:
            '(https://developer.android.com/reference/android/webkit/WebView#setDownloadListener(android.webkit.DownloadListener)',
      ),
      IOSPlatform(),
    ],
  )
  final FutureOr<void> Function(
    T controller,
    DownloadStartRequest downloadStartRequest,
  )?
  onDownloadStarting;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme}
  ///Event fired when the `WebView` finds the `custom-scheme` while loading a resource.
  ///Here you can handle the url [request] and return a [CustomSchemeResponse] to load a specific resource encoded to `base64`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLoadResourceWithCustomScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'WKURLSchemeHandler',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkurlschemehandler',
      ),
    ],
  )
  final FutureOr<CustomSchemeResponse?> Function(
    T controller,
    WebResourceRequest request,
  )?
  onLoadResourceWithCustomScheme;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCreateWindow}
  ///Event fired when the `WebView` requests the host application to create a new window,
  ///for example when trying to open a link with `target="_blank"` or when `window.open()` is called by JavaScript side.
  ///If the host application chooses to honor this request, it should return `true` from this method, create a new WebView to host the window.
  ///If the host application chooses not to honor the request, it should return `false` from this method.
  ///The default implementation of this method does nothing and hence returns `false`.
  ///
  ///- [createWindowAction] represents the request.
  ///
  ///**NOTE**: to allow JavaScript to open windows, you need to set [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically] setting to `true`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCreateWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onCreateWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCreateWindow(android.webkit.WebView,%20boolean,%20boolean,%20android.os.Message)',
        note:
            'You need to set [InAppWebViewSettings.supportMultipleWindows] setting to `true`. Also, if the request has been created using JavaScript (`window.open()`), then there are some limitation: check the [NavigationAction] class.',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview',
        note:
            """Setting these initial settings [InAppWebViewSettings.supportZoom], [InAppWebViewSettings.useOnLoadResource], [InAppWebViewSettings.useShouldInterceptAjaxRequest],
[InAppWebViewSettings.useShouldInterceptFetchRequest], [InAppWebViewSettings.applicationNameForUserAgent], [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically],
[InAppWebViewSettings.javaScriptEnabled], [InAppWebViewSettings.minimumFontSize], [InAppWebViewSettings.preferredContentMode], [InAppWebViewSettings.incognito],
[InAppWebViewSettings.cacheEnabled], [InAppWebViewSettings.mediaPlaybackRequiresUserGesture],
[InAppWebViewSettings.resourceCustomSchemes], [InAppWebViewSettings.sharedCookiesEnabled],
[InAppWebViewSettings.enableViewportScale], [InAppWebViewSettings.allowsAirPlayForMediaPlayback],
[InAppWebViewSettings.allowsPictureInPictureMediaPlayback], [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled],
[InAppWebViewSettings.allowsInlineMediaPlayback], [InAppWebViewSettings.suppressesIncrementalRendering], [InAppWebViewSettings.selectionGranularity],
[InAppWebViewSettings.ignoresViewportScaleLimits], [InAppWebViewSettings.limitsNavigationsToAppBoundDomains],
[InAppWebViewSettings.upgradeKnownHostsToHTTPS],
will have no effect due to a `WKWebView` limitation when creating the new window WebView: it's impossible to return the new `WKWebView`
with a different `WKWebViewConfiguration` instance (see https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview).
So, these options will be inherited from the caller WebView.
Also, note that calling [InAppWebViewController.setSettings] method using the controller of the new created WebView,
it will update also the WebView options of the caller WebView.""",
      ),
    ],
  )
  final FutureOr<bool?> Function(
    T controller,
    CreateWindowAction createWindowAction,
  )?
  onCreateWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow}
  ///Event fired when the host application should close the given WebView and remove it from the view system if necessary.
  ///At this point, WebCore has stopped any loading in this window and has removed any cross-scripting ability in javascript.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCloseWindow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onCloseWindow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onCloseWindow(android.webkit.WebView)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webViewDidClose',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537390-webviewdidclose',
      ),
    ],
  )
  final void Function(T controller)? onCloseWindow;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus}
  ///Event fired when the JavaScript `window` object of the WebView has received focus.
  ///This is the result of the `focus` JavaScript event applied to the `window` object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowFocus.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final void Function(T controller)? onWindowFocus;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur}
  ///Event fired when the JavaScript `window` object of the WebView has lost focus.
  ///This is the result of the `blur` JavaScript event applied to the `window` object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWindowBlur.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final void Function(T controller)? onWindowBlur;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert}
  ///Event fired when javascript calls the `alert()` method to display an alert dialog.
  ///If [JsAlertResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsAlertRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsAlert.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsAlert',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsAlert(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1537406-webview',
      ),
    ],
  )
  final FutureOr<JsAlertResponse?> Function(
    T controller,
    JsAlertRequest jsAlertRequest,
  )?
  onJsAlert;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm}
  ///Event fired when javascript calls the `confirm()` method to display a confirm dialog.
  ///If [JsConfirmResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsConfirmRequest] contains the message to be displayed in the confirm dialog and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsConfirm.onJsConfirm}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsConfirm',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsConfirm(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1536489-webview',
      ),
    ],
  )
  final FutureOr<JsConfirmResponse?> Function(
    T controller,
    JsConfirmRequest jsConfirmRequest,
  )?
  onJsConfirm;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt}
  ///Event fired when javascript calls the `prompt()` method to display a prompt dialog.
  ///If [JsPromptResponse.handledByClient] is `true`, the webview will assume that the client will handle the dialog.
  ///
  ///[jsPromptRequest] contains the message to be displayed in the prompt dialog, the default value displayed in the prompt dialog, and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsPrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsPrompt(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20android.webkit.JsPromptResult)',
      ),
      IOSPlatform(
        apiName: 'WKUIDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/1538086-webview',
      ),
    ],
  )
  final FutureOr<JsPromptResponse?> Function(
    T controller,
    JsPromptRequest jsPromptRequest,
  )?
  onJsPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest}
  ///Event fired when the WebView received an HTTP authentication request. The default behavior is to cancel the request.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [URLAuthenticationChallenge].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedHttpAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedHttpAuthRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedHttpAuthRequest(android.webkit.WebView,%20android.webkit.HttpAuthHandler,%20java.lang.String,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
    ],
  )
  final FutureOr<HttpAuthResponse?> Function(
    T controller,
    HttpAuthenticationChallenge challenge,
  )?
  onReceivedHttpAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest}
  ///Event fired when the WebView need to perform server trust authentication (certificate validation).
  ///The host application must return either [ServerTrustAuthResponse] instance with [ServerTrustAuthResponseAction.CANCEL] or [ServerTrustAuthResponseAction.PROCEED].
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ServerTrustChallenge].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedSslError',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedSslError(android.webkit.WebView,%20android.webkit.SslErrorHandler,%20android.net.http.SslError)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
        note:
            """To override the certificate verification logic, you have to provide ATS (App Transport Security) exceptions in your iOS/macOS `Info.plist`.
See `NSAppTransportSecurity` in the [Information Property List Key Reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW1) for details.""",
      ),
    ],
  )
  final FutureOr<ServerTrustAuthResponse?> Function(
    T controller,
    ServerTrustChallenge challenge,
  )?
  onReceivedServerTrustAuthRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest}
  ///Notify the host application to handle an SSL client certificate request.
  ///Webview stores the response in memory (for the life of the application) if [ClientCertResponseAction.PROCEED] or [ClientCertResponseAction.CANCEL]
  ///is called and does not call [onReceivedClientCertRequest] again for the same host and port pair.
  ///Note that, multiple layers in chromium network stack might be caching the responses.
  ///
  ///[challenge] contains data about host, port, protocol, realm, etc. as specified in the [ClientCertChallenge].
  ///
  ///**Returning [ClientCertResponseAction.PROCEED] does not guarantee a certificate is sent.** If
  ///the plugin cannot load the PKCS#12 file named by [ClientCertResponse.certificatePath], iOS
  ///falls back to `performDefaultHandling` — the navigation continues **without** a client
  ///certificate, and the server sees an unauthenticated request. Nothing is reported to Dart: there
  ///is no error callback, no exception and no change in the event's return value. The usual symptom
  ///is a `401`/`403` arriving at [onReceivedHttpError] instead of the page you expected.
  ///
  ///A missing file and an unreadable file take the same branch, so from Dart the two are
  ///indistinguishable.
  ///
  ///**On iOS 17.x this bites a correct, correctly-passworded certificate.** Apple's
  ///`SecPKCS12Import` on that release cannot read a container encrypted with
  ///`PBES2 / PBKDF2 / AES-256-CBC`, which is **OpenSSL 3's default output** — so a `.p12`/`.pfx`
  ///produced by a modern `openssl pkcs12 -export` is silently rejected. It reports
  ///`errSecAuthFailed` (`-25293`), whose message is *"The user name or passphrase you entered is
  ///not correct."* **That message is a lie in this case**; the passphrase is fine and the container
  ///is simply unparseable. The same file works on iOS 26. Inspect a container with:
  ///
  ///```
  ///openssl pkcs12 -info -nokeys -noout -in cert.pfx
  ///```
  ///
  ///If it reports `PBES2, PBKDF2, AES-256-CBC`, re-export it with `-legacy` (OpenSSL 3) for iOS
  ///17.x compatibility — at the cost of the weaker RC2/3DES encryption that flag selects. Weigh
  ///that against dropping iOS 17.x support; the plugin cannot work around it.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedClientCertRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedClientCertRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedClientCertRequest(android.webkit.WebView,%20android.webkit.ClientCertRequest)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455638-webview',
      ),
    ],
  )
  final FutureOr<ClientCertResponse?> Function(
    T controller,
    ClientCertChallenge challenge,
  )?
  onReceivedClientCertRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptAjaxRequest}
  ///Event fired when an `XMLHttpRequest` is sent to a server.
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation, it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the `XMLHttpRequest`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptAjaxRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
    ],
  )
  final FutureOr<AjaxRequest?> Function(T controller, AjaxRequest ajaxRequest)?
  shouldInterceptAjaxRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxReadyStateChange}
  ///Event fired whenever the `readyState` attribute of an `XMLHttpRequest` changes.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///Due to the async nature of this event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxReadyStateChange.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxReadyStateChange] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
    ],
  )
  final FutureOr<AjaxRequestAction?> Function(
    T controller,
    AjaxRequest ajaxRequest,
  )?
  onAjaxReadyStateChange;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress}
  ///Event fired as an `XMLHttpRequest` progress.
  ///It gives the host application a chance to abort the request.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[ajaxRequest] represents the [XMLHttpRequest].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onAjaxProgress.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptAjaxRequest] and [InAppWebViewSettings.useOnAjaxProgress] settings documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
    ],
  )
  final FutureOr<AjaxRequestAction?> Function(
    T controller,
    AjaxRequest ajaxRequest,
  )?
  onAjaxProgress;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest}
  ///Event fired when a request is sent to a server through [Fetch API](https://developer.mozilla.org/it/docs/Web/API/Fetch_API).
  ///It gives the host application a chance to take control over the request before sending it.
  ///This event is implemented using JavaScript under the hood.
  ///
  ///[fetchRequest] represents a resource request.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptFetchRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptFetchRequest] setting documentation.
Also, on Android that doesn't support the [WebViewFeature.DOCUMENT_START_SCRIPT], unlike iOS that has [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript) that
can inject javascript code right after the document element is created but before any other content is loaded, in Android the javascript code
used to intercept ajax requests is loaded as soon as possible so it won't be instantaneous as iOS.
In that case, after the `window.addEventListener("flutterInAppWebViewPlatformReady")` event is dispatched, the ajax requests can be intercept for sure.""",
      ),
      IOSPlatform(),
    ],
  )
  final FutureOr<FetchRequest?> Function(
    T controller,
    FetchRequest fetchRequest,
  )?
  shouldInterceptFetchRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory}
  ///Event fired when the host application updates its visited links database.
  ///This event is also fired when the navigation state of the `WebView` changes through the usage of
  ///javascript **[History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)** functions (`pushState()`, `replaceState()`) and `onpopstate` event
  ///or, also, when the javascript `window.location` changes without reloading the webview (for example appending or modifying a hash to the url).
  ///
  ///[url] represents the url being visited.
  ///
  ///[isReload] indicates if this url is being reloaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onUpdateVisitedHistory.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.doUpdateVisitedHistory',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#doUpdateVisitedHistory(android.webkit.WebView,%20java.lang.String,%20boolean)',
      ),
      IOSPlatform(),
    ],
    parameterPlatforms: {
      'isReload': [AndroidPlatform()],
    },
  )
  final void Function(T controller, WebUri? url, bool? isReload)?
  onUpdateVisitedHistory;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrintRequest}
  ///Event fired when `window.print()` is called from JavaScript side.
  ///
  ///Return `true` to handle printing yourself: **the OS print UI is not shown at all**. Return
  ///`false` (or `null`, or register no handler) to let the plugin print the page, which raises the
  ///platform's print dialog.
  ///
  ///[url] represents the url on which is called.
  ///
  ///**This event is asked before the print job exists.** That is what makes `true` able to suppress
  ///the dialog: once the job has been created the OS UI is up and nothing in this plugin can take it
  ///down again — on Android `PrintJob.cancel()` is a no-op while the job is in `CREATED` state,
  ///which is exactly the state it is in while the dialog is open.
  ///
  ///Because no job exists yet, there is no [PlatformPrintJobController] to hand over. If you want
  ///one, return `true` here and start the job yourself:
  ///
  ///```dart
  ///onPrintRequest: (controller, url) async {
  ///  final printJob = await controller.printCurrentPage(
  ///    settings: PrintJobSettings(handledByClient: true),
  ///  );
  ///  // ... use printJob, and call printJob.dispose() when done
  ///  return true;
  ///}
  ///```
  ///
  ///Note that [PlatformInAppWebViewController.printCurrentPage] always raises the print dialog — it
  ///is an explicit request to print. This event is the only place where printing can be declined.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPrintRequest.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final FutureOr<bool?> Function(T controller, WebUri? url)? onPrintRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult}
  ///Event fired when an HTML element of the webview has been clicked and held.
  ///
  ///[hitTestResult] represents the hit result for hitting an HTML elements.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onLongPressHitTestResult.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.setOnLongClickListener',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#setOnLongClickListener(android.view.View.OnLongClickListener)',
      ),
      IOSPlatform(
        apiName: 'UILongPressGestureRecognizer',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uilongpressgesturerecognizer',
      ),
    ],
  )
  final void Function(T controller, InAppWebViewHitTestResult hitTestResult)?
  onLongPressHitTestResult;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen}
  ///Event fired when the current page has entered full screen mode.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onEnterFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onShowCustomView',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowCustomView(android.view.View,%20android.webkit.WebChromeClient.CustomViewCallback)',
      ),
      IOSPlatform(
        apiName: 'UIWindow.didBecomeVisibleNotification',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiwindow/1621621-didbecomevisiblenotification',
      ),
    ],
  )
  final void Function(T controller)? onEnterFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen}
  ///Event fired when the current page has exited full screen mode.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onExitFullscreen.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onHideCustomView',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onHideCustomView()',
      ),
      IOSPlatform(
        apiName: 'UIWindow.didBecomeHiddenNotification',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiwindow/1621617-didbecomehiddennotification',
      ),
    ],
  )
  final void Function(T controller)? onExitFullscreen;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible}
  ///Called when the web view begins to receive web content.
  ///
  ///This event occurs early in the document loading process, and as such
  ///you should expect that linked resources (for example, CSS and images) may not be available.
  ///
  ///[url] represents the URL corresponding to the page navigation that triggered this callback.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPageCommitVisible.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onPageCommitVisible',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onPageCommitVisible(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455635-webview',
      ),
    ],
  )
  final void Function(T controller, WebUri? url)? onPageCommitVisible;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged}
  ///Event fired when a change in the document title occurred.
  ///
  ///[title] represents the string containing the new title of the document.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onTitleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedTitle',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTitle(android.webkit.WebView,%20java.lang.String)',
      ),
      IOSPlatform(),
    ],
  )
  final void Function(T controller, String? title)? onTitleChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onOverScrolled}
  ///Event fired to respond to the results of an over-scroll operation.
  ///
  ///[x] represents the new X scroll value in pixels.
  ///
  ///[y] represents the new Y scroll value in pixels.
  ///
  ///[clampedX] is `true` if [x] was clamped to an over-scroll boundary.
  ///
  ///[clampedY] is `true` if [y] was clamped to an over-scroll boundary.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onOverScrolled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onOverScrolled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onOverScrolled(int,%20int,%20boolean,%20boolean)',
      ),
      IOSPlatform(),
    ],
  )
  final void Function(T controller, int x, int y, bool clampedX, bool clampedY)?
  onOverScrolled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged}
  ///Event fired when the zoom scale of the WebView has changed.
  ///
  ///[oldScale] The old zoom scale factor.
  ///
  ///[newScale] The new zoom scale factor.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onZoomScaleChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onScaleChanged',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onScaleChanged(android.webkit.WebView,%20float,%20float)',
      ),
      IOSPlatform(
        apiName: 'UIScrollViewDelegate.scrollViewDidZoom',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619409-scrollviewdidzoom',
      ),
    ],
  )
  final void Function(T controller, double oldScale, double newScale)?
  onZoomScaleChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit}
  ///Event fired when the webview notifies that a loading URL has been flagged by Safe Browsing.
  ///The default behavior is to show an interstitial to the user, with the reporting checkbox visible.
  ///
  ///[url] represents the url of the request.
  ///
  ///[threatType] represents the reason the resource was caught by Safe Browsing, corresponding to a [SafeBrowsingThreat].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onSafeBrowsingHit.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onSafeBrowsingHit',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onSafeBrowsingHit(android.webkit.WebView,%20android.webkit.WebResourceRequest,%20int,%20android.webkit.SafeBrowsingResponse)',
        available: '27',
      ),
    ],
  )
  final FutureOr<SafeBrowsingResponse?> Function(
    T controller,
    WebUri url,
    SafeBrowsingThreat? threatType,
  )?
  onSafeBrowsingHit;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest}
  ///Event fired when the WebView is requesting permission to access the specified resources and the permission currently isn't granted or denied.
  ///
  ///[permissionRequest] represents the permission request with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequest(android.webkit.PermissionRequest)',
        available: '21',
      ),
      IOSPlatform(
        available: '15.0',
        note:
            'The default [PermissionResponse.action] is [PermissionResponseAction.PROMPT].',
      ),
    ],
  )
  final FutureOr<PermissionResponse?> Function(
    T controller,
    PermissionRequest permissionRequest,
  )?
  onPermissionRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt}
  ///Event that notifies the host application that web content from the specified origin is attempting to use the Geolocation API, but no permission state is currently set for that origin.
  ///Note that for applications targeting Android N and later SDKs (API level > `Build.VERSION_CODES.M`) this method is only called for requests originating from secure origins such as https.
  ///On non-secure origins geolocation requests are automatically denied.
  ///
  ///[origin] represents the origin of the web content attempting to use the Geolocation API.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsShowPrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)',
      ),
    ],
  )
  final FutureOr<GeolocationPermissionShowPromptResponse?> Function(
    T controller,
    String origin,
  )?
  onGeolocationPermissionsShowPrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt}
  ///Notify the host application that a request for Geolocation permissions, made with a previous call to [onGeolocationPermissionsShowPrompt] has been canceled.
  ///Any related UI should therefore be hidden.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onGeolocationPermissionsHidePrompt.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onGeolocationPermissionsHidePrompt',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()',
      ),
    ],
  )
  final void Function(T controller)? onGeolocationPermissionsHidePrompt;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptRequest}
  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the WebView will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This event is invoked for a variety of URL schemes (e.g., `http(s):`, `data:`, `file:`, etc.),
  ///not only those schemes which send requests over the network.
  ///This is not called for `javascript:` URLs, `blob:` URLs, or for assets accessed via `file:///android_asset/` or `file:///android_res/` URLs.
  ///
  ///In the case of redirects, this is only called for the initial resource URL, not any subsequent redirect URLs.
  ///
  ///[request] Object containing the details of the request.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useShouldInterceptRequest] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.shouldInterceptRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)',
      ),
    ],
  )
  final FutureOr<WebResourceResponse?> Function(
    T controller,
    WebResourceRequest request,
  )?
  shouldInterceptRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessUnresponsive}
  ///Event called when the renderer currently associated with the WebView becomes unresponsive as a result of a long running blocking task such as the execution of JavaScript.
  ///
  ///If a WebView fails to process an input event, or successfully navigate to a new URL within a reasonable time frame, the renderer is considered to be unresponsive, and this callback will be called.
  ///
  ///This callback will continue to be called at regular intervals as long as the renderer remains unresponsive.
  ///If the renderer becomes responsive again, [onRenderProcessResponsive] will be called once,
  ///and this method will not subsequently be called unless another period of unresponsiveness is detected.
  ///
  ///The minimum interval between successive calls to [onRenderProcessUnresponsive] is 5 seconds.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///Applications may choose to terminate the associated renderer via the object that is passed to this callback,
  ///if in multiprocess mode, however this must be accompanied by correctly handling [onRenderProcessGone] for this WebView,
  ///and all other WebViews associated with the same renderer. Failure to do so will result in application termination.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessUnresponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessUnresponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessUnresponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
    ],
  )
  final FutureOr<WebViewRenderProcessAction?> Function(
    T controller,
    WebUri? url,
  )?
  onRenderProcessUnresponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessResponsive}
  ///Event called once when an unresponsive renderer currently associated with the WebView becomes responsive.
  ///
  ///After a WebView renderer becomes unresponsive, which is notified to the application by [onRenderProcessUnresponsive],
  ///it is possible for the blocking renderer task to complete, returning the renderer to a responsive state.
  ///In that case, this method is called once to indicate responsiveness.
  ///
  ///No action is taken by WebView as a result of this method call.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessResponsive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewRenderProcessClient.onRenderProcessResponsive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewRenderProcessClient#onRenderProcessResponsive(android.webkit.WebView,%20android.webkit.WebViewRenderProcess)',
        available: '29',
      ),
    ],
  )
  final FutureOr<WebViewRenderProcessAction?> Function(
    T controller,
    WebUri? url,
  )?
  onRenderProcessResponsive;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessGone}
  ///Event fired when the given WebView's render process has exited.
  ///The application's implementation of this callback should only attempt to clean up the WebView.
  ///The WebView should be removed from the view hierarchy, all references to it should be cleaned up.
  ///
  ///To cause an render process crash for test purpose, the application can call load url `"chrome://crash"` on the WebView.
  ///Note that multiple WebView instances may be affected if they share a render process, not just the specific WebView which loaded `"chrome://crash"`.
  ///
  ///[detail] the reason why it exited.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRenderProcessGone.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onRenderProcessGone',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onRenderProcessGone(android.webkit.WebView,%20android.webkit.RenderProcessGoneDetail)',
        available: '26',
      ),
    ],
  )
  final void Function(T controller, RenderProcessGoneDetail detail)?
  onRenderProcessGone;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission}
  ///As the host application if the browser should resend data as the requested page was a result of a POST. The default is to not resend the data.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onFormResubmission.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onFormResubmission',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onFormResubmission(android.webkit.WebView,%20android.os.Message,%20android.os.Message)',
      ),
    ],
  )
  final FutureOr<FormResubmissionAction?> Function(T controller, WebUri? url)?
  onFormResubmission;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedTouchIconUrl}
  ///Event fired when there is an url for an apple-touch-icon.
  ///
  ///[url] represents the icon url.
  ///
  ///[precomposed] is `true` if the url is for a precomposed touch icon.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedTouchIconUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onReceivedTouchIconUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onReceivedTouchIconUrl(android.webkit.WebView,%20java.lang.String,%20boolean)',
      ),
    ],
  )
  final void Function(T controller, WebUri url, bool precomposed)?
  onReceivedTouchIconUrl;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsBeforeUnload}
  ///Event fired when the client should display a dialog to confirm navigation away from the current page.
  ///This is the result of the `onbeforeunload` javascript event.
  ///If [JsBeforeUnloadResponse.handledByClient] is `true`, WebView will assume that the client will handle the confirm dialog.
  ///If [JsBeforeUnloadResponse.handledByClient] is `false`, a default value of `true` will be returned to javascript to accept navigation away from the current page.
  ///The default behavior is to return `false`.
  ///Setting the [JsBeforeUnloadResponse.action] to [JsBeforeUnloadResponseAction.CONFIRM] will navigate away from the current page,
  ///[JsBeforeUnloadResponseAction.CANCEL] will cancel the navigation.
  ///
  ///[jsBeforeUnloadRequest] contains the message to be displayed in the alert dialog and the of the page requesting the dialog.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onJsBeforeUnload.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onJsBeforeUnload',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onJsBeforeUnload(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20android.webkit.JsResult)',
      ),
    ],
  )
  final FutureOr<JsBeforeUnloadResponse?> Function(
    T controller,
    JsBeforeUnloadRequest jsBeforeUnloadRequest,
  )?
  onJsBeforeUnload;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest}
  ///Event fired when a request to automatically log in the user has been processed.
  ///
  ///[loginRequest] contains the realm, account and args of the login request.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onReceivedLoginRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewClient.onReceivedLoginRequest',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebViewClient#onReceivedLoginRequest(android.webkit.WebView,%20java.lang.String,%20java.lang.String,%20java.lang.String)',
      ),
    ],
  )
  final void Function(T controller, LoginRequest loginRequest)?
  onReceivedLoginRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled}
  ///Notify the host application that the given permission request has been canceled. Any related UI should therefore be hidden.
  ///
  ///[permissionRequest] represents the permission request that needs be canceled
  ///with an array of resources the web content wants to access
  ///and the origin of the web page which is trying to access the restricted resources.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onPermissionRequestCanceled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onPermissionRequestCanceled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onPermissionRequestCanceled(android.webkit.PermissionRequest)',
        available: '21',
      ),
    ],
  )
  final void Function(T controller, PermissionRequest permissionRequest)?
  onPermissionRequestCanceled;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus}
  ///Request display and focus for this WebView.
  ///This may happen due to another WebView opening a link in this WebView and requesting that this WebView be displayed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebChromeClient.onRequestFocus](https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)))
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onRequestFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onRequestFocus',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onRequestFocus(android.webkit.WebView)',
      ),
    ],
  )
  final void Function(T controller)? onRequestFocus;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate}
  ///Invoked when the web view's web content process is terminated.
  ///Reloading the page will start a new render process if needed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onWebContentProcessDidTerminate.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webViewWebContentProcessDidTerminate',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455639-webviewwebcontentprocessdidtermi',
      ),
    ],
  )
  final void Function(T controller)? onWebContentProcessDidTerminate;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation}
  ///Called when a web view receives a server redirect.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onDidReceiveServerRedirectForProvisionalNavigation.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455627-webview',
      ),
    ],
  )
  final void Function(T controller)?
  onDidReceiveServerRedirectForProvisionalNavigation;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse}
  ///Called when a web view asks for permission to navigate to new content after the response to the navigation request is known.
  ///
  ///[navigationResponse] represents the navigation response.
  ///
  ///**NOTE**: In order to be able to listen this event, check the [InAppWebViewSettings.useOnNavigationResponse] setting documentation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onNavigationResponse.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455643-webview',
      ),
    ],
  )
  final FutureOr<NavigationResponseAction?> Function(
    T controller,
    NavigationResponse navigationResponse,
  )?
  onNavigationResponse;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS}
  ///Called when a web view asks whether to continue with a connection that uses a deprecated version of TLS (v1.0 and v1.1).
  ///
  ///[challenge] represents the authentication challenge.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.shouldAllowDeprecatedTLS.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKNavigationDelegate.webView',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationdelegate/3601237-webview',
        available: '14.0',
      ),
    ],
  )
  final FutureOr<ShouldAllowDeprecatedTLSAction?> Function(
    T controller,
    URLAuthenticationChallenge challenge,
  )?
  shouldAllowDeprecatedTLS;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged}
  ///Event fired when a change in the camera capture state occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onCameraCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform(available: '15.0')])
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )?
  onCameraCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged}
  ///Event fired when a change in the microphone capture state occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onMicrophoneCaptureStateChanged.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform(available: '15.0')])
  final FutureOr<void> Function(
    T controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )?
  onMicrophoneCaptureStateChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged}
  ///Event fired when the content size of the `WebView` changes.
  ///
  ///[oldContentSize] represents the old content size value.
  ///
  ///[newContentSize] represents the new content size value.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onContentSizeChanged.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  final void Function(T controller, Size oldContentSize, Size newContentSize)?
  onContentSizeChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onShowFileChooser}
  ///Tell the client to show a file chooser.
  ///This is called to handle HTML forms with 'file' input type,
  ///in response to the user pressing the "Select File" button.
  ///To cancel the request, return a [ShowFileChooserResponse] with [ShowFileChooserResponse.filePaths] to `null`.
  ///
  ///Note that the WebView does not enforce any restrictions on the chosen file(s).
  ///WebView can access all files that your app can access.
  ///In case the file(s) are chosen through an untrusted source such as a third-party app,
  ///it is your own app's responsibility to check what the returned Uris refer
  ///to.
  ///
  ///**NOTE for iOS**: available on iOS 18.4+ and it behaves differently from Android in two ways
  ///that matter.
  ///
  ///First, returning a [ShowFileChooserResponse] with [ShowFileChooserResponse.handledByClient]
  ///set to `false` **cancels** the request. On Android it falls through to the plugin's own file
  ///picker, but on iOS there is nothing to fall back to: `WKUIDelegate`'s open-panel method is
  ///all-or-nothing, and by the time this event fires WebKit has already declined to show its own
  ///picker. If you set [InAppWebViewSettings.useOnShowFileChooser] you are taking over file
  ///selection completely.
  ///
  ///Second, [ShowFileChooserRequest.acceptTypes], [ShowFileChooserRequest.isCaptureEnabled],
  ///[ShowFileChooserRequest.title] and [ShowFileChooserRequest.filenameHint] are always empty,
  ///`false` and `null`. `WKOpenPanelParameters` does not expose the `accept` attribute of the
  ///`<input type="file">` element, so filtering by MIME type is not possible on iOS.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.onShowFileChooser.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebChromeClient.onShowFileChooser',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebChromeClient#onShowFileChooser(android.webkit.WebView,%20android.webkit.ValueCallback%3Candroid.net.Uri[]%3E,%20android.webkit.WebChromeClient.FileChooserParams)',
      ),
      IOSPlatform(
        available: "18.4",
        apiName:
            'WKUIDelegate.webView(_:runOpenPanelWith:initiatedByFrame:completionHandler:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkuidelegate/webview(_:runopenpanelwith:initiatedbyframe:completionhandler:)',
        note:
            'Requires [InAppWebViewSettings.useOnShowFileChooser] to be `true`. Returning `handledByClient: false` cancels the request instead of falling back to a default picker.',
      ),
    ],
  )
  final FutureOr<ShowFileChooserResponse?> Function(
    T controller,
    ShowFileChooserRequest request,
  )?
  onShowFileChooser;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUrlRequest}
  ///Initial url request that will be loaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUrlRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            'When loading an URL Request using "POST" method, headers are ignored.',
      ),
      IOSPlatform(),
    ],
  )
  final URLRequest? initialUrlRequest;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialFile}
  ///Initial asset file that will be loaded. See [InAppWebViewController.loadFile] for explanation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialFile.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final String? initialFile;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialData}
  ///Initial [InAppWebViewInitialData] that will be loaded.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialData.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final InAppWebViewInitialData? initialData;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialSettings}
  ///Initial settings that will be used.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialSettings.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final InAppWebViewSettings? initialSettings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///Context menu which contains custom menu items to be shown when [ContextMenu] is presented.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final ContextMenu? contextMenu;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///Initial list of user scripts to be loaded at start or end of a page loading.
  ///To add or remove user scripts, you have to use the [InAppWebViewController]'s methods such as [InAppWebViewController.addUserScript],
  ///[InAppWebViewController.removeUserScript], [InAppWebViewController.removeAllUserScripts], etc.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            """This property will be ignored if the [PlatformWebViewCreationParams.windowId] has been set.
There isn't any way to add/remove user scripts specific to iOS window WebViews.
This is a limitation of the native WebKit APIs.""",
      ),
    ],
  )
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///Represents the pull-to-refresh feature controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            'To be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.',
      ),
      IOSPlatform(),
    ],
  )
  final PlatformPullToRefreshController? pullToRefreshController;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///Represents the find interaction feature controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final PlatformFindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
  const PlatformWebViewCreationParams({
    this.controllerFromPlatform,
    this.windowId,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onReceivedError,
    this.onReceivedHttpError,
    this.onProgressChanged,
    this.onConsoleMessage,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.onDownloadStarting,
    this.onLoadResourceWithCustomScheme,
    this.onCreateWindow,
    this.onCloseWindow,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onUpdateVisitedHistory,
    this.onPrintRequest,
    this.onLongPressHitTestResult,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onPageCommitVisible,
    this.onTitleChanged,
    this.onWindowFocus,
    this.onWindowBlur,
    this.onOverScrolled,
    this.onZoomScaleChanged,
    this.onSafeBrowsingHit,
    this.onPermissionRequest,
    this.onGeolocationPermissionsShowPrompt,
    this.onGeolocationPermissionsHidePrompt,
    this.shouldInterceptRequest,
    this.onRenderProcessGone,
    this.onRenderProcessResponsive,
    this.onRenderProcessUnresponsive,
    this.onFormResubmission,
    this.onReceivedTouchIconUrl,
    this.onJsBeforeUnload,
    this.onReceivedLoginRequest,
    this.onPermissionRequestCanceled,
    this.onRequestFocus,
    this.onWebContentProcessDidTerminate,
    this.onDidReceiveServerRedirectForProvisionalNavigation,
    this.onNavigationResponse,
    this.shouldAllowDeprecatedTLS,
    this.onCameraCaptureStateChanged,
    this.onMicrophoneCaptureStateChanged,
    this.onContentSizeChanged,
    this.onShowFileChooser,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    this.initialSettings,
    this.contextMenu,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.findInteractionController,
  });

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebViewCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebViewCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => _PlatformWebViewCreationParamsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
