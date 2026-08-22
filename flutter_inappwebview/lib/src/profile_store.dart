import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.supported_platforms}
class ProfileStore {
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore}
  ProfileStore()
    : this.fromPlatformCreationParams(
        const PlatformProfileStoreCreationParams(),
      );

  /// Constructs a [ProfileStore] from creation params for a specific
  /// platform.
  ProfileStore.fromPlatformCreationParams(
    PlatformProfileStoreCreationParams params,
  ) : this.fromPlatform(PlatformProfileStore(params));

  /// Constructs a [ProfileStore] from a specific platform
  /// implementation.
  ProfileStore.fromPlatform(this.platform);

  /// Implementation of [PlatformProfileStore] for the current platform.
  final PlatformProfileStore platform;

  static ProfileStore? _instance;

  ///Gets the [ProfileStore] shared instance.
  static ProfileStore instance() {
    _instance ??= ProfileStore();
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.defaultProfileName}
  static const String defaultProfileName =
      PlatformProfileStore.defaultProfileName;

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames.supported_platforms}
  Future<List<String>> getAllProfileNames() => platform.getAllProfileNames();

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile.supported_platforms}
  Future<String?> getOrCreateProfile({required String name}) =>
      platform.getOrCreateProfile(name: name);

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.deleteProfile}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.deleteProfile.supported_platforms}
  Future<bool> deleteProfile({required String name}) =>
      platform.deleteProfile(name: name);

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProfileStore.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.isMethodSupported}
  static bool isMethodSupported(
    PlatformProfileStoreMethod method, {
    TargetPlatform? platform,
  }) => PlatformProfileStore.static().isMethodSupported(
    method,
    platform: platform,
  );
}
