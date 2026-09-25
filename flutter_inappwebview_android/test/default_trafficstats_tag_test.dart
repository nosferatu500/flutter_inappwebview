import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING` —
/// `setDefaultTrafficStatsTag`.
///
/// This one is a **process-global static**, so unlike the rest of the controller surface it goes on
/// the manager API, not the per-WebView channel. Since §188 that is the Pigeon-generated
/// `InAppWebViewManagerHostApi`, so the channel this pins is the generated one.
///
/// The 32-bit range assertion is pinned too: `TrafficStats` takes a Java `int`. The Kotlin side
/// keeps the low 32 bits of the `Long` Pigeon hands it — which is what lets the unsigned form the
/// androidx javadoc uses (`0xFFFFFF00`) map to the intended tag — so anything wider would silently
/// become a *different* tag rather than fail, and the Dart assert is the only thing that stops it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewManagerHostApi'
      '.setDefaultTrafficStatsTag';
  const codec = InAppWebViewManagerHostApi.pigeonChannelCodec;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AndroidInAppWebViewController controller;
  final List<List<Object?>> calls = <List<Object?>>[];
  bool reply = true;

  setUp(() {
    calls.clear();
    reply = true;
    controller = AndroidInAppWebViewController.static();
    messenger.setMockMessageHandler(channel, (message) async {
      calls.add(codec.decodeMessage(message) as List<Object?>);
      return codec.encodeMessage(<Object?>[reply]);
    });
  });

  tearDown(() {
    messenger.setMockMessageHandler(channel, null);
  });

  group('AndroidInAppWebViewController.setDefaultTrafficStatsTag', () {
    test('goes on the manager API, not the per-WebView channel', () async {
      await controller.setDefaultTrafficStatsTag(0x42);

      expect(calls.single, <Object?>[0x42]);
    });

    test('accepts the unsigned form the androidx javadoc uses', () async {
      // The javadoc's own example is 0xFFFFFF00, which is above the signed int range but still
      // 32 bits. The assert must not reject it, and it must cross unchanged — the Kotlin `toInt()`
      // is what turns it into the tag.
      await controller.setDefaultTrafficStatsTag(0xFFFFFF00);

      expect(calls.single, <Object?>[0xFFFFFF00]);
    });

    test('accepts the signed lower bound', () async {
      await controller.setDefaultTrafficStatsTag(-0x80000000);

      expect(calls.single, <Object?>[-0x80000000]);
    });

    test('rejects a value wider than 32 bits', () {
      expect(
        () => controller.setDefaultTrafficStatsTag(0x1FFFFFFFF),
        throwsAssertionError,
      );
      expect(
        () => controller.setDefaultTrafficStatsTag(-0x80000001),
        throwsAssertionError,
      );
    });

    test('reports false when the platform could not apply it', () async {
      // The hand-written version also asserted that a *null* reply read as false. That half is gone
      // with the transport, not dropped: the host method is typed non-null `bool`, so the Kotlin
      // side cannot send null, and `false` is how it reports an unsupported feature.
      reply = false;
      expect(await controller.setDefaultTrafficStatsTag(1), isFalse);
    });
  });

  group('platform gating', () {
    test('reports Android-only', () {
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.setDefaultTrafficStatsTag,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.setDefaultTrafficStatsTag,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
