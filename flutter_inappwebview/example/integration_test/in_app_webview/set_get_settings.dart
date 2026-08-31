part of 'main.dart';

void setGetSettings() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getSettings,
  );

  final url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('set/get settings', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: false),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    // Platform view creation happens asynchronously.
    await tester.pumpAndSettle();
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    InAppWebViewSettings? settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, false);

    await controller.setSettings(
      settings: InAppWebViewSettings(javaScriptEnabled: true),
    );

    settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, true);
  }, skip: shouldSkip);

  // TODO.md P4d: on iOS a whole family of settings is creation-only, and this pins the contract
  // the dartdoc now states. `WKWebView.configuration` hands out a fresh copy on every access, so a
  // `configuration.x = y` in `setSettings` is discarded; only writes through the four shared
  // sub-objects (`preferences`, `defaultWebpagePreferences`, `userContentController`,
  // `websiteDataStore`) reach the live WebView.
  //
  // `getSettings` re-reads these from the real configuration, so this is observable from Dart.
  // `minimumFontSize` is the control: it goes through `preferences` and *must* change in the very
  // same call, otherwise the test would pass just as well against a `setSettings` that did nothing
  // at all.
  //
  // If the plugin ever recreates the WebView when a creation-only setting changes, this test is
  // supposed to fail — it is the record of a documented limitation, not of a desired one.
  skippableTestWidgets(
    'creation-only iOS settings are unchanged by setSettings',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            initialSettings: InAppWebViewSettings(
              suppressesIncrementalRendering: false,
              upgradeKnownHostsToHTTPS: true,
              allowsAirPlayForMediaPlayback: true,
              minimumFontSize: 8,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.setSettings(
        settings: InAppWebViewSettings(
          suppressesIncrementalRendering: true,
          upgradeKnownHostsToHTTPS: false,
          allowsAirPlayForMediaPlayback: false,
          minimumFontSize: 22,
        ),
      );

      final settings = await controller.getSettings();
      expect(settings, isNotNull);
      expect(settings!.minimumFontSize, 22, reason: 'the control must change');
      expect(settings.suppressesIncrementalRendering, false);
      expect(settings.upgradeKnownHostsToHTTPS, true);
      expect(settings.allowsAirPlayForMediaPlayback, true);
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.iOS,
  );
}
