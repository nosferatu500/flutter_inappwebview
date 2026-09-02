import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../types/action_mode_menu_item.dart';
import '../types/attribution_registration_behavior.dart';
import '../types/cache_mode.dart';
import '../types/data_detector_types.dart';
import '../types/layout_algorithm.dart';
import '../types/mixed_content_mode.dart';
import '../types/over_scroll_mode.dart';
import '../types/renderer_priority_policy.dart';
import '../types/scrollbar_style.dart';
import '../types/scrollview_content_inset_adjustment_behavior.dart';
import '../types/writing_tools_behavior.dart';
import '../types/upgrade_to_https_policy.dart';
import '../types/security_restriction_mode.dart';
import '../types/scrollview_deceleration_rate.dart';
import '../types/selection_granularity.dart';
import '../types/user_preferred_content_mode.dart';
import '../types/vertical_scrollbar_position.dart';
import '../types/user_agent_metadata.dart';
import '../types/webview_media_integrity_api_status_config.dart';
import '../types/web_authentication_support.dart';

part 'in_app_webview_settings.g.dart';

List<ContentBlocker> _deserializeContentBlockers(
  List<dynamic>? contentBlockersMapList, {
  EnumMethod? enumMethod,
}) {
  List<ContentBlocker> contentBlockers = [];
  if (contentBlockersMapList != null) {
    for (var contentBlocker in contentBlockersMapList) {
      contentBlockers.add(
        ContentBlocker.fromMap(
          Map<dynamic, Map<dynamic, dynamic>>.from(
            Map<dynamic, dynamic>.from(contentBlocker),
          ),
          enumMethod: enumMethod,
        ),
      );
    }
  }
  return contentBlockers;
}

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all the WebView settings available.
///{@endtemplate}
@ExchangeableObject(copyMethod: true)
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
class InAppWebViewSettings_ {
  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useShouldOverrideUrlLoading;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onLoadResource] event.
  ///
  ///If the [PlatformWebViewCreationParams.onLoadResource] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useOnLoadResource;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onDownloadStarting] event.
  ///
  ///If the [PlatformWebViewCreationParams.onDownloadStarting] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useOnDownloadStart;

  ///Sets the user-agent for the WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setUserAgentString",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)",
      ),
      IOSPlatform(
        apiName: "WKWebView.customUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent",
      ),
    ],
  )
  String? userAgent;

  ///Append to the existing user-agent. Setting userAgent will override this.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: "WKWebViewConfiguration.applicationNameForUserAgent",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `userAgent` instead, which is applied to the live WebView and does respond to `setSettings`.",
      ),
    ],
  )
  String? applicationNameForUserAgent;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setJavaScriptEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "WKWebpagePreferences.allowsContentJavaScript",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/",
      ),
    ],
  )
  bool? javaScriptEnabled;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setJavaScriptCanOpenWindowsAutomatically",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)",
      ),
      IOSPlatform(
        apiName: "WKPreferences.javaScriptCanOpenWindowsAutomatically",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/",
      ),
    ],
  )
  bool? javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMediaPlaybackRequiresUserGesture",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)",
      ),
      IOSPlatform(
        apiName:
            "WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? mediaPlaybackRequiresUserGesture;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMinimumFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)",
      ),
      IOSPlatform(
        apiName: "WKPreferences.minimumFontSize",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/",
      ),
    ],
  )
  int? minimumFontSize;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setVerticalScrollBarEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "UIScrollView.showsVerticalScrollIndicator",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/",
      ),
    ],
  )
  bool? verticalScrollBarEnabled;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setHorizontalScrollBarEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)",
      ),
      IOSPlatform(
        apiName: "UIScrollView.showsHorizontalScrollIndicator",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator",
      ),
    ],
  )
  bool? horizontalScrollBarEnabled;

  ///List of custom schemes that the WebView must handle. Use the [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme] event to intercept resource requests with custom scheme.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: "11.0"),
    ],
  )
  List<String>? resourceCustomSchemes;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: "11.0"),
    ],
  )
  @ExchangeableObjectProperty(deserializer: _deserializeContentBlockers)
  List<ContentBlocker>? contentBlockers;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        available: "13.0",
        apiName: "WKWebpagePreferences.preferredContentMode",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/",
      ),
    ],
  )
  UserPreferredContentMode_? preferredContentMode;

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
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useShouldInterceptAjaxRequest;

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
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useOnAjaxReadyStateChange;

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
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useOnAjaxProgress;

  ///Set to `false` to be able to listen to also sync `XMLHttpRequest`s at the
  ///[PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///**NOTE**: Using `false` will cause the `XMLHttpRequest.send()` method for sync
  ///requests to not wait on the JavaScript code the response synchronously,
  ///as if it was an async `XMLHttpRequest`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? interceptOnlyAsyncAjaxRequests;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? useShouldInterceptFetchRequest;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """setting this to `true`, it will clear all the cookies of all WebView instances, 
because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.""",
      ),
      IOSPlatform(
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? incognito;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? cacheEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? transparentBackground;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? disableVerticalScroll;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? disableHorizontalScroll;

  ///Set to `true` to disable context menu. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? disableContextMenu;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSupportZoom",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)",
      ),
      IOSPlatform(),
    ],
  )
  bool? supportZoom;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowFileAccessFromFileURLs",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)",
      ),
      IOSPlatform(),
    ],
  )
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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowUniversalAccessFromFileURLs",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)",
      ),
      IOSPlatform(
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? allowUniversalAccessFromFileURLs;

  ///Set to `true` to allow audio playing when the app goes in background or the screen is locked or another app is opened.
  ///However, there will be no controls in the notification bar or on the lockscreen.
  ///Also, make sure to not call [PlatformInAppWebViewController.pause], otherwise it will stop audio playing.
  ///The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: if you use this setting, your app could be rejected by the Google Play Store.
  ///For example, if you allow background playing of YouTube videos, which is a violation of the YouTube API Terms of Service.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? allowBackgroundAudioPlaying;

  ///Use a [WebViewAssetLoader] instance to load local files including application's static assets and resources using http(s):// URLs.
  ///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  WebViewAssetLoader_? webViewAssetLoader;

  ///Sets the text zoom of the page in percent. The default value is `100`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setTextZoom",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)",
      ),
    ],
  )
  int? textZoom;

  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBuiltInZoomControls",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)",
      ),
    ],
  )
  bool? builtInZoomControls;

  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDisplayZoomControls",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)",
      ),
    ],
  )
  bool? displayZoomControls;

  ///Set to `true` if you want the database storage API is enabled. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDatabaseEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)",
      ),
    ],
  )
  bool? databaseEnabled;

  ///Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDomStorageEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)",
      ),
    ],
  )
  bool? domStorageEnabled;

  ///Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels.
  ///When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used.
  ///If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setUseWideViewPort",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)",
      ),
    ],
  )
  bool? useWideViewPort;

  ///Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
  ///Safe Browsing is enabled by default for devices which support it.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "26",
        apiName: "WebSettings.setSafeBrowsingEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)",
      ),
    ],
  )
  bool? safeBrowsingEnabled;

  ///Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebSettings.setMixedContentMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)",
      ),
    ],
  )
  MixedContentMode_? mixedContentMode;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowContentAccess",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)",
      ),
    ],
  )
  bool? allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setAllowFileAccess",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)",
      ),
    ],
  )
  bool? allowFileAccess;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(apiName: "WebSettings.setAppCachePath")],
  )
  String? appCachePath;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBlockNetworkImage",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)",
      ),
    ],
  )
  bool? blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setBlockNetworkLoads",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)",
      ),
    ],
  )
  bool? blockNetworkLoads;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [CacheMode.LOAD_DEFAULT].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setCacheMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)",
      ),
    ],
  )
  CacheMode_? cacheMode;

  ///Sets the cursive font family name. The default value is `"cursive"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setCursiveFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)",
      ),
    ],
  )
  String? cursiveFontFamily;

  ///Sets the default fixed font size. The default value is `16`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultFixedFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)",
      ),
    ],
  )
  int? defaultFixedFontSize;

  ///Sets the default font size. The default value is `16`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)",
      ),
    ],
  )
  int? defaultFontSize;

  ///Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setDefaultTextEncodingName",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)",
      ),
    ],
  )
  String? defaultTextEncodingName;

  ///Disables the action mode menu items according to menuItems flag.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "24",
        apiName: "WebSettings.setDisabledActionModeMenuItems",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)",
      ),
    ],
  )
  ActionModeMenuItem_? disabledActionModeMenuItems;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setFantasyFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)",
      ),
    ],
  )
  String? fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setFixedFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)",
      ),
    ],
  )
  String? fixedFontFamily;

  ///Sets whether Geolocation is enabled. The default is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setGeolocationEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean)",
        note:
            """Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met:
- an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION);
- an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.""",
      ),
    ],
  )
  bool? geolocationEnabled;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLayoutAlgorithm",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)",
      ),
    ],
  )
  LayoutAlgorithm_? layoutAlgorithm;

  ///Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///This setting is taken into account when the content width is greater than the width of the WebView control, for example, when [useWideViewPort] is enabled.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLoadWithOverviewMode",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)",
      ),
    ],
  )
  bool? loadWithOverviewMode;

  ///Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
  ///Note that if the value of this setting is changed from false to true, all images resources referenced by content currently displayed by the WebView are loaded automatically.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setLoadsImagesAutomatically",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)",
      ),
    ],
  )
  bool? loadsImagesAutomatically;

  ///Sets the minimum logical font size. The default is `8`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setMinimumLogicalFontSize",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)",
      ),
    ],
  )
  int? minimumLogicalFontSize;

  ///Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of [useWideViewPort] and [loadWithOverviewMode].
  ///If the content fits into the WebView control by width, then the zoom is set to 100%. For wide content, the behavior depends on the state of [loadWithOverviewMode].
  ///If its value is true, the content will be zoomed out to be fit by width into the WebView control, otherwise not.
  ///If initial scale is greater than 0, WebView starts with this value as initial scale.
  ///Please note that unlike the scale properties in the viewport meta tag, this method doesn't take the screen density into account.
  ///The default is `0`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setInitialScale",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)",
      ),
    ],
  )
  int? initialScale;

  ///Tells the WebView whether it needs to set a node. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setNeedInitialFocus",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)",
      ),
    ],
  )
  bool? needInitialFocus;

  ///Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
  ///Turning this on can avoid rendering artifacts when animating an offscreen WebView on-screen.
  ///Offscreen WebViews in this mode use more memory. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "23",
        apiName: "WebSettings.setOffscreenPreRaster",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)",
      ),
    ],
  )
  bool? offscreenPreRaster;

  ///Sets the sans-serif font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSansSerifFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)",
      ),
    ],
  )
  String? sansSerifFontFamily;

  ///Sets the serif font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSerifFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)",
      ),
    ],
  )
  String? serifFontFamily;

  ///Sets the standard font family name. The default value is `"sans-serif"`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setStandardFontFamily",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)",
      ),
    ],
  )
  String? standardFontFamily;

  ///Boolean value to enable third party cookies in the WebView.
  ///Used on Android Lollipop and above only as third party cookies are enabled by default on Android Kitkat and below and on iOS.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "CookieManager.setAcceptThirdPartyCookies",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)",
      ),
    ],
  )
  bool? thirdPartyCookiesEnabled;

  ///Boolean value to enable Hardware Acceleration in the WebView.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setLayerType",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)",
      ),
    ],
  )
  bool? hardwareAcceleration;

  ///Sets whether the WebView supports multiple windows.
  ///If set to `true`, [PlatformWebViewCreationParams.onCreateWindow] event must be implemented by the host application. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettings.setSupportMultipleWindows",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)",
      ),
    ],
  )
  bool? supportMultipleWindows;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a sub-frame matches the regular expression, then the request of that sub-frame is canceled.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? regexToCancelSubFramesLoading;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to allow navigation requests synchronously.
  ///If the url request match the regular expression, then the request is allowed automatically,
  ///and the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event will not be fired.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? regexToAllowSyncUrlLoading;

  ///Set to `false` to disable Flutter Hybrid Composition. The default value is `true`.
  ///Hybrid Composition is supported starting with Flutter v1.20+.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            """It is recommended to use Hybrid Composition only on Android 10+ for a release app,
as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).""",
      ),
    ],
  )
  bool? useHybridComposition;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? useShouldInterceptRequest;

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
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int? syncCallbackTimeoutMillis;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onRenderProcessGone] event.
  ///
  ///If the [PlatformWebViewCreationParams.onRenderProcessGone] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? useOnRenderProcessGone;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [OverScrollMode.IF_CONTENT_SCROLLS].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setOverScrollMode",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setOverScrollMode(int)",
      ),
    ],
  )
  OverScrollMode_? overScrollMode;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setNetworkAvailable",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)",
      ),
    ],
  )
  bool? networkAvailable;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setScrollBarStyle",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)",
      ),
    ],
  )
  ScrollBarStyle_? scrollBarStyle;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setVerticalScrollbarPosition",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)",
      ),
    ],
  )
  VerticalScrollbarPosition_? verticalScrollbarPosition;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollBarDefaultDelayBeforeFade",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)",
      ),
    ],
  )
  int? scrollBarDefaultDelayBeforeFade;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollbarFadingEnabled",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)",
      ),
    ],
  )
  bool? scrollbarFadingEnabled;

  ///Defines the scrollbar fade duration in milliseconds.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setScrollBarFadeDuration",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)",
      ),
    ],
  )
  int? scrollBarFadeDuration;

  ///Sets the renderer priority policy for this WebView.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebView.setRendererPriorityPolicy",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)",
      ),
    ],
  )
  RendererPriorityPolicy_? rendererPriorityPolicy;

  ///Sets whether the default Android WebView’s internal error page should be suppressed or displayed for bad navigations.
  ///`true` means suppressed (not shown), `false` means it will be displayed. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? disableDefaultErrorPage;

  ///Sets the vertical scrollbar thumb color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setVerticalScrollbarThumbDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? verticalScrollbarThumbColor;

  ///Sets the vertical scrollbar track color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setVerticalScrollbarTrackDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? verticalScrollbarTrackColor;

  ///Sets the horizontal scrollbar thumb color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setHorizontalScrollbarThumbDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? horizontalScrollbarThumbColor;

  ///Sets the horizontal scrollbar track color.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "View.setHorizontalScrollbarTrackDrawable",
        apiUrl:
            "https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)",
      ),
    ],
  )
  Color_? horizontalScrollbarTrackColor;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "29",
        apiName: "WebSettingsCompat.setAlgorithmicDarkeningAllowed",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean)",
        note:
            "available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.",
      ),
    ],
  )
  bool? algorithmicDarkeningAllowed;

  ///Sets whether the [Payment Request API](https://developer.mozilla.org/en-US/docs/Web/API/Payment_Request_API)
  ///is enabled in this WebView.
  ///
  ///When enabled, `PaymentRequest` becomes available to web content, which lets a page invoke
  ///payment handlers — including Google Pay — instead of falling back to a manual checkout form.
  ///
  ///The Payment Request API is disabled by default.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setPaymentRequestEnabled",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setPaymentRequestEnabled(android.webkit.WebSettings,boolean)",
        note:
            "available on Android only if [WebViewFeature.PAYMENT_REQUEST] feature is supported.",
      ),
    ],
  )
  bool? paymentRequestEnabled;

  ///Sets the level of [Web Authentication API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)
  ///support this WebView provides, i.e. whether web content may create and use passkeys.
  ///
  ///Leave `null` to keep the platform default, which is [WebAuthenticationSupport.NONE].
  ///
  ///Use [WebAuthenticationSupport.FOR_APP] for an app signing users in to its own service.
  ///[WebAuthenticationSupport.FOR_BROWSER] is for apps that are themselves a browser and has
  ///additional requirements — read the Android documentation before setting it.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setWebAuthenticationSupport",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebAuthenticationSupport(android.webkit.WebSettings,int)",
        note:
            "available on Android only if [WebViewFeature.WEB_AUTHENTICATION] feature is supported.",
      ),
    ],
  )
  WebAuthenticationSupport_? webAuthenticationSupport;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setDownloadFaviconsEnabled",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setDownloadFaviconsEnabled(android.webkit.WebSettings,boolean)",
        note:
            "available on Android only if [WebViewFeature.DOWNLOAD_FAVICONS_ENABLED] feature is supported.",
      ),
    ],
  )
  bool? downloadFaviconsEnabled;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setBackForwardCacheEnabled",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setBackForwardCacheEnabled(android.webkit.WebSettings,boolean)",
        note:
            "available on Android only if [WebViewFeature.BACK_FORWARD_CACHE] feature is supported.",
      ),
    ],
  )
  bool? backForwardCacheEnabled;

  ///Sets how this WebView registers sources and triggers for the
  ///[Attribution Reporting API](https://developer.android.com/design-for-safety/privacy-sandbox/attribution).
  ///
  ///Controls whether an ad impression and its conversion are attributed to the app or to the web.
  ///Only relevant to apps that display ads or measure conversions in a WebView; use
  ///[AttributionRegistrationBehavior.DISABLED] to switch attribution registration off entirely.
  ///
  ///Leave `null` to keep the platform default.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setAttributionRegistrationBehavior",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAttributionRegistrationBehavior(android.webkit.WebSettings,int)",
        note:
            "available on Android only if [WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR] feature is supported.",
      ),
    ],
  )
  AttributionRegistrationBehavior_? attributionRegistrationBehavior;

  ///Sets the [WebView Media Integrity API](https://developer.android.com/privacy-and-security/webview-media-integrity)
  ///configuration for this WebView.
  ///
  ///The API lets a media provider verify that content is being played in a genuine, unmodified
  ///WebView before serving it. The config carries a default status plus optional per-origin
  ///overrides, so one trusted provider can be granted app identity while everything else stays
  ///more restricted.
  ///
  ///Leave `null` to keep the platform default.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setWebViewMediaIntegrityApiStatus",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setWebViewMediaIntegrityApiStatus(android.webkit.WebSettings,androidx.webkit.WebViewMediaIntegrityApiStatusConfig)",
        note:
            "available on Android only if [WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS] feature is supported.",
      ),
    ],
  )
  WebViewMediaIntegrityApiStatusConfig_? webViewMediaIntegrityApiStatus;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebSettingsCompat.setUserAgentMetadata",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setUserAgentMetadata(android.webkit.WebSettings,androidx.webkit.UserAgentMetadata)",
        note:
            "available on Android only if [WebViewFeature.USER_AGENT_METADATA] feature is supported. [UserAgentMetadata.formFactors] additionally requires [WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS].",
      ),
    ],
  )
  UserAgentMetadata_? userAgentMetadata;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "WebViewCompat.setProfile",
        apiUrl:
            "https://developer.android.com/reference/androidx/webkit/WebViewCompat#setProfile(android.webkit.WebView,java.lang.String)",
        note:
            "available on Android only if [WebViewFeature.MULTI_PROFILE] feature is supported.",
      ),
    ],
  )
  String? profileName;

  ///Sets whether EnterpriseAuthenticationAppLinkPolicy if set by admin is allowed to have any
  ///effect on WebView.
  ///
  ///EnterpriseAuthenticationAppLinkPolicy in WebView allows admins to specify authentication
  ///urls. When WebView is redirected to authentication url, and an app on the device has
  ///registered as the default handler for the url, that app is launched.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            "available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.",
      ),
    ],
  )
  bool? enterpriseAuthenticationAppLinkPolicyEnabled;

  ///When not playing, video elements are represented by a 'poster' image.
  ///The image to use can be specified by the poster attribute of the video tag in HTML.
  ///If the attribute is absent, then a default poster will be used.
  ///This property allows the WebView to provide that default image.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  Uint8List? defaultVideoPoster;

  ///Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disallowOverScroll;

  ///Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? enableViewportScale;

  ///Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.suppressesIncrementalRendering",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? suppressesIncrementalRendering;

  ///Set to `true` to allow AirPlay. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsAirPlayForMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebView.allowsBackForwardNavigationGestures",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu",
      ),
    ],
  )
  bool? allowsBackForwardNavigationGestures;

  ///Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebView.allowsLinkPreview",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview",
      ),
    ],
  )
  bool? allowsLinkPreview;

  ///Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
  ///The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.ignoresViewportScaleLimits",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? ignoresViewportScaleLimits;

  ///Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
  ///For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsInlineMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? allowsInlineMediaPlayback;

  ///Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.allowsPictureInPictureMediaPlayback",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? allowsPictureInPictureMediaPlayback;

  ///A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
  ///According to the official documentation, this feature is currently available in the following region: China.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "WKPreferences.isFraudulentWebsiteWarningEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable",
      ),
    ],
  )
  bool? isFraudulentWebsiteWarningEnabled;

  ///The level of granularity with which the user can interactively select content in the web view.
  ///The default value is [SelectionGranularity.DYNAMIC].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKWebViewConfiguration.selectionGranularity",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  SelectionGranularity_? selectionGranularity;

  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [DataDetectorTypes.LINK].
  ///The default value is [DataDetectorTypes.NONE].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "10",
        apiName: "WKWebViewConfiguration.dataDetectorTypes",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  List<DataDetectorTypes_>? dataDetectorTypes;

  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "11.0",
        note:
            "Applied when the WebView is created. On a running WebView `setSettings` still copies the `HTTPCookieStorage.shared` cookies into the WebView's data store, but it cannot switch the WebView to a non-persistent store: that half of the work is written to a discarded copy of `WKWebView.configuration`. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? sharedCookiesEnabled;

  ///Configures whether the scroll indicator insets are automatically adjusted by the system.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "UIScrollView.automaticallyAdjustsScrollIndicatorInsets",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica",
      ),
    ],
  )
  bool? automaticallyAdjustsScrollIndicatorInsets;

  ///A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "11.0",
        apiName: "UIView.accessibilityIgnoresInvertColors",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors",
      ),
    ],
  )
  bool? accessibilityIgnoresInvertColors;

  ///A [ScrollViewDecelerationRate] value that determines the rate of deceleration after the user lifts their finger.
  ///The default value is [ScrollViewDecelerationRate.NORMAL].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.decelerationRate",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate",
      ),
    ],
  )
  ScrollViewDecelerationRate_? decelerationRate;

  ///A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.alwaysBounceVertical",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical",
      ),
    ],
  )
  bool? alwaysBounceVertical;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.alwaysBounceHorizontal",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal",
      ),
    ],
  )
  bool? alwaysBounceHorizontal;

  ///A Boolean value that controls whether the scroll-to-top gesture is enabled.
  ///The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
  ///the system asks the scroll view closest to the status bar to scroll to the top.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.scrollsToTop",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop",
      ),
    ],
  )
  bool? scrollsToTop;

  ///A Boolean value that determines whether paging is enabled for the scroll view.
  ///If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.isPagingEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled",
      ),
    ],
  )
  bool? isPagingEnabled;

  ///A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content.
  ///This value determines how large the content can be scaled.
  ///It must be greater than the minimum zoom scale for zooming to be enabled.
  ///The default value is `1.0`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.maximumZoomScale",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale",
      ),
    ],
  )
  double? maximumZoomScale;

  ///A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content.
  ///This value determines how small the content can be scaled.
  ///The default value is `1.0`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.minimumZoomScale",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale",
      ),
    ],
  )
  double? minimumZoomScale;

  ///Configures how safe area insets are added to the adjusted content inset.
  ///The default value is [ScrollViewContentInsetAdjustmentBehavior.NEVER].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "11.0",
        apiName: "UIScrollView.contentInsetAdjustmentBehavior",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior",
      ),
    ],
  )
  ScrollViewContentInsetAdjustmentBehavior_? contentInsetAdjustmentBehavior;

  ///A Boolean value that determines whether scrolling is disabled in a particular direction.
  ///If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
  ///If this property is `true` and the user begins dragging in one general direction (horizontally or vertically),
  ///the scroll view disables scrolling in the other direction.
  ///If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "UIScrollView.isDirectionalLockEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled",
      ),
    ],
  )
  bool? isDirectionalLockEnabled;

  ///The media type for the contents of the web view.
  ///When the value of this property is `null`, the web view derives the current media type from the CSS media property of its content.
  ///If you assign a value other than `null` to this property, the web view uses the value you provide instead.
  ///The default value of this property is `null`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebView.mediaType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype",
      ),
    ],
  )
  String? mediaType;

  ///The scale factor by which the web view scales content relative to its bounds.
  ///The default value of this property is `1.0`, which displays the content without any scaling.
  ///Changing the value of this property is equivalent to setting the CSS `zoom` property on all page content.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebView.pageZoom",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom",
      ),
    ],
  )
  double? pageZoom;

  ///A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain.
  ///Check [App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) for more details.
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.0",
        apiName: "WKWebViewConfiguration.limitsNavigationsToAppBoundDomains",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it.",
      ),
    ],
  )
  bool? limitsNavigationsToAppBoundDomains;

  ///Set to `true` to be able to listen to the [PlatformWebViewCreationParams.onNavigationResponse] event.
  ///
  ///If the [PlatformWebViewCreationParams.onNavigationResponse] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? useOnNavigationResponse;

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
  @SupportedPlatforms(platforms: [IOSPlatform(available: "13.0")])
  bool? applePayAPIEnabled;

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
  @SupportedPlatforms(platforms: [IOSPlatform()])
  WebUri? allowingReadAccessTo;

  ///Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
  ///This is implemented using also JavaScript, so it must be enabled or it won't work.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disableLongPressContextMenuOnLinks;

  ///Set to `true` to disable the [inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) above system keyboard.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? disableInputAccessoryView;

  ///The color the web view displays behind the active page, visible when the user scrolls beyond the bounds of the page.
  ///
  ///The web view derives the default value of this property from the content of the page,
  ///using the background colors of the `<html>` and `<body>` elements with the background color of the web view.
  ///To override the default color, set this property to a new color.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKWebView.underPageBackgroundColor",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor",
      ),
    ],
  )
  Color_? underPageBackgroundColor;

  ///A Boolean value indicating whether text interaction is enabled or not.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKPreferences.isTextInteractionEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled",
      ),
    ],
  )
  bool? isTextInteractionEnabled;

  ///A Boolean value indicating whether WebKit will apply built-in workarounds (quirks)
  ///to improve compatibility with certain known websites. You can disable site-specific quirks
  ///to help test your website without these workarounds. The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.4",
        apiName: "WKPreferences.isSiteSpecificQuirksModeEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled",
      ),
    ],
  )
  bool? isSiteSpecificQuirksModeEnabled;

  ///A Boolean value indicating whether HTTP requests to servers known to support HTTPS should be automatically upgraded to HTTPS requests.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "WKWebViewConfiguration.upgradeKnownHostsToHTTPS",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps",
        note:
            "Applied when the WebView is created. Changing it with `setSettings` on a running WebView has **no** effect: `WKWebView.configuration` returns a fresh copy on every access, so the write is discarded. Recreate the WebView to change it. Use `preferredHTTPSNavigationPolicy` instead, which is applied per navigation and does respond to `setSettings`.",
      ),
    ],
  )
  bool? upgradeKnownHostsToHTTPS;

  ///Sets whether fullscreen API is enabled or not.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.4",
        apiName: "WKPreferences.isElementFullscreenEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled",
      ),
    ],
  )
  bool? isElementFullscreenEnabled;

  ///Sets whether the web view's built-in find interaction native UI is enabled or not.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.0",
        apiName: "WKWebView.isFindInteractionEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/",
      ),
    ],
  )
  bool? isFindInteractionEnabled;

  ///Set minimum viewport inset to the smallest inset a webpage may experience in your app's maximally collapsed UI configuration.
  ///Values must be either zero or positive. It must be smaller than [maximumViewportInset].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.5",
        apiName: "WKWebView.setMinimumViewportInset",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/",
      ),
    ],
  )
  EdgeInsets? minimumViewportInset;

  ///Set maximum viewport inset to the largest inset a webpage may experience in your app's maximally expanded UI configuration.
  ///Values must be either zero or positive. It must be larger than [minimumViewportInset].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.5",
        apiName: "WKWebView.setMinimumViewportInset",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/",
      ),
    ],
  )
  EdgeInsets? maximumViewportInset;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "26.0",
        apiName: "WKWebView.obscuredContentInsets",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/obscuredcontentinsets",
        note:
            "Shrinks the bounds of the layout viewport so fixed/sticky elements avoid app-drawn chrome; the page still paints edge to edge. The exact page-visible effect is WebKit's and is not characterised here — do not assume a relationship to `env(safe-area-inset-*)`. All values must be non-negative. Applied live, so `setSettings` works. **Not** a fix for the keyboard `contentInset` behaviour — that path is unchanged on iOS 15 through 18.",
      ),
    ],
  )
  EdgeInsets? obscuredContentInsets;

  ///Controls whether this WebView is inspectable in Web Inspector.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.4",
        apiName: "WKWebView.isInspectable",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable",
      ),
    ],
  )
  bool? isInspectable;

  ///A Boolean value that indicates whether to include any background color or graphics when printing content.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.4",
        apiName: "WKWebView.shouldPrintBackgrounds",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds",
      ),
    ],
  )
  bool? shouldPrintBackgrounds;

  ///A [Set] of Regular Expression Patterns that will be used on native side to match the allowed origins
  ///that are able to execute the JavaScript Handlers defined for the current WebView.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///
  ///An empty [Set] will block every origin.
  ///
  ///The default value is `null` and will allow every origin.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Set<String>? javaScriptHandlersOriginAllowList;

  ///Set to `true` to allow to execute the JavaScript Handlers only on the main frame.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? javaScriptHandlersForMainFrameOnly;

  ///Set to `false` to disable the JavaScript Bridge completely.
  ///This will affect also all the internal plugin [UserScript]s
  ///that are using the JavaScript Bridge to work.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? javaScriptBridgeEnabled;

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
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Set<String>? javaScriptBridgeOriginAllowList;

  ///Set to `true` to allow the JavaScript Bridge only on the main frame.
  ///If [pluginScriptsForMainFrameOnly] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? javaScriptBridgeForMainFrameOnly;

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
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Set<String>? pluginScriptsOriginAllowList;

  ///Set to `true` to allow internal plugin [UserScript]s only on the main frame.
  ///
  ///**NOTE**: If [javaScriptBridgeForMainFrameOnly] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? pluginScriptsForMainFrameOnly;

  ///A Boolean value that determines whether user events are ignored and removed from the event queue.
  ///
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: "UIView.isUserInteractionEnabled",
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled',
      ),
    ],
  )
  bool? isUserInteractionEnabled;

  ///The view’s alpha value. The value of this property is a floating-point number
  ///in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "View.setAlpha",
        apiUrl:
            'https://developer.android.com/reference/android/view/View#setAlpha(float)',
      ),
      IOSPlatform(
        apiName: "UIView.alpha",
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1622417-alpha',
      ),
    ],
  )
  double? alpha;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "16.0",
        apiName: "WKWebpagePreferences.lockdownModeEnabled",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/islockdownmodeenabled",
        note:
            "Defaults to the device's system setting. Passing `false` overrides a user who enabled Lockdown Mode.",
      ),
    ],
  )
  bool? lockdownModeEnabled;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "26.5",
        apiName: "WKWebpagePreferences.securityRestrictionMode",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/securityrestrictionmode",
        note:
            "Main-frame navigations only. Creates isolated WebContent processes. Lowering the mode fails silently while the system enforces Lockdown.",
      ),
    ],
  )
  SecurityRestrictionMode_? securityRestrictionMode;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.2",
        apiName: "WKWebpagePreferences.preferredHTTPSNavigationPolicy",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebpagepreferences/preferredhttpsnavigationpolicy",
        note:
            "Applies to top-level navigations only, and `upgradeKnownHostsToHTTPS` supersedes it for known hosts.",
      ),
    ],
  )
  UpgradeToHTTPSPolicy_? preferredHTTPSNavigationPolicy;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.0",
        apiName: "WKWebViewConfiguration.supportsAdaptiveImageGlyph",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/supportsadaptiveimageglyph",
        note:
            "Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.",
      ),
    ],
  )
  bool? supportsAdaptiveImageGlyph;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.0",
        apiName: "WKWebViewConfiguration.writingToolsBehavior",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/writingtoolsbehavior",
        note:
            "Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored.",
      ),
    ],
  )
  WritingToolsBehavior_? writingToolsBehavior;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "26.0",
        apiName: "WKWebViewConfiguration.showsSystemScreenTimeBlockingView",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/showssystemscreentimeblockingview",
        note:
            "Applied at WebView creation only; `WKWebView.configuration` is a copy, so later changes are ignored. Setting it `false` hides the system blocking view but does not unblock the content.",
      ),
    ],
  )
  bool? showsSystemScreenTimeBlockingView;

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
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        available: "18.4",
        note:
            'While `false`, the WebView keeps WebKit\'s built-in file picker. Setting it `true` replaces that picker entirely with the [PlatformWebViewCreationParams.onShowFileChooser] event.',
      ),
    ],
  )
  bool? useOnShowFileChooser;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "26.0",
        note:
            'Gates the `WKUIDelegate` selector through a `responds(to:)` override, so while it is `false` WebKit does not see the delegate method at all.',
      ),
    ],
  )
  bool? useOnInsertInputSuggestion;

  @ExchangeableObjectConstructor()
  InAppWebViewSettings_({
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
    this.preferredContentMode = UserPreferredContentMode_.RECOMMENDED,
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
    this.cacheMode = CacheMode_.LOAD_DEFAULT,
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
    this.overScrollMode = OverScrollMode_.IF_CONTENT_SCROLLS,
    this.networkAvailable,
    this.scrollBarStyle = ScrollBarStyle_.SCROLLBARS_INSIDE_OVERLAY,
    this.verticalScrollbarPosition =
        VerticalScrollbarPosition_.SCROLLBAR_POSITION_DEFAULT,
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
    this.selectionGranularity = SelectionGranularity_.DYNAMIC,
    this.dataDetectorTypes = const [DataDetectorTypes_.NONE],
    this.sharedCookiesEnabled = false,
    this.automaticallyAdjustsScrollIndicatorInsets = false,
    this.accessibilityIgnoresInvertColors = false,
    this.decelerationRate = ScrollViewDecelerationRate_.NORMAL,
    this.alwaysBounceVertical = false,
    this.alwaysBounceHorizontal = false,
    this.scrollsToTop = true,
    this.isPagingEnabled = false,
    this.maximumZoomScale = 1.0,
    this.minimumZoomScale = 1.0,
    this.contentInsetAdjustmentBehavior =
        ScrollViewContentInsetAdjustmentBehavior_.NEVER,
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
    // WebKit's header says "All edge insets must be non-negative" for `obscuredContentInsets`. An
    // assert only fires in debug, so this is a development aid rather than a guarantee -- the
    // dartdoc says what the native does with a negative value.
    assert(
      obscuredContentInsets == null || obscuredContentInsets!.isNonNegative,
      "obscuredContentInsets must be non-negative on every side",
    );
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    InAppWebViewSettingsProperty property, {
    TargetPlatform? platform,
  }) => _InAppWebViewSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
