import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/cookie_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `CookieManager.flush`'s return contract (§137, re-pinned for Pigeon in §168).
///
/// `flush` used to return `Future<void>` while the Kotlin side already answered `true` on success
/// and `false` when the cookie store could not be resolved — so the one bit that mattered was
/// computed natively and then discarded in Dart. That also made the class doc false: it promises a
/// profile-scoped call "reports failure", which a `void` cannot do.
///
/// 🚨 **The `?? false` is gone, and that is a deliberate behaviour change, not an oversight.** The
/// hand-written version read `invokeMethod<bool>('flush', args) ?? false`, and §137's note explained
/// that the coalesce was load-bearing: a `MethodChannel` answers `null` both when the native side
/// replies null *and when there is no handler at all*, so without it a flush on a disposed or
/// unregistered channel would throw a cast error instead of reporting failure.
///
/// Pigeon types this method `bool`, so there is no null to coalesce — a host that answers null is a
/// protocol violation and raises, and a missing handler raises too. The test below pins that. This
/// is the better contract for exactly the reason P0b.9 existed: a `flush` that silently answers
/// "false, nothing was written" when the channel is not even connected is indistinguishable from a
/// real failure, and `flush`'s whole history here is about not swallowing that distinction.
/// `isAcceptCookieEnabled` on this same class is genuinely `bool?` and keeps its null, so the
/// choice remains per-method and is still worth pinning.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CookieManagerHostApi.pigeonChannelCodec;
  const flushChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.CookieManagerHostApi.flush';

  late AndroidCookieManager cookieManager;
  final Map<String, List<Object?>?> received = {};
  Object? nativeReply;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(flushChannel, (message) async {
          received[flushChannel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[nativeReply]);
        });
  }

  setUp(() {
    received.clear();
    nativeReply = true;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    install();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(flushChannel, null);
  });

  group('CookieManager.flush return value', () {
    test('a native true is returned to the caller', () async {
      nativeReply = true;
      expect(await cookieManager.flush(), true);
      expect(received[flushChannel], <Object?>[null]);
    });

    test('a native false is returned, not swallowed', () async {
      // The Kotlin sends this when `getCookieManager(profileName)` resolves to null — no profile
      // of that name, or no MULTI_PROFILE support. Nothing was written, and before §137 the
      // caller had no way to learn that.
      nativeReply = false;
      expect(await cookieManager.flush(profileName: 'nope'), false);
    });

    test('a null reply raises rather than silently reading as false', () async {
      // The inverse of the pre-Pigeon assertion, and deliberately so — see this file's header.
      // `flush` is declared `bool`, so null is off-contract and surfaces instead of being folded
      // into the same answer the resolvable-store-but-nothing-written case produces.
      nativeReply = null;
      await expectLater(
        cookieManager.flush(),
        throwsA(isA<PlatformException>()),
      );
    });

    test('flush sends profileName as its only argument', () async {
      await cookieManager.flush(profileName: 'p');
      expect(received[flushChannel], <Object?>['p']);
    });
  });
}
