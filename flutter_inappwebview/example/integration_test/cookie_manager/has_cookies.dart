part of 'main.dart';

/// Verifies `CookieManager.hasCookies` (§58) against a real cookie store.
///
/// Two things a unit test cannot say: that the store-wide probe actually tracks the store, and that
/// a **session** cookie (no expiry, which is what [PlatformCookieManager.setCookie] writes here)
/// counts as "has cookies". Both are asserted below.
///
/// No WebView is pumped: `CookieManager` is process-global on Android, so a page load would only
/// add a network dependency (§57).
void hasCookies() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      !CookieManager.isMethodSupported(PlatformCookieManagerMethod.hasCookies);

  skippableTestWidgets('hasCookies tracks the store', (
    WidgetTester tester,
  ) async {
    final cookieManager = CookieManager.instance();
    final url = WebUri('https://example.com/');

    await cookieManager.deleteAllCookies();
    expect(
      await cookieManager.hasCookies(),
      isFalse,
      reason: 'the store was just emptied',
    );

    // A session cookie -- no expiresDate, no maxAge.
    expect(
      await cookieManager.setCookie(url: url, name: 'probe', value: 'v'),
      isTrue,
    );
    expect(
      await cookieManager.hasCookies(),
      isTrue,
      reason: 'a session cookie still counts as a stored cookie',
    );

    // It is store-wide, so it answers true for an origin the caller never asks about.
    expect(await cookieManager.getCookies(url: url), isNotEmpty);

    await cookieManager.deleteAllCookies();
    expect(await cookieManager.hasCookies(), isFalse);
  }, skip: shouldSkip);
}
