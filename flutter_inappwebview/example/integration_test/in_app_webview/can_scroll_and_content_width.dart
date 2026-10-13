part of 'main.dart';

void canScrollAndContentWidth() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.canScrollVertically,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  Future<InAppWebViewController> load(WidgetTester tester, String body) async {
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
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0">$body</body></html>',
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
    final controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);
    return controller;
  }

  // Measured on API 37: a page four screens tall scrolls vertically and not horizontally, and is as
  // wide as the viewport (411). A page 2000 px wide scrolls horizontally and reports that width
  // (§193). The tall page's (true, false) pair is what catches the two getters being crossed.
  skippableGroup(
    'canScrollVertically / canScrollHorizontally / getContentWidth',
    () {
      skippableTestWidgets('a tall page', (WidgetTester tester) async {
        final controller = await load(
          tester,
          '<div style="height:400vh">tall</div>',
        );
        expect(await controller.canScrollVertically(), isTrue);
        expect(await controller.canScrollHorizontally(), isFalse);
      });

      skippableTestWidgets('a wide page', (WidgetTester tester) async {
        final controller = await load(
          tester,
          '<div style="width:2000px;height:10px">wide</div>',
        );
        expect(await controller.canScrollHorizontally(), isTrue);
        expect(await controller.getContentWidth(), 2000);
      });
    },
    skip: shouldSkip,
  );
}
