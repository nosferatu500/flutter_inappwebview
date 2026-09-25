part of 'main.dart';

void programmaticZoomScale() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onZoomScaleChanged,
  );

  skippableGroup('programmatic zoom scale', () {
    final shouldSkipTest1 = !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.zoomIn,
    );

    skippableTestWidgets('zoomIn/zoomOut', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      expect(await controller.zoomIn(), true);
      await Future.delayed(Duration(seconds: 1));
      expect(await controller.zoomOut(), true);
    }, skip: shouldSkipTest1);

    skippableTestWidgets('onZoomScaleChanged', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> onZoomScaleChangedCompleter = Completer<void>();
      final scaleChanges = <List<double>>[];

      var listenForScaleChange = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
            onZoomScaleChanged: (controller, oldScale, newScale) {
              if (listenForScaleChange) {
                scaleChanges.add([oldScale, newScale]);
                if (!onZoomScaleChangedCompleter.isCompleted) {
                  onZoomScaleChangedCompleter.complete();
                }
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      // Lets the page's own layout-time scale changes land before listening, and gives `zoomBy`
      // a laid-out view to act on (see `_pumpFrames`).
      await _pumpFrames(tester);
      listenForScaleChange = true;

      await controller.zoomBy(zoomFactor: 2);

      await expectLater(onZoomScaleChangedCompleter.future, completes);

      if (defaultTargetPlatform == TargetPlatform.android) {
        // "It fired" could not tell old from new, and swapping them in Kotlin passed it (§189).
        // Page layout also reports scale changes of its own, so look for the one `zoomBy(2)` makes:
        // measured on API 37 as 2.625 → 5.25, in device pixels. A swap reads 5.25 → 2.625 instead.
        await Future.delayed(const Duration(seconds: 1));
        expect(
          scaleChanges.any((c) => (c[1] / c[0] - 2).abs() < 0.01),
          isTrue,
          reason: 'no scale change doubled the scale: $scaleChanges',
        );
      }
    });

    skippableTestWidgets('zoomBy', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await expectLater(
        controller.zoomBy(zoomFactor: 3.0, animated: true),
        completes,
      );
    });

    skippableTestWidgets('getZoomScale', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final scale = await controller.getZoomScale();
      expect(scale, isNonZero);
      expect(scale, isPositive);
    });
  }, skip: shouldSkip);
}
