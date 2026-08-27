// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.onNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
class NavigationResponseAction {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const NavigationResponseAction._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory NavigationResponseAction._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => NavigationResponseAction._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Allow the navigation to continue.
  static const ALLOW = NavigationResponseAction._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = NavigationResponseAction._internal(0, 0);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = NavigationResponseAction._internal(2, 2);

  ///Set of all values of [NavigationResponseAction].
  static final Set<NavigationResponseAction> values = {
    NavigationResponseAction.ALLOW,
    NavigationResponseAction.CANCEL,
    NavigationResponseAction.DOWNLOAD,
  };

  ///Gets a possible [NavigationResponseAction] instance from [int] value.
  static NavigationResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationResponseAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [NavigationResponseAction] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static NavigationResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return NavigationResponseAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return NavigationResponseAction.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [NavigationResponseAction] instance value with name [name].
  ///
  /// Goes through [NavigationResponseAction.values] looking for a value with
  /// name [name], as reported by [NavigationResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static NavigationResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return NavigationResponseAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [NavigationResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, NavigationResponseAction> asNameMap() =>
      <String, NavigationResponseAction>{
        for (final value in NavigationResponseAction.values)
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
      case 2:
        return 'DOWNLOAD';
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
