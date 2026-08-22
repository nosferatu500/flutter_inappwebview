import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the iOS half of §29's `profileName` decision.
///
/// `PlatformCookieManager` declares `profileName` on every method because Android needs it, and
/// Dart then *requires* every implementer to accept it — including this one, which has no profiles
/// to scope to. `IOSCookieManager` therefore takes it and drops it on the floor, deliberately.
///
/// The risk is that "accepted and ignored" quietly becomes "accepted and forwarded": somebody
/// pattern-edits the argument maps across packages and the key starts reaching a native side that
/// has no idea what it means. Nothing would fail — the Swift reader would just not look at it — so
/// this asserts the absence instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cookieChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );
  // IOSCookieManager falls back to a JavaScript path below iOS 10.13, which it decides by asking
  // the platform for its version over a separate channel. Answer with a modern one so the tests
  // exercise the channel path.
  const platformUtilChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_platformutil',
  );

  late IOSCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    cookieManager = IOSCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(platformUtilChannel, (call) async {
      if (call.method == 'getSystemVersion') return '17.0';
      return null;
    });
    messenger.setMockMethodCallHandler(cookieChannel, (MethodCall call) async {
      calls.add(call);
      if (call.method == 'getCookies') return <dynamic>[];
      return true;
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(cookieChannel, null);
    messenger.setMockMethodCallHandler(platformUtilChannel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('IOSCookieManager profileName', () {
    test('is accepted but never put on the wire', () async {
      await cookieManager.setCookie(
        url: WebUri('https://example.com'),
        name: 'session',
        value: 'abc',
        profileName: 'signed_in',
      );

      expect(calls.single.method, 'setCookie');
      expect(
        argsOf(calls.single).containsKey('profileName'),
        isFalse,
        reason:
            'iOS has no profiles; the parameter exists only so the override '
            'matches PlatformCookieManager',
      );
      // The arguments it does care about are untouched.
      expect(argsOf(calls.single)['name'], 'session');
      expect(argsOf(calls.single)['value'], 'abc');
    });

    test('does not change behaviour when omitted', () async {
      await cookieManager.deleteAllCookies();

      expect(calls.single.method, 'deleteAllCookies');
      expect(argsOf(calls.single).containsKey('profileName'), isFalse);
    });
  });
}
