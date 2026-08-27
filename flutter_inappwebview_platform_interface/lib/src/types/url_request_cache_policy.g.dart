// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_request_cache_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants used to specify interaction with the cached responses.
class URLRequestCachePolicy {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const URLRequestCachePolicy._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory URLRequestCachePolicy._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => URLRequestCachePolicy._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Ignore local cache data, and instruct proxies and other intermediates to disregard their caches so far as the protocol allows.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA =
      URLRequestCachePolicy._internal(4, 4);

  ///The URL load should be loaded only from the originating source.
  ///This policy specifies that no existing cache data should be used to satisfy a URL load request.
  ///
  ///**NOTE**: Always use this policy if you are making HTTP or HTTPS byte-range requests.
  static const RELOAD_IGNORING_LOCAL_CACHE_DATA =
      URLRequestCachePolicy._internal(1, 1);

  ///Use cache data if the origin source can validate it; otherwise, load from the origin.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_REVALIDATING_CACHE_DATA = URLRequestCachePolicy._internal(
    5,
    5,
  );

  ///Use existing cache data, regardless or age or expiration date, and fail if no cached data is available.
  ///
  ///If there is no existing data in the cache corresponding to a URL load request,
  ///no attempt is made to load the data from the originating source, and the load is considered to have failed.
  ///This constant specifies a behavior that is similar to an “offline” mode.
  static const RETURN_CACHE_DATA_DONT_LOAD = URLRequestCachePolicy._internal(
    3,
    3,
  );

  ///Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data.
  static const RETURN_CACHE_DATA_ELSE_LOAD = URLRequestCachePolicy._internal(
    2,
    2,
  );

  ///Use the caching logic defined in the protocol implementation, if any, for a particular URL load request.
  ///This is the default policy for URL load requests.
  static const USE_PROTOCOL_CACHE_POLICY = URLRequestCachePolicy._internal(
    0,
    0,
  );

  ///Set of all values of [URLRequestCachePolicy].
  static final Set<URLRequestCachePolicy> values = {
    URLRequestCachePolicy.RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA,
    URLRequestCachePolicy.RELOAD_IGNORING_LOCAL_CACHE_DATA,
    URLRequestCachePolicy.RELOAD_REVALIDATING_CACHE_DATA,
    URLRequestCachePolicy.RETURN_CACHE_DATA_DONT_LOAD,
    URLRequestCachePolicy.RETURN_CACHE_DATA_ELSE_LOAD,
    URLRequestCachePolicy.USE_PROTOCOL_CACHE_POLICY,
  };

  ///Gets a possible [URLRequestCachePolicy] instance from [int] value.
  static URLRequestCachePolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return URLRequestCachePolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [URLRequestCachePolicy] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static URLRequestCachePolicy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return URLRequestCachePolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return URLRequestCachePolicy.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [URLRequestCachePolicy] instance value with name [name].
  ///
  /// Goes through [URLRequestCachePolicy.values] looking for a value with
  /// name [name], as reported by [URLRequestCachePolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static URLRequestCachePolicy? byName(String? name) {
    if (name != null) {
      try {
        return URLRequestCachePolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [URLRequestCachePolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, URLRequestCachePolicy> asNameMap() =>
      <String, URLRequestCachePolicy>{
        for (final value in URLRequestCachePolicy.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4:
        return 'RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA';
      case 1:
        return 'RELOAD_IGNORING_LOCAL_CACHE_DATA';
      case 5:
        return 'RELOAD_REVALIDATING_CACHE_DATA';
      case 3:
        return 'RETURN_CACHE_DATA_DONT_LOAD';
      case 2:
        return 'RETURN_CACHE_DATA_ELSE_LOAD';
      case 0:
        return 'USE_PROTOCOL_CACHE_POLICY';
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
    return name();
  }
}
