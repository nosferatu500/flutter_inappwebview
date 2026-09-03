part of 'main.dart';

/// Verifies `shouldGoToBackForwardListItem` (B4, iOS 26.0+) on a device.
///
/// **This is the first of the three iOS 26.0 events this fork added that a simulator can actually
/// exercise.** `onInsertInputSuggestion` needs Apple Intelligence and a human, and
/// `onWritingToolsActiveChanged` did not fire even on a real device; a back navigation needs
/// neither.
///
/// It pins three separately-measured facts, the third of which is not in WebKit's header:
///
/// 1. a **page-initiated** back (`history.back()`) answered `CANCEL` does not happen;
/// 2. the same navigation answered `ALLOW` does;
/// 3. a **programmatic** `goBack()` answered `CANCEL` **happens anyway** — the delegate is still
///    consulted and the plugin still hands WebKit `false` (verified by instrumenting the Swift),
///    but WebKit performs the navigation regardless. Sensible in hindsight — the app asked for it —
///    and completely invisible from the header, which says only that back/forward navigations
///    "including those triggered by webpage JavaScript" consult the delegate.
///
/// Fact 3 is asserted rather than avoided so that a future WebKit release changing it is noticed
/// here rather than by a user.
///
/// Uses the project's node server rather than `TEST_CROSS_PLATFORM_URL_*`, for the reason
/// `web_history.dart` records at length: `flutter.dev` cancels its own back navigations, WebKit
/// never calls `didFinishNavigation`, and the ALLOW half would wait out its 60s timeout.
void shouldGoToBackForwardListItem() {
  final shouldSkip =
      defaultTargetPlatform != TargetPlatform.iOS ||
      // iOS 26.0+. Below it the delegate does not exist and the event can never fire, which is a
      // different thing from it firing and being ignored.
      (_iosMajorVersion() ?? 0) < 26;

  final urlA = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
  final urlB = WebUri(
    'http://${environment["NODE_SERVER_IP"]}:8082/test-index',
  );

  skippableTestWidgets('shouldGoToBackForwardListItem can veto a back navigation', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
        StreamController<String>.broadcast();
    final List<WebHistoryItem> seen = <WebHistoryItem>[];
    final List<bool> instantBack = <bool>[];
    // Flipped between phases; the handler itself is registered once, at creation, because that is
    // the only place a handler can be registered.
    var decision = ShouldGoToBackForwardListItemAction.CANCEL;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: urlA),
          shouldGoToBackForwardListItem:
              (controller, backForwardListItem, willUseInstantBack) {
                seen.add(backForwardListItem);
                instantBack.add(willUseInstantBack);
                return decision;
              },
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoads.add(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();

    Future<String> waitForUrl(String expectedUrl) async {
      await for (final url in pageLoads.stream) {
        if (url == expectedUrl) {
          return url;
        }
      }
      throw Exception('Stream closed without receiving $expectedUrl');
    }

    /// Polls `getUrl()` instead of waiting for `onLoadStop`.
    ///
    /// Back/forward navigations cannot be waited on through page-load events: when WebKit resumes
    /// a suspended page — the `willUseInstantBack` path — there is no normal load, so no
    /// `onLoadStop` ever arrives. An earlier version of this test waited on the event stream and
    /// timed out at 60s on exactly that step.
    Future<void> waitForCurrentUrl(String expectedUrl) async {
      for (var i = 0; i < 100; i++) {
        if ((await controller.getUrl())?.toString() == expectedUrl) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    await waitForUrl(urlA.toString());

    // Subscribe before navigating, or the load can complete before the listener attaches.
    var loadFuture = waitForUrl(urlB.toString());
    await controller.loadUrl(urlRequest: URLRequest(url: urlB));
    await loadFuture;
    expect(await controller.canGoBack(), isTrue);

    // ---- 1. page-initiated back, CANCEL: does not happen ----
    await controller.evaluateJavascript(source: 'history.back();');
    await Future.delayed(const Duration(seconds: 3));

    expect(
      seen,
      isNotEmpty,
      reason:
          'the delegate must have been consulted -- an empty list means the @objc thunk is '
          'missing or useShouldGoToBackForwardListItem was not inferred from the handler',
    );
    expect(
      (await controller.getUrl())?.toString(),
      urlB.toString(),
      reason: 'CANCEL must leave the WebView on the page it was showing',
    );
    expect(
      seen.first.url?.toString(),
      urlA.toString(),
      reason:
          'the item reported is the one we were about to go to, not the current one',
    );
    expect(
      seen.first.offset,
      -1,
      reason:
          'one step back, located natively in the current back/forward list',
    );

    // ---- 2. page-initiated back, ALLOW: happens ----
    decision = ShouldGoToBackForwardListItemAction.ALLOW;
    var seenBefore = seen.length;
    await controller.evaluateJavascript(source: 'history.back();');
    await waitForCurrentUrl(urlA.toString());

    expect(seen.length, greaterThan(seenBefore));
    expect(
      (await controller.getUrl())?.toString(),
      urlA.toString(),
      reason: 'ALLOW must let the same navigation through',
    );

    // ---- 3. programmatic goBack(), CANCEL: happens ANYWAY ----
    // Forward to B first so there is something to go back from again.
    await controller.evaluateJavascript(source: 'history.forward();');
    await waitForCurrentUrl(urlB.toString());
    expect(
      (await controller.getUrl())?.toString(),
      urlB.toString(),
      reason: 'setup for phase 3 -- forward must have happened',
    );

    decision = ShouldGoToBackForwardListItemAction.CANCEL;
    seenBefore = seen.length;
    await controller.goBack();
    await waitForCurrentUrl(urlA.toString());

    expect(
      seen.length,
      greaterThan(seenBefore),
      reason: 'the delegate is consulted for a programmatic goBack() too',
    );
    expect(
      (await controller.getUrl())?.toString(),
      urlA.toString(),
      reason:
          'MEASURED, not desired: WebKit performs an app-initiated back/forward navigation even '
          'when the delegate answers false. If this ever starts failing, the veto has become '
          'universal and PlatformWebViewCreationParams.shouldGoToBackForwardListItem needs its '
          'documentation revisited',
    );

    // `willUseInstantBack` is deliberately not asserted either way: WebKit decides whether the
    // target page is still resident, its header says a `true` is not a promise, and a simulator
    // under memory pressure is exactly where that could go either way. Recorded so a later reader
    // can see it was considered rather than forgotten.
    expect(instantBack, hasLength(seen.length));

    await pageLoads.close();
  }, skip: shouldSkip);
}
