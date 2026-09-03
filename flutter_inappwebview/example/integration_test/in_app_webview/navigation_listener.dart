part of 'main.dart';

/// Verifies C1's first half — `onNavigationStarted` / `onNavigationRedirected` /
/// `onNavigationCompleted`, backed by `androidx.webkit.NavigationListener`.
///
/// Four things are asserted here that no unit test can reach, because each is a claim about what
/// Chromium actually does rather than about the plugin's own wiring:
///
/// 1. **`statusCode` on the happy path.** The reason the feature is worth having: `200` for a
///    navigation that succeeded, which `onReceivedHttpError` could never report. A unit test can
///    only prove the key survives the channel, not that Chromium fills it in.
/// 2. **The id is stable across the sequence.** The plugin synthesises it from androidx's interned
///    peer, so this is really a test that `getOrCreatePeer` behaves as the bytecode says: one
///    identity across `started -> redirected -> completed`.
/// 3. **Every redirect hop is reported.** The fixture redirects twice, so a listener that reported
///    only the final hop would pass a one-hop test and fail here.
/// 4. **A same-document navigation is seen and classified.** `history.pushState` produces no page
///    load at all, so no existing event in this plugin reports it.
///
/// Uses the project's node server: the redirect chain and the `200` both need a fixture that this
/// repo controls, and `flutter.dev` is not one.
void navigationListener() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  final urlA = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
  final redirectUrl = WebUri(
    'http://${environment["NODE_SERVER_IP"]}:8082/test-redirect',
  );
  final redirectTarget = WebUri(
    'http://${environment["NODE_SERVER_IP"]}:8082/test-redirect-target',
  );
  // A real HTML document rather than the one-paragraph root, so there is something for the engine
  // to call a contentful paint.
  final pageUrl = WebUri(
    'http://${environment["NODE_SERVER_IP"]}:8082/test-index',
  );

  skippableTestWidgets('NavigationListener reports the whole navigation lifecycle', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final List<WebViewNavigation> started = <WebViewNavigation>[];
    final List<WebViewNavigation> redirected = <WebViewNavigation>[];
    final List<WebViewNavigation> completed = <WebViewNavigation>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: urlA),
          // Supplying these infers `useNavigationListener`; nothing sets it explicitly here, which
          // is itself the assertion that the inference works.
          onNavigationStarted: (controller, navigation) =>
              started.add(navigation),
          onNavigationRedirected: (controller, navigation) =>
              redirected.add(navigation),
          onNavigationCompleted: (controller, navigation) =>
              completed.add(navigation),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();

    expect(
      await WebViewFeature.isFeatureSupported(
        WebViewFeature.NAVIGATION_LISTENER,
      ),
      isTrue,
      reason:
          'NAVIGATION_LISTENER is unsupported by this device\'s WebView provider, so nothing '
          'below can fire. Both test AVDs (API 33 and API 37) support it; a failure here means '
          'the emulator image has an older WebView, not that the plugin regressed',
    );

    /// Waits for a completed navigation matching [test].
    ///
    /// Deliberately not `onLoadStop`: a same-document navigation produces no page load, so a load
    /// event would never arrive for the `pushState` phase below.
    ///
    /// The predicate takes `didCommit` into account at every call site rather than just the url,
    /// because **a url does not identify a navigation.** Running this test inside the full group
    /// showed the initial load producing *two* navigations to the same address — one that never
    /// committed and one that did — so matching on the url alone paired the `started` of the first
    /// with the `completed` of the second and made the id assertion fail. That was the test being
    /// wrong, not the plugin: `id` is precisely the thing that distinguishes them.
    Future<WebViewNavigation> waitForCompleted(
      bool Function(WebViewNavigation) test,
    ) async {
      for (var i = 0; i < 150; i++) {
        final match = completed.where(test).firstOrNull;
        if (match != null) {
          return match;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      throw Exception(
        'no matching onNavigationCompleted; completed so far: '
        '${completed.map((n) => "id=${n.id} ${n.url} didCommit=${n.didCommit}").toList()}, '
        'started so far: ${started.map((n) => "id=${n.id} ${n.url}").toList()}',
      );
    }

    // ---- 1. the initial load: what a completion alone can prove ----
    //
    // **Nothing about the started/completed pairing is asserted for the initial navigation, and
    // that is not caution — it is not testable here.** The Kotlin listener is registered inside the
    // native `prepare()`, while the Dart controller installs its channel handler a moment later, so
    // an event fired in that window goes to a channel nobody is listening on and is dropped. The
    // WebView's first navigation starts inside it. Measured in-group, where the machine is loaded
    // and the window is widest:
    //
    //     completed: [id=2 http://…:8082/ didCommit=true]
    //     started:   [id=1 http://…:8082/]
    //
    // — the navigation that committed never delivered its start, and the one that did start was
    // superseded. So for the initial load there may be *no* navigation with both halves. (Trap 65:
    // this is §114's `.initial` KVO problem on Android.) The pairing is asserted in phase 1b
    // instead, on a navigation this test issues itself once Dart is definitely listening.
    final firstCompleted = await waitForCompleted(
      (n) => n.url?.toString() == urlA.toString() && n.didCommit,
    );

    expect(
      firstCompleted.didCommitErrorPage,
      isFalse,
      reason:
          'the fixture answers 200, so this is content and not an error page',
    );
    expect(
      firstCompleted.statusCode,
      200,
      reason:
          'the whole point of the feature: the HTTP status of a navigation that SUCCEEDED. '
          'onReceivedHttpError never fires for a 200',
    );
    expect(
      firstCompleted.webResourceError,
      isNull,
      reason: 'a successful navigation carries no error',
    );

    // ---- 1b. the started/completed pairing, on a navigation we issue ourselves ----
    started.clear();
    redirected.clear();
    completed.clear();

    await controller.loadUrl(urlRequest: URLRequest(url: pageUrl));
    final ownCompleted = await waitForCompleted(
      (n) => n.url?.toString() == pageUrl.toString() && n.didCommit,
    );

    final ownStarted = started
        .where((n) => n.id == ownCompleted.id)
        .firstOrNull;
    expect(
      ownStarted,
      isNotNull,
      reason:
          'the id is what ties started to completed; androidx identifies a navigation by object '
          'identity and the plugin turns that into this number. Unlike the initial load, this '
          'navigation was issued after Dart was listening, so both halves must arrive. '
          'started: ${started.map((n) => "${n.id}:${n.url}").toList()}, '
          'completed id ${ownCompleted.id}',
    );
    expect(
      ownStarted!.url?.toString(),
      pageUrl.toString(),
      reason: 'the started half of this navigation is for the same address',
    );
    expect(
      ownStarted.statusCode,
      isNull,
      reason:
          'an uncommitted navigation reports no status rather than a fabricated 0 — asserted '
          'because that mapping is a plugin choice, not a platform one',
    );
    expect(
      ownStarted.didCommit,
      isFalse,
      reason: 'nothing has committed at the moment a navigation starts',
    );

    // ---- 2. a two-hop redirect chain ----
    started.clear();
    redirected.clear();
    completed.clear();

    await controller.loadUrl(urlRequest: URLRequest(url: redirectUrl));
    final redirectCompleted = await waitForCompleted(
      (n) => n.url?.toString() == redirectTarget.toString() && n.didCommit,
    );

    expect(
      redirected.length,
      greaterThanOrEqualTo(2),
      reason:
          'the fixture redirects twice, so every hop is reported rather than only the last: got '
          '${redirected.map((n) => n.url.toString()).toList()}',
    );
    expect(
      redirected.map((n) => n.id).toSet(),
      <int>{redirectCompleted.id},
      reason: 'every hop belongs to the one navigation that started it',
    );
    // The url of ONE navigation changes as it is followed, which is the whole reason the payload
    // has to be a per-event snapshot rather than a reference to androidx's mutable object.
    //
    // Asserted between `started` and `completed`, deliberately. An earlier version compared the
    // first *redirect* hop against the final url and failed on API 33, where the first hop already
    // reports the destination — i.e. the platform does not promise which end of a hop `getUrl()`
    // names, and the test was encoding a guess about that rather than the property it cared about.
    final redirectStarted = started
        .where((n) => n.id == redirectCompleted.id)
        .firstOrNull;
    expect(
      redirectStarted,
      isNotNull,
      reason:
          'started ids: ${started.map((n) => "${n.id}:${n.url}").toList()}, '
          'completed id ${redirectCompleted.id}',
    );
    expect(
      redirectStarted!.url?.toString(),
      isNot(redirectCompleted.url?.toString()),
      reason:
          'the same navigation object reports the requested url when it starts and the final url '
          'when it completes. redirect hops seen: '
          '${redirected.map((n) => n.url.toString()).toList()}',
    );
    expect(redirectCompleted.statusCode, 200);

    // ---- 3. a same-document navigation, which no other event here reports ----
    started.clear();
    redirected.clear();
    completed.clear();

    await controller.evaluateJavascript(
      source: "history.pushState({}, '', '/test-redirect-target?same-doc');",
    );

    final sameDocument = await waitForCompleted(
      (n) => n.url?.toString() == '${redirectTarget.toString()}?same-doc',
    );

    expect(
      sameDocument.isSameDocument,
      isTrue,
      reason:
          'a pushState does not load a new document; nothing else in this plugin reports it at all',
    );
    expect(
      sameDocument.statusCode,
      isNull,
      reason: 'a same-document navigation carries no HTTP response of its own',
    );

    // `isBack` / `isForward` / `isRestore` are deliberately not asserted here. They need a
    // back/forward traversal, `web_history.dart` already drives that path, and a history
    // navigation that Chromium serves from the back/forward cache produces no load event to
    // synchronise on — the same hazard §115 hit on iOS. The classification flags' wire shape is
    // covered by the Kotlin and Dart unit tests instead.
  }, skip: shouldSkip);

  skippableTestWidgets('page lifecycle and Web Vitals arrive for a page', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final List<String> order = <String>[];
    final List<WebViewPage> loaded = <WebViewPage>[];
    final List<WebViewNavigation> completed = <WebViewNavigation>[];
    final List<int> firstPaints = <int>[];
    final List<int> largestPaints = <int>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: pageUrl),
          // Note what is NOT here: `onPerformanceMarkMillis`. That absence is the subject of the
          // settings assertion at the end.
          onNavigationCompleted: (controller, navigation) =>
              completed.add(navigation),
          onPageDomContentLoadedEvent: (controller, page) =>
              order.add('dom:${page.id}'),
          onPageLoadEvent: (controller, page) {
            order.add('load:${page.id}');
            loaded.add(page);
          },
          onFirstContentfulPaintMillis: (controller, page, durationMillis) =>
              firstPaints.add(durationMillis),
          onLargestContentfulPaintMillis: (controller, page, durationMillis) =>
              largestPaints.add(durationMillis),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();

    for (var i = 0; i < 150 && loaded.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(
      loaded,
      isNotEmpty,
      reason: 'onPageLoadEvent never arrived; order so far: $order',
    );

    // ---- 1. DOMContentLoaded precedes load, and this is DOMContentLoaded with no injected JS ----
    expect(
      order.first,
      startsWith('dom:'),
      reason:
          'DOMContentLoaded precedes load, which waits for subresources. Getting this without '
          'injecting a script into the page is the point of the event: $order',
    );
    expect(order.any((e) => e.startsWith('load:')), isTrue);

    // ---- 2. a page id links the page events to the navigation that created the document ----
    //
    // Polled rather than read once. `onPageLoadEvent` and the `onNavigationCompleted` of the
    // navigation that created that page are independent callbacks with no guaranteed order, and on
    // the slower API 33 emulator the page event wins the race: reading `completed` immediately
    // found only an earlier navigation (`id=1 pageId=1`) while the loaded page was already `id=2`.
    // Waiting for the correlation is the honest test; asserting over whatever had arrived so far
    // was not.
    final page = loaded.first;
    WebViewNavigation? navigation;
    for (var i = 0; i < 100; i++) {
      navigation = completed.where((n) => n.pageId == page.id).firstOrNull;
      if (navigation != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(
      navigation,
      isNotNull,
      reason:
          'WebViewNavigation.pageId and WebViewPage.id are the same synthesised number, and that '
          'is the only way to correlate a page event with its navigation. navigations: '
          '${completed.map((n) => "id=${n.id} pageId=${n.pageId}").toList()}, page id=${page.id}',
    );
    expect(navigation!.didCommit, isTrue);

    // ---- 3. Web Vitals straight from the engine ----
    for (var i = 0; i < 60 && firstPaints.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(
      firstPaints,
      isNotEmpty,
      reason:
          'First Contentful Paint should be reported for a page that renders visible text, with '
          'no PerformanceObserver installed by the plugin',
    );
    expect(
      firstPaints.first,
      greaterThan(0),
      reason: 'the platform reports a duration, not a flag',
    );

    // Give LCP a moment to settle. It is asserted more loosely than FCP on purpose: LCP is defined
    // against the largest element painted *so far*, so the engine may revise it several times and
    // the count is not something to pin.
    await Future.delayed(const Duration(seconds: 2));
    expect(
      largestPaints,
      isNotEmpty,
      reason:
          'Largest Contentful Paint should be reported at least once for a page with visible '
          'content',
    );

    // ---- 4. the two-tier gate: the cheap handlers must NOT have opted us into the costly one ----
    final settings = await controller.getSettings();
    expect(
      settings?.useNavigationListener,
      isTrue,
      reason:
          'supplying any of these handlers infers the listener registration',
    );
    expect(
      settings?.useOnPerformanceMarkMillis,
      isNot(isTrue),
      reason:
          'THE POINT OF HAVING TWO SETTINGS: five handlers were supplied and none of them is '
          'onPerformanceMarkMillis, so the unbounded event must stay off. If this ever flips, an '
          'app opting into DOMContentLoaded silently starts paying a channel message per '
          'performance.mark()',
    );

    // `onPageDeleted` is deliberately not asserted. It reports back/forward-cache eviction, which
    // is Chromium's decision and depends on memory pressure and cache size — a test that waits for
    // it would be waiting on something no API here can provoke. Its wire shape is covered by the
    // Dart unit test.
  }, skip: shouldSkip);

  skippableTestWidgets('performance marks arrive only behind their own opt-in', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();
    final List<String> marks = <String>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: pageUrl),
          onPerformanceMarkMillis:
              (controller, page, markName, markTimeMillis) =>
                  marks.add('$markName@${markTimeMillis >= 0}'),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete(url?.toString());
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
    await pageLoaded.future;

    // Supplying this one handler, and only this one, turns both gates on.
    final settings = await controller.getSettings();
    expect(
      settings?.useNavigationListener,
      isTrue,
      reason: 'the event still needs the platform listener registered',
    );
    expect(
      settings?.useOnPerformanceMarkMillis,
      isTrue,
      reason: 'its own handler is the only thing that infers this gate',
    );

    await controller.evaluateJavascript(
      source: "performance.mark('integration-probe');",
    );

    for (var i = 0; i < 100 && marks.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(
      marks.map((m) => m.split('@').first),
      contains('integration-probe'),
      reason:
          'the mark name the page passed to performance.mark() is carried through verbatim; '
          'received: $marks',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('the performance-mark gate actually suppresses the event', (
    WidgetTester tester,
  ) async {
    // The control for the test above, and the only one that proves the *setting* does anything.
    //
    // Turning the gate off while still supplying a handler is the one configuration where Dart
    // would happily deliver the event and only the Kotlin guard stands in the way. Without this,
    // "no marks arrived" is equally explained by there being no handler to deliver them to.
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();
    final List<String> marks = <String>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: pageUrl),
          initialSettings: InAppWebViewSettings(
            useNavigationListener: true,
            // Explicit `false` beats the inference from the handler below.
            useOnPerformanceMarkMillis: false,
          ),
          onPerformanceMarkMillis:
              (controller, page, markName, markTimeMillis) =>
                  marks.add(markName),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete(url?.toString());
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
    await pageLoaded.future;

    expect(
      (await controller.getSettings())?.useOnPerformanceMarkMillis,
      isFalse,
      reason:
          'an explicit false must survive the inference, not be overwritten by it',
    );

    await controller.evaluateJavascript(
      source: "performance.mark('should-not-arrive');",
    );
    await Future.delayed(const Duration(seconds: 3));

    expect(
      marks,
      isEmpty,
      reason:
          'the handler exists and the listener is registered, so the only thing that can stop '
          'this event is the Kotlin gate. If marks arrive here, the setting is decorative and '
          'every app listening for DOMContentLoaded pays for every performance.mark()',
    );
  }, skip: shouldSkip);
}
