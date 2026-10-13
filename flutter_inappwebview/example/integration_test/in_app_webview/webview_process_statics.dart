part of 'main.dart';

/// Device coverage for the `InAppWebViewManager` static methods that had none (§187), written before
/// migrating that channel to Pigeon, per rule 2.
///
/// Seven of the channel's fifteen methods were never called on a device. Four are safe to run inside
/// this group and are here; the other three change irreversible process-wide WebView state
/// (`disableWebView`, `enableSlowWholeDocumentDraw`) and live in `integration_test/process_isolated/`,
/// each run as its own process. Every expected value below was **measured on the device first**
/// (Pixel_10, API 37), not assumed from the docs.
void webViewProcessStatics() {
  skippableTest(
    'getVariationsHeader answers the header when supported',
    () async {
      final supported = await WebViewFeature.isFeatureSupported(
        WebViewFeature.GET_VARIATIONS_HEADER,
      );
      final header = await InAppWebViewController.getVariationsHeader();
      if (!supported) {
        // The Kotlin side answers null rather than throwing where the feature is missing.
        expect(header, isNull);
        return;
      }
      // A non-empty base64 value on the measured WebView (`CIj4ygEI…`). Asserted as non-empty rather
      // than non-null: an empty string would mean the value crossed but carried nothing.
      expect(header, isNotNull);
      expect(header, isNotEmpty);
    },
    skip: !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.getVariationsHeader,
    ),
  );

  skippableTest(
    'isMultiProcessEnabled is true on a multi-process WebView',
    () async {
      if (!await WebViewFeature.isFeatureSupported(
        WebViewFeature.MULTI_PROCESS,
      )) {
        markTestSkipped('MULTI_PROCESS unsupported');
        return;
      }
      // Every WebView since Android O runs its renderer out of process, and this fork's minSdk is 30.
      // `true` also cannot be produced by the Dart side's `?? false` fallback, so it proves the answer
      // crossed.
      expect(await InAppWebViewController.isMultiProcessEnabled(), isTrue);
    },
    skip: !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.isMultiProcessEnabled,
    ),
  );

  skippableTest(
    'setDefaultTrafficStatsTag reports that it applied',
    () async {
      final supported = await WebViewFeature.isFeatureSupported(
        WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING,
      );
      // ⚠️ Transport and return value only: there is no getter for the tag, so its effect (how the
      // WebView's traffic is accounted) is not observable here. The answer is the gate's own verdict:
      // `true` where the feature exists, `false` where the Kotlin side skipped the call.
      expect(
        await InAppWebViewController.setDefaultTrafficStatsTag(42),
        supported,
      );
    },
    skip: !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.setDefaultTrafficStatsTag,
    ),
  );

  skippableTestWidgets(
    'setJavaScriptBridgeName renames the bridge on a new page',
    (WidgetTester tester) async {
      const renamed = 'renamed_bridge';
      final original = await InAppWebViewController.getJavaScriptBridgeName();
      // The documented default, and the value every other test in this group depends on.
      expect(original, 'flutter_inappwebview');

      try {
        await InAppWebViewController.setJavaScriptBridgeName(renamed);
        expect(await InAppWebViewController.getJavaScriptBridgeName(), renamed);

        // The effect, not just the round trip: a WebView created *after* the rename exposes the bridge
        // under the new name and no longer under the old one. (Documented as applying only to WebViews
        // created afterwards, which is why a fresh one is built here.)
        final loaded = Completer<InAppWebViewController>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(
                data: '<html><body>bridge</body></html>',
              ),
              onLoadStop: (controller, url) {
                if (!loaded.isCompleted) {
                  loaded.complete(controller);
                }
              },
            ),
          ),
        );
        final controller = await loaded.future;
        expect(
          await controller.evaluateJavascript(source: 'typeof window.$renamed'),
          'object',
        );
        expect(
          await controller.evaluateJavascript(
            source: 'typeof window.flutter_inappwebview',
          ),
          'undefined',
        );
      } finally {
        // Process-global: every WebView created later in the run needs the default name back.
        await InAppWebViewController.setJavaScriptBridgeName(original);
      }
      expect(await InAppWebViewController.getJavaScriptBridgeName(), original);
    },
    skip: !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.setJavaScriptBridgeName,
    ),
  );
}
