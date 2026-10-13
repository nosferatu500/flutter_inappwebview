part of 'main.dart';

/// Verifies `CookieManager.allowFileSchemeCookies` (§59) on a device.
///
/// There is nothing to round-trip here — the plugin exposes no setter, because the platform's is
/// deprecated — so what the device is actually for is the **value**: is it non-null (i.e. does the
/// static call succeed at all behind the provider guard), and is it the `false` that Android
/// documents as the default for apps targeting API 21+? The doc claims that default, so it is
/// pinned; if a future platform flips it, this fails and the doc gets corrected rather than
/// quietly going stale — which is exactly the §57 failure mode.
void fileSchemeCookies() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      !CookieManager.isMethodSupported(
        PlatformCookieManagerMethod.isFileSchemeCookiesAllowed,
      );

  skippableTestWidgets('file scheme cookie policy is readable', (
    WidgetTester tester,
  ) async {
    final allowed = await CookieManager.isFileSchemeCookiesAllowed();

    expect(
      allowed,
      isNotNull,
      reason:
          'null means the provider guard rejected the call, not that file cookies are disallowed',
    );
    expect(
      allowed,
      isFalse,
      reason:
          'Android documents false as the default for apps targeting API 21+; if this is now true '
          'the platform default changed and PlatformCookieManager.isFileSchemeCookiesAllowed needs '
          'its doc updated',
    );

    // Process-global and read-only, so it cannot drift between calls.
    expect(await CookieManager.isFileSchemeCookiesAllowed(), allowed);
  }, skip: shouldSkip);
}
