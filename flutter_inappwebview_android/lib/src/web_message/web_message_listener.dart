import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/web_message.g.dart';
import 'web_message_converters.dart';

/// Object specifying creation parameters for creating a [AndroidWebMessageListener].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessageListenerCreationParams] for
/// more information.
@immutable
class AndroidWebMessageListenerCreationParams
    extends PlatformWebMessageListenerCreationParams {
  /// Creates a new [AndroidWebMessageListenerCreationParams] instance.
  const AndroidWebMessageListenerCreationParams({
    required this.allowedOriginRules,
    required super.jsObjectName,
    super.onPostMessage,
  });

  /// Creates a [AndroidWebMessageListenerCreationParams] instance based on [PlatformWebMessageListenerCreationParams].
  factory AndroidWebMessageListenerCreationParams.fromPlatformWebMessageListenerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebMessageListenerCreationParams params,
  ) {
    return AndroidWebMessageListenerCreationParams(
      allowedOriginRules: params.allowedOriginRules ?? {"*"},
      jsObjectName: params.jsObjectName,
      onPostMessage: params.onPostMessage,
    );
  }

  @override
  final Set<String> allowedOriginRules;

  @override
  String toString() {
    return 'AndroidWebMessageListenerCreationParams{jsObjectName: $jsObjectName, allowedOriginRules: $allowedOriginRules, onPostMessage: $onPostMessage}';
  }
}

/// Receives [WebMessageListenerFlutterApi] events and forwards them to the listener.
///
/// A separate class rather than `AndroidWebMessageListener implements
/// WebMessageListenerFlutterApi`, because the names collide: the platform interface exposes
/// `onPostMessage` as a **callback getter** and the generated API declares it as a **method**, and
/// Dart rejects inheriting the same name as both. §14 predicted this would be the common case for
/// every event whose name matches its callback, and it is the first time it has actually bitten.
class _WebMessageListenerFlutterApiImpl
    implements WebMessageListenerFlutterApi {
  _WebMessageListenerFlutterApiImpl(this._listener);

  final AndroidWebMessageListener _listener;

  @override
  void onPostMessage(
    WebMessageData? message,
    String? sourceOrigin,
    bool isMainFrame,
  ) => _listener._onPostMessageFromPlatform(message, sourceOrigin, isMainFrame);
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener}
class AndroidWebMessageListener extends PlatformWebMessageListener {
  /// Constructs a [AndroidWebMessageListener].
  AndroidWebMessageListener(PlatformWebMessageListenerCreationParams params)
    : super.implementation(
        params is AndroidWebMessageListenerCreationParams
            ? params
            : AndroidWebMessageListenerCreationParams.fromPlatformWebMessageListenerCreationParams(
                params,
              ),
      ) {
    assert(
      !_androidParams.allowedOriginRules.contains(""),
      "allowedOriginRules cannot contain empty strings",
    );
    _channelSuffix = '${_id}_${params.jsObjectName}';
    hostApi = WebMessageListenerHostApi(messageChannelSuffix: _channelSuffix);
    WebMessageListenerFlutterApi.setUp(
      _WebMessageListenerFlutterApiImpl(this),
      messageChannelSuffix: _channelSuffix,
    );
  }

  /// `<id>_<jsObjectName>`, matching the suffix the Kotlin side registers against. Stored so
  /// construction and disposal cannot drift apart -- unregistering against the wrong suffix would
  /// silently leave the handler bound.
  late final String _channelSuffix;

  /// Transport for this listener instance (§165).
  late final WebMessageListenerHostApi hostApi;

  static final AndroidWebMessageListener _staticValue =
      AndroidWebMessageListener(
        AndroidWebMessageListenerCreationParams(
          jsObjectName: '',
          allowedOriginRules: {"*"},
        ),
      );

  /// Provide static access.
  factory AndroidWebMessageListener.static() {
    return _staticValue;
  }

  ///Message Listener ID used internally.
  final String _id = IdGenerator.generate();

  AndroidJavaScriptReplyProxy? _replyProxy;

  AndroidWebMessageListenerCreationParams get _androidParams =>
      params as AndroidWebMessageListenerCreationParams;

  void _onPostMessageFromPlatform(
    WebMessageData? message,
    String? sourceOrigin,
    bool isMainFrame,
  ) {
    // Created on first message and reused, as before: the proxy is the reply handle for this
    // listener, not for the individual message.
    _replyProxy ??= AndroidJavaScriptReplyProxy(
      PlatformJavaScriptReplyProxyCreationParams(webMessageListener: this),
    );
    onPostMessage?.call(
      message == null ? null : webMessageFromData(message),
      sourceOrigin == null ? null : WebUri(sourceOrigin),
      isMainFrame,
      _replyProxy!,
    );
  }

  @override
  void dispose() {
    // Unregisters this instance's generated event handler for its suffix.
    WebMessageListenerFlutterApi.setUp(
      null,
      messageChannelSuffix: _channelSuffix,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "jsObjectName": params.jsObjectName,
      "allowedOriginRules": _androidParams.allowedOriginRules.toList(),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebMessageListener{id: $_id, jsObjectName: ${params.jsObjectName}, allowedOriginRules: ${params.allowedOriginRules}, replyProxy: $_replyProxy}';
  }
}

/// Object specifying creation parameters for creating a [AndroidJavaScriptReplyProxy].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformJavaScriptReplyProxyCreationParams] for
/// more information.
@immutable
class AndroidJavaScriptReplyProxyCreationParams
    extends PlatformJavaScriptReplyProxyCreationParams {
  /// Creates a new [AndroidJavaScriptReplyProxyCreationParams] instance.
  const AndroidJavaScriptReplyProxyCreationParams({
    required super.webMessageListener,
  });

  /// Creates a [AndroidJavaScriptReplyProxyCreationParams] instance based on [PlatformJavaScriptReplyProxyCreationParams].
  factory AndroidJavaScriptReplyProxyCreationParams.fromPlatformJavaScriptReplyProxyCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return AndroidJavaScriptReplyProxyCreationParams(
      webMessageListener: params.webMessageListener,
    );
  }
}

///{@macro flutter_inappwebview_platform_interface.JavaScriptReplyProxy}
class AndroidJavaScriptReplyProxy extends PlatformJavaScriptReplyProxy {
  /// Constructs a [AndroidWebMessageListener].
  AndroidJavaScriptReplyProxy(PlatformJavaScriptReplyProxyCreationParams params)
    : super.implementation(
        params is AndroidJavaScriptReplyProxyCreationParams
            ? params
            : AndroidJavaScriptReplyProxyCreationParams.fromPlatformJavaScriptReplyProxyCreationParams(
                params,
              ),
      );

  AndroidWebMessageListener get _androidWebMessageListener =>
      params.webMessageListener as AndroidWebMessageListener;

  @override
  Future<void> postMessage(WebMessage message) async {
    // The bool is discarded: the platform interface declares `Future<void>`.
    await _androidWebMessageListener.hostApi.postMessage(
      webMessageToData(message),
    );
  }

  @override
  String toString() {
    return 'AndroidJavaScriptReplyProxy{}';
  }
}
