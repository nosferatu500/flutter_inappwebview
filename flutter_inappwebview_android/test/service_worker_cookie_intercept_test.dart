import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for the Service Worker half of `COOKIE_INTERCEPT` (§126).
///
/// The device test can prove the switch round-trips; it cannot see an argument key that the Kotlin
/// reads under a different name, because `call.argument` returns null and
/// `settings?.set…(null!!)` would be the only symptom — on a path the device test does exercise,
/// but with a NullPointerException rather than a wrong value. These pin the names instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_serviceworkercontroller',
  );

  late AndroidServiceWorkerController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    controller = AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('setIncludeCookiesOnShouldInterceptRequestEnabled', () {
    test('sends the flag under the key the Kotlin reads', () async {
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(true);

      expect(
        calls.single.method,
        'setIncludeCookiesOnShouldInterceptRequestEnabled',
      );
      expect(argsOf(calls.single)['enabled'], true);
      expect(argsOf(calls.single)['profileName'], isNull);
    });

    test('false is sent, not omitted', () async {
      // Turning the switch back off is a real request; a dropped `false` would leave cookies
      // flowing into every intercepted service-worker request.
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(false);

      expect(argsOf(calls.single).containsKey('enabled'), isTrue);
      expect(argsOf(calls.single)['enabled'], false);
    });

    test('carries profileName when given', () async {
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(
        true,
        profileName: 'work',
      );

      expect(argsOf(calls.single)['profileName'], 'work');
    });
  });

  group('getIncludeCookiesOnShouldInterceptRequestEnabled', () {
    test('returns what the platform answered', () async {
      for (final v in [true, false]) {
        reply = v;
        expect(
          await controller.getIncludeCookiesOnShouldInterceptRequestEnabled(),
          v,
        );
      }
    });

    test('a null reply stays null and is NOT collapsed to false', () async {
      // The load-bearing assertion. Its neighbours (`getAllowContentAccess` and friends) do
      // `?? false`, so copying one of them would have produced a getter that reports "cookies are
      // off" for a WebView where the feature is missing and for a named profile where the API does
      // not exist at all — three states flattened into two, invisibly.
      reply = null;
      expect(
        await controller.getIncludeCookiesOnShouldInterceptRequestEnabled(),
        isNull,
      );
      expect(
        await controller.getIncludeCookiesOnShouldInterceptRequestEnabled(
          profileName: 'work',
        ),
        isNull,
      );
    });
  });

  group('platform gating', () {
    test('both methods report Android-only', () {
      for (final m in [
        PlatformServiceWorkerControllerMethod
            .getIncludeCookiesOnShouldInterceptRequestEnabled,
        PlatformServiceWorkerControllerMethod
            .setIncludeCookiesOnShouldInterceptRequestEnabled,
      ]) {
        expect(
          controller.isMethodSupported(m, platform: TargetPlatform.android),
          isTrue,
        );
        expect(
          controller.isMethodSupported(m, platform: TargetPlatform.iOS),
          isFalse,
        );
      }
    });
  });
}
