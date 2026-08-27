// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_confirm_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [JsConfirmResponse] class.
class JsConfirmResponseAction {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const JsConfirmResponseAction._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory JsConfirmResponseAction._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => JsConfirmResponseAction._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Confirm that the user hit cancel button.
  static const CANCEL = JsConfirmResponseAction._internal(1, 1);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsConfirmResponseAction._internal(0, 0);

  ///Set of all values of [JsConfirmResponseAction].
  static final Set<JsConfirmResponseAction> values = {
    JsConfirmResponseAction.CANCEL,
    JsConfirmResponseAction.CONFIRM,
  };

  ///Gets a possible [JsConfirmResponseAction] instance from [int] value.
  static JsConfirmResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return JsConfirmResponseAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [JsConfirmResponseAction] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static JsConfirmResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return JsConfirmResponseAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return JsConfirmResponseAction.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [JsConfirmResponseAction] instance value with name [name].
  ///
  /// Goes through [JsConfirmResponseAction.values] looking for a value with
  /// name [name], as reported by [JsConfirmResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static JsConfirmResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return JsConfirmResponseAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [JsConfirmResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, JsConfirmResponseAction> asNameMap() =>
      <String, JsConfirmResponseAction>{
        for (final value in JsConfirmResponseAction.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'CANCEL';
      case 0:
        return 'CONFIRM';
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
