import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_browser_manager.g.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// §217: the per-WebView MethodChannels (`inappwebview_<id>` and `inappbrowser_<id>`) are gone.
/// Every method and event moved to Pigeon in W1–W5 (§207–§216), so neither the controller nor the
/// browser registers a handler on them any more: a message there finds nobody, and the same event
/// over Pigeon still arrives (the positive control, so a null cannot just mean a misspelt name).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const methodCodec = StandardMethodCodec();
  const pigeonCodec = InAppWebViewFlutterApi.pigeonChannelCodec;

  Future<ByteData?> send(String channel, ByteData? message) {
    final reply = Completer<ByteData?>();
    unawaited(
      messenger.handlePlatformMessage(channel, message, reply.complete),
    );
    return reply.future;
  }

  Future<ByteData?> onMethodChannel(String name, String method, Object? args) =>
      send(
        'dev.nosferatu500.inappwebview/$name',
        methodCodec.encodeMethodCall(MethodCall(method, args)),
      );

  Future<ByteData?> overPigeon(
    String suffix,
    String method,
    List<Object?> args,
  ) => send(
    'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewFlutterApi'
    '.$method.$suffix',
    pigeonCodec.encodeMessage(args),
  );

  test(
    'a WebView controller has no MethodChannel handler, only Pigeon',
    () async {
      final titles = <String?>[];
      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 21,
          webviewParams: AndroidInAppWebViewWidgetCreationParams(
            onTitleChanged: (_, title) => titles.add(title),
          ),
        ),
      );
      addTearDown(controller.dispose);

      expect(
        await overPigeon('inappwebview_21', 'onTitleChanged', ['over-pigeon']),
        isNotNull,
        reason: 'the positive control: the controller is listening',
      );
      expect(titles, ['over-pigeon']);

      expect(
        await onMethodChannel('inappwebview_21', 'onTitleChanged', {
          'title': 'over-the-channel',
        }),
        isNull,
        reason: 'nothing may be registered on the old MethodChannel any more',
      );
      expect(titles, ['over-pigeon']);
    },
  );

  test('an in-app browser has no MethodChannel handler, only Pigeon', () async {
    // The browser builds its WebView controller when it opens, so it is opened; answering the
    // manager's `open` is what lets that complete.
    const managerOpen =
        'dev.flutter.pigeon.flutter_inappwebview_android.InAppBrowserManagerHostApi.open';
    messenger.setMockMessageHandler(
      managerOpen,
      (message) async => InAppBrowserManagerHostApi.pigeonChannelCodec
          .encodeMessage(<Object?>[true]),
    );
    addTearDown(() => messenger.setMockMessageHandler(managerOpen, null));
    final browser = AndroidInAppBrowser(AndroidInAppBrowserCreationParams());
    addTearDown(browser.dispose);
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri('https://example.com')),
    );

    expect(
      await overPigeon('inappbrowser_${browser.id}', 'onTitleChanged', ['t']),
      isNotNull,
      reason:
          "the positive control: the browser's WebView controller is listening",
    );
    expect(
      await onMethodChannel('inappbrowser_${browser.id}', 'onTitleChanged', {
        'title': 't',
      }),
      isNull,
      reason: 'nothing may be registered on the old MethodChannel any more',
    );
  });
}
