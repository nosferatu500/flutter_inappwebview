import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every manager below attaches its method-call handler to a **constant**
/// `MethodChannel` name. `setMethodCallHandler` is last-writer-wins per channel
/// name and tells the loser nothing, so if a factory mints a new object each
/// call, the previously-registered one silently stops receiving calls.
///
/// That is not hypothetical: it is how `ServiceWorkerController.shouldInterceptRequest`
/// broke (§141), and why `AndroidServiceWorkerController._serviceWorkerClient`
/// and `IOSCookieManager`'s observer are `static` — workarounds that move the
/// *state* process-wide so it stops mattering which object owns the handler.
///
/// §155 made the factories return one instance instead, which fixes the
/// ordinary path. This pins that.
///
/// WHAT THIS DOES NOT CLAIM. The public constructors are still public, so a
/// caller can create a second instance and take the handler. §141's regression
/// test exercises exactly that and must keep passing — the `static` fields are
/// what make it survivable. Closing that hole means private constructors, a
/// breaking change to this package, and is deliberately not done here.
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
          reason:
              '${entry.key}: the factory returned two different objects, so the '
              'second has taken the method-call handler from the first.',
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
