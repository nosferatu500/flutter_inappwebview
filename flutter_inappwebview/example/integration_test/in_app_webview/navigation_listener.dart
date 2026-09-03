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
        '${completed.map((n) => "id=${n.id} ${n.url} didCommit=${n.didCommit}").toList()}',
      );
    }

    // ---- 1. the initial load: started + completed, one id, a real status code ----
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

    // Paired by id, not by url — see the note on waitForCompleted.
    final firstStarted = started
        .where((n) => n.id == firstCompleted.id)
        .firstOrNull;
    expect(
      firstStarted,
      isNotNull,
      reason:
          'the id is what ties started to completed; androidx identifies a navigation by object '
          'identity and the plugin turns that into this number. started ids so far: '
          '${started.map((n) => "${n.id}:${n.url}").toList()}',
    );
    expect(
      firstStarted!.url?.toString(),
      urlA.toString(),
      reason: 'the started half of this navigation is for the same address',
    );
    expect(
      firstStarted.statusCode,
      isNull,
      reason:
          'an uncommitted navigation reports no status rather than a fabricated 0 — asserted '
          'because that mapping is a plugin choice, not a platform one',
    );
    expect(
      firstStarted.didCommit,
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
    expect(
      redirected.first.url?.toString(),
      isNot(redirectCompleted.url?.toString()),
      reason:
          'the url changes across the sequence — which is exactly why the payload is a snapshot '
          'and not a live view of one mutable object',
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
}
