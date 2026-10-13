import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.supported_platforms}
class WebStorageManager {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager}
  WebStorageManager()
    : this.fromPlatformCreationParams(
        const PlatformWebStorageManagerCreationParams(),
      );

  /// Constructs a [WebStorageManager] from creation params for a specific
  /// platform.
  WebStorageManager.fromPlatformCreationParams(
    PlatformWebStorageManagerCreationParams params,
  ) : this.fromPlatform(PlatformWebStorageManager(params));

  /// Constructs a [WebStorageManager] from a specific platform
  /// implementation.
  WebStorageManager.fromPlatform(this.platform);

  /// Implementation of [PlatformCookieManager] for the current platform.
  final PlatformWebStorageManager platform;

  static WebStorageManager? _instance;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebStorageManager.static().isClassSupported(platform: platform);

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformWebStorageManagerMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebStorageManager.static().isMethodSupported(
    method,
    platform: platform,
  );

  ///Gets the [WebStorageManager] shared instance.
  static WebStorageManager instance() {
    _instance ??= WebStorageManager();
    return _instance!;
  }

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getOrigins}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getOrigins.supported_platforms}
  Future<List<WebStorageOrigin>> getOrigins({String? profileName}) =>
      platform.getOrigins(profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteAllData}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteAllData.supported_platforms}
  Future<bool> deleteAllData({String? profileName}) =>
      platform.deleteAllData(profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteOrigin}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteOrigin.supported_platforms}
  Future<bool> deleteOrigin({required String origin, String? profileName}) =>
      platform.deleteOrigin(origin: origin, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingData}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingData.supported_platforms}
  Future<bool> deleteBrowsingData({String? profileName}) =>
      platform.deleteBrowsingData(profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingDataForSite}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingDataForSite.supported_platforms}
  Future<String?> deleteBrowsingDataForSite({
    required String site,
    String? profileName,
  }) =>
      platform.deleteBrowsingDataForSite(site: site, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getQuotaForOrigin}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getQuotaForOrigin.supported_platforms}
  Future<int?> getQuotaForOrigin({
    required String origin,
    String? profileName,
  }) => platform.getQuotaForOrigin(origin: origin, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getUsageForOrigin}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.getUsageForOrigin.supported_platforms}
  Future<int?> getUsageForOrigin({
    required String origin,
    String? profileName,
  }) => platform.getUsageForOrigin(origin: origin, profileName: profileName);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.fetchDataRecords}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.fetchDataRecords.supported_platforms}
  Future<List<WebsiteDataRecord>> fetchDataRecords({
    required Set<WebsiteDataType> dataTypes,
  }) => platform.fetchDataRecords(dataTypes: dataTypes);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.removeDataFor}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.removeDataFor.supported_platforms}
  Future<void> removeDataFor({
    required Set<WebsiteDataType> dataTypes,
    required List<WebsiteDataRecord> dataRecords,
  }) => platform.removeDataFor(dataTypes: dataTypes, dataRecords: dataRecords);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.removeDataModifiedSince}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorageManager.removeDataModifiedSince.supported_platforms}
  Future<void> removeDataModifiedSince({
    required Set<WebsiteDataType> dataTypes,
    required DateTime date,
  }) => platform.removeDataModifiedSince(dataTypes: dataTypes, date: date);
}
