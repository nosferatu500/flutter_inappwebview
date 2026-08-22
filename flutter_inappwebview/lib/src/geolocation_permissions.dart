import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions}
///
///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.supported_platforms}
class GeolocationPermissions {
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions}
  GeolocationPermissions()
    : this.fromPlatformCreationParams(
        const PlatformGeolocationPermissionsCreationParams(),
      );

  /// Constructs a [GeolocationPermissions] from creation params for a specific
  /// platform.
  GeolocationPermissions.fromPlatformCreationParams(
    PlatformGeolocationPermissionsCreationParams params,
  ) : this.fromPlatform(PlatformGeolocationPermissions(params));

  /// Constructs a [GeolocationPermissions] from a specific platform
  /// implementation.
  GeolocationPermissions.fromPlatform(this.platform);

  /// Implementation of [PlatformGeolocationPermissions] for the current platform.
  final PlatformGeolocationPermissions platform;

  static GeolocationPermissions? _instance;

  ///Gets the [GeolocationPermissions] shared instance.
  static GeolocationPermissions instance() {
    _instance ??= GeolocationPermissions();
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.allow}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.allow.supported_platforms}
  Future<bool> allow({required String origin, String? profileName}) =>
      platform.allow(origin: origin, profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clear}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clear.supported_platforms}
  Future<bool> clear({required String origin, String? profileName}) =>
      platform.clear(origin: origin, profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clearAll}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clearAll.supported_platforms}
  Future<bool> clearAll({String? profileName}) =>
      platform.clearAll(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getAllowed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getAllowed.supported_platforms}
  Future<bool?> getAllowed({required String origin, String? profileName}) =>
      platform.getAllowed(origin: origin, profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getOrigins}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getOrigins.supported_platforms}
  Future<List<String>> getOrigins({String? profileName}) =>
      platform.getOrigins(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformGeolocationPermissions.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.isMethodSupported}
  static bool isMethodSupported(
    PlatformGeolocationPermissionsMethod method, {
    TargetPlatform? platform,
  }) => PlatformGeolocationPermissions.static().isMethodSupported(
    method,
    platform: platform,
  );
}
