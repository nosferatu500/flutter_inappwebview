import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `getMetaThemeColor` to its only working path on Android: reading the `theme-color` meta
/// tag with JavaScript.
///
/// It used to send a `getMetaThemeColor` message first. The Kotlin side has never handled one, so
/// the request always failed, the Dart side swallowed the error and fell through to the
/// JavaScript. Measured on a device before the send was removed (§190): breaking the JavaScript
/// fallback made the integration test return null, so the channel never supplied the value.
///
/// Since §210 the JavaScript goes through the Pigeon `evaluateJavascript`, so the MethodChannel
/// must see nothing at all: any message there would be a `getMetaThemeColor` again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // The per-WebView channel name is built from the controller id.
  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_11',
  );
  const evaluateJavascript =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewHostApi.'
      'evaluateJavascript.inappwebview_11';
  const codec = InAppWebViewHostApi.pigeonChannelCodec;

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  final List<Object?> evaluated = <Object?>[];
  String? reply;

  setUp(() {
    calls.clear();
    evaluated.clear();
    reply = null;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 11),
    );
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return null;
    });
    messenger.setMockMessageHandler(evaluateJavascript, (message) async {
      evaluated.add((codec.decodeMessage(message) as List<Object?>)[0]);
      return codec.encodeMessage(<Object?>[reply]);
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMessageHandler(evaluateJavascript, null);
    controller.dispose();
  });

  // The shape the page script returns, as the Kotlin side forwards it: a JSON string.
  String metaTags(List<Map<String, Object?>> tags) => jsonEncode(tags);

  test(
    'asks only evaluateJavascript, and never sends a getMetaThemeColor message',
    () async {
      reply = metaTags([
        {'name': 'theme-color', 'content': '#0a8f3c', 'attrs': []},
      ]);

      await controller.getMetaThemeColor();

      expect(evaluated, hasLength(1));
      expect(calls, isEmpty);
    },
  );

  test('reads the color from the theme-color meta tag', () async {
    // Three different components, so a channel-order mix-up cannot produce the same color.
    reply = metaTags([
      {'name': 'viewport', 'content': 'width=device-width', 'attrs': []},
      {'name': 'theme-color', 'content': '#0a8f3c', 'attrs': []},
    ]);

    expect(await controller.getMetaThemeColor(), const Color(0xFF0A8F3C));
  });

  test('a page without a theme-color meta tag reads as null', () async {
    reply = metaTags([
      {'name': 'viewport', 'content': 'width=device-width', 'attrs': []},
    ]);

    expect(await controller.getMetaThemeColor(), isNull);
  });
}
