import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// iOS half of the constant-channel singleton gate. See the Android file for
/// the full reasoning; in short: these four managers attach their method-call
/// handler to a **constant** `MethodChannel` name, and `setMethodCallHandler`
/// is last-writer-wins per name with no notice to the loser, so a factory that
/// mints a new object per call silently unhooks the previous one.
///
/// `IOSCookieManager` is the class that made this concrete — its cookie-store
/// observer is `static` precisely because `.static()` and
/// `createPlatformCookieManager` used to produce different objects on one
/// channel (§112).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = IOSInAppWebViewPlatform();

  final factories = <String, Object Function()>{
    'CookieManager': () => platform.createPlatformCookieManager(
      const PlatformCookieManagerCreationParams(),
    ),
    'HttpAuthCredentialDatabase': () =>
        platform.createPlatformHttpAuthCredentialDatabase(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        ),
    'ProxyController': () => platform.createPlatformProxyController(
      const PlatformProxyControllerCreationParams(),
    ),
    'WebStorageManager': () => platform.createPlatformWebStorageManager(
      const PlatformWebStorageManagerCreationParams(),
    ),
  };

  test('all four constant-channel managers are covered', () {
    expect(factories, hasLength(4));
  });

  group('the factory returns one instance', () {
    for (final entry in factories.entries) {
      test(entry.key, () {
        expect(
          identical(entry.value(), entry.value()),
          isTrue,
          reason:
              '${entry.key}: the factory returned two different objects, so the '
              'second has taken the method-call handler from the first.',
        );
      });
    }
  });

  test('the static accessor resolves to that same instance', () {
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
        platform.createPlatformWebStorageManager(
          const PlatformWebStorageManagerCreationParams(),
        ),
        platform.createPlatformWebStorageManagerStatic(),
      ),
      isTrue,
    );
  });
}
