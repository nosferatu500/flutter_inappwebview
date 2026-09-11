import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/web_message.g.dart';
import 'web_message_converters.dart';
import 'web_message_port.dart';

/// Object specifying creation parameters for creating a [AndroidWebMessageChannel].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessageChannelCreationParams] for
/// more information.
@immutable
class AndroidWebMessageChannelCreationParams
    extends PlatformWebMessageChannelCreationParams {
  /// Creates a new [AndroidWebMessageChannelCreationParams] instance.
  const AndroidWebMessageChannelCreationParams({
    required super.id,
    required super.port1,
    required super.port2,
  });

  /// Creates a [AndroidWebMessageChannelCreationParams] instance based on [PlatformWebMessageChannelCreationParams].
  factory AndroidWebMessageChannelCreationParams.fromPlatformWebMessageChannelCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebMessageChannelCreationParams params,
  ) {
    return AndroidWebMessageChannelCreationParams(
      id: params.id,
      port1: params.port1,
      port2: params.port2,
    );
  }

  @override
  String toString() {
    return 'AndroidWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
class AndroidWebMessageChannel extends PlatformWebMessageChannel
    implements WebMessageChannelFlutterApi {
  /// Constructs a [AndroidWebMessageChannel].
  AndroidWebMessageChannel(PlatformWebMessageChannelCreationParams params)
    : super.implementation(
        params is AndroidWebMessageChannelCreationParams
            ? params
            : AndroidWebMessageChannelCreationParams.fromPlatformWebMessageChannelCreationParams(
                params,
              ),
      ) {
    hostApi = WebMessageChannelHostApi(messageChannelSuffix: params.id);
    WebMessageChannelFlutterApi.setUp(this, messageChannelSuffix: params.id);
  }

  /// Transport for this channel instance. The channel id is the `messageChannelSuffix`, so each
  /// `WebMessageChannel` gets its own set of generated channels (§165).
  late final WebMessageChannelHostApi hostApi;

  static final AndroidWebMessageChannel _staticValue = AndroidWebMessageChannel(
    AndroidWebMessageChannelCreationParams(
      id: '',
      port1: AndroidWebMessagePort(
        AndroidWebMessagePortCreationParams(index: 0),
      ),
      port2: AndroidWebMessagePort(
        AndroidWebMessagePortCreationParams(index: 1),
      ),
    ),
  );

  /// Provide static access.
  factory AndroidWebMessageChannel.static() {
    return _staticValue;
  }

  AndroidWebMessagePort get _androidPort1 => port1 as AndroidWebMessagePort;

  AndroidWebMessagePort get _androidPort2 => port2 as AndroidWebMessagePort;

  static AndroidWebMessageChannel? _fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    var webMessageChannel = AndroidWebMessageChannel(
      AndroidWebMessageChannelCreationParams(
        id: map["id"],
        port1: AndroidWebMessagePort(
          AndroidWebMessagePortCreationParams(index: 0),
        ),
        port2: AndroidWebMessagePort(
          AndroidWebMessagePortCreationParams(index: 1),
        ),
      ),
    );
    webMessageChannel._androidPort1.webMessageChannel = webMessageChannel;
    webMessageChannel._androidPort2.webMessageChannel = webMessageChannel;
    return webMessageChannel;
  }

  @override
  void onMessage(int index, WebMessageData? message) {
    final port = index == 0 ? _androidPort1 : _androidPort2;
    port.onMessage?.call(message == null ? null : webMessageFromData(message));
  }

  @override
  AndroidWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    return _fromMap(map);
  }

  @override
  void dispose() {
    // Unregisters this instance's generated event handler. Skipping it would leave it bound to a
    // disposed channel for the life of the messenger.
    WebMessageChannelFlutterApi.setUp(null, messageChannelSuffix: params.id);
  }

  @override
  String toString() {
    return 'AndroidWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}

extension InternalWebMessageChannel on AndroidWebMessageChannel {
  /// The generated transport, reached by [AndroidWebMessagePort], which posts through the channel
  /// that owns it.
  WebMessageChannelHostApi get internalHostApi => hostApi;
}
