part of 'main.dart';

void loadUrl() {
  final shouldSkip1 = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.loadUrl,
  );

  var initialUrl = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstUrlLoad = Completer<String>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == initialUrl.toString() &&
                !firstUrlLoad.isCompleted) {
              firstUrlLoad.complete(url.toString());
            } else if (url.toString() == TEST_CROSS_PLATFORM_URL_1.toString() &&
                !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    expect(await firstUrlLoad.future, initialUrl.toString());

    await controller.loadUrl(
      urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
    );
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_1.toString());
  }, skip: shouldSkip1);

  // A GET with headers takes its own branch on Android (`WebView.loadUrl(url, headers)`), and no
  // other test sent headers through `loadUrl`. The node server's /echo-headers page prints what it
  // received (lower-cased names), which is what's read back. Two headers with different values, so a
  // swap or a single dropped header shows; a second load without headers proves they don't stick.
  // Android only: this is the only platform it was measured on (Pixel_10, API 37, §211).
  skippableTestWidgets(
    'loadUrl sends its headers',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      final url = WebUri(
        'http://${environment["NODE_SERVER_IP"]}:8082/echo-headers',
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url.toString());
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;

      Future<Map<String, dynamic>> received(URLRequest request) async {
        final loaded = pageLoads.stream.first;
        await controller.loadUrl(urlRequest: request);
        expect(await loaded, url.toString());
        final String text = await controller.evaluateJavascript(
          source: "document.querySelector('pre').textContent",
        );
        return jsonDecode(text) as Map<String, dynamic>;
      }

      final withHeaders = await received(
        URLRequest(
          url: url,
          headers: {'X-Fork-Probe': 'alpha', 'X-Second-Probe': 'beta'},
        ),
      );
      expect(withHeaders['x-fork-probe'], 'alpha');
      expect(withHeaders['x-second-probe'], 'beta');

      final withoutHeaders = await received(URLRequest(url: url));
      expect(withoutHeaders.containsKey('x-fork-probe'), isFalse);
      expect(withoutHeaders.containsKey('x-second-probe'), isFalse);
      await pageLoads.close();
    },
    skip: shouldSkip1 || defaultTargetPlatform != TargetPlatform.android,
  );

  skippableTestWidgets("loadUrl does not relabel the previous page's events", (
    WidgetTester tester,
  ) async {
    // Page A commits, then blocks its web process for 1.5 s in an inline script, so its finish
    // is still to come when `loadUrl(B)` is issued from A's commit. Every event must name its
    // own navigation: before §279 iOS sent `WKWebView.url`, which names B as soon as B is
    // requested, so A's finish arrived as an `onLoadStop` for B before B had started.
    final pageA = WebUri(
      'data:text/html,<title>A</title><!--NAVURLA-->'
      '<script>var t = Date.now(); while (Date.now() - t < 1500) {}</script>',
    );
    final pageB = WebUri('data:text/html,<title>B</title><!--NAVURLB-->');
    String name(WebUri? url) => '$url'.contains('NAVURLA')
        ? 'A'
        : '$url'.contains('NAVURLB')
        ? 'B'
        : '$url';
    final events = <String>[];
    var issuedB = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: pageA),
          onLoadStart: (controller, url) => events.add('start ${name(url)}'),
          onPageCommitVisible: (controller, url) {
            events.add('commit ${name(url)}');
            if (name(url) == 'A' && !issuedB) {
              issuedB = true;
              events.add('loadUrl B');
              controller.loadUrl(urlRequest: URLRequest(url: pageB));
            }
          },
          onLoadStop: (controller, url) => events.add('stop ${name(url)}'),
        ),
      ),
    );

    final deadline = DateTime.now().add(const Duration(seconds: 20));
    bool bFinished() {
      final start = events.indexOf('start B');
      return start >= 0 && events.skip(start).contains('stop B');
    }

    while (!bFinished() && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(
      bFinished(),
      isTrue,
      reason: 'B never started and finished: $events',
    );

    // The first event naming B after it was requested is B's own start.
    final requested = events.indexOf('loadUrl B');
    expect(
      events.skip(requested + 1).firstWhere((e) => e.endsWith(' B')),
      'start B',
      reason: 'an event named B before B started: $events',
    );
    expect(
      events.where((e) => e == 'stop B').length,
      1,
      reason: 'B finished more than once: $events',
    );
  }, skip: shouldSkip1);

  final shouldSkip2 = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.loadSimulatedRequest,
  );

  skippableTestWidgets('loadSimulatedRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstUrlLoad = Completer<String>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == initialUrl.toString() &&
                !firstUrlLoad.isCompleted) {
              firstUrlLoad.complete(url.toString());
            } else if (url.toString() == TEST_CROSS_PLATFORM_URL_1.toString() &&
                !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    expect(await firstUrlLoad.future, initialUrl.toString());

    const htmlCode = "<h1>Hello</h1>";
    await controller.loadSimulatedRequest(
      urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      data: Uint8List.fromList(utf8.encode(htmlCode)),
    );
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_1.toString());
    expect(
      (await controller.evaluateJavascript(
        source: "document.body.innerHTML",
      )).toString().trim(),
      htmlCode,
    );
  }, skip: shouldSkip2);
}
