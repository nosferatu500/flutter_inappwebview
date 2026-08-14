import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.supported_platforms}
class ServiceWorkerController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
  ServiceWorkerController()
    : this.fromPlatformCreationParams(
        const PlatformServiceWorkerControllerCreationParams(),
      );

  /// Constructs a [ServiceWorkerController] from creation params for a specific
  /// platform.
  ServiceWorkerController.fromPlatformCreationParams(
    PlatformServiceWorkerControllerCreationParams params,
  ) : this.fromPlatform(PlatformServiceWorkerController(params));

  /// Constructs a [ServiceWorkerController] from a specific platform
  /// implementation.
  ServiceWorkerController.fromPlatform(this.platform);

  /// Implementation of [PlatformServiceWorkerController] for the current platform.
  final PlatformServiceWorkerController platform;

  static ServiceWorkerController? _instance;

  ///Gets the [ServiceWorkerController] shared instance.
  static ServiceWorkerController instance() {
    if (_instance == null) {
      _instance = ServiceWorkerController();
    }
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient.supported_platforms}
  ServiceWorkerClient? get serviceWorkerClient => platform.serviceWorkerClient;

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  setServiceWorkerClient(ServiceWorkerClient? value) =>
      platform.setServiceWorkerClient(value);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  static Future<bool> getAllowContentAccess() =>
      PlatformServiceWorkerController.static().getAllowContentAccess();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  static Future<bool> getAllowFileAccess() =>
      PlatformServiceWorkerController.static().getAllowFileAccess();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  static Future<bool> getBlockNetworkLoads() =>
      PlatformServiceWorkerController.static().getBlockNetworkLoads();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  static Future<CacheMode?> getCacheMode() =>
      PlatformServiceWorkerController.static().getCacheMode();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  static Future<void> setAllowContentAccess(bool allow) =>
      PlatformServiceWorkerController.static().setAllowContentAccess(allow);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  static Future<void> setAllowFileAccess(bool allow) =>
      PlatformServiceWorkerController.static().setAllowFileAccess(allow);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  static Future<void> setBlockNetworkLoads(bool flag) =>
      PlatformServiceWorkerController.static().setBlockNetworkLoads(flag);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  static Future<void> setCacheMode(CacheMode mode) =>
      PlatformServiceWorkerController.static().setCacheMode(mode);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformServiceWorkerController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.isMethodSupported}
  static bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformServiceWorkerController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
