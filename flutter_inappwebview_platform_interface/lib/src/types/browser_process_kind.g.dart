// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Indicates the process type used in the [BrowserProcessInfo] interface.
class BrowserProcessKind {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const BrowserProcessKind._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory BrowserProcessKind._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => BrowserProcessKind._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Set of all values of [BrowserProcessKind].
  static final Set<BrowserProcessKind> values = {};

  ///Gets a possible [BrowserProcessKind] instance from [int] value.
  static BrowserProcessKind? fromValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessKind.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return BrowserProcessKind._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [BrowserProcessKind] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static BrowserProcessKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return BrowserProcessKind.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return BrowserProcessKind.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [BrowserProcessKind] instance value with name [name].
  ///
  /// Goes through [BrowserProcessKind.values] looking for a value with
  /// name [name], as reported by [BrowserProcessKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static BrowserProcessKind? byName(String? name) {
    if (name != null) {
      try {
        return BrowserProcessKind.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [BrowserProcessKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, BrowserProcessKind> asNameMap() =>
      <String, BrowserProcessKind>{
        for (final value in BrowserProcessKind.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {}
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  BrowserProcessKind operator |(BrowserProcessKind value) =>
      BrowserProcessKind._internal(
        value.toValue() | _value,
        value.toNativeValue() != null && _nativeValue != null
            ? value.toNativeValue()! | _nativeValue!
            : null,
      );

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
