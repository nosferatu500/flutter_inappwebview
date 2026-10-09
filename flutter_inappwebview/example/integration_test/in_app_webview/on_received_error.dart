part of 'main.dart';

void onReceivedError() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedError,
  );

  skippableGroup('onReceivedError', () {
    skippableTestWidgets('invalid url', (WidgetTester tester) async {
      final Completer<String> errorUrlCompleter = Completer<String>();
      final Completer<WebResourceErrorType> errorCodeCompleter =
          Completer<WebResourceErrorType>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_NOT_A_WEBSITE_URL),
            onReceivedError: (controller, request, error) {
              errorUrlCompleter.complete(request.url.toString());
              errorCodeCompleter.complete(error.type);
            },
          ),
        ),
      );

      final String url = await errorUrlCompleter.future;
      final WebResourceErrorType errorType = await errorCodeCompleter.future;

      expect(errorType, WebResourceErrorType.HOST_LOOKUP);
      expect(url, TEST_NOT_A_WEBSITE_URL.toString());
    });

    skippableTestWidgets('event is not called with valid url', (
      WidgetTester tester,
    ) async {
      final Completer<void> onReceivedErrorCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
              ),
            ),
            onReceivedError: (controller, request, error) {
              onReceivedErrorCompleter.complete();
            },
          ),
        ),
      );

      expect(onReceivedErrorCompleter.future, doesNotComplete);
    });

    // Loads [target] from a page that has loaded, as an app would, and returns the events that
    // followed: `start <url>`, `stop <url>`, `error <url> <type> <description>`, and `url <getUrl>`
    // last. Waits until the load has ended either way, then 2 s more, so a late error still counts
    // (measured §307: errors came 1-19 ms after their start).
    Future<List<String>> eventsAfterLoading(
      WidgetTester tester,
      String target,
    ) async {
      final deadline = TestDeadline();
      final first = 'http://${environment["NODE_SERVER_IP"]}:8082/';
      final events = <String>[];
      String state() => 'events: $events';
      final controllerCompleter = Completer<InAppWebViewController>();
      await deadline.frame(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri(first)),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStart: (controller, url) => events.add('start $url'),
              onLoadStop: (controller, url) => events.add('stop $url'),
              onReceivedError: (controller, request, error) => events.add(
                'error ${request.url} ${error.type} ${error.description}',
              ),
            ),
          ),
        ),
      );
      final controller = await deadline.step(
        'onWebViewCreated',
        controllerCompleter.future,
      );
      await deadline.until(
        'the first page',
        () => events.contains('stop $first'),
        state: state,
      );
      events.clear();
      await deadline.step(
        'loadUrl',
        controller.loadUrl(urlRequest: URLRequest(url: WebUri(target))),
      );
      await deadline.until(
        'the load of $target ending',
        () =>
            events.any((e) => e.startsWith('error ') || e.startsWith('stop ')),
        state: state,
      );
      await Future<void>.delayed(const Duration(seconds: 2));
      events.add('url ${await deadline.step('getUrl', controller.getUrl())}');
      return events;
    }

    // Port 59999 is closed on both test hosts (checked §307): on Android, 127.0.0.1 is the emulator
    // itself; on the iOS simulator, it is the Mac.
    skippableTestWidgets('a refused connection is reported on both platforms', (
      WidgetTester tester,
    ) async {
      const target = 'http://127.0.0.1:59999/';
      final events = await eventsAfterLoading(tester, target);
      expect(
        events.where((e) => e.startsWith('error ')),
        [
          startsWith(
            'error $target ${WebResourceErrorType.CANNOT_CONNECT_TO_HOST}',
          ),
        ],
        reason: 'one error for the refused URL: $events',
      );
    });

    // WebKit refuses some ports itself, port 1 among them, and loads `about:blank` instead with no
    // error; a bare `WKWebView` does the same (§307). Android reports `net::ERR_UNSAFE_PORT`. Pinned
    // on both, so a change in either engine shows up here.
    skippableTestWidgets(
      'a restricted port: Android reports it, iOS loads about:blank',
      (WidgetTester tester) async {
        const target = 'http://127.0.0.1:1/';
        final events = await eventsAfterLoading(tester, target);
        final errors = events.where((e) => e.startsWith('error ')).toList();
        if (defaultTargetPlatform == TargetPlatform.android) {
          expect(errors, [
            'error $target ${WebResourceErrorType.UNKNOWN} net::ERR_UNSAFE_PORT',
          ], reason: 'one unsafe-port error: $events');
        } else {
          expect(errors, isEmpty, reason: 'WebKit reports no error: $events');
          expect(
            events,
            containsAllInOrder([
              'start $target',
              'stop about:blank',
              'url about:blank',
            ]),
            reason: 'the load should end on about:blank: $events',
          );
        }
      },
    );
  }, skip: shouldSkip);
}
