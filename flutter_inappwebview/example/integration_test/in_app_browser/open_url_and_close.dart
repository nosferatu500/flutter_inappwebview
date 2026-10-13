part of 'main.dart';

void openUrlAndClose() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('open url and close', () async {
    var inAppBrowser = MyInAppBrowser();
    expect(inAppBrowser.isOpened(), false);
    expect(() async {
      await inAppBrowser.show();
    }, throwsAssertionError);

    await inAppBrowser.openUrlRequest(urlRequest: URLRequest(url: TEST_URL_1));
    await inAppBrowser.browserCreated.future;
    expect(inAppBrowser.isOpened(), true);
    expect(() async {
      await inAppBrowser.openUrlRequest(
        urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      );
    }, throwsAssertionError);

    await inAppBrowser.firstPageLoaded.future;
    var controller = inAppBrowser.webViewController;

    expect(controller, isNotNull);
    final String? url = (await controller!.getUrl())?.toString();
    expect(url, TEST_URL_1.toString());

    await inAppBrowser.close();
    // `onExit` and `close`'s reply travel on two different Pigeon channels since §195; on the old
    // shared MethodChannel their order was implied. Kotlin sends `onExit` first, so by the time
    // `close()` completes the browser must already report itself closed. Checked before awaiting
    // `browserClosed`, which would hide a reordering.
    expect(
      inAppBrowser.isOpened(),
      false,
      reason: 'onExit must be delivered before close() completes',
    );
    await inAppBrowser.browserClosed.future;
    expect(inAppBrowser.isOpened(), false);
    expect(inAppBrowser.webViewController, isNull);
  }, skip: shouldSkip);

  // iOS: rules that WebKit can't compile (its rule regex has no `|`) stop the page from loading,
  // and say so through `onReceivedError`, after `onBrowserCreated`. Before §285 the browser sent
  // nothing at all, not even `onBrowserCreated` (measured: 10 s). Android accepts the rule.
  skippableTest(
    'content blockers that fail to compile stop the browser loading with an error',
    () async {
      final url = WebUri('http://${environment["NODE_SERVER_IP"]}:8082/');
      final browser = _EventsBrowser();
      await browser.openUrlRequest(
        urlRequest: URLRequest(url: url),
        settings: InAppBrowserClassSettings(
          webViewSettings: InAppWebViewSettings(
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
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!browser.events.any((e) => e.startsWith('error ')) &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await Future<void>.delayed(const Duration(seconds: 1));
      final events = browser.events;
      expect(events.first, 'created', reason: '$events');
      expect(
        events.where((e) => e.startsWith('error $url')),
        [contains('contentBlockers could not be compiled')],
        reason: 'one error for the initial URL naming the cause: $events',
      );
      expect(
        events.where((e) => e.startsWith('stop ')),
        isEmpty,
        reason: 'the page must not load without its rules: $events',
      );
      await browser.close();
      await browser.closed.future.timeout(const Duration(seconds: 10));
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.iOS,
  );
}

class _EventsBrowser extends InAppBrowser {
  final events = <String>[];
  final closed = Completer<void>();

  @override
  void onBrowserCreated() => events.add('created');

  @override
  void onLoadStop(WebUri? url) => events.add('stop $url');

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) =>
      events.add('error ${request.url} ${error.description}');

  @override
  void onExit() {
    if (!closed.isCompleted) closed.complete();
  }
}
