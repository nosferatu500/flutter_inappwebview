part of 'main.dart';

void onLoadStart() {
  // Android only: this is the only platform the values below were measured on (API 37, §213).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onLoadStart,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Every other test used `onLoadStart` only as "the load began" and never read its `url`, so a
  // migration that sent the wrong URL (or a constant) would have passed all of them. Measured: the
  // first load reports the node server's root, and reloading after a `pushState` reports the
  // pushed URL, which is the page actually being loaded.
  skippableTestWidgets('onLoadStart reports the URL being loaded', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final StreamController<String> starts = StreamController<String>();
    final StreamController<void> stops = StreamController<void>.broadcast();
    final root = 'http://${environment["NODE_SERVER_IP"]}:8082/';

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: WebUri(root)),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStart: (controller, url) {
            starts.add(url.toString());
          },
          onLoadStop: (controller, url) {
            stops.add(null);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final startUrls = StreamIterator<String>(starts.stream);

    expect(await startUrls.moveNext(), isTrue);
    expect(startUrls.current, root);
    await stops.stream.first;

    await controller.evaluateJavascript(
      source: "history.pushState({}, '', '/pushed');",
    );
    final reloaded = stops.stream.first;
    await controller.reload();
    expect(await startUrls.moveNext(), isTrue);
    expect(startUrls.current, '${root}pushed');
    await reloaded;

    await startUrls.cancel();
    await starts.close();
    await stops.close();
  }, skip: shouldSkip);
}
