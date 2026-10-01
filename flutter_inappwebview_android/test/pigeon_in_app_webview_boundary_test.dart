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
    // W3
    'loadUrl', 'injectJavascriptFileFromUrl', 'injectCSSCode',
    'injectCSSFileFromUrl', 'setSettings', 'getSettings',
    'getCopyBackForwardList', 'scrollTo', 'scrollBy', 'printCurrentPage',
    'zoomBy', 'getZoomScale', 'getHitTestResult', 'pageDown', 'pageUp',
    'zoomIn', 'zoomOut', 'clearFocus', 'requestFocus', 'setContextMenu',
    'requestFocusNodeHref', 'requestImageRef', 'getScrollX', 'getScrollY',
    'getCertificate', 'addUserScript', 'removeUserScript',
    'removeUserScriptsByGroupName', 'removeAllUserScripts',
    'createWebMessageChannel', 'postWebMessage', 'addWebMessageListener',
    'canScrollVertically', 'canScrollHorizontally', 'isInFullscreen',
    'hideInputMethod', 'showInputMethod', 'saveState', 'restoreState',
    'setAudioMuted', 'isAudioMuted', 'flingScroll',
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

    // W3 (§212).

    test(
      'the W3 argument-taking methods send their arguments in order, maps as toMap()',
      () async {
        // No print job: printCurrentPage answers a nullable job id, not the default `true`.
        stubAll('inappwebview_7', {'printCurrentPage': null});
        final request = URLRequest(
          url: WebUri('https://example.com/load'),
          method: 'GET',
          headers: {'X-A': 'a'},
        );
        await c.loadUrl(
          urlRequest: request,
          allowingReadAccessTo: WebUri('file:///ignored'),
        );
        // `allowingReadAccessTo` is iOS's; the Android side never read it (§212).
        expect(sent['loadUrl'], [request.toMap()]);

        final scriptAttributes = ScriptHtmlTagAttributes(id: 'the-script');
        await c.injectJavascriptFileFromUrl(
          urlFile: WebUri('https://example.com/a.js'),
          scriptHtmlTagAttributes: scriptAttributes,
        );
        expect(sent['injectJavascriptFileFromUrl'], [
          'https://example.com/a.js',
          scriptAttributes.toMap(),
        ]);

        final cssAttributes = CSSLinkHtmlTagAttributes(id: 'the-css');
        await c.injectCSSFileFromUrl(
          urlFile: WebUri('https://example.com/a.css'),
          cssLinkHtmlTagAttributes: cssAttributes,
        );
        expect(sent['injectCSSFileFromUrl'], [
          'https://example.com/a.css',
          cssAttributes.toMap(),
        ]);

        await c.injectCSSCode(source: 'body{}');
        expect(sent['injectCSSCode'], ['body{}']);

        final settings = InAppWebViewSettings(minimumFontSize: 13);
        await c.setSettings(settings: settings);
        expect(sent['setSettings'], [settings.toMap()]);

        // Distinct x and y, and a different pair for each method.
        await c.scrollTo(x: 3, y: 4, animated: true);
        expect(sent['scrollTo'], [3, 4, true]);
        await c.scrollBy(x: 5, y: 6);
        expect(sent['scrollBy'], [5, 6, false]);
        await c.flingScroll(velocityX: 7, velocityY: 8);
        expect(sent['flingScroll'], [7, 8]);

        final printSettings = PrintJobSettings(jobName: 'the-job');
        await c.printCurrentPage(settings: printSettings);
        expect(sent['printCurrentPage'], [printSettings.toMap()]);

        // `animated` is iOS's; the Android side never read it (§212).
        await c.zoomBy(zoomFactor: 2.5, animated: true);
        expect(sent['zoomBy'], [2.5]);

        final rect = InAppWebViewRect(x: 1, y: 2, width: 3, height: 4);
        await c.requestFocus(
          direction: FocusDirection.DOWN,
          previouslyFocusedRect: rect,
        );
        expect(sent['requestFocus'], [
          FocusDirection.DOWN.toNativeValue(),
          rect.toMap(),
        ]);

        final menu = ContextMenu(
          menuItems: [ContextMenuItem(id: 9, title: 'x')],
        );
        await c.setContextMenu(menu);
        expect(sent['setContextMenu'], [menu.toMap()]);

        await c.pageDown(bottom: true);
        expect(sent['pageDown'], [true]);
        await c.pageUp(top: false);
        expect(sent['pageUp'], [false]);

        await c.restoreState(Uint8List.fromList([4, 2]));
        expect(sent['restoreState'], [
          Uint8List.fromList([4, 2]),
        ]);

        await c.postWebMessage(
          message: WebMessage(data: 'the-message'),
          targetOrigin: WebUri('https://example.com'),
        );
        expect(sent['postWebMessage'], [
          WebMessage(data: 'the-message').toMap(),
          'https://example.com',
        ]);
      },
    );

    test(
      'the user-script methods send the script, and removeUserScript its index',
      () async {
        final start = UserScript(
          source: 'var a = 1;',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          groupName: 'the-group',
        );
        final second = UserScript(
          source: 'var b = 2;',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        );
        await c.addUserScripts(userScripts: [start, second]);
        expect(sent['addUserScript'], [second.toMap()]);

        // `second` is at index 1 among the document-start scripts.
        await c.removeUserScript(userScript: second);
        expect(sent['removeUserScript'], [1, second.toMap()]);

        await c.removeUserScriptsByGroupName(groupName: 'the-group');
        expect(sent['removeUserScriptsByGroupName'], ['the-group']);

        await c.removeAllUserScripts();
        expect(sent['removeAllUserScripts'], isEmpty);
      },
    );

    test('the W3 answers map back, each from its own method', () async {
      // Values chosen so a crossed wire fails: x ≠ y, and the bool pairs answer differently.
      stubAll('inappwebview_7', {
        'getSettings': InAppWebViewSettings(minimumFontSize: 31).toMap(),
        'getZoomScale': 1.75,
        'getHitTestResult': {'type': 5, 'extra': 'the-extra'},
        'requestFocusNodeHref': {
          'url': 'https://example.com/href',
          'title': 'the-title',
          'src': 'https://example.com/src',
        },
        'requestImageRef': {'url': 'https://example.com/image'},
        'getScrollX': 11,
        'getScrollY': 22,
        'canScrollVertically': true,
        'canScrollHorizontally': false,
        'isInFullscreen': true,
        'zoomIn': true,
        'zoomOut': false,
        'pageDown': true,
        'pageUp': false,
        'requestFocus': true,
        'printCurrentPage': 'the-job-id',
        'saveState': Uint8List.fromList([1, 2, 3]),
        'restoreState': true,
        'isAudioMuted': true,
      });
      expect((await c.getSettings())?.minimumFontSize, 31);
      expect(await c.getZoomScale(), 1.75);
      final hit = await c.getHitTestResult();
      expect(hit?.type, InAppWebViewHitTestResultType.fromNativeValue(5));
      expect(hit?.extra, 'the-extra');
      final href = await c.requestFocusNodeHref();
      expect(href?.url, WebUri('https://example.com/href'));
      expect(href?.title, 'the-title');
      expect(href?.src, 'https://example.com/src');
      expect(
        (await c.requestImageRef())?.url,
        WebUri('https://example.com/image'),
      );
      expect(await c.getScrollX(), 11);
      expect(await c.getScrollY(), 22);
      expect(await c.canScrollVertically(), isTrue);
      expect(await c.canScrollHorizontally(), isFalse);
      expect(await c.isInFullscreen(), isTrue);
      expect(await c.zoomIn(), isTrue);
      expect(await c.zoomOut(), isFalse);
      expect(await c.pageDown(bottom: true), isTrue);
      expect(await c.pageUp(top: true), isFalse);
      expect(await c.requestFocus(), isTrue);
      expect(
        (await c.printCurrentPage())?.id,
        'the-job-id',
        reason: 'the job id becomes the print job controller id',
      );
      expect(await c.saveState(), Uint8List.fromList([1, 2, 3]));
      expect(await c.restoreState(Uint8List(0)), isTrue);
      expect(await c.isAudioMuted(), isTrue);
    });

    test(
      "postWebMessage's platform failure keeps the code and message it had",
      () async {
        messenger.setMockMessageHandler(
          '$prefix.postWebMessage.inappwebview_7',
          (message) async => codec.encodeMessage(<Object?>[
            'WebViewChannelDelegate',
            'the platform refused',
            null,
          ]),
        );
        await expectLater(
          c.postWebMessage(message: WebMessage(data: 'x')),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'WebViewChannelDelegate')
                .having((e) => e.message, 'message', 'the platform refused'),
          ),
        );
      },
    );

    test('no host method reaches the MethodChannel any more', () async {
      stubAll('inappwebview_7', {
        'getSettings': null,
        'getCopyBackForwardList': null,
        'getZoomScale': null,
        'getHitTestResult': null,
        'requestFocusNodeHref': null,
        'requestImageRef': null,
        'getScrollX': null,
        'getScrollY': null,
        'getCertificate': null,
        'createWebMessageChannel': null,
        'printCurrentPage': null,
        'saveState': null,
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

      await c.loadUrl(urlRequest: URLRequest(url: WebUri('https://e.com')));
      await c.injectJavascriptFileFromUrl(urlFile: WebUri('https://e.com/a'));
      await c.injectCSSCode(source: 'x');
      await c.injectCSSFileFromUrl(urlFile: WebUri('https://e.com/b'));
      await c.setSettings(settings: InAppWebViewSettings());
      await c.getSettings();
      await c.getCopyBackForwardList();
      await c.scrollTo(x: 1, y: 1);
      await c.scrollBy(x: 1, y: 1);
      await c.printCurrentPage();
      await c.zoomBy(zoomFactor: 2);
      await c.getZoomScale();
      await c.getHitTestResult();
      await c.pageDown(bottom: true);
      await c.pageUp(top: true);
      await c.zoomIn();
      await c.zoomOut();
      await c.clearFocus();
      await c.requestFocus();
      await c.setContextMenu(null);
      await c.requestFocusNodeHref();
      await c.requestImageRef();
      await c.getScrollX();
      await c.getScrollY();
      await c.getCertificate();
      final script = UserScript(
        source: 'x',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
      );
      await c.addUserScript(userScript: script);
      await c.removeUserScript(userScript: script);
      await c.removeUserScriptsByGroupName(groupName: 'g');
      await c.removeAllUserScripts();
      await c.createWebMessageChannel();
      await c.postWebMessage(message: WebMessage(data: 'x'));
      await c.canScrollVertically();
      await c.canScrollHorizontally();
      await c.isInFullscreen();
      await c.hideInputMethod();
      await c.showInputMethod();
      await c.saveState();
      await c.restoreState(Uint8List(0));
      await c.setAudioMuted(true);
      await c.isAudioMuted();
      await c.flingScroll(velocityX: 1, velocityY: 1);
      // `addWebMessageListener` needs a real listener; the device pins it (web_message.dart).
      expect(onMethodChannel, isEmpty);
      expect(sent.length, 41);
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
        expect(await c.getSettings(), isNull);
        expect(await c.getScrollX(), isNull);
        expect(await c.canScrollVertically(), isFalse);
        expect(await c.isInFullscreen(), isFalse);
        expect(await c.pageDown(bottom: true), isFalse);
        expect(await c.restoreState(Uint8List(0)), isFalse);
        expect(await c.printCurrentPage(), isNull);
        await c.loadUrl(urlRequest: URLRequest(url: WebUri('https://e.com')));
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
