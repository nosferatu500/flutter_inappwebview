part of 'main.dart';

void obscuredContentInsets() {
  final shouldSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.obscuredContentInsets,
      ) ||
      defaultTargetPlatform != TargetPlatform.iOS ||
      // iOS 26.0+ only, and unlike a bool there is no meaningful pre-26 behaviour to assert: the
      // property does not exist, so `getSettings()` can only echo what Dart sent.
      (_iosMajorVersion() ?? 0) < 26;

  final url = TEST_CROSS_PLATFORM_URL_1;

  // The mirror image of `screen_time.dart`'s creation-only test, and the reason both exist:
  // `obscuredContentInsets` lives on the `WKWebView`, not on its configuration, so it is **not**
  // subject to §95's copy-on-access rule and `setSettings` really changes it. If this test ever
  // starts behaving like the creation-only one, the apply site has been moved into the
  // configuration by mistake.
  skippableTestWidgets(
    'obscuredContentInsets is applied at creation and is live',
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
              obscuredContentInsets: const EdgeInsets.only(top: 44, bottom: 20),
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

      var settings = await controller.getSettings();
      expect(settings, isNotNull);
      expect(
        settings!.obscuredContentInsets,
        const EdgeInsets.only(top: 44, bottom: 20),
        reason: 'the creation-time value must reach the WKWebView',
      );

      await controller.setSettings(
        settings: InAppWebViewSettings(
          obscuredContentInsets: const EdgeInsets.only(top: 8, left: 12),
        ),
      );

      settings = await controller.getSettings();
      expect(settings, isNotNull);
      expect(
        settings!.obscuredContentInsets,
        const EdgeInsets.only(top: 8, left: 12),
        reason:
            'a WKWebView property, so setSettings must change it — unlike the '
            'configuration-backed settings',
      );
    },
    skip: shouldSkip,
  );

  // **There is deliberately no test here for what the *page* sees.**
  //
  // WebKit's header promises that the insets "shrink the bounds of the layout viewport" and that
  // fixed/sticky elements are adjusted near an inset edge. Trying to pin that from this harness
  // produced three different answers in three framings on the same simulator and the same binary:
  //
  //   two WebViews, insets set at creation, run alone   window.innerHeight delta 64, env unchanged
  //   one WebView, insets set via setSettings, alone    delta 64, but env(safe-area-inset-top)
  //                                                    read 0px before and 18px after
  //   one WebView, insets via setSettings, full group   delta 108, not 64
  //
  // A measurement that disagrees with itself is not evidence either way (traps 21 and 38), and an
  // assertion that changes its verdict between an isolated run and a group run would poison every
  // future baseline. So the page-visible behaviour is left unclaimed — in this file and in the
  // dartdoc — and the tests above pin what this plugin is actually responsible for: the value
  // reaches `WKWebView.obscuredContentInsets` and can be read back, at creation and live.
}
