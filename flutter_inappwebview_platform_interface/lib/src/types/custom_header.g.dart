// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_header.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An HTTP header name/value pair sent on every request to an origin matching [originRules].
///
///Added with [PlatformProfileStore.addCustomHeader] and scoped to a browsing profile, so it
///applies to **every** request that profile makes to a matching origin — including subresources,
///prefetches and requests issued by service workers — not just to navigations. It is therefore a
///very different thing from the per-request `headers` on [URLRequest], which apply to one load.
///
///`WebSocket` requests are **not** covered.
class CustomHeader {
  ///A valid HTTP header name, for example `X-Tenant`.
  ///
  ///Matched **case-insensitively** against headers already added: adding `x-tenant` when
  ///`X-Tenant` exists is the same header name. The casing of the first one added is the casing
  ///that gets sent.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String name;

  ///The origins this header is sent to, in the same format as
  ///[PlatformInAppWebViewController.addWebMessageListener]'s `allowedOriginRules` —
  ///for example `{"https://example.com"}`, `{"https://*.example.com"}` or `{"*"}` for every origin.
  ///
  ///**A header with no matching rule is simply never sent**; nothing throws. Verified on device
  ///with a two-header control — one rule matching the loaded origin and one not — where only the
  ///matching header appeared on the request.
  ///
  ///Adding the same [name] and [value] again with different rules **merges** the rule sets rather
  ///than replacing them.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  Set<String> originRules;

  ///A valid HTTP header value. Unlike [name], this is matched **case-sensitively**.
  ///
  ///If several headers share a [name] but differ in value and all match a request, every value is
  ///sent as a single comma-separated list, per
  ///[RFC 7230 §3.2.2](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2). The platform does not
  ///check whether merging is meaningful for that particular header, so avoid relying on it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String value;
  CustomHeader({
    required this.name,
    required this.originRules,
    required this.value,
  });

  ///Gets a possible [CustomHeader] instance from a [Map] value.
  static CustomHeader? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CustomHeader(
      name: map['name'],
      originRules: Set<String>.from(map['originRules']!.cast<String>()),
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"name": name, "originRules": originRules.toList(), "value": value};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CustomHeader{name: $name, originRules: $originRules, value: $value}';
  }
}
