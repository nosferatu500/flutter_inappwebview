part of 'main.dart';

void onRenderProcessGone() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onRenderProcessGone,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // `chrome://crash` makes the renderer crash on purpose. Measured on API 37: `didCrash` is true
  // (§192). `useOnRenderProcessGone` is required. Without it the plugin returns the platform
  // default, which for a crashed renderer kills the app.
  skippableTestWidgets('onRenderProcessGone', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<RenderProcessGoneDetail> gone =
        Completer<RenderProcessGoneDetail>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialSettings: InAppWebViewSettings(useOnRenderProcessGone: true),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>renderer</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onRenderProcessGone: (controller, detail) {
            if (!gone.isCompleted) gone.complete(detail);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri('chrome://crash')),
    );

    final detail = await gone.future.timeout(const Duration(seconds: 20));
    expect(detail.didCrash, isTrue);
    // Measured on API 37 (§213): with no priority policy the renderer exits at IMPORTANT.
    expect(
      detail.rendererPriorityAtExit,
      RendererPriority.RENDERER_PRIORITY_IMPORTANT,
    );
  }, skip: shouldSkip);

  // The default priority alone can't tell a passed-through value from a constant. With a BOUND
  // policy the renderer exits at BOUND (measured, §213), which only the real value produces.
  skippableTestWidgets('onRenderProcessGone reports the priority at exit', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<RenderProcessGoneDetail> gone =
        Completer<RenderProcessGoneDetail>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialSettings: InAppWebViewSettings(
            useOnRenderProcessGone: true,
            rendererPriorityPolicy: RendererPriorityPolicy(
              rendererRequestedPriority:
                  RendererPriority.RENDERER_PRIORITY_BOUND,
              waivedWhenNotVisible: false,
            ),
          ),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>renderer</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onRenderProcessGone: (controller, detail) {
            if (!gone.isCompleted) gone.complete(detail);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri('chrome://crash')),
    );
    final detail = await gone.future.timeout(const Duration(seconds: 20));
    expect(detail.didCrash, isTrue);
    expect(
      detail.rendererPriorityAtExit,
      RendererPriority.RENDERER_PRIORITY_BOUND,
    );
  }, skip: shouldSkip);
}
