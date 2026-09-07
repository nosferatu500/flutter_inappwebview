part of 'main.dart';

void webViewAssetLoader() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.webViewAssetLoader,
  );

  skippableTestWidgets('WebViewAssetLoader', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_WEBVIEW_ASSET_LOADER_URL),
          initialSettings: InAppWebViewSettings(
            allowFileAccessFromFileURLs: false,
            allowUniversalAccessFromFileURLs: false,
            allowFileAccess: false,
            allowContentAccess: false,
            webViewAssetLoader: WebViewAssetLoader(
              domain: TEST_WEBVIEW_ASSET_LOADER_DOMAIN,
              pathHandlers: [AssetsPathHandler(path: '/assets/')],
            ),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete(url.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    final url = await pageLoaded.future;

    expect(url, TEST_WEBVIEW_ASSET_LOADER_URL.toString());

    expect(
      await controller.evaluateJavascript(
        source: "document.querySelector('h1').innerHTML",
      ),
      'WebViewAssetLoader',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('WebViewAssetLoader changed through setSettings', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    final assetsUrl = TEST_WEBVIEW_ASSET_LOADER_URL.toString();
    final otherAssetsUrl =
        'https://$TEST_WEBVIEW_ASSET_LOADER_DOMAIN/other-assets/flutter_assets/test_assets/website/index.html';

    // Settled only by a *main-frame* event for the URL currently awaited. Both
    // halves matter: keying on the URL stops an event from the previous page
    // ending the wait, and the main-frame check stops a failed subresource
    // (the page requests a favicon that no path handler serves) doing the same.
    // Completing on the error as well as on load stop means an unserved path
    // fails on the assertion below instead of hanging for the 60s timeout.
    var awaitedUrl = assetsUrl;
    var navigated = Completer<void>();
    void settle(String url, {required bool isForMainFrame}) {
      if (isForMainFrame && url == awaitedUrl && !navigated.isCompleted) {
        navigated.complete();
      }
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_WEBVIEW_ASSET_LOADER_URL),
          initialSettings: InAppWebViewSettings(
            allowFileAccessFromFileURLs: false,
            allowUniversalAccessFromFileURLs: false,
            allowFileAccess: false,
            allowContentAccess: false,
            webViewAssetLoader: WebViewAssetLoader(
              domain: TEST_WEBVIEW_ASSET_LOADER_DOMAIN,
              pathHandlers: [AssetsPathHandler(path: '/assets/')],
            ),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          // onLoadStop is main-frame only.
          onLoadStop: (controller, url) =>
              settle(url.toString(), isForMainFrame: true),
          onReceivedError: (controller, request, error) => settle(
            request.url.toString(),
            isForMainFrame: request.isForMainFrame ?? false,
          ),
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await navigated.future;

    // The original prefix serves: without this the second assertion could pass
    // against a loader that never worked at all.
    expect(
      await controller.evaluateJavascript(
        source: "document.querySelector('h1')?.innerHTML",
      ),
      'WebViewAssetLoader',
    );

    // Swap in a loader that serves the same assets under a different prefix.
    // Before the fix the native side rebuilt the loader from the *previous*
    // settings, so this new prefix was never registered.
    await controller.setSettings(
      settings: InAppWebViewSettings(
        allowFileAccessFromFileURLs: false,
        allowUniversalAccessFromFileURLs: false,
        allowFileAccess: false,
        allowContentAccess: false,
        webViewAssetLoader: WebViewAssetLoader(
          domain: TEST_WEBVIEW_ASSET_LOADER_DOMAIN,
          pathHandlers: [AssetsPathHandler(path: '/other-assets/')],
        ),
      ),
    );

    awaitedUrl = otherAssetsUrl;
    navigated = Completer<void>();
    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri(otherAssetsUrl)),
    );
    await navigated.future;

    expect(
      await controller.evaluateJavascript(
        source: "document.querySelector('h1')?.innerHTML",
      ),
      'WebViewAssetLoader',
    );
  }, skip: shouldSkip);
}
