// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attributed_string_text_effect_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the supported proxy types.
class AttributedStringTextEffectStyle {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const AttributedStringTextEffectStyle._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory AttributedStringTextEffectStyle._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => AttributedStringTextEffectStyle._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE = AttributedStringTextEffectStyle._internal(
    'letterpressStyle',
    'letterpressStyle',
  );

  ///Set of all values of [AttributedStringTextEffectStyle].
  static final Set<AttributedStringTextEffectStyle> values = {
    AttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  };

  ///Gets a possible [AttributedStringTextEffectStyle] instance from [String] value.
  static AttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return AttributedStringTextEffectStyle.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AttributedStringTextEffectStyle] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static AttributedStringTextEffectStyle? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return AttributedStringTextEffectStyle.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return AttributedStringTextEffectStyle.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [AttributedStringTextEffectStyle] instance value with name [name].
  ///
  /// Goes through [AttributedStringTextEffectStyle.values] looking for a value with
  /// name [name], as reported by [AttributedStringTextEffectStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AttributedStringTextEffectStyle? byName(String? name) {
    if (name != null) {
      try {
        return AttributedStringTextEffectStyle.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AttributedStringTextEffectStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AttributedStringTextEffectStyle> asNameMap() =>
      <String, AttributedStringTextEffectStyle>{
        for (final value in AttributedStringTextEffectStyle.values)
          value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'letterpressStyle':
        return 'LETTERPRESS_STYLE';
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
