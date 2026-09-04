import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_webview/headless_in_app_webview.dart';
import 'platform_util.dart';

/// Object specifying creation parameters for creating a [IOSCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformCookieManagerCreationParams] for
/// more information.
@immutable
class IOSCookieManagerCreationParams
    extends PlatformCookieManagerCreationParams {
  /// Creates a new [IOSCookieManagerCreationParams] instance.
  const IOSCookieManagerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformCookieManagerCreationParams params,
  ) : super();

  /// Creates a [IOSCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory IOSCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
    PlatformCookieManagerCreationParams params,
  ) {
    return IOSCookieManagerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager}
class IOSCookieManager extends PlatformCookieManager with ChannelController {
  /// Creates a new [IOSCookieManager].
  IOSCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is IOSCookieManagerCreationParams
            ? params
            : IOSCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static final IOSCookieManager _staticValue = IOSCookieManager(
    IOSCookieManagerCreationParams(PlatformCookieManagerCreationParams()),
  );

  factory IOSCookieManager.static() {
    return _staticValue;
  }

  static IOSCookieManager? _instance;

  ///Gets the [IOSCookieManager] shared instance.
  static IOSCookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static IOSCookieManager _init() {
    _instance = IOSCookieManager(
      IOSCookieManagerCreationParams(
        const PlatformCookieManagerCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Deliberately `static`, and it is not a shortcut.
  ///
  /// `createPlatformCookieManager` returns a **new** [IOSCookieManager] on every call and
  /// [IOSCookieManager.static] is a further, separate object — yet all of them attach a method-call
  /// handler to the same `const MethodChannel`, where the last one to be constructed silently
  /// replaces the previous handler. An observer held per instance would therefore stop firing the
  /// moment anything touched `CookieManager.isMethodSupported`, which constructs the static one.
  ///
  /// Holding it statically also matches the platform: there is one
  /// `WKWebsiteDataStore.default().httpCookieStore` in the process and one native observer
  /// registration for it, so every [CookieManager] necessarily sees the same one.
  static CookieStoreObserver? _cookieStoreObserver;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onCookiesChanged":
        // No arguments: WKHTTPCookieStoreObserver reports that the store changed and nothing
        // about what changed.
        _cookieStoreObserver?.onCookiesChanged?.call();
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  Future<bool> setAcceptCookie(
    bool accept, {
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('accept', () => accept);
    return await channel?.invokeMethod<bool>('setAcceptCookie', args) ?? false;
  }

  @override
  Future<bool?> isAcceptCookieEnabled({
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isAcceptCookieEnabled', args);
  }

  @override
  CookieStoreObserver? get cookieStoreObserver => _cookieStoreObserver;

  @override
  Future<void> setCookieStoreObserver(CookieStoreObserver? observer) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('isNull', () => observer == null);
    await channel?.invokeMethod('setCookieStoreObserver', args);
    // Assigned after the native call so a failure to register leaves the Dart side saying there is
    // no observer, rather than claiming one that would never fire.
    _cookieStoreObserver = observer;
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
    PlatformInAppWebViewController? webViewController,
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    assert(path.isNotEmpty);

    if (await _shouldUseJavascript()) {
      await _setCookieWithJavaScript(
        url: url,
        name: name,
        value: value,
        domain: domain,
        path: path,
        expiresDate: expiresDate,
        maxAge: maxAge,
        isSecure: isSecure,
        sameSite: sameSite,
        webViewController: webViewController,
      );
      return true;
    }

    Map<String, dynamic> args = <String, dynamic>{};
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
    // Android-only; accepted so the signature matches PlatformCookieManager.
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

    // No `_shouldUseJavascript()` branch here, unlike `setCookie`. That branch is reachable only
    // below system version 10.13 and this module's deployment target is iOS 15.0, so it is dead
    // code on the singular call too — see `TODO.md`. Mirroring dead code into a new method would
    // make it look load-bearing.
    Map<String, dynamic> args = <String, dynamic>{};
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

  Future<void> _setCookieWithJavaScript({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    HTTPCookieSameSitePolicy? sameSite,
    PlatformInAppWebViewController? webViewController,
  }) async {
    var cookieValue = "$name=$value; Path=$path";

    if (domain != null) cookieValue += "; Domain=$domain";

    if (expiresDate != null) {
      cookieValue += "; Expires=${await _getCookieExpirationDate(expiresDate)}";
    }

    if (maxAge != null) cookieValue += "; Max-Age=$maxAge";

    if (isSecure != null && isSecure) cookieValue += "; Secure";

    if (sameSite != null && sameSite.isSupported()) {
      cookieValue += "; SameSite=${sameSite.toNativeValue()!}";
    }

    cookieValue += ";";

    if (webViewController != null) {
      final javaScriptEnabled =
          (await webViewController.getSettings())?.javaScriptEnabled ?? false;
      if (javaScriptEnabled) {
        await webViewController.evaluateJavascript(
          source: 'document.cookie="$cookieValue"',
        );
        return;
      }
    }

    final setCookieCompleter = Completer<void>();
    final headlessWebView = IOSHeadlessInAppWebView(
      IOSHeadlessInAppWebViewCreationParams(
        initialUrlRequest: URLRequest(url: url),
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(
            source: 'document.cookie="$cookieValue"',
          );
          setCookieCompleter.complete();
        },
      ),
    );
    await headlessWebView.run();
    await setCookieCompleter.future;
    await headlessWebView.dispose();
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? webViewController,
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    if (await _shouldUseJavascript()) {
      return await _getCookiesWithJavaScript(
        url: url,
        webViewController: webViewController,
      );
    }

    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
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

  Future<List<Cookie>> _getCookiesWithJavaScript({
    required WebUri url,
    PlatformInAppWebViewController? webViewController,
  }) async {
    assert(url.toString().isNotEmpty);

    List<Cookie> cookies = [];

    if (webViewController != null) {
      final javaScriptEnabled =
          (await webViewController.getSettings())?.javaScriptEnabled ?? false;
      if (javaScriptEnabled) {
        List<String> documentCookies =
            (await webViewController.evaluateJavascript(
                      source: 'document.cookie',
                    )
                    as String)
                .split(';')
                .map((documentCookie) => documentCookie.trim())
                .toList();
        for (var documentCookie in documentCookies) {
          List<String> cookie = documentCookie.split('=');
          if (cookie.length > 1) {
            cookies.add(Cookie(name: cookie[0], value: cookie[1]));
          }
        }
        return cookies;
      }
    }

    final pageLoaded = Completer<void>();
    final headlessWebView = IOSHeadlessInAppWebView(
      IOSHeadlessInAppWebViewCreationParams(
        initialUrlRequest: URLRequest(url: url),
        onLoadStop: (controller, url) async {
          pageLoaded.complete();
        },
      ),
    );
    await headlessWebView.run();
    await pageLoaded.future;

    List<String> documentCookies =
        (await headlessWebView.webViewController!.evaluateJavascript(
                  source: 'document.cookie',
                )
                as String)
            .split(';')
            .map((documentCookie) => documentCookie.trim())
            .toList();
    for (var documentCookie in documentCookies) {
      List<String> cookie = documentCookie.split('=');
      if (cookie.length > 1) {
        cookies.add(Cookie(name: cookie[0], value: cookie[1]));
      }
    }
    await headlessWebView.dispose();
    return cookies;
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    PlatformInAppWebViewController? webViewController,
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    if (await _shouldUseJavascript()) {
      List<Cookie> cookies = await _getCookiesWithJavaScript(
        url: url,
        webViewController: webViewController,
      );
      return cookies.cast<Cookie?>().firstWhere(
        (cookie) => cookie!.name == name,
        orElse: () => null,
      );
    }

    Map<String, dynamic> args = <String, dynamic>{};
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
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    if (await _shouldUseJavascript()) {
      await _setCookieWithJavaScript(
        url: url,
        name: name,
        value: "",
        path: path,
        domain: domain,
        maxAge: -1,
        webViewController: webViewController,
      );
      return true;
    }

    Map<String, dynamic> args = <String, dynamic>{};
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
    // Android-only; accepted so the signature matches PlatformCookieManager.
    String? profileName,
  }) async {
    assert(url.toString().isNotEmpty);

    if (await _shouldUseJavascript()) {
      List<Cookie> cookies = await _getCookiesWithJavaScript(
        url: url,
        webViewController: webViewController,
      );
      for (var i = 0; i < cookies.length; i++) {
        await _setCookieWithJavaScript(
          url: url,
          name: cookies[i].name,
          value: "",
          path: path,
          domain: domain,
          maxAge: -1,
          webViewController: webViewController,
        );
      }
      return true;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    return await channel?.invokeMethod<bool>('deleteCookies', args) ?? false;
  }

  @override
  Future<bool> deleteAllCookies({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('deleteAllCookies', args) ?? false;
  }

  @override
  Future<List<Cookie>> getAllCookies() async {
    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> cookieListMap =
        await channel?.invokeMethod<List>('getAllCookies', args) ?? [];
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

  Future<String> _getCookieExpirationDate(int expiresDate) async {
    var platformUtil = PlatformUtil.instance();
    var dateTime = DateTime.fromMillisecondsSinceEpoch(expiresDate).toUtc();
    return await platformUtil.formatDate(
      date: dateTime,
      format: 'EEE, dd MMM yyyy HH:mm:ss z',
      locale: 'en_US',
      timezone: 'GMT',
    );
  }

  Future<bool> _shouldUseJavascript() async {
    final platformUtil = PlatformUtil.instance();
    final systemVersion = await platformUtil.getSystemVersion();
    return systemVersion.compareTo("10.13") == -1;
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalCookieManager on IOSCookieManager {
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
