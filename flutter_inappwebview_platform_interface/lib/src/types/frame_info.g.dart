// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information about a frame on a webpage.
class FrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool isMainFrame;

  ///The frame’s current request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  URLRequest? request;

  ///The frame’s security origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  SecurityOrigin? securityOrigin;
  FrameInfo({required this.isMainFrame, this.request, this.securityOrigin});

  ///Gets a possible [FrameInfo] instance from a [Map] value.
  static FrameInfo? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = FrameInfo(
      isMainFrame: map['isMainFrame'],
      request: URLRequest.fromMap(
        map['request']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      securityOrigin: SecurityOrigin.fromMap(
        map['securityOrigin']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(enumMethod: enumMethod),
      "securityOrigin": securityOrigin?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FrameInfo{isMainFrame: $isMainFrame, request: $request, securityOrigin: $securityOrigin}';
  }
}
