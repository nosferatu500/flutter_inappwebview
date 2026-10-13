part of 'main.dart';

void getSelectedText() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.getSelectedText,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Measured on API 37: with nothing selected the answer is an empty string, not null. After a
  // selection made with a JavaScript range, it is exactly the selected word (§193).
  skippableTestWidgets('getSelectedText', (WidgetTester tester) async {
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
                '<!DOCTYPE html><html><body><p id="p">alpha beta gamma</p></body></html>',
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

    expect(await controller.getSelectedText(), '');

    await controller.evaluateJavascript(
      source:
          'var text = document.getElementById("p").firstChild;'
          'var range = document.createRange();'
          'range.setStart(text, 6); range.setEnd(text, 10);'
          'var selection = window.getSelection();'
          'selection.removeAllRanges(); selection.addRange(range);',
    );

    expect(await controller.getSelectedText(), 'beta');
  }, skip: shouldSkip);
}
