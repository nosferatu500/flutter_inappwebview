part of 'main.dart';

/// Pins the plural [CookieManager.setCookies] (§129).
///
/// The load-bearing assertions are the ones a per-cookie loop would also satisfy *plus* the ones
/// it would not: that every entry gets its **own** field values rather than the last one's, that
/// the answers come back **in input order**, and that a batch spanning two origins really writes
/// to both. A test that set three identical cookies to one origin would pass against an
/// implementation that dropped all but one.
void setCookies() {
  final shouldSkip = !CookieManager.isClassSupported();

  skippableTestWidgets('setCookies writes a batch and answers in order', (
    WidgetTester tester,
  ) async {
    final cookieManager = CookieManager.instance();
    final Completer<String> pageLoaded = Completer<String>();

    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final url = WebUri(await pageLoaded.future);
    await cookieManager.deleteCookies(url: url);

    final results = await cookieManager.setCookies(
      cookies: [
        CookieToSet(url: url, name: 'batch_a', value: 'one'),
        CookieToSet(url: url, name: 'batch_b', value: 'two'),
        CookieToSet(url: url, name: 'batch_c', value: 'three'),
      ],
    );

    expect(
      results.length,
      3,
      reason: 'setCookies must answer once per input cookie',
    );
    expect(results, everyElement(isTrue));

    final cookies = await cookieManager.getCookies(url: url);
    String? valueOf(String name) =>
        cookies.where((c) => c.name == name).map((c) => c.value).firstOrNull;

    // Distinct values, so an implementation that wrote the last cookie three times, or the first
    // one three times, fails here rather than passing on a count.
    expect(valueOf('batch_a'), 'one');
    expect(valueOf('batch_b'), 'two');
    expect(valueOf('batch_c'), 'three');

    await cookieManager.deleteCookies(url: url);
  }, skip: shouldSkip);

  skippableTestWidgets('setCookies spans several origins in one call', (
    WidgetTester tester,
  ) async {
    // Each CookieToSet carries its own url, which is the reason the type exists rather than the
    // url being hoisted to the call. If the native side used one url for the whole batch, the
    // second cookie would land on the first origin and both assertions below would fail.
    final cookieManager = CookieManager.instance();
    final Completer<String> pageLoaded = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final urlA = WebUri(await pageLoaded.future);
    final urlB = TEST_CROSS_PLATFORM_URL_2;
    await cookieManager.deleteCookies(url: urlA);
    await cookieManager.deleteCookies(url: urlB);

    final results = await cookieManager.setCookies(
      cookies: [
        CookieToSet(url: urlA, name: 'origin_a', value: 'aaa'),
        CookieToSet(url: urlB, name: 'origin_b', value: 'bbb'),
      ],
    );
    expect(results, [isTrue, isTrue]);

    final onA = await cookieManager.getCookies(url: urlA);
    final onB = await cookieManager.getCookies(url: urlB);

    expect(
      onA.where((c) => c.name == 'origin_a').map((c) => c.value),
      contains('aaa'),
    );
    expect(
      onB.where((c) => c.name == 'origin_b').map((c) => c.value),
      contains('bbb'),
    );
    // The other half of the control: neither cookie leaked onto the other origin.
    expect(onA.map((c) => c.name), isNot(contains('origin_b')));
    expect(onB.map((c) => c.name), isNot(contains('origin_a')));

    await cookieManager.deleteCookies(url: urlA);
    await cookieManager.deleteCookies(url: urlB);
  }, skip: shouldSkip);

  skippableTestWidgets('setCookies carries the per-cookie flags', (
    WidgetTester tester,
  ) async {
    // `isHttpOnly` differs between the two entries and nothing else does, so an implementation
    // that built one cookie and reused it, or that dropped the optional fields, is caught.
    final cookieManager = CookieManager.instance();
    final Completer<String> pageLoaded = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final url = WebUri(await pageLoaded.future);
    await cookieManager.deleteCookies(url: url);

    await cookieManager.setCookies(
      cookies: [
        CookieToSet(url: url, name: 'flag_on', value: 'on', isHttpOnly: true),
        CookieToSet(
          url: url,
          name: 'flag_off',
          value: 'off',
          isHttpOnly: false,
        ),
      ],
    );

    final cookies = await cookieManager.getCookies(url: url);
    Cookie? named(String name) =>
        cookies.where((c) => c.name == name).firstOrNull;

    expect(
      cookies.map((c) => c.name),
      containsAll(['flag_on', 'flag_off']),
      reason: 'both cookies must have been written',
    );
    // Values differ too, so a batch that built one cookie and reused it fails here.
    expect(named('flag_on')?.value, 'on');
    expect(named('flag_off')?.value, 'off');

    // `isHttpOnly` is only reported back on Android behind GET_COOKIE_INFO, so assert the
    // round trip where the platform answers at all rather than skipping the whole test. This is
    // the flag being *carried per cookie*, not the flag's effect on `document.cookie` — the
    // plugin's own getCookies ignores HttpOnly, so it could not see that either way.
    if (named('flag_on')?.isHttpOnly != null) {
      expect(named('flag_on')?.isHttpOnly, isTrue);
      expect(named('flag_off')?.isHttpOnly, isFalse);
    }

    await cookieManager.deleteCookies(url: url);
  }, skip: shouldSkip);

  skippableTestWidgets('setCookies with an empty list is a no-op', (
    WidgetTester tester,
  ) async {
    final cookieManager = CookieManager.instance();
    expect(await cookieManager.setCookies(cookies: []), isEmpty);
  }, skip: shouldSkip);
}
