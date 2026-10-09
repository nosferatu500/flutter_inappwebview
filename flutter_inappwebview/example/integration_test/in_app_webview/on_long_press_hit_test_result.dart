part of 'main.dart';

/// Pumps frames for about two seconds. Call it after the page has loaded and before the first
/// gesture or zoom.
///
/// Measured on API 37 (§192): without it, a gesture sent right after `onLoadStop` is lost. Long
/// press, drag and tap each timed out, and `zoomBy` reported no scale change, while the same calls
/// worked after frames had been pumped. `await pageLoaded.future` pumps none. This is probably also
/// why §191's first tap into a fresh page reported nothing: its "second tap" came after a pump.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

void onLongPressHitTestResult() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onLongPressHitTestResult,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Measured on API 37: a long press on a link reports SRC_ANCHOR_TYPE with the link's URL, 3 of 3
  // presses. One probe that tapped the page first reported UNKNOWN_TYPE once, so this test does not
  // tap before pressing (§192).
  skippableTestWidgets('onLongPressHitTestResult', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<InAppWebViewHitTestResult> hitTestResult =
        Completer<InAppWebViewHitTestResult>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><a href="https://example.com/long-press" '
                'style="display:block;height:100vh;font-size:40px">long press link</a>'
                '</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onLongPressHitTestResult: (controller, result) {
            if (!hitTestResult.isCompleted) hitTestResult.complete(result);
          },
        ),
      ),
    );

    await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.longPressAt(Offset(size.width / 2, size.height / 2));

    final result = await hitTestResult.future.timeout(
      const Duration(seconds: 10),
    );
    expect(result.type, InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE);
    expect(result.extra, 'https://example.com/long-press');
  }, skip: shouldSkip);
}
