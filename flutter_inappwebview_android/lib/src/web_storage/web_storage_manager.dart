import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/web_storage_manager.g.dart';

/// Object specifying creation parameters for creating a [AndroidWebStorageManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebStorageManagerCreationParams] for
/// more information.
@immutable
class AndroidWebStorageManagerCreationParams
    extends PlatformWebStorageManagerCreationParams {
  /// Creates a new [AndroidWebStorageManagerCreationParams] instance.
  const AndroidWebStorageManagerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebStorageManagerCreationParams params,
  ) : super();

  /// Creates a [AndroidWebStorageManagerCreationParams] instance based on [PlatformWebStorageManagerCreationParams].
  factory AndroidWebStorageManagerCreationParams.fromPlatformWebStorageManagerCreationParams(
    PlatformWebStorageManagerCreationParams params,
  ) {
    return AndroidWebStorageManagerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager}
///
/// Transport is Pigeon-generated ([WebStorageManagerHostApi]) rather than a hand-written
/// `MethodChannel`; the ninth channel migrated, after find_interaction (§14),
/// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
/// credential_database (§163), both web_message channels (§165) and cookie_manager (§168). There is
/// no `messageChannelSuffix` because `android.webkit.WebStorage` is process-global.
class AndroidWebStorageManager extends PlatformWebStorageManager
    implements Disposable {
  /// Creates a new [AndroidWebStorageManager].
  AndroidWebStorageManager(PlatformWebStorageManagerCreationParams params)
    : super.implementation(
        params is AndroidWebStorageManagerCreationParams
            ? params
            : AndroidWebStorageManagerCreationParams.fromPlatformWebStorageManagerCreationParams(
                params,
              ),
      );

  final WebStorageManagerHostApi _hostApi = WebStorageManagerHostApi();

  static AndroidWebStorageManager? _instance;

  ///Gets the WebStorage manager shared instance.
  static AndroidWebStorageManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidWebStorageManager _init() {
    _instance = AndroidWebStorageManager(
      AndroidWebStorageManagerCreationParams(
        const PlatformWebStorageManagerCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Provide static access.
  factory AndroidWebStorageManager.static() {
    return instance();
  }

  @override
  Future<List<WebStorageOrigin>> getOrigins({String? profileName}) async {
    final origins = await _hostApi.getOrigins(profileName);
    return origins
        .map(
          (o) => WebStorageOrigin(
            origin: o.origin,
            quota: o.quota,
            usage: o.usage,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteAllData({String? profileName}) async {
    // The host answers whether the storage was resolved at all, and that answer is dropped here
    // because the platform interface declares `Future<void>`. Surfacing it is a platform-interface
    // change (see the schema, and the TODO row it names), not a transport one.
    await _hostApi.deleteAllData(profileName);
  }

  @override
  Future<void> deleteOrigin({
    required String origin,
    String? profileName,
  }) async {
    // See deleteAllData for the discarded bool.
    await _hostApi.deleteOrigin(origin, profileName);
  }

  @override
  Future<bool> deleteBrowsingData({String? profileName}) async {
    return await _hostApi.deleteBrowsingData(profileName);
  }

  @override
  Future<String?> deleteBrowsingDataForSite({
    required String site,
    String? profileName,
  }) async {
    // Answers the registrable domain the platform actually cleared, which is not necessarily
    // [site]: "www.example.com" comes back as "example.com".
    return await _hostApi.deleteBrowsingDataForSite(site, profileName);
  }

  @override
  Future<int> getQuotaForOrigin({
    required String origin,
    String? profileName,
  }) async {
    // `0` when the storage could not be resolved, which is indistinguishable from a genuine zero
    // quota. Preserved from the hand-written channel; see the schema.
    return await _hostApi.getQuotaForOrigin(origin, profileName);
  }

  @override
  Future<int> getUsageForOrigin({
    required String origin,
    String? profileName,
  }) async {
    // `0` on an unresolvable store; see getQuotaForOrigin.
    return await _hostApi.getUsageForOrigin(origin, profileName);
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton.
  }
}
