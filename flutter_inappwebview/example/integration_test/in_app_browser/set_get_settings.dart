part of 'main.dart';

void setGetSettings() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('set/get settings', () async {
    var inAppBrowser = MyInAppBrowser();
    await inAppBrowser.openUrlRequest(
      urlRequest: URLRequest(url: TEST_URL_1),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hideToolbarTop: true),
      ),
    );
    await inAppBrowser.browserCreated.future;
    await inAppBrowser.firstPageLoaded.future;

    InAppBrowserClassSettings? settings = await inAppBrowser.getSettings();
    expect(settings, isNotNull);
    expect(settings!.browserSettings.hideToolbarTop, true);

    await inAppBrowser.setSettings(
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hideToolbarTop: false),
      ),
    );

    settings = await inAppBrowser.getSettings();
    expect(settings, isNotNull);
    expect(settings!.browserSettings.hideToolbarTop, false);

    await expectLater(inAppBrowser.close(), completes);
  }, skip: shouldSkip);

  final androidOnly =
      shouldSkip || defaultTargetPlatform != TargetPlatform.android;

  skippableTest('setSettings carries its ints and colors intact', () async {
    // The `open` path has this check (§196); this is the same for `setSettings`, whose map Pigeon
    // delivers with its ints as Long unless they are normalized (§197, §199). Neither value is a
    // default, and each can only come back from its own field.
    var inAppBrowser = MyInAppBrowser();
    await inAppBrowser.openData(data: '<html><body>settings</body></html>');
    await inAppBrowser.firstPageLoaded.future;

    await inAppBrowser.setSettings(
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(minimumFontSize: 31),
        browserSettings: InAppBrowserSettings(
          toolbarTopBackgroundColor: const Color(0xFF7B1FA2),
        ),
      ),
    );

    final settings = await inAppBrowser.getSettings();
    expect(settings?.webViewSettings.minimumFontSize, 31);
    expect(
      settings?.browserSettings.toolbarTopBackgroundColor,
      const Color(0xFF7B1FA2),
    );

    await expectLater(inAppBrowser.close(), completes);
  }, skip: androidOnly);

  skippableTest('the browser WebView has its own settings pair', () async {
    // The browser's WebView controller shares the browser's MethodChannel, and its setSettings /
    // getSettings stayed there when the browser's own pair moved to Pigeon (§199).
    var inAppBrowser = MyInAppBrowser();
    await inAppBrowser.openData(data: '<html><body>settings</body></html>');
    await inAppBrowser.firstPageLoaded.future;
    final controller = inAppBrowser.webViewController!;

    await controller.setSettings(
      settings: InAppWebViewSettings(minimumFontSize: 27),
    );

    expect((await controller.getSettings())?.minimumFontSize, 27);
    // The same WebView, seen through the browser's own getter.
    expect(
      (await inAppBrowser.getSettings())?.webViewSettings.minimumFontSize,
      27,
    );

    await expectLater(inAppBrowser.close(), completes);
  }, skip: androidOnly);

  skippableTest(
    'the WebView controller setSettings leaves the browser settings alone',
    () async {
      // §206. The controller's map carries no browser keys, and until §206 the browser Activity
      // parsed it into a fresh `InAppBrowserSettings`, so every browser setting not read live came
      // back as a default. The colour and the title are two of those seven.
      var inAppBrowser = MyInAppBrowser();
      await inAppBrowser.openData(
        data: '<html><body>settings</body></html>',
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: const Color(0xFF0A8F3C),
            toolbarTopFixedTitle: 'Fixed Title',
          ),
        ),
      );
      await inAppBrowser.firstPageLoaded.future;

      await inAppBrowser.webViewController!.setSettings(
        settings: InAppWebViewSettings(minimumFontSize: 27),
      );

      final settings = await inAppBrowser.getSettings();
      // The control: the controller's own setting did apply.
      expect(settings?.webViewSettings.minimumFontSize, 27);
      expect(
        settings?.browserSettings.toolbarTopBackgroundColor,
        const Color(0xFF0A8F3C),
      );
      expect(settings?.browserSettings.toolbarTopFixedTitle, 'Fixed Title');

      await expectLater(inAppBrowser.close(), completes);
    },
    skip: androidOnly,
  );
}
