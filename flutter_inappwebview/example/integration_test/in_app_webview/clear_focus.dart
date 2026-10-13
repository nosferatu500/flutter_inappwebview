part of 'main.dart';

void clearFocus() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.clearFocus,
  );

  skippableTestWidgets('clearFocus', (WidgetTester tester) async {
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
                '<!DOCTYPE html><html><body><input id="field">'
                '<script>var blurs = 0;'
                'window.addEventListener("blur", function() { blurs++; });'
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

    if (defaultTargetPlatform != TargetPlatform.android) {
      await expectLater(controller.clearFocus(), completes);
      return;
    }

    // A freshly created WebView does not have focus, so clearing it would show nothing: take
    // focus first, and check that it was taken. Measured on API 37: `document.hasFocus()` reads
    // false after load, true after `requestFocus()`, false after `clearFocus()`, and exactly one
    // window `blur` fires. Before this, the test only checked that the call completed, and a
    // Kotlin handler that replied without clearing anything passed it.
    expect(await controller.requestFocus(), isTrue);
    await Future.delayed(const Duration(seconds: 1));
    expect(
      await controller.evaluateJavascript(source: 'document.hasFocus()'),
      isTrue,
      reason: 'precondition: the page must have focus before it can lose it',
    );

    await controller.clearFocus();
    await Future.delayed(const Duration(seconds: 1));

    expect(
      await controller.evaluateJavascript(source: 'document.hasFocus()'),
      isFalse,
    );
    expect(await controller.evaluateJavascript(source: 'blurs'), 1);
  }, skip: shouldSkip);
}
