import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.MUTE_AUDIO` — `setAudioMuted` / `isAudioMuted`.
///
/// Both cross the per-WebView `InAppWebViewHostApi` (Pigeon since §212), so the failure modes are
/// a dropped or flipped flag on the way in, and an answer read from the wrong method on the way
/// back. Neither shows up in a build.
///
/// Before §212 a null reply (the feature unsupported on this WebView provider) read as "not
/// muted" through `?? false`. The Pigeon answer is a non-null `bool`, and Kotlin turns the
/// unsupported case into `false` before replying, so the Dart side can no longer see a null. A
/// caller that needs to tell "unsupported" from "audible" must still check
/// WebViewFeature.isFeatureSupported(MUTE_AUDIO) first.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = InAppWebViewHostApi.pigeonChannelCodec;
  String hostChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewHostApi.'
      '$method.inappwebview_7';

  late AndroidInAppWebViewController controller;
  final Map<String, List<Object?>> sent = <String, List<Object?>>{};
  bool reply = false;

  setUp(() {
    sent.clear();
    reply = false;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 7),
    );
    for (final method in ['setAudioMuted', 'isAudioMuted']) {
      messenger.setMockMessageHandler(hostChannel(method), (message) async {
        sent[method] = codec.decodeMessage(message) as List<Object?>? ?? [];
        return codec.encodeMessage(<Object?>[
          method == 'isAudioMuted' ? reply : true,
        ]);
      });
    }
  });

  tearDown(() {
    for (final method in ['setAudioMuted', 'isAudioMuted']) {
      messenger.setMockMessageHandler(hostChannel(method), null);
    }
    controller.dispose();
  });

  group('AndroidInAppWebViewController.setAudioMuted', () {
    test('sends the flag to setAudioMuted', () async {
      await controller.setAudioMuted(true);

      expect(sent.keys, ['setAudioMuted']);
      expect(sent['setAudioMuted'], [true]);
    });

    test('false is sent, not omitted', () async {
      // Unmuting is a real request. Dropping a `false` would leave the WebView muted with no
      // error anywhere.
      await controller.setAudioMuted(false);

      expect(sent['setAudioMuted'], [false]);
    });
  });

  group('AndroidInAppWebViewController.isAudioMuted', () {
    test('sends no arguments', () async {
      await controller.isAudioMuted();

      expect(sent.keys, ['isAudioMuted']);
      expect(sent['isAudioMuted'], isEmpty);
    });

    test('returns what the native side read', () async {
      reply = true;
      expect(await controller.isAudioMuted(), isTrue);

      reply = false;
      expect(await controller.isAudioMuted(), isFalse);
    });

    test(
      'a disposed controller reads as "not muted" and sends nothing',
      () async {
        final disposed = AndroidInAppWebViewController(
          AndroidInAppWebViewControllerCreationParams(id: 7),
        );
        disposed.dispose();
        reply = true;
        expect(await disposed.isAudioMuted(), isFalse);
        expect(sent, isEmpty);
      },
    );
  });

  group('platform gating', () {
    test('both methods report Android-only', () {
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.setAudioMuted,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.isAudioMuted,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.setAudioMuted,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });
}
