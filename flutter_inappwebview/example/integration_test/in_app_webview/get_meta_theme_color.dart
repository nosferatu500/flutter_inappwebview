part of 'main.dart';

void getMetaThemeColor() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getMetaThemeColor,
  );

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('getMetaThemeColor', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    expect(await controller.getMetaThemeColor(), isNotNull);
  }, skip: shouldSkip);

  // The test above cannot tell one color from another, and a third-party page's color is not ours
  // to pin. A fallback returning any non-null color passed it (§190). This page carries a known
  // value with three different components. Android only: there the value always comes from
  // reading the meta tag with JavaScript. iOS reads `WKWebView.themeColor` natively, which was not
  // measured against this page.
  skippableTestWidgets(
    'getMetaThemeColor reads the page\'s exact color',
    (WidgetTester tester) async {
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
                  '<!DOCTYPE html><html><head><meta charset="UTF-8">'
                  '<meta name="theme-color" content="#0a8f3c">'
                  '</head><body>theme</body></html>',
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

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      expect(await controller.getMetaThemeColor(), const Color(0xFF0A8F3C));
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
  );
}
