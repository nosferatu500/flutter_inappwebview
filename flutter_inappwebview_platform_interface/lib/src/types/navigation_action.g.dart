// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about an action that causes navigation to occur.
class NavigationAction {
  ///The pointing-device buttons that were pressed when the navigation was triggered.
  ///
  ///Despite the name, which is inherited from the WebKit property, this is **not** a button
  ///index — the native `UIEventButtonMask` is a bit mask defined as `1 << (buttonNumber - 1)`.
  ///It is exposed as a set of named buttons so the distinction cannot be got wrong.
  ///`null` means the platform did not report the value at all, which is the case below iOS 18.4.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.4+ ([Official API - WKNavigationAction.buttonNumber](https://developer.apple.com/documentation/webkit/wknavigationaction/buttonnumber))
  List<ButtonMask>? buttonNumber;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebResourceRequest.hasGesture](https://developer.android.com/reference/android/webkit/WebResourceRequest#hasGesture())):
  ///    - On Android < 21, this is always `false`
  ///- Windows WebView2:
  ///    - Available only if the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  bool? hasGesture;

  ///Whether the navigation is a redirect produced by a content rule list rather than by the
  ///page or the server.
  ///
  ///The only rule-list action this plugin can express today is
  ///[ContentBlockerActionType.MAKE_HTTPS] in [InAppWebViewSettings.contentBlockers], so on iOS
  ///this is effectively "the `http` → `https` upgrade one of my own rules performed".
  ///
  ///This is **not** [isRedirect], which reports a *server-side* redirect and is Android/Windows
  ///only. A content rule list redirect never reaches the network at the original URL, so no
  ///server was involved.
  ///
  ///`false` means the platform reported the value and the navigation was not rule-list driven;
  ///`null` means it did not report the value at all, which is the case below iOS 26.0. The
  ///distinction matters for a caller that vetoes or logs unexpected navigations: a rule-list
  ///redirect was caused by the app's own configuration, not by the content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+ ([Official API - WKNavigationAction.isContentRuleListRedirect](https://developer.apple.com/documentation/webkit/wknavigationaction/iscontentrulelistredirect))
  ///- macOS WKWebView 26.0+ ([Official API - WKNavigationAction.isContentRuleListRedirect](https://developer.apple.com/documentation/webkit/wknavigationaction/iscontentrulelistredirect))
  bool? isContentRuleListRedirect;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android and Windows**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebResourceRequest.isRedirect](https://developer.android.com/reference/android/webkit/WebResourceRequest#isRedirect()))
  ///- Windows WebView2
  bool? isRedirect;

  ///The modifier keys that were held down when the navigation was triggered,
  ///for example `[ModifierFlag.COMMAND]` for a command-click.
  ///
  ///This is a set because the underlying `UIKeyModifierFlags` is a bit mask and more than one
  ///modifier can be held at once. An empty list means no modifier was held; `null` means the
  ///platform did not report the value at all, which is the case below iOS 18.4.
  ///
  ///A common use is distinguishing an ordinary link activation from a command-click, which on
  ///Apple platforms conventionally means "open in a new tab".
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.4+ ([Official API - WKNavigationAction.modifierFlags](https://developer.apple.com/documentation/webkit/wknavigationaction/modifierflags))
  List<ModifierFlag>? modifierFlags;

  ///The type of action triggering the navigation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.navigationType](https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype))
  ///- macOS WKWebView ([Official API - WKNavigationAction.navigationType](https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype))
  ///- Windows WebView2
  NavigationType? navigationType;

  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest request;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.5+ ([Official API - WKNavigationAction.shouldPerformDownload](https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload))
  ///- macOS WKWebView 11.3+ ([Official API - WKNavigationAction.shouldPerformDownload](https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload))
  bool? shouldPerformDownload;

  ///The frame that requested the navigation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.sourceFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe))
  ///- macOS WKWebView ([Official API - WKNavigationAction.sourceFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe))
  FrameInfo? sourceFrame;

  ///The frame in which to display the new content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKNavigationAction.targetFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe))
  ///- macOS WKWebView ([Official API - WKNavigationAction.targetFrame](https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe))
  FrameInfo? targetFrame;
  NavigationAction({
    this.buttonNumber,
    this.hasGesture,
    this.isContentRuleListRedirect,
    required this.isForMainFrame,
    this.isRedirect,
    this.modifierFlags,
    this.navigationType,
    required this.request,
    this.shouldPerformDownload,
    this.sourceFrame,
    this.targetFrame,
  });

  ///Gets a possible [NavigationAction] instance from a [Map] value.
  static NavigationAction? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = NavigationAction(
      buttonNumber: map['buttonNumber'] != null
          ? List<ButtonMask>.from(
              map['buttonNumber'].map(
                (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue => ButtonMask.fromNativeValue(e),
                  EnumMethod.value => ButtonMask.fromValue(e),
                  EnumMethod.name => ButtonMask.byName(e),
                }!,
              ),
            )
          : null,
      hasGesture: map['hasGesture'],
      isContentRuleListRedirect: map['isContentRuleListRedirect'],
      isForMainFrame: map['isForMainFrame'],
      isRedirect: map['isRedirect'],
      modifierFlags: map['modifierFlags'] != null
          ? List<ModifierFlag>.from(
              map['modifierFlags'].map(
                (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue => ModifierFlag.fromNativeValue(e),
                  EnumMethod.value => ModifierFlag.fromValue(e),
                  EnumMethod.name => ModifierFlag.byName(e),
                }!,
              ),
            )
          : null,
      navigationType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => NavigationType.fromNativeValue(
          map['navigationType'],
        ),
        EnumMethod.value => NavigationType.fromValue(map['navigationType']),
        EnumMethod.name => NavigationType.byName(map['navigationType']),
      },
      request: URLRequest.fromMap(
        map['request']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      shouldPerformDownload: map['shouldPerformDownload'],
      sourceFrame: FrameInfo.fromMap(
        map['sourceFrame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      targetFrame: FrameInfo.fromMap(
        map['targetFrame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "buttonNumber": buttonNumber
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "hasGesture": hasGesture,
      "isContentRuleListRedirect": isContentRuleListRedirect,
      "isForMainFrame": isForMainFrame,
      "isRedirect": isRedirect,
      "modifierFlags": modifierFlags
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "navigationType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => navigationType?.toNativeValue(),
        EnumMethod.value => navigationType?.toValue(),
        EnumMethod.name => navigationType?.name(),
      },
      "request": request.toMap(enumMethod: enumMethod),
      "shouldPerformDownload": shouldPerformDownload,
      "sourceFrame": sourceFrame?.toMap(enumMethod: enumMethod),
      "targetFrame": targetFrame?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NavigationAction{buttonNumber: $buttonNumber, hasGesture: $hasGesture, isContentRuleListRedirect: $isContentRuleListRedirect, isForMainFrame: $isForMainFrame, isRedirect: $isRedirect, modifierFlags: $modifierFlags, navigationType: $navigationType, request: $request, shouldPerformDownload: $shouldPerformDownload, sourceFrame: $sourceFrame, targetFrame: $targetFrame}';
  }
}
