part of 'main.dart';

void requestImageRef() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.requestImageRef,
  );

  skippableTestWidgets('requestImageRef', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // Shared with requestFocusNodeHref, see request_focus_node_href.dart.
          initialData: InAppWebViewInitialData(data: _hitTestPage),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    if (defaultTargetPlatform != TargetPlatform.android) {
      await expectLater(controller.requestImageRef(), completes);
      return;
    }

    // Before this, the test only checked that the call completed. Values measured on API 37.
    final size = tester.getSize(find.byType(InAppWebView));

    await _tapTwice(tester, Offset(size.width / 2, size.height / 4));
    expect(
      (await controller.requestImageRef())?.url,
      isNull,
      reason: 'a link without an image has no image to report',
    );

    await _tapTwice(tester, Offset(size.width / 2, size.height * 3 / 4));
    expect((await controller.requestImageRef())?.url?.toString(), _onePixelPng);
  }, skip: shouldSkip);
}
