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
      // The framework calls onSafeBrowsingHit from API 27; below that only the androidx client
      // can deliver it, when the WebView provides SAFE_BROWSING_HIT.
      final sdkInt = await androidSdkInt();
      if (sdkInt != null &&
          sdkInt < 27 &&
          !await WebViewFeature.isFeatureSupported(
            WebViewFeature.SAFE_BROWSING_HIT,
          )) {
        markTestSkipped('onSafeBrowsingHit needs API 27 or SAFE_BROWSING_HIT');
        return;
      }
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

    // Both answer null / false without their feature (framework API 27, or the WebView's androidx
    // support), which is reachable since minSdk 26.
    skippableTest('getSafeBrowsingPrivacyPolicyUrl', () async {
      if (defaultTargetPlatform == TargetPlatform.android &&
          !await WebViewFeature.isFeatureSupported(
            WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL,
          )) {
        markTestSkipped('SAFE_BROWSING_PRIVACY_POLICY_URL unsupported');
        return;
      }
      expect(
        await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl(),
        isNotNull,
      );
    });

    skippableTest('setSafeBrowsingAllowlist', () async {
      if (defaultTargetPlatform == TargetPlatform.android &&
          !await WebViewFeature.isFeatureSupported(
            WebViewFeature.SAFE_BROWSING_ALLOWLIST,
          )) {
        markTestSkipped('SAFE_BROWSING_ALLOWLIST unsupported');
        return;
      }
      expect(
        await InAppWebViewController.setSafeBrowsingAllowlist(
          hosts: ["flutter.dev", "github.com"],
        ),
        true,
      );
    });
  }, skip: shouldSkip);
}
