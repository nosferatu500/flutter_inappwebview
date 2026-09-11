part of 'main.dart';

void startAndStop() {
  final shouldSkip =
      !TracingController.isMethodSupported(
        PlatformTracingControllerMethod.start,
      ) ||
      !TracingController.isMethodSupported(
        PlatformTracingControllerMethod.stop,
      );

  skippableTestWidgets('start and stop', (WidgetTester tester) async {
    final Completer<void> pageLoaded = Completer<void>();

    final tracingAvailable = await WebViewFeature.isFeatureSupported(
      WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE,
    );

    if (!tracingAvailable) {
      return;
    }

    final tracingController = TracingController.instance();
    expect(await tracingController.isTracing(), false);
    await tracingController.start(
      settings: TracingSettings(
        tracingMode: TracingMode.RECORD_CONTINUOUSLY,
        categories: [TracingCategory.CATEGORIES_ANDROID_WEBVIEW, "blink*"],
      ),
    );
    expect(await tracingController.isTracing(), true);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
        ),
      ),
    );

    await pageLoaded.future;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String traceFilePath =
        '${appDocDir.path}${Platform.pathSeparator}trace.json';
    expect(await tracingController.stop(filePath: traceFilePath), true);

    expect(File(traceFilePath).existsSync(), true);

    // `stop()` returning true means tracing was stopped, NOT that the trace has been written:
    // the plugin hands androidx an Executor and the flush runs on it. `isTracing()` stays true
    // until that finishes, and how long that takes scales with the trace — measured at ~6s for
    // an 8.5 MB file on an API 37 emulator, so the fixed 2-second sleep this replaces failed
    // deterministically (3 runs out of 3). Poll instead of guessing a duration.
    var stillTracing = true;
    for (var i = 0; i < 30 && stillTracing; i++) {
      await Future.delayed(Duration(seconds: 1));
      stillTracing = await tracingController.isTracing();
    }
    expect(
      stillTracing,
      false,
      reason:
          'isTracing() was still true 30s after stop() returned true; the trace flush never '
          'completed (trace file is ${File(traceFilePath).lengthSync()} bytes).',
    );
  }, skip: shouldSkip);
}
