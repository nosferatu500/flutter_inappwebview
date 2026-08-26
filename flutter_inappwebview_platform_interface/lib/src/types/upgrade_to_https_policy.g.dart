// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_to_https_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate whether a top-level navigation should prefer HTTPS,
///and how a failure to upgrade should be handled.
class UpgradeToHTTPSPolicy {
  final int _value;
  final int? _nativeValue;
  const UpgradeToHTTPSPolicy._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory UpgradeToHTTPSPolicy._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => UpgradeToHTTPSPolicy._internal(value, nativeValue());

  ///Upgrades HTTP requests to HTTPS, and silently re-attempts the request with HTTP on failure.
  ///
  ///The most permissive of the upgrading modes: a site that cannot serve HTTPS still loads.
  static const AUTOMATIC_FALLBACK_TO_HTTP = UpgradeToHTTPSPolicy._internal(
    1,
    1,
  );

  ///Upgrades HTTP requests to HTTPS, and fails with an error if HTTPS is not available.
  ///
  ///The strictest mode — the HTTPS-Only equivalent. There is no HTTP fallback at all.
  static const ERROR_ON_FAILURE = UpgradeToHTTPSPolicy._internal(3, 3);

  ///Maintains the current behaviour without preferring HTTPS.
  ///
  ///This is the default.
  static const KEEP_AS_REQUESTED = UpgradeToHTTPSPolicy._internal(0, 0);

  ///Upgrades HTTP requests to HTTPS, and shows a warning page on failure,
  ///letting the user decide whether to continue over HTTP.
  static const USER_MEDIATED_FALLBACK_TO_HTTP = UpgradeToHTTPSPolicy._internal(
    2,
    2,
  );

  ///Set of all values of [UpgradeToHTTPSPolicy].
  static final Set<UpgradeToHTTPSPolicy> values = {
    UpgradeToHTTPSPolicy.AUTOMATIC_FALLBACK_TO_HTTP,
    UpgradeToHTTPSPolicy.ERROR_ON_FAILURE,
    UpgradeToHTTPSPolicy.KEEP_AS_REQUESTED,
    UpgradeToHTTPSPolicy.USER_MEDIATED_FALLBACK_TO_HTTP,
  };

  ///Gets a possible [UpgradeToHTTPSPolicy] instance from [int] value.
  static UpgradeToHTTPSPolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return UpgradeToHTTPSPolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UpgradeToHTTPSPolicy] instance from a native value.
  static UpgradeToHTTPSPolicy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return UpgradeToHTTPSPolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [UpgradeToHTTPSPolicy] instance value with name [name].
  ///
  /// Goes through [UpgradeToHTTPSPolicy.values] looking for a value with
  /// name [name], as reported by [UpgradeToHTTPSPolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static UpgradeToHTTPSPolicy? byName(String? name) {
    if (name != null) {
      try {
        return UpgradeToHTTPSPolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [UpgradeToHTTPSPolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, UpgradeToHTTPSPolicy> asNameMap() =>
      <String, UpgradeToHTTPSPolicy>{
        for (final value in UpgradeToHTTPSPolicy.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'AUTOMATIC_FALLBACK_TO_HTTP';
      case 3:
        return 'ERROR_ON_FAILURE';
      case 0:
        return 'KEEP_AS_REQUESTED';
      case 2:
        return 'USER_MEDIATED_FALLBACK_TO_HTTP';
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
