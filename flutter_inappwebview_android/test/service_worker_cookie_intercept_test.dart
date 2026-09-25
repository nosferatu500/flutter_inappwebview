import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/service_worker.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for the Service Worker half of `COOKIE_INTERCEPT` (§126).
///
/// The device test can prove the switch round-trips; it cannot see an argument sent in the wrong
/// slot or dropped. These pin the wire instead. Since §186 the transport is Pigeon — positional
/// arguments rather than map keys — and the assertions are otherwise unchanged. The load-bearing one
/// is still that a null answer is **not** collapsed to false.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hostBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.ServiceWorkerHostApi';
  const setter = '$hostBase.setIncludeCookiesOnShouldInterceptRequestEnabled';
  const getter = '$hostBase.getIncludeCookiesOnShouldInterceptRequestEnabled';
  const codec = ServiceWorkerHostApi.pigeonChannelCodec;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AndroidServiceWorkerController controller;

  /// Every host call, as (channel, positional arguments).
  final List<(String, List<Object?>)> calls = <(String, List<Object?>)>[];

  /// What the getter answers.
  bool? reply;

  setUp(() {
    calls.clear();
    reply = null;
    controller = AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    );
    messenger.setMockMessageHandler(setter, (message) async {
      calls.add((setter, codec.decodeMessage(message) as List<Object?>));
      return codec.encodeMessage(<Object?>[true]);
    });
    messenger.setMockMessageHandler(getter, (message) async {
      calls.add((getter, codec.decodeMessage(message) as List<Object?>));
      return codec.encodeMessage(<Object?>[reply]);
    });
  });

  tearDown(() {
    messenger.setMockMessageHandler(setter, null);
    messenger.setMockMessageHandler(getter, null);
  });

  group('setIncludeCookiesOnShouldInterceptRequestEnabled', () {
    test('sends the flag first and the profile second', () async {
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(true);

      final (channel, args) = calls.single;
      expect(channel, setter);
      expect(args, <Object?>[true, null]);
    });

    test('false is sent, not omitted', () async {
      // Turning the switch back off is a real request; a dropped `false` would leave cookies
      // flowing into every intercepted service-worker request.
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(false);

      expect(calls.single.$2.first, false);
    });

    test('carries profileName when given', () async {
      await controller.setIncludeCookiesOnShouldInterceptRequestEnabled(
        true,
        profileName: 'work',
      );

      expect(calls.single.$2, <Object?>[true, 'work']);
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
      // The load-bearing assertion. Its neighbours (`getAllowContentAccess` and friends) answer a
      // non-null bool, so copying one of them would have produced a getter that reports "cookies
      // are off" for a WebView where the feature is missing and for a named profile where the API
      // does not exist at all — three states flattened into two, invisibly. The schema types this
      // one `bool?` for exactly that reason.
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
      expect(calls.last.$2, <Object?>['work']);
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
