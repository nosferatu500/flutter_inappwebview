// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space_authentication_method.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
class URLProtectionSpaceAuthenticationMethod {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const URLProtectionSpaceAuthenticationMethod._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory URLProtectionSpaceAuthenticationMethod._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => URLProtectionSpaceAuthenticationMethod._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodClientCertificate',
        'NSURLAuthenticationMethodClientCertificate',
      );

  ///Use the default authentication method for a protocol.
  static const NSURL_AUTHENTICATION_METHOD_DEFAULT =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodDefault',
        'NSURLAuthenticationMethodDefault',
      );

  ///Use HTML form authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTML_FORM =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodHTMLForm',
        'NSURLAuthenticationMethodHTMLForm',
      );

  ///Use HTTP basic authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_BASIC =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodHTTPBasic',
        'NSURLAuthenticationMethodHTTPBasic',
      );

  ///Use HTTP digest authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodHTTPDigest',
        'NSURLAuthenticationMethodHTTPDigest',
      );

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodNegotiate',
        'NSURLAuthenticationMethodNegotiate',
      );

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodNTLM',
        'NSURLAuthenticationMethodNTLM',
      );

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      URLProtectionSpaceAuthenticationMethod._internal(
        'NSURLAuthenticationMethodServerTrust',
        'NSURLAuthenticationMethodServerTrust',
      );

  ///Set of all values of [URLProtectionSpaceAuthenticationMethod].
  static final Set<URLProtectionSpaceAuthenticationMethod> values = {
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE,
    URLProtectionSpaceAuthenticationMethod.NSURL_AUTHENTICATION_METHOD_DEFAULT,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_HTML_FORM,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_HTTP_BASIC,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NEGOTIATE,
    URLProtectionSpaceAuthenticationMethod.NSURL_AUTHENTICATION_METHOD_NTLM,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_SERVER_TRUST,
  };

  ///Gets a possible [URLProtectionSpaceAuthenticationMethod] instance from [String] value.
  static URLProtectionSpaceAuthenticationMethod? fromValue(String? value) {
    if (value != null) {
      try {
        return URLProtectionSpaceAuthenticationMethod.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [URLProtectionSpaceAuthenticationMethod] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static URLProtectionSpaceAuthenticationMethod? fromNativeValue(
    String? value,
  ) {
    if (value != null) {
      try {
        return URLProtectionSpaceAuthenticationMethod.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return URLProtectionSpaceAuthenticationMethod.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [URLProtectionSpaceAuthenticationMethod] instance value with name [name].
  ///
  /// Goes through [URLProtectionSpaceAuthenticationMethod.values] looking for a value with
  /// name [name], as reported by [URLProtectionSpaceAuthenticationMethod.name].
  /// Returns the first value with the given name, otherwise `null`.
  static URLProtectionSpaceAuthenticationMethod? byName(String? name) {
    if (name != null) {
      try {
        return URLProtectionSpaceAuthenticationMethod.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [URLProtectionSpaceAuthenticationMethod] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, URLProtectionSpaceAuthenticationMethod> asNameMap() =>
      <String, URLProtectionSpaceAuthenticationMethod>{
        for (final value in URLProtectionSpaceAuthenticationMethod.values)
          value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'NSURLAuthenticationMethodClientCertificate':
        return 'NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE';
      case 'NSURLAuthenticationMethodDefault':
        return 'NSURL_AUTHENTICATION_METHOD_DEFAULT';
      case 'NSURLAuthenticationMethodHTMLForm':
        return 'NSURL_AUTHENTICATION_METHOD_HTML_FORM';
      case 'NSURLAuthenticationMethodHTTPBasic':
        return 'NSURL_AUTHENTICATION_METHOD_HTTP_BASIC';
      case 'NSURLAuthenticationMethodHTTPDigest':
        return 'NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST';
      case 'NSURLAuthenticationMethodNegotiate':
        return 'NSURL_AUTHENTICATION_METHOD_NEGOTIATE';
      case 'NSURLAuthenticationMethodNTLM':
        return 'NSURL_AUTHENTICATION_METHOD_NTLM';
      case 'NSURLAuthenticationMethodServerTrust':
        return 'NSURL_AUTHENTICATION_METHOD_SERVER_TRUST';
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
