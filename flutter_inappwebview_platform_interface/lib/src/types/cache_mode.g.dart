// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to override the way the cache is used.
class CacheMode {
  final int _value;
  final int? _nativeValue;
  const CacheMode._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory CacheMode._internalMultiPlatform(int value, Function nativeValue) =>
      CacheMode._internal(value, nativeValue());

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = CacheMode._internal(1, 1);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = CacheMode._internal(3, 3);

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = CacheMode._internal(-1, -1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = CacheMode._internal(2, 2);

  ///Set of all values of [CacheMode].
  static final Set<CacheMode> values = [
    CacheMode.LOAD_CACHE_ELSE_NETWORK,
    CacheMode.LOAD_CACHE_ONLY,
    CacheMode.LOAD_DEFAULT,
    CacheMode.LOAD_NO_CACHE,
  ].toSet();

  ///Gets a possible [CacheMode] instance from [int] value.
  static CacheMode? fromValue(int? value) {
    if (value != null) {
      try {
        return CacheMode.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CacheMode] instance from a native value.
  static CacheMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CacheMode.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [CacheMode] instance value with name [name].
  ///
  /// Goes through [CacheMode.values] looking for a value with
  /// name [name], as reported by [CacheMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static CacheMode? byName(String? name) {
    if (name != null) {
      try {
        return CacheMode.values.firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [CacheMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, CacheMode> asNameMap() => <String, CacheMode>{
    for (final value in CacheMode.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'LOAD_CACHE_ELSE_NETWORK';
      case 3:
        return 'LOAD_CACHE_ONLY';
      case -1:
        return 'LOAD_DEFAULT';
      case 2:
        return 'LOAD_NO_CACHE';
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
