import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `CookieManager.allowFileSchemeCookies`, exposed as
/// `isFileSchemeCookiesAllowed`.
///
/// The native method is `static`, so the thing worth pinning is what this call must *not* carry:
/// no `profileName`. Every other method on this channel sends one — if a future edit adds it back
/// out of symmetry, it would imply a per-profile value that the platform does not have.
///
/// Since §168 the schema declares `isFileSchemeCookiesAllowed()` with no parameters, so the
/// asymmetry is enforced by the generated signature on both sides rather than by this test alone.
/// The test still earns its place: it pins that the call goes out **argument-less** (Pigeon sends a
/// null message body for a no-parameter method), which is the observable form of "no profile
/// scope", and it keeps the `bool?` null distinct from `false`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const fileSchemeChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.isFileSchemeCookiesAllowed';

  late AndroidCookieManager cookieManager;
  Object? reply;
  var messageWasNull = false;

  setUp(() {
    reply = false;
    messageWasNull = false;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(fileSchemeChannel, (message) async {
          messageWasNull = message == null;
          return codec.encodeMessage(<Object?>[reply]);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(fileSchemeChannel, null);
  });

  group('AndroidCookieManager.isFileSchemeCookiesAllowed', () {
    test('sends no arguments at all -- no profileName', () async {
      await cookieManager.isFileSchemeCookiesAllowed();

      // The native method is static: there is no instance and no profile to scope to. A
      // no-parameter Pigeon method sends a null body, so anything else here would mean an argument
      // had been added.
      expect(messageWasNull, isTrue);
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
