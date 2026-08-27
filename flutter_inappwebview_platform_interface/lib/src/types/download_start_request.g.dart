// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a download request of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStarting].
class DownloadStartRequest {
  ///Content-disposition http header, if present.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? contentDisposition;

  ///The file size reported by the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  int contentLength;

  ///Whether this download was initiated by the user, rather than started by the page on its own.
  ///
  ///Useful for deciding whether to honour a download at all: a drive-by download that the user
  ///never asked for reports `false`.
  ///
  ///`null` means the platform did not report it, which happens in two distinct cases on iOS:
  ///below iOS 18.2, and — on any version — when the event was raised from the navigation-response
  ///path rather than from a real `WKDownload`. See the note on [originatingFrame].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.2+ ([Official API - WKDownload.isUserInitiated](https://developer.apple.com/documentation/webkit/wkdownload/isuserinitiated)):
  ///    - `null` when the event came from the navigation-response path, which has no WKDownload to ask.
  bool? isUserInitiated;

  ///The mimetype of the content reported by the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? mimeType;

  ///The frame that originated this download.
  ///
  ///`null` under the same two conditions as [isUserInitiated]. The second one is worth spelling
  ///out: on iOS the `onDownloadStarting` event has **three** producers, and one of them fires when
  ///the plugin detects a download from the navigation response and cancels it before WebKit creates
  ///a download object. There is nothing to read the frame from on that path, so a `null` here does
  ///not imply an old OS.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 18.2+ ([Official API - WKDownload.originatingFrame](https://developer.apple.com/documentation/webkit/wkdownload/originatingframe)):
  ///    - `null` when the event came from the navigation-response path, which has no WKDownload to ask.
  FrameInfo? originatingFrame;

  ///A suggested filename to use if saving the resource to disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? textEncodingName;

  ///The full url to the content that should be downloaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  WebUri url;

  ///the user agent to be used for the download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? userAgent;
  DownloadStartRequest({
    this.contentDisposition,
    required this.contentLength,
    this.isUserInitiated,
    this.mimeType,
    this.originatingFrame,
    this.suggestedFilename,
    this.textEncodingName,
    required this.url,
    this.userAgent,
  });

  ///Gets a possible [DownloadStartRequest] instance from a [Map] value.
  static DownloadStartRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = DownloadStartRequest(
      contentDisposition: map['contentDisposition'],
      contentLength: map['contentLength'],
      isUserInitiated: map['isUserInitiated'],
      mimeType: map['mimeType'],
      originatingFrame: FrameInfo.fromMap(
        map['originatingFrame']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      url: WebUri(map['url']),
      userAgent: map['userAgent'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "contentDisposition": contentDisposition,
      "contentLength": contentLength,
      "isUserInitiated": isUserInitiated,
      "mimeType": mimeType,
      "originatingFrame": originatingFrame?.toMap(enumMethod: enumMethod),
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "url": url.toString(),
      "userAgent": userAgent,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadStartRequest{contentDisposition: $contentDisposition, contentLength: $contentLength, isUserInitiated: $isUserInitiated, mimeType: $mimeType, originatingFrame: $originatingFrame, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, url: $url, userAgent: $userAgent}';
  }
}
