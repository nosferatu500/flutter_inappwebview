import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-WebView channel's first Pigeon slice (§207, W1): 25 synchronous
/// load, navigation and state methods on `InAppWebViewHostApi`. Every message goes through the
/// **real generated codec** on the real channel names, so this pins the Dart half: each method on
/// its own channel, under the right suffix, with its arguments in order, and each answer mapped
/// back. The Kotlin half is pinned on the device by the in_app_webview group (§189–§193).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppWebViewHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppWebViewHostApi';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  const methods = [
    'getUrl', 'getTitle', 'getProgress', 'getOriginalUrl', 'postUrl', //
    'loadData', 'loadFile', 'reload', 'goBack', 'canGoBack', 'goForward',
    'canGoForward', 'goBackOrForward', 'canGoBackOrForward', 'stopLoading',
    'isLoading', 'clearHistory', 'clearSslPreferences', 'clearFormData',
    'pause', 'resume', 'pauseTimers', 'resumeTimers', 'prerenderUrl',
    'getContentHeight',
  ];

  /// What each method was sent, by method name.
  final sent = <String, List<Object?>>{};

  /// Stubs every method under [suffix], answering [answers] (default: `true`).
  void stubAll(String suffix, [Map<String, Object?> answers = const {}]) {
    for (final m in methods) {
      messenger.setMockMessageHandler('$prefix.$m.$suffix', (message) async {
        sent[m] = (codec.decodeMessage(message) as List<Object?>?) ?? [];
        return codec.encodeMessage(<Object?>[answers[m] ?? true]);
      });
    }
  }

  void clearAll(String suffix) {
    for (final m in methods) {
      messenger.setMockMessageHandler('$prefix.$m.$suffix', null);
    }
  }

  AndroidInAppWebViewController controller(Object id) =>
      AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(id: id),
      );

  setUp(sent.clear);

  group('a WebView the plugin builds, on suffix inappwebview_<id>', () {
    late AndroidInAppWebViewController c;

    setUp(() {
      stubAll('inappwebview_7', {
        'getUrl': 'https://example.com/url',
        'getTitle': 'the-title',
        'getProgress': 42,
        'getOriginalUrl': 'https://example.com/original',
        'canGoBack': true,
        'canGoForward': false,
        'canGoBackOrForward': true,
        'isLoading': true,
        'prerenderUrl': true,
        'getContentHeight': 1234,
      });
      c = controller(7);
    });

    tearDown(() => clearAll('inappwebview_7'));

    test('the getters map each answer back, each from its own method', () async {
      // Every value is different, so an answer read from the wrong channel fails.
      expect(await c.getUrl(), WebUri('https://example.com/url'));
      expect(await c.getTitle(), 'the-title');
      expect(await c.getProgress(), 42);
      expect(await c.getOriginalUrl(), WebUri('https://example.com/original'));
      expect(await c.canGoBack(), isTrue);
      expect(await c.canGoForward(), isFalse);
      expect(await c.isLoading(), isTrue);
      expect(await c.prerenderUrl(WebUri('https://example.com/p')), isTrue);
      expect(sent['prerenderUrl'], ['https://example.com/p']);
      expect(await c.getContentHeight(), 1234);
    });

    test('the argument-taking methods send their arguments in order', () async {
      await c.postUrl(
        url: WebUri('https://example.com/post'),
        postData: Uint8List.fromList([1, 2, 3]),
      );
      expect(sent['postUrl']![0], 'https://example.com/post');
      expect(sent['postUrl']![1], Uint8List.fromList([1, 2, 3]));

      await c.loadData(
        data: 'the-data',
        mimeType: 'the/mime',
        encoding: 'the-encoding',
        baseUrl: WebUri('https://example.com/base'),
        historyUrl: WebUri('https://example.com/history'),
      );
      expect(sent['loadData'], [
        'the-data',
        'the/mime',
        'the-encoding',
        'https://example.com/base',
        'https://example.com/history',
      ]);

      await c.loadFile(assetFilePath: 'assets/page.html');
      expect(sent['loadFile'], ['assets/page.html']);

      await c.goBackOrForward(steps: -2);
      expect(sent['goBackOrForward'], [-2]);
      expect(await c.canGoBackOrForward(steps: 3), isTrue);
      expect(sent['canGoBackOrForward'], [3]);
    });

    test(
      'loadData defaults both URLs to about:blank, and sends no allowingReadAccessTo',
      () async {
        await c.loadData(
          data: 'x',
          allowingReadAccessTo: WebUri('file:///ignored'),
        );
        // `allowingReadAccessTo` is iOS's; the Android side never read it (§207).
        expect(sent['loadData'], [
          'x',
          'text/html',
          'utf8',
          'about:blank',
          'about:blank',
        ]);
      },
    );

    test('the no-argument commands each reach their own method', () async {
      await c.reload();
      await c.goBack();
      await c.goForward();
      await c.stopLoading();
      await c.clearHistory();
      await c.clearSslPreferences();
      await c.clearFormData();
      await c.pause();
      await c.resume();
      await c.pauseTimers();
      await c.resumeTimers();
      expect(sent.keys.toSet(), {
        'reload',
        'goBack',
        'goForward',
        'stopLoading',
        'clearHistory',
        'clearSslPreferences',
        'clearFormData',
        'pause',
        'resume',
        'pauseTimers',
        'resumeTimers',
      });
    });

    test(
      'loadFile surfaces the platform error as the same PlatformException',
      () async {
        messenger.setMockMessageHandler(
          '$prefix.loadFile.inappwebview_7',
          (message) async => codec.encodeMessage(<Object?>[
            'WebViewChannelDelegate',
            'missing.html not found',
            null,
          ]),
        );
        await expectLater(
          c.loadFile(assetFilePath: 'missing.html'),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'WebViewChannelDelegate')
                .having((e) => e.message, 'message', 'missing.html not found'),
          ),
        );
      },
    );

    test(
      'getContentHeight falls back to JavaScript when the platform answers 0',
      () async {
        // The fallback still goes through the MethodChannel's evaluateJavascript (W2 moves it).
        stubAll('inappwebview_7', {'getContentHeight': 0});
        final channel = MethodChannel(
          'dev.nosferatu500.inappwebview/inappwebview_7',
        );
        messenger.setMockMethodCallHandler(channel, (call) async {
          return call.method == 'evaluateJavascript' ? 987 : null;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
        expect(await c.getContentHeight(), 987);
      },
    );

    test(
      'after dispose nothing is sent, and the queries answer their defaults',
      () async {
        c.dispose();
        expect(await c.getUrl(), isNull);
        expect(await c.canGoBack(), isFalse);
        expect(await c.isLoading(), isFalse);
        await c.reload();
        expect(sent, isEmpty);
      },
    );
  });

  test(
    'an in-app browser WebView uses suffix inappbrowser_<browser id>',
    () async {
      stubAll('inappbrowser_b1', {'getUrl': 'https://example.com/browser'});
      addTearDown(() => clearAll('inappbrowser_b1'));
      final c = AndroidInAppWebViewController.fromInAppBrowser(
        AndroidInAppWebViewControllerCreationParams(id: 'b1'),
        const MethodChannel('dev.nosferatu500.inappwebview/inappbrowser_b1'),
        AndroidInAppBrowser(AndroidInAppBrowserCreationParams()),
        null,
      );
      expect(await c.getUrl(), WebUri('https://example.com/browser'));
      expect(sent.keys, ['getUrl']);
    },
  );
}
