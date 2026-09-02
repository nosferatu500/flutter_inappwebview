part of 'main.dart';

/// Verifies the cookie master switch — `CookieManager.setAcceptCookie` / `acceptCookie` (§55 on
/// Android, §113 on iOS), on a device (§57).
///
/// The interesting assertion is the **negative** one. `setAcceptCookie(false)` does *not* stop
/// [PlatformCookieManager.setCookie] from writing: a programmatic write still succeeds and the
/// cookie is still in the store. Measured on Android 13 (API 33), WebView 109 — **and then measured
/// again on iOS 26.5, where `WKHTTPCookieStore.setCookiePolicy(.disallow)` behaves the same way**.
/// The switch governs cookies flowing through the WebView's own network traffic, not the app's
/// writes — which is the opposite of what the Android reference's "should send and accept cookies"
/// reads like, and it is why this is pinned rather than left to a doc comment.
///
/// **The body below runs unchanged on both platforms, and that is the finding**, not an assumption:
/// two independently-specified APIs agree on the default, on the round trip, on not hiding existing
/// cookies and on not blocking programmatic writes.
///
/// Deliberately does NOT pump a WebView: on Android `CookieManager` is process-global and needs
/// none, so loading a real page would only add a network dependency. An earlier version of this
/// test did load `https://flutter.dev/` and timed out at 60s on a slow emulator.
void acceptCookie() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      !CookieManager.isMethodSupported(
        PlatformCookieManagerMethod.setAcceptCookie,
      );

  skippableTestWidgets('accept cookie master switch', (
    WidgetTester tester,
  ) async {
    final cookieManager = CookieManager.instance();
    final url = WebUri('https://example.com/');

    Future<List<String>> names() async =>
        (await cookieManager.getCookies(url: url)).map((c) => c.name).toList();

    // `isMethodSupported` is a *platform* check and is true on every iOS, but the underlying
    // `WKHTTPCookieStore.setCookiePolicy` is iOS 17.0+. Below that floor the correct behaviour is a
    // different answer, not an absent one, so it is asserted here rather than skipped -- otherwise
    // a missing availability guard and a working one look identical.
    final major = iosMajorVersion();
    if (major != null && major < 17) {
      await cookieManager.deleteAllCookies();

      expect(
        await cookieManager.setAcceptCookie(false),
        isFalse,
        reason:
            'iOS $major cannot set a cookie policy, and `false` here means "not applied" -- '
            'not "cookies are now rejected"',
      );
      expect(
        await cookieManager.isAcceptCookieEnabled(),
        isNull,
        reason:
            'iOS $major has no cookie policy to read, and null must not be collapsed to false',
      );
      // And the failed switch changed nothing: the store still works.
      expect(
        await cookieManager.setCookie(url: url, name: 'unswitched', value: 'v'),
        isTrue,
      );
      expect(await names(), ['unswitched']);
      await cookieManager.deleteAllCookies();
      return;
    }

    try {
      await cookieManager.deleteAllCookies();

      // The platform default, and the reason the getter is `bool?` rather than `bool`: a caller
      // must be able to tell "not accepting" from "could not read".
      expect(await cookieManager.isAcceptCookieEnabled(), isTrue);

      expect(
        await cookieManager.setCookie(url: url, name: 'before', value: 'v1'),
        isTrue,
      );
      expect(await names(), ['before']);

      // Turn it off, and read it back -- this is the round trip through both new channel methods.
      expect(await cookieManager.setAcceptCookie(false), isTrue);
      expect(await cookieManager.isAcceptCookieEnabled(), isFalse);

      // Turning it off deletes nothing and hides nothing: the earlier cookie is still readable.
      expect(await names(), ['before']);

      // And a programmatic write is NOT blocked by it. If this ever starts failing, the switch's
      // scope has changed and PlatformCookieManager.setAcceptCookie's doc needs revisiting.
      expect(
        await cookieManager.setCookie(url: url, name: 'during', value: 'v2'),
        isTrue,
      );
      expect(await names(), ['before', 'during']);

      expect(await cookieManager.setAcceptCookie(true), isTrue);
      expect(await cookieManager.isAcceptCookieEnabled(), isTrue);
      expect(await names(), ['before', 'during']);
    } finally {
      // A switch with no documented reset on restart -- process-wide on Android, per data store on
      // iOS -- so restore it even on failure: leaving it off could poison later tests and later
      // runs.
      await cookieManager.setAcceptCookie(true);
      await cookieManager.deleteAllCookies();
    }
  }, skip: shouldSkip);
}
