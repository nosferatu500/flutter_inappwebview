part of 'main.dart';

void onReceivedLoginRequest() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onReceivedLoginRequest,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // WebView reports an auto-login request when a response carries an `X-Auto-Login` header. No
  // test server sends one, so the test intercepts the request and answers with a response that
  // does. Measured on API 37: an intercepted response's header is enough, and the three fields
  // arrive decoded (`%40` → `@`) (§192).
  skippableTestWidgets('onReceivedLoginRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<LoginRequest> loginRequest = Completer<LoginRequest>();
    final loginUrl = WebUri('https://example.com/login');

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
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          shouldInterceptRequest: (controller, request) async {
            if (request.url.toString() != loginUrl.toString()) return null;
            return WebResourceResponse(
              contentType: 'text/html',
              contentEncoding: 'utf-8',
              data: Uint8List.fromList(
                utf8.encode('<html><body>login</body></html>'),
              ),
              statusCode: 200,
              reasonPhrase: 'OK',
              headers: {
                'X-Auto-Login':
                    'realm=com.google&account=probe%40example.com&args=abc',
              },
            );
          },
          onReceivedLoginRequest: (controller, request) {
            if (!loginRequest.isCompleted) loginRequest.complete(request);
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.loadUrl(urlRequest: URLRequest(url: loginUrl));

    final request = await loginRequest.future.timeout(
      const Duration(seconds: 15),
    );
    // Three different values, so a transposition between any two fields fails.
    expect(request.realm, 'com.google');
    expect(request.account, 'probe@example.com');
    expect(request.args, 'abc');
  }, skip: shouldSkip);
}
