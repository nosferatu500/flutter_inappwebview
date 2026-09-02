import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'in_app_webview/platform_headless_in_app_webview.dart';
import 'in_app_webview/platform_inappwebview_controller.dart';
import 'inappwebview_platform.dart';
import 'types/main.dart';
import 'web_uri.dart';

part 'platform_cookie_manager.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams}
/// Object specifying creation parameters for creating a [PlatformCookieManager].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform(), IOSPlatform()])
@immutable
class PlatformCookieManagerCreationParams {
  /// Used by the platform implementation to create a new [PlatformCookieManager].
  const PlatformCookieManagerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformCookieManagerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformCookieManager}
///Class that implements a singleton object (shared instance) which manages the cookies used by WebView instances.
///
///Every method here operates on the default cookie store unless a `profileName` is given. On
///Android, passing one scopes that single call to the cookie store of that browsing profile
///instead — the same profile a WebView is put on with [InAppWebViewSettings.profileName]. Cookies
///are not shared between profiles, so a WebView running on a non-default profile is *not* affected
///by calls that omit `profileName`.
///
///Scoping is per call rather than per instance, matching how `webViewController` already narrows
///these methods. The trade-off is that omitting it silently falls back to the default profile
///rather than failing, so a caller working with profiles has to pass it every time.
///
///`profileName` requires [WebViewFeature.MULTI_PROFILE]. Without that feature, or when no profile
///of that name exists, nothing is read or written and the call reports failure — it never falls
///back to the default store. Use [PlatformProfileStore] to create profiles.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      note:
          'It is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).',
    ),
    IOSPlatform(
      note:
          """It is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
On iOS below 11.0, it is implemented using JavaScript. See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
  """,
    ),
  ],
)
abstract class PlatformCookieManager extends PlatformInterface {
  /// Creates a new [PlatformCookieManager]
  factory PlatformCookieManager(PlatformCookieManagerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformCookieManager cookieManager = InAppWebViewPlatform.instance!
        .createPlatformCookieManager(params);
    PlatformInterface.verify(cookieManager, _token);
    return cookieManager;
  }

  /// Creates a new [PlatformCookieManager] to access static methods.
  factory PlatformCookieManager.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformCookieManager cookieManagerStatic = InAppWebViewPlatform
        .instance!
        .createPlatformCookieManagerStatic();
    PlatformInterface.verify(cookieManagerStatic, _token);
    return cookieManagerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformCookieManager].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformCookieManager.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformCookieManager].
  final PlatformCookieManagerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie}
  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie.
  ///The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///The return value indicates whether the cookie was set successfully.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.setCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#setCookie(java.lang.String,%20java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.setCookie',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie',
        note:
            """On iOS below 11.0, the [webViewController] could be used if you need to set a session-only cookie using JavaScript
(so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) on
the current URL of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
In this case, this method will return always `true`.""",
      ),
    ],
  )
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
    @SupportedPlatforms(platforms: [IOSPlatform()])
    PlatformInAppWebViewController? webViewController,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'setCookie is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies}
  ///Gets all the cookies for the given [url].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.getCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.getAllCookies',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies',
        note:
            """On iOS below 11.0, the [webViewController] is used for getting the cookies (also session-only cookies) using JavaScript
(cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
In this case the [url] parameter is ignored.
All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).""",
      ),
    ],
  )
  Future<List<Cookie>> getCookies({
    required WebUri url,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    PlatformInAppWebViewController? webViewController,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getCookies is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie}
  ///Gets a cookie by its [name] for the given [url].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.getCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.getAllCookies',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies',
        note:
            """On iOS below 11.0, the [webViewController] is used for getting the cookie (also session-only cookie) using JavaScript
(cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
In this case the [url] parameter is ignored.
All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).""",
      ),
    ],
  )
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    PlatformInAppWebViewController? webViewController,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getCookie is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie}
  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///The return value indicates whether the cookie was deleted successfully.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.getCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.delete',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete',
        note:
            """On iOS below 11.0, the [webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript
(cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
In this case the [url] parameter is ignored.
If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
In this case, this method will return always `true`.""",
      ),
    ],
  )
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    PlatformInAppWebViewController? webViewController,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteCookie is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies}
  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///The return value indicates whether cookies were deleted successfully.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.getCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.delete',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete',
        note:
            """On iOS below 11.0, the [webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript
(cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
In this case the [url] parameter is ignored.
If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
In this case, this method will return always `true`.""",
      ),
    ],
  )
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    @SupportedPlatforms(platforms: [IOSPlatform()])
    PlatformInAppWebViewController? webViewController,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteCookies is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies}
  ///Removes all cookies.
  ///
  ///The return value indicates whether any cookies were removed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.removeAllCookies',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#removeAllCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.removeData',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
        available: '11.0',
        note: """It will return always `true`.""",
      ),
    ],
  )
  Future<bool> deleteAllCookies({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'deleteAllCookies is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies}
  ///Fetches all stored cookies.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.getAllCookies',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies',
        available: '11.0',
      ),
    ],
  )
  Future<List<Cookie>> getAllCookies() {
    throw UnimplementedError(
      'getAllCookies is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies}
  ///Removes all session cookies, which are cookies without an expiration date.
  ///
  ///The return value indicates whether any cookies were removed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.removeSessionCookies',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#removeSessionCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)',
      ),
    ],
  )
  Future<bool> removeSessionCookies({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'removeSessionCookies is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.flush}
  ///Ensures all cookies currently accessible through the getCookie API are written to persistent storage.
  ///This call will block the caller until it is done and may perform I/O.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.flush.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.flush',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#flush()',
      ),
    ],
  )
  Future<void> flush({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'flush is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.hasCookies}
  ///Returns whether the cookie store holds any cookie at all.
  ///
  ///Unlike [getCookies] this takes **no url**: it is a question about the whole store, not about
  ///one origin, and it answers without enumerating or parsing anything. Use it for the cheap
  ///"is there anything to clear?" check that would otherwise be
  ///`(await getCookies(url: …)).isNotEmpty` — which is both more expensive and a different
  ///question, since it only ever sees one origin.
  ///
  ///Returns `bool?`, not `bool`, for the same reason as [isAcceptCookieEnabled]: `null` means the
  ///cookie store could not be resolved — no WebView provider is installed, or a `profileName` was
  ///given that does not exist — and reporting `false` there would say "there are no cookies" about
  ///a store that was never read. A caller clearing cookies on logout must be able to tell those
  ///apart before deciding to skip the work.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.hasCookies.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.hasCookies',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#hasCookies()',
      ),
    ],
  )
  Future<bool?> hasCookies({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      '${PlatformCookieManagerMethod.hasCookies.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.isFileSchemeCookiesAllowed}
  ///Returns whether the WebView sends and accepts cookies for `file://` URLs.
  ///
  ///**Read-only, deliberately.** The platform's setter, `setAcceptFileSchemeCookies`, is
  ///`@Deprecated` and is not exposed by this plugin — file-scheme cookies share a single origin
  ///across every local file, so one local page can read another's cookies. The getter is not
  ///deprecated, which is why the pair is asymmetric here rather than by oversight.
  ///
  ///It is **process-global**, not per-WebView and not per-profile: the platform method is `static`
  ///and, when it was still settable, had to be called before any WebView existed. That is why this
  ///takes no `profileName` while everything else on this class does, and why the facade exposes it
  ///as a `static`.
  ///
  ///Returns `bool?` like [hasCookies] and [isAcceptCookieEnabled]: `null` means no WebView provider
  ///could be resolved, which is not the same as "file-scheme cookies are disallowed".
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isFileSchemeCookiesAllowed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.allowFileSchemeCookies',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#allowFileSchemeCookies()',
        note:
            'Read-only: the counterpart `setAcceptFileSchemeCookies` is deprecated and is not exposed.',
      ),
    ],
  )
  Future<bool?> isFileSchemeCookiesAllowed() {
    throw UnimplementedError(
      '${PlatformCookieManagerMethod.isFileSchemeCookiesAllowed.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.setAcceptCookie}
  ///Sets whether the cookie store accepts cookies at all.
  ///
  ///This is the master switch for cookies flowing through the WebView's **own network traffic**:
  ///with [accept] set to `false` the WebView stops accepting cookies from responses and stops
  ///sending stored ones, first-party included. It is coarser than
  ///[setAcceptThirdPartyCookies] on the WebView, which is the narrower tool if the goal is a
  ///privacy setting rather than an off switch.
  ///
  ///**It does not disable this class.** Measured on Android 13 / WebView 109 **and, separately, on
  ///iOS 26.5**: while acceptance is off, [setCookie] still succeeds *and the cookie is still
  ///stored*, [deleteCookie] still deletes, and [getCookies] keeps returning everything already in
  ///the store. So the switch governs the engine, not the app's own reads and writes — which is not
  ///what either platform's wording suggests. An integration test pins this on both.
  ///
  ///Turning it off therefore deletes nothing and hides nothing. Use [deleteAllCookies] to actually
  ///remove cookies.
  ///
  ///**Its scope differs by platform** and neither is per-WebView. On Android it is process-wide for
  ///the cookie store it applies to; on iOS it belongs to the default data store's cookie store, so
  ///a WebView on a non-persistent (incognito) store is unaffected.
  ///
  ///The return value indicates whether the switch was applied, not what it was set to. It is
  ///`false` when the switch could not be applied at all: on Android when the cookie store could not
  ///be resolved (see the `profileName` contract in the class documentation), and on **iOS below
  ///17.0**, where there is no cookie policy to set. `false` never means "cookies are now rejected".
  ///
  ///Setting the policy is **not** a cookie change: it does not notify a
  ///[CookieStoreObserver] registered with [setCookieStoreObserver] (measured on iOS 26.5).
  ///
  ///Read the current state with [isAcceptCookieEnabled].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setAcceptCookie.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.setAcceptCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#setAcceptCookie(boolean)',
        note:
            'The switch is process-wide for the default cookie store, so it affects every WebView in the app, not just one.',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.setCookiePolicy',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/4133727-setcookiepolicy',
        available: '17.0',
        note:
            'Scoped to the default data store\'s cookie store rather than the process. Returns `false` below iOS 17.0, where the policy cannot be set at all.',
      ),
    ],
  )
  Future<bool> setAcceptCookie(
    bool accept, {
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      '${PlatformCookieManagerMethod.setAcceptCookie.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.isAcceptCookieEnabled}
  ///Returns whether the cookie store currently accepts cookies, as last set by
  ///[setAcceptCookie].
  ///
  ///The platform default is `true` on both platforms, which is why this returns `bool?` rather than
  ///`bool`: `null` means *nothing could be read*, and reporting `false` there would claim cookies
  ///are being rejected when in fact nothing was measured — the opposite of the default.
  ///
  ///`null` has two causes, one per platform. On Android the cookie store could not be resolved:
  ///no WebView provider is installed, or a `profileName` was given that does not exist. On **iOS
  ///below 17.0** there is no cookie policy to read at all, since
  ///`WKHTTPCookieStore.getCookiePolicy` does not exist there — an integration test asserts that on
  ///an iOS 16.4 simulator, because a guard that collapses to `false` is invisible on any simulator
  ///at or above the floor.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.isAcceptCookieEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'CookieManager.acceptCookie',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/CookieManager#acceptCookie()',
      ),
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.getCookiePolicy',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/4133726-getcookiepolicy',
        available: '17.0',
        note:
            'Returns `null` below iOS 17.0, where there is no policy to read.',
      ),
    ],
  )
  Future<bool?> isAcceptCookieEnabled({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      '${PlatformCookieManagerMethod.isAcceptCookieEnabled.name} is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.cookieStoreObserver}
  ///The observer currently registered with [setCookieStoreObserver], or `null` if there is none.
  ///
  ///Answers `null` on any platform that cannot register one — which is every platform except iOS,
  ///where [setCookieStoreObserver] throws instead of doing nothing. That is not the same as "the
  ///observer was lost": there was never anything to lose.
  ///
  ///There is **one observer per app, not one per instance**: the cookie store is a single
  ///process-wide object, so setting an observer on any [PlatformCookieManager] replaces the
  ///observer every other one reports here.
  ///{@endtemplate}
  CookieStoreObserver? get cookieStoreObserver => null;

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.setCookieStoreObserver}
  ///Registers an [observer] that is notified whenever the cookie store changes, or removes the
  ///current one when [observer] is `null`.
  ///
  ///This is the alternative to polling [getAllCookies] on a timer, which is the only thing a
  ///caller could do before.
  ///
  ///**The notification carries no payload**, deliberately: the platform's own callback carries
  ///none either — it says *that* the store changed, not what changed. To find out, read the store
  ///again with [getAllCookies] or [getCookies] from inside the callback. Nothing is diffed for
  ///you, and nothing is fetched on your behalf, because doing so would put an unasked-for read on
  ///every cookie write in the app.
  ///
  ///**Writes made through this class count as changes.** Measured on iOS 17.5 and 26.5: one
  ///[setCookie] fires it once, three in a row fire it three times — nothing is coalesced — and
  ///[deleteAllCookies] fires it once. A pure read such as [getAllCookies] fires it not at all. So
  ///a callback that re-reads the store will not loop, but a callback that *writes* to it will.
  ///
  ///**It observes the default cookie store only** — the same store every other method on this
  ///class operates on. A `WKWebView` running on a non-persistent (incognito) data store has its
  ///own cookie store and does not report through here.
  ///
  ///The native observer is registered only while an observer is set, so an app that never calls
  ///this pays nothing, and it is removed when the plugin is disposed.
  ///
  ///**There is one observer for the whole app.** Calling this a second time — on this object or on
  ///any other [PlatformCookieManager] — replaces the first, it does not add a second listener. The
  ///store is process-wide, so an observer cannot belong to one instance.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManager.setCookieStoreObserver.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKHTTPCookieStore.addObserver',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2915464-addobserver',
        available: '11.0',
        note:
            'Android has no counterpart: `android.webkit.CookieManager` exposes no change notification.',
      ),
    ],
  )
  Future<void> setCookieStoreObserver(CookieStoreObserver? observer) {
    throw UnimplementedError(
      '${PlatformCookieManagerMethod.setCookieStoreObserver.name} is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformCookieManagerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}

///{@template flutter_inappwebview_platform_interface.CookieStoreObserver}
///Class used by clients to be notified of cookie store changes.
///
///Register one with [PlatformCookieManager.setCookieStoreObserver]. It is modelled as a class
///rather than a bare callback because the platform models it as a protocol, which may grow — the
///same reason [ServiceWorkerClient] is a class with one field.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.CookieStoreObserver.supported_platforms}
@SupportedPlatforms(
  platforms: [
    IOSPlatform(
      apiName: 'WKHTTPCookieStoreObserver',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkhttpcookiestoreobserver',
      available: '11.0',
    ),
  ],
)
class CookieStoreObserver {
  ///{@template flutter_inappwebview_platform_interface.CookieStoreObserver.onCookiesChanged}
  ///Notifies that the cookies in the store changed.
  ///
  ///It takes no arguments and there is nothing missing: the platform callback reports the *fact*
  ///of a change and nothing else. Read the store from inside this callback if you need the new
  ///state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.CookieStoreObserver.onCookiesChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: 'WKHTTPCookieStoreObserver.cookiesDidChangeInCookieStore',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkhttpcookiestoreobserver/2915463-cookiesdidchange',
        available: '11.0',
      ),
    ],
  )
  final void Function()? onCookiesChanged;

  CookieStoreObserver({this.onCookiesChanged});

  ///{@template flutter_inappwebview_platform_interface.CookieStoreObserver.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _CookieStoreObserverClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.CookieStoreObserver.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(
    CookieStoreObserverProperty property, {
    TargetPlatform? platform,
  }) => _CookieStoreObserverPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
