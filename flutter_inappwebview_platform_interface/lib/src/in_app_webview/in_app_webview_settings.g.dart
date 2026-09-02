// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all the WebView settings available.
///{@endtemplate}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
class InAppWebViewSettings {
  ///A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIView.accessibilityIgnoresInvertColors](https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors))
  bool? accessibilityIgnoresInvertColors;

  ///Control whether algorithmic darkening is allowed.
  ///
  ///WebView always sets the media query `prefers-color-scheme` according to the app's theme attribute `isLightTheme`,
  ///i.e. `prefers-color-scheme` is light if `isLightTheme` is `true` or not specified, otherwise it is `dark`.
  ///This means that the web content's light or dark style will be applied automatically to match the app's theme if the content supports it.
  ///
  ///Algorithmic darkening is disallowed by default.
  ///
  ///If the app's theme is dark and it allows algorithmic darkening,
  ///WebView will attempt to darken web content using an algorithm,
  ///if the content doesn't define its own dark styles and doesn't explicitly disable darkening.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettingsCompat.setAlgorithmicDarkeningAllowed](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.
  bool? algorithmicDarkeningAllowed;

  ///Set to `true` to allow audio playing when the app goes in background or the screen is locked or another app is opened.
  ///However, there will be no controls in the notification bar or on the lockscreen.
  ///Also, make sure to not call [PlatformInAppWebViewController.pause], otherwise it will stop audio playing.
  ///The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: if you use this setting, your app could be rejected by the Google Play Store.
  ///For example, if you allow background playing of YouTube videos, which is a violation of the YouTube API Terms of Service.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? allowBackgroundAudioPlaying;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowContentAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)))
  bool? allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)))
  bool? allowFileAccess;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  bool? allowFileAccessFromFileURLs;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin.
  ///This includes access to content from other file scheme URLs or web contexts.
  ///Note that some access such as image HTML elements doesn't follow same-origin rules and isn't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to launch cross-site scripting attacks,
  ///either accessing arbitrary local files including WebView cookies, app private data or even credentials used on arbitrary web sites.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowUniversalAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)))
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? allowUniversalAccessFromFileURLs;

  ///Used in combination with [PlatformWebViewCreationParams.initialUrlRequest] or [PlatformWebViewCreationParams.initialData] (using the `file://` scheme), it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [URLRequest.url] if you are using it with the [PlatformWebViewCreationParams.initialUrlRequest] parameter or
  ///the [InAppWebViewInitialData.baseUrl] if you are using it with the [PlatformWebViewCreationParams.initialData] parameter.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///
  ///**This is not a security boundary. Do not rely on it to keep a `file://` page away from other
  ///local files.** Setting it selects which WebKit API the plugin calls
  ///(`WKWebView.loadFileURL(_:allowingReadAccessTo:)` instead of `WKWebView.load(_:)`), and WebKit
  ///decides what that scope actually restricts.
  ///
  ///Measured on iOS 17.5 and 26.5: a page at `<dir>/html/index.html` with
  ///`<script src="../js/main.js">` loads and runs that sibling script **in every configuration** —
  ///with no value set, with `<dir>/` set, and with the scope narrowed to `<dir>/html/` alone, which
  ///does not contain it. The plugin was verified to pass the correct file URL through to
  ///`loadFileURL`, so this is WebKit's behaviour, not a value that fails to arrive.
  ///
  ///If a local page must not reach a file, do not put that file where the page can name it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  WebUri? allowingReadAccessTo;

  ///Set to `true` to allow AirPlay. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? allowsAirPlayForMediaPlayback;

  ///Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations.
  ///
  ///**NOTE for Windows**: Swiping down to refresh is off by default and not exposed via API currently,
  ///it requires the "--pull-to-refresh" option to be included in
  ///the additional browser arguments to be configured.
  ///(See [WebViewEnvironmentSettings.additionalBrowserArguments].).
  ///When set to `false`, the end user cannot swipe to navigate or pull to refresh.
  ///This API only affects the overscrolling navigation functionality and has
  ///no effect on the scrolling interaction used to explore the web content shown in WebView2.
  ///Disabling/Enabling [allowsBackForwardNavigationGestures] takes effect after the next navigation.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  bool? allowsBackForwardNavigationGestures;

  ///Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
  ///For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsInlineMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? allowsInlineMediaPlayback;

  ///Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  bool? allowsLinkPreview;

  ///Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsPictureInPictureMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? allowsPictureInPictureMediaPlayback;

  ///The view’s alpha value. The value of this property is a floating-point number
  ///in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setAlpha](https://developer.android.com/reference/android/view/View#setAlpha(float)))
  ///- iOS WKWebView ([Official API - UIView.alpha](https://developer.apple.com/documentation/uikit/uiview/1622417-alpha))
  double? alpha;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceHorizontal](https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal))
  bool? alwaysBounceHorizontal;

  ///A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceVertical](https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical))
  bool? alwaysBounceVertical;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView (Official API - WebSettings.setAppCachePath)
  String? appCachePath;

  ///Set to `true` to enable Apple Pay API for the `WebView` at its first page load or on the next page load (using [PlatformInAppWebViewController.setOptions]). The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: As written in the official [Safari 13 Release Notes](https://developer.apple.com/documentation/safari-release-notes/safari-13-release-notes#Payment-Request-API),
  ///it won't work if any script injection APIs are used (such as [PlatformInAppWebViewController.evaluateJavascript] or [UserScript]).
  ///So, when this attribute is `true`, all the methods, options, and events implemented using JavaScript won't be called or won't do anything and the result will always be `null`.
  ///
  ///Methods affected:
  ///- [PlatformInAppWebViewController.addUserScript]
  ///- [PlatformInAppWebViewController.addUserScripts]
  ///- [PlatformInAppWebViewController.removeUserScript]
  ///- [PlatformInAppWebViewController.removeUserScripts]
  ///- [PlatformInAppWebViewController.removeAllUserScripts]
  ///- [PlatformInAppWebViewController.evaluateJavascript]
  ///- [PlatformInAppWebViewController.callAsyncJavaScript]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromUrl]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromAsset]
  ///- [PlatformInAppWebViewController.injectCSSCode]
  ///- [PlatformInAppWebViewController.injectCSSFileFromUrl]
  ///- [PlatformInAppWebViewController.injectCSSFileFromAsset]
  ///- [PlatformFindInteractionController.findAll]
  ///- [PlatformFindInteractionController.findNext]
  ///- [PlatformFindInteractionController.clearMatches]
  ///- [PlatformInAppWebViewController.pauseTimers]
  ///- [PlatformInAppWebViewController.getSelectedText]
  ///- [PlatformInAppWebViewController.getHitTestResult]
  ///- [PlatformInAppWebViewController.requestFocusNodeHref]
  ///- [PlatformInAppWebViewController.requestImageRef]
  ///- [PlatformInAppWebViewController.postWebMessage]
  ///- [PlatformInAppWebViewController.createWebMessageChannel]
  ///- [PlatformInAppWebViewController.addWebMessageListener]
  ///
  ///Settings affected:
  ///- [PlatformWebViewCreationParams.initialUserScripts]
  ///- [InAppWebViewSettings.supportZoom]
  ///- [InAppWebViewSettings.useOnLoadResource]
  ///- [InAppWebViewSettings.useShouldInterceptAjaxRequest]
  ///- [InAppWebViewSettings.useShouldInterceptFetchRequest]
  ///- [InAppWebViewSettings.enableViewportScale]
  ///
  ///Events affected:
  ///- the `hitTestResult` argument of [PlatformWebViewCreationParams.onLongPressHitTestResult] will be empty
  ///- the `hitTestResult` argument of [ContextMenu.onCreateContextMenu] will be empty
  ///- [PlatformWebViewCreationParams.onLoadResource]
  ///- [PlatformWebViewCreationParams.shouldInterceptAjaxRequest]
  ///- [PlatformWebViewCreationParams.onAjaxReadyStateChange]
  ///- [PlatformWebViewCreationParams.onAjaxProgress]
  ///- [PlatformWebViewCreationParams.shouldInterceptFetchRequest]
  ///- [PlatformWebViewCreationParams.onConsoleMessage]
  ///- [PlatformWebViewCreationParams.onPrintRequest]
  ///- [PlatformWebViewCreationParams.onWindowFocus]
  ///- [PlatformWebViewCreationParams.onWindowBlur]
  ///- [FindInteractionController.onFindResultReceived]
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  bool? applePayAPIEnabled;

  ///Append to the existing user-agent. Setting userAgent will override this.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `userAgent` instead, which is applied to the live WebView and does respond to `setSettings`.
  String? applicationNameForUserAgent;

  ///Sets how this WebView registers sources and triggers for the
  ///[Attribution Reporting API](https://developer.android.com/design-for-safety/privacy-sandbox/attribution).
  ///
  ///Controls whether an ad impression and its conversion are attributed to the app or to the web.
  ///Only relevant to apps that display ads or measure conversions in a WebView; use
  ///[AttributionRegistrationBehavior.DISABLED] to switch attribution registration off entirely.
  ///
  ///Leave `null` to keep the platform default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setAttributionRegistrationBehavior](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAttributionRegistrationBehavior(android.webkit.WebSettings,int))):
  ///    - available on Android only if [WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR] feature is supported.
  AttributionRegistrationBehavior? attributionRegistrationBehavior;

  ///Configures whether the scroll indicator insets are automatically adjusted by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - UIScrollView.automaticallyAdjustsScrollIndicatorInsets](https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica))
  bool? automaticallyAdjustsScrollIndicatorInsets;

  ///Sets whether this WebView uses the [back/forward cache](https://web.dev/articles/bfcache).
  ///
  ///When enabled, a page the user navigates away from is kept in memory in a frozen state, so
  ///going back restores it instantly instead of reloading it.
  ///
  ///**This changes what your load callbacks see.** A page served from the back/forward cache is
  ///restored rather than re-loaded, so a back navigation does not repeat the full load lifecycle
  ///the way it does without the cache. Pages that need to run work on every appearance should
  ///listen for the web-standard `pageshow`/`pagehide` events and check their `persisted` flag,
  ///which is the signal designed for exactly this.
  ///
  ///Leave `null` to keep the platform default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setBackForwardCacheEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setBackForwardCacheEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.BACK_FORWARD_CACHE] feature is supported.
  bool? backForwardCacheEnabled;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkImage](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)))
  bool? blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkLoads](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)))
  bool? blockNetworkLoads;

  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBuiltInZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)))
  bool? builtInZoomControls;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? cacheEnabled;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [CacheMode.LOAD_DEFAULT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCacheMode](https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)))
  CacheMode? cacheMode;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  List<ContentBlocker>? contentBlockers;

  ///Configures how safe area insets are added to the adjusted content inset.
  ///The default value is [ScrollViewContentInsetAdjustmentBehavior.NEVER].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIScrollView.contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior))
  ScrollViewContentInsetAdjustmentBehavior? contentInsetAdjustmentBehavior;

  ///Sets the cursive font family name. The default value is `"cursive"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCursiveFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)))
  String? cursiveFontFamily;

  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [DataDetectorTypes.LINK].
  ///The default value is [DataDetectorTypes.NONE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 10+ ([Official API - WKWebViewConfiguration.dataDetectorTypes](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  List<DataDetectorTypes>? dataDetectorTypes;

  ///Set to `true` if you want the database storage API is enabled. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDatabaseEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)))
  bool? databaseEnabled;

  ///A [ScrollViewDecelerationRate] value that determines the rate of deceleration after the user lifts their finger.
  ///The default value is [ScrollViewDecelerationRate.NORMAL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.decelerationRate](https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate))
  ScrollViewDecelerationRate? decelerationRate;

  ///Sets the default fixed font size. The default value is `16`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFixedFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)))
  int? defaultFixedFontSize;

  ///Sets the default font size. The default value is `16`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)))
  int? defaultFontSize;

  ///Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultTextEncodingName](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)))
  String? defaultTextEncodingName;

  ///When not playing, video elements are represented by a 'poster' image.
  ///The image to use can be specified by the poster attribute of the video tag in HTML.
  ///If the attribute is absent, then a default poster will be used.
  ///This property allows the WebView to provide that default image.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  Uint8List? defaultVideoPoster;

  ///Set to `true` to disable context menu. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? disableContextMenu;

  ///Sets whether the default Android WebView’s internal error page should be suppressed or displayed for bad navigations.
  ///`true` means suppressed (not shown), `false` means it will be displayed. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? disableDefaultErrorPage;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? disableHorizontalScroll;

  ///Set to `true` to disable the [inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) above system keyboard.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disableInputAccessoryView;

  ///Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
  ///This is implemented using also JavaScript, so it must be enabled or it won't work.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disableLongPressContextMenuOnLinks;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? disableVerticalScroll;

  ///Disables the action mode menu items according to menuItems flag.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 24+ ([Official API - WebSettings.setDisabledActionModeMenuItems](https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)))
  ActionModeMenuItem? disabledActionModeMenuItems;

  ///Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disallowOverScroll;

  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDisplayZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)))
  bool? displayZoomControls;

  ///Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDomStorageEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)))
  bool? domStorageEnabled;

  ///Sets whether this WebView downloads the favicons declared by the pages it loads.
  ///
  ///Favicon downloading costs an extra network request per page, so turning it off is worthwhile
  ///for a WebView whose favicons are never displayed.
  ///
  ///**This setting does not surface an icon to Dart.** It only controls whether the WebView issues
  ///the request — measured on API 33, the fetch of `favicon.ico` is visible through
  ///[PlatformWebViewCreationParams.onLoadResource] when this is enabled. The framework callback that
  ///used to deliver the downloaded bitmap, `WebChromeClient.onReceivedIcon`, is no longer dispatched
  ///by a modern WebView, so the plugin removed the event it fed in 7.0.0. Use
  ///[PlatformInAppWebViewController.getFavicons] to read a page's icons.
  ///
  ///Leave `null` to keep the platform default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setDownloadFaviconsEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setDownloadFaviconsEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.DOWNLOAD_FAVICONS_ENABLED] feature is supported.
  bool? downloadFaviconsEnabled;

  ///Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? enableViewportScale;

  ///Sets whether EnterpriseAuthenticationAppLinkPolicy if set by admin is allowed to have any
  ///effect on WebView.
  ///
  ///EnterpriseAuthenticationAppLinkPolicy in WebView allows admins to specify authentication
  ///urls. When WebView is redirected to authentication url, and an app on the device has
  ///registered as the default handler for the url, that app is launched.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.
  bool? enterpriseAuthenticationAppLinkPolicyEnabled;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFantasyFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)))
  String? fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFixedFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)))
  String? fixedFontFamily;

  ///Sets whether Geolocation is enabled. The default is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setGeolocationEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean))):
  ///    - Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met: - an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION); - an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.
  bool? geolocationEnabled;

  ///Boolean value to enable Hardware Acceleration in the WebView.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setLayerType](https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)))
  bool? hardwareAcceleration;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setHorizontalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsHorizontalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator))
  bool? horizontalScrollBarEnabled;

  ///Sets the horizontal scrollbar thumb color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  Color? horizontalScrollbarThumbColor;

  ///Sets the horizontal scrollbar track color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  Color? horizontalScrollbarTrackColor;

  ///Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
  ///The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.ignoresViewportScaleLimits](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? ignoresViewportScaleLimits;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - setting this to `true`, it will clear all the cookies of all WebView instances, because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? incognito;

  ///Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of [useWideViewPort] and [loadWithOverviewMode].
  ///If the content fits into the WebView control by width, then the zoom is set to 100%. For wide content, the behavior depends on the state of [loadWithOverviewMode].
  ///If its value is true, the content will be zoomed out to be fit by width into the WebView control, otherwise not.
  ///If initial scale is greater than 0, WebView starts with this value as initial scale.
  ///Please note that unlike the scale properties in the viewport meta tag, this method doesn't take the screen density into account.
  ///The default is `0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setInitialScale](https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)))
  int? initialScale;

  ///Set to `false` to be able to listen to also sync `XMLHttpRequest`s at the
  ///[PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///**NOTE**: Using `false` will cause the `XMLHttpRequest.send()` method for sync
  ///requests to not wait on the JavaScript code the response synchronously,
  ///as if it was an async `XMLHttpRequest`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? interceptOnlyAsyncAjaxRequests;

  ///A Boolean value that determines whether scrolling is disabled in a particular direction.
  ///If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
  ///If this property is `true` and the user begins dragging in one general direction (horizontally or vertically),
  ///the scroll view disables scrolling in the other direction.
  ///If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isDirectionalLockEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled))
  bool? isDirectionalLockEnabled;

  ///Sets whether fullscreen API is enabled or not.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  bool? isElementFullscreenEnabled;

  ///Sets whether the web view's built-in find interaction native UI is enabled or not.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebView.isFindInteractionEnabled](https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/))
  bool? isFindInteractionEnabled;

  ///A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
  ///According to the official documentation, this feature is currently available in the following region: China.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  bool? isFraudulentWebsiteWarningEnabled;

  ///Controls whether this WebView is inspectable in Web Inspector.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  bool? isInspectable;

  ///A Boolean value that determines whether paging is enabled for the scroll view.
  ///If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isPagingEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled))
  bool? isPagingEnabled;

  ///A Boolean value indicating whether WebKit will apply built-in workarounds (quirks)
  ///to improve compatibility with certain known websites. You can disable site-specific quirks
  ///to help test your website without these workarounds. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  bool? isSiteSpecificQuirksModeEnabled;

  ///A Boolean value indicating whether text interaction is enabled or not.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  bool? isTextInteractionEnabled;

  ///A Boolean value that determines whether user events are ignored and removed from the event queue.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIView.isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled))
  bool? isUserInteractionEnabled;

  ///Set to `false` to disable the JavaScript Bridge completely.
  ///This will affect also all the internal plugin [UserScript]s
  ///that are using the JavaScript Bridge to work.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? javaScriptBridgeEnabled;

  ///Set to `true` to allow the JavaScript Bridge only on the main frame.
  ///If [pluginScriptsForMainFrameOnly] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? javaScriptBridgeForMainFrameOnly;

  ///A [Set] of patterns that will be used to match the allowed origins where
  ///the JavaScript Bridge could be used.
  ///If [pluginScriptsOriginAllowList] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin and, in this case,
  ///it will force the behaviour of the [javaScriptBridgeEnabled] parameter,
  ///as it was set to `false`.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  Set<String>? javaScriptBridgeOriginAllowList;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptCanOpenWindowsAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)))
  ///- iOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  bool? javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)))
  ///- iOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  bool? javaScriptEnabled;

  ///Set to `true` to allow to execute the JavaScript Handlers only on the main frame.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? javaScriptHandlersForMainFrameOnly;

  ///A [Set] of Regular Expression Patterns that will be used on native side to match the allowed origins
  ///that are able to execute the JavaScript Handlers defined for the current WebView.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///
  ///An empty [Set] will block every origin.
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  Set<String>? javaScriptHandlersOriginAllowList;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLayoutAlgorithm](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)))
  LayoutAlgorithm? layoutAlgorithm;

  ///A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain.
  ///Check [App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) for more details.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? limitsNavigationsToAppBoundDomains;

  ///Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///This setting is taken into account when the content width is greater than the width of the WebView control, for example, when [useWideViewPort] is enabled.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadWithOverviewMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)))
  bool? loadWithOverviewMode;

  ///Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
  ///Note that if the value of this setting is changed from false to true, all images resources referenced by content currently displayed by the WebView are loaded automatically.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadsImagesAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)))
  bool? loadsImagesAutomatically;

  ///Whether Lockdown Mode is enabled for this WebView's navigations.
  ///
  ///Lockdown Mode trades performance and web compatibility for security, disabling web features
  ///outright. Setting it `true` opts a single WebView into those restrictions even when the device
  ///is not in Lockdown Mode.
  ///
  ///**Leave this `null` unless you specifically mean to override the user.** WebKit documents the
  ///default as *depending on the system setting*, so `null` means "respect whatever the device is
  ///configured to do". Passing `false` explicitly **disables Lockdown Mode for this WebView even on
  ///a device where the user turned it on**, which is virtually never what an app should do.
  ///
  ///For hardening untrusted content without breaking it, prefer
  ///[InAppWebViewSettings.securityRestrictionMode] with
  ///[SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY], which keeps full web compatibility and only
  ///costs JavaScript performance.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebpagePreferences.lockdownModeEnabled](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/islockdownmodeenabled)):
  ///    - Defaults to the device's system setting. Passing `false` overrides a user who enabled Lockdown Mode.
  bool? lockdownModeEnabled;

  ///Set maximum viewport inset to the largest inset a webpage may experience in your app's maximally expanded UI configuration.
  ///Values must be either zero or positive. It must be larger than [minimumViewportInset].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  EdgeInsets? maximumViewportInset;

  ///A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content.
  ///This value determines how large the content can be scaled.
  ///It must be greater than the minimum zoom scale for zooming to be enabled.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.maximumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale))
  double? maximumZoomScale;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMediaPlaybackRequiresUserGesture](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)))
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? mediaPlaybackRequiresUserGesture;

  ///The media type for the contents of the web view.
  ///When the value of this property is `null`, the web view derives the current media type from the CSS media property of its content.
  ///If you assign a value other than `null` to this property, the web view uses the value you provide instead.
  ///The default value of this property is `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  String? mediaType;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)))
  ///- iOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  int? minimumFontSize;

  ///Sets the minimum logical font size. The default is `8`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumLogicalFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)))
  int? minimumLogicalFontSize;

  ///Set minimum viewport inset to the smallest inset a webpage may experience in your app's maximally collapsed UI configuration.
  ///Values must be either zero or positive. It must be smaller than [maximumViewportInset].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  EdgeInsets? minimumViewportInset;

  ///A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content.
  ///This value determines how small the content can be scaled.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.minimumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale))
  double? minimumZoomScale;

  ///Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebSettings.setMixedContentMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)))
  MixedContentMode? mixedContentMode;

  ///Tells the WebView whether it needs to set a node. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setNeedInitialFocus](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)))
  bool? needInitialFocus;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setNetworkAvailable](https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)))
  bool? networkAvailable;

  ///Edge insets, relative to the WebView's own coordinate space, that shrink the **layout
  ///viewport** because your app draws something over those areas — a translucent navigation bar,
  ///a floating toolbar, a set of overlay buttons.
  ///
  ///This is not a scroll inset and not a margin: the page keeps painting edge to edge underneath
  ///your UI. WebKit's documentation describes the effect as shrinking the bounds of the **layout
  ///viewport**, and says it adjusts how `position: fixed` and `position: sticky` elements are
  ///rendered near an edge with a non-zero inset, so a sticky header lands below your bar rather
  ///than behind it.
  ///
  ///**What the page observes is WebKit's business and this plugin does not characterise it.** An
  ///attempt to pin it from the integration suite gave inconsistent results on one simulator and one
  ///binary — `window.innerHeight` shrank by `top + bottom` in some framings and by more in others,
  ///and `env(safe-area-inset-*)` appeared unaffected in one framing and changed in another. Do not
  ///assume a particular relationship to the safe-area custom properties; measure it on a real
  ///device for the layout you actually ship, or pass the values into the page yourself.
  ///
  ///All four values must be **non-negative** — this is WebKit's requirement, and it is asserted in
  ///the constructor. Leaving this `null` keeps WebKit's default of zero on all sides.
  ///
  ///**NOTE for iOS**: this is a property of the `WKWebView` itself rather than of its
  ///configuration, so — unlike [InAppWebViewSettings.showsSystemScreenTimeBlockingView] and the
  ///rest of the creation-only family — it **does** take effect when changed through `setSettings`
  ///on a running WebView.
  ///
  ///**NOTE for iOS**: this is **not** a replacement for the plugin's keyboard handling and does not
  ///fix the keyboard `contentInset` behaviour on any OS that can still be affected by it. It
  ///arrives at iOS 26.0, and the manual `keyboardWillShow`/`keyboardWillHide` compensation remains
  ///the only mechanism on **iOS 15 through 18** — every version this plugin supports below 26.
  ///Treat it as a new capability for app-drawn overlay chrome, not as a fix.
  ///
  ///**NOTE for iOS**: it is unrelated to [InAppWebViewSettings.minimumViewportInset] /
  ///[InAppWebViewSettings.maximumViewportInset], which describe the *range* a page should expect as
  ///your UI collapses and expands. This one is the inset in force right now.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+ ([Official API - WKWebView.obscuredContentInsets](https://developer.apple.com/documentation/webkit/wkwebview/obscuredcontentinsets)):
  ///    - Shrinks the bounds of the layout viewport so fixed/sticky elements avoid app-drawn chrome; the page still paints edge to edge. The exact page-visible effect is WebKit's and is not characterised here — do not assume a relationship to `env(safe-area-inset-*)`. All values must be non-negative. Applied live, so `setSettings` works. **Not** a fix for the keyboard `contentInset` behaviour — that path is unchanged on iOS 15 through 18.
  EdgeInsets? obscuredContentInsets;

  ///Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
  ///Turning this on can avoid rendering artifacts when animating an offscreen WebView on-screen.
  ///Offscreen WebViews in this mode use more memory. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+ ([Official API - WebSettings.setOffscreenPreRaster](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)))
  bool? offscreenPreRaster;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [OverScrollMode.IF_CONTENT_SCROLLS].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setOverScrollMode](https://developer.android.com/reference/android/view/View#setOverScrollMode(int)))
  OverScrollMode? overScrollMode;

  ///The scale factor by which the web view scales content relative to its bounds.
  ///The default value of this property is `1.0`, which displays the content without any scaling.
  ///Changing the value of this property is equivalent to setting the CSS `zoom` property on all page content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  double? pageZoom;

  ///Sets whether the [Payment Request API](https://developer.mozilla.org/en-US/docs/Web/API/Payment_Request_API)
  ///is enabled in this WebView.
  ///
  ///When enabled, `PaymentRequest` becomes available to web content, which lets a page invoke
  ///payment handlers — including Google Pay — instead of falling back to a manual checkout form.
  ///
  ///The Payment Request API is disabled by default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setPaymentRequestEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setPaymentRequestEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.PAYMENT_REQUEST] feature is supported.
  bool? paymentRequestEnabled;

  ///Set to `true` to allow internal plugin [UserScript]s only on the main frame.
  ///
  ///**NOTE**: If [javaScriptBridgeForMainFrameOnly] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? pluginScriptsForMainFrameOnly;

  ///A [Set] of patterns that will be used to match the allowed origins
  ///that are able to load all the internal plugin [UserScript]s used by the plugin itself.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin.
  ///
  ///**NOTE**: If [javaScriptBridgeOriginAllowList] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  Set<String>? pluginScriptsOriginAllowList;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 13.0+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  UserPreferredContentMode? preferredContentMode;

  ///Whether a top-level navigation should be upgraded to HTTPS, and what should happen when the
  ///upgrade fails.
  ///
  ///Leaving this `null` keeps WebKit's documented default,
  ///[UpgradeToHTTPSPolicy.KEEP_AS_REQUESTED], which does not prefer HTTPS at all.
  ///[UpgradeToHTTPSPolicy.ERROR_ON_FAILURE] is the HTTPS-Only equivalent.
  ///
  ///**NOTE for iOS**: two limitations come from WebKit itself, not from this plugin.
  ///[InAppWebViewSettings.upgradeKnownHostsToHTTPS] **supersedes** this policy for hosts WebKit
  ///already knows support HTTPS, and the policy is **ignored for subframe navigations** — it only
  ///applies to top-level ones. WebKit may also ignore it entirely based on system configuration.
  ///
  ///Unlike [InAppWebViewSettings.writingToolsBehavior], this one *does* take effect when changed
  ///through `setSettings`: it is applied to the per-navigation `WKWebpagePreferences` WebKit hands
  ///to the navigation policy delegate, not to the immutable configuration copy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.2+ ([Official API - WKWebpagePreferences.preferredHTTPSNavigationPolicy](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/preferredhttpsnavigationpolicy)):
  ///    - Applies to top-level navigations only, and `upgradeKnownHostsToHTTPS` supersedes it for known hosts.
  UpgradeToHTTPSPolicy? preferredHTTPSNavigationPolicy;

  ///Runs this WebView on the named browsing profile, creating the profile if it does not exist.
  ///
  ///A profile owns its own cookies, web storage, geolocation permissions and service workers, so
  ///two WebViews on different profiles share none of that. Leave `null` to use the default profile,
  ///which is what every WebView uses otherwise.
  ///
  ///**This only takes effect when the WebView is created.** The platform refuses to move a WebView
  ///to another profile once it has been used, so changing this through
  ///[PlatformInAppWebViewController.setSettings] does nothing — it is not applied and no error is
  ///raised. Recreate the WebView to switch profiles.
  ///
  ///**The plugin's own storage APIs default to the default profile, so pass this name to them
  ///too.** [PlatformCookieManager], [PlatformWebStorageManager] and
  ///[PlatformServiceWorkerController]'s settings methods all take a `profileName`; omitting it acts
  ///on the default profile's data, which on a non-default profile means reading or clearing data
  ///this WebView is not using. The one exception is
  ///[PlatformServiceWorkerController.setServiceWorkerClient], which is always default-profile —
  ///its intercept event carries no profile identity. Use [PlatformProfileStore] to create and
  ///delete profiles.
  ///
  ///Not applied to WebViews opened as a new window by another WebView — those keep the profile of
  ///the WebView that opened them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.setProfile](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setProfile(android.webkit.WebView,java.lang.String))):
  ///    - available on Android only if [WebViewFeature.MULTI_PROFILE] feature is supported.
  String? profileName;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to allow navigation requests synchronously.
  ///If the url request match the regular expression, then the request is allowed automatically,
  ///and the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event will not be fired.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? regexToAllowSyncUrlLoading;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a sub-frame matches the regular expression, then the request of that sub-frame is canceled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? regexToCancelSubFramesLoading;

  ///Sets the renderer priority policy for this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setRendererPriorityPolicy](https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)))
  RendererPriorityPolicy? rendererPriorityPolicy;

  ///List of custom schemes that the WebView must handle. Use the [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme] event to intercept resource requests with custom scheme.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  List<String>? resourceCustomSchemes;

  ///Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
  ///Safe Browsing is enabled by default for devices which support it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 26+ ([Official API - WebSettings.setSafeBrowsingEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)))
  bool? safeBrowsingEnabled;

  ///Sets the sans-serif font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSansSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)))
  String? sansSerifFontFamily;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarDefaultDelayBeforeFade](https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)))
  int? scrollBarDefaultDelayBeforeFade;

  ///Defines the scrollbar fade duration in milliseconds.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarFadeDuration](https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)))
  int? scrollBarFadeDuration;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setScrollBarStyle](https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)))
  ScrollBarStyle? scrollBarStyle;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollbarFadingEnabled](https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)))
  bool? scrollbarFadingEnabled;

  ///A Boolean value that controls whether the scroll-to-top gesture is enabled.
  ///The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
  ///the system asks the scroll view closest to the status bar to scroll to the top.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.scrollsToTop](https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop))
  bool? scrollsToTop;

  ///How much additional security hardening the WebView should apply to a navigation.
  ///
  ///Leaving this `null` keeps WebKit's documented default, [SecurityRestrictionMode.NONE].
  ///[SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY] is the one to reach for when loading content
  ///you do not control: it disables the JavaScript JIT and widens Memory Tagging Extension coverage
  ///while keeping full web compatibility, so the cost is JavaScript speed rather than broken pages.
  ///
  ///**NOTE for iOS**: several WebKit behaviours are worth knowing before using this.
  ///
  ///Setting any mode other than [SecurityRestrictionMode.NONE] makes WebKit create **separate,
  ///isolated WebContent processes** for that protection level, so mixing modes across WebViews
  ///costs additional processes.
  ///
  ///The mode applies to **main frame navigations only** and is ignored for subframes — but when it
  ///is set for a main frame, all subframe content *and opened windows* inherit the same
  ///restrictions.
  ///
  ///If the system has already chosen [SecurityRestrictionMode.LOCKDOWN] — for example because the
  ///device is in Lockdown Mode — attempts to set a **less** restrictive mode **fail silently**.
  ///
  ///Like [InAppWebViewSettings.preferredHTTPSNavigationPolicy] and unlike
  ///[InAppWebViewSettings.writingToolsBehavior], this takes effect when changed through
  ///`setSettings`, because it is applied to the per-navigation `WKWebpagePreferences`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.5+ ([Official API - WKWebpagePreferences.securityRestrictionMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/securityrestrictionmode)):
  ///    - Main-frame navigations only. Creates isolated WebContent processes. Lowering the mode fails silently while the system enforces Lockdown.
  SecurityRestrictionMode? securityRestrictionMode;

  ///The level of granularity with which the user can interactively select content in the web view.
  ///The default value is [SelectionGranularity.DYNAMIC].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.selectionGranularity](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  SelectionGranularity? selectionGranularity;

  ///Sets the serif font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)))
  String? serifFontFamily;

  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+:
  ///    - Applied when the WebView is created. On a running WebView `setSettings` still copies the `HTTPCookieStorage.shared` cookies into the WebView's data store, but it cannot switch the WebView to a non-persistent store: that half of the work is written to a discarded copy of `WKWebView.configuration`. Recreate the WebView to change it.
  bool? sharedCookiesEnabled;

  ///A Boolean value that indicates whether to include any background color or graphics when printing content.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  bool? shouldPrintBackgrounds;

  ///Whether WebKit draws its own Screen Time blocking view over the WebView when Screen Time
  ///restrictions block the loaded content.
  ///
  ///The default value is `true`, which is WebKit's own default: the system blocking view appears
  ///and the app has nothing to do. Set it to `false` when the app wants to present its own UI
  ///instead — read [PlatformInAppWebViewController.isBlockedByScreenTime] to find out whether the
  ///current content is blocked.
  ///
  ///**NOTE for iOS**: turning this off does **not** unblock the content. WebKit still refuses to
  ///show it; all that changes is who draws the explanation. A `false` with no
  ///[PlatformInAppWebViewController.isBlockedByScreenTime] check leaves the user looking at a blank
  ///WebView with no indication of why.
  ///
  ///**NOTE for iOS**: this is a `WKWebViewConfiguration` property, and `WKWebView.configuration`
  ///returns *a copy of the configuration with which the web view was initialized*. It is therefore
  ///applied **only when the WebView is created**, and changing it later through `setSettings` has
  ///no effect — the same limitation as [InAppWebViewSettings.supportsAdaptiveImageGlyph] and
  ///[InAppWebViewSettings.writingToolsBehavior]. Recreate the WebView to change it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+ ([Official API - WKWebViewConfiguration.showsSystemScreenTimeBlockingView](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/showssystemscreentimeblockingview)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored. Setting it `false` hides the system blocking view but does not unblock the content.
  bool? showsSystemScreenTimeBlockingView;

  ///Sets the standard font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setStandardFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)))
  String? standardFontFamily;

  ///Sets whether the WebView supports multiple windows.
  ///If set to `true`, [PlatformWebViewCreationParams.onCreateWindow] event must be implemented by the host application. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportMultipleWindows](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)))
  bool? supportMultipleWindows;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)))
  ///- iOS WKWebView
  bool? supportZoom;

  ///Whether the WebView allows insertion of **adaptive image glyphs** — the inline, text-sized
  ///images Apple Intelligence produces, most visibly Genmoji — into editable content.
  ///
  ///The default is `false`, which does not reject them: WebKit inserts them as **regular images**
  ///instead. Setting `true` inserts them with full adaptive sizing, so they scale with surrounding
  ///text like an emoji rather than sitting in the line as a fixed-size picture.
  ///
  ///**NOTE for iOS**: this is a `WKWebViewConfiguration` property, and `WKWebView.configuration` is
  ///documented as *"a copy of the configuration with which the web view was initialized"*. It is
  ///therefore applied **only when the WebView is created**, and changing it later through
  ///`setSettings` has no effect — the same limitation as
  ///[InAppWebViewSettings.writingToolsBehavior].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.0+ ([Official API - WKWebViewConfiguration.supportsAdaptiveImageGlyph](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/supportsadaptiveimageglyph)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.
  bool? supportsAdaptiveImageGlyph;

  ///Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  bool? suppressesIncrementalRendering;

  ///How long, **in milliseconds**, the WebView will wait for your Dart handler to answer a
  ///*synchronous* callback before continuing without it. The default is `10000` (10 seconds).
  ///
  ///Two events on Android are synchronous: [PlatformWebViewCreationParams.shouldInterceptRequest]
  ///and [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme]. The WebView cannot start
  ///loading the resource until it knows the answer, so the plugin **blocks a WebView worker
  ///thread** for the duration of the round trip to Dart. This is the bound on that block.
  ///
  ///On expiry the plugin logs a warning and behaves as if the handler had returned `null` — the
  ///resource simply loads normally, and the reply is ignored if it arrives later. Nothing is
  ///reported to Dart, because there is no longer anything the answer could affect.
  ///
  ///Raise it only if your handler legitimately needs longer — one that proxies the request through
  ///Dart HTTP over a slow link is the usual case. Every millisecond of it is a WebView thread
  ///parked, so a high value on a handler that has actually hung makes the page unresponsive for
  ///that much longer. A value of `0` or less is ignored and the default is used, so a mistaken `0`
  ///cannot silently switch interception off.
  ///
  ///Two other Dart callbacks block the same way and are **not** governed by this setting; both keep
  ///the fixed 10-second default:
  ///- `PathHandler.handle` for a custom [WebViewAssetLoader] path handler, which the WebView builds
  ///from [webViewAssetLoader] and which holds no reference to these settings.
  ///- [PlatformServiceWorkerController]'s `ServiceWorkerClient.shouldInterceptRequest`, which
  ///belongs to a process-wide controller with no WebView and therefore no settings to read.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int? syncCallbackTimeoutMillis;

  ///Sets the text zoom of the page in percent. The default value is `100`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setTextZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)))
  int? textZoom;

  ///Boolean value to enable third party cookies in the WebView.
  ///Used on Android Lollipop and above only as third party cookies are enabled by default on Android Kitkat and below and on iOS.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - CookieManager.setAcceptThirdPartyCookies](https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)))
  bool? thirdPartyCookiesEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? transparentBackground;

  ///The color the web view displays behind the active page, visible when the user scrolls beyond the bounds of the page.
  ///
  ///The web view derives the default value of this property from the content of the page,
  ///using the background colors of the `<html>` and `<body>` elements with the background color of the web view.
  ///To override the default color, set this property to a new color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  Color? underPageBackgroundColor;

  ///A Boolean value indicating whether HTTP requests to servers known to support HTTPS should be automatically upgraded to HTTPS requests.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `preferredHTTPSNavigationPolicy` instead, which is applied per navigation and does respond to `setSettings`.
  bool? upgradeKnownHostsToHTTPS;

  ///Set to `false` to disable Flutter Hybrid Composition. The default value is `true`.
  ///Hybrid Composition is supported starting with Flutter v1.20+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It is recommended to use Hybrid Composition only on Android 10+ for a release app, as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
  bool? useHybridComposition;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxProgress] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxProgress] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxProgress] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useOnAjaxProgress;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxReadyStateChange] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useOnAjaxReadyStateChange;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onDownloadStarting] event.
  ///
  ///If the [PlatformWebViewCreationParams.onDownloadStarting] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useOnDownloadStart;

  ///Set to `true` to be able to listen at the
  ///[PlatformWebViewCreationParams.onInsertInputSuggestion] event.
  ///
  ///If the [PlatformWebViewCreationParams.onInsertInputSuggestion] event is implemented and this
  ///value is `null`, it is automatically inferred as `true`; otherwise the default is `false`. This
  ///inference is not applied for [PlatformInAppBrowser], where the value must be set manually — the
  ///same rule as [InAppWebViewSettings.useOnShowFileChooser].
  ///
  ///**NOTE for iOS**: this gates the `WKUIDelegate` selector itself, not just the event. While it
  ///is `false` the plugin reports that it does not implement
  ///`webView(_:insertInputSuggestion:)` at all, so WebKit's own handling — whatever it is — stays
  ///in place. Setting it `true` hands you the suggestion and, with it, the responsibility for
  ///inserting the text into the page: WebKit's header documents no fallback for an implemented
  ///delegate, unlike the open-panel method it sits beside. Same mechanism as
  ///[InAppWebViewSettings.useOnShowFileChooser].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+:
  ///    - Gates the `WKUIDelegate` selector through a `responds(to:)` override, so while it is `false` WebKit does not see the delegate method at all.
  bool? useOnInsertInputSuggestion;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onLoadResource] event.
  ///
  ///If the [PlatformWebViewCreationParams.onLoadResource] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useOnLoadResource;

  ///Set to `true` to be able to listen to the [PlatformWebViewCreationParams.onNavigationResponse] event.
  ///
  ///If the [PlatformWebViewCreationParams.onNavigationResponse] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? useOnNavigationResponse;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onRenderProcessGone] event.
  ///
  ///If the [PlatformWebViewCreationParams.onRenderProcessGone] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? useOnRenderProcessGone;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onShowFileChooser] event.
  ///
  ///If the [PlatformWebViewCreationParams.onShowFileChooser] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**NOTE for iOS**: this setting decides whether the WebView keeps WebKit's own file picker or
  ///hands selection to Dart, and there is no middle ground. While it is `false` the WebView shows
  ///the same picker Safari does; while it is `true` the picker is entirely your
  ///[PlatformWebViewCreationParams.onShowFileChooser] handler's responsibility, and a response with
  ///`handledByClient: false` cancels the upload rather than falling back.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 18.4+:
  ///    - While `false`, the WebView keeps WebKit's built-in file picker. Setting it `true` replaces that picker entirely with the [PlatformWebViewCreationParams.onShowFileChooser] event.
  bool? useOnShowFileChooser;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event implementation,
  ///it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useShouldInterceptFetchRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? useShouldInterceptRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? useShouldOverrideUrlLoading;

  ///Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels.
  ///When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used.
  ///If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUseWideViewPort](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)))
  bool? useWideViewPort;

  ///Sets the user-agent for the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUserAgentString](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  String? userAgent;

  ///Overrides the [User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
  ///this WebView reports.
  ///
  ///Client Hints are the structured replacement for parsing the User-Agent string, which is frozen
  ///and progressively reduced. Prefer this over [userAgent] when you need the *content* to see a
  ///particular brand, platform or device: the hints are what modern sites read, and unlike a
  ///hand-written UA string they stay well-formed.
  ///
  ///Every field of [UserAgentMetadata] is optional, so you can override only the hints you care
  ///about and leave the WebView's own values for the rest.
  ///
  ///Leave `null` to keep the platform default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setUserAgentMetadata](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setUserAgentMetadata(android.webkit.WebSettings,androidx.webkit.UserAgentMetadata))):
  ///    - available on Android only if [WebViewFeature.USER_AGENT_METADATA] feature is supported. [UserAgentMetadata.formFactors] additionally requires [WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS].
  UserAgentMetadata? userAgentMetadata;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsVerticalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/))
  bool? verticalScrollBarEnabled;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollbarPosition](https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)))
  VerticalScrollbarPosition? verticalScrollbarPosition;

  ///Sets the vertical scrollbar thumb color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  Color? verticalScrollbarThumbColor;

  ///Sets the vertical scrollbar track color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  Color? verticalScrollbarTrackColor;

  ///Sets the level of [Web Authentication API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)
  ///support this WebView provides, i.e. whether web content may create and use passkeys.
  ///
  ///Leave `null` to keep the platform default, which is [WebAuthenticationSupport.NONE].
  ///
  ///Use [WebAuthenticationSupport.FOR_APP] for an app signing users in to its own service.
  ///[WebAuthenticationSupport.FOR_BROWSER] is for apps that are themselves a browser and has
  ///additional requirements — read the Android documentation before setting it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setWebAuthenticationSupport](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebAuthenticationSupport(android.webkit.WebSettings,int))):
  ///    - available on Android only if [WebViewFeature.WEB_AUTHENTICATION] feature is supported.
  WebAuthenticationSupport? webAuthenticationSupport;

  ///Use a [WebViewAssetLoader] instance to load local files including application's static assets and resources using http(s):// URLs.
  ///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebViewAssetLoader? webViewAssetLoader;

  ///Sets the [WebView Media Integrity API](https://developer.android.com/privacy-and-security/webview-media-integrity)
  ///configuration for this WebView.
  ///
  ///The API lets a media provider verify that content is being played in a genuine, unmodified
  ///WebView before serving it. The config carries a default status plus optional per-origin
  ///overrides, so one trusted provider can be granted app identity while everything else stays
  ///more restricted.
  ///
  ///Leave `null` to keep the platform default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setWebViewMediaIntegrityApiStatus](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebViewMediaIntegrityApiStatus(android.webkit.WebSettings,androidx.webkit.WebViewMediaIntegrityApiStatusConfig))):
  ///    - available on Android only if [WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS] feature is supported.
  WebViewMediaIntegrityApiStatusConfig? webViewMediaIntegrityApiStatus;

  ///How much of the Apple Intelligence Writing Tools UI this WebView should offer for editable
  ///content.
  ///
  ///Leaving this `null` keeps WebKit's own behaviour, which its documentation describes as
  ///equivalent to [WritingToolsBehavior.LIMITED] — the overlay-panel experience. Set
  ///[WritingToolsBehavior.COMPLETE] for the full inline-editing experience, or
  ///[WritingToolsBehavior.NONE] to opt a WebView out of Writing Tools entirely.
  ///
  ///**NOTE for iOS**: this is a `WKWebViewConfiguration` property, and `WKWebView.configuration` is
  ///documented as *"a copy of the configuration with which the web view was initialized"*. It is
  ///therefore applied **only when the WebView is created** and changing it later through
  ///`setSettings` has no effect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.0+ ([Official API - WKWebViewConfiguration.writingToolsBehavior](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/writingtoolsbehavior)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.
  WritingToolsBehavior? writingToolsBehavior;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  InAppWebViewSettings({
    this.useShouldOverrideUrlLoading,
    this.useOnLoadResource,
    this.useOnDownloadStart,
    this.userAgent = "",
    this.applicationNameForUserAgent = "",
    this.javaScriptEnabled = true,
    this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true,
    this.minimumFontSize,
    this.verticalScrollBarEnabled = true,
    this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [],
    this.contentBlockers = const [],
    this.preferredContentMode = UserPreferredContentMode.RECOMMENDED,
    this.useShouldInterceptAjaxRequest,
    this.useOnAjaxReadyStateChange,
    this.useOnAjaxProgress,
    this.interceptOnlyAsyncAjaxRequests = true,
    this.useShouldInterceptFetchRequest,
    this.incognito = false,
    this.cacheEnabled = true,
    this.transparentBackground = false,
    this.disableVerticalScroll = false,
    this.disableHorizontalScroll = false,
    this.disableContextMenu = false,
    this.supportZoom = true,
    this.allowFileAccessFromFileURLs = false,
    this.allowUniversalAccessFromFileURLs = false,
    this.textZoom,
    this.builtInZoomControls = true,
    this.displayZoomControls = false,
    this.databaseEnabled = true,
    this.domStorageEnabled = true,
    this.useWideViewPort = true,
    this.safeBrowsingEnabled = true,
    this.mixedContentMode,
    this.allowContentAccess = true,
    this.allowFileAccess = true,
    this.appCachePath,
    this.blockNetworkImage = false,
    this.blockNetworkLoads = false,
    this.cacheMode = CacheMode.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive",
    this.defaultFixedFontSize = 16,
    this.defaultFontSize = 16,
    this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems,
    this.fantasyFontFamily = "fantasy",
    this.fixedFontFamily = "monospace",
    this.geolocationEnabled = true,
    this.layoutAlgorithm,
    this.loadWithOverviewMode = true,
    this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8,
    this.needInitialFocus = true,
    this.offscreenPreRaster = false,
    this.sansSerifFontFamily = "sans-serif",
    this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif",
    this.thirdPartyCookiesEnabled = true,
    this.hardwareAcceleration = true,
    this.initialScale = 0,
    this.supportMultipleWindows = false,
    this.regexToCancelSubFramesLoading,
    this.regexToAllowSyncUrlLoading,
    this.useHybridComposition = true,
    this.useShouldInterceptRequest,
    this.syncCallbackTimeoutMillis,
    this.useOnRenderProcessGone,
    this.overScrollMode = OverScrollMode.IF_CONTENT_SCROLLS,
    this.networkAvailable,
    this.scrollBarStyle = ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    this.verticalScrollbarPosition =
        VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    this.scrollBarDefaultDelayBeforeFade,
    this.scrollbarFadingEnabled = true,
    this.scrollBarFadeDuration,
    this.rendererPriorityPolicy,
    this.disableDefaultErrorPage = false,
    this.verticalScrollbarThumbColor,
    this.verticalScrollbarTrackColor,
    this.horizontalScrollbarThumbColor,
    this.horizontalScrollbarTrackColor,
    this.algorithmicDarkeningAllowed = false,
    this.paymentRequestEnabled = false,
    this.webAuthenticationSupport,
    this.downloadFaviconsEnabled,
    this.backForwardCacheEnabled,
    this.attributionRegistrationBehavior,
    this.webViewMediaIntegrityApiStatus,
    this.userAgentMetadata,
    this.profileName,
    this.enterpriseAuthenticationAppLinkPolicyEnabled = true,
    this.defaultVideoPoster,
    this.disallowOverScroll = false,
    this.enableViewportScale = false,
    this.suppressesIncrementalRendering = false,
    this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true,
    this.allowsLinkPreview = true,
    this.ignoresViewportScaleLimits = false,
    this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true,
    this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = SelectionGranularity.DYNAMIC,
    this.dataDetectorTypes = const [DataDetectorTypes.NONE],
    this.sharedCookiesEnabled = false,
    this.automaticallyAdjustsScrollIndicatorInsets = false,
    this.accessibilityIgnoresInvertColors = false,
    this.decelerationRate = ScrollViewDecelerationRate.NORMAL,
    this.alwaysBounceVertical = false,
    this.alwaysBounceHorizontal = false,
    this.scrollsToTop = true,
    this.isPagingEnabled = false,
    this.maximumZoomScale = 1.0,
    this.minimumZoomScale = 1.0,
    this.contentInsetAdjustmentBehavior =
        ScrollViewContentInsetAdjustmentBehavior.NEVER,
    this.isDirectionalLockEnabled = false,
    this.mediaType,
    this.pageZoom = 1.0,
    this.limitsNavigationsToAppBoundDomains = false,
    this.useOnNavigationResponse,
    this.applePayAPIEnabled = false,
    this.allowingReadAccessTo,
    this.disableLongPressContextMenuOnLinks = false,
    this.disableInputAccessoryView = false,
    this.underPageBackgroundColor,
    this.isTextInteractionEnabled = true,
    this.isSiteSpecificQuirksModeEnabled = true,
    this.upgradeKnownHostsToHTTPS = true,
    this.isElementFullscreenEnabled = true,
    this.isFindInteractionEnabled = false,
    this.minimumViewportInset,
    this.maximumViewportInset,
    this.obscuredContentInsets,
    this.isInspectable = false,
    this.shouldPrintBackgrounds = false,
    this.allowBackgroundAudioPlaying = false,
    this.webViewAssetLoader,
    this.javaScriptHandlersOriginAllowList,
    this.javaScriptHandlersForMainFrameOnly,
    this.javaScriptBridgeEnabled = true,
    this.javaScriptBridgeOriginAllowList,
    this.javaScriptBridgeForMainFrameOnly,
    this.pluginScriptsOriginAllowList,
    this.pluginScriptsForMainFrameOnly = false,
    this.isUserInteractionEnabled = true,
    this.alpha,
    this.supportsAdaptiveImageGlyph,
    this.writingToolsBehavior,
    this.preferredHTTPSNavigationPolicy,
    this.securityRestrictionMode,
    this.lockdownModeEnabled,
    this.showsSystemScreenTimeBlockingView = true,
    this.useOnShowFileChooser,
    this.useOnInsertInputSuggestion,
  }) {
    minimumFontSize ??= Util.isAndroid ? 8 : 0;
    assert(
      resourceCustomSchemes == null ||
          (resourceCustomSchemes != null &&
              !resourceCustomSchemes!.contains("http") &&
              !resourceCustomSchemes!.contains("https")),
    );
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo!.isScheme("file"),
    );
    assert(
      (minimumViewportInset == null && maximumViewportInset == null) ||
          minimumViewportInset != null &&
              maximumViewportInset != null &&
              minimumViewportInset!.isNonNegative &&
              maximumViewportInset!.isNonNegative &&
              minimumViewportInset!.vertical <=
                  maximumViewportInset!.vertical &&
              minimumViewportInset!.horizontal <=
                  maximumViewportInset!.horizontal,
      "minimumViewportInset cannot be larger than maximumViewportInset",
    );
    assert(
      obscuredContentInsets == null || obscuredContentInsets!.isNonNegative,
      "obscuredContentInsets must be non-negative on every side",
    );
  }

  ///Gets a possible [InAppWebViewSettings] instance from a [Map] value.
  static InAppWebViewSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewSettings(
      allowingReadAccessTo: map['allowingReadAccessTo'] != null
          ? WebUri(map['allowingReadAccessTo'])
          : null,
      alpha: map['alpha'],
      appCachePath: map['appCachePath'],
      attributionRegistrationBehavior: switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          AttributionRegistrationBehavior.fromNativeValue(
            map['attributionRegistrationBehavior'],
          ),
        EnumMethod.value => AttributionRegistrationBehavior.fromValue(
          map['attributionRegistrationBehavior'],
        ),
        EnumMethod.name => AttributionRegistrationBehavior.byName(
          map['attributionRegistrationBehavior'],
        ),
      },
      backForwardCacheEnabled: map['backForwardCacheEnabled'],
      defaultVideoPoster: map['defaultVideoPoster'] != null
          ? Uint8List.fromList(map['defaultVideoPoster'].cast<int>())
          : null,
      disabledActionModeMenuItems: switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => ActionModeMenuItem.fromNativeValue(
          map['disabledActionModeMenuItems'],
        ),
        EnumMethod.value => ActionModeMenuItem.fromValue(
          map['disabledActionModeMenuItems'],
        ),
        EnumMethod.name => ActionModeMenuItem.byName(
          map['disabledActionModeMenuItems'],
        ),
      },
      downloadFaviconsEnabled: map['downloadFaviconsEnabled'],
      horizontalScrollbarThumbColor:
          map['horizontalScrollbarThumbColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['horizontalScrollbarThumbColor'],
            )
          : null,
      horizontalScrollbarTrackColor:
          map['horizontalScrollbarTrackColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['horizontalScrollbarTrackColor'],
            )
          : null,
      javaScriptBridgeForMainFrameOnly: map['javaScriptBridgeForMainFrameOnly'],
      javaScriptBridgeOriginAllowList:
          map['javaScriptBridgeOriginAllowList'] != null
          ? Set<String>.from(
              map['javaScriptBridgeOriginAllowList']!.cast<String>(),
            )
          : null,
      javaScriptHandlersForMainFrameOnly:
          map['javaScriptHandlersForMainFrameOnly'],
      javaScriptHandlersOriginAllowList:
          map['javaScriptHandlersOriginAllowList'] != null
          ? Set<String>.from(
              map['javaScriptHandlersOriginAllowList']!.cast<String>(),
            )
          : null,
      layoutAlgorithm: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => LayoutAlgorithm.fromNativeValue(
          map['layoutAlgorithm'],
        ),
        EnumMethod.value => LayoutAlgorithm.fromValue(map['layoutAlgorithm']),
        EnumMethod.name => LayoutAlgorithm.byName(map['layoutAlgorithm']),
      },
      lockdownModeEnabled: map['lockdownModeEnabled'],
      maximumViewportInset: MapEdgeInsets.fromMap(
        map['maximumViewportInset']?.cast<String, dynamic>(),
      ),
      mediaType: map['mediaType'],
      minimumFontSize: map['minimumFontSize'],
      minimumViewportInset: MapEdgeInsets.fromMap(
        map['minimumViewportInset']?.cast<String, dynamic>(),
      ),
      mixedContentMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => MixedContentMode.fromNativeValue(
          map['mixedContentMode'],
        ),
        EnumMethod.value => MixedContentMode.fromValue(map['mixedContentMode']),
        EnumMethod.name => MixedContentMode.byName(map['mixedContentMode']),
      },
      networkAvailable: map['networkAvailable'],
      obscuredContentInsets: MapEdgeInsets.fromMap(
        map['obscuredContentInsets']?.cast<String, dynamic>(),
      ),
      pluginScriptsOriginAllowList: map['pluginScriptsOriginAllowList'] != null
          ? Set<String>.from(
              map['pluginScriptsOriginAllowList']!.cast<String>(),
            )
          : null,
      preferredHTTPSNavigationPolicy: switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => UpgradeToHTTPSPolicy.fromNativeValue(
          map['preferredHTTPSNavigationPolicy'],
        ),
        EnumMethod.value => UpgradeToHTTPSPolicy.fromValue(
          map['preferredHTTPSNavigationPolicy'],
        ),
        EnumMethod.name => UpgradeToHTTPSPolicy.byName(
          map['preferredHTTPSNavigationPolicy'],
        ),
      },
      profileName: map['profileName'],
      regexToAllowSyncUrlLoading: map['regexToAllowSyncUrlLoading'],
      regexToCancelSubFramesLoading: map['regexToCancelSubFramesLoading'],
      rendererPriorityPolicy: RendererPriorityPolicy.fromMap(
        map['rendererPriorityPolicy']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      scrollBarDefaultDelayBeforeFade: map['scrollBarDefaultDelayBeforeFade'],
      scrollBarFadeDuration: map['scrollBarFadeDuration'],
      securityRestrictionMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => SecurityRestrictionMode.fromNativeValue(
          map['securityRestrictionMode'],
        ),
        EnumMethod.value => SecurityRestrictionMode.fromValue(
          map['securityRestrictionMode'],
        ),
        EnumMethod.name => SecurityRestrictionMode.byName(
          map['securityRestrictionMode'],
        ),
      },
      supportsAdaptiveImageGlyph: map['supportsAdaptiveImageGlyph'],
      syncCallbackTimeoutMillis: map['syncCallbackTimeoutMillis'],
      textZoom: map['textZoom'],
      underPageBackgroundColor: map['underPageBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['underPageBackgroundColor'])
          : null,
      useOnAjaxProgress: map['useOnAjaxProgress'],
      useOnAjaxReadyStateChange: map['useOnAjaxReadyStateChange'],
      useOnDownloadStart: map['useOnDownloadStart'],
      useOnInsertInputSuggestion: map['useOnInsertInputSuggestion'],
      useOnLoadResource: map['useOnLoadResource'],
      useOnNavigationResponse: map['useOnNavigationResponse'],
      useOnRenderProcessGone: map['useOnRenderProcessGone'],
      useOnShowFileChooser: map['useOnShowFileChooser'],
      useShouldInterceptAjaxRequest: map['useShouldInterceptAjaxRequest'],
      useShouldInterceptFetchRequest: map['useShouldInterceptFetchRequest'],
      useShouldInterceptRequest: map['useShouldInterceptRequest'],
      useShouldOverrideUrlLoading: map['useShouldOverrideUrlLoading'],
      userAgentMetadata: UserAgentMetadata.fromMap(
        map['userAgentMetadata']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      verticalScrollbarThumbColor: map['verticalScrollbarThumbColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['verticalScrollbarThumbColor'],
            )
          : null,
      verticalScrollbarTrackColor: map['verticalScrollbarTrackColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['verticalScrollbarTrackColor'],
            )
          : null,
      webAuthenticationSupport: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WebAuthenticationSupport.fromNativeValue(
          map['webAuthenticationSupport'],
        ),
        EnumMethod.value => WebAuthenticationSupport.fromValue(
          map['webAuthenticationSupport'],
        ),
        EnumMethod.name => WebAuthenticationSupport.byName(
          map['webAuthenticationSupport'],
        ),
      },
      webViewAssetLoader: WebViewAssetLoader.fromMap(
        map['webViewAssetLoader']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      webViewMediaIntegrityApiStatus:
          WebViewMediaIntegrityApiStatusConfig.fromMap(
            map['webViewMediaIntegrityApiStatus']?.cast<String, dynamic>(),
            enumMethod: enumMethod,
          ),
      writingToolsBehavior: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WritingToolsBehavior.fromNativeValue(
          map['writingToolsBehavior'],
        ),
        EnumMethod.value => WritingToolsBehavior.fromValue(
          map['writingToolsBehavior'],
        ),
        EnumMethod.name => WritingToolsBehavior.byName(
          map['writingToolsBehavior'],
        ),
      },
    );
    instance.accessibilityIgnoresInvertColors =
        map['accessibilityIgnoresInvertColors'];
    instance.algorithmicDarkeningAllowed = map['algorithmicDarkeningAllowed'];
    instance.allowBackgroundAudioPlaying = map['allowBackgroundAudioPlaying'];
    instance.allowContentAccess = map['allowContentAccess'];
    instance.allowFileAccess = map['allowFileAccess'];
    instance.allowFileAccessFromFileURLs = map['allowFileAccessFromFileURLs'];
    instance.allowUniversalAccessFromFileURLs =
        map['allowUniversalAccessFromFileURLs'];
    instance.allowsAirPlayForMediaPlayback =
        map['allowsAirPlayForMediaPlayback'];
    instance.allowsBackForwardNavigationGestures =
        map['allowsBackForwardNavigationGestures'];
    instance.allowsInlineMediaPlayback = map['allowsInlineMediaPlayback'];
    instance.allowsLinkPreview = map['allowsLinkPreview'];
    instance.allowsPictureInPictureMediaPlayback =
        map['allowsPictureInPictureMediaPlayback'];
    instance.alwaysBounceHorizontal = map['alwaysBounceHorizontal'];
    instance.alwaysBounceVertical = map['alwaysBounceVertical'];
    instance.applePayAPIEnabled = map['applePayAPIEnabled'];
    instance.applicationNameForUserAgent = map['applicationNameForUserAgent'];
    instance.automaticallyAdjustsScrollIndicatorInsets =
        map['automaticallyAdjustsScrollIndicatorInsets'];
    instance.blockNetworkImage = map['blockNetworkImage'];
    instance.blockNetworkLoads = map['blockNetworkLoads'];
    instance.builtInZoomControls = map['builtInZoomControls'];
    instance.cacheEnabled = map['cacheEnabled'];
    instance.cacheMode = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => CacheMode.fromNativeValue(map['cacheMode']),
      EnumMethod.value => CacheMode.fromValue(map['cacheMode']),
      EnumMethod.name => CacheMode.byName(map['cacheMode']),
    };
    instance.contentBlockers = _deserializeContentBlockers(
      map['contentBlockers'],
      enumMethod: enumMethod,
    );
    instance.contentInsetAdjustmentBehavior = switch (enumMethod ??
        EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ScrollViewContentInsetAdjustmentBehavior.fromNativeValue(
          map['contentInsetAdjustmentBehavior'],
        ),
      EnumMethod.value => ScrollViewContentInsetAdjustmentBehavior.fromValue(
        map['contentInsetAdjustmentBehavior'],
      ),
      EnumMethod.name => ScrollViewContentInsetAdjustmentBehavior.byName(
        map['contentInsetAdjustmentBehavior'],
      ),
    };
    instance.cursiveFontFamily = map['cursiveFontFamily'];
    instance.dataDetectorTypes = map['dataDetectorTypes'] != null
        ? List<DataDetectorTypes>.from(
            map['dataDetectorTypes'].map(
              (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                EnumMethod.nativeValue => DataDetectorTypes.fromNativeValue(e),
                EnumMethod.value => DataDetectorTypes.fromValue(e),
                EnumMethod.name => DataDetectorTypes.byName(e),
              }!,
            ),
          )
        : null;
    instance.databaseEnabled = map['databaseEnabled'];
    instance.decelerationRate = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => ScrollViewDecelerationRate.fromNativeValue(
        map['decelerationRate'],
      ),
      EnumMethod.value => ScrollViewDecelerationRate.fromValue(
        map['decelerationRate'],
      ),
      EnumMethod.name => ScrollViewDecelerationRate.byName(
        map['decelerationRate'],
      ),
    };
    instance.defaultFixedFontSize = map['defaultFixedFontSize'];
    instance.defaultFontSize = map['defaultFontSize'];
    instance.defaultTextEncodingName = map['defaultTextEncodingName'];
    instance.disableContextMenu = map['disableContextMenu'];
    instance.disableDefaultErrorPage = map['disableDefaultErrorPage'];
    instance.disableHorizontalScroll = map['disableHorizontalScroll'];
    instance.disableInputAccessoryView = map['disableInputAccessoryView'];
    instance.disableLongPressContextMenuOnLinks =
        map['disableLongPressContextMenuOnLinks'];
    instance.disableVerticalScroll = map['disableVerticalScroll'];
    instance.disallowOverScroll = map['disallowOverScroll'];
    instance.displayZoomControls = map['displayZoomControls'];
    instance.domStorageEnabled = map['domStorageEnabled'];
    instance.enableViewportScale = map['enableViewportScale'];
    instance.enterpriseAuthenticationAppLinkPolicyEnabled =
        map['enterpriseAuthenticationAppLinkPolicyEnabled'];
    instance.fantasyFontFamily = map['fantasyFontFamily'];
    instance.fixedFontFamily = map['fixedFontFamily'];
    instance.geolocationEnabled = map['geolocationEnabled'];
    instance.hardwareAcceleration = map['hardwareAcceleration'];
    instance.horizontalScrollBarEnabled = map['horizontalScrollBarEnabled'];
    instance.ignoresViewportScaleLimits = map['ignoresViewportScaleLimits'];
    instance.incognito = map['incognito'];
    instance.initialScale = map['initialScale'];
    instance.interceptOnlyAsyncAjaxRequests =
        map['interceptOnlyAsyncAjaxRequests'];
    instance.isDirectionalLockEnabled = map['isDirectionalLockEnabled'];
    instance.isElementFullscreenEnabled = map['isElementFullscreenEnabled'];
    instance.isFindInteractionEnabled = map['isFindInteractionEnabled'];
    instance.isFraudulentWebsiteWarningEnabled =
        map['isFraudulentWebsiteWarningEnabled'];
    instance.isInspectable = map['isInspectable'];
    instance.isPagingEnabled = map['isPagingEnabled'];
    instance.isSiteSpecificQuirksModeEnabled =
        map['isSiteSpecificQuirksModeEnabled'];
    instance.isTextInteractionEnabled = map['isTextInteractionEnabled'];
    instance.isUserInteractionEnabled = map['isUserInteractionEnabled'];
    instance.javaScriptBridgeEnabled = map['javaScriptBridgeEnabled'];
    instance.javaScriptCanOpenWindowsAutomatically =
        map['javaScriptCanOpenWindowsAutomatically'];
    instance.javaScriptEnabled = map['javaScriptEnabled'];
    instance.limitsNavigationsToAppBoundDomains =
        map['limitsNavigationsToAppBoundDomains'];
    instance.loadWithOverviewMode = map['loadWithOverviewMode'];
    instance.loadsImagesAutomatically = map['loadsImagesAutomatically'];
    instance.maximumZoomScale = map['maximumZoomScale'];
    instance.mediaPlaybackRequiresUserGesture =
        map['mediaPlaybackRequiresUserGesture'];
    instance.minimumLogicalFontSize = map['minimumLogicalFontSize'];
    instance.minimumZoomScale = map['minimumZoomScale'];
    instance.needInitialFocus = map['needInitialFocus'];
    instance.offscreenPreRaster = map['offscreenPreRaster'];
    instance.overScrollMode = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => OverScrollMode.fromNativeValue(
        map['overScrollMode'],
      ),
      EnumMethod.value => OverScrollMode.fromValue(map['overScrollMode']),
      EnumMethod.name => OverScrollMode.byName(map['overScrollMode']),
    };
    instance.pageZoom = map['pageZoom'];
    instance.paymentRequestEnabled = map['paymentRequestEnabled'];
    instance.pluginScriptsForMainFrameOnly =
        map['pluginScriptsForMainFrameOnly'];
    instance.preferredContentMode = switch (enumMethod ??
        EnumMethod.nativeValue) {
      EnumMethod.nativeValue => UserPreferredContentMode.fromNativeValue(
        map['preferredContentMode'],
      ),
      EnumMethod.value => UserPreferredContentMode.fromValue(
        map['preferredContentMode'],
      ),
      EnumMethod.name => UserPreferredContentMode.byName(
        map['preferredContentMode'],
      ),
    };
    instance.resourceCustomSchemes = map['resourceCustomSchemes'] != null
        ? List<String>.from(map['resourceCustomSchemes']!.cast<String>())
        : null;
    instance.safeBrowsingEnabled = map['safeBrowsingEnabled'];
    instance.sansSerifFontFamily = map['sansSerifFontFamily'];
    instance.scrollBarStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => ScrollBarStyle.fromNativeValue(
        map['scrollBarStyle'],
      ),
      EnumMethod.value => ScrollBarStyle.fromValue(map['scrollBarStyle']),
      EnumMethod.name => ScrollBarStyle.byName(map['scrollBarStyle']),
    };
    instance.scrollbarFadingEnabled = map['scrollbarFadingEnabled'];
    instance.scrollsToTop = map['scrollsToTop'];
    instance.selectionGranularity = switch (enumMethod ??
        EnumMethod.nativeValue) {
      EnumMethod.nativeValue => SelectionGranularity.fromNativeValue(
        map['selectionGranularity'],
      ),
      EnumMethod.value => SelectionGranularity.fromValue(
        map['selectionGranularity'],
      ),
      EnumMethod.name => SelectionGranularity.byName(
        map['selectionGranularity'],
      ),
    };
    instance.serifFontFamily = map['serifFontFamily'];
    instance.sharedCookiesEnabled = map['sharedCookiesEnabled'];
    instance.shouldPrintBackgrounds = map['shouldPrintBackgrounds'];
    instance.showsSystemScreenTimeBlockingView =
        map['showsSystemScreenTimeBlockingView'];
    instance.standardFontFamily = map['standardFontFamily'];
    instance.supportMultipleWindows = map['supportMultipleWindows'];
    instance.supportZoom = map['supportZoom'];
    instance.suppressesIncrementalRendering =
        map['suppressesIncrementalRendering'];
    instance.thirdPartyCookiesEnabled = map['thirdPartyCookiesEnabled'];
    instance.transparentBackground = map['transparentBackground'];
    instance.upgradeKnownHostsToHTTPS = map['upgradeKnownHostsToHTTPS'];
    instance.useHybridComposition = map['useHybridComposition'];
    instance.useWideViewPort = map['useWideViewPort'];
    instance.userAgent = map['userAgent'];
    instance.verticalScrollBarEnabled = map['verticalScrollBarEnabled'];
    instance.verticalScrollbarPosition = switch (enumMethod ??
        EnumMethod.nativeValue) {
      EnumMethod.nativeValue => VerticalScrollbarPosition.fromNativeValue(
        map['verticalScrollbarPosition'],
      ),
      EnumMethod.value => VerticalScrollbarPosition.fromValue(
        map['verticalScrollbarPosition'],
      ),
      EnumMethod.name => VerticalScrollbarPosition.byName(
        map['verticalScrollbarPosition'],
      ),
    };
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    InAppWebViewSettingsProperty property, {
    TargetPlatform? platform,
  }) => _InAppWebViewSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "accessibilityIgnoresInvertColors": accessibilityIgnoresInvertColors,
      "algorithmicDarkeningAllowed": algorithmicDarkeningAllowed,
      "allowBackgroundAudioPlaying": allowBackgroundAudioPlaying,
      "allowContentAccess": allowContentAccess,
      "allowFileAccess": allowFileAccess,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
      "allowingReadAccessTo": allowingReadAccessTo?.toString(),
      "allowsAirPlayForMediaPlayback": allowsAirPlayForMediaPlayback,
      "allowsBackForwardNavigationGestures":
          allowsBackForwardNavigationGestures,
      "allowsInlineMediaPlayback": allowsInlineMediaPlayback,
      "allowsLinkPreview": allowsLinkPreview,
      "allowsPictureInPictureMediaPlayback":
          allowsPictureInPictureMediaPlayback,
      "alpha": alpha,
      "alwaysBounceHorizontal": alwaysBounceHorizontal,
      "alwaysBounceVertical": alwaysBounceVertical,
      "appCachePath": appCachePath,
      "applePayAPIEnabled": applePayAPIEnabled,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "attributionRegistrationBehavior": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          attributionRegistrationBehavior?.toNativeValue(),
        EnumMethod.value => attributionRegistrationBehavior?.toValue(),
        EnumMethod.name => attributionRegistrationBehavior?.name(),
      },
      "automaticallyAdjustsScrollIndicatorInsets":
          automaticallyAdjustsScrollIndicatorInsets,
      "backForwardCacheEnabled": backForwardCacheEnabled,
      "blockNetworkImage": blockNetworkImage,
      "blockNetworkLoads": blockNetworkLoads,
      "builtInZoomControls": builtInZoomControls,
      "cacheEnabled": cacheEnabled,
      "cacheMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => cacheMode?.toNativeValue(),
        EnumMethod.value => cacheMode?.toValue(),
        EnumMethod.name => cacheMode?.name(),
      },
      "contentBlockers": contentBlockers
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "contentInsetAdjustmentBehavior": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          contentInsetAdjustmentBehavior?.toNativeValue(),
        EnumMethod.value => contentInsetAdjustmentBehavior?.toValue(),
        EnumMethod.name => contentInsetAdjustmentBehavior?.name(),
      },
      "cursiveFontFamily": cursiveFontFamily,
      "dataDetectorTypes": dataDetectorTypes
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "databaseEnabled": databaseEnabled,
      "decelerationRate": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => decelerationRate?.toNativeValue(),
        EnumMethod.value => decelerationRate?.toValue(),
        EnumMethod.name => decelerationRate?.name(),
      },
      "defaultFixedFontSize": defaultFixedFontSize,
      "defaultFontSize": defaultFontSize,
      "defaultTextEncodingName": defaultTextEncodingName,
      "defaultVideoPoster": defaultVideoPoster,
      "disableContextMenu": disableContextMenu,
      "disableDefaultErrorPage": disableDefaultErrorPage,
      "disableHorizontalScroll": disableHorizontalScroll,
      "disableInputAccessoryView": disableInputAccessoryView,
      "disableLongPressContextMenuOnLinks": disableLongPressContextMenuOnLinks,
      "disableVerticalScroll": disableVerticalScroll,
      "disabledActionModeMenuItems": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => disabledActionModeMenuItems?.toNativeValue(),
        EnumMethod.value => disabledActionModeMenuItems?.toValue(),
        EnumMethod.name => disabledActionModeMenuItems?.name(),
      },
      "disallowOverScroll": disallowOverScroll,
      "displayZoomControls": displayZoomControls,
      "domStorageEnabled": domStorageEnabled,
      "downloadFaviconsEnabled": downloadFaviconsEnabled,
      "enableViewportScale": enableViewportScale,
      "enterpriseAuthenticationAppLinkPolicyEnabled":
          enterpriseAuthenticationAppLinkPolicyEnabled,
      "fantasyFontFamily": fantasyFontFamily,
      "fixedFontFamily": fixedFontFamily,
      "geolocationEnabled": geolocationEnabled,
      "hardwareAcceleration": hardwareAcceleration,
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "horizontalScrollbarThumbColor": horizontalScrollbarThumbColor?.toHex(),
      "horizontalScrollbarTrackColor": horizontalScrollbarTrackColor?.toHex(),
      "ignoresViewportScaleLimits": ignoresViewportScaleLimits,
      "incognito": incognito,
      "initialScale": initialScale,
      "interceptOnlyAsyncAjaxRequests": interceptOnlyAsyncAjaxRequests,
      "isDirectionalLockEnabled": isDirectionalLockEnabled,
      "isElementFullscreenEnabled": isElementFullscreenEnabled,
      "isFindInteractionEnabled": isFindInteractionEnabled,
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "isInspectable": isInspectable,
      "isPagingEnabled": isPagingEnabled,
      "isSiteSpecificQuirksModeEnabled": isSiteSpecificQuirksModeEnabled,
      "isTextInteractionEnabled": isTextInteractionEnabled,
      "isUserInteractionEnabled": isUserInteractionEnabled,
      "javaScriptBridgeEnabled": javaScriptBridgeEnabled,
      "javaScriptBridgeForMainFrameOnly": javaScriptBridgeForMainFrameOnly,
      "javaScriptBridgeOriginAllowList": javaScriptBridgeOriginAllowList
          ?.toList(),
      "javaScriptCanOpenWindowsAutomatically":
          javaScriptCanOpenWindowsAutomatically,
      "javaScriptEnabled": javaScriptEnabled,
      "javaScriptHandlersForMainFrameOnly": javaScriptHandlersForMainFrameOnly,
      "javaScriptHandlersOriginAllowList": javaScriptHandlersOriginAllowList
          ?.toList(),
      "layoutAlgorithm": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => layoutAlgorithm?.toNativeValue(),
        EnumMethod.value => layoutAlgorithm?.toValue(),
        EnumMethod.name => layoutAlgorithm?.name(),
      },
      "limitsNavigationsToAppBoundDomains": limitsNavigationsToAppBoundDomains,
      "loadWithOverviewMode": loadWithOverviewMode,
      "loadsImagesAutomatically": loadsImagesAutomatically,
      "lockdownModeEnabled": lockdownModeEnabled,
      "maximumViewportInset": maximumViewportInset?.toMap(),
      "maximumZoomScale": maximumZoomScale,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "mediaType": mediaType,
      "minimumFontSize": minimumFontSize,
      "minimumLogicalFontSize": minimumLogicalFontSize,
      "minimumViewportInset": minimumViewportInset?.toMap(),
      "minimumZoomScale": minimumZoomScale,
      "mixedContentMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => mixedContentMode?.toNativeValue(),
        EnumMethod.value => mixedContentMode?.toValue(),
        EnumMethod.name => mixedContentMode?.name(),
      },
      "needInitialFocus": needInitialFocus,
      "networkAvailable": networkAvailable,
      "obscuredContentInsets": obscuredContentInsets?.toMap(),
      "offscreenPreRaster": offscreenPreRaster,
      "overScrollMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => overScrollMode?.toNativeValue(),
        EnumMethod.value => overScrollMode?.toValue(),
        EnumMethod.name => overScrollMode?.name(),
      },
      "pageZoom": pageZoom,
      "paymentRequestEnabled": paymentRequestEnabled,
      "pluginScriptsForMainFrameOnly": pluginScriptsForMainFrameOnly,
      "pluginScriptsOriginAllowList": pluginScriptsOriginAllowList?.toList(),
      "preferredContentMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => preferredContentMode?.toNativeValue(),
        EnumMethod.value => preferredContentMode?.toValue(),
        EnumMethod.name => preferredContentMode?.name(),
      },
      "preferredHTTPSNavigationPolicy": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          preferredHTTPSNavigationPolicy?.toNativeValue(),
        EnumMethod.value => preferredHTTPSNavigationPolicy?.toValue(),
        EnumMethod.name => preferredHTTPSNavigationPolicy?.name(),
      },
      "profileName": profileName,
      "regexToAllowSyncUrlLoading": regexToAllowSyncUrlLoading,
      "regexToCancelSubFramesLoading": regexToCancelSubFramesLoading,
      "rendererPriorityPolicy": rendererPriorityPolicy?.toMap(
        enumMethod: enumMethod,
      ),
      "resourceCustomSchemes": resourceCustomSchemes,
      "safeBrowsingEnabled": safeBrowsingEnabled,
      "sansSerifFontFamily": sansSerifFontFamily,
      "scrollBarDefaultDelayBeforeFade": scrollBarDefaultDelayBeforeFade,
      "scrollBarFadeDuration": scrollBarFadeDuration,
      "scrollBarStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => scrollBarStyle?.toNativeValue(),
        EnumMethod.value => scrollBarStyle?.toValue(),
        EnumMethod.name => scrollBarStyle?.name(),
      },
      "scrollbarFadingEnabled": scrollbarFadingEnabled,
      "scrollsToTop": scrollsToTop,
      "securityRestrictionMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => securityRestrictionMode?.toNativeValue(),
        EnumMethod.value => securityRestrictionMode?.toValue(),
        EnumMethod.name => securityRestrictionMode?.name(),
      },
      "selectionGranularity": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => selectionGranularity?.toNativeValue(),
        EnumMethod.value => selectionGranularity?.toValue(),
        EnumMethod.name => selectionGranularity?.name(),
      },
      "serifFontFamily": serifFontFamily,
      "sharedCookiesEnabled": sharedCookiesEnabled,
      "shouldPrintBackgrounds": shouldPrintBackgrounds,
      "showsSystemScreenTimeBlockingView": showsSystemScreenTimeBlockingView,
      "standardFontFamily": standardFontFamily,
      "supportMultipleWindows": supportMultipleWindows,
      "supportZoom": supportZoom,
      "supportsAdaptiveImageGlyph": supportsAdaptiveImageGlyph,
      "suppressesIncrementalRendering": suppressesIncrementalRendering,
      "syncCallbackTimeoutMillis": syncCallbackTimeoutMillis,
      "textZoom": textZoom,
      "thirdPartyCookiesEnabled": thirdPartyCookiesEnabled,
      "transparentBackground": transparentBackground,
      "underPageBackgroundColor": underPageBackgroundColor?.toHex(),
      "upgradeKnownHostsToHTTPS": upgradeKnownHostsToHTTPS,
      "useHybridComposition": useHybridComposition,
      "useOnAjaxProgress": useOnAjaxProgress,
      "useOnAjaxReadyStateChange": useOnAjaxReadyStateChange,
      "useOnDownloadStart": useOnDownloadStart,
      "useOnInsertInputSuggestion": useOnInsertInputSuggestion,
      "useOnLoadResource": useOnLoadResource,
      "useOnNavigationResponse": useOnNavigationResponse,
      "useOnRenderProcessGone": useOnRenderProcessGone,
      "useOnShowFileChooser": useOnShowFileChooser,
      "useShouldInterceptAjaxRequest": useShouldInterceptAjaxRequest,
      "useShouldInterceptFetchRequest": useShouldInterceptFetchRequest,
      "useShouldInterceptRequest": useShouldInterceptRequest,
      "useShouldOverrideUrlLoading": useShouldOverrideUrlLoading,
      "useWideViewPort": useWideViewPort,
      "userAgent": userAgent,
      "userAgentMetadata": userAgentMetadata?.toMap(enumMethod: enumMethod),
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "verticalScrollbarPosition": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => verticalScrollbarPosition?.toNativeValue(),
        EnumMethod.value => verticalScrollbarPosition?.toValue(),
        EnumMethod.name => verticalScrollbarPosition?.name(),
      },
      "verticalScrollbarThumbColor": verticalScrollbarThumbColor?.toHex(),
      "verticalScrollbarTrackColor": verticalScrollbarTrackColor?.toHex(),
      "webAuthenticationSupport": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => webAuthenticationSupport?.toNativeValue(),
        EnumMethod.value => webAuthenticationSupport?.toValue(),
        EnumMethod.name => webAuthenticationSupport?.name(),
      },
      "webViewAssetLoader": webViewAssetLoader?.toMap(enumMethod: enumMethod),
      "webViewMediaIntegrityApiStatus": webViewMediaIntegrityApiStatus?.toMap(
        enumMethod: enumMethod,
      ),
      "writingToolsBehavior": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => writingToolsBehavior?.toNativeValue(),
        EnumMethod.value => writingToolsBehavior?.toValue(),
        EnumMethod.name => writingToolsBehavior?.name(),
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of InAppWebViewSettings.
  InAppWebViewSettings copy() {
    return InAppWebViewSettings.fromMap(toMap()) ?? InAppWebViewSettings();
  }

  @override
  String toString() {
    return 'InAppWebViewSettings{accessibilityIgnoresInvertColors: $accessibilityIgnoresInvertColors, algorithmicDarkeningAllowed: $algorithmicDarkeningAllowed, allowBackgroundAudioPlaying: $allowBackgroundAudioPlaying, allowContentAccess: $allowContentAccess, allowFileAccess: $allowFileAccess, allowFileAccessFromFileURLs: $allowFileAccessFromFileURLs, allowUniversalAccessFromFileURLs: $allowUniversalAccessFromFileURLs, allowingReadAccessTo: $allowingReadAccessTo, allowsAirPlayForMediaPlayback: $allowsAirPlayForMediaPlayback, allowsBackForwardNavigationGestures: $allowsBackForwardNavigationGestures, allowsInlineMediaPlayback: $allowsInlineMediaPlayback, allowsLinkPreview: $allowsLinkPreview, allowsPictureInPictureMediaPlayback: $allowsPictureInPictureMediaPlayback, alpha: $alpha, alwaysBounceHorizontal: $alwaysBounceHorizontal, alwaysBounceVertical: $alwaysBounceVertical, appCachePath: $appCachePath, applePayAPIEnabled: $applePayAPIEnabled, applicationNameForUserAgent: $applicationNameForUserAgent, attributionRegistrationBehavior: $attributionRegistrationBehavior, automaticallyAdjustsScrollIndicatorInsets: $automaticallyAdjustsScrollIndicatorInsets, backForwardCacheEnabled: $backForwardCacheEnabled, blockNetworkImage: $blockNetworkImage, blockNetworkLoads: $blockNetworkLoads, builtInZoomControls: $builtInZoomControls, cacheEnabled: $cacheEnabled, cacheMode: $cacheMode, contentBlockers: $contentBlockers, contentInsetAdjustmentBehavior: $contentInsetAdjustmentBehavior, cursiveFontFamily: $cursiveFontFamily, dataDetectorTypes: $dataDetectorTypes, databaseEnabled: $databaseEnabled, decelerationRate: $decelerationRate, defaultFixedFontSize: $defaultFixedFontSize, defaultFontSize: $defaultFontSize, defaultTextEncodingName: $defaultTextEncodingName, defaultVideoPoster: $defaultVideoPoster, disableContextMenu: $disableContextMenu, disableDefaultErrorPage: $disableDefaultErrorPage, disableHorizontalScroll: $disableHorizontalScroll, disableInputAccessoryView: $disableInputAccessoryView, disableLongPressContextMenuOnLinks: $disableLongPressContextMenuOnLinks, disableVerticalScroll: $disableVerticalScroll, disabledActionModeMenuItems: $disabledActionModeMenuItems, disallowOverScroll: $disallowOverScroll, displayZoomControls: $displayZoomControls, domStorageEnabled: $domStorageEnabled, downloadFaviconsEnabled: $downloadFaviconsEnabled, enableViewportScale: $enableViewportScale, enterpriseAuthenticationAppLinkPolicyEnabled: $enterpriseAuthenticationAppLinkPolicyEnabled, fantasyFontFamily: $fantasyFontFamily, fixedFontFamily: $fixedFontFamily, geolocationEnabled: $geolocationEnabled, hardwareAcceleration: $hardwareAcceleration, horizontalScrollBarEnabled: $horizontalScrollBarEnabled, horizontalScrollbarThumbColor: $horizontalScrollbarThumbColor, horizontalScrollbarTrackColor: $horizontalScrollbarTrackColor, ignoresViewportScaleLimits: $ignoresViewportScaleLimits, incognito: $incognito, initialScale: $initialScale, interceptOnlyAsyncAjaxRequests: $interceptOnlyAsyncAjaxRequests, isDirectionalLockEnabled: $isDirectionalLockEnabled, isElementFullscreenEnabled: $isElementFullscreenEnabled, isFindInteractionEnabled: $isFindInteractionEnabled, isFraudulentWebsiteWarningEnabled: $isFraudulentWebsiteWarningEnabled, isInspectable: $isInspectable, isPagingEnabled: $isPagingEnabled, isSiteSpecificQuirksModeEnabled: $isSiteSpecificQuirksModeEnabled, isTextInteractionEnabled: $isTextInteractionEnabled, isUserInteractionEnabled: $isUserInteractionEnabled, javaScriptBridgeEnabled: $javaScriptBridgeEnabled, javaScriptBridgeForMainFrameOnly: $javaScriptBridgeForMainFrameOnly, javaScriptBridgeOriginAllowList: $javaScriptBridgeOriginAllowList, javaScriptCanOpenWindowsAutomatically: $javaScriptCanOpenWindowsAutomatically, javaScriptEnabled: $javaScriptEnabled, javaScriptHandlersForMainFrameOnly: $javaScriptHandlersForMainFrameOnly, javaScriptHandlersOriginAllowList: $javaScriptHandlersOriginAllowList, layoutAlgorithm: $layoutAlgorithm, limitsNavigationsToAppBoundDomains: $limitsNavigationsToAppBoundDomains, loadWithOverviewMode: $loadWithOverviewMode, loadsImagesAutomatically: $loadsImagesAutomatically, lockdownModeEnabled: $lockdownModeEnabled, maximumViewportInset: $maximumViewportInset, maximumZoomScale: $maximumZoomScale, mediaPlaybackRequiresUserGesture: $mediaPlaybackRequiresUserGesture, mediaType: $mediaType, minimumFontSize: $minimumFontSize, minimumLogicalFontSize: $minimumLogicalFontSize, minimumViewportInset: $minimumViewportInset, minimumZoomScale: $minimumZoomScale, mixedContentMode: $mixedContentMode, needInitialFocus: $needInitialFocus, networkAvailable: $networkAvailable, obscuredContentInsets: $obscuredContentInsets, offscreenPreRaster: $offscreenPreRaster, overScrollMode: $overScrollMode, pageZoom: $pageZoom, paymentRequestEnabled: $paymentRequestEnabled, pluginScriptsForMainFrameOnly: $pluginScriptsForMainFrameOnly, pluginScriptsOriginAllowList: $pluginScriptsOriginAllowList, preferredContentMode: $preferredContentMode, preferredHTTPSNavigationPolicy: $preferredHTTPSNavigationPolicy, profileName: $profileName, regexToAllowSyncUrlLoading: $regexToAllowSyncUrlLoading, regexToCancelSubFramesLoading: $regexToCancelSubFramesLoading, rendererPriorityPolicy: $rendererPriorityPolicy, resourceCustomSchemes: $resourceCustomSchemes, safeBrowsingEnabled: $safeBrowsingEnabled, sansSerifFontFamily: $sansSerifFontFamily, scrollBarDefaultDelayBeforeFade: $scrollBarDefaultDelayBeforeFade, scrollBarFadeDuration: $scrollBarFadeDuration, scrollBarStyle: $scrollBarStyle, scrollbarFadingEnabled: $scrollbarFadingEnabled, scrollsToTop: $scrollsToTop, securityRestrictionMode: $securityRestrictionMode, selectionGranularity: $selectionGranularity, serifFontFamily: $serifFontFamily, sharedCookiesEnabled: $sharedCookiesEnabled, shouldPrintBackgrounds: $shouldPrintBackgrounds, showsSystemScreenTimeBlockingView: $showsSystemScreenTimeBlockingView, standardFontFamily: $standardFontFamily, supportMultipleWindows: $supportMultipleWindows, supportZoom: $supportZoom, supportsAdaptiveImageGlyph: $supportsAdaptiveImageGlyph, suppressesIncrementalRendering: $suppressesIncrementalRendering, syncCallbackTimeoutMillis: $syncCallbackTimeoutMillis, textZoom: $textZoom, thirdPartyCookiesEnabled: $thirdPartyCookiesEnabled, transparentBackground: $transparentBackground, underPageBackgroundColor: $underPageBackgroundColor, upgradeKnownHostsToHTTPS: $upgradeKnownHostsToHTTPS, useHybridComposition: $useHybridComposition, useOnAjaxProgress: $useOnAjaxProgress, useOnAjaxReadyStateChange: $useOnAjaxReadyStateChange, useOnDownloadStart: $useOnDownloadStart, useOnInsertInputSuggestion: $useOnInsertInputSuggestion, useOnLoadResource: $useOnLoadResource, useOnNavigationResponse: $useOnNavigationResponse, useOnRenderProcessGone: $useOnRenderProcessGone, useOnShowFileChooser: $useOnShowFileChooser, useShouldInterceptAjaxRequest: $useShouldInterceptAjaxRequest, useShouldInterceptFetchRequest: $useShouldInterceptFetchRequest, useShouldInterceptRequest: $useShouldInterceptRequest, useShouldOverrideUrlLoading: $useShouldOverrideUrlLoading, useWideViewPort: $useWideViewPort, userAgent: $userAgent, userAgentMetadata: $userAgentMetadata, verticalScrollBarEnabled: $verticalScrollBarEnabled, verticalScrollbarPosition: $verticalScrollbarPosition, verticalScrollbarThumbColor: $verticalScrollbarThumbColor, verticalScrollbarTrackColor: $verticalScrollbarTrackColor, webAuthenticationSupport: $webAuthenticationSupport, webViewAssetLoader: $webViewAssetLoader, webViewMediaIntegrityApiStatus: $webViewMediaIntegrityApiStatus, writingToolsBehavior: $writingToolsBehavior}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [InAppWebViewSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum InAppWebViewSettingsProperty {
  ///Can be used to check if the [InAppWebViewSettings.accessibilityIgnoresInvertColors] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.accessibilityIgnoresInvertColors.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIView.accessibilityIgnoresInvertColors](https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  accessibilityIgnoresInvertColors,

  ///Can be used to check if the [InAppWebViewSettings.algorithmicDarkeningAllowed] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.algorithmicDarkeningAllowed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettingsCompat.setAlgorithmicDarkeningAllowed](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  algorithmicDarkeningAllowed,

  ///Can be used to check if the [InAppWebViewSettings.allowBackgroundAudioPlaying] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowBackgroundAudioPlaying.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowBackgroundAudioPlaying,

  ///Can be used to check if the [InAppWebViewSettings.allowContentAccess] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowContentAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowContentAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowContentAccess,

  ///Can be used to check if the [InAppWebViewSettings.allowFileAccess] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowFileAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowFileAccess,

  ///Can be used to check if the [InAppWebViewSettings.allowFileAccessFromFileURLs] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowFileAccessFromFileURLs.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowFileAccessFromFileURLs,

  ///Can be used to check if the [InAppWebViewSettings.allowUniversalAccessFromFileURLs] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowUniversalAccessFromFileURLs.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowUniversalAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)))
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowUniversalAccessFromFileURLs,

  ///Can be used to check if the [InAppWebViewSettings.allowingReadAccessTo] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowingReadAccessTo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowingReadAccessTo,

  ///Can be used to check if the [InAppWebViewSettings.allowsAirPlayForMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsAirPlayForMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsAirPlayForMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.allowsBackForwardNavigationGestures] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsBackForwardNavigationGestures.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsBackForwardNavigationGestures,

  ///Can be used to check if the [InAppWebViewSettings.allowsInlineMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsInlineMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsInlineMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsInlineMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.allowsLinkPreview] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsLinkPreview.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsLinkPreview,

  ///Can be used to check if the [InAppWebViewSettings.allowsPictureInPictureMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsPictureInPictureMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsPictureInPictureMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsPictureInPictureMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.alpha] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alpha.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setAlpha](https://developer.android.com/reference/android/view/View#setAlpha(float)))
  ///- iOS WKWebView ([Official API - UIView.alpha](https://developer.apple.com/documentation/uikit/uiview/1622417-alpha))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alpha,

  ///Can be used to check if the [InAppWebViewSettings.alwaysBounceHorizontal] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alwaysBounceHorizontal.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceHorizontal](https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alwaysBounceHorizontal,

  ///Can be used to check if the [InAppWebViewSettings.alwaysBounceVertical] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alwaysBounceVertical.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceVertical](https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alwaysBounceVertical,

  ///Can be used to check if the [InAppWebViewSettings.appCachePath] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.appCachePath.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView (Official API - WebSettings.setAppCachePath)
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  appCachePath,

  ///Can be used to check if the [InAppWebViewSettings.applePayAPIEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.applePayAPIEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  applePayAPIEnabled,

  ///Can be used to check if the [InAppWebViewSettings.applicationNameForUserAgent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.applicationNameForUserAgent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `userAgent` instead, which is applied to the live WebView and does respond to `setSettings`.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  applicationNameForUserAgent,

  ///Can be used to check if the [InAppWebViewSettings.attributionRegistrationBehavior] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.attributionRegistrationBehavior.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setAttributionRegistrationBehavior](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAttributionRegistrationBehavior(android.webkit.WebSettings,int))):
  ///    - available on Android only if [WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  attributionRegistrationBehavior,

  ///Can be used to check if the [InAppWebViewSettings.automaticallyAdjustsScrollIndicatorInsets] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.automaticallyAdjustsScrollIndicatorInsets.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - UIScrollView.automaticallyAdjustsScrollIndicatorInsets](https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  automaticallyAdjustsScrollIndicatorInsets,

  ///Can be used to check if the [InAppWebViewSettings.backForwardCacheEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.backForwardCacheEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setBackForwardCacheEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setBackForwardCacheEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.BACK_FORWARD_CACHE] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  backForwardCacheEnabled,

  ///Can be used to check if the [InAppWebViewSettings.blockNetworkImage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.blockNetworkImage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkImage](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  blockNetworkImage,

  ///Can be used to check if the [InAppWebViewSettings.blockNetworkLoads] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.blockNetworkLoads.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkLoads](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  blockNetworkLoads,

  ///Can be used to check if the [InAppWebViewSettings.builtInZoomControls] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.builtInZoomControls.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBuiltInZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  builtInZoomControls,

  ///Can be used to check if the [InAppWebViewSettings.cacheEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cacheEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cacheEnabled,

  ///Can be used to check if the [InAppWebViewSettings.cacheMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cacheMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCacheMode](https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cacheMode,

  ///Can be used to check if the [InAppWebViewSettings.contentBlockers] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.contentBlockers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  contentBlockers,

  ///Can be used to check if the [InAppWebViewSettings.contentInsetAdjustmentBehavior] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.contentInsetAdjustmentBehavior.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIScrollView.contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  contentInsetAdjustmentBehavior,

  ///Can be used to check if the [InAppWebViewSettings.cursiveFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cursiveFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCursiveFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cursiveFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.dataDetectorTypes] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.dataDetectorTypes.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 10+ ([Official API - WKWebViewConfiguration.dataDetectorTypes](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  dataDetectorTypes,

  ///Can be used to check if the [InAppWebViewSettings.databaseEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.databaseEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDatabaseEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  databaseEnabled,

  ///Can be used to check if the [InAppWebViewSettings.decelerationRate] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.decelerationRate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.decelerationRate](https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  decelerationRate,

  ///Can be used to check if the [InAppWebViewSettings.defaultFixedFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultFixedFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFixedFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultFixedFontSize,

  ///Can be used to check if the [InAppWebViewSettings.defaultFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultFontSize,

  ///Can be used to check if the [InAppWebViewSettings.defaultTextEncodingName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultTextEncodingName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultTextEncodingName](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultTextEncodingName,

  ///Can be used to check if the [InAppWebViewSettings.defaultVideoPoster] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultVideoPoster.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultVideoPoster,

  ///Can be used to check if the [InAppWebViewSettings.disableContextMenu] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableContextMenu.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableContextMenu,

  ///Can be used to check if the [InAppWebViewSettings.disableDefaultErrorPage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableDefaultErrorPage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableDefaultErrorPage,

  ///Can be used to check if the [InAppWebViewSettings.disableHorizontalScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableHorizontalScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableHorizontalScroll,

  ///Can be used to check if the [InAppWebViewSettings.disableInputAccessoryView] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableInputAccessoryView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableInputAccessoryView,

  ///Can be used to check if the [InAppWebViewSettings.disableLongPressContextMenuOnLinks] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableLongPressContextMenuOnLinks.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableLongPressContextMenuOnLinks,

  ///Can be used to check if the [InAppWebViewSettings.disableVerticalScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableVerticalScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableVerticalScroll,

  ///Can be used to check if the [InAppWebViewSettings.disabledActionModeMenuItems] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disabledActionModeMenuItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 24+ ([Official API - WebSettings.setDisabledActionModeMenuItems](https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disabledActionModeMenuItems,

  ///Can be used to check if the [InAppWebViewSettings.disallowOverScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disallowOverScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disallowOverScroll,

  ///Can be used to check if the [InAppWebViewSettings.displayZoomControls] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.displayZoomControls.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDisplayZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  displayZoomControls,

  ///Can be used to check if the [InAppWebViewSettings.domStorageEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.domStorageEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDomStorageEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  domStorageEnabled,

  ///Can be used to check if the [InAppWebViewSettings.downloadFaviconsEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.downloadFaviconsEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setDownloadFaviconsEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setDownloadFaviconsEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.DOWNLOAD_FAVICONS_ENABLED] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  downloadFaviconsEnabled,

  ///Can be used to check if the [InAppWebViewSettings.enableViewportScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.enableViewportScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enableViewportScale,

  ///Can be used to check if the [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enterpriseAuthenticationAppLinkPolicyEnabled,

  ///Can be used to check if the [InAppWebViewSettings.fantasyFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.fantasyFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFantasyFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  fantasyFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.fixedFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.fixedFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFixedFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  fixedFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.geolocationEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.geolocationEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setGeolocationEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean))):
  ///    - Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met: - an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION); - an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  geolocationEnabled,

  ///Can be used to check if the [InAppWebViewSettings.hardwareAcceleration] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.hardwareAcceleration.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setLayerType](https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hardwareAcceleration,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollBarEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollBarEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setHorizontalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsHorizontalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollBarEnabled,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollbarThumbColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollbarThumbColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollbarThumbColor,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollbarTrackColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollbarTrackColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollbarTrackColor,

  ///Can be used to check if the [InAppWebViewSettings.ignoresViewportScaleLimits] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.ignoresViewportScaleLimits.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.ignoresViewportScaleLimits](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  ignoresViewportScaleLimits,

  ///Can be used to check if the [InAppWebViewSettings.incognito] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.incognito.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - setting this to `true`, it will clear all the cookies of all WebView instances, because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
  ///- iOS WKWebView:
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  incognito,

  ///Can be used to check if the [InAppWebViewSettings.initialScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.initialScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setInitialScale](https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  initialScale,

  ///Can be used to check if the [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.interceptOnlyAsyncAjaxRequests.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  interceptOnlyAsyncAjaxRequests,

  ///Can be used to check if the [InAppWebViewSettings.isDirectionalLockEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isDirectionalLockEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isDirectionalLockEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isDirectionalLockEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isElementFullscreenEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isElementFullscreenEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isElementFullscreenEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isFindInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isFindInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebView.isFindInteractionEnabled](https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isFindInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isFraudulentWebsiteWarningEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isFraudulentWebsiteWarningEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isInspectable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isInspectable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isInspectable,

  ///Can be used to check if the [InAppWebViewSettings.isPagingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isPagingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isPagingEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isPagingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isSiteSpecificQuirksModeEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isSiteSpecificQuirksModeEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isSiteSpecificQuirksModeEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isTextInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isTextInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isTextInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isUserInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isUserInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIView.isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isUserInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptCanOpenWindowsAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)))
  ///- iOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptCanOpenWindowsAutomatically,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)))
  ///- iOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptHandlersForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptHandlersForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptHandlersForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptHandlersOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptHandlersOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptHandlersOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.layoutAlgorithm] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.layoutAlgorithm.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLayoutAlgorithm](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  layoutAlgorithm,

  ///Can be used to check if the [InAppWebViewSettings.limitsNavigationsToAppBoundDomains] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.limitsNavigationsToAppBoundDomains.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  limitsNavigationsToAppBoundDomains,

  ///Can be used to check if the [InAppWebViewSettings.loadWithOverviewMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.loadWithOverviewMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadWithOverviewMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  loadWithOverviewMode,

  ///Can be used to check if the [InAppWebViewSettings.loadsImagesAutomatically] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.loadsImagesAutomatically.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadsImagesAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  loadsImagesAutomatically,

  ///Can be used to check if the [InAppWebViewSettings.lockdownModeEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.lockdownModeEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebpagePreferences.lockdownModeEnabled](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/islockdownmodeenabled)):
  ///    - Defaults to the device's system setting. Passing `false` overrides a user who enabled Lockdown Mode.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  lockdownModeEnabled,

  ///Can be used to check if the [InAppWebViewSettings.maximumViewportInset] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.maximumViewportInset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumViewportInset,

  ///Can be used to check if the [InAppWebViewSettings.maximumZoomScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.maximumZoomScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.maximumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumZoomScale,

  ///Can be used to check if the [InAppWebViewSettings.mediaPlaybackRequiresUserGesture] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mediaPlaybackRequiresUserGesture.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMediaPlaybackRequiresUserGesture](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)))
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaPlaybackRequiresUserGesture,

  ///Can be used to check if the [InAppWebViewSettings.mediaType] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mediaType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaType,

  ///Can be used to check if the [InAppWebViewSettings.minimumFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)))
  ///- iOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumFontSize,

  ///Can be used to check if the [InAppWebViewSettings.minimumLogicalFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumLogicalFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumLogicalFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumLogicalFontSize,

  ///Can be used to check if the [InAppWebViewSettings.minimumViewportInset] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumViewportInset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumViewportInset,

  ///Can be used to check if the [InAppWebViewSettings.minimumZoomScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumZoomScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.minimumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumZoomScale,

  ///Can be used to check if the [InAppWebViewSettings.mixedContentMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mixedContentMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebSettings.setMixedContentMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mixedContentMode,

  ///Can be used to check if the [InAppWebViewSettings.needInitialFocus] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.needInitialFocus.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setNeedInitialFocus](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  needInitialFocus,

  ///Can be used to check if the [InAppWebViewSettings.networkAvailable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.networkAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setNetworkAvailable](https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  networkAvailable,

  ///Can be used to check if the [InAppWebViewSettings.obscuredContentInsets] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.obscuredContentInsets.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+ ([Official API - WKWebView.obscuredContentInsets](https://developer.apple.com/documentation/webkit/wkwebview/obscuredcontentinsets)):
  ///    - Shrinks the bounds of the layout viewport so fixed/sticky elements avoid app-drawn chrome; the page still paints edge to edge. The exact page-visible effect is WebKit's and is not characterised here — do not assume a relationship to `env(safe-area-inset-*)`. All values must be non-negative. Applied live, so `setSettings` works. **Not** a fix for the keyboard `contentInset` behaviour — that path is unchanged on iOS 15 through 18.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  obscuredContentInsets,

  ///Can be used to check if the [InAppWebViewSettings.offscreenPreRaster] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.offscreenPreRaster.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+ ([Official API - WebSettings.setOffscreenPreRaster](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  offscreenPreRaster,

  ///Can be used to check if the [InAppWebViewSettings.overScrollMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.overScrollMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setOverScrollMode](https://developer.android.com/reference/android/view/View#setOverScrollMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  overScrollMode,

  ///Can be used to check if the [InAppWebViewSettings.pageZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pageZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageZoom,

  ///Can be used to check if the [InAppWebViewSettings.paymentRequestEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.paymentRequestEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setPaymentRequestEnabled](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setPaymentRequestEnabled(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.PAYMENT_REQUEST] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  paymentRequestEnabled,

  ///Can be used to check if the [InAppWebViewSettings.pluginScriptsForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pluginScriptsForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pluginScriptsForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.pluginScriptsOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pluginScriptsOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pluginScriptsOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.preferredContentMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.preferredContentMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 13.0+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredContentMode,

  ///Can be used to check if the [InAppWebViewSettings.preferredHTTPSNavigationPolicy] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.preferredHTTPSNavigationPolicy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.2+ ([Official API - WKWebpagePreferences.preferredHTTPSNavigationPolicy](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/preferredhttpsnavigationpolicy)):
  ///    - Applies to top-level navigations only, and `upgradeKnownHostsToHTTPS` supersedes it for known hosts.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredHTTPSNavigationPolicy,

  ///Can be used to check if the [InAppWebViewSettings.profileName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.profileName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.setProfile](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setProfile(android.webkit.WebView,java.lang.String))):
  ///    - available on Android only if [WebViewFeature.MULTI_PROFILE] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  profileName,

  ///Can be used to check if the [InAppWebViewSettings.regexToAllowSyncUrlLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.regexToAllowSyncUrlLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  regexToAllowSyncUrlLoading,

  ///Can be used to check if the [InAppWebViewSettings.regexToCancelSubFramesLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.regexToCancelSubFramesLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  regexToCancelSubFramesLoading,

  ///Can be used to check if the [InAppWebViewSettings.rendererPriorityPolicy] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.rendererPriorityPolicy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setRendererPriorityPolicy](https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  rendererPriorityPolicy,

  ///Can be used to check if the [InAppWebViewSettings.resourceCustomSchemes] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.resourceCustomSchemes.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  resourceCustomSchemes,

  ///Can be used to check if the [InAppWebViewSettings.safeBrowsingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.safeBrowsingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 26+ ([Official API - WebSettings.setSafeBrowsingEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  safeBrowsingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.sansSerifFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.sansSerifFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSansSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sansSerifFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarDefaultDelayBeforeFade] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarDefaultDelayBeforeFade.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarDefaultDelayBeforeFade](https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarDefaultDelayBeforeFade,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarFadeDuration] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarFadeDuration.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarFadeDuration](https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarFadeDuration,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setScrollBarStyle](https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarStyle,

  ///Can be used to check if the [InAppWebViewSettings.scrollbarFadingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollbarFadingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollbarFadingEnabled](https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollbarFadingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.scrollsToTop] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollsToTop.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.scrollsToTop](https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollsToTop,

  ///Can be used to check if the [InAppWebViewSettings.securityRestrictionMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.securityRestrictionMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.5+ ([Official API - WKWebpagePreferences.securityRestrictionMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/securityrestrictionmode)):
  ///    - Main-frame navigations only. Creates isolated WebContent processes. Lowering the mode fails silently while the system enforces Lockdown.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  securityRestrictionMode,

  ///Can be used to check if the [InAppWebViewSettings.selectionGranularity] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.selectionGranularity.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.selectionGranularity](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  selectionGranularity,

  ///Can be used to check if the [InAppWebViewSettings.serifFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.serifFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  serifFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.sharedCookiesEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.sharedCookiesEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+:
  ///    - Applied when the WebView is created. On a running WebView `setSettings` still copies the `HTTPCookieStorage.shared` cookies into the WebView's data store, but it cannot switch the WebView to a non-persistent store: that half of the work is written to a discarded copy of `WKWebView.configuration`. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sharedCookiesEnabled,

  ///Can be used to check if the [InAppWebViewSettings.shouldPrintBackgrounds] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.shouldPrintBackgrounds.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldPrintBackgrounds,

  ///Can be used to check if the [InAppWebViewSettings.showsSystemScreenTimeBlockingView] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.showsSystemScreenTimeBlockingView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+ ([Official API - WKWebViewConfiguration.showsSystemScreenTimeBlockingView](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/showssystemscreentimeblockingview)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored. Setting it `false` hides the system blocking view but does not unblock the content.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showsSystemScreenTimeBlockingView,

  ///Can be used to check if the [InAppWebViewSettings.standardFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.standardFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setStandardFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  standardFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.supportMultipleWindows] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.supportMultipleWindows.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportMultipleWindows](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  supportMultipleWindows,

  ///Can be used to check if the [InAppWebViewSettings.supportZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.supportZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)))
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  supportZoom,

  ///Can be used to check if the [InAppWebViewSettings.supportsAdaptiveImageGlyph] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.supportsAdaptiveImageGlyph.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.0+ ([Official API - WKWebViewConfiguration.supportsAdaptiveImageGlyph](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/supportsadaptiveimageglyph)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  supportsAdaptiveImageGlyph,

  ///Can be used to check if the [InAppWebViewSettings.suppressesIncrementalRendering] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.suppressesIncrementalRendering.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  suppressesIncrementalRendering,

  ///Can be used to check if the [InAppWebViewSettings.syncCallbackTimeoutMillis] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.syncCallbackTimeoutMillis.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  syncCallbackTimeoutMillis,

  ///Can be used to check if the [InAppWebViewSettings.textZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.textZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setTextZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  textZoom,

  ///Can be used to check if the [InAppWebViewSettings.thirdPartyCookiesEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.thirdPartyCookiesEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - CookieManager.setAcceptThirdPartyCookies](https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  thirdPartyCookiesEnabled,

  ///Can be used to check if the [InAppWebViewSettings.transparentBackground] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.transparentBackground.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  transparentBackground,

  ///Can be used to check if the [InAppWebViewSettings.underPageBackgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.underPageBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  underPageBackgroundColor,

  ///Can be used to check if the [InAppWebViewSettings.upgradeKnownHostsToHTTPS] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.upgradeKnownHostsToHTTPS.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps)):
  ///    - Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `preferredHTTPSNavigationPolicy` instead, which is applied per navigation and does respond to `setSettings`.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  upgradeKnownHostsToHTTPS,

  ///Can be used to check if the [InAppWebViewSettings.useHybridComposition] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useHybridComposition.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It is recommended to use Hybrid Composition only on Android 10+ for a release app, as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useHybridComposition,

  ///Can be used to check if the [InAppWebViewSettings.useOnAjaxProgress] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnAjaxProgress.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnAjaxProgress,

  ///Can be used to check if the [InAppWebViewSettings.useOnAjaxReadyStateChange] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnAjaxReadyStateChange.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnAjaxReadyStateChange,

  ///Can be used to check if the [InAppWebViewSettings.useOnDownloadStart] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnDownloadStart.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnDownloadStart,

  ///Can be used to check if the [InAppWebViewSettings.useOnInsertInputSuggestion] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnInsertInputSuggestion.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+:
  ///    - Gates the `WKUIDelegate` selector through a `responds(to:)` override, so while it is `false` WebKit does not see the delegate method at all.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnInsertInputSuggestion,

  ///Can be used to check if the [InAppWebViewSettings.useOnLoadResource] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnLoadResource.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnLoadResource,

  ///Can be used to check if the [InAppWebViewSettings.useOnNavigationResponse] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnNavigationResponse.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnNavigationResponse,

  ///Can be used to check if the [InAppWebViewSettings.useOnRenderProcessGone] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnRenderProcessGone.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnRenderProcessGone,

  ///Can be used to check if the [InAppWebViewSettings.useOnShowFileChooser] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnShowFileChooser.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 18.4+:
  ///    - While `false`, the WebView keeps WebKit's built-in file picker. Setting it `true` replaces that picker entirely with the [PlatformWebViewCreationParams.onShowFileChooser] event.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnShowFileChooser,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptAjaxRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptAjaxRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptAjaxRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptFetchRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptFetchRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptFetchRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldOverrideUrlLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldOverrideUrlLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldOverrideUrlLoading,

  ///Can be used to check if the [InAppWebViewSettings.useWideViewPort] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useWideViewPort.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUseWideViewPort](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useWideViewPort,

  ///Can be used to check if the [InAppWebViewSettings.userAgent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.userAgent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUserAgentString](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  userAgent,

  ///Can be used to check if the [InAppWebViewSettings.userAgentMetadata] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.userAgentMetadata.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setUserAgentMetadata](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setUserAgentMetadata(android.webkit.WebSettings,androidx.webkit.UserAgentMetadata))):
  ///    - available on Android only if [WebViewFeature.USER_AGENT_METADATA] feature is supported. [UserAgentMetadata.formFactors] additionally requires [WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS].
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  userAgentMetadata,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollBarEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollBarEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsVerticalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollBarEnabled,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarPosition] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarPosition.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollbarPosition](https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarPosition,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarThumbColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarThumbColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarThumbColor,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarTrackColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarTrackColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarTrackColor,

  ///Can be used to check if the [InAppWebViewSettings.webAuthenticationSupport] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.webAuthenticationSupport.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setWebAuthenticationSupport](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebAuthenticationSupport(android.webkit.WebSettings,int))):
  ///    - available on Android only if [WebViewFeature.WEB_AUTHENTICATION] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webAuthenticationSupport,

  ///Can be used to check if the [InAppWebViewSettings.webViewAssetLoader] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.webViewAssetLoader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewAssetLoader,

  ///Can be used to check if the [InAppWebViewSettings.webViewMediaIntegrityApiStatus] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.webViewMediaIntegrityApiStatus.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setWebViewMediaIntegrityApiStatus](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebViewMediaIntegrityApiStatus(android.webkit.WebSettings,androidx.webkit.WebViewMediaIntegrityApiStatusConfig))):
  ///    - available on Android only if [WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewMediaIntegrityApiStatus,

  ///Can be used to check if the [InAppWebViewSettings.writingToolsBehavior] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.writingToolsBehavior.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.0+ ([Official API - WKWebViewConfiguration.writingToolsBehavior](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/writingtoolsbehavior)):
  ///    - Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  writingToolsBehavior,
}

extension _InAppWebViewSettingsPropertySupported on InAppWebViewSettings {
  static bool isPropertySupported(
    InAppWebViewSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case InAppWebViewSettingsProperty.accessibilityIgnoresInvertColors:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.algorithmicDarkeningAllowed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowBackgroundAudioPlaying:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowContentAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowFileAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowFileAccessFromFileURLs:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowUniversalAccessFromFileURLs:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowingReadAccessTo:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsAirPlayForMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsBackForwardNavigationGestures:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsInlineMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsLinkPreview:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsPictureInPictureMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alpha:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alwaysBounceHorizontal:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alwaysBounceVertical:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.appCachePath:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.applePayAPIEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.applicationNameForUserAgent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.attributionRegistrationBehavior:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty
          .automaticallyAdjustsScrollIndicatorInsets:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.backForwardCacheEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.blockNetworkImage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.blockNetworkLoads:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.builtInZoomControls:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cacheEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cacheMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.contentBlockers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.contentInsetAdjustmentBehavior:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cursiveFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.dataDetectorTypes:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.databaseEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.decelerationRate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultFixedFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultTextEncodingName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultVideoPoster:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableContextMenu:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableDefaultErrorPage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableHorizontalScroll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableInputAccessoryView:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableLongPressContextMenuOnLinks:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableVerticalScroll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disabledActionModeMenuItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disallowOverScroll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.displayZoomControls:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.domStorageEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.downloadFaviconsEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.enableViewportScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty
          .enterpriseAuthenticationAppLinkPolicyEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.fantasyFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.fixedFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.geolocationEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.hardwareAcceleration:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollBarEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollbarThumbColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollbarTrackColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.ignoresViewportScaleLimits:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.incognito:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.initialScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.interceptOnlyAsyncAjaxRequests:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isDirectionalLockEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isElementFullscreenEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isFindInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isFraudulentWebsiteWarningEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isInspectable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isPagingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isSiteSpecificQuirksModeEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isTextInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isUserInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeOriginAllowList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptCanOpenWindowsAutomatically:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptHandlersForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptHandlersOriginAllowList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.layoutAlgorithm:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.limitsNavigationsToAppBoundDomains:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.loadWithOverviewMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.loadsImagesAutomatically:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.lockdownModeEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.maximumViewportInset:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.maximumZoomScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mediaPlaybackRequiresUserGesture:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mediaType:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumLogicalFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumViewportInset:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumZoomScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mixedContentMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.needInitialFocus:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.networkAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.obscuredContentInsets:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.offscreenPreRaster:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.overScrollMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pageZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.paymentRequestEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pluginScriptsForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pluginScriptsOriginAllowList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.preferredContentMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.preferredHTTPSNavigationPolicy:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.profileName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.regexToAllowSyncUrlLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.regexToCancelSubFramesLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.rendererPriorityPolicy:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.resourceCustomSchemes:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.safeBrowsingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.sansSerifFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarDefaultDelayBeforeFade:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarFadeDuration:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollbarFadingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollsToTop:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.securityRestrictionMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.selectionGranularity:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.serifFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.sharedCookiesEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.shouldPrintBackgrounds:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.showsSystemScreenTimeBlockingView:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.standardFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.supportMultipleWindows:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.supportZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.supportsAdaptiveImageGlyph:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.suppressesIncrementalRendering:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.syncCallbackTimeoutMillis:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.textZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.thirdPartyCookiesEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.transparentBackground:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.underPageBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.upgradeKnownHostsToHTTPS:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useHybridComposition:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnAjaxProgress:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnAjaxReadyStateChange:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnDownloadStart:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnInsertInputSuggestion:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnLoadResource:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnNavigationResponse:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnRenderProcessGone:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnShowFileChooser:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptAjaxRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptFetchRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldOverrideUrlLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useWideViewPort:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.userAgent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.userAgentMetadata:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollBarEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarPosition:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarThumbColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarTrackColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.webAuthenticationSupport:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.webViewAssetLoader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.webViewMediaIntegrityApiStatus:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.writingToolsBehavior:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
