import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that each process-wide manager's factory returns one instance (§155).
///
/// Why it mattered: these managers once attached their handlers to a **constant**
/// `MethodChannel` name, and `setMethodCallHandler` is last-writer-wins per name
/// and tells the loser nothing, so a factory minting a new object each call left
/// the previous one deaf. That is how `ServiceWorkerController.shouldInterceptRequest`
/// broke (§141).
///
/// Where it stands (re-measured §291): all ten are Pigeon now. Nine only call the
/// platform (a `HostApi`) and register no Dart-side handler at all, so a second
/// instance takes nothing from the first. `ServiceWorkerController` still
/// registers one, `ServiceWorkerFlutterApi.setUp`, on a constant channel, once
/// per construction and last writer wins, but that handler is stateless: it reads
/// the `static` `_serviceWorkerClient`, so whichever instance registered last
/// answers the same. The test stays as a guard: one instance per factory is still
/// the contract, and a manager that gains a Dart-side handler would bring the
/// hazard back.
///
/// WHAT THIS DOES NOT CLAIM. The public constructors are still public, so a
/// caller can create a second instance. §141's regression test exercises that
/// for `ServiceWorkerController` and must keep passing; the `static` client is
/// what makes it survivable. Closing that means private constructors, a breaking
/// change to this package, and is deliberately not done here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = AndroidInAppWebViewPlatform();

  /// Each entry builds the manager through the factory the app-facing package
  /// uses. Two calls must give the same object.
  final factories = <String, Object Function()>{
    'CookieManager': () => platform.createPlatformCookieManager(
      const PlatformCookieManagerCreationParams(),
    ),
    'GeolocationPermissions': () =>
        platform.createPlatformGeolocationPermissions(
          const PlatformGeolocationPermissionsCreationParams(),
        ),
    'HttpAuthCredentialDatabase': () =>
        platform.createPlatformHttpAuthCredentialDatabase(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        ),
    'ProcessGlobalConfig': () => platform.createPlatformProcessGlobalConfig(
      const PlatformProcessGlobalConfigCreationParams(),
    ),
    'ProfileStore': () => platform.createPlatformProfileStore(
      const PlatformProfileStoreCreationParams(),
    ),
    'ProxyController': () => platform.createPlatformProxyController(
      const PlatformProxyControllerCreationParams(),
    ),
    'ServiceWorkerController': () =>
        platform.createPlatformServiceWorkerController(
          const PlatformServiceWorkerControllerCreationParams(),
        ),
    'TracingController': () => platform.createPlatformTracingController(
      const PlatformTracingControllerCreationParams(),
    ),
    'WebStorageManager': () => platform.createPlatformWebStorageManager(
      const PlatformWebStorageManagerCreationParams(),
    ),
    'WebViewFeature': () => platform.createPlatformWebViewFeature(
      const PlatformWebViewFeatureCreationParams(),
    ),
  };

  test('all ten constant-channel managers are covered', () {
    // Guards against an entry being dropped from the map above, which would
    // silently shrink what the next test checks.
    expect(factories, hasLength(10));
  });

  group('the factory returns one instance', () {
    for (final entry in factories.entries) {
      test(entry.key, () {
        final first = entry.value();
        final second = entry.value();
        expect(
          identical(first, second),
          isTrue,
          reason: '${entry.key}: the factory returned two different objects.',
        );
      });
    }
  });

  test('the static accessor resolves to that same instance', () {
    // `.static()` used to be a *separate* singleton (`_staticValue`), so a
    // class could hold two live registrants without any caller asking for two.
    expect(
      identical(
        platform.createPlatformCookieManager(
          const PlatformCookieManagerCreationParams(),
        ),
        platform.createPlatformCookieManagerStatic(),
      ),
      isTrue,
    );
    expect(
      identical(
        platform.createPlatformProxyController(
          const PlatformProxyControllerCreationParams(),
        ),
        platform.createPlatformProxyControllerStatic(),
      ),
      isTrue,
    );
  });
}
