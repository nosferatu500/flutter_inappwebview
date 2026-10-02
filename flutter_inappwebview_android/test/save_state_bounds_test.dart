import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of `saveState`'s two new bounds (§124) — `maxSize` and
/// `includeForwardState`, backed by `WebViewCompat.saveState`.
///
/// The whole design turns on one thing a build cannot see: **absent must arrive as `null`, not as a
/// default.** The Kotlin treats a null as "no constraint asked for", which selects the framework
/// `WebView.saveState` and needs no `WebViewFeature.SAVE_STATE`. If Dart ever helpfully defaulted
/// these to `Int.MAX_VALUE` / `true`, every unconstrained `saveState()` would silently start
/// requiring that feature and would return `null` on any WebView without it — with no compile error
/// and no analyzer warning anywhere.
///
/// Since §212 the call is the Pigeon `saveState(maxSize, includeForwardState)`: positional, so the
/// message is always a two-element list, `[maxSize, includeForwardState]`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = InAppWebViewHostApi.pigeonChannelCodec;
  const saveStateChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewHostApi.'
      'saveState.inappwebview_9';
  const methodChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_9',
  );

  late AndroidInAppWebViewController controller;
  final List<List<Object?>> calls = <List<Object?>>[];
  final List<String> onMethodChannel = <String>[];
  Object? reply;

  setUp(() {
    calls.clear();
    onMethodChannel.clear();
    reply = null;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 9),
    );
    messenger.setMockMessageHandler(saveStateChannel, (message) async {
      calls.add(codec.decodeMessage(message) as List<Object?>);
      return codec.encodeMessage(<Object?>[reply]);
    });
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      onMethodChannel.add(call.method);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMessageHandler(saveStateChannel, null);
    messenger.setMockMethodCallHandler(methodChannel, null);
    controller.dispose();
  });

  group('AndroidInAppWebViewController.saveState', () {
    test('sends both bounds as null when neither is given', () async {
      reply = Uint8List.fromList(<int>[1, 2, 3]);
      await controller.saveState();

      expect(calls.single, [null, null]);
      expect(onMethodChannel, isEmpty);
    });

    test('sends the bounds in the order the Kotlin side reads', () async {
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(maxSize: 512000, includeForwardState: false);

      expect(calls.single, [512000, false]);
    });

    test('an explicit false is sent, not dropped as falsy', () async {
      // `includeForwardState: false` is the entire point of the argument. Sending nothing would
      // read as "no constraint" and produce a full state, which is the opposite request.
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(includeForwardState: false);

      expect(calls.single, [null, false]);
    });

    test('either bound alone still leaves the other null', () async {
      reply = Uint8List.fromList(<int>[1]);
      await controller.saveState(maxSize: 1024);

      expect(calls.single, [1024, null]);
    });

    test('the platform answer is returned', () async {
      reply = Uint8List.fromList(<int>[4, 5, 6]);
      expect(await controller.saveState(), Uint8List.fromList(<int>[4, 5, 6]));
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
