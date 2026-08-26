import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `CookieManager.allowFileSchemeCookies`, exposed as
/// `isFileSchemeCookiesAllowed`.
///
/// The native method is `static`, so the thing worth pinning is what this call must *not* carry:
/// no `profileName`. Every other method on this channel sends one, and the Kotlin handler for this
/// one does not read it — if a future edit adds it back out of symmetry, it would imply a
/// per-profile value that the platform does not have.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late AndroidCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = false;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AndroidCookieManager.isFileSchemeCookiesAllowed', () {
    test('sends an empty argument map -- no profileName', () async {
      await cookieManager.isFileSchemeCookiesAllowed();

      expect(calls.single.method, 'isFileSchemeCookiesAllowed');
      final args = calls.single.arguments as Map<Object?, Object?>;
      // The native method is static: there is no instance and no profile to scope to.
      expect(args, isEmpty);
    });

    test('returns what the native side read', () async {
      reply = false;
      expect(await cookieManager.isFileSchemeCookiesAllowed(), isFalse);

      reply = true;
      expect(await cookieManager.isFileSchemeCookiesAllowed(), isTrue);
    });

    test('null survives instead of becoming false', () async {
      // Kotlin sends null when no WebView provider could be resolved. "Not allowed" and "could not
      // ask" are different answers.
      reply = null;
      expect(await cookieManager.isFileSchemeCookiesAllowed(), isNull);
    });

    test('is reported as Android-only', () {
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.isFileSchemeCookiesAllowed,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.isFileSchemeCookiesAllowed,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
