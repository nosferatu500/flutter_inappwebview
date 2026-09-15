import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument on the cookie-manager channel.
///
/// The Kotlin side treats null as "the default cookie store". So a dropped `profileName` does not
/// fail — every call silently lands on the **default** profile, which for a WebView running on
/// another profile means cookies written nowhere useful and cookies read that do not exist.
///
/// Before §168 this was a *key* in an argument map and could be renamed to nothing; it is now a
/// positional parameter on a generated signature, so the rename failure mode is gone. What remains
/// worth pinning — and is why this file survived the migration rather than being folded into the
/// boundary test — is that **every method that accepts a profile actually forwards the one it was
/// given**. That is still invisible to the compiler: passing `null` instead of the caller's value
/// type-checks perfectly.
///
/// §167 added the device half of this (`cookies are scoped to their profile`); this is the cheap
/// half that runs on every `flutter test`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.';

  // Every method that takes a profile, with the reply shape its caller accepts.
  const channels = <String, Object?>{
    '${prefix}setCookie': true,
    '${prefix}setCookies': <Object?>[true],
    '${prefix}getCookies': <Object?>[],
    '${prefix}deleteCookie': true,
    '${prefix}deleteCookies': true,
    '${prefix}deleteAllCookies': true,
    '${prefix}removeSessionCookies': true,
    '${prefix}flush': true,
    '${prefix}hasCookies': true,
    '${prefix}isAcceptCookieEnabled': true,
    '${prefix}setAcceptCookie': true,
  };

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};

  setUp(() {
    received.clear();
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    channels.forEach((channel, reply) {
      messenger.setMockMessageHandler(channel, (message) async {
        received[channel] = message == null
            ? null
            : codec.decodeMessage(message) as List<Object?>;
        return codec.encodeMessage(<Object?>[reply]);
      });
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in channels.keys) {
      messenger.setMockMessageHandler(channel, null);
    }
  });

  group('AndroidCookieManager profileName', () {
    test('is sent in the position the Android side reads', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'session',
        value: 'abc',
        profileName: 'signed_in',
      );

      expect(received['${prefix}setCookie']!.last, 'signed_in');
    });

    test('is null when not given, which means the default store', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'session',
        value: 'abc',
      );

      expect(received['${prefix}setCookie']!.last, isNull);
    });

    test('reaches every method that accepts it', () async {
      final url = WebUri('https://example.com');
      await cookieManager.setCookie(
        url: url,
        name: 'n',
        value: 'v',
        profileName: 'p',
      );
      await cookieManager.setCookies(
        cookies: [CookieToSet(url: url, name: 'n', value: 'v')],
        profileName: 'p',
      );
      await cookieManager.getCookies(url: url, profileName: 'p');
      await cookieManager.getCookie(url: url, name: 'n', profileName: 'p');
      await cookieManager.deleteCookie(url: url, name: 'n', profileName: 'p');
      await cookieManager.deleteCookies(url: url, profileName: 'p');
      await cookieManager.deleteAllCookies(profileName: 'p');
      await cookieManager.removeSessionCookies(profileName: 'p');
      await cookieManager.flush(profileName: 'p');
      await cookieManager.hasCookies(profileName: 'p');
      await cookieManager.isAcceptCookieEnabled(profileName: 'p');
      await cookieManager.setAcceptCookie(true, profileName: 'p');

      // Eleven channels, twelve calls: `getCookie` is implemented on top of `getCookies`, so it
      // reuses that channel rather than adding one.
      expect(received.keys.toSet(), channels.keys.toSet());

      // `profileName` is the **last** parameter on every one of these, whatever else they carry —
      // which is what makes a single assertion possible across methods taking one to five
      // arguments.
      received.forEach((channel, args) {
        expect(
          args!.last,
          'p',
          reason: '${channel.split('.').last} dropped profileName',
        );
      });
    });

    test('is not sent by isFileSchemeCookiesAllowed', () async {
      // The one method on this channel with no profile scope: the native call is static. Asserted
      // here as well as in its own file because this is the list a future edit would add it to.
      expect(
        channels.keys,
        isNot(contains('${prefix}isFileSchemeCookiesAllowed')),
      );
    });
  });
}
