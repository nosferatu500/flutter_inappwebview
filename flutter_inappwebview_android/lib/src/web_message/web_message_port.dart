import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'web_message_channel.dart';
import 'web_message_converters.dart';

/// Object specifying creation parameters for creating a [AndroidWebMessagePort].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessagePortCreationParams] for
/// more information.
@immutable
class AndroidWebMessagePortCreationParams
    extends PlatformWebMessagePortCreationParams {
  /// Creates a new [AndroidWebMessagePortCreationParams] instance.
  const AndroidWebMessagePortCreationParams({required super.index});

  /// Creates a [AndroidWebMessagePortCreationParams] instance based on [PlatformWebMessagePortCreationParams].
  factory AndroidWebMessagePortCreationParams.fromPlatformWebMessagePortCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebMessagePortCreationParams params,
  ) {
    return AndroidWebMessagePortCreationParams(index: params.index);
  }

  @override
  String toString() {
    return 'AndroidWebMessagePortCreationParams{index: $index}';
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessagePort}
class AndroidWebMessagePort extends PlatformWebMessagePort {
  WebMessageCallback? _onMessage;
  late AndroidWebMessageChannel _webMessageChannel;

  /// Constructs a [AndroidWebMessagePort].
  AndroidWebMessagePort(PlatformWebMessagePortCreationParams params)
    : super.implementation(
        params is AndroidWebMessagePortCreationParams
            ? params
            : AndroidWebMessagePortCreationParams.fromPlatformWebMessagePortCreationParams(
                params,
              ),
      );

  // The bool each host method returns is discarded: the platform interface declares `Future<void>`
  // for all three, and `false` means only "the view is not an InAppWebView". Kept on the wire so
  // the distinction survives -- see the schema.
  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {
    await _webMessageChannel.internalHostApi.setWebMessageCallback(
      params.index,
    );
    _onMessage = onMessage;
  }

  @override
  Future<void> postMessage(WebMessage message) async {
    await _webMessageChannel.internalHostApi.postMessage(
      params.index,
      webMessageToData(message),
    );
  }

  @override
  Future<void> close() async {
    await _webMessageChannel.internalHostApi.close(params.index);
  }

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "index": params.index,
      "webMessageChannelId": _webMessageChannel.params.id,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebMessagePort{index: ${params.index}}';
  }
}

extension InternalWebMessagePort on AndroidWebMessagePort {
  WebMessageCallback? get onMessage => _onMessage;
  void set onMessage(WebMessageCallback? value) => _onMessage = value;

  AndroidWebMessageChannel get webMessageChannel => _webMessageChannel;
  void set webMessageChannel(AndroidWebMessageChannel value) =>
      _webMessageChannel = value;
}
