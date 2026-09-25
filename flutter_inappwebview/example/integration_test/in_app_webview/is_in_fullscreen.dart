part of 'main.dart';

void isInFullscreen() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.isInFullscreen,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Measured on API 37: false → true while the page is fullscreen → false after it leaves (§193).
  // The page goes fullscreen the same way as in fullscreen_events.dart.
  skippableTestWidgets('isInFullscreen', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> entered = Completer<void>();
    final Completer<void> exited = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><div onclick="this.requestFullscreen()" '
                'style="height:100vh;background:#0a0">fullscreen</div></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onEnterFullscreen: (controller) {
            if (!entered.isCompleted) entered.complete();
          },
          onExitFullscreen: (controller) {
            if (!exited.isCompleted) exited.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    expect(await controller.isInFullscreen(), isFalse);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.tapAt(Offset(size.width / 2, size.height / 2));
    try {
      await entered.future.timeout(const Duration(seconds: 10));
      expect(await controller.isInFullscreen(), isTrue);
    } finally {
      // The fullscreen view covers the Flutter view; leave it even if the assertion failed.
      await controller.evaluateJavascript(source: 'document.exitFullscreen();');
    }

    await exited.future.timeout(const Duration(seconds: 10));
    expect(await controller.isInFullscreen(), isFalse);
  }, skip: shouldSkip);
}
