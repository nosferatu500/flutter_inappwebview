import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'website_data_type.g.dart';

///Class that represents a website data type.
@ExchangeableEnum()
class WebsiteDataType_ {
  // ignore: unused_field
  final String _value;
  const WebsiteDataType_._internal(this._value);

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeFetchCache",
  );

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeDiskCache",
  );

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache = WebsiteDataType_._internal(
    "WKWebsiteDataTypeMemoryCache",
  );

  ///HTML offline web application caches.
  ///
  ///**NOTE**: WebKit deprecated this in iOS 26.2 — Application Cache is no longer supported, so on
  ///those versions it matches no data. It is kept because it is still accepted, and removing it
  ///would break code that passes it explicitly.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      WebsiteDataType_._internal("WKWebsiteDataTypeOfflineWebApplicationCache");

  ///File system storage — the origin-private file system (OPFS).
  ///
  ///**NOTE**: available on iOS 16.0+.
  static const WKWebsiteDataTypeFileSystem = WebsiteDataType_._internal(
    "WKWebsiteDataTypeFileSystem",
  );

  ///Search field history.
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeSearchFieldRecentSearches =
      WebsiteDataType_._internal("WKWebsiteDataTypeSearchFieldRecentSearches");

  ///MediaKeys storage, used by Encrypted Media Extensions (DRM).
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeMediaKeys = WebsiteDataType_._internal(
    "WKWebsiteDataTypeMediaKeys",
  );

  ///Hash salt used to derive the `deviceId` exposed to a site.
  ///
  ///**NOTE**: available on iOS 17.0+.
  static const WKWebsiteDataTypeHashSalt = WebsiteDataType_._internal(
    "WKWebsiteDataTypeHashSalt",
  );

  ///Screen Time information.
  ///
  ///**NOTE**: available on iOS 26.0+.
  ///
  ///**WARNING — deliberately excluded from [ALL], and do not pass it to
  ///[PlatformWebStorageManager.removeDataModifiedSince].** On iOS 26.5 that call **terminates the
  ///app** with an uncaught `NSGenericException`: WebKit's
  ///`ScreenTimeWebsiteDataSupport::removeScreenTimeDataWithInterval` builds an `NSDateInterval`
  ///from the `modifiedSince` value and throws *"Start date cannot be later in time than end
  ///date!"*. It is an uncaught Objective-C exception raised inside WebKit, so there is nothing
  ///Dart can catch and nothing the plugin can guard. Measured on iOS 26.5; removing this constant
  ///from the set makes the same call succeed.
  ///
  ///[PlatformWebStorageManager.fetchDataRecords] with this type is fine — only the
  ///`modifiedSince` deletion path crashes.
  static const WKWebsiteDataTypeScreenTime = WebsiteDataType_._internal(
    "WKWebsiteDataTypeScreenTime",
  );

  ///Cookies.
  static const WKWebsiteDataTypeCookies = WebsiteDataType_._internal(
    "WKWebsiteDataTypeCookies",
  );

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage = WebsiteDataType_._internal(
    "WKWebsiteDataTypeSessionStorage",
  );

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage = WebsiteDataType_._internal(
    "WKWebsiteDataTypeLocalStorage",
  );

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases = WebsiteDataType_._internal(
    "WKWebsiteDataTypeWebSQLDatabases",
  );

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases = WebsiteDataType_._internal(
    "WKWebsiteDataTypeIndexedDBDatabases",
  );

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      WebsiteDataType_._internal("WKWebsiteDataTypeServiceWorkerRegistrations");

  ///Returns a set of all available website data types.
  ///
  ///This is the set to pass to [PlatformWebStorageManager.removeDataFor] or
  ///[PlatformWebStorageManager.removeDataModifiedSince] to clear everything WebKit stores for a
  ///site.
  ///
  ///It deliberately includes types that only exist on newer iOS versions — measured on iOS 17.5,
  ///where four of them are unknown to the framework: WebKit ignores a data type it does not
  ///recognise, so passing the whole set is safe on every supported version and keeps a wipe
  ///complete as the OS gains storage kinds.
  ///
  ///**[WKWebsiteDataTypeScreenTime] is deliberately NOT in this set**, even though it is a valid
  ///data type on iOS 26+: passing it to `removeDataModifiedSince` terminates the app from inside
  ///WebKit. See that constant for the measurement. Add it yourself only if you know you need it
  ///and are not using the `modifiedSince` deletion path.
  @ExchangeableEnumCustomValue()
  // ignore: non_constant_identifier_names
  static final Set<WebsiteDataType_> ALL = {
    WebsiteDataType_.WKWebsiteDataTypeFetchCache,
    WebsiteDataType_.WKWebsiteDataTypeDiskCache,
    WebsiteDataType_.WKWebsiteDataTypeMemoryCache,
    WebsiteDataType_.WKWebsiteDataTypeOfflineWebApplicationCache,
    WebsiteDataType_.WKWebsiteDataTypeCookies,
    WebsiteDataType_.WKWebsiteDataTypeSessionStorage,
    WebsiteDataType_.WKWebsiteDataTypeLocalStorage,
    WebsiteDataType_.WKWebsiteDataTypeWebSQLDatabases,
    WebsiteDataType_.WKWebsiteDataTypeIndexedDBDatabases,
    WebsiteDataType_.WKWebsiteDataTypeServiceWorkerRegistrations,
    WebsiteDataType_.WKWebsiteDataTypeFileSystem,
    WebsiteDataType_.WKWebsiteDataTypeSearchFieldRecentSearches,
    WebsiteDataType_.WKWebsiteDataTypeMediaKeys,
    WebsiteDataType_.WKWebsiteDataTypeHashSalt,
  };
}
