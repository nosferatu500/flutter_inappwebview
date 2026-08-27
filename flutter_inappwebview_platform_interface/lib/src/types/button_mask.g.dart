// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button_mask.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a pointing-device button that was pressed during a navigation.
///
///The native type is `UIEventButtonMask`, a bit mask defined as `1 << (buttonNumber - 1)`,
///**not** a button index. That matters because the WebKit property it comes from is called
///`buttonNumber`: a caller who reads the raw native value as a number gets `1` for the primary
///button and `2` for the secondary one — which looks like a one-based index but is not, since a
///third button would report `4`. Exposing it as a set of named buttons removes the ambiguity.
class ButtonMask {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const ButtonMask._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory ButtonMask._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => ButtonMask._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///The primary button, normally a left click or a single-finger tap.
  ///Corresponds to `UIEventButtonMaskPrimary` (`1 << 0`).
  static const PRIMARY = ButtonMask._internal('PRIMARY', 'PRIMARY');

  ///The secondary button, normally a right click.
  ///Corresponds to `UIEventButtonMaskSecondary` (`1 << 1`).
  static const SECONDARY = ButtonMask._internal('SECONDARY', 'SECONDARY');

  ///Set of all values of [ButtonMask].
  static final Set<ButtonMask> values = {
    ButtonMask.PRIMARY,
    ButtonMask.SECONDARY,
  };

  ///Gets a possible [ButtonMask] instance from [String] value.
  static ButtonMask? fromValue(String? value) {
    if (value != null) {
      try {
        return ButtonMask.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ButtonMask] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static ButtonMask? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ButtonMask.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return ButtonMask.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [ButtonMask] instance value with name [name].
  ///
  /// Goes through [ButtonMask.values] looking for a value with
  /// name [name], as reported by [ButtonMask.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ButtonMask? byName(String? name) {
    if (name != null) {
      try {
        return ButtonMask.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ButtonMask] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ButtonMask> asNameMap() => <String, ButtonMask>{
    for (final value in ButtonMask.values) value.name(): value,
  };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'PRIMARY':
        return 'PRIMARY';
      case 'SECONDARY':
        return 'SECONDARY';
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
