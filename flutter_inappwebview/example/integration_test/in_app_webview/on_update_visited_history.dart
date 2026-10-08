part of 'main.dart';

void onUpdateVisitedHistory() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onUpdateVisitedHistory,
  );

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('onUpdateVisitedHistory', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstPushCompleter = Completer<String>();
    final Completer<String> secondPushCompleter = Completer<String>();
    final Completer<void> pageLoaded = Completer<void>();

    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) async {
            if (url!.toString().endsWith("second-push")) {
              secondPushCompleter.complete(url.toString());
            } else if (url.toString().endsWith("first-push")) {
              firstPushCompleter.complete(url.toString());
            }
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    await controller.evaluateJavascript(
      source: """
var state = {}
var title = ''
var url = 'first-push';
history.pushState(state, title, url);

setTimeout(function() {
    var url = 'second-push';
    history.pushState(state, title, url);
}, 500);
""",
    );

    var firstPushUrl = await firstPushCompleter.future;
    expect(
      firstPushUrl,
      '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}first-push',
    );

    var secondPushUrl = await secondPushCompleter.future;
    expect(
      secondPushUrl,
      '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}second-push',
    );
  }, skip: shouldSkip);

  // The test above reads only the URL. `isReload` (Android's) was never asserted, so a migration
  // that sent a constant would have passed it. Measured on API 37 (§213): the first load and a
  // `pushState` report false, and a reload reports true.
  skippableTestWidgets(
    'onUpdateVisitedHistory reports isReload',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<void> stops = StreamController<void>.broadcast();
      final history = <(String, bool?)>[];
      final root = 'http://${environment["NODE_SERVER_IP"]}:8082/';

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(root)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              stops.add(null);
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              history.add((url.toString(), isReload));
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await stops.stream.first;

      await controller.evaluateJavascript(
        source: "history.pushState({}, '', '/pushed');",
      );
      final reloaded = stops.stream.first;
      await controller.reload();
      await reloaded;
      for (var i = 0; i < 20 && history.length < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      expect(history, [
        (root, false),
        ('${root}pushed', false),
        ('${root}pushed', true),
      ]);
      await stops.close();
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
  );

  // A load is reported once it is in the history (§296). iOS used to report it from KVO on
  // `WKWebView.url`, which names a `load()` request at once: B came 2-3 ms after `loadUrl(B)`,
  // 1.5 s before B started, while the list still ended at A. Android reports it after B's start.
  skippableTestWidgets('onUpdateVisitedHistory reports a load once it has started', (
    WidgetTester tester,
  ) async {
    // Page A blocks its web process for 1.5 s after it commits, and `loadUrl(B)` is issued from
    // A's commit, so B's request is pending for that long (the `loadUrl` relabelling test's setup).
    final pageA = WebUri(
      'data:text/html,<title>A</title><!--NAVURLA-->'
      '<script>var t = Date.now(); while (Date.now() - t < 1500) {}</script>',
    );
    final pageB = WebUri('data:text/html,<title>B</title><!--NAVURLB-->');
    String name(Object? url) => '$url'.contains('NAVURLA')
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
            if (name(url) == 'A' && !issuedB) {
              issuedB = true;
              events.add('loadUrl B');
              controller.loadUrl(urlRequest: URLRequest(url: pageB));
            }
          },
          onLoadStop: (controller, url) => events.add('stop ${name(url)}'),
          onUpdateVisitedHistory: (controller, url, isReload) async {
            final label = name(url);
            events.add('history $label');
            final list = await controller.getCopyBackForwardList();
            final index = list?.currentIndex;
            final entries = list?.list ?? const <WebHistoryItem>[];
            events.add(
              'list at $label: current '
              '${index != null && index < entries.length ? name(entries[index].url) : null}',
            );
          },
        ),
      ),
    );

    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (!events.any((e) => e.startsWith('list at B')) &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    final requested = events.indexOf('loadUrl B');
    expect(requested, isNot(-1), reason: 'B was never requested: $events');
    expect(
      events.skip(requested + 1).firstWhere((e) => e.endsWith(' B')),
      'start B',
      reason: 'an event named B before B started: $events',
    );
    expect(
      events.where((e) => e.startsWith('list at B')),
      ['list at B: current B'],
      reason: 'B reported once, when it is the current history entry: $events',
    );
  }, skip: shouldSkip);

  // A navigation that never happens is never reported (§296). iOS used to report a `loadUrl`
  // refused by `shouldOverrideUrlLoading` twice: the refused URL, then the page it stayed on. And
  // it reported no reload, which Android does.
  skippableTestWidgets(
    'onUpdateVisitedHistory skips refused navigations and reports a reload',
    (WidgetTester tester) async {
      final root = 'http://${environment["NODE_SERVER_IP"]}:8082';
      String name(Object? url) => '$url'.replaceAll(root, '');
      final controllerCompleter = Completer<InAppWebViewController>();
      final stops = StreamController<String>.broadcast();
      final asked = <String>[];
      final history = <String>[];
      var recording = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('$root/')),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (c) => controllerCompleter.complete(c),
            shouldOverrideUrlLoading: (controller, action) async {
              final url = name(action.request.url);
              asked.add(url);
              return url.contains('refused')
                  ? NavigationActionPolicy.CANCEL
                  : NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) => stops.add(name(url)),
            onUpdateVisitedHistory: (controller, url, isReload) {
              if (recording) history.add(name(url));
            },
          ),
        ),
      );
      final controller = await controllerCompleter.future;
      await stops.stream.first.timeout(const Duration(seconds: 10));
      recording = true;

      // Bounded: waits for [url] to be refused, then for anything it might still report.
      Future<void> refused(String url) async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (!asked.contains(url) && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        expect(asked, contains(url), reason: '$url was never asked about');
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      await controller.evaluateJavascript(
        source: "location.href = '/refused-by-page';",
      );
      await refused('/refused-by-page');
      // Android does not ask shouldOverrideUrlLoading about loadUrl; iOS does.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri('$root/refused-by-loadUrl')),
        );
        await refused('/refused-by-loadUrl');
      }

      await controller.evaluateJavascript(
        source: "history.pushState({}, '', '/after');",
      );
      final reloaded = stops.stream.first.timeout(const Duration(seconds: 10));
      await controller.reload();
      await reloaded;
      for (var i = 0; i < 20 && history.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      expect(history, ['/after', '/after']);
      await stops.close();
    },
    skip: shouldSkip,
  );
}
