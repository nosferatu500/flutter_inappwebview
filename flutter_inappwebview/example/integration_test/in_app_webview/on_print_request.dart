part of 'main.dart';

/// Records the app's lifecycle changes. The print dialog is another app's Activity, so raising it
/// pauses this one, and that is the only trace of it a test in this process can see.
class _LifecycleRecorder with WidgetsBindingObserver {
  final List<AppLifecycleState> states = <AppLifecycleState>[];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => states.add(state);
}

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
  //
  // That `true` really suppresses it is asserted through the app lifecycle (§215). Measured on
  // API 37 with a local page whose handler answered `false`: the dialog took the app through
  // inactive, hidden and paused within four seconds. Answering `true`, nothing changed.
  skippableTestWidgets('onPrintRequest', (WidgetTester tester) async {
    final Completer<String> onPrintCompleter = Completer<String>();
    final lifecycle = _LifecycleRecorder();
    WidgetsBinding.instance.addObserver(lifecycle);
    addTearDown(() => WidgetsBinding.instance.removeObserver(lifecycle));
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

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Future.delayed(const Duration(seconds: 4));
      expect(
        lifecycle.states,
        isEmpty,
        reason: 'the app was paused, so the print dialog was raised anyway',
      );
    }
  }, skip: shouldSkip);
}
