import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-WebView channel's Pigeon slices on `InAppWebViewHostApi`: W1
/// (§207), 25 synchronous load, navigation and state methods, and W2 (§210), the nine that answer
/// from a callback. Every message goes through the **real generated codec** on the real channel
/// names, so this pins the Dart half: each method on its own channel, under the right suffix, with
/// its arguments in order, and each answer mapped back. The Kotlin half is pinned on the device by
/// the in_app_webview group (§189–§193, §209).
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
    // W2
    'evaluateJavascript', 'callAsyncJavaScript', 'takeScreenshot',
    'getContentWidth', 'getSelectedText', 'saveWebArchive', 'isSecureContext',
    'postVisualStateCallback', 'documentHasImages',
  ];

  /// What each method was sent, by method name.
  final sent = <String, List<Object?>>{};

  /// Stubs every method under [suffix], answering [answers] (default: `true`; an explicit `null`
  /// answers null).
  void stubAll(String suffix, [Map<String, Object?> answers = const {}]) {
    for (final m in methods) {
      messenger.setMockMessageHandler('$prefix.$m.$suffix', (message) async {
        sent[m] = (codec.decodeMessage(message) as List<Object?>?) ?? [];
        return codec.encodeMessage(<Object?>[
          answers.containsKey(m) ? answers[m] : true,
        ]);
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
      'getContentHeight and getContentWidth fall back to JavaScript when the platform answers 0',
      () async {
        // WebView reports the script's result as JSON text, which the controller decodes.
        stubAll('inappwebview_7', {
          'getContentHeight': 0,
          'getContentWidth': 0,
          'evaluateJavascript': '987',
        });
        expect(await c.getContentHeight(), 987);
        expect(sent['evaluateJavascript'], [
          'document.documentElement.scrollHeight;',
          null,
        ]);
        expect(await c.getContentWidth(), 987);
        expect(sent['evaluateJavascript'], [
          'document.documentElement.scrollWidth;',
          null,
        ]);
      },
    );

    // The device can't see this half: its JavaScript fallback answers the same width (rule 27, as
    // getContentHeight's K6 in §207). Only here does "the platform answered" show.
    test(
      'getContentWidth returns the platform answer without asking JavaScript',
      () async {
        stubAll('inappwebview_7', {'getContentWidth': 1234});
        expect(await c.getContentWidth(), 1234);
        expect(sent.keys, ['getContentWidth']);
      },
    );

    test(
      'evaluateJavascript sends the source and content world, and decodes JSON answers',
      () async {
        stubAll('inappwebview_7', {
          'evaluateJavascript': '[1, "a", {"b": true}]',
        });
        expect(
          await c.evaluateJavascript(
            source: 'the-source',
            contentWorld: ContentWorld.world(name: 'the-world'),
          ),
          [
            1,
            'a',
            {'b': true},
          ],
        );
        expect(sent['evaluateJavascript'], [
          'the-source',
          {'name': 'the-world'},
        ]);

        // Not JSON: returned as the text itself. No content world: sent as null.
        stubAll('inappwebview_7', {'evaluateJavascript': 'not json'});
        expect(await c.evaluateJavascript(source: 'plain'), 'not json');
        expect(sent['evaluateJavascript'], ['plain', null]);
      },
    );

    test(
      'callAsyncJavaScript sends body, arguments and content world, and decodes value and error',
      () async {
        stubAll('inappwebview_7', {
          'callAsyncJavaScript': '{"value": 49, "error": "the-error"}',
        });
        final result = await c.callAsyncJavaScript(
          functionBody: 'return x;',
          arguments: {
            'x': 49,
            'nested': {
              'n': [1, 2],
            },
          },
          contentWorld: ContentWorld.PAGE,
        );
        expect(result?.value, 49);
        expect(result?.error, 'the-error');
        expect(sent['callAsyncJavaScript'], [
          'return x;',
          {
            'x': 49,
            'nested': {
              'n': [1, 2],
            },
          },
          {'name': 'page'},
        ]);
      },
    );

    test(
      'takeScreenshot sends ScreenshotConfiguration.toMap() and returns the bytes',
      () async {
        stubAll('inappwebview_7', {
          'takeScreenshot': Uint8List.fromList([9, 8, 7]),
        });
        final configuration = ScreenshotConfiguration(
          rect: InAppWebViewRect(x: 1, y: 2, width: 3, height: 4),
          snapshotWidth: 5,
          compressFormat: CompressFormat.JPEG,
          quality: 6,
        );
        expect(
          await c.takeScreenshot(screenshotConfiguration: configuration),
          Uint8List.fromList([9, 8, 7]),
        );
        expect(sent['takeScreenshot'], [configuration.toMap()]);

        await c.takeScreenshot();
        expect(sent['takeScreenshot'], [null]);
      },
    );

    test(
      'the other W2 methods map each answer back, each from its own method',
      () async {
        // isSecureContext and documentHasImages answer differently, so a crossed wire fails.
        stubAll('inappwebview_7', {
          'getSelectedText': 'the-selection',
          'saveWebArchive': '/the/saved.mht',
          'isSecureContext': true,
          'documentHasImages': false,
          'postVisualStateCallback': null,
        });
        expect(await c.getSelectedText(), 'the-selection');
        expect(
          await c.saveWebArchive(filePath: '/the/dir', autoname: true),
          '/the/saved.mht',
        );
        expect(sent['saveWebArchive'], ['/the/dir', true]);
        expect(await c.isSecureContext(), isTrue);
        expect(await c.documentHasImages(), isFalse);
        await c.postVisualStateCallback();
        expect(sent.keys.toSet(), {
          'getSelectedText',
          'saveWebArchive',
          'isSecureContext',
          'documentHasImages',
          'postVisualStateCallback',
        });
      },
    );

    test('the W2 methods send nothing on the MethodChannel', () async {
      stubAll('inappwebview_7', {
        'evaluateJavascript': '1',
        'callAsyncJavaScript': '{"value": null, "error": null}',
        'takeScreenshot': null,
        'getContentWidth': 1,
        'getSelectedText': null,
        'saveWebArchive': null,
        'postVisualStateCallback': null,
      });
      final channel = MethodChannel(
        'dev.nosferatu500.inappwebview/inappwebview_7',
      );
      final onMethodChannel = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        onMethodChannel.add(call.method);
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await c.evaluateJavascript(source: '1');
      await c.callAsyncJavaScript(functionBody: 'return 1;');
      await c.takeScreenshot();
      await c.getContentWidth();
      await c.getSelectedText();
      await c.saveWebArchive(filePath: '/d', autoname: true);
      await c.isSecureContext();
      await c.postVisualStateCallback();
      await c.documentHasImages();
      expect(onMethodChannel, isEmpty);
      expect(sent.length, 9);
    });

    test(
      'after dispose nothing is sent, and the queries answer their defaults',
      () async {
        c.dispose();
        expect(await c.getUrl(), isNull);
        expect(await c.canGoBack(), isFalse);
        expect(await c.isLoading(), isFalse);
        await c.reload();
        expect(await c.evaluateJavascript(source: '1'), isNull);
        expect(await c.callAsyncJavaScript(functionBody: 'return 1;'), isNull);
        expect(await c.takeScreenshot(), isNull);
        expect(await c.isSecureContext(), isFalse);
        expect(await c.documentHasImages(), isFalse);
        await c.postVisualStateCallback();
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
