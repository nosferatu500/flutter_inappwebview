import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the plural `setCookies` (§129) on Android.
///
/// The device tests prove the cookies land. What they cannot see is that **every entry is spelled
/// exactly the way the singular `setCookie` spells it**, which is load-bearing: `MyCookieManager`
/// runs one `buildCookieValue` for both calls, and it reads `expiresDate` as a `String`. The
/// generated `CookieToSet.toMap()` would send it as an `int`, so a maintainer who replaces the
/// hand-written argument map with `toMap()` gets a null expiry on the platform side, silently and
/// only for the plural call. Nothing else in the repo can catch that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late AndroidCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];
  List<Object?> reply = <Object?>[];

  setUp(() {
    calls.clear();
    reply = <Object?>[true, true];
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          if (call.method == 'setCookies') return reply;
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;
  List<Object?> cookiesOf(MethodCall call) =>
      argsOf(call)['cookies'] as List<Object?>;

  group('AndroidCookieManager.setCookies wire shape', () {
    test('sends one channel call carrying every cookie', () async {
      await cookieManager.setCookies(
        cookies: [
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'a',
            value: '1',
          ),
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'b',
            value: '2',
          ),
        ],
      );

      // One call, not one per cookie — the single round trip is the entire point of the method.
      expect(calls.length, 1);
      expect(calls.single.method, 'setCookies');
      expect(cookiesOf(calls.single).length, 2);
    });

    test('spells every key the way the singular setCookie spells it', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'a',
        value: '1',
        path: '/p',
        domain: '.example.com',
        expiresDate: 1750000000000,
        maxAge: 60,
        isSecure: true,
        isHttpOnly: false,
        sameSite: HTTPCookieSameSitePolicy.LAX,
      );
      await cookieManager.setCookies(
        cookies: [
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'a',
            value: '1',
            path: '/p',
            domain: '.example.com',
            expiresDate: 1750000000000,
            maxAge: 60,
            isSecure: true,
            isHttpOnly: false,
            sameSite: HTTPCookieSameSitePolicy.LAX,
          ),
        ],
      );

      final singular = Map<Object?, Object?>.from(argsOf(calls.first))
        ..remove('profileName');
      final plural = cookiesOf(calls.last).single as Map<Object?, Object?>;

      // The comparison, rather than a list of individual expects: it stays true when a field is
      // added to either call, which is exactly when the two are most likely to drift.
      expect(plural, singular);
    });

    test('sends expiresDate as a String, not an int', () async {
      // The specific drift the test above would also catch, called out because it is the one the
      // generated `CookieToSet.toMap()` gets wrong.
      await cookieManager.setCookies(
        cookies: [
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'a',
            value: '1',
            expiresDate: 1750000000000,
          ),
        ],
      );

      final cookie = cookiesOf(calls.single).single as Map<Object?, Object?>;
      expect(cookie['expiresDate'], '1750000000000');
      expect(cookie['expiresDate'], isA<String>());
    });

    test('an empty list never reaches the channel', () async {
      expect(await cookieManager.setCookies(cookies: []), isEmpty);
      expect(calls, isEmpty);
    });

    test('fails the same way the singular call does with no handler', () async {
      // Written expecting `[false, false]` and corrected by the result: `invokeMethod` **throws**
      // MissingPluginException rather than answering null, so neither call's `??` fallback covers
      // a missing native handler — that only covers a null channel on a disposed manager. What
      // matters is that the plural does not invent a *different* failure mode from the singular,
      // so both are asserted here rather than the assumption being left in a comment.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      await expectLater(
        cookieManager.setCookies(
          cookies: [
            CookieToSet(
              url: WebUri('https://example.com'),
              name: 'a',
              value: '1',
            ),
          ],
        ),
        throwsA(isA<MissingPluginException>()),
      );
      await expectLater(
        cookieManager.setCookie(
          url: WebUri('https://example.com'),
          name: 'a',
          value: '1',
        ),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test('preserves the platform answers in order', () async {
      reply = <Object?>[true, false, true];

      final results = await cookieManager.setCookies(
        cookies: [
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'a',
            value: '1',
          ),
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'b',
            value: '2',
          ),
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'c',
            value: '3',
          ),
        ],
      );
      expect(results, [true, false, true]);
    });

    test('carries profileName, which is Android-only', () async {
      await cookieManager.setCookies(
        cookies: [
          CookieToSet(
            url: WebUri('https://example.com'),
            name: 'a',
            value: '1',
          ),
        ],
        profileName: 'signed_in',
      );
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });
  });
}
