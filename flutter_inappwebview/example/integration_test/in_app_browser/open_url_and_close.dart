part of 'main.dart';

void openUrlAndClose() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('open url and close', () async {
    var inAppBrowser = new MyInAppBrowser();
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
}
