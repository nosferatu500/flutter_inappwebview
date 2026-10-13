part of 'main.dart';

void contentBlocker() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.contentBlockers,
  );

  skippableTestWidgets('Content Blocker', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await InAppWebViewController.clearAllCache();

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
            contentBlockers: [
              ContentBlocker(
                trigger: ContentBlockerTrigger(
                  urlFilter: ".*",
                  resourceType: [
                    ContentBlockerTriggerResourceType.IMAGE,
                    ContentBlockerTriggerResourceType.STYLE_SHEET,
                  ],
                  ifTopUrl: [TEST_CROSS_PLATFORM_URL_1.toString()],
                ),
                action: ContentBlockerAction(
                  type: ContentBlockerActionType.BLOCK,
                ),
              ),
            ],
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    await expectLater(pageLoaded.future, completes);
  }, skip: shouldSkip);

  // iOS: rules that WebKit can't compile (its rule regex has no `|`) stop the page from loading,
  // and say so through `onReceivedError`. Before §285 the WebView sent nothing after
  // `onWebViewCreated` and stayed blank (measured: 10 s). Android's regex accepts the same rule.
  skippableTestWidgets(
    'content blockers that fail to compile stop the initial load with an error',
    (WidgetTester tester) async {
      final url = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
      final events = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            initialSettings: InAppWebViewSettings(
              contentBlockers: [
                ContentBlocker(
                  trigger: ContentBlockerTrigger(urlFilter: '(alpha|beta)'),
                  action: ContentBlockerAction(
                    type: ContentBlockerActionType.BLOCK,
                  ),
                ),
              ],
            ),
            onLoadStop: (controller, u) => events.add('stop $u'),
            onReceivedError: (controller, request, error) =>
                events.add('error ${request.url} ${error.description}'),
          ),
        ),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!events.any((e) => e.startsWith('error ')) &&
          DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(
        events.where((e) => e.startsWith('error $url')),
        [contains('contentBlockers could not be compiled')],
        reason: 'one error for the initial URL naming the cause: $events',
      );
      // Then make sure the page doesn't load after all.
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(
        events.where((e) => e.startsWith('stop ')),
        isEmpty,
        reason: 'the page must not load without its rules: $events',
      );
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.iOS,
  );

  // iOS: `setSettings` with rules WebKit can't compile throws, and the previous rules stay (§301).
  // Before, it removed the old rules first and the compile error only printed: measured, the next
  // page loaded with nothing blocked and `getSettings` reported the rule that failed. CSS rules set
  // through `setSettings` apply from the next navigation, so each check reloads.
  skippableTestWidgets(
    'setSettings with content blockers that fail to compile throws and keeps the previous rules',
    (WidgetTester tester) async {
      final deadline = TestDeadline();
      final url = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
      var stops = 0;
      final controllerCompleter = Completer<InAppWebViewController>();
      ContentBlocker hide(String id) => ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: '.*'),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
          selector: '#$id',
        ),
      );
      await deadline.frame(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: url),
              initialSettings: InAppWebViewSettings(
                contentBlockers: [hide('a')],
              ),
              onWebViewCreated: (c) => controllerCompleter.complete(c),
              onLoadStop: (controller, u) => stops++,
            ),
          ),
        ),
      );
      final c = await deadline.step(
        'onWebViewCreated',
        controllerCompleter.future,
      );
      await deadline.until('the first onLoadStop', () => stops > 0);

      Future<void> reload(String why) async {
        final before = stops;
        await deadline.step(
          'loadUrl ($why)',
          c.loadUrl(urlRequest: URLRequest(url: url)),
        );
        await deadline.until('onLoadStop ($why)', () => stops > before);
      }

      Future<String> state() async {
        String display(Object? v) => '$v';
        final a = await deadline.step(
          'reading #a',
          c.evaluateJavascript(source: _displayOf('a')),
        );
        final b = await deadline.step(
          'reading #b',
          c.evaluateJavascript(source: _displayOf('b')),
        );
        final settings = await deadline.step('getSettings', c.getSettings());
        return 'a ${display(a)}, b ${display(b)}, getSettings '
            '${settings?.contentBlockers?.map((r) => r.action.selector ?? r.trigger.urlFilter).toList()}';
      }

      await deadline.step(
        'setSettings with #b',
        c.setSettings(
          settings: InAppWebViewSettings(contentBlockers: [hide('b')]),
        ),
      );
      await reload('after #b');
      expect(
        await state(),
        'a block, b none, getSettings [#b]',
        reason: 'the control: valid rules replace the old ones',
      );

      Object? thrown;
      try {
        await deadline.step(
          'setSettings with rules that fail to compile',
          c.setSettings(
            settings: InAppWebViewSettings(
              contentBlockers: [
                ContentBlocker(
                  trigger: ContentBlockerTrigger(urlFilter: '(alpha|beta)'),
                  action: ContentBlockerAction(
                    type: ContentBlockerActionType.BLOCK,
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        thrown = e;
      }
      expect(
        thrown,
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'contentBlockers')
            .having(
              (e) => e.message,
              'message',
              contains('could not be compiled, so the previous rules are kept'),
            ),
      );
      await reload('after the failed setSettings');
      expect(
        await state(),
        'a block, b none, getSettings [#b]',
        reason: 'the previous rules should still be in force, and reported',
      );
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.iOS,
  );
}

/// JavaScript that adds `<div id="[id]">` if the page has none and returns its computed `display`.
String _displayOf(String id) =>
    "if (!document.getElementById('$id')) "
    "document.body.insertAdjacentHTML('beforeend', '<div id=\"$id\">x</div>'); "
    "getComputedStyle(document.getElementById('$id')).display";
