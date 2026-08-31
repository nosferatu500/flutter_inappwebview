part of 'main.dart';

void shouldInterceptRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldInterceptRequest,
  );

  skippableTestWidgets('shouldInterceptRequest', (WidgetTester tester) async {
    List<String> resourceList = [
      "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
      "https://code.jquery.com/jquery-3.3.1.min.js",
      "https://via.placeholder.com/100x50",
    ];
    List<String> resourceLoaded = [];

    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> loadedResourceCompleter = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    </head>
    <body>
      <img src="https://via.placeholder.com/100x50" alt="placeholder 100x50">
    </body>
</html>
                    """,
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          shouldInterceptRequest: (controller, request) async {
            resourceLoaded.add(request.url.toString());
            if (resourceLoaded.length == resourceList.length) {
              loadedResourceCompleter.complete();
            }
            return null;
          },
        ),
      ),
    );

    await pageLoaded.future;
    await loadedResourceCompleter.future;
    expect(resourceLoaded, containsAll(resourceList));
  }, skip: shouldSkip);

  // `syncCallbackTimeoutMillis` (TODO.md P0b.5) can only be observed on a device: it bounds a
  // native latch, and from Dart a timed-out handler looks exactly like one whose response was used.
  // The discriminator is whether the *substituted* script ran. Both tests below use the same
  // handler with the same delay and differ only in the setting, so the setting is the only thing
  // that can explain the difference.
  //
  // The script URL is https://localhost/... deliberately: nothing listens there on an emulator, so
  // "the plugin loaded it normally" always fails fast and leaves the flag unset. No fixture and no
  // internet involved.
  const injectedScriptUrl = 'https://localhost/sync-callback-timeout.js';
  const pageWithInjectedScript =
      """
<!doctype html>
<html lang="en">
    <head><meta charset="UTF-8"><script src="$injectedScriptUrl"></script></head>
    <body>sync callback timeout</body>
</html>
""";

  Future<String?> runWithTimeout(
    WidgetTester tester, {
    required int? syncCallbackTimeoutMillis,
    required Duration handlerDelay,
  }) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: pageWithInjectedScript,
            baseUrl: WebUri('https://localhost/'),
          ),
          initialSettings: InAppWebViewSettings(
            useShouldInterceptRequest: true,
            syncCallbackTimeoutMillis: syncCallbackTimeoutMillis,
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          shouldInterceptRequest: (controller, request) async {
            if (request.url.toString() != injectedScriptUrl) {
              return null;
            }
            await Future.delayed(handlerDelay);
            return WebResourceResponse(
              contentType: 'application/javascript',
              data: Uint8List.fromList(
                utf8.encode("window.__injected = 'yes';"),
              ),
            );
          },
        ),
      ),
    );

    final controller = await controllerCompleter.future;
    await pageLoaded.future;
    return await controller.evaluateJavascript(source: 'window.__injected');
  }

  skippableTestWidgets(
    'a slow shouldInterceptRequest handler is abandoned at syncCallbackTimeoutMillis',
    (WidgetTester tester) async {
      final injected = await runWithTimeout(
        tester,
        syncCallbackTimeoutMillis: 1000,
        handlerDelay: const Duration(milliseconds: 3000),
      );

      // The handler answered at 3s, the WebView stopped waiting at 1s and loaded the URL itself.
      // With the built-in 10s default this same handler succeeds — see the next test.
      expect(injected, isNull);
    },
    skip:
        shouldSkip ||
        !InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.syncCallbackTimeoutMillis,
        ),
  );

  skippableTestWidgets(
    'raising syncCallbackTimeoutMillis lets a slow handler answer',
    (WidgetTester tester) async {
      final injected = await runWithTimeout(
        tester,
        syncCallbackTimeoutMillis: 8000,
        handlerDelay: const Duration(milliseconds: 3000),
      );

      expect(injected, 'yes');
    },
    skip:
        shouldSkip ||
        !InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.syncCallbackTimeoutMillis,
        ),
  );
}
