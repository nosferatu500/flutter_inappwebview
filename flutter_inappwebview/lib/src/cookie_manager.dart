import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_webview/in_app_webview_controller.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager}
///
///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.supported_platforms}
class CookieManager {
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.supported_platforms}
  CookieManager()
    : this.fromPlatformCreationParams(
        const PlatformCookieManagerCreationParams(),
      );

  /// Constructs a [CookieManager] from creation params for a specific
  /// platform.
  CookieManager.fromPlatformCreationParams(
    PlatformCookieManagerCreationParams params,
  ) : this.fromPlatform(PlatformCookieManager(params));

  /// Constructs a [CookieManager] from a specific platform
  /// implementation.
  CookieManager.fromPlatform(this.platform);

  /// Implementation of [PlatformCookieManager] for the current platform.
  final PlatformCookieManager platform;

  static CookieManager? _instance;

  ///Gets the [CookieManager] shared instance.
  static CookieManager instance() {
    _instance ??= CookieManager();
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie.supported_platforms}
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
    InAppWebViewController? webViewController,
    String? profileName,
  }) => platform.setCookie(
    url: url,
    name: name,
    value: value,
    path: path,
    domain: domain,
    expiresDate: expiresDate,
    maxAge: maxAge,
    isSecure: isSecure,
    isHttpOnly: isHttpOnly,
    sameSite: sameSite,
    webViewController: webViewController?.platform,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies.supported_platforms}
  Future<List<Cookie>> getCookies({
    required WebUri url,
    InAppWebViewController? webViewController,
    String? profileName,
  }) => platform.getCookies(
    url: url,
    webViewController: webViewController?.platform,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie.supported_platforms}
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    InAppWebViewController? webViewController,
    String? profileName,
  }) => platform.getCookie(
    url: url,
    name: name,
    webViewController: webViewController?.platform,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie.supported_platforms}
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    InAppWebViewController? webViewController,
    String? profileName,
  }) => platform.deleteCookie(
    url: url,
    name: name,
    path: path,
    domain: domain,
    webViewController: webViewController?.platform,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies.supported_platforms}
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    InAppWebViewController? webViewController,
    String? profileName,
  }) => platform.deleteCookies(
    url: url,
    path: path,
    domain: domain,
    webViewController: webViewController?.platform,
    profileName: profileName,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies.supported_platforms}
  Future<bool> deleteAllCookies({String? profileName}) =>
      platform.deleteAllCookies(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies.supported_platforms}
  Future<List<Cookie>> getAllCookies() => platform.getAllCookies();

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies.supported_platforms}
  Future<bool> removeSessionCookies({String? profileName}) =>
      platform.removeSessionCookies(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.flush}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.flush.supported_platforms}
  Future<void> flush({String? profileName}) =>
      platform.flush(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.hasCookies}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.hasCookies.supported_platforms}
  Future<bool?> hasCookies({String? profileName}) =>
      platform.hasCookies(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setAcceptCookie}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setAcceptCookie.supported_platforms}
  Future<bool> setAcceptCookie(bool accept, {String? profileName}) =>
      platform.setAcceptCookie(accept, profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isAcceptCookieEnabled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isAcceptCookieEnabled.supported_platforms}
  Future<bool?> isAcceptCookieEnabled({String? profileName}) =>
      platform.isAcceptCookieEnabled(profileName: profileName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isFileSchemeCookiesAllowed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isFileSchemeCookiesAllowed.supported_platforms}
  ///
  ///`static` because the value is process-global — following the same shape as
  ///[ServiceWorkerController]'s static getters.
  static Future<bool?> isFileSchemeCookiesAllowed() =>
      PlatformCookieManager.static().isFileSchemeCookiesAllowed();

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformCookieManager.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isMethodSupported}
  static bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) => PlatformCookieManager.static().isMethodSupported(
    method,
    platform: platform,
  );
}
