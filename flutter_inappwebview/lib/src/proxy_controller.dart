import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.supported_platforms}
class ProxyController {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController}
  ProxyController()
    : this.fromPlatformCreationParams(
        const PlatformProxyControllerCreationParams(),
      );

  /// Constructs a [ProxyController] from creation params for a specific
  /// platform.
  ProxyController.fromPlatformCreationParams(
    PlatformProxyControllerCreationParams params,
  ) : this.fromPlatform(PlatformProxyController(params));

  /// Constructs a [ProxyController] from a specific platform
  /// implementation.
  ProxyController.fromPlatform(this.platform);

  /// Implementation of [PlatformProxyController] for the current platform.
  final PlatformProxyController platform;

  static ProxyController? _instance;

  ///Gets the [ProxyController] shared instance.
  static ProxyController instance() {
    _instance ??= ProxyController();
    return _instance!;
  }

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.setProxyOverride}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.setProxyOverride.supported_platforms}
  Future<void> setProxyOverride({required ProxySettings settings}) =>
      platform.setProxyOverride(settings: settings);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride.supported_platforms}
  Future<void> clearProxyOverride() => platform.clearProxyOverride();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProxyController.static().isClassSupported(platform: platform);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProxyController.isMethodSupported}
  static bool isMethodSupported(
    PlatformProxyControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformProxyController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
