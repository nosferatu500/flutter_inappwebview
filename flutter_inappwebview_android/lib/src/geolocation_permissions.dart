import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidGeolocationPermissions].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformGeolocationPermissionsCreationParams] for
/// more information.
@immutable
class AndroidGeolocationPermissionsCreationParams
    extends PlatformGeolocationPermissionsCreationParams {
  /// Creates a new [AndroidGeolocationPermissionsCreationParams] instance.
  const AndroidGeolocationPermissionsCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformGeolocationPermissionsCreationParams params,
  ) : super();

  /// Creates a [AndroidGeolocationPermissionsCreationParams] instance based on [PlatformGeolocationPermissionsCreationParams].
  factory AndroidGeolocationPermissionsCreationParams.fromPlatformGeolocationPermissionsCreationParams(
    PlatformGeolocationPermissionsCreationParams params,
  ) {
    return AndroidGeolocationPermissionsCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions}
class AndroidGeolocationPermissions extends PlatformGeolocationPermissions
    with ChannelController {
  /// Creates a new [AndroidGeolocationPermissions].
  AndroidGeolocationPermissions(
    PlatformGeolocationPermissionsCreationParams params,
  ) : super.implementation(
        params is AndroidGeolocationPermissionsCreationParams
            ? params
            : AndroidGeolocationPermissionsCreationParams.fromPlatformGeolocationPermissionsCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'dev.nosferatu500.inappwebview/inappwebview_geolocationpermissions',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static AndroidGeolocationPermissions? _instance;

  ///Gets the [AndroidGeolocationPermissions] shared instance.
  static AndroidGeolocationPermissions instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidGeolocationPermissions _init() {
    _instance = AndroidGeolocationPermissions(
      AndroidGeolocationPermissionsCreationParams(
        const PlatformGeolocationPermissionsCreationParams(),
      ),
    );
    return _instance!;
  }

  static final AndroidGeolocationPermissions _staticValue =
      AndroidGeolocationPermissions(
        AndroidGeolocationPermissionsCreationParams(
          const PlatformGeolocationPermissionsCreationParams(),
        ),
      );

  /// Provide static access.
  factory AndroidGeolocationPermissions.static() {
    return _staticValue;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<bool> allow({required String origin, String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('origin', () => origin);
    return await channel?.invokeMethod<bool>('allow', args) ?? false;
  }

  @override
  Future<bool> clear({required String origin, String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('origin', () => origin);
    return await channel?.invokeMethod<bool>('clear', args) ?? false;
  }

  @override
  Future<bool> clearAll({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    return await channel?.invokeMethod<bool>('clearAll', args) ?? false;
  }

  @override
  Future<bool?> getAllowed({
    required String origin,
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('origin', () => origin);
    return await channel?.invokeMethod<bool?>('getAllowed', args);
  }

  @override
  Future<List<String>> getOrigins({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    return (await channel?.invokeMethod<List>(
          'getOrigins',
          args,
        ))?.cast<String>() ??
        <String>[];
  }

  @override
  void dispose() {
    // empty
  }
}
