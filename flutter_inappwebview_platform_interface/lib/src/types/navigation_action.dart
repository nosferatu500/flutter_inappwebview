import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_request.dart';
import 'navigation_type.dart';
import 'frame_info.dart';
import 'modifier_flag.dart';
import 'button_mask.dart';
import 'enum_method.dart';

part 'navigation_action.g.dart';

///An object that contains information about an action that causes navigation to occur.
@ExchangeableObject()
class NavigationAction_ {
  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest_ request;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android and Windows**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebResourceRequest.hasGesture",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebResourceRequest#hasGesture()",
        note: "On Android < 21, this is always `false`",
      ),
      WindowsPlatform(
        note:
            "Available only if the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event",
      ),
    ],
  )
  bool? hasGesture;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: If the request is associated to the [PlatformWebViewCreationParams.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        available: "21",
        apiName: "WebResourceRequest.isRedirect",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/WebResourceRequest#isRedirect()",
      ),
      WindowsPlatform(),
    ],
  )
  bool? isRedirect;

  ///The type of action triggering the navigation.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.navigationType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.navigationType",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401914-navigationtype",
      ),
      WindowsPlatform(),
    ],
  )
  NavigationType_? navigationType;

  ///The frame that requested the navigation.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.sourceFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.sourceFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401926-sourceframe",
      ),
    ],
  )
  FrameInfo_? sourceFrame;

  ///The frame in which to display the new content.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "WKNavigationAction.targetFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe",
      ),
      MacOSPlatform(
        apiName: "WKNavigationAction.targetFrame",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/1401918-targetframe",
      ),
    ],
  )
  FrameInfo_? targetFrame;

  ///A value indicating whether the web content used a download attribute to indicate that this should be downloaded.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.5",
        apiName: "WKNavigationAction.shouldPerformDownload",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload",
      ),
      MacOSPlatform(
        available: "11.3",
        apiName: "WKNavigationAction.shouldPerformDownload",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/3727357-shouldperformdownload",
      ),
    ],
  )
  bool? shouldPerformDownload;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "26.0",
        apiName: "WKNavigationAction.isContentRuleListRedirect",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/iscontentrulelistredirect",
      ),
      MacOSPlatform(
        available: "26.0",
        apiName: "WKNavigationAction.isContentRuleListRedirect",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/iscontentrulelistredirect",
      ),
    ],
  )
  bool? isContentRuleListRedirect;

  ///The modifier keys that were held down when the navigation was triggered,
  ///for example `[ModifierFlag.COMMAND]` for a command-click.
  ///
  ///This is a set because the underlying `UIKeyModifierFlags` is a bit mask and more than one
  ///modifier can be held at once. An empty list means no modifier was held; `null` means the
  ///platform did not report the value at all, which is the case below iOS 18.4.
  ///
  ///A common use is distinguishing an ordinary link activation from a command-click, which on
  ///Apple platforms conventionally means "open in a new tab".
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.4",
        apiName: "WKNavigationAction.modifierFlags",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/modifierflags",
      ),
    ],
  )
  List<ModifierFlag_>? modifierFlags;

  ///The pointing-device buttons that were pressed when the navigation was triggered.
  ///
  ///Despite the name, which is inherited from the WebKit property, this is **not** a button
  ///index — the native `UIEventButtonMask` is a bit mask defined as `1 << (buttonNumber - 1)`.
  ///It is exposed as a set of named buttons so the distinction cannot be got wrong.
  ///`null` means the platform did not report the value at all, which is the case below iOS 18.4.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "18.4",
        apiName: "WKNavigationAction.buttonNumber",
        apiUrl:
            "https://developer.apple.com/documentation/webkit/wknavigationaction/buttonnumber",
      ),
    ],
  )
  List<ButtonMask_>? buttonNumber;

  NavigationAction_({
    required this.request,
    required this.isForMainFrame,
    this.hasGesture,
    this.isRedirect,
    this.navigationType,
    this.sourceFrame,
    this.targetFrame,
    this.shouldPerformDownload,
    this.isContentRuleListRedirect,
    this.modifierFlags,
    this.buttonNumber,
  });
}
