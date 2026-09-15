import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the cookie master switch — `CookieManager.setAcceptCookie` /
/// `acceptCookie`.
///
/// Transport is Pigeon since §168; before that this file mocked the hand-written `MethodChannel`
/// and asserted **argument keys** (`call.argument("accept")`), because a renamed key arrived as
/// null and the Kotlin side then reported failure rather than crashing — a silently dead switch.
/// Pigeon removes that failure mode entirely: arguments are positional and the generated Kotlin
/// signature is `setAcceptCookie(accept: Boolean, profileName: String?)`, so a mismatch cannot
/// compile. What is still worth pinning, and is pinned below, is the **order and presence** of
/// those positional arguments and — unchanged in substance — the **null return**.
///
/// `isAcceptCookieEnabled` deliberately does *not* collapse null to false. The platform default is
/// `true`, so `null` (store unresolvable) and `false` (cookies actively rejected) are opposite
/// claims and must stay distinguishable; the schema types it `bool?` so the wire now carries that
/// distinction itself.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.';
  const setAcceptChannel = '${prefix}setAcceptCookie';
  const isAcceptEnabledChannel = '${prefix}isAcceptCookieEnabled';

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          // `containsKey`, not `?? true`: a deliberate null reply is the point of several tests
          // here and `??` would quietly turn it back into true.
          return codec.encodeMessage(<Object?>[
            replies.containsKey(channel) ? replies[channel] : true,
          ]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    install(setAcceptChannel);
    install(isAcceptEnabledChannel);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in [setAcceptChannel, isAcceptEnabledChannel]) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  group('AndroidCookieManager.setAcceptCookie', () {
    test('sends the accept flag as the first positional argument', () async {
      await cookieManager.setAcceptCookie(false);

      expect(received[setAcceptChannel], <Object?>[false, null]);
    });

    test('carries profileName like every other method here', () async {
      await cookieManager.setAcceptCookie(true, profileName: 'signed_in');

      expect(received[setAcceptChannel], <Object?>[true, 'signed_in']);
    });

    test('reports false when the native side could not apply it', () async {
      // Kotlin sends false when the cookie store cannot be resolved -- no WebView provider, or a
      // profileName that does not exist.
      replies[setAcceptChannel] = false;
      expect(await cookieManager.setAcceptCookie(true), isFalse);
    });
  });

  group('AndroidCookieManager.isAcceptCookieEnabled', () {
    test('sends profileName as its only argument', () async {
      await cookieManager.isAcceptCookieEnabled();

      // One argument, not two: the accept flag belongs to the setter only. Under the old map-based
      // wire this was spelled as "does not contain the key 'accept'".
      expect(received[isAcceptEnabledChannel], <Object?>[null]);
    });

    test('returns what the native side read', () async {
      replies[isAcceptEnabledChannel] = false;
      expect(await cookieManager.isAcceptCookieEnabled(), isFalse);

      replies[isAcceptEnabledChannel] = true;
      expect(await cookieManager.isAcceptCookieEnabled(), isTrue);
    });

    test('null survives instead of becoming false', () async {
      // This is the whole point of the bool? return type. Kotlin sends null when it could not
      // resolve the store; the platform default is true, so a `?? false` here would report
      // "cookies are rejected" for a state that was never measured.
      replies[isAcceptEnabledChannel] = null;
      expect(await cookieManager.isAcceptCookieEnabled(), isNull);
    });
  });

  group('PlatformCookieManagerMethod', () {
    // Was 'reports both methods as Android-only' until B9 gave them an iOS implementation
    // (`WKHTTPCookieStore.setCookiePolicy` / `getCookiePolicy`, iOS 17.0+). The iOS half of the
    // assertion is now the opposite; the Android half is unchanged and is what this test is
    // really for — Android must not lose support while iOS gains it.
    test('reports both methods on Android and iOS', () {
      for (final method in <PlatformCookieManagerMethod>[
        PlatformCookieManagerMethod.setAcceptCookie,
        PlatformCookieManagerMethod.isAcceptCookieEnabled,
      ]) {
        expect(
          cookieManager.isMethodSupported(
            method,
            platform: TargetPlatform.android,
          ),
          isTrue,
        );
        expect(
          cookieManager.isMethodSupported(method, platform: TargetPlatform.iOS),
          isTrue,
        );
      }
    });
  });
}
