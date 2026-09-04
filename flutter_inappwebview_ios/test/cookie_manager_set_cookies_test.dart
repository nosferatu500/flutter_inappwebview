import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the plural `setCookies` (§129) on iOS.
///
/// The Swift side reads `expiresDate` with `as? String` and `maxAge` with `as? Int64`, and runs
/// one `makeCookie` for both the singular and the plural call. The generated
/// `CookieToSet.toMap()` would send `expiresDate` as an `int`, where `as? String` yields nil and
/// the cookie silently becomes a session cookie — no error, no log, and only on the plural path.
/// Nothing in this repo compiles Swift and Dart together, so only an assertion here sees it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late IOSCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    cookieManager = IOSCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          if (call.method == 'setCookies') return <Object?>[true];
          // `getSystemVersion` is consulted by the singular call's dead JS branch.
          if (call.method == 'getSystemVersion') return '26.5';
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            'dev.nosferatu500.inappwebview/inappwebview_platformutil',
          ),
          (MethodCall call) async =>
              call.method == 'getSystemVersion' ? '26.5' : null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;
  List<Object?> cookiesOf(MethodCall call) =>
      argsOf(call)['cookies'] as List<Object?>;

  group('IOSCookieManager.setCookies wire shape', () {
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

      final setCalls = calls.where((c) => c.method == 'setCookies').toList();
      expect(setCalls.length, 1);
      expect(cookiesOf(setCalls.single).length, 2);
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

      final singular = argsOf(calls.firstWhere((c) => c.method == 'setCookie'));
      final plural =
          cookiesOf(calls.firstWhere((c) => c.method == 'setCookies')).single
              as Map<Object?, Object?>;

      expect(plural, singular);
    });

    test('sends expiresDate as a String, not an int', () async {
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

      final cookie =
          cookiesOf(calls.firstWhere((c) => c.method == 'setCookies')).single
              as Map<Object?, Object?>;
      expect(cookie['expiresDate'], '1750000000000');
      expect(cookie['expiresDate'], isA<String>());
      // `as? Int64` on the Swift side, so this one must stay a number.
      expect(cookie['maxAge'], isNull);
    });

    test('does not send profileName, which iOS has no concept of', () async {
      // Accepted in the signature so the platform interface matches, and dropped here — the same
      // treatment every other method on this class gives it (§29).
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
      final args = argsOf(calls.firstWhere((c) => c.method == 'setCookies'));
      expect(args.containsKey('profileName'), isFalse);
    });

    test('an empty list never reaches the channel', () async {
      expect(await cookieManager.setCookies(cookies: []), isEmpty);
      expect(calls.where((c) => c.method == 'setCookies'), isEmpty);
    });
  });
}
