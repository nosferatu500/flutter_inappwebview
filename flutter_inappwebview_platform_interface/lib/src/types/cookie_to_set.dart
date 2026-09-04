import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../platform_cookie_manager.dart';
import '../web_uri.dart';
import 'http_cookie_same_site_policy.dart';
import 'enum_method.dart';

part 'cookie_to_set.g.dart';

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
@ExchangeableObject()
class CookieToSet_ {
  ///The URL the cookie is set for. Any existing cookie with the same host, [path] and [name] is
  ///replaced.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  WebUri url;

  ///The cookie name.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String name;

  ///The cookie value.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String value;

  ///The cookie path. Defaults to `"/"`, matching [PlatformCookieManager.setCookie].
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String path;

  ///The cookie domain.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  String? domain;

  ///The cookie expiration date in milliseconds since the epoch.
  ///
  ///A cookie that has already expired is ignored by the platform, exactly as with
  ///[PlatformCookieManager.setCookie].
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  int? expiresDate;

  ///The cookie's max age in seconds.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  int? maxAge;

  ///Whether the cookie is only sent over a secure connection.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? isSecure;

  ///Whether the cookie is inaccessible to JavaScript.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  bool? isHttpOnly;

  ///The cookie's same-site policy.
  @SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
  HTTPCookieSameSitePolicy_? sameSite;

  @ExchangeableObjectConstructor()
  CookieToSet_({
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
}
