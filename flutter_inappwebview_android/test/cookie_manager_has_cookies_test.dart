import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `CookieManager.hasCookies`.
///
/// The store-wide probe sends nothing but `profileName`, so the only things that can break at
/// runtime are the method name and the `null` handling — and the second is the one worth pinning:
/// `null` ("the store could not be read") must not collapse into `false` ("the store is empty"),
/// because a caller that skips a logout-time cookie clear on the strength of a `false` would skip
/// it for a store that does hold cookies.
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
    reply = true;
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

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidCookieManager.hasCookies', () {
    test('sends nothing but profileName, and no url', () async {
      await cookieManager.hasCookies();

      expect(calls.single.method, 'hasCookies');
      expect(argsOf(calls.single).containsKey('profileName'), isTrue);
      expect(argsOf(calls.single)['profileName'], isNull);
      // Store-wide, not per-origin: sending a url would imply the wrong question.
      expect(argsOf(calls.single).containsKey('url'), isFalse);
    });

    test('carries profileName when scoped', () async {
      await cookieManager.hasCookies(profileName: 'signed_in');
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });

    test('returns what the native side read', () async {
      reply = true;
      expect(await cookieManager.hasCookies(), isTrue);

      reply = false;
      expect(await cookieManager.hasCookies(), isFalse);
    });

    test('null survives instead of becoming false', () async {
      // Kotlin sends null when the cookie store cannot be resolved. "No cookies" and "could not
      // look" are different answers and a `?? false` here would merge them.
      reply = null;
      expect(await cookieManager.hasCookies(), isNull);
    });

    test('is reported as Android-only', () {
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.hasCookies,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.hasCookies,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
