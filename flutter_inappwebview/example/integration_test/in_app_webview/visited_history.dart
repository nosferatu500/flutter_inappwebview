part of 'main.dart';

/// Verifies D4 — `onRequestVisitedHistory`, backed by `WebChromeClient.getVisitedHistory`.
///
/// The event was probed before it was built, because D6 was rejected for failing exactly this
/// question: **modern Chromium really does call this hook**, and it fires **once per `WebView`**
/// rather than once per page load. Both of those are asserted here rather than left as notes,
/// because "once per WebView" is a promise the dartdoc makes to callers and nothing else could
/// catch it changing.
void visitedHistory() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  final firstUrl = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
  final secondUrl = WebUri(
    'http://${environment["NODE_SERVER_IP"]}:8082/test-index',
  );

  skippableTestWidgets('onRequestVisitedHistory is asked once per WebView', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    // Collected into a list and polled, NOT awaited through a broadcast stream. A broadcast
    // StreamController does not buffer, so an `onLoadStop` that fires before `await for` subscribes
    // is lost and the wait never returns — which is exactly what happened on API 33: the initial
    // load completed during WebView setup and the test sat out its 60-second timeout.
    final List<String> loads = <String>[];
    var requests = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: firstUrl),
          onRequestVisitedHistory: (controller) {
            requests++;
            return <WebUri>[firstUrl];
          },
          onLoadStop: (controller, url) {
            loads.add(url!.toString());
          },
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();

    Future<void> waitForUrl(String expected) async {
      for (var i = 0; i < 150; i++) {
        if (loads.contains(expected)) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      throw Exception('never loaded $expected; loads so far: $loads');
    }

    await waitForUrl(firstUrl.toString());

    // The request is made during WebView setup, so it may already have arrived or be moments away.
    for (var i = 0; i < 100 && requests == 0; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(
      requests,
      1,
      reason:
          'the engine asks the app for its visited history. Unlike D6 this is a live hook, not a '
          'dead AOSP leftover — if this is 0, either the WebView provider stopped calling it or '
          'the plugin stopped answering',
    );

    // ---- it is NOT re-asked per navigation ----
    await controller.loadUrl(urlRequest: URLRequest(url: secondUrl));
    await waitForUrl(secondUrl.toString());
    await controller.reload();
    await Future.delayed(const Duration(seconds: 2));

    expect(
      requests,
      1,
      reason:
          'once per WebView, not once per page load — measured as 1 call for one WebView and 117 '
          'across a ~120-test group. An app cannot refresh its answer by navigating, which is why '
          'the dartdoc frames it as "what had been visited when this WebView started"',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('a null answer keeps the platform default', (
    WidgetTester tester,
  ) async {
    // Returning null must not throw and must not stall the load: the Kotlin falls through to
    // `super.getVisitedHistory`, which leaves the engine's callback unanswered — exactly what a
    // WebView without this plugin does. The observable claim is that the page still loads
    // normally, which is what would break if the callback were mishandled on the platform thread.
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> loaded = Completer<String>();
    var requests = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: firstUrl),
          onRequestVisitedHistory: (controller) {
            requests++;
            return null;
          },
          onLoadStop: (controller, url) {
            if (!loaded.isCompleted) {
              loaded.complete(url?.toString());
            }
          },
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    await controllerCompleter.future;
    await tester.pump();

    expect(await loaded.future, firstUrl.toString());
    for (var i = 0; i < 50 && requests == 0; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(
      requests,
      1,
      reason: 'the event still fires; it is the answer that declines',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('the answer is not readable back by the page', (
    WidgetTester tester,
  ) async {
    // Asserts the *mitigation*, on §115's precedent: pin the surprising half so that a platform
    // change fails here rather than surprising a user.
    //
    // This event hands the page's rendering a list of URLs the user has visited, which is the
    // classic `:visited` side-channel. Measured on API 37: a link reported as visited and a link
    // that was not **both** report the unvisited colour through `getComputedStyle`, so the engine
    // is lying to script about `:visited` exactly as browsers are supposed to. That is what keeps
    // the privacy exposure of answering this event bounded — and if a future WebView ever stopped
    // lying, an app feeding this API its user's history would begin leaking it to every page. This
    // test is the canary for that.
    //
    // It also means **the feature's visual effect cannot be verified from Dart at all**: the tests
    // above assert the request and the answer, because the rendering is deliberately unobservable.
    final linksUrl = WebUri(
      'http://${environment["NODE_SERVER_IP"]}:8082/test-visited-links',
    );
    final reportedUrl = WebUri(
      'http://${environment["NODE_SERVER_IP"]}:8082/test-visited-target',
    );
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> loaded = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: linksUrl),
          onRequestVisitedHistory: (controller) => <WebUri>[reportedUrl],
          onLoadStop: (controller, url) {
            if (!loaded.isCompleted) {
              loaded.complete(url?.toString());
            }
          },
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    expect(await loaded.future, linksUrl.toString());
    // The engine applies visited state asynchronously after the answer arrives.
    await Future.delayed(const Duration(seconds: 3));

    Future<String?> colorOf(String id) async =>
        (await controller.evaluateJavascript(
          source: "getComputedStyle(document.getElementById('$id')).color",
        ))?.toString();

    final reported = await colorOf('reported');
    final unreported = await colorOf('unreported');

    expect(
      reported,
      'rgb(0, 0, 255)',
      reason:
          'the fixture styles `a:visited` red and `a` blue. The reported link must still read as '
          'blue to script: if this becomes rgb(255, 0, 0), the engine has started exposing '
          '`:visited` state to getComputedStyle and answering this event now leaks the user\'s '
          'history to any page that asks',
    );
    expect(
      unreported,
      reported,
      reason:
          'a page cannot tell the two apart, which is the whole point of the mitigation',
    );
  }, skip: shouldSkip);
}
