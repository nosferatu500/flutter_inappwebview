part of 'main.dart';

/// Device coverage for the `profileName` argument all five `GeolocationPermissions` methods carry
/// (§174).
///
/// This is the half that matters most for the Pigeon migration, for the same reason §167's cookie
/// equivalent did: a schema that dropped or mis-typed `profileName` would silently resolve every
/// call against the **default** store, and every test in `stored_decisions.dart` would still pass.
///
/// It is also where the only `null`-versus-`false` distinction on this channel lives.
/// `getGeolocationPermissions` returns null when `MULTI_PROFILE` is unsupported or the named profile
/// does not exist, and the five methods then disagree with each other **on purpose**: `allow`,
/// `clear` and `clearAll` answer `false`, `getOrigins` answers an empty list, and `getAllowed`
/// answers **`null`** rather than `false`, so a caller can tell "could not ask" from "nothing
/// stored". Pigeon makes an unanswered branch unrepresentable, so the migration has to restate each
/// of these by hand — this pins what they currently are.
void geolocationProfileScope() {
  const origin = 'https://inappwebview-geo-scope.test';
  const profileOrigin = 'https://inappwebview-geo-scope-profile.test';

  // `getOrigins` hands back the origin with a trailing slash, while `allow`/`getAllowed`/`clear`
  // take it without. Measured, and pinned on its own by `originNormalisation` in
  // stored_decisions.dart — spelled out here because every `getOrigins` assertion below depends on
  // it, and the first run of this group failed four tests for this one reason.
  const storedOrigin = '$origin/';
  const storedProfileOrigin = '$profileOrigin/';

  // Created and never deleted, matching custom_request_headers.dart and §167: androidx refuses to
  // delete a profile loaded this run, and getOrCreateProfile is idempotent, so a reused name is
  // safe across runs where a delete would be a flake waiting to happen.
  const profile = 'inappwebview_geolocation_scope_test';

  final permissions = GeolocationPermissions.instance();

  Future<bool> available() async =>
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  skippableTestWidgets('decisions are scoped to their profile', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('MULTI_PROFILE unsupported');
      return;
    }

    expect(
      await ProfileStore.instance().getOrCreateProfile(name: profile),
      isNotNull,
      reason: 'the rest of this test is meaningless without a real profile',
    );

    try {
      await permissions.clearAll();
      await permissions.clearAll(profileName: profile);

      expect(await permissions.allow(origin: origin), isTrue);
      expect(
        await permissions.allow(origin: profileOrigin, profileName: profile),
        isTrue,
        reason: 'a write scoped to a named profile still reports success',
      );

      // Asserted as *disjoint lists* rather than "the profile has its origin", because a dropped
      // `profileName` makes both calls resolve the same store — and then each list carries both
      // origins, which a one-sided `contains` assertion would happily pass. §167's reasoning,
      // reused because the failure mode is identical.
      expect(
        await permissions.getOrigins(),
        [storedOrigin],
        reason: 'the default store must not see the named profile\'s decision',
      );
      expect(
        await permissions.getOrigins(profileName: profile),
        [storedProfileOrigin],
        reason: 'the named profile must not see the default store\'s decision',
      );

      expect(await permissions.getAllowed(origin: profileOrigin), isFalse);
      expect(
        await permissions.getAllowed(origin: origin, profileName: profile),
        isFalse,
      );
    } finally {
      await permissions.clearAll();
      await permissions.clearAll(profileName: profile);
    }
  }, skip: false);

  /// The null-store branch, which is the other half of what the migration must preserve.
  ///
  /// Distinct from the `MULTI_PROFILE`-absent case, which returns null from the same helper one
  /// line earlier — that one cannot be produced on a device that supports the feature, and stays
  /// with the Dart unit tests.
  skippableTestWidgets('an unknown profile resolves to no store', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('MULTI_PROFILE unsupported');
      return;
    }

    const missing = 'inappwebview_geolocation_no_such_profile';

    expect(
      await ProfileStore.instance().getAllProfileNames(),
      isNot(contains(missing)),
      reason: 'the test is vacuous if this name happens to exist',
    );

    try {
      await permissions.clearAll();
      expect(await permissions.allow(origin: origin), isTrue);

      // The three that answer false.
      expect(
        await permissions.allow(origin: origin, profileName: missing),
        isFalse,
      );
      expect(
        await permissions.clear(origin: origin, profileName: missing),
        isFalse,
      );
      expect(await permissions.clearAll(profileName: missing), isFalse);

      // The one that answers an empty list.
      expect(await permissions.getOrigins(profileName: missing), isEmpty);

      // And the one that answers null, not false. `isNull` is the whole point of the assertion:
      // `false` here would misreport "could not ask" as "nothing stored".
      expect(
        await permissions.getAllowed(origin: origin, profileName: missing),
        isNull,
        reason:
            'null means "could not ask", which false would misreport as "no decision stored"',
      );

      // And none of that touched the default store — including the clearAll, which is the call
      // most likely to do damage if the profile argument were dropped.
      expect(await permissions.getAllowed(origin: origin), isTrue);
      expect(await permissions.getOrigins(), contains(storedOrigin));
    } finally {
      await permissions.clearAll();
    }
  }, skip: false);
}
