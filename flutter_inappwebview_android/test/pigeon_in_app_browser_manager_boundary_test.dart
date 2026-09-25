import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_browser_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the in-app browser manager channel (§197), the nineteenth migrated to
/// Pigeon and the first under §194's decision B. Every message goes through the **real generated
/// codec** on the real channel names; it pins the Dart half of the new data class. The Kotlin half
/// (data class field → Bundle key) is pinned on the device by §196.
///
/// Every string below is different, so a transposition between any two same-typed fields fails.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppBrowserManagerHostApi.pigeonChannelCodec;
  const channelPrefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppBrowserManagerHostApi';

  final sent = <String, List<Object?>>{};

  void stub(String method, List<Object?> envelope) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$channelPrefix.$method', (message) async {
          sent[method] = codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(envelope);
        });
  }

  /// The raw element of a list field. Pigeon's generated `decode` exposes `List<Map<String?,
  /// Object?>?>` fields as a lazy `cast` view, and the codec builds `Map<Object?, Object?>`, so
  /// reading an element through the view throws. That only happens here, where the *test* decodes
  /// what Dart sent; in production this class is decoded by Kotlin, whose casts are unchecked.
  Map<Object?, Object?> element(List<Object?> list) =>
      list.cast<Object?>().single as Map<Object?, Object?>;

  InAppBrowserOpenRequestData openRequest() =>
      sent['open']!.single as InAppBrowserOpenRequestData;

  setUp(() {
    sent.clear();
    stub('open', <Object?>[true]);
    stub('openWithSystemBrowser', <Object?>[true]);
  });

  tearDown(() {
    for (final m in ['open', 'openWithSystemBrowser']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('$channelPrefix.$m', null);
    }
  });

  group('open', () {
    test('openData puts each value in its own field', () async {
      final browser = AndroidInAppBrowser(AndroidInAppBrowserCreationParams());
      await browser.openData(
        data: 'the-data',
        mimeType: 'the/mime',
        encoding: 'the-encoding',
        baseUrl: WebUri('https://example.com/base'),
        historyUrl: WebUri('https://example.com/history'),
      );

      final r = openRequest();
      expect(r.id, browser.id);
      expect(r.data, 'the-data');
      expect(r.mimeType, 'the/mime');
      expect(r.encoding, 'the-encoding');
      expect(r.baseUrl, 'https://example.com/base');
      expect(r.historyUrl, 'https://example.com/history');
      expect(r.urlRequest, isNull);
      expect(r.assetFilePath, isNull);
    });

    test(
      'openData without URLs sends about:blank for both, as before',
      () async {
        final browser = AndroidInAppBrowser(
          AndroidInAppBrowserCreationParams(),
        );
        await browser.openData(data: 'x');

        final r = openRequest();
        expect(r.baseUrl, 'about:blank');
        expect(r.historyUrl, 'about:blank');
        expect(r.mimeType, 'text/html');
        expect(r.encoding, 'utf8');
      },
    );

    test('openUrlRequest sends the request as its map', () async {
      final browser = AndroidInAppBrowser(AndroidInAppBrowserCreationParams());
      await browser.openUrlRequest(
        urlRequest: URLRequest(
          url: WebUri('https://example.com/page'),
          headers: {'X-Header': 'value'},
        ),
      );

      final r = openRequest();
      expect(r.urlRequest?['url'], 'https://example.com/page');
      expect(r.urlRequest?['headers'], {'X-Header': 'value'});
      expect(r.data, isNull);
      expect(r.assetFilePath, isNull);
    });

    test('openFile sends the asset path', () async {
      final browser = AndroidInAppBrowser(AndroidInAppBrowserCreationParams());
      await browser.openFile(assetFilePath: 'assets/page.html');

      final r = openRequest();
      expect(r.assetFilePath, 'assets/page.html');
      expect(r.urlRequest, isNull);
      expect(r.data, isNull);
    });

    test(
      'the map-valued fields carry what their toMap() produced (§194, B)',
      () async {
        final browser = AndroidInAppBrowser(
          AndroidInAppBrowserCreationParams(
            windowId: 7,
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: 'window.a = 1;',
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
            ]),
          ),
        );
        browser.addMenuItem(InAppBrowserMenuItem(id: 5, title: 'Five'));
        await browser.openData(
          data: 'x',
          settings: InAppBrowserClassSettings(
            webViewSettings: InAppWebViewSettings(minimumFontSize: 22),
          ),
        );

        final r = openRequest();
        expect(r.windowId, 7);
        // An int nested in the untyped settings map crosses as an int. The device test in §196
        // checks that Kotlin still reads it as an `Int`.
        expect(r.settings['minimumFontSize'], 22);
        expect(element(r.initialUserScripts)['source'], 'window.a = 1;');
        expect(element(r.menuItems)['id'], 5);
        expect(element(r.menuItems)['title'], 'Five');
        expect(
          r.contextMenu,
          isEmpty,
          reason: 'no context menu is sent as {}, as before',
        );
        expect(r.pullToRefreshSettings['enabled'], false);
      },
    );
  });

  group('openWithSystemBrowser', () {
    test('sends the url', () async {
      await AndroidInAppBrowser.static().openWithSystemBrowser(
        url: WebUri('https://example.com/system'),
      );
      expect(sent['openWithSystemBrowser'], ['https://example.com/system']);
    });

    test('a platform error arrives as the same PlatformException', () async {
      // What Kotlin's `throw FlutterError(LOG_TAG, "<url> cannot be opened!", null)` sends: Pigeon's
      // error envelope is [code, message, details].
      stub('openWithSystemBrowser', <Object?>[
        'InAppBrowserManager',
        'bad://x cannot be opened!',
        null,
      ]);
      await expectLater(
        AndroidInAppBrowser.static().openWithSystemBrowser(
          url: WebUri('bad://x'),
        ),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'InAppBrowserManager')
              .having((e) => e.message, 'message', 'bad://x cannot be opened!'),
        ),
      );
    });
  });
}
