part of 'main.dart';

void getHitTestResult() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.getHitTestResult,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Measured on API 37: UNKNOWN_TYPE before anything is touched, then SRC_ANCHOR_TYPE with the
  // link's URL after a tap on it (§193). The link's click is cancelled so the tap does not navigate.
  skippableTestWidgets('getHitTestResult', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><a href="https://example.com/hit" '
                'onclick="event.preventDefault()" style="display:block;height:100vh">link</a>'
                '</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    final before = await controller.getHitTestResult();
    expect(before?.type, InAppWebViewHitTestResultType.UNKNOWN_TYPE);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.tapAt(Offset(size.width / 2, size.height / 2));
    await _pumpFrames(tester);

    final after = await controller.getHitTestResult();
    expect(after?.type, InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE);
    expect(after?.extra, 'https://example.com/hit');
  }, skip: shouldSkip);
}
