part of 'main.dart';

void onFaviconChanged() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onFaviconChanged,
  );

  skippableTestWidgets('onFaviconChanged', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<FaviconChangedRequest> onFaviconChangedCompleter =
        Completer<FaviconChangedRequest>();

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
            pageLoaded.complete();
          },
          onFaviconChanged: (controller, request) {
            if (!onFaviconChangedCompleter.isCompleted) {
              onFaviconChangedCompleter.complete(request);
            }
          },
        ),
      ),
    );

    await pageLoaded.future;
    final FaviconChangedRequest request =
        await onFaviconChangedCompleter.future;
    // Android reports the icon bytes, Windows may report the URL instead.
    expect(request.icon ?? request.url, isNotNull);
  }, skip: shouldSkip);
}
