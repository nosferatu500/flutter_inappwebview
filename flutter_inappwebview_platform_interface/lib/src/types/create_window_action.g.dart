// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_window_action.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the navigation request used by the [PlatformWebViewCreationParams.onCreateWindow] event.
class CreateWindowAction extends NavigationAction {
  ///Indicates if the new window should be a dialog, rather than a full-size window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? isDialog;

  ///Window features requested by the webpage.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWindowFeatures](https://developer.apple.com/documentation/webkit/wkwindowfeatures))
  ///- macOS WKWebView ([Official API - WKWindowFeatures](https://developer.apple.com/documentation/webkit/wkwindowfeatures))
  ///- Windows WebView2 ([Official API - ICoreWebView2WindowFeatures](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2windowfeatures?view=webview2-1.0.2210.55))
  WindowFeatures? windowFeatures;

  ///The window id. Used by `WebView` to create a new WebView.
  int windowId;
  CreateWindowAction({
    this.isDialog,
    this.windowFeatures,
    required this.windowId,
    required URLRequest request,
    required bool isForMainFrame,
    bool? hasGesture,
    bool? isRedirect,
    NavigationType? navigationType,
    FrameInfo? sourceFrame,
    FrameInfo? targetFrame,
    bool? shouldPerformDownload,
  }) : super(
         request: request,
         isForMainFrame: isForMainFrame,
         hasGesture: hasGesture,
         isRedirect: isRedirect,
         navigationType: navigationType,
         sourceFrame: sourceFrame,
         targetFrame: targetFrame,
         shouldPerformDownload: shouldPerformDownload,
       );

  ///Gets a possible [CreateWindowAction] instance from a [Map] value.
  static CreateWindowAction? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CreateWindowAction(
      request: URLRequest.fromMap(
        map['request']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      )!,
      isForMainFrame: map['isForMainFrame'],
      hasGesture: map['hasGesture'],
      isRedirect: map['isRedirect'],
      navigationType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => NavigationType.fromNativeValue(
          map['navigationType'],
        ),
        EnumMethod.value => NavigationType.fromValue(map['navigationType']),
        EnumMethod.name => NavigationType.byName(map['navigationType']),
      },
      sourceFrame: FrameInfo.fromMap(
        map['sourceFrame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      targetFrame: FrameInfo.fromMap(
        map['targetFrame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      isDialog: map['isDialog'],
      windowFeatures: WindowFeatures.fromMap(
        map['windowFeatures']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      windowId: map['windowId'],
    );
    instance.shouldPerformDownload = map['shouldPerformDownload'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "request": request.toMap(enumMethod: enumMethod),
      "isForMainFrame": isForMainFrame,
      "hasGesture": hasGesture,
      "isRedirect": isRedirect,
      "navigationType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => navigationType?.toNativeValue(),
        EnumMethod.value => navigationType?.toValue(),
        EnumMethod.name => navigationType?.name(),
      },
      "sourceFrame": sourceFrame?.toMap(enumMethod: enumMethod),
      "targetFrame": targetFrame?.toMap(enumMethod: enumMethod),
      "shouldPerformDownload": shouldPerformDownload,
      "isDialog": isDialog,
      "windowFeatures": windowFeatures?.toMap(enumMethod: enumMethod),
      "windowId": windowId,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CreateWindowAction{request: $request, isForMainFrame: $isForMainFrame, hasGesture: $hasGesture, isRedirect: $isRedirect, navigationType: $navigationType, sourceFrame: $sourceFrame, targetFrame: $targetFrame, shouldPerformDownload: $shouldPerformDownload, isDialog: $isDialog, windowFeatures: $windowFeatures, windowId: $windowId}';
  }
}
