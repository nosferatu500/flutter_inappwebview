import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebMessagePort}
class WebMessagePort implements IWebMessagePort {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebMessagePort}
  WebMessagePort({required int index})
    : this.fromPlatformCreationParams(
        params: PlatformWebMessagePortCreationParams(index: index),
      );

  /// Constructs a [WebMessagePort].
  ///
  /// See [WebMessagePort.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebMessagePort.fromPlatformCreationParams({
    required PlatformWebMessagePortCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebMessagePort(params));

  /// Constructs a [WebMessagePort] from a specific platform implementation.
  WebMessagePort.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebMessagePort] for the current platform.
  final PlatformWebMessagePort platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebMessagePort.setWebMessageCallback}
  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) =>
      platform.setWebMessageCallback(onMessage);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebMessagePort.postMessage}
  @override
  Future<void> postMessage(WebMessage message) => platform.postMessage(message);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebMessagePort.close}
  @override
  Future<void> close() => platform.close();

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) =>
      platform.toMap(enumMethod: enumMethod);

  @override
  Map<String, dynamic> toJson() => platform.toJson();

  @override
  String toString() => platform.toString();
}
