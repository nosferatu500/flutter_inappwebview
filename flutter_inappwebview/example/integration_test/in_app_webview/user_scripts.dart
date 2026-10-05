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
                forMainFrameOnly:
                    defaultTargetPlatform != TargetPlatform.android,
                contentWorld: ContentWorld.DEFAULT_CLIENT,
              ),
              UserScript(
                source: "var bar2 = 12;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                forMainFrameOnly:
                    defaultTargetPlatform != TargetPlatform.android,
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
  }, skip: shouldSkip);
}
