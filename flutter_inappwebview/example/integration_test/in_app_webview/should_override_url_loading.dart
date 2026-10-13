part of 'main.dart';

void shouldOverrideUrlLoading() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldOverrideUrlLoading,
  );

  skippableGroup('shouldOverrideUrlLoading', () {
    final String page =
        '''<!DOCTYPE html><head></head><body><a id="link" href="$TEST_URL_3">flutter_inappwebview</a></body></html>''';
    final String pageEncoded =
        'data:text/html;charset=utf-8;base64,${base64Encode(const Utf8Encoder().convert(page))}';

    skippableTestWidgets('can allow requests', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return (navigationAction.request.url!.host.contains(
                    TEST_URL_4.host.replaceAll("www.", ""),
                  ))
                  ? NavigationActionPolicy.CANCEL
                  : NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_EXAMPLE"',
      );

      await pageLoads.stream.first; // Wait for the next page load.
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_EXAMPLE.toString());

      unawaited(pageLoads.close());
    });

    final shouldSkipTest2 = !NavigationType.LINK_ACTIVATED.isSupported();
    testWidgets(
      'allow requests on iOS only if navigationType == NavigationType.LINK_ACTIVATED',
      (WidgetTester tester) async {
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var isFirstLoad =
                    navigationAction.request.url!.scheme == "data";
                return (isFirstLoad ||
                        navigationAction.navigationType ==
                            NavigationType.LINK_ACTIVATED)
                    ? NavigationActionPolicy.ALLOW
                    : NavigationActionPolicy.CANCEL;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
          source: 'location.href = "$TEST_URL_2"',
        );

        // There should never be any second page load, since our new URL is
        // blocked. Still wait for a potential page change for some time in order
        // to give the test a chance to fail.
        await pageLoads.stream
            // ignore: unnecessary_cast
            .map((event) => event as String?)
            .first
            .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
        String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, isNot(TEST_URL_2.toString()));

        await controller.evaluateJavascript(
          source: 'document.querySelector("#link").click();',
        );
        await pageLoads.stream.first; // Wait for the next page load.
        currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, TEST_URL_3.toString());

        unawaited(pageLoads.close());
      },
      skip: shouldSkipTest2,
    );

    skippableTestWidgets('can block requests', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return (navigationAction.request.url!.host.contains(
                    TEST_URL_4.host.replaceAll("www.", ""),
                  ))
                  ? NavigationActionPolicy.CANCEL
                  : NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_4"',
      );

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoads.stream
          // ignore: unnecessary_cast
          .map((event) => event as String?)
          .first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(
        currentUrl,
        isNot(contains(TEST_URL_4.host.replaceAll("www.", ""))),
      );

      unawaited(pageLoads.close());
    });

    skippableTestWidgets('supports asynchronous decisions', (
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
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var action = NavigationActionPolicy.CANCEL;
              action = await Future<NavigationActionPolicy>.delayed(
                const Duration(milliseconds: 10),
                () => NavigationActionPolicy.ALLOW,
              );
              return action;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_EXAMPLE"',
      );

      await pageLoads.stream.first; // Wait for second page to load.
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_EXAMPLE.toString());

      unawaited(pageLoads.close());
    });

    // What each kind of answer does, the same on both platforms (D1, §309). Measured before: a
    // null answer cancelled on both; a throwing handler allowed on Android and cancelled on iOS; and
    // `useShouldOverrideUrlLoading: true` with no handler cancelled the navigation on Android and
    // every navigation on iOS, the first load included. Each test loads `:8082/`, then navigates
    // to `/test-index` from JS, and returns the `onLoadStop` URLs, `getUrl`, and whether the handler
    // was asked for the target.
    Future<({List<String> loads, String? url, bool asked})> navigate(
      WidgetTester tester,
      Future<NavigationActionPolicy?> Function(
        InAppWebViewController controller,
        NavigationAction action,
      )?
      handler,
    ) async {
      final deadline = TestDeadline();
      final start = "http://${environment["NODE_SERVER_IP"]}:8082/";
      final target = "http://${environment["NODE_SERVER_IP"]}:8082/test-index";
      final loads = <String>[];
      final asked = <String>[];
      final created = Completer<InAppWebViewController>();
      await deadline.frame(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri(start)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
              ),
              onWebViewCreated: created.complete,
              shouldOverrideUrlLoading: handler == null
                  ? null
                  : (controller, action) {
                      asked.add(action.request.url.toString());
                      return handler(controller, action);
                    },
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
        'the first page',
        () => loads.contains(start),
        state: () => 'loads: $loads',
      );
      await deadline.step(
        'navigating from JS',
        controller.evaluateJavascript(source: 'location.href = "$target";'),
      );
      // An allowed load of this fixture page finishes in well under a second; a cancelled one
      // never does, so the wait is a fixed one, long enough for either.
      await Future<void>.delayed(const Duration(seconds: 3));
      return (
        loads: loads,
        url: (await deadline.step('getUrl', controller.getUrl()))?.toString(),
        asked: asked.contains(target),
      );
    }

    final targetUrl = "http://${environment["NODE_SERVER_IP"]}:8082/test-index";

    skippableTestWidgets('a null answer allows the navigation', (
      WidgetTester tester,
    ) async {
      final r = await navigate(tester, (controller, action) async => null);
      expect(r.asked, isTrue, reason: 'the handler was asked: ${r.loads}');
      expect(r.loads, contains(targetUrl));
      expect(r.url, targetUrl);
    });

    skippableTestWidgets('a handler that throws cancels the navigation', (
      WidgetTester tester,
    ) async {
      final r = await navigate(tester, (controller, action) async {
        if (action.request.url.toString() == targetUrl) {
          throw StateError('an allow-list bug');
        }
        return NavigationActionPolicy.ALLOW;
      });
      expect(r.asked, isTrue, reason: 'the handler was asked: ${r.loads}');
      expect(r.loads, isNot(contains(targetUrl)));
      expect(r.url, isNot(targetUrl));
    });

    skippableTestWidgets(
      'useShouldOverrideUrlLoading with no handler allows every navigation',
      (WidgetTester tester) async {
        // `navigate` waits for the first page, which iOS used to cancel here as well.
        final r = await navigate(tester, null);
        expect(r.loads, contains(targetUrl));
        expect(r.url, targetUrl);
      },
    );
  }, skip: shouldSkip);
}
