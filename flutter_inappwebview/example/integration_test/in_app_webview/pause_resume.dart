part of 'main.dart';

void pauseResume() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.pause,
  );

  skippableTestWidgets('pause/resume', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // `frames` counts animation frames. `WebView.onPause()` stops them and hides the page;
          // it does not stop JavaScript, which is what lets the test read both back while paused.
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><body>paused?<script>var frames = 0;'
                '(function tick() { frames++; requestAnimationFrame(tick); })();'
                '</script></body></html>',
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

    Future<dynamic> js(String source) =>
        controller.evaluateJavascript(source: source);

    // Measured on API 37: `visibilityState` is 'visible' → 'hidden' → 'visible', and the frame
    // counter stands still while paused (4 → 4 over a second) and runs again after resume. Before
    // this, the test only checked that both calls completed, and Kotlin handlers that replied
    // without calling onPause / onResume passed it.
    expect(await js('document.visibilityState'), 'visible');

    await controller.pause();
    try {
      await Future.delayed(const Duration(seconds: 1));
      expect(await js('document.visibilityState'), 'hidden');
      final framesPaused = await js('frames');
      await Future.delayed(const Duration(seconds: 1));
      expect(
        await js('frames'),
        framesPaused,
        reason: 'no animation frame may run while the WebView is paused',
      );
    } finally {
      await controller.resume();
    }

    await Future.delayed(const Duration(seconds: 1));
    expect(await js('document.visibilityState'), 'visible');
    final framesResumed = await js('frames');
    await Future.delayed(const Duration(seconds: 1));
    expect(await js('frames'), greaterThan(framesResumed));
  }, skip: shouldSkip);
}
