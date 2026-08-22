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
    _instance ??= ServiceWorkerController();
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient.supported_platforms}
  ServiceWorkerClient? get serviceWorkerClient => platform.serviceWorkerClient;

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) =>
      platform.setServiceWorkerClient(value);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  static Future<bool> getAllowContentAccess({String? profileName}) =>
      PlatformServiceWorkerController.static().getAllowContentAccess(
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  static Future<bool> getAllowFileAccess({String? profileName}) =>
      PlatformServiceWorkerController.static().getAllowFileAccess(
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  static Future<bool> getBlockNetworkLoads({String? profileName}) =>
      PlatformServiceWorkerController.static().getBlockNetworkLoads(
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  static Future<CacheMode?> getCacheMode({String? profileName}) =>
      PlatformServiceWorkerController.static().getCacheMode(
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  static Future<void> setAllowContentAccess(
    bool allow, {
    String? profileName,
  }) => PlatformServiceWorkerController.static().setAllowContentAccess(
    allow,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  static Future<void> setAllowFileAccess(bool allow, {String? profileName}) =>
      PlatformServiceWorkerController.static().setAllowFileAccess(
        allow,
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  static Future<void> setBlockNetworkLoads(bool flag, {String? profileName}) =>
      PlatformServiceWorkerController.static().setBlockNetworkLoads(
        flag,
        profileName: profileName,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  static Future<void> setCacheMode(CacheMode mode, {String? profileName}) =>
      PlatformServiceWorkerController.static().setCacheMode(
        mode,
        profileName: profileName,
      );

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
