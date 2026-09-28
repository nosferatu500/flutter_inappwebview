part of 'main.dart';

/// Serves a fixed [WebResourceResponse] per file name, and records every path it is asked for.
class _RecordingPathHandler extends CustomPathHandler {
  _RecordingPathHandler(this.responses) : super(path: '/custom/');

  final Map<String, WebResourceResponse?> responses;
  final List<String> paths = [];

  @override
  Future<WebResourceResponse?> handle(String path) async {
    paths.add(path);
    return responses[path];
  }
}

/// The custom path handler's channel, asserted before it is migrated (§204). It is the one
/// `WebViewAssetLoader` handler that crosses a channel: Kotlin's `PathHandlerExt.handle` blocks a
/// WebView thread on a round trip to [CustomPathHandler.handle] and turns the answer into a
/// `WebResourceResponse`. Every field that answer carries is asserted on a value only it produces.
/// Values measured on API 37.
///
/// `WebResourceResponse.cookies` is not covered: the Kotlin handler never reads it.
void customPathHandler() {
  final shouldSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.webViewAssetLoader,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  final origin = 'https://$TEST_WEBVIEW_ASSET_LOADER_DOMAIN';

  Uint8List bytes(String s) => Uint8List.fromList(utf8.encode(s));

  /// Loads [path] under the handler's prefix and returns the controller once it has loaded.
  Future<InAppWebViewController> load(
    WidgetTester tester,
    _RecordingPathHandler handler,
    String path,
  ) async {
    final created = Completer<InAppWebViewController>();
    final loaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: WebUri('$origin/custom/$path')),
          initialSettings: InAppWebViewSettings(
            webViewAssetLoader: WebViewAssetLoader(
              domain: TEST_WEBVIEW_ASSET_LOADER_DOMAIN,
              pathHandlers: [handler],
            ),
          ),
          onWebViewCreated: created.complete,
          onLoadStop: (controller, url) {
            if (!loaded.isCompleted) loaded.complete();
          },
        ),
      ),
    );
    final controller = await created.future;
    await loaded.future.timeout(const Duration(seconds: 30));
    return controller;
  }

  final page = WebResourceResponse(
    contentType: 'text/html',
    data: bytes('<html><body>custom page</body></html>'),
  );

  skippableTestWidgets(
    'CustomPathHandler serves the page for the path under its prefix',
    (WidgetTester tester) async {
      final handler = _RecordingPathHandler({'page.html': page});
      final c = await load(tester, handler, 'page.html?q=1');

      // The loader strips its own prefix and the query before calling the handler.
      expect(handler.paths.first, 'page.html');
      expect(
        await c.evaluateJavascript(source: 'document.body.innerText'),
        'custom page',
      );
      expect(
        await c.evaluateJavascript(source: 'document.contentType'),
        'text/html',
      );
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'CustomPathHandler status, reason, headers and type reach the page',
    (WidgetTester tester) async {
      final handler = _RecordingPathHandler({
        'page.html': page,
        'status.txt': WebResourceResponse(
          contentType: 'text/plain',
          statusCode: 404,
          reasonPhrase: 'Not Here',
          headers: {'X-Probe': 'probe-value'},
          data: bytes('status body'),
        ),
        // Kotlin uses the status and reason only when BOTH are given.
        'status-only.txt': WebResourceResponse(
          contentType: 'text/plain',
          statusCode: 404,
          data: bytes('status only'),
        ),
      });
      final c = await load(tester, handler, 'page.html');

      Future<Object?> fetch(String path) async => (await c.callAsyncJavaScript(
        functionBody:
            '''
        const r = await fetch('/custom/$path');
        return [r.status, r.statusText, r.headers.get('X-Probe'),
                r.headers.get('content-type'), await r.text()];
      ''',
      ))?.value;

      expect(await fetch('status.txt'), [
        404,
        'Not Here',
        'probe-value',
        'text/plain',
        'status body',
      ]);
      expect(await fetch('status-only.txt'), [
        200,
        'OK',
        null,
        'text/plain',
        'status only',
      ]);
    },
    skip: shouldSkip,
  );

  skippableTestWidgets('CustomPathHandler contentEncoding decodes the data', (
    WidgetTester tester,
  ) async {
    // The bytes are "é" in UTF-8 (C3 A9), declared as ISO-8859-1. Honouring the declaration gives
    // two characters, "Ã©". Without one, Chrome detects the encoding itself and finds UTF-8: one
    // character.
    //
    // 🚨 The declaration must contradict what Chrome would detect, or the field has no visible
    // effect. §204 measured two versions that a mutant dropping the encoding passed: a Latin-1
    // byte declared ISO-8859-1 (detected as windows-1252 anyway) and UTF-8 bytes declared UTF-8.
    final handler = _RecordingPathHandler({
      'declared.html': WebResourceResponse(
        contentType: 'text/html',
        contentEncoding: 'ISO-8859-1',
        data: bytes('<html><body>é</body></html>'),
      ),
    });
    final c = await load(tester, handler, 'declared.html');
    expect(
      await c.evaluateJavascript(
        source:
            '[document.body.innerText.length, document.body.innerText.charCodeAt(0),'
            ' document.body.innerText.charCodeAt(1)]',
      ),
      [2, 0xC3, 0xA9],
    );
    expect(
      await c.evaluateJavascript(source: 'document.characterSet'),
      'windows-1252',
    );
  }, skip: shouldSkip);

  skippableTestWidgets(
    'CustomPathHandler returning null falls through to the network',
    (WidgetTester tester) async {
      // The test domain does not resolve, so a request the handler declines fails to fetch; one
      // it serves does not. The served page is the control.
      final handler = _RecordingPathHandler({'page.html': page});
      final c = await load(tester, handler, 'page.html');
      final result = await c.callAsyncJavaScript(
        functionBody: '''
        try { await fetch('/custom/declined.txt'); return 'resolved'; }
        catch (e) { return 'rejected'; }
      ''',
      );
      expect(result?.value, 'rejected');
      expect(handler.paths, contains('declined.txt'));
    },
    skip: shouldSkip,
  );
}
