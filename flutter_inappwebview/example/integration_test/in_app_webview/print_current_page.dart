part of 'main.dart';

void printCurrentPage() {
  // Skipped on Android when every group runs in one process (`webview_flutter_test.dart`): its print
  // dialog can't be dismissed and blocks every later group (§289, §304). The `in_app_webview` group
  // run on its own still runs it, last.
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.printCurrentPage,
      ) ||
      (runningAllGroups && defaultTargetPlatform == TargetPlatform.android);

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('printCurrentPage', (WidgetTester tester) async {
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
    await expectLater(controller.printCurrentPage(), completes);
  }, skip: shouldSkip);
}
