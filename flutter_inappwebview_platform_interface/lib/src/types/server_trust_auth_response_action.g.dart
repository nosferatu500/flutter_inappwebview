// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_auth_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [ServerTrustAuthResponse] class.
class ServerTrustAuthResponseAction {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const ServerTrustAuthResponseAction._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory ServerTrustAuthResponseAction._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => ServerTrustAuthResponseAction._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = ServerTrustAuthResponseAction._internal(0, 0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = ServerTrustAuthResponseAction._internal(1, 1);

  ///Set of all values of [ServerTrustAuthResponseAction].
  static final Set<ServerTrustAuthResponseAction> values = {
    ServerTrustAuthResponseAction.CANCEL,
    ServerTrustAuthResponseAction.PROCEED,
  };

  ///Gets a possible [ServerTrustAuthResponseAction] instance from [int] value.
  static ServerTrustAuthResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ServerTrustAuthResponseAction] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static ServerTrustAuthResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return ServerTrustAuthResponseAction.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [ServerTrustAuthResponseAction] instance value with name [name].
  ///
  /// Goes through [ServerTrustAuthResponseAction.values] looking for a value with
  /// name [name], as reported by [ServerTrustAuthResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ServerTrustAuthResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return ServerTrustAuthResponseAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ServerTrustAuthResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ServerTrustAuthResponseAction> asNameMap() =>
      <String, ServerTrustAuthResponseAction>{
        for (final value in ServerTrustAuthResponseAction.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'CANCEL';
      case 1:
        return 'PROCEED';
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
