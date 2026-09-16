import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/profile_store.g.dart';

/// Object specifying creation parameters for creating a [AndroidProfileStore].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProfileStoreCreationParams] for
/// more information.
@immutable
class AndroidProfileStoreCreationParams
    extends PlatformProfileStoreCreationParams {
  /// Creates a new [AndroidProfileStoreCreationParams] instance.
  const AndroidProfileStoreCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProfileStoreCreationParams params,
  ) : super();

  /// Creates a [AndroidProfileStoreCreationParams] instance based on [PlatformProfileStoreCreationParams].
  factory AndroidProfileStoreCreationParams.fromPlatformProfileStoreCreationParams(
    PlatformProfileStoreCreationParams params,
  ) {
    return AndroidProfileStoreCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore}
///
/// Transport is Pigeon-generated ([ProfileStoreHostApi]) rather than a hand-written `MethodChannel`;
/// the tenth channel migrated, after find_interaction (§14), process_global_config (§157), proxy
/// (§160), webview_feature (§161), tracing_controller (§162), credential_database (§163), both
/// web_message channels (§165), cookie_manager (§168) and web_storage_manager (§169). There is no
/// `messageChannelSuffix` because `androidx.webkit.ProfileStore` is process-global.
class AndroidProfileStore extends PlatformProfileStore implements Disposable {
  /// Creates a new [AndroidProfileStore].
  AndroidProfileStore(PlatformProfileStoreCreationParams params)
    : super.implementation(
        params is AndroidProfileStoreCreationParams
            ? params
            : AndroidProfileStoreCreationParams.fromPlatformProfileStoreCreationParams(
                params,
              ),
      );

  final ProfileStoreHostApi _hostApi = ProfileStoreHostApi();

  static AndroidProfileStore? _instance;

  ///Gets the [AndroidProfileStore] shared instance.
  static AndroidProfileStore instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProfileStore _init() {
    _instance = AndroidProfileStore(
      AndroidProfileStoreCreationParams(
        const PlatformProfileStoreCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Provide static access.
  factory AndroidProfileStore.static() {
    return instance();
  }

  @override
  Future<List<String>> getAllProfileNames() async {
    // No `?? <String>[]`: the schema types this non-null, and the host already answers an empty
    // list when MULTI_PROFILE is unsupported. The old cast from an untyped platform `List` is gone
    // too — Pigeon decodes `List<String>` directly.
    return await _hostApi.getAllProfileNames();
  }

  @override
  Future<String?> getOrCreateProfile({required String name}) async {
    // `String?`, and the null is "nothing was created" rather than "created with an empty name".
    return await _hostApi.getOrCreateProfile(name);
  }

  @override
  Future<void> addCustomHeader(
    CustomHeader header, {
    String? profileName,
  }) async {
    await _hostApi.addCustomHeader(
      CustomHeaderData(
        name: header.name,
        value: header.value,
        originRules: header.originRules.toList(),
      ),
      profileName,
    );
  }

  @override
  Future<bool> hasCustomHeader(String headerName, {String? profileName}) async {
    // The `?? false` the hand-written channel needed is gone: the schema types this non-null, and
    // the host still answers `false` for an unresolvable profile or a missing feature.
    return await _hostApi.hasCustomHeader(headerName, profileName);
  }

  @override
  Future<Set<CustomHeader>> getCustomHeaders({
    String? headerName,
    String? headerValue,
    String? profileName,
  }) async {
    final headers = await _hostApi.getCustomHeaders(
      headerName,
      headerValue,
      profileName,
    );
    // Back to a `Set` because that is what the platform interface declares and what androidx holds;
    // the wire has no set, so the list is the transport shape only.
    return headers
        .map(
          (h) => CustomHeader(
            name: h.name,
            value: h.value,
            originRules: h.originRules.toSet(),
          ),
        )
        .toSet();
  }

  @override
  Future<void> clearCustomHeader(
    String headerName, {
    String? headerValue,
    String? profileName,
  }) async {
    await _hostApi.clearCustomHeader(headerName, headerValue, profileName);
  }

  @override
  Future<void> clearAllCustomHeaders({String? profileName}) async {
    await _hostApi.clearAllCustomHeaders(profileName);
  }

  @override
  Future<bool> deleteProfile({required String name}) async {
    // Throws a `PlatformException(code: "ProfileStoreManager")` when the platform refuses the
    // deletion — a living WebView holds the profile, the profile was loaded this run, or the name is
    // the default profile. `false` means only "no such profile" or "MULTI_PROFILE unsupported".
    return await _hostApi.deleteProfile(name);
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton.
  }
}
