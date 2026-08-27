import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING` —
/// `setDefaultTrafficStatsTag`.
///
/// This one is a **process-global static**, so unlike the rest of the controller surface it goes on
/// the manager channel (`…/inappwebview_manager`), not the per-WebView one. Sending it to the wrong
/// channel is a `MissingPluginException` at runtime and invisible to every gate here, so the channel
/// name is part of the contract this pins.
///
/// The 32-bit range assertion is pinned too: `TrafficStats` takes a Java `int`, and the standard
/// codec silently promotes anything wider to an int64, which fails at the Kotlin cast site rather
/// than at the call.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const managerChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_manager',
  );

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = true;
    controller = AndroidInAppWebViewController.static();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(managerChannel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(managerChannel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidInAppWebViewController.setDefaultTrafficStatsTag', () {
    test('goes on the manager channel, not the per-WebView one', () async {
      await controller.setDefaultTrafficStatsTag(0x42);

      expect(calls.single.method, 'setDefaultTrafficStatsTag');
      expect(argsOf(calls.single)['tag'], 0x42);
    });

    test('accepts the unsigned form the androidx javadoc uses', () async {
      // The javadoc's own example is 0xFFFFFF00, which is above the signed int range but still
      // 32 bits. The assert must not reject it.
      await controller.setDefaultTrafficStatsTag(0xFFFFFF00);

      expect(argsOf(calls.single)['tag'], 0xFFFFFF00);
    });

    test('accepts the signed lower bound', () async {
      await controller.setDefaultTrafficStatsTag(-0x80000000);

      expect(argsOf(calls.single)['tag'], -0x80000000);
    });

    test('rejects a value that would be encoded as an int64', () {
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
      reply = false;
      expect(await controller.setDefaultTrafficStatsTag(1), isFalse);

      reply = null;
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
