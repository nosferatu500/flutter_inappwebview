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

    // iOS only: what a popup still takes from its opener, now that it has its own
    // `WKUserContentController` (§259). WebKit's controller has no getter for its rule lists, so the
    // opener's compiled content blockers are copied across at `createWebViewWith`; and the plugin
    // scripts follow the popup's own settings, `supportZoom: false` being the one checked here.
    skippableTestWidgets(
      'a popup WebView keeps its opener\'s content blockers and uses its own settings',
      (WidgetTester tester) async {
        final Completer<int> windowIdCompleter = Completer<int>();
        final Completer<InAppWebViewController> popupLoaded =
            Completer<InAppWebViewController>();

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
                  initialSettings: InAppWebViewSettings(
                    javaScriptCanOpenWindowsAutomatically: true,
                    supportMultipleWindows: true,
                    contentBlockers: [
                      ContentBlocker(
                        trigger: ContentBlockerTrigger(urlFilter: ".*"),
                        action: ContentBlockerAction(
                          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
                          selector: "#opener-blocked",
                        ),
                      ),
                    ],
                  ),
                  onCreateWindow: (controller, createNavigationAction) async {
                    if (!windowIdCompleter.isCompleted) {
                      windowIdCompleter.complete(
                        createNavigationAction.windowId,
                      );
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
                    initialSettings: InAppWebViewSettings(supportZoom: false),
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
          const Duration(seconds: 30),
        );
        await tester.pumpWidget(tree(windowId: windowId));
        await _pumpFrames(tester);
        final popup = await popupLoaded.future.timeout(
          const Duration(seconds: 30),
        );

        expect(
          await popup.evaluateJavascript(
            source:
                "document.body.insertAdjacentHTML('beforeend', "
                "'<div id=\"opener-blocked\">x</div>'); "
                "getComputedStyle(document.getElementById('opener-blocked')).display",
          ),
          'none',
          reason: "the opener's css-display-none content blocker should apply",
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
    skippableTestWidgets('can open new window and go back', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
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

      await tester.pump();

      final InAppWebViewController controller =
          await controllerCompleter.future;

      Future<String> waitForUrl(String expectedUrl) async {
        await for (final url in pageLoads.stream) {
          if (url == expectedUrl) {
            return url;
          }
        }
        throw Exception('Stream closed without receiving $expectedUrl');
      }

      // Wait for initial page load
      await waitForUrl(TEST_CROSS_PLATFORM_URL_1.toString());
      await controller.evaluateJavascript(
        source: 'window.open("$TEST_URL_1", "_blank");',
      );
      final currentUrl = await waitForUrl(TEST_URL_1.toString());
      expect(currentUrl, contains(TEST_URL_1.host));

      await controller.goBack();
      final urlAfterGoBack = await waitForUrl(
        TEST_CROSS_PLATFORM_URL_1.toString(),
      );
      expect(urlAfterGoBack, contains(TEST_CROSS_PLATFORM_URL_1.host));

      unawaited(pageLoads.close());
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
