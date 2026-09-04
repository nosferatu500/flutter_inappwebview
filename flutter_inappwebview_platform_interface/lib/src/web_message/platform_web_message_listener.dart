import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import 'web_message.dart';

// ignore: uri_has_not_been_generated
part 'platform_web_message_listener.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebMessageListener].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
@immutable
class PlatformWebMessageListenerCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebMessageListener].
  const PlatformWebMessageListenerCreationParams({
    required this.jsObjectName,
    this.allowedOriginRules,
    this.contentWorld,
    this.onPostMessage,
  });

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.jsObjectName}
  ///The name for the injected JavaScript object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.jsObjectName.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final String jsObjectName;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.allowedOriginRules}
  ///A set of matching rules for the allowed origins.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.allowedOriginRules.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  final Set<String>? allowedOriginRules;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.contentWorld}
  ///The scope of execution the injected JavaScript object is created in.
  ///
  ///Listeners are keyed on **both** [jsObjectName] and the content world, so the same
  ///[jsObjectName] may be registered once per world and each registration receives only the
  ///messages posted from its own world.
  ///
  ///Defaults to `null`, which means [ContentWorld.PAGE] — the webpage's own scope, and the
  ///behaviour of every release before this one.
  ///
  ///Use it to keep the injected object out of the page's reach: a listener in a world other than
  ///[ContentWorld.PAGE] is invisible to page scripts, and the code that talks to it — whether
  ///from [PlatformInAppWebViewController.evaluateJavascript] or a [UserScript] — must name the
  ///same [ContentWorld] to see it. The DOM is shared as normal; only the JavaScript scope
  ///differs.
  ///
  ///**NOTE for Android**: this is **iOS-only**, and it is not an oversight. Android's
  ///[ContentWorld] is an `<iframe>` emulation shared by
  ///[PlatformInAppWebViewController.evaluateJavascript] and [UserScript], while `androidx`'s own
  ///isolated worlds (behind [WebViewFeature.JS_INJECTION_IN_FRAME_AND_WORLD]) are a separate
  ///mechanism with no "evaluate in world" entry point. Honouring this field on Android would
  ///register a listener in a scope no Dart code could reach. On Android the value is ignored.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.contentWorld.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKUserContentController.addScriptMessageHandler',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkusercontentcontroller/3585113-addscriptmessagehandler',
      ),
    ],
  )
  final ContentWorld? contentWorld;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.onPostMessage}
  ///Event that receives a message sent by a `postMessage()` on the injected JavaScript object.
  ///
  ///Note that when the frame is `file:` or `content:` origin, the value of [sourceOrigin] is `null`.
  ///
  ///- [message] represents the message from JavaScript.
  ///- [sourceOrigin] represents the origin of the frame that the message is from.
  ///- [isMainFrame] is `true` if the message is from the main frame.
  ///- [replyProxy] is used to reply back to the JavaScript object.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.onPostMessage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewCompat.WebMessageListener.onPostMessage',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewCompat.WebMessageListener#onPostMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri,%20boolean,%20androidx.webkit.JavaScriptReplyProxy)',
      ),
      IOSPlatform(),
    ],
  )
  final OnPostMessageCallback? onPostMessage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageListenerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebMessageListenerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformWebMessageListenerCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );

  @override
  String toString() {
    return 'PlatformWebMessageListenerCreationParams{jsObjectName: $jsObjectName, allowedOriginRules: $allowedOriginRules, contentWorld: $contentWorld, onPostMessage: $onPostMessage}';
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener}
///This listener receives messages sent on the JavaScript object which was injected by [PlatformInAppWebViewController.addWebMessageListener].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
abstract class PlatformWebMessageListener extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformWebMessageListener]
  factory PlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessageListener webMessageListener = InAppWebViewPlatform
        .instance!
        .createPlatformWebMessageListener(params);
    PlatformInterface.verify(webMessageListener, _token);
    return webMessageListener;
  }

  /// Creates a new [PlatformWebMessageListener] to access static methods.
  factory PlatformWebMessageListener.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessageListener webMessageListenerStatic =
        InAppWebViewPlatform.instance!.createPlatformWebMessageListenerStatic();
    PlatformInterface.verify(webMessageListenerStatic, _token);
    return webMessageListenerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformWebMessageListener].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebMessageListener.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebMessageListener].
  final PlatformWebMessageListenerCreationParams params;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.jsObjectName}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.jsObjectName.supported_platforms}
  String get jsObjectName => params.jsObjectName;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.allowedOriginRules}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.allowedOriginRules.supported_platforms}
  Set<String>? get allowedOriginRules => params.allowedOriginRules;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.contentWorld}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.contentWorld.supported_platforms}
  ContentWorld? get contentWorld => params.contentWorld;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.onPostMessage}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.onPostMessage.supported_platforms}
  OnPostMessageCallback? get onPostMessage => params.onPostMessage;

  Map<String, dynamic> toMap() {
    throw UnimplementedError(
      'toMap is not implemented on the current platform.',
    );
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
      'toJson is not implemented on the current platform.',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener.dispose}
  ///Disposes the channel.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  @override
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform.',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageListenerClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebMessageListenerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebMessageListenerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebMessageListenerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  @override
  String toString() {
    return 'PlatformWebMessageListener{jsObjectName: $jsObjectName, allowedOriginRules: $allowedOriginRules, onPostMessage: $onPostMessage}';
  }
}

/// Object specifying creation parameters for creating a [PlatformJavaScriptReplyProxy].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformJavaScriptReplyProxyCreationParams {
  /// Used by the platform implementation to create a new [PlatformJavaScriptReplyProxy].
  const PlatformJavaScriptReplyProxyCreationParams({
    required this.webMessageListener,
  });

  final PlatformWebMessageListener webMessageListener;
}

///{@template flutter_inappwebview_platform_interface.PlatformJavaScriptReplyProxy}
///This class represents the JavaScript object injected by [PlatformInAppWebViewController.addWebMessageListener].
///An instance will be given by [PlatformWebMessageListener.onPostMessage].
///The app can use `postMessage(String)` to talk to the JavaScript context.
///
///There is a 1:1 relationship between this object and the JavaScript object in a frame.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformJavaScriptReplyProxy.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
abstract class PlatformJavaScriptReplyProxy extends PlatformInterface {
  /// Creates a new [PlatformWebMessageListener]
  factory PlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformJavaScriptReplyProxy javaScriptReplyProxy =
        InAppWebViewPlatform.instance!.createPlatformJavaScriptReplyProxy(
          params,
        );
    PlatformInterface.verify(javaScriptReplyProxy, _token);
    return javaScriptReplyProxy;
  }

  /// Used by the platform implementation to create a new [PlatformJavaScriptReplyProxy].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformJavaScriptReplyProxy.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformJavaScriptReplyProxy].
  final PlatformJavaScriptReplyProxyCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformJavaScriptReplyProxy.postMessage}
  ///Post a [message] to the injected JavaScript object which sent this [PlatformJavaScriptReplyProxy].
  ///
  ///If [message] is of type [WebMessageType.ARRAY_BUFFER], be aware that large byte buffers can lead to out-of-memory crashes on low-end devices.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/JavaScriptReplyProxy#postMessage(java.lang.String)
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformJavaScriptReplyProxy.postMessage.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  Future<void> postMessage(WebMessage message) {
    throw UnimplementedError(
      'postMessage is not implemented on the current platform.',
    );
  }

  @override
  String toString() {
    return 'JavaScriptReplyProxy{}';
  }
}
