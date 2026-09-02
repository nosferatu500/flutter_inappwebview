import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire shape and the ownership rule of `setCookieStoreObserver` (A4,
/// `WKHTTPCookieStoreObserver`).
///
/// The device suite proves the notification arrives from WebKit. What it cannot see is the Dart
/// side's one non-obvious decision: **the observer is held statically**, because
/// `createPlatformCookieManager` hands out a new `IOSCookieManager` on every call, `.static()` is a
/// further separate object, and all of them attach a handler to the same `const MethodChannel` —
/// where the last one constructed silently replaces the previous handler. Held per instance, the
/// callback would stop firing as soon as anything touched `CookieManager.isMethodSupported`. The
/// third test is the one that can go red for that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cookieChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_cookiemanager',
  );

  late IOSCookieManager cookieManager;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    cookieManager = IOSCookieManager(
      const PlatformCookieManagerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cookieChannel, (MethodCall call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() async {
    // Leave no observer behind: the field is static, so it would outlive the test.
    await cookieManager.setCookieStoreObserver(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cookieChannel, null);
  });

  /// Delivers what the Swift sends: `channel.invokeMethod("onCookiesChanged", arguments: [:])`.
  Future<void> deliverOnCookiesChanged() async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          cookieChannel.name,
          cookieChannel.codec.encodeMethodCall(
            const MethodCall('onCookiesChanged', <String, dynamic>{}),
          ),
          (_) {},
        );
  }

  group('IOSCookieManager.setCookieStoreObserver', () {
    test('registers and unregisters with a single isNull flag', () async {
      await cookieManager.setCookieStoreObserver(CookieStoreObserver());
      expect(calls.single.method, 'setCookieStoreObserver');
      expect(
        calls.single.arguments as Map<Object?, Object?>,
        <Object?, Object?>{'isNull': false},
        reason:
            'the native side only needs to know whether to add or remove itself as the observer',
      );
      expect(cookieManager.cookieStoreObserver, isNotNull);

      calls.clear();
      await cookieManager.setCookieStoreObserver(null);
      expect(
        calls.single.arguments as Map<Object?, Object?>,
        <Object?, Object?>{'isNull': true},
      );
      expect(cookieManager.cookieStoreObserver, isNull);
    });

    test('onCookiesChanged carries no payload and still fires', () async {
      var fired = 0;
      await cookieManager.setCookieStoreObserver(
        CookieStoreObserver(onCookiesChanged: () => fired++),
      );

      await deliverOnCookiesChanged();
      await deliverOnCookiesChanged();

      expect(
        fired,
        2,
        reason:
            'the event is a bare notification -- every delivery is one call, nothing is coalesced '
            'in Dart',
      );
    });

    test(
      'survives another IOSCookieManager taking over the channel handler',
      () async {
        var fired = 0;
        await cookieManager.setCookieStoreObserver(
          CookieStoreObserver(onCookiesChanged: () => fired++),
        );

        // Exactly what `CookieManager.isMethodSupported` does on first use, and what any second
        // `CookieManager()` does: build another instance, which re-registers the channel's
        // method-call handler over the one the observer was set through.
        IOSCookieManager.static();
        IOSCookieManager(const PlatformCookieManagerCreationParams());

        await deliverOnCookiesChanged();
        expect(
          fired,
          1,
          reason:
              'the observer belongs to the process-wide cookie store, not to the instance that '
              'happens to own the channel handler',
        );
      },
    );

    test('the observer is shared by every instance', () async {
      var fired = 0;
      await cookieManager.setCookieStoreObserver(
        CookieStoreObserver(onCookiesChanged: () => fired++),
      );

      final other = IOSCookieManager(
        const PlatformCookieManagerCreationParams(),
      );
      expect(
        other.cookieStoreObserver,
        same(cookieManager.cookieStoreObserver),
        reason: 'there is one WKHTTPCookieStore, so there is one observer',
      );

      await other.setCookieStoreObserver(null);
      expect(
        cookieManager.cookieStoreObserver,
        isNull,
        reason: 'clearing it anywhere clears it everywhere',
      );

      await deliverOnCookiesChanged();
      expect(fired, 0);
    });
  });

  group('support checks', () {
    test('setCookieStoreObserver is iOS-only', () {
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.setCookieStoreObserver,
          platform: TargetPlatform.iOS,
        ),
        isTrue,
      );
      expect(
        cookieManager.isMethodSupported(
          PlatformCookieManagerMethod.setCookieStoreObserver,
          platform: TargetPlatform.android,
        ),
        isFalse,
        reason: 'android.webkit.CookieManager has no change notification',
      );
    });

    test('CookieStoreObserver has exactly one property', () {
      expect(
        CookieStoreObserverProperty.values,
        <CookieStoreObserverProperty>[
          CookieStoreObserverProperty.onCookiesChanged,
        ],
        reason:
            'WKHTTPCookieStoreObserver declares one method; growing this should be a deliberate '
            'response to Apple adding one, not drift',
      );
    });
  });
}
