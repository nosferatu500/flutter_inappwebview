import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.supported_platforms}
class ServiceWorkerController {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController}
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

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient.supported_platforms}
  ServiceWorkerClient? get serviceWorkerClient => platform.serviceWorkerClient;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) =>
      platform.setServiceWorkerClient(value);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  static Future<bool> getAllowContentAccess({String? profileName}) =>
      PlatformServiceWorkerController.static().getAllowContentAccess(
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  static Future<bool> getAllowFileAccess({String? profileName}) =>
      PlatformServiceWorkerController.static().getAllowFileAccess(
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  static Future<bool> getBlockNetworkLoads({String? profileName}) =>
      PlatformServiceWorkerController.static().getBlockNetworkLoads(
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  static Future<CacheMode?> getCacheMode({String? profileName}) =>
      PlatformServiceWorkerController.static().getCacheMode(
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled.supported_platforms}
  static Future<bool?> getIncludeCookiesOnShouldInterceptRequestEnabled({
    String? profileName,
  }) => PlatformServiceWorkerController.static()
      .getIncludeCookiesOnShouldInterceptRequestEnabled(
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled.supported_platforms}
  static Future<void> setIncludeCookiesOnShouldInterceptRequestEnabled(
    bool enabled, {
    String? profileName,
  }) => PlatformServiceWorkerController.static()
      .setIncludeCookiesOnShouldInterceptRequestEnabled(
        enabled,
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  static Future<void> setAllowContentAccess(
    bool allow, {
    String? profileName,
  }) => PlatformServiceWorkerController.static().setAllowContentAccess(
    allow,
    profileName: profileName,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  static Future<void> setAllowFileAccess(bool allow, {String? profileName}) =>
      PlatformServiceWorkerController.static().setAllowFileAccess(
        allow,
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  static Future<void> setBlockNetworkLoads(bool flag, {String? profileName}) =>
      PlatformServiceWorkerController.static().setBlockNetworkLoads(
        flag,
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  static Future<void> setCacheMode(CacheMode mode, {String? profileName}) =>
      PlatformServiceWorkerController.static().setCacheMode(
        mode,
        profileName: profileName,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformServiceWorkerController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformServiceWorkerController.isMethodSupported}
  static bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformServiceWorkerController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
