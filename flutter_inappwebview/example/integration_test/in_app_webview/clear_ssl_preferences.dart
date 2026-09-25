part of 'main.dart';

void clearSslPreferences() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.clearSslPreferences,
  );

  // What `clearSslPreferences` clears is WebView's memory of "proceed anyway" answers to
  // certificate errors. The test node server's HTTPS port presents a certificate the emulator does
  // not trust, so every *new* connection to it asks `onReceivedServerTrustAuthRequest` unless a
  // PROCEED is remembered.
  //
  // 🚨 "New connection" is the catch. Loads on a kept-alive socket never re-check the certificate,
  // so clearing looked like it did nothing until the loads were spaced past the node server's
  // keep-alive timeout (Node's default, 5 s). Measured on API 37 with 7 s gaps: the load before
  // clearing does not ask, the one after asks again, and the next one is remembered again. But 7 s
  // failed 1 run in 5 (the load after clearing did not ask), probably because a request made after
  // `onLoadStop` (the favicon is the likely one, unconfirmed) keeps a socket alive past the gap. The
  // gap is 12 s; see §191 for the measured rate.
  //
  // Counts are relative: `ssl_request.dart` runs earlier in the group, against the same host, and
  // may already have left a PROCEED behind, so the first load may or may not ask.
  skippableTestWidgets('clearSslPreferences', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final url = WebUri("https://${environment["NODE_SERVER_IP"]}:4433/");
    var trustRequests = 0;
    var loadStops = 0;

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
            loadStops++;
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            trustRequests++;
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          // The server also asks for a client certificate; declining it still loads a page.
          onReceivedClientCertRequest: (controller, challenge) async {
            return ClientCertResponse(action: ClientCertResponseAction.CANCEL);
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

    Future<void> loadOnAFreshConnection() async {
      await Future.delayed(const Duration(seconds: 12));
      final previous = loadStops;
      await controller.loadUrl(urlRequest: URLRequest(url: url));
      await waitForLoadStop(previous);
    }

    await waitForLoadStop(0);
    final afterFirstLoad = trustRequests;

    // Control: without clearing, a new connection is answered from the remembered PROCEED. If
    // this ever starts asking, the increment below stops meaning anything.
    await loadOnAFreshConnection();
    expect(
      trustRequests,
      afterFirstLoad,
      reason: 'a remembered PROCEED must not ask again',
    );

    await controller.clearSslPreferences();
    await loadOnAFreshConnection();
    expect(
      trustRequests,
      afterFirstLoad + 1,
      reason: 'clearing must make the certificate error ask again',
    );
  }, skip: shouldSkip);
}
