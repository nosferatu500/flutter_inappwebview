// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_data_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a website data type.
class WebsiteDataType {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const WebsiteDataType._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory WebsiteDataType._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => WebsiteDataType._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///Returns a set of all available website data types.
  ///
  ///This is the set to pass to [PlatformWebStorageManager.removeDataFor] or
  ///[PlatformWebStorageManager.removeDataModifiedSince] to clear everything WebKit stores for a
  ///site. It deliberately includes types that only exist on newer iOS versions: WebKit ignores a
  ///data type it does not recognise, so passing the whole set is safe on every supported version
  ///and is what makes a wipe complete as the OS gains storage kinds.
  static final ALL = {
    WebsiteDataType.WKWebsiteDataTypeFetchCache,
    WebsiteDataType.WKWebsiteDataTypeDiskCache,
    WebsiteDataType.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType.WKWebsiteDataTypeCookies,
    WebsiteDataType.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
    WebsiteDataType.WKWebsiteDataTypeFileSystem,
    WebsiteDataType.WKWebsiteDataTypeSearchFieldRecentSearches,
    WebsiteDataType.WKWebsiteDataTypeMediaKeys,
    WebsiteDataType.WKWebsiteDataTypeHashSalt,
  };

  ///Cookies.
  static const WKWebsiteDataTypeCookies = WebsiteDataType._internal(
    'WKWebsiteDataTypeCookies',
    'WKWebsiteDataTypeCookies',
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeDiskCache',
    'WKWebsiteDataTypeDiskCache',
  );

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeFetchCache',
    'WKWebsiteDataTypeFetchCache',
  );

  ///File system storage — the origin-private file system (OPFS).
  ///
  ///**NOTE**: available on iOS 16.0+.
  static const WKWebsiteDataTypeFileSystem = WebsiteDataType._internal(
    'WKWebsiteDataTypeFileSystem',
    'WKWebsiteDataTypeFileSystem',
  );

  ///Hash salt used to derive the `deviceId` exposed to a site.
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeHashSalt = WebsiteDataType._internal(
    'WKWebsiteDataTypeHashSalt',
    'WKWebsiteDataTypeHashSalt',
  );

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases = WebsiteDataType._internal(
    'WKWebsiteDataTypeIndexedDBDatabases',
    'WKWebsiteDataTypeIndexedDBDatabases',
  );

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = WebsiteDataType._internal(
    'WKWebsiteDataTypeLocalStorage',
    'WKWebsiteDataTypeLocalStorage',
  );

  ///MediaKeys storage, used by Encrypted Media Extensions (DRM).
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeMediaKeys = WebsiteDataType._internal(
    'WKWebsiteDataTypeMediaKeys',
    'WKWebsiteDataTypeMediaKeys',
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = WebsiteDataType._internal(
    'WKWebsiteDataTypeMemoryCache',
    'WKWebsiteDataTypeMemoryCache',
  );

  ///HTML offline web application caches.
  ///
  ///**NOTE**: WebKit deprecated this in iOS 26.2 — Application Cache is no longer supported, so on
  ///those versions it matches no data. It is kept because it is still accepted, and removing it
  ///would break code that passes it explicitly.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      WebsiteDataType._internal(
        'WKWebsiteDataTypeOfflineWebApplicationCache',
        'WKWebsiteDataTypeOfflineWebApplicationCache',
      );

  ///Screen Time information.
  ///
  ///**NOTE**: available on iOS 26.0+.
  static const WKWebsiteDataTypeScreenTime = WebsiteDataType._internal(
    'WKWebsiteDataTypeScreenTime',
    'WKWebsiteDataTypeScreenTime',
  );

  ///Search field history.
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeSearchFieldRecentSearches =
      WebsiteDataType._internal(
        'WKWebsiteDataTypeSearchFieldRecentSearches',
        'WKWebsiteDataTypeSearchFieldRecentSearches',
      );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      WebsiteDataType._internal(
        'WKWebsiteDataTypeServiceWorkerRegistrations',
        'WKWebsiteDataTypeServiceWorkerRegistrations',
      );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage = WebsiteDataType._internal(
    'WKWebsiteDataTypeSessionStorage',
    'WKWebsiteDataTypeSessionStorage',
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases = WebsiteDataType._internal(
    'WKWebsiteDataTypeWebSQLDatabases',
    'WKWebsiteDataTypeWebSQLDatabases',
  );

  ///Set of all values of [WebsiteDataType].
  static final Set<WebsiteDataType> values = {
    WebsiteDataType.WKWebsiteDataTypeCookies,
    WebsiteDataType.WKWebsiteDataTypeDiskCache,
    WebsiteDataType.WKWebsiteDataTypeFetchCache,
    WebsiteDataType.WKWebsiteDataTypeFileSystem,
    WebsiteDataType.WKWebsiteDataTypeHashSalt,
    WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType.WKWebsiteDataTypeMediaKeys,
    WebsiteDataType.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType.WKWebsiteDataTypeScreenTime,
    WebsiteDataType.WKWebsiteDataTypeSearchFieldRecentSearches,
    WebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
    WebsiteDataType.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
  };

  ///Gets a possible [WebsiteDataType] instance from [String] value.
  static WebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebsiteDataType] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static WebsiteDataType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return WebsiteDataType.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [WebsiteDataType] instance value with name [name].
  ///
  /// Goes through [WebsiteDataType.values] looking for a value with
  /// name [name], as reported by [WebsiteDataType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebsiteDataType? byName(String? name) {
    if (name != null) {
      try {
        return WebsiteDataType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebsiteDataType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebsiteDataType> asNameMap() => <String, WebsiteDataType>{
    for (final value in WebsiteDataType.values) value.name(): value,
  };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'WKWebsiteDataTypeCookies':
        return 'WKWebsiteDataTypeCookies';
      case 'WKWebsiteDataTypeDiskCache':
        return 'WKWebsiteDataTypeDiskCache';
      case 'WKWebsiteDataTypeFetchCache':
        return 'WKWebsiteDataTypeFetchCache';
      case 'WKWebsiteDataTypeFileSystem':
        return 'WKWebsiteDataTypeFileSystem';
      case 'WKWebsiteDataTypeHashSalt':
        return 'WKWebsiteDataTypeHashSalt';
      case 'WKWebsiteDataTypeIndexedDBDatabases':
        return 'WKWebsiteDataTypeIndexedDBDatabases';
      case 'WKWebsiteDataTypeLocalStorage':
        return 'WKWebsiteDataTypeLocalStorage';
      case 'WKWebsiteDataTypeMediaKeys':
        return 'WKWebsiteDataTypeMediaKeys';
      case 'WKWebsiteDataTypeMemoryCache':
        return 'WKWebsiteDataTypeMemoryCache';
      case 'WKWebsiteDataTypeOfflineWebApplicationCache':
        return 'WKWebsiteDataTypeOfflineWebApplicationCache';
      case 'WKWebsiteDataTypeScreenTime':
        return 'WKWebsiteDataTypeScreenTime';
      case 'WKWebsiteDataTypeSearchFieldRecentSearches':
        return 'WKWebsiteDataTypeSearchFieldRecentSearches';
      case 'WKWebsiteDataTypeServiceWorkerRegistrations':
        return 'WKWebsiteDataTypeServiceWorkerRegistrations';
      case 'WKWebsiteDataTypeSessionStorage':
        return 'WKWebsiteDataTypeSessionStorage';
      case 'WKWebsiteDataTypeWebSQLDatabases':
        return 'WKWebsiteDataTypeWebSQLDatabases';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}
