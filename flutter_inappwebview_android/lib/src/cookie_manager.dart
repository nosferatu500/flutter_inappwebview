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
