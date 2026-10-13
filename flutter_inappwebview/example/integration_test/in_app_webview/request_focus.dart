part of 'main.dart';

void requestFocus() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.requestFocus,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // The Kotlin handler has three branches: no arguments, a direction, and a direction with the
  // previously focused rect. `clear_focus.dart` already uses the first as its precondition, so this
  // covers the other two. Measured on API 37: each answers true and gives the page focus
  // (`document.hasFocus()`), starting from no focus each time (§193).
  skippableTestWidgets('requestFocus', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body><input id="field"></body></html>',
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

    Future<dynamic> hasFocus() async {
      await Future.delayed(const Duration(seconds: 1));
      return controller.evaluateJavascript(source: 'document.hasFocus()');
    }

    expect(await hasFocus(), isFalse, reason: 'precondition');
    expect(
      await controller.requestFocus(direction: FocusDirection.DOWN),
      isTrue,
    );
    expect(await hasFocus(), isTrue);

    await controller.clearFocus();
    expect(await hasFocus(), isFalse, reason: 'precondition');
    expect(
      await controller.requestFocus(
        direction: FocusDirection.UP,
        previouslyFocusedRect: InAppWebViewRect(
          x: 0,
          y: 0,
          width: 10,
          height: 10,
        ),
      ),
      isTrue,
    );
    expect(await hasFocus(), isTrue);
  }, skip: shouldSkip);
}
