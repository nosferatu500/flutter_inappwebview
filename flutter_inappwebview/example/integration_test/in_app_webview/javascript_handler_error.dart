part of 'main.dart';

/// Regression test for §66: a JavaScript handler that **throws** must reject the caller's promise,
/// not leave it pending.
///
/// Before the fix, the iOS side built the rejection by interpolating the error message into a
/// single-quoted JS string literal escaping only `'`. A Dart `Exception` message routinely contains
/// a newline, which made the whole script invalid, so `evaluateJavaScript` failed silently and the
/// promise stayed pending **for the lifetime of the page** — `await callHandler(...)` never settled.
///
/// The message below deliberately contains a newline *and* a single quote, because either alone
/// would not have caught it: the old code escaped the quote correctly and the newline not at all.
///
/// The happy path is asserted in the same test on purpose. A rejection test alone would still pass
/// against an implementation that rejected everything.
void javascriptHandlerError() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
  );

  skippableTestWidgets('JavaScript Handler error rejects the promise', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: """
<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body>
<script>
window.okState = 'pending'; window.okResult = null;
window.badState = 'pending'; window.badResult = null;
window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  window.flutter_inappwebview.callHandler('okHandler', 7)
    .then(function(r) { window.okState = 'resolved'; window.okResult = JSON.stringify(r); })
    .catch(function(e) { window.okState = 'rejected'; window.okResult = String(e); });
  window.flutter_inappwebview.callHandler('throwingHandler')
    .then(function(r) { window.badState = 'resolved'; window.badResult = JSON.stringify(r); })
    .catch(function(e) { window.badState = 'rejected'; window.badResult = String(e); });
});
</script></body></html>
""",
          ),
          onWebViewCreated: (controller) {
            // Note the parameter is a JavaScriptHandlerFunctionData, not a List: the args are on
            // `.args`. Several older tests in this group still index it directly and throw.
            controller.addJavaScriptHandler(
              handlerName: 'okHandler',
              callback: (data) => {'echo': data.args.first},
            );
            controller.addJavaScriptHandler(
              handlerName: 'throwingHandler',
              callback: (data) {
                throw Exception("first line\nsecond line 'quoted'");
              },
            );
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) => pageLoaded.complete(),
        ),
      ),
    );

    final controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    Future<String?> state(String name) async =>
        await controller.evaluateJavascript(source: 'window.$name;') as String?;

    // Poll: both settle within a couple of frames, but neither is synchronous.
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (await state('okState') != 'pending' &&
          await state('badState') != 'pending') {
        break;
      }
    }

    expect(
      await state('okState'),
      'resolved',
      reason: 'a well-behaved handler did not resolve its promise',
    );
    expect(
      await controller.evaluateJavascript(source: 'window.okResult;'),
      '{"echo":7}',
    );

    expect(
      await state('badState'),
      'rejected',
      reason:
          'a throwing handler left the promise pending -- the rejection script is probably invalid '
          'JavaScript again, so evaluateJavaScript failed silently',
    );
    // The thrown message must survive escaping intact, newline and quote included.
    final badResult =
        await controller.evaluateJavascript(source: 'window.badResult;')
            as String?;
    expect(badResult, contains('first line'));
    expect(badResult, contains("second line 'quoted'"));
  }, skip: shouldSkip);
}
