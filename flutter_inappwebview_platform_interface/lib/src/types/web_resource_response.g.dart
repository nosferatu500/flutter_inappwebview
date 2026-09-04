// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource response of the `WebView`.
class WebResourceResponse {
  ///The resource response's encoding. The default value is `utf-8`.
  String? contentEncoding;

  ///The resource response's MIME type, for example `text/html`.
  String? contentType;

  ///A list of `Set-Cookie` header values to apply as if the intercepted response had carried them,
  ///for example `["id=abc; Path=/; HttpOnly", "theme=dark; Max-Age=3600"]`.
  ///
  ///Each entry is one complete `Set-Cookie` **value** — the `Set-Cookie:` name itself is not part
  ///of it. Supplying them here rather than in [headers] is what lets you set more than one cookie,
  ///since [headers] is a `Map` and cannot hold a repeated header name.
  ///
  ///**These values are silently ignored unless cookie interception is enabled** — nothing throws
  ///and nothing is logged. Enable it with
  ///[InAppWebViewSettings.includeCookiesOnShouldInterceptRequest] for a `WebView`, or with
  ///[PlatformServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled] for a
  ///service worker, and check [WebViewFeature.COOKIE_INTERCEPT] first.
  ///
  ///A `Set-Cookie` entry left in [headers] is also applied when interception is enabled, but
  ///prefer this field: it is the only one that can carry several cookies.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebResourceResponseCompat.setCookies](https://developer.android.com/reference/androidx/webkit/WebResourceResponseCompat#setCookies(java.util.List%3Cjava.lang.String%3E))):
  ///    - available on Android only if [WebViewFeature.COOKIE_INTERCEPT] feature is supported.
  List<String>? cookies;

  ///The data provided by the resource response.
  Uint8List? data;

  ///The headers for the resource response. If [headers] isn't `null`, then you need to set also [statusCode] and [reasonPhrase].
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  Map<String, String>? headers;

  ///The phrase describing the status code, for example `"OK"`. Must be non-empty.
  ///If reasonPhrase is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  String? reasonPhrase;

  ///The status code needs to be in the ranges [100, 299], [400, 599]. Causing a redirect by specifying a 3xx code is not supported.
  ///If statusCode is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  int? statusCode;
  WebResourceResponse({
    this.contentEncoding = "utf-8",
    this.contentType = "",
    this.cookies,
    this.data,
    this.headers,
    this.reasonPhrase,
    this.statusCode,
  });

  ///Gets a possible [WebResourceResponse] instance from a [Map] value.
  static WebResourceResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceResponse(
      cookies: map['cookies'] != null
          ? List<String>.from(map['cookies']!.cast<String>())
          : null,
      data: map['data'] != null
          ? Uint8List.fromList(map['data'].cast<int>())
          : null,
      headers: map['headers']?.cast<String, String>(),
      reasonPhrase: map['reasonPhrase'],
      statusCode: map['statusCode'],
    );
    instance.contentEncoding = map['contentEncoding'];
    instance.contentType = map['contentType'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "contentEncoding": contentEncoding,
      "contentType": contentType,
      "cookies": cookies,
      "data": data,
      "headers": headers,
      "reasonPhrase": reasonPhrase,
      "statusCode": statusCode,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceResponse{contentEncoding: $contentEncoding, contentType: $contentType, cookies: $cookies, data: $data, headers: $headers, reasonPhrase: $reasonPhrase, statusCode: $statusCode}';
  }
}
