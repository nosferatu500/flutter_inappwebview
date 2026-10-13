part of 'main.dart';

void clearSslPreferences() {
  // The test forces its fresh connections with `clearClientCertPreferences`, so it needs both.
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.clearSslPreferences,
      ) ||
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.clearClientCertPreferences,
      );

  // What `clearSslPreferences` clears is WebView's memory of "proceed anyway" answers to
  // certificate errors. The test node server's HTTPS port presents a certificate the emulator does
  // not trust, so every *new* connection to it asks `onReceivedServerTrustAuthRequest` unless a
  // PROCEED is remembered.
  //
  // 🚨 "New connection" is the catch. A load on a pooled socket never re-checks the certificate,
  // so it can't tell a cleared preference from a remembered one. This test used to wait 12 s
  // between loads for the node server's 5 s keep-alive to close the socket, and flaked in the
  // group (§204, §207). Measured on API 37 (§208): each load opens two connections, and the second
  // one lingers 16–25 s after the load, so a 12 s gap sometimes reused it.
  //
  // So each load now starts with `clearClientCertPreferences`, which closes WebView's pooled
  // connections (measured: every socket to the server is replaced within a second). It also forgets
  // the CANCEL answered below, so a new TLS handshake asks for a client certificate again. That ask
  // is asserted, which proves each load really made a fresh connection. Without it, the control
  // below would pass on a reused socket without testing anything.
  //
  // Counts are relative: `ssl_request.dart` runs earlier in the group, against the same host, and
  // may already have left a PROCEED behind, so the first load may or may not ask.
  skippableTestWidgets('clearSslPreferences', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final url = WebUri("https://${environment["NODE_SERVER_IP"]}:4433/");
    var trustRequests = 0;
    var clientCertRequests = 0;
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
            clientCertRequests++;
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
      await InAppWebViewController.clearClientCertPreferences();
      final previousClientCertRequests = clientCertRequests;
      final previous = loadStops;
      await controller.loadUrl(urlRequest: URLRequest(url: url));
      await waitForLoadStop(previous);
      expect(
        clientCertRequests,
        greaterThan(previousClientCertRequests),
        reason: 'the load must have made a new TLS handshake',
      );
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
