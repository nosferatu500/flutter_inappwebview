import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'custom_header.g.dart';

///An HTTP header name/value pair sent on every request to an origin matching [originRules].
///
///Added with [PlatformProfileStore.addCustomHeader] and scoped to a browsing profile, so it
///applies to **every** request that profile makes to a matching origin — including subresources,
///prefetches and requests issued by service workers — not just to navigations. It is therefore a
///very different thing from the per-request `headers` on [URLRequest], which apply to one load.
///
///`WebSocket` requests are **not** covered.
@ExchangeableObject()
class CustomHeader_ {
  ///A valid HTTP header name, for example `X-Tenant`.
  ///
  ///Matched **case-insensitively** against headers already added: adding `x-tenant` when
  ///`X-Tenant` exists is the same header name. The casing of the first one added is the casing
  ///that gets sent.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String name;

  ///A valid HTTP header value. Unlike [name], this is matched **case-sensitively**.
  ///
  ///If several headers share a [name] but differ in value and all match a request, every value is
  ///sent as a single comma-separated list, per
  ///[RFC 7230 §3.2.2](https://www.rfc-editor.org/rfc/rfc7230#section-3.2.2). The platform does not
  ///check whether merging is meaningful for that particular header, so avoid relying on it.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String value;

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
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  Set<String> originRules;

  CustomHeader_({
    required this.name,
    required this.value,
    required this.originRules,
  });
}
