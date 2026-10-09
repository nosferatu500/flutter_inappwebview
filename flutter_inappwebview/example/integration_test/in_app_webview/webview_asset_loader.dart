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
    const otherAssetsUrl =
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

  // D3 (§311): the app disposes a path handler it no longer uses (`PathHandler.dispose`); the plugin
  // can't, since one handler can serve several WebViews. Disposing twice is safe, and afterwards
  // the WebView no longer reaches the handler for its path.
  skippableTestWidgets(
    'a disposed CustomPathHandler no longer answers its path',
    (WidgetTester tester) async {
      final deadline = TestDeadline();
      final handler = _TextPathHandler(path: '/custom/');
      final created = Completer<InAppWebViewController>();
      final loads = <String>[];
      const indexUrl =
          'https://$TEST_WEBVIEW_ASSET_LOADER_DOMAIN/custom/index.html';
      await deadline.frame(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri(indexUrl)),
              initialSettings: InAppWebViewSettings(
                webViewAssetLoader: WebViewAssetLoader(
                  domain: TEST_WEBVIEW_ASSET_LOADER_DOMAIN,
                  pathHandlers: [handler],
                ),
              ),
              onWebViewCreated: created.complete,
              onLoadStop: (controller, url) => loads.add(url.toString()),
            ),
          ),
        ),
      );
      final controller = await deadline.step(
        'onWebViewCreated',
        created.future,
      );
      await deadline.until(
        'the handler-served page',
        () => loads.contains(indexUrl),
        state: () => 'loads $loads, handled ${handler.paths}',
      );
      Future<String?> fetch(String file) async {
        final result = await deadline.step(
          'fetching $file',
          controller.callAsyncJavaScript(
            functionBody:
                "try { const r = await fetch('/custom/$file');"
                " return 'status ' + r.status + ': ' + (await r.text()); }"
                " catch (e) { return 'rejected: ' + e; }",
          ),
        );
        return result?.value?.toString();
      }

      expect(
        await fetch('before.txt'),
        'status 200: custom before.txt',
        reason: 'the control: the handler answers its path',
      );

      expect(handler.dispose, returnsNormally);
      expect(
        handler.dispose,
        returnsNormally,
        reason: 'a second call is a no-op',
      );

      // Measured on API 37: the handler isn't asked, and the page's fetch fails (`TypeError: Failed
      // to fetch`), as for a URL nothing serves.
      expect(
        await fetch('after.txt'),
        startsWith('rejected: '),
        reason: 'a disposed handler no longer serves its path',
      );
      expect(handler.paths, ['index.html', 'before.txt']);
    },
    skip: shouldSkip,
  );
}

/// Answers every path under its prefix with `custom <path>`, and records the paths it was asked for.
class _TextPathHandler extends CustomPathHandler {
  _TextPathHandler({required super.path});

  final paths = <String>[];

  @override
  Future<WebResourceResponse?> handle(String path) async {
    paths.add(path);
    return WebResourceResponse(
      contentType: path.endsWith('.html') ? 'text/html' : 'text/plain',
      data: Uint8List.fromList(utf8.encode('custom $path')),
    );
  }
}
