import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `CookieManager.hasCookies`.
///
/// The store-wide probe sends nothing but `profileName`, so the only things that can break at
/// runtime are the argument list and the `null` handling — and the second is the one worth pinning:
/// `null` ("the store could not be read") must not collapse into `false` ("the store is empty"),
/// because a caller that skips a logout-time cookie clear on the strength of a `false` would skip
/// it for a store that does hold cookies.
///
/// Transport is Pigeon since §168. The "no url is sent" assertion below used to be spelled as
/// "the argument map has no `url` key"; positionally it is simply that the call carries **one**
/// argument. `hasCookies` is declared `bool?` in the schema, so the null the third test pins is now
/// part of the wire contract rather than a Dart-side convention.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const hasCookiesChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.hasCookies';

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};
  Object? reply;

  setUp(() {
    received.clear();
    reply = true;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hasCookiesChannel, (message) async {
          received[hasCookiesChannel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[reply]);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hasCookiesChannel, null);
  });

  group('AndroidCookieManager.hasCookies', () {
    test('sends nothing but profileName, and no url', () async {
      await cookieManager.hasCookies();

      // Exactly one argument. Store-wide, not per-origin: sending a url would imply the wrong
      // question, and a second positional argument is the only way that could happen now.
      expect(received[hasCookiesChannel], <Object?>[null]);
    });

    test('carries profileName when scoped', () async {
      await cookieManager.hasCookies(profileName: 'signed_in');
      expect(received[hasCookiesChannel], <Object?>['signed_in']);
    });

    test('returns what the native side read', () async {
      reply = true;
      expect(await cookieManager.hasCookies(), isTrue);

      reply = false;
      expect(await cookieManager.hasCookies(), isFalse);
    });

    test('null survives instead of becoming false', () async {
      // Kotlin sends null when the cookie store cannot be resolved. "No cookies" and "could not
      // look" are different answers and collapsing them would merge them. Pinned on the device too
      // since §167 (`an unknown profile resolves to no store`).
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
