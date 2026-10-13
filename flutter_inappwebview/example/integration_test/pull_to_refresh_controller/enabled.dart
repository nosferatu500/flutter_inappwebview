part of 'main.dart';

void enabled() {
  final shouldSkip =
      !PullToRefreshController.isMethodSupported(
        PlatformPullToRefreshControllerMethod.setEnabled,
      ) ||
      !PullToRefreshController.isMethodSupported(
        PlatformPullToRefreshControllerMethod.isEnabled,
      );

  skippableTestWidgets('setEnabled and isEnabled round-trip', (
    WidgetTester tester,
  ) async {
    final controller = await _pumpWebViewWithPullToRefresh(
      tester,
      settings: PullToRefreshSettings(enabled: true),
    );

    // The creation payload asked for enabled: true, and `PullToRefreshLayout.prepare()` applies it.
    // Asserted first so the two later assertions are known to be *changes* rather than the state
    // the view happened to start in.
    expect(await controller.isEnabled(), true);

    await controller.setEnabled(false);
    expect(await controller.isEnabled(), false);

    // Back again: a `setEnabled` that ignored its argument and always disabled would pass the
    // assertion above and fail this one.
    await controller.setEnabled(true);
    expect(await controller.isEnabled(), true);
  }, skip: shouldSkip);
}
