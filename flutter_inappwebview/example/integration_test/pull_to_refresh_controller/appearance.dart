part of 'main.dart';

void appearance() {
  final shouldSkip = !PullToRefreshController.isMethodSupported(
    PlatformPullToRefreshControllerMethod.getDefaultSlingshotDistance,
  );

  skippableTestWidgets('getDefaultSlingshotDistance answers the platform constant', (
    WidgetTester tester,
  ) async {
    final controller = await _pumpWebViewWithPullToRefresh(tester);

    // `SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE` is **-1**, read out of the androidx AAR with
    // `javap -constants` rather than guessed. It is a sentinel meaning "compute the default", not a
    // distance — so a test asserting a positive number here would have been wrong about the API.
    //
    // -1 is also the one value that proves the call *arrived*: the Dart side falls back to `?? 0`
    // when the channel is null, so a dead channel answers 0 and cannot pass this.
    expect(await controller.getDefaultSlingshotDistance(), -1);
  }, skip: shouldSkip);

  skippableTestWidgets('the write-only setters are accepted by the platform', (
    WidgetTester tester,
  ) async {
    final controller = await _pumpWebViewWithPullToRefresh(tester);

    // ⚠️ **Transport coverage only, and deliberately labelled as such** (§171). These five have no
    // getter on either side of the channel — `SwipeRefreshLayout` exposes no reader for the colour
    // scheme, the trigger distance, the slingshot distance or the indicator size — so there is
    // nothing to assert beyond "the platform accepted the call and answered".
    //
    // That is not nothing: each one narrows or parses its argument on the Kotlin side
    // (`Color.parseColor` on a hex string, `Int` for the two distances, the native enum value for
    // the size), and a malformed argument throws there rather than being ignored. A mutant that
    // drops any of these payloads would survive this test, and when this channel is migrated that
    // gap should be stated rather than papered over.
    await expectLater(controller.setColor(Colors.blue), completes);
    await expectLater(controller.setBackgroundColor(Colors.grey), completes);
    await expectLater(controller.setDistanceToTriggerSync(150), completes);
    await expectLater(controller.setSlingshotDistance(150), completes);
    await expectLater(
      controller.setIndicatorSize(PullToRefreshSize.LARGE),
      completes,
    );

    // The controller is still answering afterwards, which a throw on any of the five would have
    // prevented — the assertion that gives the five above their meaning.
    expect(await controller.isEnabled(), true);
  }, skip: shouldSkip);
}
