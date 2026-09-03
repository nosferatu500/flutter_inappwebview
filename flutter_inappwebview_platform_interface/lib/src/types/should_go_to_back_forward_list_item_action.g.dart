// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'should_go_to_back_forward_list_item_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.shouldGoToBackForwardListItem] event.
///It represents the policy to pass back to the decision handler.
class ShouldGoToBackForwardListItemAction {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const ShouldGoToBackForwardListItemAction._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory ShouldGoToBackForwardListItemAction._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => ShouldGoToBackForwardListItemAction._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Allow the back/forward navigation to continue.
  static const ALLOW = ShouldGoToBackForwardListItemAction._internal(1, 1);

  ///Cancel the back/forward navigation. The `WebView` stays where it is.
  static const CANCEL = ShouldGoToBackForwardListItemAction._internal(0, 0);

  ///Set of all values of [ShouldGoToBackForwardListItemAction].
  static final Set<ShouldGoToBackForwardListItemAction> values = {
    ShouldGoToBackForwardListItemAction.ALLOW,
    ShouldGoToBackForwardListItemAction.CANCEL,
  };

  ///Gets a possible [ShouldGoToBackForwardListItemAction] instance from [int] value.
  static ShouldGoToBackForwardListItemAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ShouldGoToBackForwardListItemAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ShouldGoToBackForwardListItemAction] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static ShouldGoToBackForwardListItemAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ShouldGoToBackForwardListItemAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return ShouldGoToBackForwardListItemAction.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [ShouldGoToBackForwardListItemAction] instance value with name [name].
  ///
  /// Goes through [ShouldGoToBackForwardListItemAction.values] looking for a value with
  /// name [name], as reported by [ShouldGoToBackForwardListItemAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ShouldGoToBackForwardListItemAction? byName(String? name) {
    if (name != null) {
      try {
        return ShouldGoToBackForwardListItemAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ShouldGoToBackForwardListItemAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ShouldGoToBackForwardListItemAction> asNameMap() =>
      <String, ShouldGoToBackForwardListItemAction>{
        for (final value in ShouldGoToBackForwardListItemAction.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 0:
        return 'CANCEL';
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
