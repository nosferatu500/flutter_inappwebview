import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `CookieManager.flush`'s return contract (§137).
///
/// `flush` used to return `Future<void>` while the Kotlin side already answered `true` on success
/// and `false` when the cookie store could not be resolved — so the one bit that mattered was
/// computed natively and then discarded in Dart. That also made the class doc false: it promises a
/// profile-scoped call "reports failure", which a `void` cannot do.
///
/// The `?? false` matters and is not boilerplate. A `MethodChannel` answers `null` both when the
/// native side replies `null` and when there is **no handler at all**, so without it a `flush` on
/// a disposed or unregistered channel would return `null` and — under a `Future<bool>` signature —
/// throw a cast error rather than reporting failure. `isAcceptCookieEnabled` on this same class
/// deliberately does the opposite (no `?? false`, because its platform default is `true`), so the
/// choice is per-method and worth pinning.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late AndroidCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];
  Object? nativeReply;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return nativeReply;
        });
  }

  setUp(() {
    calls.clear();
    nativeReply = true;
    cookieManager = AndroidCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    install();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('CookieManager.flush return value', () {
    test('a native true is returned to the caller', () async {
      nativeReply = true;
      expect(await cookieManager.flush(), true);
      expect(calls.single.method, 'flush');
    });

    test('a native false is returned, not swallowed', () async {
      // The Kotlin sends this when `getCookieManager(profileName)` resolves to null — no profile
      // of that name, or no MULTI_PROFILE support. Nothing was written, and before §137 the
      // caller had no way to learn that.
      nativeReply = false;
      expect(await cookieManager.flush(profileName: 'nope'), false);
    });

    test('a null reply becomes false rather than throwing', () async {
      // `null` is also what a MethodChannel yields when no handler is registered at all, so this
      // is the disposed-channel path as much as a misbehaving native one.
      nativeReply = null;
      expect(await cookieManager.flush(), false);
    });

    test('flush still sends profileName on the same channel method', () async {
      await cookieManager.flush(profileName: 'p');
      expect(calls.single.method, 'flush');
      expect(
        (calls.single.arguments as Map).cast<String, dynamic>()['profileName'],
        'p',
      );
    });
  });
}
