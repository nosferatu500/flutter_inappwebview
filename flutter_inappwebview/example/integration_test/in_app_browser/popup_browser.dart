part of 'main.dart';

/// Records the first real load (not the `about:blank` a popup starts on) and the exit.
class _PopupTestBrowser extends InAppBrowser {
  _PopupTestBrowser({super.windowId, super.initialUserScripts, this.onWindow});

  final Future<bool?> Function(CreateWindowAction action)? onWindow;
  final Completer<String?> loaded = Completer<String?>();
  final Completer<void> closed = Completer<void>();

  @override
  void onLoadStop(WebUri? url) {
    if (url?.scheme == 'about') return;
    if (!loaded.isCompleted) loaded.complete(url?.toString());
  }

  @override
  void onExit() {
    if (!closed.isCompleted) closed.complete();
  }

  @override
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) =>
      onWindow?.call(createWindowAction);
}

/// A popup browser (`windowId`) opened over its opener must leave the opener open.
///
/// On iOS the popup is presented full-screen over the opener, and the opener's `viewDidDisappear`
/// disposed it whenever it wasn't hidden: so once the popup finished appearing, the opener was
/// destroyed although nothing had closed it. Dismissing the popup then brought the dead opener
/// back, UIKit reloaded its view, and `loadView`/`viewDidLoad` recursed until the stack overflowed
/// (measured §266). The opener is checked alive after the popup has fully appeared and again
/// after the popup is closed.
void popupBrowser() {
  final shouldSkip =
      !InAppBrowser.isClassSupported() ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);

  skippableTest('a popup browser leaves its opener open', () async {
    _PopupTestBrowser? child;
    final childOpened = Completer<_PopupTestBrowser>();
    final parent = _PopupTestBrowser(
      onWindow: (action) async {
        final popup = _PopupTestBrowser(windowId: action.windowId);
        child = popup;
        await popup.openUrlRequest(
          urlRequest: URLRequest(url: WebUri('about:blank')),
        );
        childOpened.complete(popup);
        return true;
      },
    );
    await parent.openData(
      data:
          '<html><body>opener<script>setTimeout(function() {'
          ' window.open("https://www.example.com/"); }, 500);</script></body></html>',
      baseUrl: WebUri('https://www.example.com/'),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
          javaScriptCanOpenWindowsAutomatically: true,
          supportMultipleWindows: true,
        ),
      ),
    );

    Future<Object?> openerAnswers(String when) => parent.webViewController!
        .evaluateJavascript(source: '1 + 1')
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => fail('$when, the opener no longer answers'),
        );

    final popup = await childOpened.future.timeout(const Duration(seconds: 30));
    await popup.loaded.future.timeout(const Duration(seconds: 30));
    // Long enough for the popup's presentation to finish: that is when the opener disappears.
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(await openerAnswers('with the popup open'), 2);

    await popup.close();
    await popup.closed.future.timeout(const Duration(seconds: 10));
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(await openerAnswers('after the popup closed'), 2);

    await parent.close();
    await parent.closed.future.timeout(const Duration(seconds: 10));
    expect(child, same(popup));
  }, skip: shouldSkip);

  // A popup browser runs its own `initialUserScripts` and not its opener's, and keeps
  // `window.opener`. On iOS before §259 WebKit's `createWebViewWith` handed the popup its opener's
  // `WKUserContentController`, so it was the other way round: measured then with a probe
  // (`parentRuns: 1`, no `childRuns`), since closing a popup browser crashed until §266.
  skippableTest(
    'a popup browser runs its own user scripts, not its opener\'s',
    () async {
      UnmodifiableListView<UserScript> counter(String name) =>
          UnmodifiableListView([
            UserScript(
              source: 'window.$name = (window.$name || 0) + 1;',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]);
      const read =
          'JSON.stringify({parent: window.parentRuns || null, '
          'child: window.childRuns || null, hasOpener: window.opener != null})';
      final origin = 'http://${environment["NODE_SERVER_IP"]}:8082';

      final childOpened = Completer<_PopupTestBrowser>();
      final parent = _PopupTestBrowser(
        initialUserScripts: counter('parentRuns'),
        onWindow: (action) async {
          final popup = _PopupTestBrowser(
            windowId: action.windowId,
            initialUserScripts: counter('childRuns'),
          );
          await popup.openUrlRequest(
            urlRequest: URLRequest(url: WebUri('about:blank')),
          );
          childOpened.complete(popup);
          return true;
        },
      );
      await parent.openData(
        data:
            '<html><body>opener<script>setTimeout(function() {'
            ' window.open("$origin/test-redirect-target"); }, 500);</script></body></html>',
        baseUrl: WebUri('$origin/'),
        settings: InAppBrowserClassSettings(
          webViewSettings: InAppWebViewSettings(
            javaScriptCanOpenWindowsAutomatically: true,
            supportMultipleWindows: true,
          ),
        ),
      );

      final popup = await childOpened.future.timeout(
        const Duration(seconds: 30),
      );
      final popupUrl = await popup.loaded.future.timeout(
        const Duration(seconds: 30),
      );
      expect(popupUrl, '$origin/test-redirect-target');

      expect(
        await popup.webViewController!.evaluateJavascript(source: read),
        '{"parent":null,"child":1,"hasOpener":true}',
        reason: 'in the popup',
      );
      expect(
        await parent.webViewController!.evaluateJavascript(source: read),
        '{"parent":1,"child":null,"hasOpener":false}',
        reason: 'in the opener',
      );

      await popup.close();
      await popup.closed.future.timeout(const Duration(seconds: 10));
      await parent.close();
      await parent.closed.future.timeout(const Duration(seconds: 10));
    },
    skip: shouldSkip,
  );
}
