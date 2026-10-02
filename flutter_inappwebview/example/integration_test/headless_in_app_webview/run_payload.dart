part of 'main.dart';

/// Runs one headless webview, waits for its first load, and hands back its controller.
Future<(HeadlessInAppWebView, InAppWebViewController)> _runLoaded(
  HeadlessInAppWebView Function(
    void Function(InAppWebViewController) onCreated,
    void Function() onLoaded,
  )
  build,
) async {
  final created = Completer<InAppWebViewController>();
  final loaded = Completer<void>();
  final headless = build(created.complete, () {
    if (!loaded.isCompleted) loaded.complete();
  });
  await headless.run();
  final controller = await created.future;
  await loaded.future.timeout(const Duration(seconds: 30));
  return (headless, controller);
}

/// What `HeadlessInAppWebViewManager.run` receives, asserted before that channel is migrated
/// (§202), the same net §196 and §200 put under the other two managers. `run`'s `params` map goes
/// straight into `FlutterWebView`, the class that also builds every `InAppWebView` widget. Each
/// assertion is on a value only the right field produces. `initialUrlRequest`, `initialSize` and a
/// bool setting were already asserted by the other tests in this group.
///
/// Not covered, and why:
///   * `contextMenu`: a native menu, which a test gesture cannot open on a view that has no screen.
///   * `pullToRefreshSettings`: a headless webview has no pull-to-refresh gesture to trigger.
void runPayload() {
  final shouldSkip =
      !HeadlessInAppWebView.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  skippableTest('run carries initialData, and its base and history URLs', () async {
    // baseUrl and historyUrl differ, and each is reported on a different channel: the document
    // location is the base, the WebView's url is the history entry. A swap of the two fails.
    final (html, c) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(
          data: '<html><body>hello data</body></html>',
          mimeType: 'text/html',
          baseUrl: WebUri('https://example.com/base/'),
          historyUrl: WebUri('https://example.com/history/'),
        ),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
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
    await html.dispose();

    // The same markup as text/plain is shown as text, not rendered.
    final (plain, p) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(
          data: '<b>plain</b>',
          mimeType: 'text/plain',
        ),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect(
      await p.evaluateJavascript(source: 'document.contentType'),
      'text/plain',
    );
    expect(
      await p.evaluateJavascript(source: 'document.body.innerText'),
      '<b>plain</b>',
    );
    await plain.dispose();
  }, skip: shouldSkip);

  skippableTest('run carries initialFile', () async {
    final (headless, c) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialFile: 'test_assets/in_app_webview_initial_file_test.html',
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect(
      (await c.getUrl()).toString(),
      endsWith('/test_assets/in_app_webview_initial_file_test.html'),
    );
    await headless.dispose();
  }, skip: shouldSkip);

  skippableTest('an int in initialSettings arrives intact', () async {
    // 🚨 The one to watch. Settings cross as an untyped map (§194), and `InAppWebViewSettings.parse`
    // casts `value as Int`; an int that arrived as a Long would throw there (§197). 23 is not a
    // default.
    final (headless, c) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: '<html></html>'),
        initialSettings: InAppWebViewSettings(minimumFontSize: 23),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect((await c.getSettings())?.minimumFontSize, 23);
    await headless.dispose();
  }, skip: shouldSkip);

  skippableTest('an onShowFileChooser handler turns on useOnShowFileChooser', () async {
    // The handler used to be dropped converting the facade's params to Android's, so the setting
    // was never inferred and the platform opened its own picker without asking. The chooser itself
    // can't be opened here: it needs a user gesture, and a headless webview gets none (measured on
    // API 37, a scripted `click()` fires nothing). `getSettings` answers the plugin's native copy,
    // which is the one the chooser checks. Without a handler it is the platform default, false.
    final (withHandler, c) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: '<html></html>'),
        onShowFileChooser: (_, _) async =>
            ShowFileChooserResponse(handledByClient: true, filePaths: []),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect((await c.getSettings())?.useOnShowFileChooser, isTrue);
    await withHandler.dispose();

    final (withoutHandler, d) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: '<html></html>'),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect((await d.getSettings())?.useOnShowFileChooser, isFalse);
    await withoutHandler.dispose();
  }, skip: shouldSkip);

  skippableTest('initialUserScripts run in the headless webview', () async {
    // A user script's `injectionTime` crosses as an int, read `as Int` by `UserScript.fromMap`.
    final (headless, c) = await _runLoaded(
      (onCreated, onLoaded) => HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: '<html></html>'),
        initialUserScripts: UnmodifiableListView([
          UserScript(
            source: 'window.payloadScript = 41 + 1;',
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
        ]),
        onWebViewCreated: onCreated,
        onLoadStop: (_, _) => onLoaded(),
      ),
    );
    expect(await c.evaluateJavascript(source: 'window.payloadScript'), 42);
    await headless.dispose();
  }, skip: shouldSkip);

  skippableTest(
    'windowId attaches the headless webview to the window a page asked for',
    () async {
      // `windowId` is read `as Int?` by FlutterWebView. The child is given no URL of its own; it
      // can only show the popup if its windowId reached the platform and attached it to the window
      // the parent's page opened.
      HeadlessInAppWebView? child;
      final childLoaded = Completer<String>();
      final (parent, _) = await _runLoaded(
        (onCreated, onLoaded) => HeadlessInAppWebView(
          initialData: InAppWebViewInitialData(
            data:
                '<html><body>parent<script>setTimeout(function() {'
                ' window.open("https://example.com/popup"); }, 500);</script></body></html>',
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptCanOpenWindowsAutomatically: true,
            supportMultipleWindows: true,
          ),
          onCreateWindow: (controller, action) async {
            child = HeadlessInAppWebView(
              windowId: action.windowId,
              onLoadStop: (_, url) {
                if (!childLoaded.isCompleted) childLoaded.complete('$url');
              },
            );
            await child!.run();
            return true;
          },
          onWebViewCreated: onCreated,
          onLoadStop: (_, _) => onLoaded(),
        ),
      );
      expect(
        await childLoaded.future.timeout(const Duration(seconds: 30)),
        'https://example.com/popup',
      );
      await child?.dispose();
      await parent.dispose();
    },
    skip: shouldSkip,
  );
}
