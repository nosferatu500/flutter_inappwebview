part of 'main.dart';

void webHistory() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getCopyBackForwardList,
  );

  skippableGroup('web history', () {
    final shouldSkipTest1 = !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.getCopyBackForwardList,
    );

    // Two plain documents from the project's own node server, deliberately NOT
    // `https://flutter.dev/` and `https://github.com/flutter`, which this test used to drive.
    //
    // Both of those cancel their own back/forward navigations — the plugin reports
    // `onReceivedError` with `WebResourceErrorType.CANCELLED` (`NSURLErrorCancelled`, -999) and
    // WebKit never calls `didFinishNavigation`, so no `onLoadStop` arrives and the test waited out
    // its 60s timeout. It is the *pages*, not `goBack`: measured on iOS 17.5 and 26.5, the same
    // sequence over these two static pages passes, and so does a cross-origin pair
    // (`https://www.example.com/` ↔ this server). The back-forward list itself was always right —
    // `currentIndex`, `canGoBack` and `canGoForward` all moved correctly even when the load was
    // cancelled.
    //
    // This adds the node server to this test's requirements; it had none before.
    final historyUrlA = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
    final historyUrlB = WebUri(
      'http://${environment["NODE_SERVER_IP"]}:8082/test-index',
    );

    skippableTestWidgets('get history list and go back/forward', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: historyUrlA),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      await tester.pump();

      Future<String> waitForUrl(String expectedUrl) async {
        await for (final url in pageLoads.stream) {
          if (url == expectedUrl) {
            return url;
          }
        }
        throw Exception('Stream closed without receiving $expectedUrl');
      }

      // Wait for initial page load
      var url = await waitForUrl(historyUrlA.toString());
      var webHistory = await controller.getCopyBackForwardList();
      expect(url, historyUrlA.toString());
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 1);
      expect(webHistory.list![0].url.toString(), historyUrlA.toString());

      // Start listening BEFORE navigation to avoid race condition
      var loadFuture = waitForUrl(historyUrlB.toString());
      await controller.loadUrl(urlRequest: URLRequest(url: historyUrlB));
      url = await loadFuture;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, historyUrlB.toString());
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), historyUrlA.toString());
      expect(webHistory.list![1].url.toString(), historyUrlB.toString());

      loadFuture = waitForUrl(historyUrlA.toString());
      await controller.goBack();
      url = await loadFuture;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, historyUrlA.toString());
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), historyUrlA.toString());
      expect(webHistory.list![1].url.toString(), historyUrlB.toString());

      loadFuture = waitForUrl(historyUrlB.toString());
      await controller.goForward();
      url = await loadFuture;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, historyUrlB.toString());
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), historyUrlA.toString());
      expect(webHistory.list![1].url.toString(), historyUrlB.toString());

      loadFuture = waitForUrl(historyUrlA.toString());
      await controller.goTo(historyItem: webHistory.list![0]);
      url = await loadFuture;
      webHistory = await controller.getCopyBackForwardList();
      expect(url, historyUrlA.toString());
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(), historyUrlA.toString());
      expect(webHistory.list![1].url.toString(), historyUrlB.toString());

      pageLoads.close();
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 = !kIsWeb;

    skippableTestWidgets('go back/forward on web platform', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_WEB_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      await tester.pump();

      var url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      await controller.evaluateJavascript(
        source: "document.getElementById('link-page-2').click();",
      );
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_2.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goBack();
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goForward();
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_2.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goBackOrForward(steps: -1);
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      pageLoads.close();
    }, skip: shouldSkipTest2);

    final shouldSkipTest3 = !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.clearHistory,
    );

    skippableTestWidgets('clearHistory', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;
      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_1));
      await pageLoads.stream.first;

      var webHistory = await controller.getCopyBackForwardList();
      expect(webHistory!.list!.length, 2);

      await controller.clearHistory();

      webHistory = await controller.getCopyBackForwardList();
      expect(webHistory!.list!.length, 1);

      pageLoads.close();
    }, skip: shouldSkipTest3);
  }, skip: shouldSkip);
}
