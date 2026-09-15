import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the plural `setCookies` (§129) on Android.
///
/// The device tests prove the cookies land. What they cannot see is that **every entry is spelled
/// exactly the way the singular `setCookie` spells it** — `MyCookieManager` runs one
/// `buildCookieValue` for both calls, so a divergence silently changes what the platform stores for
/// one of them only.
///
/// 🚨 **§168 changed how that is guaranteed, and inverted one assertion.** Under the hand-written
/// channel the two calls were kept in step *by hand*: a Dart helper built the per-cookie map and
/// could not use `CookieToSet.toMap()`, because the generated map sent `expiresDate` as an `int`
/// while the singular call sent it as a **String**. Both natives read a String, so `toMap()` would
/// have produced a silently-null expiry on the plural path only.
///
/// Both calls now take the same Pigeon type, [CookieToSetData], so one spelling is enforced by the
/// generated signatures rather than by a comment — and `expiresDate` is a typed `int` in both
/// directions. The String round trip is gone, so the test that pinned it now pins its opposite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.';
  const setCookieChannel = '${prefix}setCookie';
  const setCookiesChannel = '${prefix}setCookies';

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};
  List<Object?> reply = <Object?>[];

  void install() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(setCookieChannel, (message) async {
      received[setCookieChannel] =
          codec.decodeMessage(message!) as List<Object?>;
      return codec.encodeMessage(<Object?>[true]);
    });
    messenger.setMockMessageHandler(setCookiesChannel, (message) async {
      received[setCookiesChannel] =
          codec.decodeMessage(message!) as List<Object?>;
      return codec.encodeMessage(<Object?>[reply]);
    });
  }

  setUp(() {
    received.clear();
    reply = <Object?>[true, true];
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    install();
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in [setCookieChannel, setCookiesChannel]) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  List<Object?> cookiesSent() =>
      received[setCookiesChannel]![0] as List<Object?>;

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
      expect(received.keys, [setCookiesChannel]);
      expect(cookiesSent().length, 2);
    });

    test('spells every field the way the singular setCookie spells it', () async {
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

      final singular = received[setCookieChannel]![0] as CookieToSetData;
      final plural = cookiesSent().single as CookieToSetData;

      // Compared field-by-field through the generated encoding rather than as a list of individual
      // expects: it stays true when a field is added to the schema, which is exactly when the two
      // paths are most likely to drift. Pigeon's Dart classes do not override `==`, so `encode()`
      // is what makes the comparison structural.
      expect(plural.encode(), singular.encode());
    });

    test('sends expiresDate as an int, not a String', () async {
      // The inverse of the pre-§168 assertion, and the reason the hand-written map existed. Now
      // that both paths share one typed field there is nothing left to keep in step by hand.
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

      final cookie = cookiesSent().single as CookieToSetData;
      expect(cookie.expiresDate, 1750000000000);
      expect(cookie.expiresDate, isA<int>());
    });

    test('an empty list never reaches the channel', () async {
      expect(await cookieManager.setCookies(cookies: []), isEmpty);
      expect(received, isEmpty);
    });

    test('fails the same way the singular call does with no handler', () async {
      // Pre-§168 this was `MissingPluginException`, from `invokeMethod`. Pigeon uses a
      // `BasicMessageChannel`, whose unhandled send resolves to a null reply rather than throwing,
      // and the generated code turns that into a `PlatformException(channel-error)`. The point of
      // the test is unchanged and is not the exception's name: the plural must not invent a
      // *different* failure mode from the singular, so both are asserted rather than one being
      // assumed to follow the other.
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      for (final c in [setCookieChannel, setCookiesChannel]) {
        messenger.setMockMessageHandler(c, null);
      }

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
        throwsA(isA<PlatformException>()),
      );
      await expectLater(
        cookieManager.setCookie(
          url: WebUri('https://example.com'),
          name: 'a',
          value: '1',
        ),
        throwsA(isA<PlatformException>()),
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
      expect(received[setCookiesChannel]!.last, 'signed_in');
    });
  });
}
