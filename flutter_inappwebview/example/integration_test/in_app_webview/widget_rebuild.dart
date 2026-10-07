part of 'main.dart';

/// A parent rebuild constructs a new `InAppWebView`, and with it a new platform widget object, but
/// keeps the same `State`, the same platform view and the same controller. The controller used to
/// stay with the first platform object, so the widget's dispose ran on one that had none and the
/// controller was never disposed (§269: measured on both platforms).
void widgetRebuild() {
  final shouldSkip = ![
    TargetPlatform.android,
    TargetPlatform.iOS,
  ].contains(defaultTargetPlatform);

  final data = InAppWebViewInitialData(
    data: '<html><body>rebuild</body></html>',
    baseUrl: WebUri('https://www.example.com/'),
  );

  Future<InAppWebViewController> created(
    WidgetTester tester,
    Completer<InAppWebViewController> controller,
    Completer<void> loaded,
  ) async {
    final c = await controller.future.timeout(const Duration(seconds: 20));
    await loaded.future.timeout(const Duration(seconds: 20));
    // Composite the view first, as an app's next frame would; with no pointer activity the binding
    // draws only the frames a test pumps (§268).
    await tester.pump();
    // Disposing the controller drops its JavaScript handlers (the app's closures), and reading
    // them back needs neither the platform nor a live channel, so this tells a disposed
    // controller from a leaked one on both platforms.
    c.addJavaScriptHandler(handlerName: 'rebuild', callback: (_) {});
    expect(c.hasJavaScriptHandler(handlerName: 'rebuild'), isTrue);
    return c;
  }

  void expectDisposed(InAppWebViewController controller) {
    expect(
      controller.hasJavaScriptHandler(handlerName: 'rebuild'),
      isFalse,
      reason: 'the controller was not disposed with its widget',
    );
  }

  skippableTestWidgets('the controller is disposed with its widget', (
    WidgetTester tester,
  ) async {
    final controller = Completer<InAppWebViewController>();
    final loaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: data,
          onWebViewCreated: (c) => controller.complete(c),
          onLoadStop: (c, url) {
            if (!loaded.isCompleted) loaded.complete();
          },
        ),
      ),
    );
    final c = await created(tester, controller, loaded);
    await tester.pumpWidget(const SizedBox());
    expectDisposed(c);
  }, skip: shouldSkip);

  skippableTestWidgets(
    'the controller is disposed with its widget after a parent rebuild',
    (WidgetTester tester) async {
      final controller = Completer<InAppWebViewController>();
      final loaded = Completer<void>();
      final generation = ValueNotifier<int>(0);
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<int>(
            valueListenable: generation,
            // A new InAppWebView, and so a new platform widget object, on every rebuild.
            builder: (context, _, _) => InAppWebView(
              key: key,
              initialData: data,
              onWebViewCreated: (c) => controller.complete(c),
              onLoadStop: (c, url) {
                if (!loaded.isCompleted) loaded.complete();
              },
            ),
          ),
        ),
      );
      final c = await created(tester, controller, loaded);
      generation.value++;
      await tester.pump();
      generation.value++;
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      expectDisposed(c);
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'the controller is disposed with its widget after a rebuild that keeps the platform object',
    (WidgetTester tester) async {
      final controller = Completer<InAppWebViewController>();
      final loaded = Completer<void>();
      final generation = ValueNotifier<int>(0);
      final key = GlobalKey();
      final platform = InAppWebView(
        initialData: data,
        onWebViewCreated: (c) => controller.complete(c),
        onLoadStop: (c, url) {
          if (!loaded.isCompleted) loaded.complete();
        },
      ).platform;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<int>(
            valueListenable: generation,
            // A new InAppWebView on every rebuild, sharing one platform widget object.
            builder: (context, _, _) =>
                InAppWebView.fromPlatform(key: key, platform: platform),
          ),
        ),
      );
      final c = await created(tester, controller, loaded);
      generation.value++;
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      expectDisposed(c);
    },
    skip: shouldSkip,
  );
}
