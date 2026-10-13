part of 'main.dart';

void prerenderUrl() {
  // Android only: `PRERENDER_WITH_URL` is an androidx.webkit feature, and API 37 is the only
  // platform the values below were measured on.
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.prerenderUrl,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // `prerenderUrl` answers `true` as soon as it has issued the request, so the answer alone
  // cannot tell a prerender from a handler that replies `true` and does nothing. The page can,
  // though: a page shown from a prerender has a non-zero `activationStart` in its navigation
  // timing. Measured on API 37: ~3500 ms after prerendering, 0 for a plain load of the same page
  // (§193). The plain load is the control.
  skippableTestWidgets('prerenderUrl', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    var loadStops = 0;
    final target = WebUri(
      "http://${environment["NODE_SERVER_IP"]}:8082/test-index",
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>start</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            loadStops++;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    Future<void> waitForLoadStop(int previous) async {
      for (var i = 0; i < 150 && loadStops == previous; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      expect(loadStops, greaterThan(previous), reason: 'the page never loaded');
    }

    Future<num> activationStart() async =>
        await controller.evaluateJavascript(
              source:
                  "performance.getEntriesByType('navigation')[0].activationStart",
            )
            as num;

    await waitForLoadStop(0);

    expect(await controller.prerenderUrl(target), isTrue);
    // Give the prerender time to finish before navigating to it.
    await Future.delayed(const Duration(seconds: 3));

    var previous = loadStops;
    await controller.loadUrl(urlRequest: URLRequest(url: target));
    await waitForLoadStop(previous);
    expect(
      await activationStart(),
      greaterThan(0),
      reason: 'the page should have been shown from the prerender',
    );

    previous = loadStops;
    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri('$target?plain=1')),
    );
    await waitForLoadStop(previous);
    expect(
      await activationStart(),
      0,
      reason: 'control: a page that was not prerendered',
    );
  }, skip: shouldSkip);
}
