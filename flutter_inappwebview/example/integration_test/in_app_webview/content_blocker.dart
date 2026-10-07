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
}
