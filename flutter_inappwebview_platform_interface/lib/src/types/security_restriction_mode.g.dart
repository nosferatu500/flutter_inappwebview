// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_restriction_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to specify how much additional security hardening a WebView applies to a navigation.
///
///Intended for high-risk browsing contexts — content whose origin you do not control.
class SecurityRestrictionMode {
  final int _value;
  final int? _nativeValue;
  const SecurityRestrictionMode._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory SecurityRestrictionMode._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => SecurityRestrictionMode._internal(value, nativeValue());

  ///Maximum security restrictions, including feature disablement.
  ///
  ///This is the mode the system applies by itself when the device is in Lockdown Mode. Setting it
  ///explicitly opts a single WebView into the same restrictions, which do disable web features and
  ///so may break pages.
  static const LOCKDOWN = SecurityRestrictionMode._internal(2, 2);

  ///Enhanced security protections optimized for maintaining web compatibility.
  ///
  ///Concretely: JavaScript JIT compilation is disabled (interpreter-only execution) and Memory
  ///Tagging Extension coverage is increased across allocations in the WebContent process. Full web
  ///compatibility is retained, so the trade-off is JavaScript performance rather than functionality.
  static const MAXIMIZE_COMPATIBILITY = SecurityRestrictionMode._internal(1, 1);

  ///No additional security restrictions beyond the WebKit defaults.
  ///
  ///This is the default.
  static const NONE = SecurityRestrictionMode._internal(0, 0);

  ///Set of all values of [SecurityRestrictionMode].
  static final Set<SecurityRestrictionMode> values = {
    SecurityRestrictionMode.LOCKDOWN,
    SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY,
    SecurityRestrictionMode.NONE,
  };

  ///Gets a possible [SecurityRestrictionMode] instance from [int] value.
  static SecurityRestrictionMode? fromValue(int? value) {
    if (value != null) {
      try {
        return SecurityRestrictionMode.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SecurityRestrictionMode] instance from a native value.
  static SecurityRestrictionMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SecurityRestrictionMode.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [SecurityRestrictionMode] instance value with name [name].
  ///
  /// Goes through [SecurityRestrictionMode.values] looking for a value with
  /// name [name], as reported by [SecurityRestrictionMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static SecurityRestrictionMode? byName(String? name) {
    if (name != null) {
      try {
        return SecurityRestrictionMode.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [SecurityRestrictionMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, SecurityRestrictionMode> asNameMap() =>
      <String, SecurityRestrictionMode>{
        for (final value in SecurityRestrictionMode.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'LOCKDOWN';
      case 1:
        return 'MAXIMIZE_COMPATIBILITY';
      case 0:
        return 'NONE';
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
