part of 'main.dart';

/// Pins an asymmetry in [PlatformInAppWebViewController.loadUrl] that is WebKit's, not the plugin's,
/// and that nothing documented until §123 measured it.
///
/// Passing `allowingReadAccessTo` makes iOS load the page with
/// `WKWebView.loadFileURL:allowingReadAccessToURL:`, which takes **only a URL** — so the rest of the
/// caller's [URLRequest] is discarded. Omit `allowingReadAccessTo` and the very same Dart call goes
/// through `WKWebView.load(_:)`, which keeps it. Two behaviours for one API, selected by an argument
/// that is about filesystem scope and has nothing to do with headers.
///
/// **A5 was the obvious fix and it is measurably not one.** iOS 15 added
/// `loadFileRequest:allowingReadAccessToURL:`, which takes an `NSURLRequest`; swapping to it on
/// iOS 26.5 produced a byte-identical navigation request to `loadFileURL:` — same missing header,
/// same replaced timeout. WebKit reads only the URL out of it. So the row shipped this test and a
/// dartdoc instead of a code change.
///
/// All three rows of the measured table are asserted, and the first two are what make the third
/// mean anything: every `file://`-with-read-access assertion is negative, and a negative assertion
/// would also pass if `shouldOverrideUrlLoading` had simply stopped firing.
void loadFileUrlRequest() {
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.loadUrl,
      ) ||
      ![
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  skippableTestWidgets(
    'allowingReadAccessTo drops the rest of the URLRequest, and nothing else does',
    (WidgetTester tester) async {
      const probeHeader = 'X-Load-File-Request-Probe';
      const probeTimeout = 42.0;

      // One WebView for all three navigations, so nothing can differ except the call being made
      // (§107: two WebViews created seconds apart are not one experiment).
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final List<URLRequest> seen = <URLRequest>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) =>
                controllerCompleter.complete(controller),
            shouldOverrideUrlLoading: (controller, action) async {
              seen.add(action.request);
              return NavigationActionPolicy.ALLOW;
            },
          ),
        ),
      );

      final controller = await controllerCompleter.future;

      URLRequest probeRequest(WebUri url) => URLRequest(
        url: url,
        headers: {probeHeader: 'yes'},
        timeoutInterval: probeTimeout,
      );

      // `seen` is cleared first and then polled. Clearing matters more than it looks: the same file
      // URL is navigated to three times in this test, so matching on the URL alone would happily
      // return an earlier navigation's request — which is exactly the bug the throwaway probe
      // behind this test had, and it produced a confident wrong answer twice (§123).
      Future<URLRequest> navigateAndObserve(
        Future<void> Function() navigate,
        bool Function(URLRequest) matches,
      ) async {
        seen.clear();
        await navigate();
        for (var i = 0; i < 150; i++) {
          final match = seen.where(matches);
          if (match.isNotEmpty) return match.first;
          await tester.pump(const Duration(milliseconds: 100));
        }
        fail('no navigation observed; saw ${seen.map((r) => r.url).toList()}');
      }

      bool isFile(URLRequest r) => r.url.toString().startsWith('file://');

      // 1. http:// — the positive control. Everything survives, end to end.
      final http = await navigateAndObserve(
        () => controller.loadUrl(
          urlRequest: probeRequest(
            WebUri('http://${environment["NODE_SERVER_IP"]}:8082/echo-headers'),
          ),
        ),
        (r) => r.url.toString().contains('echo-headers'),
      );
      expect(http.headers?[probeHeader], 'yes');
      expect(http.timeoutInterval, probeTimeout);

      await controller.loadFile(
        assetFilePath:
            'test_assets/in_app_webview_javascript_handler_test.html',
      );
      await tester.pump(const Duration(seconds: 2));
      final fileUrl = (await controller.getUrl())!;
      final directory = WebUri(
        fileUrl.toString().substring(
          0,
          fileUrl.toString().lastIndexOf('/') + 1,
        ),
      );

      // 2. file:// with no read-access scope — goes through `load(_:)` and keeps everything, so a
      // `file://` URL is not itself the reason the header disappears in case 3.
      final fileWithoutScope = await navigateAndObserve(
        () => controller.loadUrl(urlRequest: probeRequest(fileUrl)),
        isFile,
      );
      expect(fileWithoutScope.headers?[probeHeader], 'yes');
      expect(fileWithoutScope.timeoutInterval, probeTimeout);

      // 3. file:// with a read-access scope — `loadFileURL:`, and the request is gone.
      final fileWithScope = await navigateAndObserve(
        () => controller.loadUrl(
          urlRequest: probeRequest(fileUrl),
          allowingReadAccessTo: directory,
        ),
        isFile,
      );
      expect(
        fileWithScope.headers?[probeHeader],
        isNull,
        reason:
            'If the header now arrives, WebKit has changed: correct loadUrl\'s dartdoc (and '
            're-check whether loadFileRequest is worth adopting after all) rather than relaxing '
            'this expectation.',
      );
      // WebKit substitutes its own file-load timeout. The observed value on iOS 26.5 is
      // 2147483647.0 (Int32.max); asserting "not the caller's" rather than that exact sentinel,
      // since the sentinel is undocumented and the claim being pinned is the discard.
      expect(fileWithScope.timeoutInterval, isNot(probeTimeout));

      // Deliberately not asserted: `cachePolicy`. WebKit's own default for a file load is
      // RELOAD_IGNORING_LOCAL_CACHE_DATA, which is exactly the non-default value a probe naturally
      // picks to prove the point — so it reads as "preserved" in all three cases and distinguishes
      // nothing. It cost §123 a wrong conclusion; leaving it out with the reason beats leaving a
      // green assertion that proves nothing (trap 30).
    },
    skip: shouldSkip,
  );
}
