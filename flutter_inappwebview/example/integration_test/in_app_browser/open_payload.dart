part of 'main.dart';

/// Records what the payload tests need: the first load, the exit, and a hook for `onCreateWindow`.
class _PayloadBrowser extends InAppBrowser {
  _PayloadBrowser({super.windowId, super.initialUserScripts, this.onWindow});

  final Future<bool?> Function(CreateWindowAction action)? onWindow;
  final Completer<String?> loaded = Completer<String?>();
  final Completer<void> closed = Completer<void>();

  @override
  void onLoadStop(WebUri? url) {
    if (!loaded.isCompleted) loaded.complete(url?.toString());
  }

  @override
  void onExit() {
    if (!closed.isCompleted) closed.complete();
  }

  @override
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) =>
      onWindow?.call(createWindowAction);

  Future<void> closeAndWait() async {
    if (!isOpened()) return;
    await close();
    await closed.future.timeout(const Duration(seconds: 10));
  }
}

/// Every field `InAppBrowserManager.open` packs into the browser Activity's Bundle, asserted one by
/// one before that channel is migrated (§196). The migration replaces the key-by-key map reads with
/// a data class, so a transposition between two same-typed fields becomes possible. Each assertion
/// below is on a value only the right field produces. Values measured on API 37.
///
/// Not covered, and why:
///   * `encoding`: `document.characterSet` stayed `UTF-8` when `ISO-8859-1` was sent, so the field
///     has no effect a page can observe.
///   * `contextMenu`: the browser is a native Activity above Flutter, which a test gesture cannot
///     reach.
void openPayload() {
  final shouldSkip =
      !InAppBrowser.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  skippableTest(
    'openData carries data, mimeType, baseUrl and historyUrl',
    () async {
      // baseUrl and historyUrl differ, and the page reports each on a different channel: the document
      // location is the base, the WebView's url is the history entry. A swap of the two fails.
      final html = _PayloadBrowser();
      await html.openData(
        data: '<html><body>hello data</body></html>',
        mimeType: 'text/html',
        baseUrl: WebUri('https://example.com/base/'),
        historyUrl: WebUri('https://example.com/history/'),
      );
      expect(await html.loaded.future, 'https://example.com/base/');
      final c = html.webViewController!;
      expect(
        await c.evaluateJavascript(source: 'location.href'),
        'https://example.com/base/',
      );
      expect((await c.getUrl()).toString(), 'https://example.com/history/');
      expect(
        await c.evaluateJavascript(source: 'document.body.innerText'),
        'hello data',
      );
      expect(
        await c.evaluateJavascript(source: 'document.contentType'),
        'text/html',
      );
      await html.closeAndWait();

      // The same markup as text/plain is shown as text, not rendered.
      final plain = _PayloadBrowser();
      await plain.openData(data: '<b>plain</b>', mimeType: 'text/plain');
      await plain.loaded.future;
      final p = plain.webViewController!;
      expect(
        await p.evaluateJavascript(source: 'document.contentType'),
        'text/plain',
      );
      expect(
        await p.evaluateJavascript(source: 'document.body.innerText'),
        '<b>plain</b>',
      );
      await plain.closeAndWait();
    },
    skip: shouldSkip,
  );

  skippableTest('openUrlRequest carries the request headers', () async {
    final browser = _PayloadBrowser();
    await browser.openUrlRequest(
      urlRequest: URLRequest(
        url: WebUri(
          'http://${environment["NODE_SERVER_IP"]}:8082/echo-headers',
        ),
        headers: {'X-Payload-Header': 'payload-value'},
      ),
    );
    await browser.loaded.future;
    final echoed = await browser.webViewController!.evaluateJavascript(
      source: 'document.body.innerText',
    );
    expect(echoed.toString(), contains('"x-payload-header":"payload-value"'));
    await browser.closeAndWait();
  }, skip: shouldSkip);

  skippableTest('initialUserScripts run in the browser', () async {
    final browser = _PayloadBrowser(
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: 'window.payloadScript = 41 + 1;',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
    );
    await browser.openData(data: '<html><body>scripts</body></html>');
    await browser.loaded.future;
    expect(
      await browser.webViewController!.evaluateJavascript(
        source: 'window.payloadScript',
      ),
      42,
    );
    await browser.closeAndWait();
  }, skip: shouldSkip);

  skippableTest(
    'initial settings arrive with their ints and colors intact',
    () async {
      // 🚨 The int is the one to watch. Settings cross as an untyped map (§194), and the Kotlin
      // parser casts `value as Int`; if an int ever arrived as a Long it would throw there.
      final browser = _PayloadBrowser();
      await browser.openData(
        data: '<html><body>settings</body></html>',
        settings: InAppBrowserClassSettings(
          webViewSettings: InAppWebViewSettings(minimumFontSize: 22),
          browserSettings: InAppBrowserSettings(
            toolbarTopBackgroundColor: const Color(0xFF0A8F3C),
          ),
        ),
      );
      await browser.loaded.future;
      final settings = await browser.getSettings();
      expect(settings?.webViewSettings.minimumFontSize, 22);
      expect(
        settings?.browserSettings.toolbarTopBackgroundColor,
        const Color(0xFF0A8F3C),
      );
      await browser.closeAndWait();
    },
    skip: shouldSkip,
  );

  skippableTest(
    'windowId opens the browser on the window a page asked for',
    () async {
      _PayloadBrowser? child;
      final childLoaded = Completer<String?>();
      final parent = _PayloadBrowser(
        onWindow: (action) async {
          child = _PayloadBrowser(windowId: action.windowId);
          await child!.openUrlRequest(
            urlRequest: URLRequest(url: WebUri('about:blank')),
          );
          unawaited(child!.loaded.future.then(childLoaded.complete));
          return true;
        },
      );
      await parent.openData(
        data:
            '<html><body>parent<script>setTimeout(function() {'
            ' window.open("https://example.com/popup"); }, 500);</script></body></html>',
        settings: InAppBrowserClassSettings(
          webViewSettings: InAppWebViewSettings(
            javaScriptCanOpenWindowsAutomatically: true,
            supportMultipleWindows: true,
          ),
        ),
      );

      // The child was opened on about:blank; it only shows the popup if its windowId reached the
      // Activity and attached it to the window the parent created.
      expect(
        await childLoaded.future.timeout(const Duration(seconds: 30)),
        'https://example.com/popup',
      );
      await child?.closeAndWait();
      await parent.closeAndWait();
    },
    skip: shouldSkip,
  );

  skippableTest('openWithSystemBrowser reports a URL no app can open', () async {
    // The success path starts another app over the test, so only the error path is tested here.
    // It is also the part a migration changes: the error used to be `result.error`.
    await expectLater(
      InAppBrowser.openWithSystemBrowser(
        url: WebUri('nonexistent-payload-scheme://x'),
      ),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'InAppBrowserManager')
            .having(
              (e) => e.message,
              'message',
              'nonexistent-payload-scheme://x cannot be opened!',
            ),
      ),
    );
  }, skip: shouldSkip);
}
