import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `getMetaThemeColor` to its only working path on Android: reading the `theme-color` meta
/// tag with JavaScript.
///
/// It used to send a `getMetaThemeColor` message first. The Kotlin side has never handled one, so
/// the request always failed, the Dart side swallowed the error and fell through to the
/// JavaScript. Measured on a device before the send was removed (§190): breaking the JavaScript
/// fallback made the integration test return null, so the channel never supplied the value.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The per-WebView channel name is built from the controller id.
  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_11',
  );

  late AndroidInAppWebViewController controller;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    controller = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(id: 11),
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

  // The shape the page script returns, as the Kotlin side forwards it: a JSON string.
  String metaTags(List<Map<String, Object?>> tags) => jsonEncode(tags);

  test(
    'sends only evaluateJavascript, never a getMetaThemeColor message',
    () async {
      reply = metaTags([
        {'name': 'theme-color', 'content': '#0a8f3c', 'attrs': []},
      ]);

      await controller.getMetaThemeColor();

      expect(calls.map((c) => c.method), ['evaluateJavascript']);
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
