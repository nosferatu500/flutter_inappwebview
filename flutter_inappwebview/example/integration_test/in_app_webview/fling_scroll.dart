part of 'main.dart';

/// Verifies `WebView.flingScroll` (§63) actually moves the scroll position.
///
/// The interesting thing to test is *not* a final position — a fling's endpoint is decided by the
/// platform's deceleration curve, so asserting a specific `scrollY` would be asserting an
/// implementation detail and would be flaky by construction. What is worth asserting is the part
/// the API promises: after a downward fling, the content ends up scrolled somewhere below where it
/// started.
///
/// Polls rather than sleeping a fixed time, because a fling is animated: the scroll position moves
/// over several frames and the test must not depend on how many.
void flingScroll() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.flingScroll,
  );

  skippableTestWidgets('flingScroll', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // Tall enough that there is definitely somewhere to fling to, and inline so nothing is
          // fetched (§57).
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head><meta charset="UTF-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1">'
                '</head><body style="margin:0">'
                '<div style="height:8000px;background:linear-gradient(#fff,#000)"></div>'
                '</body></html>',
          ),
          onWebViewCreated: (controller) =>
              controllerCompleter.complete(controller),
          onLoadStop: (controller, url) => pageLoaded.complete(),
        ),
      ),
    );

    final controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    expect(await controller.getScrollY(), 0, reason: 'should start at the top');

    await controller.flingScroll(velocityX: 0, velocityY: 6000);

    // The fling is animated, so give it frames to run rather than a single fixed sleep.
    int? scrollY;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      scrollY = await controller.getScrollY();
      if ((scrollY ?? 0) > 0) break;
    }

    expect(
      scrollY,
      isNotNull,
      reason: 'getScrollY stopped answering during the fling',
    );
    expect(
      scrollY,
      greaterThan(0),
      reason:
          'a downward fling left the scroll position at the top -- the velocity never reached the '
          'WebView, or the argument keys do not match what the Kotlin reads',
    );
  }, skip: shouldSkip);
}
