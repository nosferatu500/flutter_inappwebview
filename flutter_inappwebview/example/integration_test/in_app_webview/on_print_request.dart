part of 'main.dart';

void onPrintRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPrintRequest,
  );

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  // Returning `true` suppresses the print job entirely: since 7.0.0 the plugin asks Dart *before*
  // calling the native printCurrentPage(), so no OS print dialog is ever raised here.
  //
  // That is what makes this test safe to run. Before the change the native side printed first and
  // only then asked Dart, so this test left `com.android.printspooler/.ui.PrintActivity` sitting on
  // top of the app no matter what it returned -- and on Android 17 every test scheduled after it
  // timed out at 60s against a UI it could never reach.
  //
  // The `false` branch is deliberately NOT covered by an automated test: it is the branch that
  // raises the modal, and nothing in the plugin API can dismiss it (PrintJob.cancel() is a no-op
  // while the job is in CREATED state). `printCurrentPage` below still exercises that path.
  skippableTestWidgets('onPrintRequest', (WidgetTester tester) async {
    final Completer<String> onPrintCompleter = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: "window.print();");
          },
          onPrintRequest: (controller, url) async {
            onPrintCompleter.complete(url?.toString());
            return true;
          },
        ),
      ),
    );
    await tester.pump();
    final String printUrl = await onPrintCompleter.future;
    expect(printUrl, url.toString());
  }, skip: shouldSkip);
}
