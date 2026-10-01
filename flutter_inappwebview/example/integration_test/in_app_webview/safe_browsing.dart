part of 'main.dart';

void safeBrowsing() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onSafeBrowsingHit,
  );

  skippableGroup('safe browsing', () {
    // The URL alone does not show the answer was used: the platform's own interstitial also ends
    // in `onLoadStop` for this URL. Measured on API 37 (§215): with no answer the hit is reported
    // twice, each followed by an UNSAFE_RESOURCE error, and the page has no title. PROCEED loads
    // the match page itself, titled "Safe Browsing", with no error.
    skippableTestWidgets('onSafeBrowsingHit', (WidgetTester tester) async {
      final Completer<String> pageLoaded = Completer<String>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final errors = <String>[];
      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: TEST_CHROME_SAFE_BROWSING_MALWARE,
            ),
            initialSettings: InAppWebViewSettings(
              // if I set javaScriptEnabled to true, it will crash!
              javaScriptEnabled: false,
              safeBrowsingEnabled: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) pageLoaded.complete(url!.toString());
            },
            onReceivedError: (controller, request, error) {
              errors.add('${error.type}');
            },
            onSafeBrowsingHit: (controller, url, threatType) async {
              return SafeBrowsingResponse(
                report: true,
                action: SafeBrowsingResponseAction.PROCEED,
              );
            },
          ),
        ),
      );

      final String url = await pageLoaded.future;
      expect(url, TEST_CHROME_SAFE_BROWSING_MALWARE.toString());

      if (defaultTargetPlatform == TargetPlatform.android) {
        final controller = await controllerCompleter.future;
        expect(await controller.getTitle(), 'Safe Browsing');
        expect(errors, isEmpty);
      }
    });

    skippableTest('getSafeBrowsingPrivacyPolicyUrl', () async {
      expect(
        await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl(),
        isNotNull,
      );
    });

    skippableTest('setSafeBrowsingAllowlist', () async {
      expect(
        await InAppWebViewController.setSafeBrowsingAllowlist(
          hosts: ["flutter.dev", "github.com"],
        ),
        true,
      );
    });
  }, skip: shouldSkip);
}
