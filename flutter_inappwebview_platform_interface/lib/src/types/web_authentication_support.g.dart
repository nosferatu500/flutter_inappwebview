// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authentication_support.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to configure the level of [Web Authentication API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)
///support a WebView provides, i.e. whether web content may use passkeys.
///
///Used by [InAppWebViewSettings.webAuthenticationSupport].
class WebAuthenticationSupport {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const WebAuthenticationSupport._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory WebAuthenticationSupport._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => WebAuthenticationSupport._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///The WebView supports the Web Authentication API for the app that embeds it.
  ///
  ///Credentials are scoped to the embedding app, so a passkey created here is not shared with the
  ///user's browser. Use this for an app that signs users in to its own service.
  static const FOR_APP = WebAuthenticationSupport._internal(1, 1);

  ///The WebView supports the Web Authentication API at browser level.
  ///
  ///Intended for apps that are themselves a browser: credentials behave as they would in one,
  ///rather than being scoped to the embedding app. Requires the app to be the registered default
  ///browser or otherwise privileged; see the Android documentation before using it.
  static const FOR_BROWSER = WebAuthenticationSupport._internal(2, 2);

  ///The WebView does not support the Web Authentication API. This is the default.
  static const NONE = WebAuthenticationSupport._internal(0, 0);

  ///Set of all values of [WebAuthenticationSupport].
  static final Set<WebAuthenticationSupport> values = {
    WebAuthenticationSupport.FOR_APP,
    WebAuthenticationSupport.FOR_BROWSER,
    WebAuthenticationSupport.NONE,
  };

  ///Gets a possible [WebAuthenticationSupport] instance from [int] value.
  static WebAuthenticationSupport? fromValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebAuthenticationSupport] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static WebAuthenticationSupport? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return WebAuthenticationSupport.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [WebAuthenticationSupport] instance value with name [name].
  ///
  /// Goes through [WebAuthenticationSupport.values] looking for a value with
  /// name [name], as reported by [WebAuthenticationSupport.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebAuthenticationSupport? byName(String? name) {
    if (name != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebAuthenticationSupport] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebAuthenticationSupport> asNameMap() =>
      <String, WebAuthenticationSupport>{
        for (final value in WebAuthenticationSupport.values)
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
        return 'FOR_APP';
      case 2:
        return 'FOR_BROWSER';
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
