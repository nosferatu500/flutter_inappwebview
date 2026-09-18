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
}
