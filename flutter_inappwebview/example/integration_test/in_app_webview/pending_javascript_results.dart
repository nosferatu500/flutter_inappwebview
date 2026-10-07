part of 'main.dart';

/// Android answers `callAsyncJavaScript` and a content-world `evaluateJavascript` through the
/// page itself: the page posts the result back over the bridge. So whenever the page can't, the
/// call used to wait forever. Measured §263, all with no answer in 5–8 s: a content world on a page
/// whose Content-Security-Policy blocks inline scripts, or on a document with no `body` (the
/// world's `<iframe>` never gets its scripts), and a pending call when the page navigates away or
/// the WebView is disposed. Each now answers at once: `callAsyncJavaScript` with an error that
/// says why, a world `evaluateJavascript` with `null`.
///
/// Android only, except the three pending-call cases, which iOS shares (§267, §268, §270). iOS
/// worlds are native and answered on both kinds of page.
void pendingJavaScriptResults() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;
  // The pending-call cases hold on iOS too. Navigation: WebKit's completion for a call whose page
  // went away came only lazily (§267: not in 15 s, then 11 ms after the next call, as "Completion
  // handler for function call is no longer reachable"). Dispose: an iOS widget's WebView used to be
  // disposed only when the engine released its platform view, and a view that was never composited
  // wasn't released until a later frame composited another one (§268). The widget now disposes it
  // itself (§270); the two dispose tests cover a composited view and one that never was.
  final shouldSkipPendingCall = ![
    TargetPlatform.android,
    TargetPlatform.iOS,
  ].contains(defaultTargetPlatform);

  Future<InAppWebViewController> loadPage(
    WidgetTester tester,
    InAppWebViewInitialData data,
  ) async {
    final created = Completer<InAppWebViewController>();
    final loaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: data,
          onWebViewCreated: (c) => created.complete(c),
          onLoadStop: (c, url) {
            if (!loaded.isCompleted) loaded.complete();
          },
        ),
      ),
    );
    final controller = await created.future;
    await loaded.future.timeout(const Duration(seconds: 20));
    return controller;
  }

  Future<T> answered<T>(Future<T> call, String what) => call.timeout(
    const Duration(seconds: 5),
    onTimeout: () => fail('$what never answered (5 s)'),
  );

  Future<void> expectWorldUnavailable(
    InAppWebViewController controller,
    String reason,
  ) async {
    // The control: the page's own bridge works here, so only the world is missing.
    expect(
      (await answered(
        controller.callAsyncJavaScript(functionBody: 'return 1 + 1;'),
        'page-world callAsyncJavaScript',
      ))?.value,
      2,
    );
    expect(
      await answered(
        controller.evaluateJavascript(
          source: '1 + 1',
          contentWorld: ContentWorld.world(name: 'unavailable'),
        ),
        'content-world evaluateJavascript',
      ),
      isNull,
      reason: 'a world that cannot be made answers null, as a world error does',
    );
    final result = await answered(
      controller.callAsyncJavaScript(
        functionBody: 'return 1 + 1;',
        contentWorld: ContentWorld.world(name: 'unavailable2'),
      ),
      'content-world callAsyncJavaScript',
    );
    expect(result?.value, isNull);
    expect(
      result?.error,
      allOf(
        contains('The content world "unavailable2" could not be created'),
        contains(reason),
      ),
    );
  }

  skippableTestWidgets(
    'a content-world evaluation answers on a page whose CSP blocks inline scripts',
    (WidgetTester tester) async {
      final controller = await loadPage(
        tester,
        InAppWebViewInitialData(
          data:
              '<html><head><meta http-equiv="Content-Security-Policy" '
              'content="script-src \'self\'"></head><body>csp</body></html>',
          baseUrl: WebUri('https://www.example.com/'),
        ),
      );
      await expectWorldUnavailable(
        controller,
        'its Content-Security-Policy blocks inline scripts',
      );
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'a content-world evaluation answers on a document with no body',
    (WidgetTester tester) async {
      final controller = await loadPage(
        tester,
        InAppWebViewInitialData(
          data:
              '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">'
              '<rect width="10" height="10"/></svg>',
          mimeType: 'image/svg+xml',
          baseUrl: WebUri('https://www.example.com/'),
        ),
      );
      await expectWorldUnavailable(controller, 'the document has no body');
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'a pending callAsyncJavaScript answers when the page navigates away',
    (WidgetTester tester) async {
      final controller = await loadPage(
        tester,
        InAppWebViewInitialData(
          data: '<html><body>first</body></html>',
          baseUrl: WebUri('https://www.example.com/'),
        ),
      );
      final pending = controller.callAsyncJavaScript(
        functionBody:
            'await new Promise(function(r) { setTimeout(r, 10000); }); return 7;',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await controller.loadData(data: '<html><body>second</body></html>');
      final result = await answered(pending, 'the pending call');
      expect(result?.value, isNull);
      expect(result?.error, contains('navigated away'));
    },
    skip: shouldSkipPendingCall,
  );

  skippableTestWidgets(
    'a pending callAsyncJavaScript answers when the WebView is disposed',
    (WidgetTester tester) async {
      final controller = await loadPage(
        tester,
        InAppWebViewInitialData(
          data: '<html><body>page</body></html>',
          baseUrl: WebUri('https://www.example.com/'),
        ),
      );
      // With no pointer activity the binding draws only the frames a test pumps, and `loadPage`
      // pumps none after the platform view exists. This frame composites the iOS view, so this is
      // the ordinary case; the next test leaves it out (§268, §270).
      await tester.pump();
      final pending = controller.callAsyncJavaScript(
        functionBody:
            'await new Promise(function(r) { setTimeout(r, 10000); }); return 7;',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      final result = await answered(pending, 'the pending call');
      expect(result?.value, isNull);
      expect(result?.error, contains('disposed'));
    },
    skip: shouldSkipPendingCall,
  );

  skippableTestWidgets(
    'a pending callAsyncJavaScript answers when a WebView that was never composited is disposed',
    (WidgetTester tester) async {
      // No frame after `loadPage`: the iOS view isn't composited (see above), as in an app that
      // removes a WebView within a frame of adding it. Before §270 the call wasn't answered in
      // 5 s here, because the WebView waited for the engine's release (§268).
      final controller = await loadPage(
        tester,
        InAppWebViewInitialData(
          data: '<html><body>page</body></html>',
          baseUrl: WebUri('https://www.example.com/'),
        ),
      );
      final pending = controller.callAsyncJavaScript(
        functionBody:
            'await new Promise(function(r) { setTimeout(r, 10000); }); return 7;',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      final result = await answered(pending, 'the pending call');
      expect(result?.value, isNull);
      expect(result?.error, contains('disposed'));
    },
    skip: shouldSkipPendingCall,
  );
}
