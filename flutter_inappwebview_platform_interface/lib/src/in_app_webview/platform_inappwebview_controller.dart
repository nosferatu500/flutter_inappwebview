import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../context_menu/main.dart';
import '../debug_logging_settings.dart';
import '../in_app_browser/platform_in_app_browser.dart';
import '../inappwebview_platform.dart';
import '../platform_webview_feature.dart';
import '../print_job/main.dart';
import '../types/main.dart';
import '../web_message/main.dart';
import '../web_storage/platform_web_storage.dart';
import '../web_uri.dart';
import 'in_app_webview_keep_alive.dart';
import 'in_app_webview_settings.dart';
import 'platform_headless_in_app_webview.dart';
import 'platform_inappwebview_widget.dart';
import 'platform_webview.dart';

part 'platform_inappwebview_controller.g.dart';

///List of forbidden names for JavaScript handlers used internally bu the plugin.
final kJavaScriptHandlerForbiddenNames = UnmodifiableListView<String>([
  "onLoadResource",
  "onConsoleMessage",
  "shouldInterceptAjaxRequest",
  "onAjaxReadyStateChange",
  "onAjaxProgress",
  "shouldInterceptFetchRequest",
  "onPrintRequest",
  "onWindowFocus",
  "onWindowBlur",
  "callAsyncJavaScript",
  "evaluateJavaScriptWithContentWorld",
  "onFindResultReceived",
  "onWebMessagePortMessageReceived",
  "onWebMessageListenerPostMessageReceived",
  "onScrollChanged",
]);

/// Object specifying creation parameters for creating a [PlatformInAppWebViewController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformInAppWebViewControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInAppWebViewController].
  const PlatformInAppWebViewControllerCreationParams({
    required this.id,
    this.webviewParams,
  });

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.id}
  final dynamic id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webviewParams}
  final PlatformWebViewCreationParams? webviewParams;
}

///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController}
///Controls a WebView, such as an [InAppWebView] widget instance, a [HeadlessInAppWebView] instance or [PlatformInAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [PlatformInAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [PlatformInAppBrowser] instance, you can get it through the [PlatformInAppBrowser.webViewController] attribute.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
abstract class PlatformInAppWebViewController extends PlatformInterface
    implements Disposable {
  ///Debug settings used by [PlatformInAppWebViewWidget], [PlatformHeadlessInAppWebView] and [PlatformInAppBrowser].
  ///The default value excludes the [PlatformWebViewCreationParams.onScrollChanged] and [PlatformWebViewCreationParams.onOverScrolled] events.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings(
    maxLogMessageLength: 1000,
    excludeFilter: [RegExp(r"onScrollChanged"), RegExp(r"onOverScrolled")],
  );

  /// Creates a new [PlatformInAppWebViewController]
  factory PlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewController inAppWebViewController =
        InAppWebViewPlatform.instance!.createPlatformInAppWebViewController(
          params,
        );
    PlatformInterface.verify(inAppWebViewController, _token);
    return inAppWebViewController;
  }

  /// Creates a new [PlatformInAppWebViewController] to access static methods.
  factory PlatformInAppWebViewController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppWebViewController inAppWebViewControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformInAppWebViewControllerStatic();
    PlatformInterface.verify(inAppWebViewControllerStatic, _token);
    return inAppWebViewControllerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformInAppWebViewController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInAppWebViewController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInAppWebViewController].
  final PlatformInAppWebViewControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.id}
  /// WebView ID.
  ///{@endtemplate}
  dynamic get id => params.id;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webviewParams}
  /// WebView params.
  ///{@endtemplate}
  PlatformWebViewCreationParams? get webviewParams => params.webviewParams;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage}
  ///Provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  PlatformWebStorage get webStorage => throw UnimplementedError(
    '${PlatformInAppWebViewControllerProperty.webStorage.name} is not implemented on the current platform',
  );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl}
  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [PlatformWebViewCreationParams.onLoadStart] because although the load for that URL has begun, the current page may not have changed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getUrl()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.url',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1415005-url',
      ),
    ],
  )
  Future<WebUri?> getUrl() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle}
  ///Gets the title for the current page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getTitle',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getTitle()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.title',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1415015-title',
      ),
    ],
  )
  Future<String?> getTitle() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getTitle.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress}
  ///Gets the progress for the current page. The progress value is between 0 and 100.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getProgress',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getProgress()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.estimatedProgress',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress',
      ),
    ],
  )
  Future<int?> getProgress() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getProgress.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml}
  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  ///
  ///Returns `null` if it was unable to get it.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<String?> getHtml() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getHtml.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons}
  ///Gets the list of all favicons for the current page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<List<Favicon>> getFavicons() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getFavicons.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl}
  ///Loads the given [urlRequest].
  ///
  ///- [allowingReadAccessTo], used in combination with [urlRequest] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the URL parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.loadUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)',
        note:
            'If method is "POST", [Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])). Also, when loading an URL Request using "POST" method, headers are ignored.',
      ),
      IOSPlatform(
        apiName: 'WKWebView.load',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414954-load',
        note:
            'If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)',
      ),
    ],
  )
  Future<void> loadUrl({
    required URLRequest urlRequest,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    WebUri? allowingReadAccessTo,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.loadUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl}
  ///Loads the given [url] with [postData] (x-www-form-urlencoded) using `POST` method into this WebView.
  ///
  ///Example:
  ///```dart
  ///var postData = Uint8List.fromList(utf8.encode("firstname=Foo&surname=Bar"));
  ///controller.postUrl(url: WebUri("https://www.example.com/"), postData: postData);
  ///```
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.postUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])',
      ),
      IOSPlatform(),
    ],
  )
  Future<void> postUrl({required WebUri url, required Uint8List postData}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.postUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadData}
  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///
  ///- [mimeType] argument specifies the format of the data. The default value is `"text/html"`.
  ///- [encoding] argument specifies the encoding of the data. The default value is `"utf8"`.
  ///- [historyUrl] represents the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///- [allowingReadAccessTo], used in combination with [baseUrl] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This [baseUrl] must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [baseUrl] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.loadDataWithBaseURL',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKWebView.loadHTMLString',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring',
        note:
            'or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load)',
      ),
    ],
  )
  Future<void> loadData({
    required String data,
    @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
    String mimeType = "text/html",
    @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
    String encoding = "utf8",
    @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
    WebUri? baseUrl,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) WebUri? historyUrl,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    WebUri? allowingReadAccessTo,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.loadData.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile}
  ///Loads the given [assetFilePath].
  ///
  ///To be able to load your local files (assets, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!
  ///
  ///Example of a `pubspec.yaml` file:
  ///```yaml
  ///...
  ///
  ///# The following section is specific to Flutter.
  ///flutter:
  ///
  ///  # The following line ensures that the Material Icons font is
  ///  # included with your application, so that you can use the icons in
  ///  # the material Icons class.
  ///  uses-material-design: true
  ///
  ///  assets:
  ///    - assets/index.html
  ///    - assets/css/
  ///    - assets/images/
  ///
  ///...
  ///```
  ///Example:
  ///```dart
  ///...
  ///controller.loadFile(assetFilePath: "assets/index.html");
  ///...
  ///```
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.loadUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKWebView.load',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414954-load',
      ),
    ],
  )
  Future<void> loadFile({required String assetFilePath}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.loadFile.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reload}
  ///Reloads the WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reload.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.reload',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#reload()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.reload',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload',
      ),
    ],
  )
  Future<void> reload() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.reload.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBack}
  ///Goes back in the history of the WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBack.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.goBack',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#goBack()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.goBack',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback',
      ),
    ],
  )
  Future<void> goBack() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.goBack.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack}
  ///Returns a boolean value indicating whether the WebView can move backward.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.canGoBack',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#canGoBack()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.canGoBack',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback',
      ),
    ],
  )
  Future<bool> canGoBack() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.canGoBack.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goForward}
  ///Goes forward in the history of the WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goForward.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.goForward',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#goForward()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.goForward',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward',
      ),
    ],
  )
  Future<void> goForward() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.goForward.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward}
  ///Returns a boolean value indicating whether the WebView can move forward.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.canGoForward',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#canGoForward()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.canGoForward',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward',
      ),
    ],
  )
  Future<bool> canGoForward() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.canGoForward.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward}
  ///Goes to the history item that is the number of [steps] away from the current item. Steps is negative if backward and positive if forward.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.goBackOrForward',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#goBackOrForward(int)',
      ),
      IOSPlatform(
        apiName: 'WKWebView.go',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414991-go',
      ),
    ],
  )
  Future<void> goBackOrForward({required int steps}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.goBackOrForward.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward}
  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of [steps].
  ///Steps is negative if backward and positive if forward.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.canGoBackOrForward',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#canGoBackOrForward(int)',
      ),
      IOSPlatform(),
    ],
  )
  Future<bool> canGoBackOrForward({required int steps}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.canGoBackOrForward.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goTo}
  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goTo.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> goTo({required WebHistoryItem historyItem}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.goTo.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading}
  ///Check if the WebView instance is in a loading state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<bool> isLoading() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isLoading.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading}
  ///Stops the WebView from loading.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.stopLoading',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#stopLoading()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.stopLoading',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading',
      ),
    ],
  )
  Future<void> stopLoading() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.stopLoading.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript}
  ///Evaluates JavaScript [source] code into the WebView and returns the result of the evaluation.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe, using `eval(source);` to get and return the result.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.evaluateJavascript',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)',
      ),
      IOSPlatform(
        apiName: 'WKWebView.evaluateJavaScript',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript',
      ),
    ],
  )
  Future<dynamic> evaluateJavascript({
    required String source,
    @SupportedPlatforms(
      platforms: [
        AndroidPlatform(),
        IOSPlatform(available: '14.0'),
      ],
    )
    ContentWorld? contentWorld,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.evaluateJavascript.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl}
  ///Injects an external JavaScript file into the WebView from a defined url.
  ///
  ///[scriptHtmlTagAttributes] represents the possible the `<script>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.injectJavascriptFileFromUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset}
  ///Evaluates the content of a JavaScript file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<dynamic> injectJavascriptFileFromAsset({
    required String assetFilePath,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.injectJavascriptFileFromAsset.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode}
  ///Injects CSS into the WebView.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> injectCSSCode({required String source}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.injectCSSCode.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl}
  ///Injects an external CSS file into the WebView from a defined url.
  ///
  ///[cssLinkHtmlTagAttributes] represents the possible CSS stylesheet `<link>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset}
  ///Injects a CSS file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.injectCSSFileFromAsset.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler}
  ///Adds a JavaScript message handler [callback] ([JavaScriptHandlerFunction]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///Forbidden [handlerName]s are represented by [kJavaScriptHandlerForbiddenNames], they are used internally by this plugin.
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)`,
  ///where `window.flutter_inappwebview` is the default JavaScript bridge object injected in the WebView and
  ///`args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  ///
  ///To get the default JavaScript bridge object name, you can use the [getJavaScriptBridgeName] method.
  ///To change the default JavaScript bridge object name, you can use the [setJavaScriptBridgeName] method.
  ///
  ///In order to call `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppWebViewPlatformReady`.
  ///This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
  ///```javascript
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     console.log("ready");
  ///   });
  ///```
  ///
  ///`window.flutter_inappwebview.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  ///that can be used to get the json result returned by [JavaScriptHandlerFunction].
  ///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
  ///
  ///So, on the JavaScript side, to get data coming from the Dart side, you will use:
  ///```html
  ///<script>
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     window.flutter_inappwebview.callHandler('handlerFoo').then(function(result) {
  ///       console.log(result);
  ///     });
  ///
  ///     window.flutter_inappwebview.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
  ///       console.log(result);
  ///     });
  ///   });
  ///</script>
  ///```
  ///
  ///Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
  ///```dart
  ///  // Inject JavaScript that will receive data back from Flutter
  ///  inAppWebViewController.evaluateJavascript(source: """
  ///    window.flutter_inappwebview.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  ///
  ///There could be forbidden names for JavaScript handlers depending on the implementation platform.
  ///
  ///**NOTE**: This method should be called, for example, in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events or, at least,
  ///before you know that your JavaScript code will call the `window.flutter_inappwebview.callHandler` method,
  ///otherwise you won't be able to intercept the JavaScript message.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.addJavaScriptHandler.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler}
  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Function? removeJavaScriptHandler({required String handlerName}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.removeJavaScriptHandler.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler}
  ///Returns `true` if a JavaScript handler with [handlerName] already exists, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool hasJavaScriptHandler({required String handlerName}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.hasJavaScriptHandler.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot}
  ///Takes a screenshot of the WebView's visible viewport and returns a [Uint8List]. Returns `null` if it wasn't be able to take it.
  ///
  ///[screenshotConfiguration] represents the configuration data to use when generating an image from a web view’s contents.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        note:
            'To be able to take screenshots outside the visible viewport, you must call [PlatformInAppWebViewController.enableSlowWholeDocumentDraw] before any WebViews are created.',
      ),
      IOSPlatform(
        apiName: 'WKWebView.takeSnapshot',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot',
        available: '11.0',
      ),
    ],
  )
  Future<Uint8List?> takeScreenshot({
    ScreenshotConfiguration? screenshotConfiguration,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.takeScreenshot.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings}
  ///Sets the WebView settings with the new [settings] and evaluates them.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> setSettings({required InAppWebViewSettings settings}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setSettings.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings}
  ///Gets the current WebView settings. Returns `null` if it wasn't able to get them.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<InAppWebViewSettings?> getSettings() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getSettings.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList}
  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.copyBackForwardList',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#copyBackForwardList()',
      ),
      IOSPlatform(
        apiName: 'WKWebView.backForwardList',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist',
      ),
    ],
  )
  Future<WebHistory?> getCopyBackForwardList() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getCopyBackForwardList.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo}
  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.scrollTo',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#scrollTo(int,%20int)',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.setContentOffset',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset',
      ),
    ],
  )
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.scrollTo.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy}
  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.scrollBy',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.setContentOffset',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset',
      ),
    ],
  )
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.scrollBy.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers}
  ///On Android native WebView, it pauses all layout, parsing, and JavaScript timers for all WebViews.
  ///This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.pauseTimers',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#pauseTimers()',
      ),
      IOSPlatform(
        note:
            'This method is implemented using JavaScript and it is restricted to just this WebView.',
      ),
    ],
  )
  Future<void> pauseTimers() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.pauseTimers.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers}
  ///On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.resumeTimers',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#resumeTimers()',
      ),
      IOSPlatform(
        note:
            'This method is implemented using JavaScript and it is restricted to just this WebView.',
      ),
    ],
  )
  Future<void> resumeTimers() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.resumeTimers.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage}
  ///Prints the current page.
  ///
  ///To obtain the [PlatformPrintJobController], use [settings] argument with [PrintJobSettings.handledByClient] to `true`.
  ///Otherwise this method will return `null` and the [PlatformPrintJobController] will be handled and disposed automatically by the system.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'PrintManager.print',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintManager#print(java.lang.String,%20android.print.PrintDocumentAdapter,%20android.print.PrintAttributes)',
      ),
      IOSPlatform(
        apiName: 'UIPrintInteractionController.present',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618149-present',
      ),
    ],
  )
  Future<PlatformPrintJobController?> printCurrentPage({
    PrintJobSettings? settings,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.printCurrentPage.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight}
  ///Gets the height of the HTML content.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getContentHeight',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getContentHeight()',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.contentSize',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize',
      ),
    ],
  )
  Future<int?> getContentHeight() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getContentHeight.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth}
  ///Gets the width of the HTML content.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This method is implemented using JavaScript.'),
      IOSPlatform(
        apiName: 'UIScrollView.contentSize',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize',
      ),
    ],
  )
  Future<int?> getContentWidth() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getContentWidth.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy}
  ///Performs a zoom operation in this WebView.
  ///
  ///[zoomFactor] represents the zoom factor to apply. On Android, the zoom factor will be clamped to the Webview's zoom limits and, also, this value must be in the range 0.01 (excluded) to 100.0 (included).
  ///
  ///[animated] `true` to animate the transition to the new scale, `false` to make the transition immediate.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.zoomBy',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#zoomBy(float)',
        available: '21',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.setZoomScale',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619412-setzoomscale',
      ),
    ],
  )
  Future<void> zoomBy({
    required double zoomFactor,
    @SupportedPlatforms(platforms: [IOSPlatform()]) bool animated = false,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.zoomBy.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl}
  ///Gets the URL that was originally requested for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStart] because although the load for that URL has begun,
  ///the current page may not have changed. Also, there may have been redirects resulting in a different URL to that originally requested.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getOriginalUrl',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getOriginalUrl()',
      ),
      IOSPlatform(),
    ],
  )
  Future<WebUri?> getOriginalUrl() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getOriginalUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale}
  ///Gets the current zoom scale of the WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'UIScrollView.zoomScale',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619419-zoomscale',
      ),
    ],
  )
  Future<double?> getZoomScale() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getZoomScale.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText}
  ///Gets the selected text.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This method is implemented using JavaScript.'),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<String?> getSelectedText() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getSelectedText.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult}
  ///Gets the hit result for hitting an HTML elements.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getHitTestResult',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getHitTestResult()',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<InAppWebViewHitTestResult?> getHitTestResult() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getHitTestResult.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus}
  ///Call this method when you want to try the WebView to be the first responder.
  ///
  ///On Android, call this to try to give focus to the WebView and
  ///give it hints about the [direction] and a specific [previouslyFocusedRect] that the focus is coming from.
  ///The [previouslyFocusedRect] can help give larger views a finer grained hint about where focus is coming from,
  ///and therefore, where to show selection, or forward focus change internally.
  ///
  ///Returns `true` whether this WebView actually took focus; otherwise, `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.requestFocus',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#requestFocus(int,%20android.graphics.Rect)',
      ),
      IOSPlatform(
        apiName: 'UIResponder.becomeFirstResponder',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiresponder/1621113-becomefirstresponder',
      ),
    ],
  )
  Future<bool?> requestFocus({
    @SupportedPlatforms(platforms: [AndroidPlatform()])
    FocusDirection? direction,
    @SupportedPlatforms(platforms: [AndroidPlatform()])
    InAppWebViewRect? previouslyFocusedRect,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.requestFocus.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus}
  ///Clears the current focus. On iOS and Android native WebView, it will clear also, for example, the current text selection.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ViewGroup.clearFocus',
        apiUrl:
            'https://developer.android.com/reference/android/view/ViewGroup#clearFocus()',
      ),
      IOSPlatform(
        apiName: 'UIResponder.resignFirstResponder',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder',
      ),
    ],
  )
  Future<void> clearFocus() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearFocus.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled}
  ///Enables/Disables the input method (system-supplied keyboard) whilst interacting with the webview.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'UIResponder.inputView',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiresponder/1621092-inputview',
      ),
    ],
  )
  Future<void> setInputMethodEnabled(bool enabled) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setInputMethodEnabled.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod}
  ///Explicitly request that the current input method's soft input area be shown to the user, if needed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'InputMethodManager.showSoftInput',
        apiUrl:
            'https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#showSoftInput(android.view.View,%20int)',
      ),
    ],
  )
  Future<void> showInputMethod() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.showInputMethod.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAudioMuted}
  ///Mutes or unmutes all audio output from this WebView.
  ///
  ///Muting is a property of the WebView itself, so it survives navigation and applies to every
  ///media element and Web Audio context in the page, including ones created later.
  ///
  ///Check [isAudioMuted] to read the current state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAudioMuted.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.setAudioMuted',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#setAudioMuted(android.webkit.WebView,boolean)',
        note:
            'Requires [WebViewFeature.MUTE_AUDIO]. Does nothing if the feature is not supported.',
      ),
    ],
  )
  Future<void> setAudioMuted(bool muted) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setAudioMuted.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isAudioMuted}
  ///Returns whether audio output from this WebView is currently muted.
  ///
  ///Returns `false` when [WebViewFeature.MUTE_AUDIO] is not supported, since audio cannot have
  ///been muted through [setAudioMuted] in that case.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isAudioMuted.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.isAudioMuted',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#isAudioMuted(android.webkit.WebView)',
        note: 'Requires [WebViewFeature.MUTE_AUDIO].',
      ),
    ],
  )
  Future<bool> isAudioMuted() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isAudioMuted.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.prerenderUrl}
  ///Asks this WebView to prerender [url], so that a later navigation to it is instant.
  ///
  ///The page is loaded and rendered in the background, ahead of any navigation. If this WebView
  ///later navigates to the same url, the prerendered result is activated instead of being fetched
  ///again; if it never does, the WebView discards it.
  ///
  ///This is a hint, not a guarantee, and it costs memory and network for a page the user may never
  ///visit — so it is worth doing for a destination you have good reason to expect, such as the
  ///target of a link the user is hovering or the next step of a flow they have started.
  ///
  ///Returns `true` if the prerender was **requested**, and `false` when
  ///[WebViewFeature.PRERENDER_WITH_URL] is not supported. It does not wait for the prerender to
  ///finish, be used, or fail.
  ///
  ///**Outcomes are not reported back.** The platform reports activation and failure through a
  ///callback, but activation can happen long after this call or never at all, so surfacing it as a
  ///`Future` would leave one uncompleted for the lifetime of the WebView. Both outcomes are logged
  ///natively instead. A prerender that fails simply means the eventual navigation loads normally.
  ///
  ///It cannot be cancelled.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.prerenderUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.prerenderUrlAsync',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#prerenderUrlAsync(android.webkit.WebView,java.lang.String,android.os.CancellationSignal,java.util.concurrent.Executor,androidx.webkit.PrerenderOperationCallback)',
        note:
            'Requires [WebViewFeature.PRERENDER_WITH_URL]. Returns `false` and prerenders nothing if the feature is not supported.',
      ),
    ],
  )
  Future<bool> prerenderUrl(WebUri url) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.prerenderUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.flingScroll}
  ///Starts a fling — a scroll that is thrown with an initial velocity and then decelerates on its
  ///own, the way a flick of the finger does.
  ///
  ///[velocityX] and [velocityY] are the initial velocity in **pixels per second**, in the same
  ///raw device pixels [scrollTo] and [scrollBy] use, with the same sign convention: positive
  ///values fling the content towards its end (right and down).
  ///
  ///This is a third thing, distinct from the two the plugin already has:
  ///
  ///- [scrollTo] goes to an absolute position;
  ///- [scrollBy] moves by a fixed amount — with `animated: true` over a fixed 300ms;
  ///- this one only sets a *velocity*. Where it stops is decided by the platform's deceleration
  ///  and by where the content ends, so the distance is not something the caller specifies or can
  ///  predict.
  ///
  ///Use it to reproduce a flick rather than to reach a known position — for a known position,
  ///[scrollTo] is both simpler and exact.
  ///
  ///The fling is clamped to the scrollable range, so an over-large velocity stops at the edge
  ///rather than overscrolling indefinitely, and a velocity on an unscrollable axis does nothing.
  ///
  ///**The platform documents no units.** `WebView.flingScroll` carries no javadoc in AOSP at all;
  ///pixels per second is what its implementation does, and it is what matches this plugin's other
  ///scroll methods, which also pass raw pixels straight through without density conversion.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.flingScroll.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.flingScroll',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#flingScroll(int,%20int)',
      ),
    ],
  )
  Future<void> flingScroll({required int velocityX, required int velocityY}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.flingScroll.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.documentHasImages}
  ///Returns whether the currently loaded document references any image at all.
  ///
  ///It is a question about the **document**, not about rendering or loading: an `<img>` whose
  ///source is broken or still downloading still counts as a reference. Nothing is reported about
  ///how many there are or where they point.
  ///
  ///Returns `false` if this controller no longer has a WebView, matching
  ///[canGoBack] and the other boolean reads on this class — a disposed controller has no document,
  ///so there is nothing for it to reference.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.documentHasImages.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.documentHasImages',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#documentHasImages(android.os.Message)',
        note:
            'The platform answers by dispatching an `android.os.Message` rather than returning a value; this API awaits it.',
      ),
    ],
  )
  Future<bool> documentHasImages() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.documentHasImages.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postVisualStateCallback}
  ///Completes once the DOM **as it exists at the moment of this call** has been drawn to the
  ///screen.
  ///
  ///This is the "do not reveal it until it is actually painted" primitive: load or mutate content
  ///while the WebView is hidden, `await` this, and only then show it — which avoids the blank or
  ///half-drawn frame that showing it on [PlatformWebViewCreationParams.onLoadStop] can produce.
  ///
  ///It is **not** [PlatformWebViewCreationParams.onPageCommitVisible], which the plugin also
  ///reports. That event is engine-driven and fires once per navigation, at the first paint after a
  ///commit. This is caller-driven and answers about *now*, so it can be used after a DOM change
  ///that involved no navigation at all.
  ///
  ///Later DOM changes are not covered — the guarantee is about the state captured when the call was
  ///made, not about anything drawn afterwards.
  ///
  ///**It can fail to complete.** The platform never invokes the callback if the WebView is
  ///destroyed first, and there is no native timeout, so a caller that must not block forever should
  ///apply its own with `Future.timeout`. The plugin deliberately does not impose one, because any
  ///value it picked would be wrong for a page heavy enough to matter.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postVisualStateCallback.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.postVisualStateCallback',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#postVisualStateCallback(long,%20android.webkit.WebView.VisualStateCallback)',
        note:
            'The platform takes a `requestId` to correlate its callback; this API omits it because the returned `Future` already correlates the reply with the call.',
      ),
    ],
  )
  Future<void> postVisualStateCallback() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.postVisualStateCallback.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod}
  ///Request to hide the soft input view from the context of the view that is currently accepting input.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'InputMethodManager.hideSoftInputFromWindow',
        apiUrl:
            'https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#hideSoftInputFromWindow(android.os.IBinder,%20int)',
      ),
      IOSPlatform(
        apiName: 'UIView.endEditing',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiview/1619630-endediting',
      ),
    ],
  )
  Future<void> hideInputMethod() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.hideInputMethod.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu}
  ///Sets or updates the WebView context menu to be used next time it will appear.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> setContextMenu(ContextMenu? contextMenu) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setContextMenu.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref}
  ///Requests the anchor or image element URL at the last tapped point.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.requestFocusNodeHref',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#requestFocusNodeHref(android.os.Message)',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.requestFocusNodeHref.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef}
  ///Requests the URL of the image last touched by the user.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.requestImageRef',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#requestImageRef(android.os.Message)',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<RequestImageRefResult?> requestImageRef() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.requestImageRef.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags}
  ///Returns the list of `<meta>` tags of the current WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This method is implemented using JavaScript.'),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<List<MetaTag>> getMetaTags() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getMetaTags.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor}
  ///Returns an instance of [Color] representing the `content` value of the
  ///`<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(note: 'This method is implemented using JavaScript.'),
      IOSPlatform(
        apiName: 'WKWebView.themeColor',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor',
        note: 'On iOS < 15.0, this method is implemented using JavaScript.',
      ),
    ],
  )
  Future<Color?> getMetaThemeColor() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getMetaThemeColor.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX}
  ///Returns the scrolled left position of the current WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.getScrollX',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#getScrollX()',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.contentOffset',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset',
      ),
    ],
  )
  Future<int?> getScrollX() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getScrollX.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY}
  ///Returns the scrolled top position of the current WebView.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'View.getScrollY',
        apiUrl:
            'https://developer.android.com/reference/android/view/View#getScrollY()',
      ),
      IOSPlatform(
        apiName: 'UIScrollView.contentOffset',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset',
      ),
    ],
  )
  Future<int?> getScrollY() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getScrollY.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate}
  ///Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.getCertificate',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#getCertificate()',
      ),
      IOSPlatform(
        note:
            'WebKit has no equivalent API, so this is the certificate the plugin recorded during a `NSURLAuthenticationMethodServerTrust` challenge for the page\'s host. **WebKit issues that challenge only once per host per process**: a second WebView loading the same host is not challenged at all, so the certificate is process-wide and can predate the current page load, this WebView, and even the WebView that is asking. It is `null` until the process has been challenged for that host at least once — which, for the very first load of a host, may be after `onLoadStop`.',
      ),
    ],
  )
  Future<SslCertificate?> getCertificate() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getCertificate.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript}
  ///Injects the specified [userScript] into the webpage’s content.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'WKUserContentController.addUserScript',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript',
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<void> addUserScript({required UserScript userScript}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.addUserScript.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts}
  ///Injects the [userScripts] into the webpage’s content.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<void> addUserScripts({required List<UserScript> userScripts}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.addUserScripts.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript}
  ///Removes the specified [userScript] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///Returns `true` if [userScript] was in the list, `false` otherwise.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<bool> removeUserScript({required UserScript userScript}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.removeUserScript.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName}
  ///Removes all the [UserScript]s with [groupName] as group name from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<void> removeUserScriptsByGroupName({required String groupName}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.removeUserScriptsByGroupName.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts}
  ///Removes the [userScripts] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<void> removeUserScripts({required List<UserScript> userScripts}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.removeUserScripts.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts}
  ///Removes all the user scripts from the webpage’s content.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(
        apiName: 'WKUserContentController.removeAllUserScripts',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts',
        note:
            "This method will throw an error if the [PlatformWebViewCreationParams.windowId] has been set. There isn't any way to add/remove user scripts specific to window WebViews. This is a limitation of the native WebKit APIs.",
      ),
    ],
  )
  Future<void> removeAllUserScripts() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.removeAllUserScripts.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript}
  ///Returns `true` if the [userScript] has been already added, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool hasUserScript({required UserScript userScript}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.hasUserScript.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript}
  ///Executes the specified string as an asynchronous JavaScript function.
  ///
  ///[functionBody] is the JavaScript string to use as the function body.
  ///This method treats the string as an anonymous JavaScript function body and calls it with the named arguments in the arguments parameter.
  ///
  ///[arguments] is a `Map` of the arguments to pass to the function call.
  ///Each key in the `Map` corresponds to the name of an argument in the [functionBody] string,
  ///and the value of that key is the value to use during the evaluation of the code.
  ///Supported value types can be found in the official Flutter docs:
  ///[Platform channel data types support and codecs](https://flutter.dev/docs/development/platform-integration/platform-channels#codec),
  ///except for [Uint8List], [Int32List], [Int64List], and [Float64List] that should be converted into a [List].
  ///All items in a `List` or `Map` must also be one of the supported types.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///
  ///**NOTE**: This method shouldn't be called in the [PlatformWebViewCreationParams.onWebViewCreated] or [PlatformWebViewCreationParams.onLoadStart] events,
  ///because, in these events, the `WebView` is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [PlatformWebViewCreationParams.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(available: '21'),
      IOSPlatform(
        apiName: 'WKWebView.callAsyncJavaScript',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript',
        available: '14.3',
      ),
    ],
  )
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const <String, dynamic>{},
    ContentWorld? contentWorld,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.callAsyncJavaScript.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive}
  ///Saves the current WebView as a web archive.
  ///Returns the file path under which the web archive file was saved, or `null` if saving the file failed.
  ///
  ///[filePath] represents the file path where the archive should be placed. This value cannot be `null`.
  ///
  ///[autoname] if `false`, takes [filePath] to be a file.
  ///If `true`, [filePath] is assumed to be a directory in which a filename will be chosen according to the URL of the current page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.saveWebArchive',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#saveWebArchive(java.lang.String,%20boolean,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)',
        note:
            'If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.',
      ),
      IOSPlatform(
        available: '14.0',
        note:
            'If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.',
      ),
    ],
  )
  Future<String?> saveWebArchive({
    required String filePath,
    bool autoname = false,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.saveWebArchive.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext}
  ///Indicates whether the webpage context is capable of using features that require [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: '21',
        note: 'This method is implemented using JavaScript.',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<bool> isSecureContext() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isSecureContext.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel}
  ///Creates a message channel to communicate with JavaScript and returns the message channel with ports that represent the endpoints of this message channel.
  ///The HTML5 message channel functionality is described [here](https://html.spec.whatwg.org/multipage/comms.html#messagechannel).
  ///
  ///The returned message channels are entangled and already in started state.
  ///
  ///This method should be called when the page is loaded, for example, when the [PlatformWebViewCreationParams.onLoadStop] is fired, otherwise the [PlatformWebMessageChannel] won't work.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.createWebMessageChannel',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#createWebMessageChannel(android.webkit.WebView)',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL].',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<PlatformWebMessageChannel?> createWebMessageChannel() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.createWebMessageChannel.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage}
  ///Post a message to main frame. The embedded application can restrict the messages to a certain target origin.
  ///See [HTML5 spec](https://html.spec.whatwg.org/multipage/comms.html#posting-messages) for how target origin can be used.
  ///
  ///A target origin can be set as a wildcard ("*"). However this is not recommended.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.postWebMessage',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#postWebMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri)',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.POST_WEB_MESSAGE].',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<void> postWebMessage({
    required WebMessage message,
    WebUri? targetOrigin,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.postWebMessage.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener}
  ///Adds a [PlatformWebMessageListener] to the WebView and injects a JavaScript object into each frame that the [PlatformWebMessageListener] will listen on.
  ///
  ///The injected JavaScript object will be named [PlatformWebMessageListener.jsObjectName] in the global scope.
  ///This will inject the JavaScript object in any frame whose origin matches [PlatformWebMessageListener.allowedOriginRules]
  ///for every navigation after this call, and the JavaScript object will be available immediately when the page begins to load.
  ///
  ///Each [PlatformWebMessageListener.allowedOriginRules] entry must follow the format `SCHEME "://" [ HOSTNAME_PATTERN [ ":" PORT ] ]`, each part is explained in the below table:
  ///
  ///<table>
  ///   <colgroup>
  ///      <col width="25%">
  ///   </colgroup>
  ///   <tbody>
  ///      <tr>
  ///         <th>Rule</th>
  ///         <th>Description</th>
  ///         <th>Example</th>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with hostname</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a regular hostname; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port
  ///            <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://foobar.com:8080</code> - Matches https:// URL on port 8080, whose normalized
  ///                  host is foobar.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://www.example.com</code> - Matches https:// URL on port 443, whose normalized host
  ///                  is www.example.com.
  ///               </li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with pattern matching</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a sub-domain matching
  ///            pattern with a leading <code translate="no" dir="ltr">*.<wbr></code>; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will
  ///            match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://*.example.com</code> - Matches https://calendar.example.com and
  ///                  https://foo.bar.example.com but not https://example.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://*.example.com:8080</code> - Matches https://calendar.example.com:8080</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with IP literal</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is https or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is IP literal; <code translate="no" dir="ltr">PORT</code> is
  ///            optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code>
  ///            for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://127.0.0.1</code> - Matches https:// URL on port 443, whose IPv4 address is
  ///                  127.0.0.1
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]</code> or <code translate="no" dir="ltr">https://[0:0::1]</code>- Matches any URL to the IPv6 loopback
  ///                  address with port 443.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]:99</code> - Matches any https:// URL to the IPv6 loopback on port 99.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>Custom scheme</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is a custom scheme; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> and <code translate="no" dir="ltr">PORT</code> must not be
  ///            present.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">my-app-scheme://</code> - Matches any my-app-scheme:// URL.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td><code translate="no" dir="ltr">*</code></td>
  ///         <td>Wildcard rule, matches any origin.</td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">*</code></li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///   </tbody>
  ///</table>
  ///
  ///Note that this is a powerful API, as the JavaScript object will be injected when the frame's origin matches any one of the allowed origins.
  ///The HTTPS scheme is strongly recommended for security; allowing HTTP origins exposes the injected object to any potential network-based attackers.
  ///If a wildcard "*" is provided, it will inject the JavaScript object to all frames.
  ///A wildcard should only be used if the app wants **any** third party web page to be able to use the injected object.
  ///When using a wildcard, the app must treat received messages as untrustworthy and validate any data carefully.
  ///
  ///This method can be called multiple times to inject multiple JavaScript objects.
  ///
  ///Let's say the injected JavaScript object is named `myObject`. We will have following methods on that object once it is available to use:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// // message needs to be a JavaScript String, MessagePorts is an optional parameter.
  /// myObject.postMessage(message[, MessagePorts]) // on Android
  /// myObject.postMessage(message) // on iOS
  ///
  /// // To receive messages posted from the app side, assign a function to the "onmessage"
  /// // property. This function should accept a single "event" argument. "event" has a "data"
  /// // property, which is the message string from the app side.
  /// myObject.onmessage = function(event) { ... }
  ///
  /// // To be compatible with DOM EventTarget's addEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject. An event object will be passed to listener with a "data" property,
  /// // which is the message string from the app side.
  /// myObject.addEventListener(type, listener)
  ///
  /// // To be compatible with DOM EventTarget's removeEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject.
  /// myObject.removeEventListener(type, listener)
  ///```
  ///
  ///We start the communication between JavaScript and the app from the JavaScript side.
  ///In order to send message from the app to JavaScript, it needs to post a message from JavaScript first,
  ///so the app will have a [PlatformJavaScriptReplyProxy] object to respond. Example:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// myObject.onmessage = function(event) {
  ///   // prints "Got it!" when we receive the app's response.
  ///   console.log(event.data);
  /// }
  /// myObject.postMessage("I'm ready!");
  ///```
  ///
  ///```dart
  /// // Flutter App
  /// child: InAppWebView(
  ///   onWebViewCreated: (controller) async {
  ///     if (defaultTargetPlatform != TargetPlatform.android || await WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
  ///       await controller.addWebMessageListener(WebMessageListener(
  ///         jsObjectName: "myObject",
  ///         onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
  ///           // do something about message, sourceOrigin and isMainFrame.
  ///           replyProxy.postMessage("Got it!");
  ///         },
  ///       ));
  ///     }
  ///     await controller.loadUrl(urlRequest: URLRequest(url: WebUri("https://www.example.com")));
  ///   },
  /// ),
  ///```
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.WebMessageListener',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#addWebMessageListener(android.webkit.WebView,%20java.lang.String,%20java.util.Set%3Cjava.lang.String%3E,%20androidx.webkit.WebViewCompat.WebMessageListener)',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.WEB_MESSAGE_LISTENER].',
      ),
      IOSPlatform(note: 'This method is implemented using JavaScript.'),
    ],
  )
  Future<void> addWebMessageListener(
    PlatformWebMessageListener webMessageListener,
  ) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.addWebMessageListener.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener}
  ///Returns `true` if the [webMessageListener] has been already added, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.hasWebMessageListener.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically}
  ///Returns `true` if the webpage can scroll vertically, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<bool> canScrollVertically() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.canScrollVertically.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally}
  ///Returns `true` if the webpage can scroll horizontally, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<bool> canScrollHorizontally() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.canScrollHorizontally.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences}
  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.clearSslPreferences',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()',
      ),
    ],
  )
  Future<void> clearSslPreferences() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearSslPreferences.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pause}
  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [PlatformInAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pause.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onPause',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onPause()',
      ),
    ],
  )
  Future<void> pause() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.pause.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resume}
  ///Resumes a WebView after a previous call to [pause].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resume.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.onResume',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#onResume()',
      ),
    ],
  )
  Future<void> resume() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.resume.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown}
  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.pageDown',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)',
      ),
    ],
  )
  Future<bool> pageDown({required bool bottom}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.pageDown.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp}
  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[top] `true` to jump to the top of the page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.pageUp',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)',
      ),
    ],
  )
  Future<bool> pageUp({required bool top}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.pageUp.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn}
  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.zoomIn',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#zoomIn()',
      ),
    ],
  )
  Future<bool> zoomIn() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.zoomIn.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut}
  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.zoomOut',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#zoomOut()',
      ),
    ],
  )
  Future<bool> zoomOut() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.zoomOut.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory}
  ///Clears the internal back/forward list.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.clearHistory',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#clearHistory()',
      ),
    ],
  )
  Future<void> clearHistory() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearHistory.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData}
  ///Removes the autocomplete popup from the currently focused form field, if present.
  ///Note this only affects the display of the autocomplete popup,
  ///it does not remove any saved form data from this WebView's store.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.clearFormData',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#clearFormData()',
      ),
    ],
  )
  Future<void> clearFormData() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearFormData.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin}
  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.reloadFromOrigin',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin',
      ),
    ],
  )
  Future<void> reloadFromOrigin() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.reloadFromOrigin.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf}
  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[pdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.createPdf',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf',
        available: '14.0',
      ),
    ],
  )
  Future<Uint8List?> createPdf({PDFConfiguration? pdfConfiguration}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.createPdf.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData}
  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.createWebArchiveData',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata',
        available: '14.0',
      ),
    ],
  )
  Future<Uint8List?> createWebArchiveData() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.createWebArchiveData.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent}
  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.hasOnlySecureContent',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent',
      ),
    ],
  )
  Future<bool> hasOnlySecureContent() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.hasOnlySecureContent.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isBlockedByScreenTime}
  ///Returns whether Screen Time restrictions are currently blocking the content of this WebView.
  ///
  ///Returns `null` when the platform cannot answer — on any platform other than iOS, and on iOS
  ///versions below 26.0, where the underlying property does not exist. That is deliberately
  ///distinct from `false`, which means *the platform was asked and the content is not blocked*.
  ///
  ///**NOTE for iOS**: there is **no change notification** for this value. WebKit does not document
  ///`WKWebView.isBlockedByScreenTime` as KVO-compliant and this plugin exposes no event for it, so
  ///the value has to be read when it matters — after
  ///[PlatformWebViewCreationParams.onLoadStop], for example. It is also per-*content*, not
  ///per-WebView: the same WebView answers `true` for a blocked page and `false` after navigating
  ///to an allowed one.
  ///
  ///**NOTE for iOS**: this reports blocking, it does not cause it. Whether WebKit also draws its
  ///own explanation over the WebView is controlled by
  ///[InAppWebViewSettings.showsSystemScreenTimeBlockingView], which is a creation-time setting.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isBlockedByScreenTime.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.isBlockedByScreenTime',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/isblockedbyscreentime',
        available: '26.0',
        note:
            'Returns `null` below iOS 26.0. No change notification exists — read it when it matters.',
      ),
    ],
  )
  Future<bool?> isBlockedByScreenTime() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isBlockedByScreenTime.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback}
  ///Pauses playback of all media in the web view.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.pauseAllMediaPlayback',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback',
        available: '15.0',
      ),
    ],
  )
  Future<void> pauseAllMediaPlayback() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended}
  ///Changes whether the webpage is suspending playback of all media in the page.
  ///Pass `true` to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with `false`.
  ///
  ///[suspended] represents a [bool] value that indicates whether the webpage should suspend media playback.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.setAllMediaPlaybackSuspended',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended',
        available: '15.0',
      ),
    ],
  )
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setAllMediaPlaybackSuspended.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations}
  ///Closes all media the web view is presenting, including picture-in-picture video and fullscreen video.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.closeAllMediaPresentations',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations',
        available: '14.5',
      ),
    ],
  )
  Future<void> closeAllMediaPresentations() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.closeAllMediaPresentations.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState}
  ///Requests the playback status of media in the web view.
  ///Returns a [MediaPlaybackState] that indicates whether the media in the web view is playing, paused, or suspended.
  ///If there’s no media in the web view to play, this method provides [MediaPlaybackState.NONE].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.requestMediaPlaybackState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate',
        available: '15.0',
      ),
    ],
  )
  Future<MediaPlaybackState?> requestMediaPlaybackState() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.requestMediaPlaybackState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen}
  ///Returns `true` if the `WebView` is in fullscreen mode, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<bool> isInFullscreen() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isInFullscreen.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState}
  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the camera to capture images or video.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.cameraCaptureState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate',
        available: '15.0',
      ),
    ],
  )
  Future<MediaCaptureState?> getCameraCaptureState() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getCameraCaptureState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState}
  ///Changes whether the webpage is using the camera to capture images or video.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.setCameraCaptureState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate',
        available: '15.0',
      ),
    ],
  )
  Future<void> setCameraCaptureState({required MediaCaptureState state}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setCameraCaptureState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState}
  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the microphone to capture audio.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.microphoneCaptureState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate',
        available: '15.0',
      ),
    ],
  )
  Future<MediaCaptureState?> getMicrophoneCaptureState() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState}
  ///Changes whether the webpage is using the microphone to capture audio.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.setMicrophoneCaptureState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate',
        available: '15.0',
      ),
    ],
  )
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setMicrophoneCaptureState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest}
  ///Loads the web content from the data you provide as if the data were the response to the request.
  ///If [urlResponse] is `null`, it loads the web content from the data as an utf8 encoded HTML string as the response to the request.
  ///
  ///[urlRequest] represents a URL request that specifies the base URL and other loading details the system uses to interpret the data you provide.
  ///
  ///[urlResponse] represents a response the system uses to interpret the data you provide.
  ///
  ///[data] represents the data or the utf8 encoded HTML string to use as the contents of the webpage.
  ///
  ///Example:
  ///```dart
  ///controller.loadSimulatedRequest(urlRequest: URLRequest(
  ///    url: WebUri("https://flutter.dev"),
  ///  ),
  ///  data: Uint8List.fromList(utf8.encode("<h1>Hello</h1>"))
  ///);
  ///```
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.loadSimulatedRequest(_:response:responseData:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest',
        available: '15.0',
        note:
            'or [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)',
      ),
    ],
  )
  Future<void> loadSimulatedRequest({
    required URLRequest urlRequest,
    required Uint8List data,
    URLResponse? urlResponse,
  }) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.loadSimulatedRequest.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveState}
  ///Returns the current state of interaction in a web view so that you can restore
  ///that state later to another web view using the [restoreState] method.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.saveState',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#saveState(android.os.Bundle)',
        note: 'This method doesn\'t store the display data for this WebView.',
      ),
      IOSPlatform(
        apiName: 'WKWebView.interactionState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate',
        available: '15.0',
      ),
    ],
  )
  Future<Uint8List?> saveState() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.saveState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState}
  ///Restores the state of this WebView from the given [state] returned by the [saveState] method.
  ///If it is called after this WebView has had a chance to build state (load pages, create a back/forward list, etc.),
  ///there may be undesirable side-effects.
  ///
  ///Returns `true` if the state was restored successfully, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.restoreState',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#restoreState(android.os.Bundle)',
        note: 'This method doesn\'t restore the display data for this WebView.',
      ),
      IOSPlatform(
        apiName: 'WKWebView.interactionState',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/3752236-interactionstate',
        available: '15.0',
      ),
    ],
  )
  Future<bool> restoreState(Uint8List state) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.restoreState.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId}
  ///View ID used internally.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  dynamic getViewId() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getViewId.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent}
  ///Gets the default user agent.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebSettings.getDefaultUserAgent',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebSettings#getDefaultUserAgent(android.content.Context)',
      ),
      IOSPlatform(),
    ],
  )
  Future<String> getDefaultUserAgent() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getDefaultUserAgent.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences}
  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.clearClientCertPreferences',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)',
        available: '21',
      ),
    ],
  )
  Future<void> clearClientCertPreferences() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearClientCertPreferences.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl}
  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.getSafeBrowsingPrivacyPolicyUrl',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl()',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].',
      ),
    ],
  )
  Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getSafeBrowsingPrivacyPolicyUrl.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist}
  ///Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
  ///
  /// Each rule should take one of these:
  ///| Rule | Example | Matches Subdomain |
  ///| -- | -- | -- |
  ///| HOSTNAME | example.com | Yes |
  ///| .HOSTNAME | .example.com | No |
  ///| IPV4_LITERAL | 192.168.1.1 | No |
  ///| IPV6_LITERAL_WITH_BRACKETS | [10:20:30:40:50:60:70:80] | No |
  ///
  ///All other rules, including wildcards, are invalid. The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///[hosts] represents the list of hosts. This value must never be `null`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.setSafeBrowsingAllowlist',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_ALLOWLIST].',
      ),
    ],
  )
  Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setSafeBrowsingAllowlist.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage}
  ///If WebView has already been loaded into the current process this method will return the package that was used to load it.
  ///Otherwise, the package that would be used if the WebView was loaded right now will be returned;
  ///this does not cause WebView to be loaded, so this information may become outdated at any time.
  ///The WebView package changes either when the current WebView package is updated, disabled, or uninstalled.
  ///It can also be changed through a Developer Setting. If the WebView package changes, any app process that
  ///has loaded WebView will be killed.
  ///The next time the app starts and loads WebView it will use the new WebView package instead.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.getCurrentWebViewPackage',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)',
        available: '21',
      ),
    ],
  )
  Future<WebViewPackageInfo?> getCurrentWebViewPackage() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getCurrentWebViewPackage.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled}
  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews.
  ///Please refer to WebView documentation for the debugging guide. The default is `false`.
  ///
  ///[debuggingEnabled] whether to enable web contents debugging.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.setWebContentsDebuggingEnabled',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)',
      ),
    ],
  )
  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setWebContentsDebuggingEnabled.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader}
  ///Gets the WebView variations encoded to be used as the X-Client-Data HTTP header.
  ///
  ///The app is responsible for adding the X-Client-Data header to any request
  ///that may use variations metadata, such as requests to Google web properties.
  ///The returned string will be a base64 encoded ClientVariations proto:
  ///https://source.chromium.org/chromium/chromium/src/+/main:components/variations/proto/client_variations.proto
  ///
  ///The string may be empty if the header is not available.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.getVariationsHeader',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#getVariationsHeader()',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.GET_VARIATIONS_HEADER].',
      ),
    ],
  )
  Future<String?> getVariationsHeader() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getVariationsHeader.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled}
  ///Returns `true` if WebView is running in multi process mode.
  ///
  ///In Android O and above, WebView may run in "multiprocess" mode.
  ///In multiprocess mode, rendering of web content is performed by a sandboxed
  ///renderer process separate to the application process.
  ///This renderer process may be shared with other WebViews in the application,
  ///but is not shared with other application processes.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.isMultiProcessEnabled',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#isMultiProcessEnabled()',
        note:
            'This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.MULTI_PROCESS].',
      ),
    ],
  )
  Future<bool> isMultiProcessEnabled() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.isMultiProcessEnabled.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setDefaultTrafficStatsTag}
  ///Sets the default `TrafficStats` tag used to account for the socket traffic caused by WebView.
  ///
  ///The tag is **global to the app**: it applies to every request made by the WebView library in
  ///this process, not only to the WebView this controller belongs to. When no tag has been set,
  ///Android accounts for WebView's socket traffic as if the tag were `0`.
  ///
  ///Setting a tag stops sockets from being shared with requests carrying a different tag, so
  ///multiplexed protocols (HTTP/2, QUIC) only reuse a connection between requests with the same
  ///tag. Changing the tag therefore costs connection reuse — set it once, early, rather than
  ///switching it per navigation.
  ///
  ///[tag] is a 32-bit value. Tags from `0xFFFFFF00` to `0xFFFFFFFF` — equivalently `-256` to `-1`,
  ///the same bit patterns read as a signed 32-bit int — are reserved for system services such as
  ///`DownloadManager` and must not be used.
  ///
  ///Returns `true` if the tag was applied, or `false` when
  ///[WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING] is not supported by the current WebView
  ///provider, in which case nothing happened and WebView's traffic stays accounted as tag `0`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setDefaultTrafficStatsTag.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.setDefaultTrafficStatsTag',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat#setDefaultTrafficStatsTag(int)',
        note:
            'Requires [WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING]. Returns `false` and does nothing if the feature is not supported.',
      ),
    ],
  )
  Future<bool> setDefaultTrafficStatsTag(int tag) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setDefaultTrafficStatsTag.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView}
  ///Indicate that the current process does not intend to use WebView,
  ///and that an exception should be thrown if a WebView is created or any other
  ///methods in the `android.webkit` package are used.
  ///
  ///Applications with multiple processes may wish to call this in processes that
  ///are not intended to use WebView to avoid accidentally incurring the memory usage
  ///of initializing WebView in long-lived processes that have no need for it,
  ///and to prevent potential data directory conflicts (see [ProcessGlobalConfigSettings.dataDirectorySuffix]).
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.disableWebView',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#disableWebView()',
        available: '28',
      ),
    ],
  )
  Future<void> disableWebView() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.disableWebView.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme}
  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKWebView.handlesURLScheme',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme',
        available: '11.0',
      ),
    ],
  )
  Future<bool> handlesURLScheme(String urlScheme) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.handlesURLScheme.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive}
  ///Disposes the WebView that is using the [keepAlive] instance for the keep alive feature.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.disposeKeepAlive.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache}
  ///Clears the resource cache. Note that the cache is per-application, so this will clear the cache for all WebViews used.
  ///
  ///[includeDiskFiles] if `false`, only the RAM cache is cleared. The default value is `true`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> clearAllCache({bool includeDiskFiles = true}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.clearAllCache.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw}
  ///For apps targeting the L release, WebView has a new default behavior that reduces memory footprint and increases
  ///performance by intelligently choosing the portion of the HTML document that needs to be drawn.
  ///These optimizations are transparent to the developers.
  ///However, under certain circumstances, an App developer may want to disable them, for example
  ///when an app draws and accesses portions of the page that is way outside the visible portion of the page.
  ///Enabling drawing the entire HTML document has a significant performance cost.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebView.enableSlowWholeDocumentDraw',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebView#enableSlowWholeDocumentDraw()',
        available: '21',
        note: 'This method should be called before any WebViews are created.',
      ),
    ],
  )
  Future<void> enableSlowWholeDocumentDraw() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.enableSlowWholeDocumentDraw.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName}
  ///Sets the name of the JavaScript Bridge object that will be used to interact with the WebView.
  ///This method should be called before any WebViews are created or when there are no WebViews.
  ///Calling this method after a WebView has been created will not change
  ///the current JavaScript Bridge object and could lead to errors.
  ///
  ///The [bridgeName] must be a non-empty string with only alphanumeric and underscore characters.
  ///It can't start with a number.
  ///
  ///The default name used by this plugin is `flutter_inappwebview`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> setJavaScriptBridgeName(String bridgeName) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.setJavaScriptBridgeName.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName}
  ///Gets the name of the JavaScript Bridge object that is used to interact with the WebView.
  ///Use [setJavaScriptBridgeName] to set a custom name.
  ///The default name used by this plugin is `flutter_inappwebview`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<String> getJavaScriptBridgeName() {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.getJavaScriptBridgeName.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml}
  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [tRexRunnerCss].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<String> get tRexRunnerHtml => throw UnimplementedError(
    '${PlatformInAppWebViewControllerProperty.tRexRunnerHtml.name} is not implemented on the current platform',
  );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss}
  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [tRexRunnerHtml].ì
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<String> get tRexRunnerCss => throw UnimplementedError(
    '${PlatformInAppWebViewControllerProperty.tRexRunnerCss.name} is not implemented on the current platform',
  );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInAppWebViewControllerClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformInAppWebViewControllerProperty property, {
    TargetPlatform? platform,
  }) => _PlatformInAppWebViewControllerPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformInAppWebViewControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewController.dispose}
  ///Disposes the controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.dispose.supported_platforms}
  @override
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  void dispose({bool isKeepAlive = false}) {
    throw UnimplementedError(
      '${PlatformInAppWebViewControllerMethod.dispose.name} is not implemented on the current platform',
    );
  }
}
