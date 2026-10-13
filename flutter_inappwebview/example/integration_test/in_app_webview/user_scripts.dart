part of 'main.dart';

void userScripts() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.addUserScript,
  );

  skippableGroup('user scripts', () {
    skippableTestWidgets('initialUserScripts', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      // This test has timed out at the group's 60 s twice (§209) with an empty stack, so nothing
      // said which await hung. Each await now has its own bound and names itself when it fails.
      Future<T> step<T>(
        String name,
        Future<T> future, {
        Duration timeout = const Duration(seconds: 20),
      }) => future.timeout(
        timeout,
        onTimeout: () =>
            fail('"$name" did not finish within ${timeout.inSeconds} s'),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            initialUserScripts: UnmodifiableListView<UserScript>([
              UserScript(
                source: "var foo = 49;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
              UserScript(
                source: "var foo2 = 19;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                contentWorld: ContentWorld.PAGE,
              ),
              UserScript(
                source: "var bar = 2;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                contentWorld: ContentWorld.DEFAULT_CLIENT,
              ),
              UserScript(
                source: "var bar2 = 12;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                contentWorld: ContentWorld.world(name: "test"),
              ),
            ]),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              if (!pageLoaded.isCompleted) pageLoaded.complete();
            },
          ),
        ),
      );
      final InAppWebViewController controller = await step(
        'onWebViewCreated',
        controllerCompleter.future,
      );
      await step(
        'the first onLoadStop',
        pageLoaded.future,
        timeout: const Duration(seconds: 30),
      );

      expect(
        await step('foo', controller.evaluateJavascript(source: "foo;")),
        49,
      );
      expect(
        await step('foo2', controller.evaluateJavascript(source: "foo2;")),
        19,
      );
      expect(
        await step(
          'foo2 in PAGE',
          controller.evaluateJavascript(
            source: "foo2;",
            contentWorld: ContentWorld.PAGE,
          ),
        ),
        19,
      );
      expect(
        await step('bar', controller.evaluateJavascript(source: "bar;")),
        isNull,
      );
      expect(
        await step('bar2', controller.evaluateJavascript(source: "bar2;")),
        isNull,
      );
      expect(
        await step(
          'bar in DEFAULT_CLIENT',
          controller.evaluateJavascript(
            source: "bar;",
            contentWorld: ContentWorld.DEFAULT_CLIENT,
          ),
        ),
        2,
      );
      expect(
        await step(
          'bar2 in world "test"',
          controller.evaluateJavascript(
            source: "bar2;",
            contentWorld: ContentWorld.world(name: "test"),
          ),
        ),
        12,
      );
    });

    // On Android a content world is an `<iframe>` the plugin adds to each frame, and a world script
    // runs inside it, where `window !== window.top`. Until §262 the main-frame check ran in there
    // too, so a world script with the default `forMainFrameOnly: true` never ran at all. The check
    // belongs to the frame the world was made for. This page has a same-origin child frame: the
    // main-frame-only script must mark the main document and not the child's, and the
    // `forMainFrameOnly: false` one is the control that the child gets world scripts at all. Each
    // script marks `window.parent`'s document, which on Android is the frame that owns the world.
    skippableTestWidgets(
      'a main-frame-only content-world script runs in the main frame only',
      (WidgetTester tester) async {
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        String mark(String name) =>
            "window.parent.document.documentElement.setAttribute('data-$name', '1');";

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(
                data:
                    '<html><body>main<iframe id="child" src="/test-index">'
                    '</iframe></body></html>',
                baseUrl: WebUri(
                  'http://${environment["NODE_SERVER_IP"]}:8082/',
                ),
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: mark('main-only'),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  contentWorld: ContentWorld.world(name: "frames"),
                ),
                UserScript(
                  source: mark('all-frames'),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  contentWorld: ContentWorld.world(name: "frames"),
                  forMainFrameOnly: false,
                ),
              ]),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
            ),
          ),
        );
        final controller = await controllerCompleter.future;

        // Both documents' marks, read from the main page (the child is same-origin).
        Future<String?> marks() async =>
            '${await controller.evaluateJavascript(source: """
(function() {
  function read(root) {
    return root ? root.getAttribute('data-main-only') + '/' +
        root.getAttribute('data-all-frames') : 'none';
  }
  var child = document.getElementById('child');
  return 'main=' + read(document.documentElement) +
      ' child=' + read(child && child.contentDocument && child.contentDocument.documentElement);
})()""")}';

        // Wait for the control in both frames: then every script that was going to run has run.
        String? seen;
        for (var i = 0; i < 50; i++) {
          seen = await marks();
          if (RegExp(r'^main=\S+/1 child=\S+/1$').hasMatch(seen ?? '')) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        expect(
          seen,
          'main=1/1 child=null/1',
          reason:
              'main=<main-only>/<all-frames> child=<main-only>/<all-frames>: the main-frame-only '
              'world script must mark the main document only, and the control both',
        );
      },
      skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
    );

    skippableTestWidgets('add/remove user scripts', (
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
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;

      var userScript1 = UserScript(
        source: "window.foo = 49;",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );
      var userScript2 = UserScript(
        source: "window.bar = 19;",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
      );
      await controller.addUserScripts(userScripts: [userScript1, userScript2]);
      await controller.reload();
      await pageLoads.stream.first;
      var value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, 49);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeUserScript(userScript: userScript1);
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeAllUserScripts();
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, isNull);

      unawaited(pageLoads.close());
    });

    // Dart sends `removeUserScript` the script's index in its own list, and Kotlin removes the
    // script at that index in its own ordered set (§212). The test above removes the only
    // document-start script, which is index 0 whatever the index says, so it passed against a
    // Kotlin that always removed index 0. This one removes the middle of three, after an initial
    // script, so it also checks that the two lists agree on where the initial scripts sit.
    skippableTestWidgets('removeUserScript removes the script at its own index', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      // Replaced before each reload, so a load can't be missed the way a broadcast stream misses
      // one that fires before it's listened to.
      var nextLoad = Completer<void>();

      final scriptA = UserScript(
        source: "window.scriptA = 1;",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );
      final scriptB = UserScript(
        source: "window.scriptB = 2;",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );
      final scriptC = UserScript(
        source: "window.scriptC = 3;",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            initialUserScripts: UnmodifiableListView<UserScript>([scriptA]),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!nextLoad.isCompleted) nextLoad.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await nextLoad.future;

      Future<void> reload() async {
        nextLoad = Completer<void>();
        await controller.reload();
        await nextLoad.future.timeout(const Duration(seconds: 30));
      }

      await controller.addUserScripts(userScripts: [scriptB, scriptC]);
      await reload();
      expect(await controller.evaluateJavascript(source: "window.scriptA;"), 1);
      expect(await controller.evaluateJavascript(source: "window.scriptB;"), 2);
      expect(await controller.evaluateJavascript(source: "window.scriptC;"), 3);

      expect(await controller.removeUserScript(userScript: scriptB), isTrue);
      await reload();
      expect(
        await controller.evaluateJavascript(source: "window.scriptA;"),
        1,
        reason: 'the script before the removed one still runs',
      );
      expect(
        await controller.evaluateJavascript(source: "window.scriptB;"),
        isNull,
        reason: 'the removed script no longer runs',
      );
      expect(
        await controller.evaluateJavascript(source: "window.scriptC;"),
        3,
        reason: 'the script after the removed one still runs',
      );
    });

    // On Android a content world is an `<iframe>`, and the document-end check used to run inside
    // it, so a world script ran as soon as the world existed, while the page was still parsing
    // (§273: parent `readyState` 'loading', 24-271 ms in, ~3 s before a page-world one). Both
    // scripts write into the page's `<html>` element: on iOS a world shares the DOM but not
    // globals, and `window.parent` is the page from an Android world and `window` itself on iOS.
    skippableTestWidgets(
      'a document-end script in a content world runs when one in the page world does',
      (WidgetTester tester) async {
        final created = Completer<InAppWebViewController>();
        final loaded = Completer<void>();
        String record(String key) =>
            'var d = (window.parent || window).document;'
            'd.documentElement.dataset.$key = d.readyState;';
        final slowImage = defaultTargetPlatform == TargetPlatform.android;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(
                data:
                    '<html><body>document end'
                    '${slowImage ? '<img src="https://www.example.com/slow.png">' : ''}'
                    '</body></html>',
                baseUrl: WebUri('https://www.example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldInterceptRequest: slowImage,
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: record('page'),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                ),
                UserScript(
                  source: record('world'),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  contentWorld: ContentWorld.world(name: 'documentEnd'),
                ),
              ]),
              // Holds the page's `load` back 2 s, which is what let the world script run first.
              shouldInterceptRequest: slowImage
                  ? (controller, request) async {
                      if (!request.url.path.endsWith('slow.png')) return null;
                      await Future<void>.delayed(const Duration(seconds: 2));
                      return WebResourceResponse(
                        contentType: 'image/png',
                        data: Uint8List(0),
                      );
                    }
                  : null,
              onWebViewCreated: created.complete,
              onLoadStop: (controller, url) {
                if (!loaded.isCompleted) loaded.complete();
              },
            ),
          ),
        );
        final controller = await created.future;
        await loaded.future.timeout(const Duration(seconds: 30));

        Future<Object?> readBoth() => controller.evaluateJavascript(
          source:
              'JSON.stringify([document.documentElement.dataset.page || null, '
              'document.documentElement.dataset.world || null])',
        );
        var both = await readBoth();
        final elapsed = Stopwatch()..start();
        while ('$both'.contains('null') &&
            elapsed.elapsed < const Duration(seconds: 10)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          both = await readBoth();
        }
        final states = (jsonDecode('$both') as List).cast<String?>();
        expect(
          states[1],
          isNot('loading'),
          reason:
              'the world script ran while the page was still parsing ($states)',
        );
        expect(
          states[1],
          states[0],
          reason:
              'page-world and content-world document-end scripts saw the page in different '
              'states [page, world]: $states',
        );
      },
    );
  }, skip: shouldSkip);
}
