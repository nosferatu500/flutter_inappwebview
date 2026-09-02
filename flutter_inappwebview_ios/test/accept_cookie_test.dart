import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the iOS half of the cookie master switch (B9, `WKHTTPCookieStore.setCookiePolicy` /
/// `getCookiePolicy`, iOS 17.0+).
///
/// These methods existed as Android-only until now, so the risk this covers is **divergence**: the
/// iOS implementation must put the same `accept` key on the wire under the same two method names
/// the Kotlin already answers to, and it must keep dropping `profileName` the way every other
/// `IOSCookieManager` method does (§29's rule, pinned for the other methods in
/// `cookie_manager_profile_test.dart`).
///
/// The `bool?` contract cannot be exercised here — whether the getter answers `null` is decided by
/// an `#available(iOS 17.0, *)` guard in the Swift, which no Dart test can see. That is asserted on
/// a real iOS 16.4 simulator by `integration_test/cookie_manager/accept_cookie.dart`; what this
/// pins is that the Dart side *forwards* a `null` rather than defaulting it, which is the half a
/// unit test can prove.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cookieChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late IOSCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];
  Object? nextResult;

  setUp(() {
    calls.clear();
    nextResult = true;
    cookieManager = IOSCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cookieChannel, (MethodCall call) async {
          calls.add(call);
          return nextResult;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cookieChannel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('IOSCookieManager.setAcceptCookie', () {
    test('sends the accept flag under the Android method name', () async {
      expect(await cookieManager.setAcceptCookie(false), isTrue);

      expect(
        calls.single.method,
        'setAcceptCookie',
        reason:
            'the same wire name the Kotlin answers to -- one Dart method, one channel method',
      );
      expect(argsOf(calls.single), <Object?, Object?>{'accept': false});
    });

    test('drops profileName, like every other iOS cookie method', () async {
      await cookieManager.setAcceptCookie(true, profileName: 'signed_in');

      expect(
        argsOf(calls.single).containsKey('profileName'),
        isFalse,
        reason:
            'iOS has no profiles; the parameter exists only for the override',
      );
      expect(argsOf(calls.single)['accept'], isTrue);
    });

    test('reports false when the native side could not apply it', () async {
      // What the Swift returns below iOS 17.0.
      nextResult = false;
      expect(await cookieManager.setAcceptCookie(false), isFalse);
    });
  });

  group('IOSCookieManager.isAcceptCookieEnabled', () {
    test('takes no arguments and forwards the answer', () async {
      expect(await cookieManager.isAcceptCookieEnabled(), isTrue);
      expect(calls.single.method, 'isAcceptCookieEnabled');
      expect(argsOf(calls.single), isEmpty);
    });

    test('forwards a null instead of defaulting it to false', () async {
      // What the Swift returns below iOS 17.0. `?? false` here would claim cookies are being
      // rejected on an OS that has no policy at all -- the opposite of the platform default.
      nextResult = null;
      expect(
        await cookieManager.isAcceptCookieEnabled(),
        isNull,
        reason: 'null means "could not be read", and must survive the Dart hop',
      );
    });

    test('drops profileName', () async {
      await cookieManager.isAcceptCookieEnabled(profileName: 'signed_in');
      expect(argsOf(calls.single).containsKey('profileName'), isFalse);
    });
  });

  group('support checks', () {
    test('both methods are now reported on iOS as well as Android', () {
      for (final method in <PlatformCookieManagerMethod>[
        PlatformCookieManagerMethod.setAcceptCookie,
        PlatformCookieManagerMethod.isAcceptCookieEnabled,
      ]) {
        expect(
          cookieManager.isMethodSupported(method, platform: TargetPlatform.iOS),
          isTrue,
          reason: '$method gained an iOS implementation in B9',
        );
        expect(
          cookieManager.isMethodSupported(
            method,
            platform: TargetPlatform.android,
          ),
          isTrue,
          reason: '$method must not have lost Android on the way',
        );
      }
    });
  });
}
