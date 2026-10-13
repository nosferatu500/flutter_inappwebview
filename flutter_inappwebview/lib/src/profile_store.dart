import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.supported_platforms}
class ProfileStore {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore}
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

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.defaultProfileName}
  static const String defaultProfileName =
      PlatformProfileStore.defaultProfileName;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames.supported_platforms}
  Future<List<String>> getAllProfileNames() => platform.getAllProfileNames();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile.supported_platforms}
  Future<String?> getOrCreateProfile({required String name}) =>
      platform.getOrCreateProfile(name: name);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.addCustomHeader}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.addCustomHeader.supported_platforms}
  Future<bool> addCustomHeader(CustomHeader header, {String? profileName}) =>
      platform.addCustomHeader(header, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.hasCustomHeader}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.hasCustomHeader.supported_platforms}
  Future<bool?> hasCustomHeader(String headerName, {String? profileName}) =>
      platform.hasCustomHeader(headerName, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getCustomHeaders}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.getCustomHeaders.supported_platforms}
  Future<Set<CustomHeader>> getCustomHeaders({
    String? headerName,
    String? headerValue,
    String? profileName,
  }) => platform.getCustomHeaders(
    headerName: headerName,
    headerValue: headerValue,
    profileName: profileName,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.clearCustomHeader}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.clearCustomHeader.supported_platforms}
  Future<bool> clearCustomHeader(
    String headerName, {
    String? headerValue,
    String? profileName,
  }) => platform.clearCustomHeader(
    headerName,
    headerValue: headerValue,
    profileName: profileName,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.clearAllCustomHeaders}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.clearAllCustomHeaders.supported_platforms}
  Future<bool> clearAllCustomHeaders({String? profileName}) =>
      platform.clearAllCustomHeaders(profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.deleteProfile}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.deleteProfile.supported_platforms}
  Future<bool> deleteProfile({required String name}) =>
      platform.deleteProfile(name: name);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStoreCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProfileStore.static().isClassSupported(platform: platform);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformProfileStore.isMethodSupported}
  static bool isMethodSupported(
    PlatformProfileStoreMethod method, {
    TargetPlatform? platform,
  }) => PlatformProfileStore.static().isMethodSupported(
    method,
    platform: platform,
  );
}
