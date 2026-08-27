// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_in_display_cutout_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the share state that should be applied to the custom tab.
class LayoutInDisplayCutoutMode {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const LayoutInDisplayCutoutMode._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory LayoutInDisplayCutoutMode._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => LayoutInDisplayCutoutMode._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = LayoutInDisplayCutoutMode._internal(3, 3);

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = LayoutInDisplayCutoutMode._internal(0, 0);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = LayoutInDisplayCutoutMode._internal(2, 2);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = LayoutInDisplayCutoutMode._internal(1, 1);

  ///Set of all values of [LayoutInDisplayCutoutMode].
  static final Set<LayoutInDisplayCutoutMode> values = {
    LayoutInDisplayCutoutMode.ALWAYS,
    LayoutInDisplayCutoutMode.DEFAULT,
    LayoutInDisplayCutoutMode.NEVER,
    LayoutInDisplayCutoutMode.SHORT_EDGES,
  };

  ///Gets a possible [LayoutInDisplayCutoutMode] instance from [int] value.
  static LayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return LayoutInDisplayCutoutMode.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [LayoutInDisplayCutoutMode] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static LayoutInDisplayCutoutMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return LayoutInDisplayCutoutMode.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return LayoutInDisplayCutoutMode.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [LayoutInDisplayCutoutMode] instance value with name [name].
  ///
  /// Goes through [LayoutInDisplayCutoutMode.values] looking for a value with
  /// name [name], as reported by [LayoutInDisplayCutoutMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static LayoutInDisplayCutoutMode? byName(String? name) {
    if (name != null) {
      try {
        return LayoutInDisplayCutoutMode.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [LayoutInDisplayCutoutMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, LayoutInDisplayCutoutMode> asNameMap() =>
      <String, LayoutInDisplayCutoutMode>{
        for (final value in LayoutInDisplayCutoutMode.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'ALWAYS';
      case 0:
        return 'DEFAULT';
      case 2:
        return 'NEVER';
      case 1:
        return 'SHORT_EDGES';
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
