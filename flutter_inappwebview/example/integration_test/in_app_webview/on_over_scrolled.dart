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
}
