import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/service_worker.g.dart';

/// Object specifying creation parameters for creating a [AndroidServiceWorkerController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformServiceWorkerControllerCreationParams] for
/// more information.
@immutable
class AndroidServiceWorkerControllerCreationParams
    extends PlatformServiceWorkerControllerCreationParams {
  /// Creates a new [AndroidServiceWorkerControllerCreationParams] instance.
  const AndroidServiceWorkerControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformServiceWorkerControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidServiceWorkerControllerCreationParams] instance based on [PlatformServiceWorkerControllerCreationParams].
  factory AndroidServiceWorkerControllerCreationParams.fromPlatformServiceWorkerControllerCreationParams(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    return AndroidServiceWorkerControllerCreationParams(params);
  }
}

/// Receives [ServiceWorkerFlutterApi] events and answers them from the registered client.
///
/// Stateless on purpose: it reads the **static** client, so it does not matter which controller
/// instance registered it last — the property the old per-instance `_handleMethod` had to be made
/// static to get (see [AndroidServiceWorkerController._serviceWorkerClient]). Every construction
/// re-registers one, as every construction used to re-attach the method-call handler.
class _ServiceWorkerFlutterApiImpl implements ServiceWorkerFlutterApi {
  const _ServiceWorkerFlutterApiImpl();

  @override
  Future<WebResourceResponseData?> shouldInterceptRequest(
    WebResourceRequestData request,
  ) async {
    final handler = AndroidServiceWorkerController
        ._serviceWorkerClient
        ?.shouldInterceptRequest;
    if (handler == null) {
      // "Not handled": the platform lets the request go to the network, as it did when the old
      // handler fell through to `return null`.
      return null;
    }
    final response = await handler(
      WebResourceRequest(
        url: WebUri(request.url),
        headers: request.headers,
        isRedirect: request.isRedirect,
        hasGesture: request.hasGesture,
        isForMainFrame: request.isForMainFrame,
        method: request.method,
      ),
    );
    if (response == null) {
      return null;
    }
    return WebResourceResponseData(
      contentType: response.contentType,
      contentEncoding: response.contentEncoding,
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
      headers: response.headers,
      data: response.data,
      cookies: response.cookies,
    );
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
///
/// Transport is Pigeon-generated ([ServiceWorkerHostApi] / [ServiceWorkerFlutterApi]) rather than a
/// hand-written `MethodChannel`. The public API is unchanged.
///
/// `implements Disposable` explicitly because it used to arrive through the `ChannelController`
/// mixin, which is gone. Unlike the pull-to-refresh, find-interaction and print-job controllers,
/// `PlatformServiceWorkerController` does not implement `Disposable` itself, so dropping the mixin
/// alone would have quietly removed the type from this class's public surface.
class AndroidServiceWorkerController extends PlatformServiceWorkerController
    implements Disposable {
  /// Creates a new [AndroidServiceWorkerController].
  AndroidServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) : super.implementation(
        params is AndroidServiceWorkerControllerCreationParams
            ? params
            : AndroidServiceWorkerControllerCreationParams.fromPlatformServiceWorkerControllerCreationParams(
                params,
              ),
      ) {
    ServiceWorkerFlutterApi.setUp(const _ServiceWorkerFlutterApiImpl());
  }

  factory AndroidServiceWorkerController.static() {
    return instance();
  }

  static AndroidServiceWorkerController? _instance;

  ///Gets the [AndroidServiceWorkerController] shared instance.
  static AndroidServiceWorkerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidServiceWorkerController _init() {
    _instance = AndroidServiceWorkerController(
      AndroidServiceWorkerControllerCreationParams(
        const PlatformServiceWorkerControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Process-wide, like the native side: one channel, not per instance.
  final ServiceWorkerHostApi _hostApi = ServiceWorkerHostApi();

  /// Deliberately `static`, and it is not a shortcut — the same reasoning as
  /// `IOSCookieManager._cookieStoreObserver`.
  ///
  /// `createPlatformServiceWorkerController` returns a **new**
  /// [AndroidServiceWorkerController] on every call — which is what the public
  /// `ServiceWorkerController()` constructor does — yet every one of them registers the event
  /// handler for the same channel, where the last one constructed silently replaces the previous
  /// one. Held per instance, a client registered through [setServiceWorkerClient] would stop being
  /// consulted the moment anything constructed a second controller, and `shouldInterceptRequest`
  /// would simply stop firing with no error anywhere.
  ///
  /// Holding it statically also matches the platform: `ServiceWorkerControllerCompat.getInstance()`
  /// is process-wide and there is one native `ServiceWorkerClientCompat` registration for it, so
  /// every [AndroidServiceWorkerController] necessarily sees the same one.
  static ServiceWorkerClient? _serviceWorkerClient;

  @override
  ServiceWorkerClient? get serviceWorkerClient => _serviceWorkerClient;

  @override
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) async {
    await _hostApi.setServiceWorkerClient(value == null);
    _serviceWorkerClient = value;
  }

  // The three `?? false` below are gone with the nullable transport: the host methods return a
  // non-null `bool`, which the Kotlin side already computes as `settings?.get…() ?: false`.

  @override
  Future<bool> getAllowContentAccess({String? profileName}) =>
      _hostApi.getAllowContentAccess(profileName);

  @override
  Future<bool> getAllowFileAccess({String? profileName}) =>
      _hostApi.getAllowFileAccess(profileName);

  @override
  Future<bool> getBlockNetworkLoads({String? profileName}) =>
      _hostApi.getBlockNetworkLoads(profileName);

  @override
  Future<CacheMode?> getCacheMode({String? profileName}) async {
    return CacheMode.fromNativeValue(await _hostApi.getCacheMode(profileName));
  }

  @override
  Future<bool?> getIncludeCookiesOnShouldInterceptRequestEnabled({
    String? profileName,
  }) {
    // Deliberately nullable, unlike the neighbouring getters: null is a real answer here (feature
    // unsupported, or a named profile) and collapsing it would claim the switch is off when it is
    // actually unreachable. The schema types it `bool?` for the same reason.
    return _hostApi.getIncludeCookiesOnShouldInterceptRequestEnabled(
      profileName,
    );
  }

  // Every setter's `bool` answer is discarded, as it always has been. See the schema.

  @override
  Future<void> setIncludeCookiesOnShouldInterceptRequestEnabled(
    bool enabled, {
    String? profileName,
  }) async {
    await _hostApi.setIncludeCookiesOnShouldInterceptRequestEnabled(
      enabled,
      profileName,
    );
  }

  @override
  Future<void> setAllowContentAccess(bool allow, {String? profileName}) async {
    await _hostApi.setAllowContentAccess(allow, profileName);
  }

  @override
  Future<void> setAllowFileAccess(bool allow, {String? profileName}) async {
    await _hostApi.setAllowFileAccess(allow, profileName);
  }

  @override
  Future<void> setBlockNetworkLoads(bool flag, {String? profileName}) async {
    await _hostApi.setBlockNetworkLoads(flag, profileName);
  }

  @override
  Future<void> setCacheMode(CacheMode mode, {String? profileName}) async {
    // `toNativeValue()` is typed nullable only because the generated enum API has one shape for
    // every enum; every `CacheMode` value is platform-independent (`_internal(2, 2)` and so on), so
    // the null is unreachable. `!` fails loudly as the hand-written channel's Kotlin `!!` did,
    // rather than inventing a silent no-op — §182's reasoning.
    await _hostApi.setCacheMode(mode.toNativeValue()!, profileName);
  }

  @override
  void dispose() {
    // Deliberately empty, as before: the event handler and the client are process-wide, so one
    // controller's dispose must not unregister what every other controller relies on.
  }
}
