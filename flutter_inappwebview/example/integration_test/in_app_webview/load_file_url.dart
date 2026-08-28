part of 'main.dart';

void loadFileUrl() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.allowingReadAccessTo,
  );

  skippableGroup('load file URL', () {
    late Directory appSupportDir;
    late File fileHtml;
    late File fileJs;

    setUpAll(() async {
      appSupportDir = (await getApplicationSupportDirectory());

      final Directory htmlFolder = Directory('${appSupportDir.path}/html/');
      if (!await htmlFolder.exists()) {
        await htmlFolder.create(recursive: true);
      }

      final Directory jsFolder = Directory('${appSupportDir.path}/js/');
      if (!await jsFolder.exists()) {
        await jsFolder.create(recursive: true);
      }

      var html = """
      <!DOCTYPE html><html>
      <head>
        <title>file scheme</title>
      </head>
      <body>
        <script src="../js/main.js"></script>
      </body>
      </html>
    """;
      fileHtml = File(htmlFolder.path + "index.html");
      fileHtml.writeAsStringSync(html);

      var js = """
      console.log('message');
      """;
      fileJs = File(jsFolder.path + "main.js");
      fileJs.writeAsStringSync(js);
    });

    // Both tests in this group used to assert a *negative* first: that without
    // `allowingReadAccessTo`, the page's sibling `../js/main.js` must NOT load. That assertion was
    // wrong, and it is the reason these two were the longest-standing red tests in the suite.
    //
    // Measured on iOS 17.5 and 26.5, with the native side instrumented at
    // `InAppWebView.loadUrl` (§81): the plugin passes exactly the right value to
    // `WKWebView.loadFileURL(_:allowingReadAccessTo:)` — right scheme, and the URL resolves to a
    // real directory — and the sibling script loads *anyway*, in every configuration:
    //
    //   no scope                  -> load(urlRequest)  -> main.js runs
    //   scope = Application Support/ -> loadFileURL    -> main.js runs
    //   scope = .../html/ ONLY       -> loadFileURL    -> main.js runs   <-- outside the scope
    //
    // So WebKit does not enforce the read-access scope for this subresource, and the value not
    // reaching `loadFileURL` — the other explanation §69 left open — is ruled out. There is no
    // plugin defect here and nothing to fix in Swift.
    //
    // What these tests can honestly assert is that a `file://` document loads and its relative
    // subresource executes, through both entry points. `allowingReadAccessTo` is exercised because
    // it changes which WebKit API the plugin calls, not because it changes the outcome — see the
    // warning on `InAppWebViewSettings.allowingReadAccessTo`, which now says so.

    skippableTestWidgets(
      'initialUrl with file:// scheme and allowingReadAccessTo',
      (WidgetTester tester) async {
        for (final scope in <WebUri?>[
          null,
          WebUri('file://${appSupportDir.path}/'),
        ]) {
          final completer = Completer<ConsoleMessage>();
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView(
                key: GlobalKey(),
                initialUrlRequest: URLRequest(
                  url: WebUri('file://${fileHtml.path}'),
                ),
                initialSettings: InAppWebViewSettings(
                  allowingReadAccessTo: scope,
                ),
                onConsoleMessage: (controller, consoleMessage) {
                  if (!completer.isCompleted) {
                    completer.complete(consoleMessage);
                  }
                },
              ),
            ),
          );

          final consoleMessage = await completer.future;
          expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
          expect(consoleMessage.message, 'message');
        }
      },
    );

    skippableTestWidgets(
      'loadUrl with file:// scheme and allowingReadAccessTo argument',
      (WidgetTester tester) async {
        for (final scope in <WebUri?>[
          null,
          WebUri('file://${appSupportDir.path}/'),
        ]) {
          final completer = Completer<ConsoleMessage>();
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView(
                key: GlobalKey(),
                onWebViewCreated: (controller) {
                  controller.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri('file://${fileHtml.path}'),
                    ),
                    allowingReadAccessTo: scope,
                  );
                },
                onConsoleMessage: (controller, consoleMessage) {
                  if (!completer.isCompleted) {
                    completer.complete(consoleMessage);
                  }
                },
              ),
            ),
          );

          final consoleMessage = await completer.future;
          expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
          expect(consoleMessage.message, 'message');
        }
      },
    );
  }, skip: shouldSkip);
}
