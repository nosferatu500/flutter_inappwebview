import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/cookie_manager.g.dart';

/// Object specifying creation parameters for creating a [AndroidCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformCookieManagerCreationParams] for
/// more information.
@immutable
class AndroidCookieManagerCreationParams
    extends PlatformCookieManagerCreationParams {
  /// Creates a new [AndroidCookieManagerCreationParams] instance.
  const AndroidCookieManagerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformCookieManagerCreationParams params,
  ) : super();

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory AndroidCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
    PlatformCookieManagerCreationParams params,
  ) {
    return AndroidCookieManagerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager}
///
/// Transport is Pigeon-generated ([CookieManagerHostApi]) rather than a hand-written
/// `MethodChannel`; the eighth channel migrated, after find_interaction (§14),
/// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
/// credential_database (§163) and both web_message channels (§165). There is no
/// `messageChannelSuffix` because `android.webkit.CookieManager` is process-global.
class AndroidCookieManager extends PlatformCookieManager implements Disposable {
  /// Creates a new [AndroidCookieManager].
  AndroidCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is AndroidCookieManagerCreationParams
            ? params
            : AndroidCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      );

  final CookieManagerHostApi _hostApi = CookieManagerHostApi();

  factory AndroidCookieManager.static() {
    return instance();
  }

  static AndroidCookieManager? _instance;

  ///Gets the [AndroidCookieManager] shared instance.
  static AndroidCookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidCookieManager _init() {
    _instance = AndroidCookieManager(
      AndroidCookieManagerCreationParams(
        const PlatformCookieManagerCreationParams(),
      ),
    );
    return _instance!;
  }

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    // Deliberately no `assert(value.isNotEmpty)`: RFC 6265 §4.1.1 permits an empty cookie value,
    // `set, get, delete` pins it on a device, and [CookieData.value] documents the same thing for
    // the read direction. §168 added that assert by mistake and the device run is what caught it.
    assert(path.isNotEmpty);

    return await _hostApi.setCookie(
      CookieToSetData(
        url: url.toString(),
        name: name,
        value: value,
        path: path,
        domain: domain,
        expiresDate: expiresDate,
        maxAge: maxAge,
        isSecure: isSecure,
        isHttpOnly: isHttpOnly,
        sameSite: sameSite?.toNativeValue(),
      ),
      profileName,
    );
  }

  @override
  Future<List<bool>> setCookies({
    required List<CookieToSet> cookies,
    String? profileName,
  }) async {
    if (cookies.isEmpty) {
      return const <bool>[];
    }
    for (final cookie in cookies) {
      assert(cookie.url.toString().isNotEmpty);
      assert(cookie.name.isNotEmpty);
      assert(cookie.path.isNotEmpty);
    }

    return await _hostApi.setCookies(
      cookies.map(_toCookieToSetData).toList(),
      profileName,
    );
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    final cookies = await _hostApi.getCookies(url.toString(), profileName);
    return cookies.map(_toCookie).toList();
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    // Still one `getCookies` call filtered on this side: the channel has no per-name lookup,
    // because `CookieManager` itself has none.
    final cookies = await _hostApi.getCookies(url.toString(), profileName);
    for (final cookie in cookies) {
      if (cookie.name == name) {
        return _toCookie(cookie);
      }
    }
    return null;
  }

  @override
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    return await _hostApi.deleteCookie(
      url.toString(),
      name,
      domain,
      path,
      profileName,
    );
  }

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    return await _hostApi.deleteCookies(
      url.toString(),
      domain,
      path,
      profileName,
    );
  }

  @override
  Future<bool> deleteAllCookies({String? profileName}) async {
    return await _hostApi.deleteAllCookies(profileName);
  }

  @override
  Future<bool> removeSessionCookies({String? profileName}) async {
    return await _hostApi.removeSessionCookies(profileName);
  }

  @override
  Future<bool?> isFileSchemeCookiesAllowed() async {
    // No profileName: the native method is static and process-global.
    return await _hostApi.isFileSchemeCookiesAllowed();
  }

  @override
  Future<bool?> hasCookies({String? profileName}) async {
    // Nullable on purpose -- see isAcceptCookieEnabled: null is "could not read the store", which
    // is not the same answer as "the store is empty". The schema types this `bool?` so the
    // distinction is now carried by the wire rather than by the absence of a `?? false`.
    return await _hostApi.hasCookies(profileName);
  }

  @override
  Future<bool> setAcceptCookie(bool accept, {String? profileName}) async {
    return await _hostApi.setAcceptCookie(accept, profileName);
  }

  @override
  Future<bool?> isAcceptCookieEnabled({String? profileName}) async {
    // Nullable, unlike most methods on this class: the Kotlin side sends null when it cannot
    // resolve the cookie store, and the platform default is `true`, so collapsing that to false
    // would report the opposite of the truth.
    return await _hostApi.isAcceptCookieEnabled(profileName);
  }

  @override
  Future<bool> flush({String? profileName}) async {
    return await _hostApi.flush(profileName);
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton.
  }
}

/// Rebuilds the public [Cookie] from the wire type.
///
/// `isSessionOnly` is passed `null` because the Android side has never populated it: the
/// hand-written Kotlin seeded the key with a literal null and never assigned it on either branch,
/// so the field is dropped from the wire and this records why it is still null here (§168).
///
/// Lives in this file rather than its own, unlike §165's web-message converters: those were shared
/// by three classes, these have exactly one caller each.
Cookie _toCookie(CookieData cookie) => Cookie(
  name: cookie.name,
  value: cookie.value,
  expiresDate: cookie.expiresDate,
  isSessionOnly: null,
  domain: cookie.domain,
  sameSite: HTTPCookieSameSitePolicy.fromNativeValue(cookie.sameSite),
  isSecure: cookie.isSecure,
  isHttpOnly: cookie.isHttpOnly,
  path: cookie.path,
);

/// The wire form of one cookie to write.
///
/// The singular [AndroidCookieManager.setCookie] builds the same type inline from its named
/// parameters, so both writes go through one Kotlin path by construction. That used to be kept true
/// by hand -- a comment on the old `_cookieToSetChannelArgs` explained that it could not use
/// `CookieToSet.toMap()` because the generated map spelled `expiresDate` as an `int` while the
/// singular call sent a `String`. One typed field ends that divergence (§168).
CookieToSetData _toCookieToSetData(CookieToSet cookie) => CookieToSetData(
  url: cookie.url.toString(),
  name: cookie.name,
  value: cookie.value,
  path: cookie.path,
  domain: cookie.domain,
  expiresDate: cookie.expiresDate,
  maxAge: cookie.maxAge,
  isSecure: cookie.isSecure,
  isHttpOnly: cookie.isHttpOnly,
  sameSite: cookie.sameSite?.toNativeValue(),
);
