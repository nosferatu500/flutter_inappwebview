import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.MUTE_AUDIO` — `setAudioMuted` / `isAudioMuted`.
///
/// Both cross the per-WebView channel, so the failure modes are the usual silent pair: a renamed
/// argument key arrives as null on the Kotlin side, and `isAudioMuted`'s `?? false` turns a missing
/// reply into a positive claim that audio is *not* muted. Neither shows up in a build.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The per-WebView channel name is built from the controller id.
  const channel = MethodChannel('dev.nosferatu500.inappwebview/inappwebview_7');

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 7),
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
    controller.dispose();
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidInAppWebViewController.setAudioMuted', () {
    test('sends the flag under the key the Kotlin side reads', () async {
      await controller.setAudioMuted(true);

      expect(calls.single.method, 'setAudioMuted');
      expect(argsOf(calls.single)['muted'], true);
    });

    test('false is sent, not omitted', () async {
      // Unmuting is a real request. Dropping a `false` would leave the WebView muted with no
      // error anywhere.
      await controller.setAudioMuted(false);

      expect(argsOf(calls.single).containsKey('muted'), isTrue);
      expect(argsOf(calls.single)['muted'], false);
    });
  });

  group('AndroidInAppWebViewController.isAudioMuted', () {
    test('sends no arguments', () async {
      reply = false;
      await controller.isAudioMuted();

      expect(calls.single.method, 'isAudioMuted');
      expect(argsOf(calls.single), isEmpty);
    });

    test('returns what the native side read', () async {
      reply = true;
      expect(await controller.isAudioMuted(), isTrue);

      reply = false;
      expect(await controller.isAudioMuted(), isFalse);
    });

    test('a missing reply reads as "not muted"', () async {
      // Documented rather than desirable: the return type is non-nullable `bool`, so `null` from
      // the platform (feature unsupported on this WebView provider) collapses to false. A caller
      // that needs to tell "unsupported" from "audible" must check
      // WebViewFeature.isFeatureSupported(MUTE_AUDIO) first.
      reply = null;
      expect(await controller.isAudioMuted(), isFalse);
    });
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
