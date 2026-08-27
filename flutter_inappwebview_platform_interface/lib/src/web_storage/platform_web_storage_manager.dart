import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/main.dart';

part 'platform_web_storage_manager.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManagerCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebStorageManager].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManagerCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(available: '9.0'),
  ],
)
@immutable
class PlatformWebStorageManagerCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebStorageManager].
  const PlatformWebStorageManagerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManagerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebStorageManagerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager}
///Class that implements a singleton object (shared instance) which manages the web storage used by WebView instances.
///
///Every method here operates on the default profile's storage unless a `profileName` is given. On
///Android, passing one scopes that single call to the web storage of that browsing profile
///instead — the same profile a WebView is put on with [InAppWebViewSettings.profileName]. Storage
///is not shared between profiles, so a WebView running on a non-default profile is *not* affected
///by calls that omit `profileName`.
///
///Scoping is per call rather than per instance, matching [PlatformCookieManager]. The trade-off is
///that omitting it silently falls back to the default profile rather than failing, so a caller
///working with profiles has to pass it every time.
///
///`profileName` requires [WebViewFeature.MULTI_PROFILE]. Without that feature, or when no profile
///of that name exists, nothing is read or deleted and the call reports failure — it never falls
///back to the default profile. Use [PlatformProfileStore] to create profiles.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'WebStorage',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/WebStorage.html',
    ),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore',
      available: '9.0',
    ),
  ],
)
abstract class PlatformWebStorageManager extends PlatformInterface {
  /// Creates a new [PlatformWebStorageManager]
  factory PlatformWebStorageManager(
    PlatformWebStorageManagerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebStorageManager webStorageManager = InAppWebViewPlatform
        .instance!
        .createPlatformWebStorageManager(params);
    PlatformInterface.verify(webStorageManager, _token);
    return webStorageManager;
  }

  /// Creates a new [PlatformWebStorageManager] to access static methods.
  factory PlatformWebStorageManager.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebStorageManager webStorageManagerStatic =
        InAppWebViewPlatform.instance!.createPlatformWebStorageManagerStatic();
    PlatformInterface.verify(webStorageManagerStatic, _token);
    return webStorageManagerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformWebStorageManager].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebStorageManager.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebStorageManager].
  final PlatformWebStorageManagerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getOrigins}
  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.getOrigins.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorage.getOrigins',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebStorage#getOrigins(android.webkit.ValueCallback%3Cjava.util.Map%3E)',
      ),
    ],
  )
  Future<List<WebStorageOrigin>> getOrigins({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getOrigins is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteAllData}
  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteAllData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorage.deleteAllData',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebStorage#deleteAllData()',
      ),
    ],
  )
  Future<void> deleteAllData({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteAllData is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteOrigin}
  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteOrigin.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorage.deleteOrigin',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebStorage#deleteOrigin(java.lang.String)',
      ),
    ],
  )
  Future<void> deleteOrigin({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteOrigin is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingData}
  ///Deletes all the data stored by websites.
  ///
  ///This is stronger than [deleteAllData]: on top of the JavaScript-readable storage APIs it also
  ///clears the network cache and the cookies.
  ///
  ///Only data stored *before* the call is guaranteed to go. Deletion is not atomic, so data written
  ///while it runs may or may not survive.
  ///
  ///The data cleared is the one belonging to the default WebView profile, which is the only profile
  ///this plugin uses. An app managing its own profiles has to clear each of them separately.
  ///
  ///Returns `true` once the deletion has completed, or `false` immediately when
  ///[WebViewFeature.DELETE_BROWSING_DATA] is not supported, in which case nothing was deleted.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingData.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorageCompat.deleteBrowsingData',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebStorageCompat#deleteBrowsingData(android.webkit.WebStorage,java.lang.Runnable)',
        note:
            'Requires [WebViewFeature.DELETE_BROWSING_DATA]. Returns `false` and deletes nothing if the feature is not supported.',
      ),
    ],
  )
  Future<bool> deleteBrowsingData({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteBrowsingData is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingDataForSite}
  ///Deletes the data stored by websites for the given [site].
  ///
  ///[site] can be a domain name or a full URL. Deletion happens at the
  ///[site](https://developer.mozilla.org/en-US/docs/Glossary/Site) level rather than for the exact
  ///host, so a [site] of `www.example.com` deletes everything belonging to `example.com`.
  ///Partitioned storage owned by the site goes too, including the storage of content the site
  ///embeds in iframes.
  ///
  ///As with [deleteBrowsingData] this covers the network cache and the cookies as well as the
  ///JavaScript-readable storage APIs, and only data stored before the call is guaranteed to go.
  ///
  ///Returns the domain the deletion was actually performed for — the top-level domain part of
  ///[site], so it can differ from what was passed in — or `null` when
  ///[WebViewFeature.DELETE_BROWSING_DATA] is not supported, in which case nothing was deleted.
  ///
  ///Throws a `PlatformException` if [site] cannot be parsed as a domain name.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.deleteBrowsingDataForSite.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorageCompat.deleteBrowsingDataForSite',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebStorageCompat#deleteBrowsingDataForSite(android.webkit.WebStorage,java.lang.String,java.lang.Runnable)',
        note:
            'Requires [WebViewFeature.DELETE_BROWSING_DATA]. Returns `null` and deletes nothing if the feature is not supported.',
      ),
    ],
  )
  Future<String?> deleteBrowsingDataForSite({
    required String site,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteBrowsingDataForSite is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getQuotaForOrigin}
  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.getQuotaForOrigin.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorage.getQuotaForOrigin',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebStorage#getQuotaForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)',
      ),
    ],
  )
  Future<int> getQuotaForOrigin({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getQuotaForOrigin is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.getUsageForOrigin}
  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.getUsageForOrigin.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebStorage.getUsageForOrigin',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/WebStorage#getUsageForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)',
      ),
    ],
  )
  Future<int> getUsageForOrigin({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getUsageForOrigin is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.fetchDataRecords}
  ///Fetches data records containing the given website data types.
  ///
  ///[dataTypes] represents the website data types to fetch records for.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.fetchDataRecords.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: '9.0',
        apiName: 'WKWebsiteDataStore.fetchDataRecords',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords',
      ),
    ],
  )
  Future<List<WebsiteDataRecord>> fetchDataRecords({
    required Set<WebsiteDataType> dataTypes,
  }) {
    throw UnimplementedError(
      'fetchDataRecords is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataFor}
  ///Removes website data of the given types for the given data records.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[dataRecords] represents the website data records to delete website data for.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataFor.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: '9.0',
        apiName: 'WKWebsiteDataStore.removeData',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata',
      ),
    ],
  )
  Future<void> removeDataFor({
    required Set<WebsiteDataType> dataTypes,
    required List<WebsiteDataRecord> dataRecords,
  }) {
    throw UnimplementedError(
      'removeDataFor is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataModifiedSince}
  ///Removes all website data of the given types that has been modified since the given date.
  ///
  ///[dataTypes] represents the website data types that should be removed.
  ///
  ///[date] represents a date. All website data modified after this date will be removed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageManager.removeDataModifiedSince.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: '9.0',
        apiName: 'WKWebsiteDataStore.removeData',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
      ),
    ],
  )
  Future<void> removeDataModifiedSince({
    required Set<WebsiteDataType> dataTypes,
    required DateTime date,
  }) {
    throw UnimplementedError(
      'removeDataModifiedSince is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebStorageManagerClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageManager.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebStorageManagerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebStorageManagerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
