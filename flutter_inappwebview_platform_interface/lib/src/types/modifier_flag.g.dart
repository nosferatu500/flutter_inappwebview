// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_flag.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a modifier key that was held down during a navigation.
///
///Modelled as a set rather than a single value because the native type,
///`UIKeyModifierFlags`, is a bit mask: more than one modifier can be held at once,
///so a navigation may report `[COMMAND, SHIFT]`.
class ModifierFlag {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const ModifierFlag._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory ModifierFlag._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => ModifierFlag._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///The Caps Lock key. Corresponds to `UIKeyModifierAlphaShift` (`1 << 16`).
  static const ALPHA_SHIFT = ModifierFlag._internal(
    'ALPHA_SHIFT',
    'ALPHA_SHIFT',
  );

  ///The Option/Alt key. Corresponds to `UIKeyModifierAlternate` (`1 << 19`).
  static const ALTERNATE = ModifierFlag._internal('ALTERNATE', 'ALTERNATE');

  ///The Command key. Corresponds to `UIKeyModifierCommand` (`1 << 20`).
  static const COMMAND = ModifierFlag._internal('COMMAND', 'COMMAND');

  ///The Control key. Corresponds to `UIKeyModifierControl` (`1 << 18`).
  static const CONTROL = ModifierFlag._internal('CONTROL', 'CONTROL');

  ///A key on the numeric keypad. Corresponds to `UIKeyModifierNumericPad` (`1 << 21`).
  static const NUMERIC_PAD = ModifierFlag._internal(
    'NUMERIC_PAD',
    'NUMERIC_PAD',
  );

  ///The Shift key. Corresponds to `UIKeyModifierShift` (`1 << 17`).
  static const SHIFT = ModifierFlag._internal('SHIFT', 'SHIFT');

  ///Set of all values of [ModifierFlag].
  static final Set<ModifierFlag> values = {
    ModifierFlag.ALPHA_SHIFT,
    ModifierFlag.ALTERNATE,
    ModifierFlag.COMMAND,
    ModifierFlag.CONTROL,
    ModifierFlag.NUMERIC_PAD,
    ModifierFlag.SHIFT,
  };

  ///Gets a possible [ModifierFlag] instance from [String] value.
  static ModifierFlag? fromValue(String? value) {
    if (value != null) {
      try {
        return ModifierFlag.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ModifierFlag] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static ModifierFlag? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ModifierFlag.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return ModifierFlag.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [ModifierFlag] instance value with name [name].
  ///
  /// Goes through [ModifierFlag.values] looking for a value with
  /// name [name], as reported by [ModifierFlag.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ModifierFlag? byName(String? name) {
    if (name != null) {
      try {
        return ModifierFlag.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ModifierFlag] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ModifierFlag> asNameMap() => <String, ModifierFlag>{
    for (final value in ModifierFlag.values) value.name(): value,
  };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'ALPHA_SHIFT':
        return 'ALPHA_SHIFT';
      case 'ALTERNATE':
        return 'ALTERNATE';
      case 'COMMAND':
        return 'COMMAND';
      case 'CONTROL':
        return 'CONTROL';
      case 'NUMERIC_PAD':
        return 'NUMERIC_PAD';
      case 'SHIFT':
        return 'SHIFT';
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
