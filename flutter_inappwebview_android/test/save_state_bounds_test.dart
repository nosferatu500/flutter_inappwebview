import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `saveState`'s two new bounds (§124) — `maxSize` and
/// `includeForwardState`, backed by `WebViewCompat.saveState`.
///
/// The whole design turns on one thing a build cannot see: **absent must arrive as `null`, not as a
/// default.** The Kotlin reads `call.argument("maxSize")` and treats a null as "no constraint asked
/// for", which selects the framework `WebView.saveState` and needs no `WebViewFeature.SAVE_STATE`.
/// If Dart ever helpfully defaulted these to `Int.MAX_VALUE` / `true`, every unconstrained
/// `saveState()` would silently start requiring that feature and would return `null` on any WebView
/// without it — with no compile error and no analyzer warning anywhere.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.nosferatu500.inappwebview/inappwebview_9');

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 9),
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

  group('AndroidInAppWebViewController.saveState', () {
    test('sends both keys as null when neither bound is given', () async {
      reply = Uint8List.fromList(<int>[1, 2, 3]);
      await controller.saveState();

      expect(calls.single.method, 'saveState');
      // Present-and-null, not absent: either spelling reaches the Kotlin side as null, but the
      // keys are asserted so a future refactor cannot quietly start omitting only one of them.
      expect(argsOf(calls.single)['maxSize'], isNull);
      expect(argsOf(calls.single)['includeForwardState'], isNull);
    });

    test('sends the bounds under the keys the Kotlin side reads', () async {
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(maxSize: 512000, includeForwardState: false);

      expect(argsOf(calls.single)['maxSize'], 512000);
      expect(argsOf(calls.single)['includeForwardState'], false);
    });

    test('an explicit false is sent, not dropped as falsy', () async {
      // `includeForwardState: false` is the entire point of the argument. Sending nothing would
      // read as "no constraint" and produce a full state, which is the opposite request.
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(includeForwardState: false);

      expect(argsOf(calls.single).containsKey('includeForwardState'), isTrue);
      expect(argsOf(calls.single)['includeForwardState'], false);
      expect(argsOf(calls.single)['maxSize'], isNull);
    });

    test('either bound alone still leaves the other null', () async {
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(maxSize: 1024);

      expect(argsOf(calls.single)['maxSize'], 1024);
      expect(argsOf(calls.single)['includeForwardState'], isNull);
    });

    test('a null reply is returned as null', () async {
      // The platform answers null when the state could not be produced under the requested
      // bounds — including when `SAVE_STATE` is unsupported, where the Kotlin deliberately does
      // NOT fall back to an unbounded state.
      reply = null;
      expect(await controller.saveState(maxSize: 1), isNull);
    });
  });

  group('WebViewFeature.SAVE_STATE', () {
    test('mirrors the androidx constant name exactly', () {
      // The value is passed straight to androidx's isFeatureSupported, which THROWS rather than
      // returning false for an unrecognised string.
      expect(WebViewFeature.SAVE_STATE.toNativeValue(), 'SAVE_STATE');
      expect(WebViewFeature.fromNativeValue('SAVE_STATE'), isNotNull);
    });

    test('is listed in values', () {
      expect(WebViewFeature.values, contains(WebViewFeature.SAVE_STATE));
    });
  });

  group('platform gating', () {
    test('saveState itself stays available on both platforms', () {
      // Only the two arguments are Android-only. The method predates them and must not become
      // Android-only by association.
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        expect(
          controller.isMethodSupported(
            PlatformInAppWebViewControllerMethod.saveState,
            platform: platform,
          ),
          isTrue,
          reason: 'saveState should still be supported on $platform',
        );
      }
    });
  });
}
