part of 'main.dart';

/// Regression test for the Android `flush` hang (`TODO.md` P0b.9, found in §55).
///
/// `MyCookieManager.flush` used to call `manager.flush()` and return **without** replying on the
/// channel. A MethodChannel has no timeout and nothing supplies a missing reply, so the Dart future
/// never completed — `await cookieManager.flush()` hung forever, taking the caller with it.
///
/// This is the only kind of test that can see it. `flutter analyze`, kotlinc, lint and the android
/// package's unit tests all pass against the broken code, because those unit tests drive the
/// channel through a mock handler that always replies — they exercise the Dart half only. The
/// explicit `.timeout` is what turns the old behaviour into a legible failure instead of a run that
/// stalls until the whole suite's timeout fires.
void flush() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      !CookieManager.isMethodSupported(PlatformCookieManagerMethod.flush);

  skippableTestWidgets('flush completes', (WidgetTester tester) async {
    final cookieManager = CookieManager.instance();
    final Completer<String> pageLoaded = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final url = WebUri(await pageLoaded.future);
    await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");

    await expectLater(
      cookieManager.flush().timeout(const Duration(seconds: 10)),
      completes,
      reason:
          'flush() did not reply on the channel -- the native handler is not calling '
          'result.success(...) on its success path',
    );

    // A flush must not disturb what it wrote out.
    final cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie?.value.toString(), "myValue");

    await cookieManager.deleteAllCookies();
  }, skip: shouldSkip);
}
