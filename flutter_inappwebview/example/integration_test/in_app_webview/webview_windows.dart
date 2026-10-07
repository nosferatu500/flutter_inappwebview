part of 'main.dart';

void webViewWindows() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onCreateWindow,
  );

  skippableGroup('WebView Windows', () {
    final shouldSkipTest1 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onCreateWindow,
        );

    skippableTestWidgets('onCreateWindow return false', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_create_window_test.html",
            initialSettings: InAppWebViewSettings(
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (url!.toString() == TEST_URL_EXAMPLE.toString()) {
                pageLoaded.complete();
              }
            },
            onCreateWindow: (controller, createNavigationAction) async {
              unawaited(
                controller.loadUrl(urlRequest: createNavigationAction.request),
              );
              return false;
            },
          ),
        ),
      );
      await tester.pump();
      await expectLater(pageLoaded.future, completes);
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.windowId,
        );

    skippableTestWidgets('onCreateWindow return true', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<int> onCreateWindowCompleter = Completer<int>();
      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_create_window_test.html",
            initialSettings: InAppWebViewSettings(
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onCreateWindow: (controller, createNavigationAction) async {
              onCreateWindowCompleter.complete(createNavigationAction.windowId);
              return true;
            },
          ),
        ),
      );

      await tester.pump();

      var windowId = await onCreateWindowCompleter.future;

      final Completer windowControllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<String> windowPageLoaded = Completer<String>();
      final Completer<void> onCloseWindowCompleter = Completer<void>();

      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            windowId: windowId,
            onWebViewCreated: (controller) {
              windowControllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              if (url!.scheme != "about" && !windowPageLoaded.isCompleted) {
                windowPageLoaded.complete(url.toString());
                await controller.evaluateJavascript(source: "window.close();");
              }
            },
            onCloseWindow: (controller) {
              onCloseWindowCompleter.complete();
            },
          ),
        ),
      );

      await tester.pump();

      final String windowUrlLoaded = await windowPageLoaded.future;

      expect(windowUrlLoaded, TEST_URL_EXAMPLE.toString());
      await expectLater(onCloseWindowCompleter.future, completes);
    }, skip: shouldSkipTest2);

    // A popup WebView runs its own scripts, not its opener's.
    // Android: a WebView created for a `windowId` doesn't get the scripts `addDocumentStartJavaScript`
    // added at creation (upstream #1455), so they are registered at the popup's first
    // `onPageStarted` and evaluated into that first document as well, guarded so each runs once
    // (§258). The popup opens a local asset, which loads fast enough that without the fallback its
    // first document always lost the race (measured §258).
    // iOS: WebKit hands `createWebViewWith` the opener's `WKUserContentController`, so the popup
    // ran the opener's scripts and never its own; it gets a controller of its own now (§259). Its
    // first navigation waits for the widget, so there is no race and it opens example.com.
    // Checked on the first document and after a reload. The parent stays on screen.
    skippableTestWidgets('a popup WebView runs its own initialUserScripts', (
      WidgetTester tester,
    ) async {
      final Completer<int> windowIdCompleter = Completer<int>();
      final Completer<InAppWebViewController> popupLoaded =
          Completer<InAppWebViewController>();
      Completer<void>? popupReloaded;
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;

      Widget tree({int? windowId}) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                key: const ValueKey('parent'),
                initialData: InAppWebViewInitialData(
                  data:
                      '<html><body>parent<script>window.open('
                      '"${isAndroid ? 'page-1.html' : TEST_URL_EXAMPLE}");'
                      '</script></body></html>',
                  baseUrl: isAndroid
                      ? WebUri(
                          'file:///android_asset/flutter_assets/test_assets/',
                        )
                      : TEST_URL_EXAMPLE,
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportMultipleWindows: true,
                  allowFileAccess: true,
                ),
                initialUserScripts: UnmodifiableListView<UserScript>([
                  UserScript(
                    source: "window.openerRuns = (window.openerRuns || 0) + 1;",
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  ),
                ]),
                onCreateWindow: (controller, createNavigationAction) async {
                  if (!windowIdCompleter.isCompleted) {
                    windowIdCompleter.complete(createNavigationAction.windowId);
                  }
                  return true;
                },
              ),
            ),
            if (windowId != null)
              Expanded(
                child: InAppWebView(
                  key: const ValueKey('popup'),
                  windowId: windowId,
                  initialUserScripts: UnmodifiableListView<UserScript>([
                    UserScript(
                      source: "window.popupRuns = (window.popupRuns || 0) + 1;",
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                    ),
                    UserScript(
                      source:
                          "window.popupEndRuns = (window.popupEndRuns || 0) + 1;",
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                      contentWorld: ContentWorld.world(name: "popupWorld"),
                    ),
                  ]),
                  onLoadStop: (controller, url) {
                    if (url?.scheme == "about") return;
                    if (!popupLoaded.isCompleted) {
                      popupLoaded.complete(controller);
                    } else if (popupReloaded?.isCompleted == false) {
                      popupReloaded!.complete();
                    }
                  },
                ),
              ),
          ],
        ),
      );

      await tester.pumpWidget(tree());
      final windowId = await windowIdCompleter.future.timeout(
        const Duration(seconds: 30),
      );
      await tester.pumpWidget(tree(windowId: windowId));
      await _pumpFrames(tester);
      final popup = await popupLoaded.future.timeout(
        const Duration(seconds: 30),
      );

      Future<void> expectScriptsRanOnce(String document) async {
        expect(
          await popup.evaluateJavascript(source: "window.popupRuns"),
          1,
          reason:
              '$document: the document-start script should run exactly once',
        );
        expect(
          await popup.evaluateJavascript(source: "window.openerRuns"),
          isNull,
          reason: "$document: the opener's user script should not run here",
        );
        // The content world is an <iframe> created once the body exists, so poll briefly. An
        // evaluation into a world that was never created doesn't answer, hence the timeout.
        Object? endRuns;
        for (var i = 0; i < 25 && endRuns == null; i++) {
          endRuns = await popup
              .evaluateJavascript(
                source: "window.popupEndRuns",
                contentWorld: ContentWorld.world(name: "popupWorld"),
              )
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () => fail(
                  '$document: an evaluation in "popupWorld" never answered, '
                  'so the content world was not created',
                ),
              );
          if (endRuns == null) {
            await Future<void>.delayed(const Duration(milliseconds: 200));
          }
        }
        expect(
          endRuns,
          1,
          reason:
              '$document: the document-end script in "popupWorld" should '
              'run exactly once',
        );
      }

      await expectScriptsRanOnce('first document');
      final reloaded = popupReloaded = Completer<void>();
      await popup.reload();
      await reloaded.future.timeout(const Duration(seconds: 30));
      await expectScriptsRanOnce('after a reload');
    }, skip: shouldSkipTest2);

    // A popup is mounted as `InAppWebView(windowId:)` once its opener's `onCreateWindow` has
    // answered true. Returns both controllers after the popup's first load.
    Future<({InAppWebViewController opener, InAppWebViewController popup})>
    openPopup(
      WidgetTester tester, {
      InAppWebViewSettings? openerSettings,
      InAppWebViewSettings? popupSettings,
    }) async {
      final Completer<int> windowIdCompleter = Completer<int>();
      final Completer<InAppWebViewController> popupLoaded =
          Completer<InAppWebViewController>();
      final Completer<InAppWebViewController> openerCreated =
          Completer<InAppWebViewController>();
      openerSettings ??= InAppWebViewSettings();
      openerSettings.javaScriptCanOpenWindowsAutomatically = true;
      openerSettings.supportMultipleWindows = true;

      Widget tree({int? windowId}) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                key: const ValueKey('parent'),
                initialData: InAppWebViewInitialData(
                  data:
                      '<html><body>parent<script>window.open('
                      '"$TEST_URL_EXAMPLE");</script></body></html>',
                  baseUrl: TEST_URL_EXAMPLE,
                ),
                initialSettings: openerSettings,
                onWebViewCreated: (controller) {
                  if (!openerCreated.isCompleted) {
                    openerCreated.complete(controller);
                  }
                },
                onCreateWindow: (controller, createNavigationAction) async {
                  if (!windowIdCompleter.isCompleted) {
                    windowIdCompleter.complete(createNavigationAction.windowId);
                  }
                  return true;
                },
              ),
            ),
            if (windowId != null)
              Expanded(
                child: InAppWebView(
                  key: const ValueKey('popup'),
                  windowId: windowId,
                  initialSettings: popupSettings,
                  onLoadStop: (controller, url) {
                    if (url?.scheme == "about") return;
                    if (!popupLoaded.isCompleted) {
                      popupLoaded.complete(controller);
                    }
                  },
                ),
              ),
          ],
        ),
      );

      await tester.pumpWidget(tree());
      final windowId = await windowIdCompleter.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => fail("the opener's onCreateWindow never came (20 s)"),
      );
      await tester.pumpWidget(tree(windowId: windowId));
      await _pumpFrames(tester);
      final popup = await popupLoaded.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            fail('the popup (windowId $windowId) never loaded (20 s)'),
      );
      return (opener: await openerCreated.future, popup: popup);
    }

    ContentBlocker hide(String selector) => ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".*"),
      action: ContentBlockerAction(
        type: ContentBlockerActionType.CSS_DISPLAY_NONE,
        selector: selector,
      ),
    );

    Future<Object?> displayOf(InAppWebViewController webView, String id) =>
        webView.evaluateJavascript(
          source:
              "document.body.insertAdjacentHTML('beforeend', "
              "'<div id=\"$id\">x</div>'); "
              "getComputedStyle(document.getElementById('$id')).display",
        );

    // A popup applies its own `contentBlockers`, not its opener's, on both platforms. iOS used to
    // do the opposite: WebKit's controller has no getter for its rule lists, so `createWebViewWith`
    // copied the opener's compiled list into the popup, and the popup's own were never compiled
    // (measured §274, Android already as here). The popup's first navigation now waits for its
    // own list (2-20 ms measured). Every WebView compiles its list under one identifier, and the
    // opener keeps its own rule after the popup's is compiled.
    skippableTestWidgets(
      'a popup WebView applies its own content blockers, not its opener\'s',
      (WidgetTester tester) async {
        final (:opener, :popup) = await openPopup(
          tester,
          openerSettings: InAppWebViewSettings(
            contentBlockers: [hide('#opener-blocked')],
          ),
          popupSettings: InAppWebViewSettings(
            contentBlockers: [hide('#popup-blocked')],
          ),
        );
        expect(
          await displayOf(popup, 'unblocked'),
          'block',
          reason: 'the control: an element no rule names is shown',
        );
        expect(
          await displayOf(popup, 'popup-blocked'),
          'none',
          reason:
              "the popup's own css-display-none content blocker should apply",
        );
        expect(
          await displayOf(popup, 'opener-blocked'),
          'block',
          reason: "the opener's content blocker should not apply in the popup",
        );
        expect(
          await displayOf(opener, 'opener-blocked'),
          'none',
          reason: "the opener's own content blocker should still apply to it",
        );
        expect(
          await displayOf(opener, 'popup-blocked'),
          'block',
          reason: "the popup's content blocker should not apply to the opener",
        );
      },
      skip: shouldSkipTest2,
    );

    // The case the copy in `createWebViewWith` used to cover: a popup with no content blockers of
    // its own got its opener's on iOS. Now it gets none, as on Android (§274).
    skippableTestWidgets(
      'a popup WebView without content blockers doesn\'t take its opener\'s',
      (WidgetTester tester) async {
        final (:opener, :popup) = await openPopup(
          tester,
          openerSettings: InAppWebViewSettings(
            contentBlockers: [hide('#opener-blocked')],
          ),
        );
        expect(
          await displayOf(opener, 'opener-blocked'),
          'none',
          reason: "the control: the opener's content blocker applies to it",
        );
        expect(
          await displayOf(popup, 'opener-blocked'),
          'block',
          reason: "the opener's content blocker should not apply in the popup",
        );
      },
      skip: shouldSkipTest2,
    );

    // The popup's events for its first page, `:8082/test-redirect-target`, over 5 s, when the
    // popup's only content blocker is [blocker]: `start`, `stop` and `error <url> <type>
    // <description>`.
    Future<List<String>> popupFirstPageEvents(
      WidgetTester tester,
      ContentBlocker blocker,
    ) async {
      final origin = 'http://${environment["NODE_SERVER_IP"]}:8082';
      final target = '$origin/test-redirect-target';
      final windowIdCompleter = Completer<int>();
      final events = <String>[];

      Widget tree({int? windowId}) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                key: const ValueKey('parent'),
                initialData: InAppWebViewInitialData(
                  data:
                      '<html><body>parent<script>window.open("$target");'
                      '</script></body></html>',
                  baseUrl: WebUri('$origin/'),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportMultipleWindows: true,
                ),
                onCreateWindow: (controller, createNavigationAction) async {
                  if (!windowIdCompleter.isCompleted) {
                    windowIdCompleter.complete(createNavigationAction.windowId);
                  }
                  return true;
                },
              ),
            ),
            if (windowId != null)
              Expanded(
                child: InAppWebView(
                  key: const ValueKey('popup'),
                  windowId: windowId,
                  initialSettings: InAppWebViewSettings(
                    contentBlockers: [blocker],
                  ),
                  onLoadStart: (controller, url) => events.add('start $url'),
                  onLoadStop: (controller, url) => events.add('stop $url'),
                  onReceivedError: (controller, request, error) => events.add(
                    'error ${request.url} ${error.type} ${error.description}',
                  ),
                ),
              ),
          ],
        ),
      );

      await tester.pumpWidget(tree());
      final windowId = await windowIdCompleter.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => fail("the opener's onCreateWindow never came (20 s)"),
      );
      await tester.pumpWidget(tree(windowId: windowId));
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return events;
    }

    // A popup's own content blockers apply to its first page too: on iOS that page's navigation
    // waits until the popup's rule list is compiled and added (§274). A `BLOCK` rule on the popup's
    // own document tells whether it waited; a `CSS_DISPLAY_NONE` rule can't, since one added a few
    // ms late still hides. Measured (§284): released before the list was in, the page loaded
    // (`start`, `stop`); with the wait, `start` then an error. Android: the error alone.
    skippableTestWidgets(
      "a popup WebView's content blockers apply to its first page",
      (WidgetTester tester) async {
        final events = await popupFirstPageEvents(
          tester,
          ContentBlocker(
            trigger: ContentBlockerTrigger(
              urlFilter: '.*test-redirect-target.*',
            ),
            action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
          ),
        );
        expect(
          events.where(
            (e) => e.startsWith('stop ') && e.contains('test-redirect-target'),
          ),
          isEmpty,
          reason:
              "the popup's own BLOCK rule should stop its first page: $events",
        );
        // And it did stop it, rather than the page never being asked for: blocked, the load
        // ends in an error on both platforms (measured: type UNKNOWN on each).
        expect(
          events.where(
            (e) => e.startsWith('error ') && e.contains('test-redirect-target'),
          ),
          isNotEmpty,
          reason: "the popup's first page should end in an error: $events",
        );
      },
      skip: shouldSkipTest2,
    );

    // iOS: a popup whose rules WebKit can't compile (no `|` in its rule regex) doesn't load its
    // first page, and says why. Before §285 it loaded without them (§274 released it anyway).
    skippableTestWidgets(
      'a popup WebView whose content blockers fail to compile loads nothing',
      (WidgetTester tester) async {
        final events = await popupFirstPageEvents(
          tester,
          ContentBlocker(
            trigger: ContentBlockerTrigger(urlFilter: '(alpha|beta)'),
            action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
          ),
        );
        expect(
          events.where((e) => e.startsWith('stop ')),
          isEmpty,
          reason: 'the popup must not load without its rules: $events',
        );
        expect(
          events.where((e) => e.startsWith('error ')),
          [
            allOf(
              contains('test-redirect-target'),
              contains('contentBlockers could not be compiled'),
            ),
          ],
          reason: 'one error for the first page naming the cause: $events',
        );
      },
      skip: shouldSkipTest2 || defaultTargetPlatform != TargetPlatform.iOS,
    );

    // iOS only: the popup's plugin scripts follow its own settings now that it has its own
    // `WKUserContentController` (§259); `supportZoom: false` adds a viewport meta on iOS only.
    skippableTestWidgets(
      'a popup WebView uses its own settings',
      (WidgetTester tester) async {
        final (opener: _, :popup) = await openPopup(
          tester,
          popupSettings: InAppWebViewSettings(supportZoom: false),
        );
        expect(
          await popup.evaluateJavascript(
            source:
                "Array.from(document.querySelectorAll('meta[name=viewport]'))"
                ".some(function(m) { return m.content.indexOf('user-scalable=no') >= 0; })",
          ),
          true,
          reason:
              "the popup's own supportZoom: false should add its viewport meta",
        );
      },
      skip: shouldSkipTest2 || defaultTargetPlatform != TargetPlatform.iOS,
    );

    final shouldSkipTest3 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onCreateWindow,
        );

    skippableTestWidgets(
      'window.open() with target _blank opens in same window',
      (WidgetTester tester) async {
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final StreamController<String> pageLoads =
            StreamController<String>.broadcast();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );
        await pageLoads.stream.first;
        final InAppWebViewController controller =
            await controllerCompleter.future;

        await controller.evaluateJavascript(
          source: 'window.open("$TEST_URL_ABOUT_BLANK", "_blank");',
        );
        await pageLoads.stream.first;
        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, TEST_URL_ABOUT_BLANK.toString());

        unawaited(pageLoads.close());
      },
      skip: shouldSkipTest3,
    );

    // on Android, for some reason, it works on an example app but not in this test
    final shouldSkipTest4 =
        kIsWeb || defaultTargetPlatform == TargetPlatform.android;
    // Two plain fixture pages, not live sites. With https://flutter.dev/ and
    // https://github.com/flutter the back navigation committed and was then cancelled (-999, no
    // `onLoadStop`) in 5 of 6 iOS runs, a few ms after the commit: the sites' own scripts, since
    // the same steps between these two pages finished in 5 of 5 (#4).
    skippableTestWidgets('can open new window and go back', (
      WidgetTester tester,
    ) async {
      final page1 = 'http://${environment["NODE_SERVER_IP"]}:8082/';
      final page2 =
          'http://${environment["NODE_SERVER_IP"]}:8082/test-redirect-target';
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      // Every `onLoadStop`, kept from the start, so a load that finishes before a wait begins
      // still counts, and a missing one fails with what did arrive.
      final loadStops = <String>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(page1)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onLoadStop: (controller, url) {
              loadStops.add(url.toString());
            },
          ),
        ),
      );

      await tester.pump();

      final InAppWebViewController controller =
          await controllerCompleter.future;

      Future<void> waitForLoadStop(String url, {required int count}) async {
        final elapsed = Stopwatch()..start();
        while (loadStops.where((u) => u == url).length < count) {
          if (elapsed.elapsed > const Duration(seconds: 20)) {
            fail(
              'onLoadStop #$count for $url did not come in 20 s; '
              'onLoadStop so far: $loadStops',
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }

      await waitForLoadStop(page1, count: 1);
      // No `onCreateWindow`: the window's URL opens in this WebView.
      await controller.evaluateJavascript(
        source: 'window.open("$page2", "_blank");',
      );
      await waitForLoadStop(page2, count: 1);
      expect((await controller.getUrl()).toString(), page2);

      await controller.goBack();
      await waitForLoadStop(page1, count: 2);
      expect((await controller.getUrl()).toString(), page1);
    }, skip: shouldSkipTest4);

    // Android blocks javascript: URLs opened from iframes for security reasons
    final shouldSkipTest5 = defaultTargetPlatform != TargetPlatform.android;
    skippableTestWidgets('javascript does not run in parent window', (
      WidgetTester tester,
    ) async {
      const String iframe = '''
        <!DOCTYPE html>
        <script>
          window.onload = () => {
            window.open(`javascript:
              var elem = document.createElement("p");
              elem.innerHTML = "<b>Executed JS in parent origin: " + window.location.origin + "</b>";
              document.body.append(elem);
            `);
          };
        </script>
      ''';
      final String iframeTestBase64 = base64Encode(
        const Utf8Encoder().convert(iframe),
      );

      final String openWindowTest =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>XSS test</title>
        </head>
        <body>
          <iframe
            onload="window.iframeLoaded = true;"
            src="data:text/html;charset=utf-8;base64,$iframeTestBase64"></iframe>
        </body>
        </html>
      ''';
      final String openWindowTestBase64 = base64Encode(
        const Utf8Encoder().convert(openWindowTest),
      );
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoadCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$openWindowTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onLoadStop: (controller, url) {
              pageLoadCompleter.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoadCompleter.future;

      final iframeLoaded = await controller.evaluateJavascript(
        source: 'iframeLoaded',
      );
      expect(iframeLoaded, true);

      final pElement = await controller.evaluateJavascript(
        source:
            'document.querySelector("p") && document.querySelector("p").textContent',
      );
      expect(pElement, null);
    }, skip: shouldSkipTest5);

    // final shouldSkipTest6 = !kIsWeb;
    const shouldSkipTest6 = true;
    // on Web, opening a new window during tests makes crash
    skippableTestWidgets('onCreateWindow called on Web', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<String> onCreateWindowCalled = Completer<String>();
      await InAppWebViewController.clearAllCache();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_WEB_PLATFORM_URL_1),
            initialSettings: InAppWebViewSettings(
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onCreateWindow: (controller, createNavigationAction) async {
              onCreateWindowCalled.complete(
                createNavigationAction.request.url.toString(),
              );
              return false;
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: "window.open('$TEST_CROSS_PLATFORM_URL_1');",
      );

      var url = await onCreateWindowCalled.future;
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());
    }, skip: shouldSkipTest6);
  }, skip: shouldSkip);
}
