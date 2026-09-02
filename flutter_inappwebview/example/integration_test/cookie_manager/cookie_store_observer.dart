part of 'main.dart';

/// Verifies `CookieManager.setCookieStoreObserver` (A4, `WKHTTPCookieStoreObserver`) against a real
/// cookie store.
///
/// What only a device can say, and what this asserts:
///
/// * that WebKit calls the observer at all — the `@objc` thunk being installed is a static fact
///   (`nm | swift-demangle`), being *called* is not;
/// * **that the plugin's own writes count as changes.** The header says nothing either way, and
///   "only web content triggers it" was the plausible alternative. If that were true the feature
///   would be far narrower than the queue row implies;
/// * that removing the observer really stops delivery, rather than only clearing the Dart-side
///   field.
///
/// No WebView is pumped: the cookie store is process-wide, so `setCookie` reaches exactly the store
/// WebKit is observing, and a page load would only add a network dependency (§57).
void cookieStoreObserver() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      !CookieManager.isMethodSupported(
        PlatformCookieManagerMethod.setCookieStoreObserver,
      );

  /// The notification is delivered asynchronously, after `setCookie`'s completion handler has
  /// already returned, so every assertion polls instead of sleeping a fixed amount.
  Future<void> waitUntil(bool Function() condition) async {
    for (var i = 0; i < 40 && !condition(); i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  skippableTestWidgets('setCookieStoreObserver reports store changes', (
    WidgetTester tester,
  ) async {
    final cookieManager = CookieManager.instance();
    final url = WebUri('https://example.com/');

    var changes = 0;
    await cookieManager.setCookieStoreObserver(
      CookieStoreObserver(onCookiesChanged: () => changes++),
    );
    expect(cookieManager.cookieStoreObserver, isNotNull);

    try {
      await cookieManager.deleteAllCookies();
      await Future.delayed(const Duration(seconds: 1));
      changes = 0;

      expect(
        await cookieManager.setCookie(url: url, name: 'observed', value: 'v'),
        isTrue,
      );
      await waitUntil(() => changes > 0);
      expect(
        changes,
        greaterThan(0),
        reason:
            'a cookie written through this plugin is a change to the store WebKit observes',
      );

      final afterSet = changes;
      expect(
        await cookieManager.deleteCookie(url: url, name: 'observed'),
        isTrue,
      );
      await waitUntil(() => changes > afterSet);
      expect(
        changes,
        greaterThan(afterSet),
        reason: 'a deletion is a change too',
      );
    } finally {
      await cookieManager.setCookieStoreObserver(null);
    }

    expect(cookieManager.cookieStoreObserver, isNull);

    // And it is really gone natively, not just forgotten in Dart.
    final afterRemoval = changes;
    expect(
      await cookieManager.setCookie(url: url, name: 'unobserved', value: 'v'),
      isTrue,
    );
    await Future.delayed(const Duration(seconds: 1));
    expect(
      changes,
      afterRemoval,
      reason: 'removeObserver: must have reached WKHTTPCookieStore',
    );

    await cookieManager.deleteAllCookies();
  }, skip: shouldSkip);
}
