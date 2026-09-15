part of 'main.dart';

/// Device coverage for the `profileName` parameter that all 12 `CookieManager` channel methods
/// carry (§166, closing the gap §166 measured).
///
/// **Why this exists.** §166 probed the Kotlin dispatch during a full green `cookie_manager` run:
/// every one of the 12 methods fires, and every one of the 58 calls carried `profileName=null`.
/// So `MyCookieManager.getCookieManager(profileName)` only ever took its `profileName == null`
/// early return — the `MULTI_PROFILE` gate and the
/// `ProfileStore.getInstance().getProfile(name)?.cookieManager` resolution behind it had **no
/// device coverage on any platform**, and neither did any method's null-manager branch. The Dart
/// unit tests (`cookie_manager_profile_test.dart`) pin only that the key leaves Dart and reaches
/// every method; they cannot see what the native side does with it.
///
/// That matters most for the Pigeon migration: a schema that dropped or mis-typed `profileName`
/// would silently resolve every call against the **default** store, and every existing test would
/// still pass.
///
/// **§137 considered this and declined**, on the grounds that "a device that lacks MULTI_PROFILE
/// would make an integration assertion mean two different things" (see `flush.dart`). That
/// objection is answered rather than ignored: both tests below return early via
/// [markTestSkipped] unless `MULTI_PROFILE` is actually supported, so a pass always means the
/// profile path ran. §137's remark was also specifically about the *failure* path; the isolation
/// test below is the success path, which it did not consider.
///
/// No WebView is pumped: `CookieManager` is process-global on Android and these are programmatic
/// writes, so a page load would only add a network dependency (§57).
void profileScope() {
  final shouldSkip =
      !CookieManager.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  Future<bool> available() async =>
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  // Created with `getOrCreateProfile` and never deleted, matching `custom_request_headers.dart`:
  // androidx refuses to delete a profile that is in use, and the call is idempotent, so a reused
  // name is safe across runs where a delete would be a flake waiting to happen.
  const profile = 'inappwebview_cookie_scope_test';

  skippableTestWidgets('cookies are scoped to their profile', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('MULTI_PROFILE unsupported');
      return;
    }

    final cookieManager = CookieManager.instance();
    final url = WebUri('https://example.com/');

    expect(
      await ProfileStore.instance().getOrCreateProfile(name: profile),
      isNotNull,
      reason: 'the rest of this test is meaningless without a real profile',
    );

    Future<List<String>> namesIn(String? name) async =>
        (await cookieManager.getCookies(
          url: url,
          profileName: name,
        )).map((c) => c.name).toList();

    try {
      await cookieManager.deleteAllCookies();
      await cookieManager.deleteAllCookies(profileName: profile);

      expect(
        await cookieManager.setCookie(url: url, name: 'inDefault', value: 'd'),
        isTrue,
      );
      expect(
        await cookieManager.setCookie(
          url: url,
          name: 'inProfile',
          value: 'p',
          profileName: profile,
        ),
        isTrue,
        reason: 'a write scoped to a named profile still reports success',
      );

      // The pair that fails if `profileName` stops reaching the native side. Asserted as
      // *disjoint lists* rather than "the profile has its cookie", because a dropped parameter
      // makes both calls resolve the same store -- and then each list carries both names, which a
      // one-sided `contains` assertion would happily pass.
      expect(
        await namesIn(null),
        ['inDefault'],
        reason: 'the default store must not see the named profile\'s cookie',
      );
      expect(
        await namesIn(profile),
        ['inProfile'],
        reason: 'the named profile must not see the default store\'s cookie',
      );
    } finally {
      await cookieManager.deleteAllCookies();
      await cookieManager.deleteAllCookies(profileName: profile);
    }
  }, skip: shouldSkip);

  /// The null-manager branch, which is the other half of what §166 found uncovered.
  ///
  /// An unknown name means `ProfileStore.getProfile` returns null, so every method takes the
  /// branch it guards -- and **those branches do not agree with each other**: `setCookie`,
  /// `deleteAllCookies` and `flush` answer `false`, `getCookies` answers an empty list, and
  /// `hasCookies` and `isAcceptCookieEnabled` answer **null** rather than `false`, deliberately,
  /// so a caller can tell "not accepting" from "could not read". Pigeon makes an unanswered branch
  /// unrepresentable, so the migration has to restate each of these by hand; this pins what they
  /// currently are, per the checklist's item 3.
  ///
  /// Distinct from the `MULTI_PROFILE`-absent case, which returns null from the same helper one
  /// line earlier -- that one stays with the unit tests, since it cannot be produced on a device
  /// that supports the feature.
  skippableTestWidgets('an unknown profile resolves to no store', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('MULTI_PROFILE unsupported');
      return;
    }

    final cookieManager = CookieManager.instance();
    final url = WebUri('https://example.com/');
    const missing = 'inappwebview_no_such_profile';

    expect(
      await ProfileStore.instance().getAllProfileNames(),
      isNot(contains(missing)),
      reason: 'the test is vacuous if this name happens to exist',
    );

    expect(
      await cookieManager.setCookie(
        url: url,
        name: 'x',
        value: 'v',
        profileName: missing,
      ),
      isFalse,
    );
    expect(
      await cookieManager.getCookies(url: url, profileName: missing),
      isEmpty,
    );
    expect(await cookieManager.deleteAllCookies(profileName: missing), isFalse);
    expect(await cookieManager.flush(profileName: missing), isFalse);

    // The two that answer null, not false. `isNull` is the whole point of the assertion.
    expect(
      await cookieManager.hasCookies(profileName: missing),
      isNull,
      reason:
          'null means "could not read", which false would misreport as "empty"',
    );
    expect(
      await cookieManager.isAcceptCookieEnabled(profileName: missing),
      isNull,
      reason:
          'null means "could not read", which false would misreport as "rejecting"',
    );

    // And none of that touched the default store.
    expect(await cookieManager.getCookies(url: url), isEmpty);
  }, skip: shouldSkip);
}
