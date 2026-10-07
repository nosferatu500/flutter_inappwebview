part of 'main.dart';

void refreshing() {
  final shouldSkip =
      !PullToRefreshController.isMethodSupported(
        PlatformPullToRefreshControllerMethod.beginRefreshing,
      ) ||
      !PullToRefreshController.isMethodSupported(
        PlatformPullToRefreshControllerMethod.isRefreshing,
      );

  skippableTestWidgets(
    'beginRefreshing, endRefreshing and isRefreshing round-trip',
    (WidgetTester tester) async {
      final controller = await _pumpWebViewWithPullToRefresh(tester);

      expect(await controller.isRefreshing(), false);

      await controller.beginRefreshing();
      expect(await controller.isRefreshing(), true);

      await controller.endRefreshing();
      expect(await controller.isRefreshing(), false);
    },
    skip: shouldSkip,
  );

  skippableTestWidgets('beginRefreshing does not fire onRefresh', (
    WidgetTester tester,
  ) async {
    var onRefreshFired = false;
    final controller = await _pumpWebViewWithPullToRefresh(
      tester,
      onRefresh: () {
        onRefreshFired = true;
      },
    );

    await controller.beginRefreshing();
    expect(await controller.isRefreshing(), true);
    // Give the event a chance to arrive before concluding it did not.
    await Future.delayed(const Duration(seconds: 1));

    // `SwipeRefreshLayout.setRefreshing(true)` moves the indicator without invoking
    // `OnRefreshListener`, so the callback belongs to a *user's* drag and nothing else.
    //
    // This is the reachable half of `onRefresh`. The other half — the event actually firing —
    // needs a real drag on a platform view, which `WidgetTester` cannot deliver (the same reason
    // `flingScroll` is a documented flake). So the channel's one event stays **uncovered in the
    // firing direction**, and this test at least pins that `beginRefreshing` is not a back door
    // into it: a platform side that called the listener from `setRefreshing` would make every
    // programmatic refresh re-enter the app's own handler.
    expect(onRefreshFired, false);
  }, skip: shouldSkip);

  // A `beginRefreshing` made before the WebView is on screen. iOS's `UIRefreshControl` ignores it
  // while it has no window and doesn't catch up when the window arrives, so the refresh was lost
  // (measured §288: the two tests above failed whenever the view wasn't composited yet). The
  // plugin now applies it when the window arrives. Called from `onWebViewCreated`, before any
  // frame has composited the view.
  skippableTestWidgets(
    'beginRefreshing before the WebView is on screen takes effect once it is',
    (WidgetTester tester) async {
      var onRefreshFired = false;
      final Completer<void> begun = Completer<void>();
      final Completer<void> pageLoaded = Completer<void>();
      final controller = PullToRefreshController(
        settings: PullToRefreshSettings(enabled: true),
        onRefresh: () => onRefreshFired = true,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile: "test_assets/in_app_webview_initial_file_test.html",
            pullToRefreshController: controller,
            onWebViewCreated: (_) async {
              await controller.beginRefreshing();
              begun.complete();
            },
            onLoadStop: (webViewController, url) {
              if (!pageLoaded.isCompleted) pageLoaded.complete();
            },
          ),
        ),
      );
      await begun.future.timeout(const Duration(seconds: 20));
      await pageLoaded.future.timeout(const Duration(seconds: 20));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      expect(await controller.isRefreshing(), true);
      await controller.endRefreshing();
      expect(await controller.isRefreshing(), false);
      expect(onRefreshFired, false);
    },
    skip: shouldSkip,
  );
}
