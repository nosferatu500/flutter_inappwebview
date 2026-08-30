part of 'main.dart';

void onFaviconChanged() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onFaviconChanged,
  );

  skippableTestWidgets('onFaviconChanged', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<FaviconChangedRequest> onFaviconChangedCompleter =
        Completer<FaviconChangedRequest>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onFaviconChanged: (controller, request) {
            if (!onFaviconChangedCompleter.isCompleted) {
              onFaviconChangedCompleter.complete(request);
            }
          },
        ),
      ),
    );

    await pageLoaded.future;

    // `onFaviconChanged` is Android-only (iOS already skips this test), and on a modern Android
    // WebView its source — `WebChromeClient.onReceivedIcon` — is never dispatched. Measured on
    // API 33 and API 37:
    //
    //   * API 37: `WebViewFeature.DOWNLOAD_FAVICONS_ENABLED` reports **unsupported**, so favicons
    //     are not downloaded at all.
    //   * API 33: the feature is supported, `downloadFaviconsEnabled: true` reads back `true`, and
    //     with a page serving a real bitmap `.ico` the WebView **does** fetch it — `onLoadResource`
    //     shows the request for `favicon.ico` — yet `onReceivedIcon` still never fires.
    //
    // `onReceivedTitle` from the same `WebChromeClient` works, so the client is installed; the
    // callback is simply not delivered any more. `onReceivedIcon` was fed by `WebIconDatabase`,
    // deprecated since API 19 and now inert. Use `InAppWebViewController.getFavicons()` instead,
    // which reads the document's own `<link rel="icon">` tags and works.
    //
    // So this test cannot pass on any WebView available here. Skipping is the honest outcome —
    // failing costs 60s a run and asserts a platform promise that is not kept.
    markTestSkipped(
      'WebChromeClient.onReceivedIcon is not dispatched by modern Android '
      'WebView (WebIconDatabase is inert), so onFaviconChanged cannot fire. '
      'Use getFavicons() instead.',
    );
  }, skip: shouldSkip);
}
