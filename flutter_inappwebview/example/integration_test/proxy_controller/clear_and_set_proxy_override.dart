part of 'main.dart';

void clearAndSetProxyOverride() {
  final shouldSkip = !ProxyController.isMethodSupported(
    PlatformProxyControllerMethod.setProxyOverride,
  );

  skippableTestWidgets('clear and set proxy override', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();

    var proxyAvailable =
        !PlatformWebViewFeature.static().isClassSupported() ||
        await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);

    if (proxyAvailable) {
      ProxyController proxyController = ProxyController.instance();

      await proxyController.clearProxyOverride();
      await proxyController.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083")],
        ),
      );
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_HTTP_EXAMPLE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    await tester.pump();

    final String url = await pageLoaded.future;
    expect(url, TEST_URL_HTTP_EXAMPLE.toString());

    // ── iOS routes cleartext HTTP through the proxy only from iOS 26 ──────────
    //
    // Measured on both simulators (§135), with the proxy set identically:
    //
    //   |            | http://www.example.com/    | https://www.example.com/  |
    //   | iOS 17.5   | real site — proxy bypassed | SECURE_CONNECTION_FAILED  |
    //   | iOS 26.5   | proxy page — proxy used    | SECURE_CONNECTION_FAILED  |
    //
    // The TLS failure is the control and it is what makes this a platform
    // finding rather than a plugin bug: the fixture's CONNECT handler tunnels
    // to a plain-HTTP port, so the handshake can only fail if the tunnel was
    // taken. It fails on BOTH — so the proxy is correctly configured and
    // demonstrably active on 17.5; iOS 17's WebKit simply does not send
    // cleartext HTTP through an `httpCONNECTProxy`. The plugin cannot do
    // better: Network.framework exposes only `httpCONNECTProxy` and
    // `socksv5Proxy`, with no plain-HTTP-proxy variant.
    //
    // Only 17.5 and 26.5 were measured; the exact version that starts routing
    // cleartext is somewhere in 18…26 and is untested, so the gate is set at
    // the lowest version known to work rather than the highest known to fail.
    final iosMajor = iosMajorVersion();
    final proxiesCleartextHttp = iosMajor == null || iosMajor >= 26;

    if (proxiesCleartextHttp) {
      // The proxy server's req.url returns different values by platform:
      // - Android: full URL (http://www.example.com/), the absolute-form request
      // - iOS: just the path (/), because the request arrives through CONNECT
      final proxyUrl = await controller.evaluateJavascript(
        source: "document.getElementById('url').innerHTML;",
      );
      expect(proxyUrl, anyOf("/", TEST_URL_HTTP_EXAMPLE.toString()));
      expect(
        await controller.evaluateJavascript(
          source: "document.getElementById('method').innerHTML;",
        ),
        "GET",
      );
      expect(
        await controller.evaluateJavascript(
          source: "document.getElementById('headers').innerHTML;",
        ),
        isNotNull,
      );
    } else {
      // Below the routing floor the correct expectation is the opposite one,
      // and asserting it keeps this branch a real test rather than a skip: the
      // page must be the origin server's, not the fixture's.
      expect(
        await controller.evaluateJavascript(
          source: "!!document.getElementById('url');",
        ),
        false,
        reason:
            'iOS $iosMajor is not expected to route cleartext HTTP through the '
            'proxy. If this now fails, that OS started routing it — move the '
            'floor down rather than deleting the branch.',
      );
    }
  }, skip: shouldSkip);
}
