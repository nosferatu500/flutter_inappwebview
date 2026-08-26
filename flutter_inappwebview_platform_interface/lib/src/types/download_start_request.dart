import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'frame_info.dart';
import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';

part 'download_start_request.g.dart';

///Class representing a download request of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStarting].
@ExchangeableObject()
class DownloadStartRequest_ {
  ///The full url to the content that should be downloaded.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  WebUri url;

  ///the user agent to be used for the download.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? userAgent;

  ///Content-disposition http header, if present.
  @SupportedPlatforms(platforms: [AndroidPlatform(), WindowsPlatform()])
  String? contentDisposition;

  ///The mimetype of the content reported by the server.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  String? mimeType;

  ///The file size reported by the server.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  int contentLength;

  ///A suggested filename to use if saving the resource to disk.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  String? textEncodingName;

  ///Whether this download was initiated by the user, rather than started by the page on its own.
  ///
  ///Useful for deciding whether to honour a download at all: a drive-by download that the user
  ///never asked for reports `false`.
  ///
  ///`null` means the platform did not report it, which happens in two distinct cases on iOS:
  ///below iOS 18.2, and — on any version — when the event was raised from the navigation-response
  ///path rather than from a real `WKDownload`. See the note on [originatingFrame].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.2",
        apiName: "WKDownload.isUserInitiated",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkdownload/isuserinitiated",
        note:
            "`null` when the event came from the navigation-response path, which has no WKDownload to ask.",
      ),
    ],
  )
  bool? isUserInitiated;

  ///The frame that originated this download.
  ///
  ///`null` under the same two conditions as [isUserInitiated]. The second one is worth spelling
  ///out: on iOS the `onDownloadStarting` event has **three** producers, and one of them fires when
  ///the plugin detects a download from the navigation response and cancels it before WebKit creates
  ///a download object. There is nothing to read the frame from on that path, so a `null` here does
  ///not imply an old OS.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.2",
        apiName: "WKDownload.originatingFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wkdownload/originatingframe",
        note:
            "`null` when the event came from the navigation-response path, which has no WKDownload to ask.",
      ),
    ],
  )
  FrameInfo_? originatingFrame;

  DownloadStartRequest_({
    required this.url,
    this.userAgent,
    this.contentDisposition,
    this.mimeType,
    required this.contentLength,
    this.suggestedFilename,
    this.textEncodingName,
    this.isUserInitiated,
    this.originatingFrame,
  });
}
