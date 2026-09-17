import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/geolocation_permissions.g.dart';

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
///
/// Transport is Pigeon-generated ([GeolocationPermissionsHostApi]) rather than a hand-written
/// `MethodChannel`; the eleventh channel migrated, after find_interaction (§14),
/// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
/// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
/// web_storage_manager (§169) and profile_store (§173). There is no `messageChannelSuffix` because
/// `android.webkit.GeolocationPermissions` is process-global.
class AndroidGeolocationPermissions extends PlatformGeolocationPermissions
    implements Disposable {
  /// Creates a new [AndroidGeolocationPermissions].
  AndroidGeolocationPermissions(
    PlatformGeolocationPermissionsCreationParams params,
  ) : super.implementation(
        params is AndroidGeolocationPermissionsCreationParams
            ? params
            : AndroidGeolocationPermissionsCreationParams.fromPlatformGeolocationPermissionsCreationParams(
                params,
              ),
      );

  final GeolocationPermissionsHostApi _hostApi =
      GeolocationPermissionsHostApi();

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

  /// Provide static access.
  factory AndroidGeolocationPermissions.static() {
    return instance();
  }

  @override
  Future<bool> allow({required String origin, String? profileName}) async {
    // The `?? false` the hand-written channel needed is gone: the schema types this non-null, and
    // the host still answers `false` for an unresolvable store.
    return await _hostApi.allow(origin, profileName);
  }

  @override
  Future<bool> clear({required String origin, String? profileName}) async {
    return await _hostApi.clear(origin, profileName);
  }

  @override
  Future<bool> clearAll({String? profileName}) async {
    return await _hostApi.clearAll(profileName);
  }

  @override
  Future<bool?> getAllowed({
    required String origin,
    String? profileName,
  }) async {
    // `bool?`, and the null is not incidental: it means the store could not be resolved, which is a
    // different answer from `false` ("asked, nothing stored"). The four sibling methods spell the
    // same condition as `false` or an empty list.
    return await _hostApi.getAllowed(origin, profileName);
  }

  @override
  Future<List<String>> getOrigins({String? profileName}) async {
    // Origins come back normalised with a trailing `/`; see the platform-interface dartdoc. The old
    // cast from an untyped platform `List` and its `?? <String>[]` are both gone — Pigeon decodes
    // `List<String>` directly and the schema types it non-null.
    return await _hostApi.getOrigins(profileName);
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton.
  }
}
