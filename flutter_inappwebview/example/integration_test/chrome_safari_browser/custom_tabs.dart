part of 'main.dart';

/// Why the two digital-asset-link tests are skipped, shared by `custom_tabs.dart` and
/// `trusted_web_activity.dart` so the two cannot drift apart (§178).
///
/// **Measured, not assumed.** `https://inappwebview.dev/.well-known/assetlinks.json` was fetched and
/// read; it delegates `common.use_as_origin` and `common.handle_all_urls` to exactly one app:
///
/// ```json
/// "package_name": "com.pichillilorenzo.flutter_inappwebviewexample",
/// "sha256_cert_fingerprints": ["D5:EB:66:89:63:83:62:9B:…"]
/// ```
///
/// This fork's example app is `dev.nosferatu500.inappwebview.example`, signed with a different key,
/// so the relation can never validate. It is not a plugin bug and no amount of retrying fixes it —
/// closing it needs a domain this repo controls, which is filed in TODO rather than faked here.
const String _assetLinksSkipReason =
    'digital asset links: inappwebview.dev delegates only to the upstream package '
    '(com.pichillilorenzo.flutter_inappwebviewexample) and its signing cert, so this fork '
    'cannot be verified as the origin';

void customTabs() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.launchUrl,
  );

  skippableGroup('Custom Tabs', () {
    skippableTest('custom referrer', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        referrer: WebUri("android-app://custom-referrer"),
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('single instance', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('add custom action button and update icon', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      var actionButtonIcon = await rootBundle.load(
        'test_assets/images/flutter-logo.png',
      );
      var actionButtonIcon2 = await rootBundle.load(
        'test_assets/images/flutter-logo.jpg',
      );
      chromeSafariBrowser.setActionButton(
        ChromeSafariBrowserActionButton(
          id: 1,
          description: 'Action Button description',
          icon: actionButtonIcon.buffer.asUint8List(),
          onClick: (url, title) {},
        ),
      );
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.updateActionButton(
        icon: actionButtonIcon2.buffer.asUint8List(),
        description: 'New Action Button description',
      );
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    }, skip: shouldSkip);

    skippableTest('mayLaunchUrl and launchUrl', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open();
      await expectLater(chromeSafariBrowser.serviceConnected.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(
        await chromeSafariBrowser.mayLaunchUrl(
          url: TEST_URL_1,
          otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1],
        ),
        true,
      );
      await chromeSafariBrowser.launchUrl(
        url: TEST_URL_1,
        headers: {'accept-language': 'it-IT'},
        otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1],
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('onNavigationEvent', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      expect(await chromeSafariBrowser.navigationEvent.future, isNotNull);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('add and update secondary toolbar', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      chromeSafariBrowser.setSecondaryToolbar(
        ChromeSafariBrowserSecondaryToolbar(
          layout: AndroidResource.layout(
            name: "remote_view",
            defPackage: "dev.nosferatu500.inappwebview.example",
          ),
          clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button1",
                defPackage: "dev.nosferatu500.inappwebview.example",
              ),
              onClick: (WebUri? url) {
                print("Button 1 with $url");
              },
            ),
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button2",
                defPackage: "dev.nosferatu500.inappwebview.example",
              ),
              onClick: (WebUri? url) {
                print("Button 2 with $url");
              },
            ),
          ],
        ),
      );
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.updateSecondaryToolbar(
        ChromeSafariBrowserSecondaryToolbar(
          layout: AndroidResource.layout(
            name: "remote_view_2",
            defPackage: "dev.nosferatu500.inappwebview.example",
          ),
          clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button3",
                defPackage: "dev.nosferatu500.inappwebview.example",
              ),
              onClick: (WebUri? url) {
                print("Button 3 with $url");
              },
            ),
          ],
        ),
      );
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    /// 🚨 **Blocked by digital asset links, permanently, and skipped *before* it opens anything.**
    ///
    /// Chrome opens a post-message channel only once it has verified that the calling app is
    /// delegated by the target origin. `https://inappwebview.dev/.well-known/assetlinks.json`
    /// declares exactly one app — **fetched and read, not assumed**:
    ///
    /// ```json
    /// "package_name": "com.pichillilorenzo.flutter_inappwebviewexample",
    /// "sha256_cert_fingerprints": ["D5:EB:66:89:…"]
    /// ```
    ///
    /// This fork's example app is `dev.nosferatu500.inappwebview.example`, signed with a different
    /// key, so `delegate_permission/common.use_as_origin` can never match. Nothing in the plugin can
    /// change that; it needs a domain this repo controls.
    ///
    /// **What that cost before the skip** (§178): `requestPostMessageChannel` answers `true` — it
    /// only means the request was accepted — and then `onMessageChannelReady` never fires, so the
    /// test hung for its full 60 s **without reaching `close()`**, leaving the Custom Tab on screen
    /// and taking down three later tests that pass in isolation.
    ///
    /// The skip is the first statement on purpose: skipping after `open()` would leave the tab up
    /// and re-create the cascade this removes.
    test('request and send post messages', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_CUSTOM_TABS_POST_MESSAGE_URL,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);

      await expectLater(
        chromeSafariBrowser.navigationFinished.future,
        completes,
      );
      expect(
        await chromeSafariBrowser.requestPostMessageChannel(
          sourceOrigin: WebUri(TEST_CUSTOM_TABS_POST_MESSAGE_URL.origin),
        ),
        true,
      );
      await expectLater(
        chromeSafariBrowser.messageChannelReady.future,
        completes,
      );
      expect(
        await chromeSafariBrowser.postMessage("Message from Flutter"),
        CustomTabsPostMessageResultType.SUCCESS,
      );
      await expectLater(
        chromeSafariBrowser.postMessageReceived.future,
        completion("Message from JavaScript"),
      );

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    }, skip: _assetLinksSkipReason);

    skippableTest('Engagement Signals Api', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);

      await expectLater(
        chromeSafariBrowser.isEngagementSignalsApiAvailable(),
        completes,
      );

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('getMaxToolbarItems', () async {
      expect(
        await ChromeSafariBrowser.getMaxToolbarItems(),
        greaterThanOrEqualTo(0),
      );
    });

    skippableTest('getPackageName', () async {
      expect(await ChromeSafariBrowser.getPackageName(), isNotNull);
    });
  }, skip: shouldSkip);
}
