import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/chrome_safari_browser_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the Custom Tabs manager channel (§201), the twentieth migrated to Pigeon
/// and the second under §194's decision B. Every message goes through the **real generated codec**
/// on the real channel names; it pins the Dart half of the new data class. The Kotlin half (data
/// class field → Bundle key → what Chrome requests) is pinned on the device by §200.
///
/// Every string below is different, so a transposition between any two same-typed fields fails.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ChromeSafariBrowserManagerHostApi.pigeonChannelCodec;
  const channelPrefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.ChromeSafariBrowserManagerHostApi';
  const methods = [
    'open',
    'isAvailable',
    'getMaxToolbarItems',
    'getPackageName',
  ];

  final sent = <String, List<Object?>>{};

  void stub(String method, List<Object?> envelope) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$channelPrefix.$method', (message) async {
          sent[method] = (codec.decodeMessage(message) as List<Object?>?) ?? [];
          return codec.encodeMessage(envelope);
        });
  }

  ChromeSafariBrowserOpenRequestData openRequest() =>
      sent['open']!.single as ChromeSafariBrowserOpenRequestData;

  AndroidChromeSafariBrowser newBrowser() =>
      AndroidChromeSafariBrowser(AndroidChromeSafariBrowserCreationParams());

  setUp(() {
    sent.clear();
    stub('open', <Object?>[true]);
  });

  tearDown(() {
    for (final m in methods) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('$channelPrefix.$m', null);
    }
  });

  group('open', () {
    test('puts each value in its own field', () async {
      final browser = newBrowser();
      await browser.open(
        url: WebUri('https://example.com/url'),
        headers: {'accept-language': 'it-IT'},
        referrer: WebUri('https://example.com/referrer'),
        otherLikelyURLs: [WebUri('https://example.com/likely')],
      );

      final r = openRequest();
      expect(r.id, browser.id);
      expect(r.url, 'https://example.com/url');
      expect(r.headers, {'accept-language': 'it-IT'});
      expect(r.referrer, 'https://example.com/referrer');
      expect(r.otherLikelyURLs, ['https://example.com/likely']);
    });

    test('with nothing set, sends the defaults it always sent', () async {
      await newBrowser().open();

      final r = openRequest();
      expect(r.url, isNull);
      expect(r.headers, isNull);
      expect(r.referrer, isNull);
      expect(r.otherLikelyURLs, isNull);
      expect(r.settings, ChromeSafariBrowserSettings().toMap());
      expect(r.actionButton, isNull);
      expect(r.secondaryToolbar, isNull);
      expect(r.menuItemList, isEmpty);
    });

    test('the settings map keeps its nested int and its null keys', () async {
      final settings = ChromeSafariBrowserSettings(
        isSingleInstance: null,
        displayMode: TrustedWebActivityImmersiveDisplayMode(
          isSticky: true,
          displayCutoutMode: LayoutInDisplayCutoutMode.SHORT_EDGES,
        ),
      );
      await newBrowser().open(settings: settings);

      final r = openRequest();
      expect(r.settings, settings.toMap());
      // §200's null-key test needs a present key with a null value, not an absent key.
      expect(r.settings.containsKey('isSingleInstance'), isTrue);
      expect(r.settings['isSingleInstance'], isNull);
      expect(
        (r.settings['displayMode'] as Map)['displayCutoutMode'],
        LayoutInDisplayCutoutMode.SHORT_EDGES.toNativeValue(),
      );
    });

    test(
      'the action button, secondary toolbar and menu items are their maps',
      () async {
        final browser = newBrowser();
        final actionButton = ChromeSafariBrowserActionButton(
          id: 11,
          description: 'the-description',
          icon: Uint8List.fromList([1, 2, 3]),
        );
        final toolbar = ChromeSafariBrowserSecondaryToolbar(
          layout: AndroidResource.layout(name: 'the_layout'),
          clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(name: 'the_button'),
            ),
          ],
        );
        final menuItem = ChromeSafariBrowserMenuItem(
          id: 12,
          label: 'the-label',
        );
        browser.setActionButton(actionButton);
        browser.setSecondaryToolbar(toolbar);
        browser.addMenuItem(menuItem);
        await browser.open();

        final r = openRequest();
        expect(r.actionButton, actionButton.toMap());
        expect(r.secondaryToolbar, toolbar.toMap());
        // The list is a lazy `cast` view, whose elements the codec built as `Map<Object?, Object?>`.
        final items = r.menuItemList.cast<Object?>().toList();
        expect(items, [menuItem.toMap()]);
      },
    );

    test('a platform error arrives as the same PlatformException', () async {
      // What Kotlin's `throw FlutterError(LOG_TAG, "ChromeCustomTabs is not available!", null)`
      // sends: Pigeon's error envelope is [code, message, details].
      stub('open', <Object?>[
        'ChromeBrowserManager',
        'ChromeCustomTabs is not available!',
        null,
      ]);
      await expectLater(
        newBrowser().open(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'ChromeBrowserManager')
              .having(
                (e) => e.message,
                'message',
                'ChromeCustomTabs is not available!',
              ),
        ),
      );
    });
  });

  group('the static methods', () {
    test('isAvailable returns what the platform answered, both ways', () async {
      final browser = AndroidChromeSafariBrowser.static();
      stub('isAvailable', <Object?>[true]);
      expect(await browser.isAvailable(), isTrue);
      stub('isAvailable', <Object?>[false]);
      expect(await browser.isAvailable(), isFalse);
      expect(sent['isAvailable'], isEmpty);
    });

    test('getMaxToolbarItems returns the platform value', () async {
      stub('getMaxToolbarItems', <Object?>[5]);
      expect(await AndroidChromeSafariBrowser.static().getMaxToolbarItems(), 5);
    });

    test(
      'getPackageName sends both arguments and returns the answer',
      () async {
        final browser = AndroidChromeSafariBrowser.static();
        stub('getPackageName', <Object?>['com.example.browser']);
        expect(
          await browser.getPackageName(
            packages: ['com.example.a', 'com.example.b'],
            ignoreDefault: true,
          ),
          'com.example.browser',
        );
        expect(sent['getPackageName'], [
          ['com.example.a', 'com.example.b'],
          true,
        ]);

        stub('getPackageName', <Object?>[null]);
        expect(await browser.getPackageName(), isNull);
        expect(sent['getPackageName'], [null, false]);
      },
    );
  });
}
