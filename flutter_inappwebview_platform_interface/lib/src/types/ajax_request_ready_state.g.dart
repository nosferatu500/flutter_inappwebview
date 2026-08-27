// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajax_request_ready_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [AjaxRequest] class. It represents the state of an [AjaxRequest].
class AjaxRequestReadyState {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const AjaxRequestReadyState._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory AjaxRequestReadyState._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => AjaxRequestReadyState._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///The operation is complete.
  static const DONE = AjaxRequestReadyState._internal(4, 4);

  ///`XMLHttpRequest.send()` has been called, and [AjaxRequest.headers] and [AjaxRequest.status] are available.
  static const HEADERS_RECEIVED = AjaxRequestReadyState._internal(2, 2);

  ///Downloading; [AjaxRequest.responseText] holds partial data.
  static const LOADING = AjaxRequestReadyState._internal(3, 3);

  ///`XMLHttpRequest.open()` has been called.
  static const OPENED = AjaxRequestReadyState._internal(1, 1);

  ///Client has been created. `XMLHttpRequest.open()` not called yet.
  static const UNSENT = AjaxRequestReadyState._internal(0, 0);

  ///Set of all values of [AjaxRequestReadyState].
  static final Set<AjaxRequestReadyState> values = {
    AjaxRequestReadyState.DONE,
    AjaxRequestReadyState.HEADERS_RECEIVED,
    AjaxRequestReadyState.LOADING,
    AjaxRequestReadyState.OPENED,
    AjaxRequestReadyState.UNSENT,
  };

  ///Gets a possible [AjaxRequestReadyState] instance from [int] value.
  static AjaxRequestReadyState? fromValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AjaxRequestReadyState] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static AjaxRequestReadyState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return AjaxRequestReadyState.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [AjaxRequestReadyState] instance value with name [name].
  ///
  /// Goes through [AjaxRequestReadyState.values] looking for a value with
  /// name [name], as reported by [AjaxRequestReadyState.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AjaxRequestReadyState? byName(String? name) {
    if (name != null) {
      try {
        return AjaxRequestReadyState.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AjaxRequestReadyState] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AjaxRequestReadyState> asNameMap() =>
      <String, AjaxRequestReadyState>{
        for (final value in AjaxRequestReadyState.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4:
        return 'DONE';
      case 2:
        return 'HEADERS_RECEIVED';
      case 3:
        return 'LOADING';
      case 1:
        return 'OPENED';
      case 0:
        return 'UNSENT';
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
