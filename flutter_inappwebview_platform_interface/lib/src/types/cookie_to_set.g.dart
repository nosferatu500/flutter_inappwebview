// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_to_set.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///One cookie to write, for [PlatformCookieManager.setCookies].
///
///This is the **input** counterpart of [Cookie], which is what [PlatformCookieManager.getCookies]
///returns. They are deliberately different types: a cookie being written needs a [url] and may
///carry a [maxAge], neither of which a cookie being read has, and a cookie being read reports
///`isSessionOnly`, which is not something a caller sets. Every field here mirrors a parameter of
///[PlatformCookieManager.setCookie] exactly, so the singular and plural calls cannot drift apart.
///
///Each entry carries its own [url], so a single [PlatformCookieManager.setCookies] call may write
///cookies for several origins.
class CookieToSet {
  ///The cookie domain.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? domain;

  ///The cookie expiration date in milliseconds since the epoch.
  ///
  ///A cookie that has already expired is ignored by the platform, exactly as with
  ///[PlatformCookieManager.setCookie].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  int? expiresDate;

  ///Whether the cookie is inaccessible to JavaScript.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? isHttpOnly;

  ///Whether the cookie is only sent over a secure connection.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? isSecure;

  ///The cookie's max age in seconds.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  int? maxAge;

  ///The cookie name.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String name;

  ///The cookie path. Defaults to `"/"`, matching [PlatformCookieManager.setCookie].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String path;

  ///The cookie's same-site policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  HTTPCookieSameSitePolicy? sameSite;

  ///The URL the cookie is set for. Any existing cookie with the same host, [path] and [name] is
  ///replaced.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  WebUri url;

  ///The cookie value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String value;
  CookieToSet({
    required this.url,
    required this.name,
    required this.value,
    this.path = "/",
    this.domain,
    this.expiresDate,
    this.maxAge,
    this.isSecure,
    this.isHttpOnly,
    this.sameSite,
  });

  ///Gets a possible [CookieToSet] instance from a [Map] value.
  static CookieToSet? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CookieToSet(
      domain: map['domain'],
      expiresDate: map['expiresDate'],
      isHttpOnly: map['isHttpOnly'],
      isSecure: map['isSecure'],
      maxAge: map['maxAge'],
      name: map['name'],
      sameSite: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => HTTPCookieSameSitePolicy.fromNativeValue(
          map['sameSite'],
        ),
        EnumMethod.value => HTTPCookieSameSitePolicy.fromValue(map['sameSite']),
        EnumMethod.name => HTTPCookieSameSitePolicy.byName(map['sameSite']),
      },
      url: WebUri(map['url']),
      value: map['value'],
    );
    if (map['path'] != null) {
      instance.path = map['path'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "domain": domain,
      "expiresDate": expiresDate,
      "isHttpOnly": isHttpOnly,
      "isSecure": isSecure,
      "maxAge": maxAge,
      "name": name,
      "path": path,
      "sameSite": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => sameSite?.toNativeValue(),
        EnumMethod.value => sameSite?.toValue(),
        EnumMethod.name => sameSite?.name(),
      },
      "url": url.toString(),
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CookieToSet{domain: $domain, expiresDate: $expiresDate, isHttpOnly: $isHttpOnly, isSecure: $isSecure, maxAge: $maxAge, name: $name, path: $path, sameSite: $sameSite, url: $url, value: $value}';
  }
}
