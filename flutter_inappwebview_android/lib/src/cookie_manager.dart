import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

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
class AndroidCookieManager extends PlatformCookieManager
    with ChannelController {
  /// Creates a new [AndroidCookieManager].
  AndroidCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is AndroidCookieManagerCreationParams
            ? params
            : AndroidCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static final AndroidCookieManager _staticValue = AndroidCookieManager(
    AndroidCookieManagerCreationParams(PlatformCookieManagerCreationParams()),
  );

  factory AndroidCookieManager.static() {
    return _staticValue;
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

  Future<dynamic> _handleMethod(MethodCall call) async {}

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
    PlatformInAppWebViewController? webViewController,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    assert(path.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);
    args.putIfAbsent('isHttpOnly', () => isHttpOnly);
    args.putIfAbsent('sameSite', () => sameSite?.toNativeValue());

    return await channel?.invokeMethod<bool>('setCookie', args) ?? false;
  }

  @override
  Future<List<bool>> setCookies({
    required List<CookieToSet> cookies,
    PlatformInAppWebViewController? webViewController,
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

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent(
      'cookies',
      () => cookies.map(_cookieToSetChannelArgs).toList(),
    );

    final results = await channel?.invokeMethod<List<Object?>>(
      'setCookies',
      args,
    );
    // The `??` covers a null channel (a disposed manager), which is the only case that yields a
    // null here -- a *missing native handler* throws MissingPluginException instead, on this call
    // and on the singular `setCookie` alike. Pinned by a unit test rather than assumed.
    return results?.map((e) => e == true).toList() ??
        List<bool>.filled(cookies.length, false);
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? webViewController,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookieListMap =
        await channel?.invokeMethod<List>('getCookies', args) ?? [];
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();

    for (var cookieMap in cookieListMap) {
      cookies.add(
        Cookie(
          name: cookieMap["name"],
          value: cookieMap["value"],
          expiresDate: cookieMap["expiresDate"],
          isSessionOnly: cookieMap["isSessionOnly"],
          domain: cookieMap["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromNativeValue(
            cookieMap["sameSite"],
          ),
          isSecure: cookieMap["isSecure"],
          isHttpOnly: cookieMap["isHttpOnly"],
          path: cookieMap["path"],
        ),
      );
    }
    return cookies;
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    PlatformInAppWebViewController? webViewController,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookies =
        await channel?.invokeMethod<List>('getCookies', args) ?? [];
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for (var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name) {
        return Cookie(
          name: cookies[i]["name"],
          value: cookies[i]["value"],
          expiresDate: cookies[i]["expiresDate"],
          isSessionOnly: cookies[i]["isSessionOnly"],
          domain: cookies[i]["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromNativeValue(
            cookies[i]["sameSite"],
          ),
          isSecure: cookies[i]["isSecure"],
          isHttpOnly: cookies[i]["isHttpOnly"],
          path: cookies[i]["path"],
        );
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
    PlatformInAppWebViewController? webViewController,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    return await channel?.invokeMethod<bool>('deleteCookie', args) ?? false;
  }

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    PlatformInAppWebViewController? webViewController,
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    return await channel?.invokeMethod<bool>('deleteCookies', args) ?? false;
  }

  @override
  Future<bool> deleteAllCookies({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    return await channel?.invokeMethod<bool>('deleteAllCookies', args) ?? false;
  }

  @override
  Future<bool> removeSessionCookies({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    return await channel?.invokeMethod<bool>('removeSessionCookies', args) ??
        false;
  }

  @override
  Future<bool?> isFileSchemeCookiesAllowed() async {
    // No profileName: the native method is static and process-global.
    return await channel?.invokeMethod<bool>(
      'isFileSchemeCookiesAllowed',
      <String, dynamic>{},
    );
  }

  @override
  Future<bool?> hasCookies({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    // Nullable on purpose -- see isAcceptCookieEnabled: null is "could not read the store", which
    // is not the same answer as "the store is empty".
    return await channel?.invokeMethod<bool>('hasCookies', args);
  }

  @override
  Future<bool> setAcceptCookie(bool accept, {String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('accept', () => accept);
    return await channel?.invokeMethod<bool>('setAcceptCookie', args) ?? false;
  }

  @override
  Future<bool?> isAcceptCookieEnabled({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    // No `?? false` here, unlike every other method on this class: the Kotlin side sends null
    // when it cannot resolve the cookie store, and the platform default is `true`, so defaulting
    // to false would report the opposite of the truth.
    return await channel?.invokeMethod<bool>('isAcceptCookieEnabled', args);
  }

  @override
  Future<void> flush({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    await channel?.invokeMethod('flush', args);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalCookieManager on AndroidCookieManager {
  Future<dynamic> Function(MethodCall call) get handleMethod => _handleMethod;
}

/// The channel arguments for one cookie, spelled **exactly** as the singular `setCookie` spells
/// them, so the native side runs one per-cookie code path for both calls.
///
/// This is deliberately not `CookieToSet.toMap()`. The generated map sends `expiresDate` as an
/// `int`, and the singular call has always sent it as a `String` (both natives read it as one).
/// Two spellings of one value on one channel is how a field ends up silently null on the platform
/// side, so the plural conforms to the singular rather than the other way round.
Map<String, dynamic> _cookieToSetChannelArgs(CookieToSet cookie) =>
    <String, dynamic>{
      "url": cookie.url.toString(),
      "name": cookie.name,
      "value": cookie.value,
      "domain": cookie.domain,
      "path": cookie.path,
      "expiresDate": cookie.expiresDate?.toString(),
      "maxAge": cookie.maxAge,
      "isSecure": cookie.isSecure,
      "isHttpOnly": cookie.isHttpOnly,
      "sameSite": cookie.sameSite?.toNativeValue(),
    };
