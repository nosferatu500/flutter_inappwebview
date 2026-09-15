import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the eighth channel migrated to Pigeon (§168, `cookie_manager`), in the
/// shape §156 established and §157/§160-§163/§165 reused.
///
/// The per-feature files next to this one (`cookie_manager_accept_test.dart`,
/// `..._flush_test.dart`, `..._has_cookies_test.dart`, `..._file_scheme_test.dart`,
/// `..._profile_test.dart`, `..._set_cookies_test.dart`) predate the migration and were converted
/// in place, so they still own the switch, the flush contract, the `bool?` trio and the plural
/// write. This file covers what none of them reach: the **read** path's type conversion and the two
/// delete methods.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.';
  const getCookiesChannel = '${prefix}getCookies';
  const setCookieChannel = '${prefix}setCookie';
  const deleteCookieChannel = '${prefix}deleteCookie';
  const deleteCookiesChannel = '${prefix}deleteCookies';
  const deleteAllChannel = '${prefix}deleteAllCookies';
  const removeSessionChannel = '${prefix}removeSessionCookies';

  const allChannels = [
    getCookiesChannel,
    setCookieChannel,
    deleteCookieChannel,
    deleteCookiesChannel,
    deleteAllChannel,
    removeSessionChannel,
  ];

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[
            replies.containsKey(channel) ? replies[channel] : true,
          ]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    replies[getCookiesChannel] = <Object?>[];
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    for (final c in allChannels) {
      install(c);
    }
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in allChannels) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  group('getCookies read path', () {
    test('rebuilds every field of the public Cookie', () async {
      replies[getCookiesChannel] = <Object?>[
        CookieData(
          name: 'session',
          value: 'abc',
          expiresDate: 1750000000000,
          domain: '.example.com',
          sameSite: 'Lax',
          isSecure: true,
          isHttpOnly: false,
          path: '/p',
        ),
      ];

      final cookies = await cookieManager.getCookies(
        url: WebUri('https://example.com'),
      );

      expect(cookies.length, 1);
      final cookie = cookies.single;
      expect(cookie.name, 'session');
      expect(cookie.value, 'abc');
      expect(cookie.expiresDate, 1750000000000);
      expect(cookie.domain, '.example.com');
      expect(cookie.sameSite, HTTPCookieSameSitePolicy.LAX);
      expect(cookie.isSecure, isTrue);
      expect(cookie.isHttpOnly, isFalse);
      expect(cookie.path, '/p');
    });

    test('isSessionOnly is null, because Android never sends it', () async {
      // 🚨 The wire finding behind this schema. The hand-written Kotlin seeded `"isSessionOnly" to
      // null` into every cookie map and then never assigned it on either branch — grep over the
      // whole module found that line to be the only occurrence — so Android has always answered
      // null here. The field is therefore absent from `CookieData` entirely, and this pins that the
      // public object still reports null rather than, say, false.
      replies[getCookiesChannel] = <Object?>[CookieData(name: 'a', value: '1')];

      final cookie = (await cookieManager.getCookies(
        url: WebUri('https://example.com'),
      )).single;

      expect(cookie.isSessionOnly, isNull);
    });

    test('a cookie with only name and value survives the conversion', () async {
      // The no-GET_COOKIE_INFO path: the platform returns a bare `name=value` list and there are no
      // attributes to parse, so everything else is null. An empty value is a real state (RFC 6265
      // §4.1.1), not a missing one.
      replies[getCookiesChannel] = <Object?>[CookieData(name: 'a', value: '')];

      final cookie = (await cookieManager.getCookies(
        url: WebUri('https://example.com'),
      )).single;

      expect(cookie.name, 'a');
      expect(cookie.value, '');
      expect(cookie.expiresDate, isNull);
      expect(cookie.domain, isNull);
      expect(cookie.sameSite, isNull);
      expect(cookie.isSecure, isNull);
      expect(cookie.isHttpOnly, isNull);
      expect(cookie.path, isNull);
    });

    test('an unrecognised sameSite becomes null, not a throw', () async {
      replies[getCookiesChannel] = <Object?>[
        CookieData(name: 'a', value: '1', sameSite: 'Nonsense'),
      ];

      final cookie = (await cookieManager.getCookies(
        url: WebUri('https://example.com'),
      )).single;

      expect(cookie.sameSite, isNull);
    });

    test('sends url and profileName, in that order', () async {
      await cookieManager.getCookies(
        url: WebUri('https://example.com/a'),
        profileName: 'p',
      );

      expect(received[getCookiesChannel], <Object?>[
        'https://example.com/a',
        'p',
      ]);
    });

    test('getCookie filters by name over the same channel call', () async {
      replies[getCookiesChannel] = <Object?>[
        CookieData(name: 'a', value: '1'),
        CookieData(name: 'b', value: '2'),
      ];

      final found = await cookieManager.getCookie(
        url: WebUri('https://example.com'),
        name: 'b',
      );

      expect(found?.name, 'b');
      expect(found?.value, '2');
      // There is no per-name lookup on the channel because `CookieManager` itself has none.
      expect(received.keys, [getCookiesChannel]);
    });

    test('getCookie answers null when the name is absent', () async {
      replies[getCookiesChannel] = <Object?>[CookieData(name: 'a', value: '1')];

      expect(
        await cookieManager.getCookie(
          url: WebUri('https://example.com'),
          name: 'missing',
        ),
        isNull,
      );
    });
  });

  group('setCookie write path', () {
    test('carries every field into the wire type', () async {
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
        sameSite: HTTPCookieSameSitePolicy.STRICT,
        profileName: 'p',
      );

      final sent = received[setCookieChannel]![0] as CookieToSetData;
      expect(sent.url, 'https://example.com');
      expect(sent.name, 'a');
      expect(sent.value, '1');
      expect(sent.path, '/p');
      expect(sent.domain, '.example.com');
      expect(sent.expiresDate, 1750000000000);
      expect(sent.maxAge, 60);
      expect(sent.isSecure, isTrue);
      expect(sent.isHttpOnly, isFalse);
      // The platform's own spelling, not the Dart enum's name.
      expect(sent.sameSite, 'Strict');
      expect(received[setCookieChannel]![1], 'p');
    });

    test('an empty value is allowed and reaches the wire', () async {
      // 🚨 Regression test for a bug §168 introduced and the *device* caught: the migration added
      // an `assert(value.isNotEmpty)` that the hand-written version never had, which made this
      // throw in debug. RFC 6265 §4.1.1 permits an empty value, `set, get, delete` writes one, and
      // `CookieData.value` documents it for the read direction — so forbidding it on the write
      // side contradicted the same change's own schema doc.
      //
      // Every one of the 45 Dart tests passed against the broken code because none of them set an
      // empty value. This is the cheap check that would have.
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'a',
        value: '',
      );

      expect((received[setCookieChannel]![0] as CookieToSetData).value, '');
    });

    test('path defaults to / rather than crossing as null', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'a',
        value: '1',
      );

      // `path` is non-null in the schema because the public API defaults it; a null here would be
      // a protocol violation rather than "no path".
      expect((received[setCookieChannel]![0] as CookieToSetData).path, '/');
    });
  });

  group('delete path', () {
    test('deleteCookie sends url, name, domain, path, profileName', () async {
      await cookieManager.deleteCookie(
        url: WebUri('https://example.com'),
        name: 'a',
        domain: '.example.com',
        path: '/p',
        profileName: 'p',
      );

      expect(received[deleteCookieChannel], <Object?>[
        'https://example.com',
        'a',
        '.example.com',
        '/p',
        'p',
      ]);
    });

    test('deleteCookies sends url, domain, path, profileName', () async {
      // Note the absent `name`: this is the plural, and it expires whatever the store holds for the
      // url rather than one named cookie.
      await cookieManager.deleteCookies(
        url: WebUri('https://example.com'),
        domain: '.example.com',
        path: '/p',
        profileName: 'p',
      );

      expect(received[deleteCookiesChannel], <Object?>[
        'https://example.com',
        '.example.com',
        '/p',
        'p',
      ]);
    });

    test(
      'deleteAllCookies and removeSessionCookies take only a profile',
      () async {
        await cookieManager.deleteAllCookies(profileName: 'p');
        await cookieManager.removeSessionCookies();

        expect(received[deleteAllChannel], <Object?>['p']);
        expect(received[removeSessionChannel], <Object?>[null]);
      },
    );

    test('a false from the host is returned, not swallowed', () async {
      // The null-manager branch: no such profile, or no MULTI_PROFILE. §167 pins the same answer on
      // a device.
      replies[deleteAllChannel] = false;
      expect(
        await cookieManager.deleteAllCookies(profileName: 'nope'),
        isFalse,
      );
    });
  });

  group('error propagation', () {
    test('a host error surfaces with its code and message', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(deleteAllChannel, (message) async {
            return codec.encodeMessage(<Object?>[
              'ERR_CODE',
              'the message',
              'the details',
            ]);
          });

      await expectLater(
        cookieManager.deleteAllCookies(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'ERR_CODE')
              .having((e) => e.message, 'message', 'the message'),
        ),
      );
    });
  });
}
