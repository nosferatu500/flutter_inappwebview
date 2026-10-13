part of 'main.dart';

void onOverScrolled() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onOverScrolled,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Dragging the page down while it is already at the top pulls past the top edge. Measured on API
  // 37: every report is x = 0, y = 0, clampedX false, clampedY true. A fling towards the top did
  // not report anything, which is why this drags (§192). The clamped pair is asymmetric, so a
  // transposition of the two flags fails.
  skippableTestWidgets('onOverScrolled', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<Object>> overScrolled = Completer<List<Object>>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><div style="height:400vh">tall</div></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onOverScrolled: (controller, x, y, clampedX, clampedY) {
            if (!overScrolled.isCompleted) {
              overScrolled.complete([x, y, clampedX, clampedY]);
            }
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);
    expect(await controller.getScrollY(), 0, reason: 'must start at the top');

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.dragFrom(
      Offset(size.width / 2, size.height / 3),
      const Offset(0, 300),
    );

    expect(await overScrolled.future.timeout(const Duration(seconds: 10)), [
      0,
      0,
      false,
      true,
    ]);
  }, skip: shouldSkip);

  // At the top both positions are 0, so the test above can't see x and y (§192's designed
  // survivor). Here the page is scrolled to its bottom-right corner first, and then dragged up,
  // past the bottom. Measured on API 37 (§213): x and y are the two maximum scroll offsets (on
  // this device 6796 and 7272 for a 3000 px × 400vh page), and clampedY is true. The page here is
  // much taller than it is wide, so y > 2x whatever the screen, and a swap of x and y fails.
  skippableTestWidgets('onOverScrolled reports x and y at the bottom-right', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final reports = <List<Object>>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0">'
                '<div style="width:2000px;height:8000px">big</div></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onOverScrolled: (controller, x, y, clampedX, clampedY) {
            reports.add([x, y, clampedX, clampedY]);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);
    await controller.scrollTo(x: 100000, y: 100000);
    await _pumpFrames(tester);
    reports.clear();

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.dragFrom(
      Offset(size.width / 2, size.height * 2 / 3),
      const Offset(0, -300),
    );
    await _pumpFrames(tester);

    expect(reports, isNotEmpty, reason: 'no over-scroll at the bottom');
    final report = reports.first;
    final x = report[0] as int;
    final y = report[1] as int;
    expect(x, greaterThan(0), reason: 'x must be the horizontal maximum');
    expect(
      y,
      greaterThan(2 * x),
      reason: 'y must be the (much larger) vertical one',
    );
    expect(report[3], isTrue, reason: 'clampedY at the bottom');
  }, skip: shouldSkip);
}
