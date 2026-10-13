part of 'main.dart';

/// Device coverage for the default profile's [GeolocationPermissions] store (§174).
///
/// **Why this group exists at all.** `GeolocationPermissionsManager` is next in the Pigeon migration
/// queue and had **zero** device tests — measured, not assumed: no file under `integration_test/`
/// mentioned geolocation. That is precisely the state §169 migrated `web_storage_manager` in, which
/// is how §168's invented `assert` got a commit further than it should have. Standing rule 2 says
/// the group comes first, as its own item; this is that item.
///
/// **No WebView is pumped.** These are the *stored* decisions, not the prompt: `allow` and `clear`
/// are a programmatic record that a WebView consults before asking, so a page load would only add a
/// network dependency (§57) and a location prompt nothing in the plugin API can dismiss. That
/// happens to be why this group is measurable at all right now — the AVD's DNS is broken, which
/// fails every external-URL test in `in_app_webview` and touches nothing here.
///
/// 🚨 **The API is live, unlike the `web_storage_manager` equivalent — but it is asymmetric.** §170
/// found `WebStorage.getOrigins` answers `[]` however much storage is in use, because it reports Web
/// SQL origins and Chromium removed Web SQL. The probe below is the equivalent, and it came back
/// *different*: the store really does record and return decisions. What it also found, on the first
/// run and in four tests at once, is that **[GeolocationPermissions.getOrigins] does not return the
/// string [GeolocationPermissions.allow] was given** — see [originNormalisation].
void storedDecisions() {
  // Distinctive and origin-shaped: scheme + host, no path. A path is not part of the identity a
  // decision is stored against, so using a URL here would be testing the wrong thing.
  const origin = 'https://inappwebview-geo-a.test';
  const otherOrigin = 'https://inappwebview-geo-b.test';

  /// What the platform hands back for [origin]. **Measured, not assumed** — see
  /// [originNormalisation], which is the test that pins it.
  const storedOrigin = '$origin/';

  final permissions = GeolocationPermissions.instance();

  setUp(() async {
    // Process-wide store shared with every other group in the aggregate run, so each test starts
    // from a known empty state rather than from whatever ran before it.
    await permissions.clearAll();
  });

  tearDown(() async {
    await permissions.clearAll();
  });

  skippableTestWidgets('a stored decision round-trips', (
    WidgetTester tester,
  ) async {
    expect(
      await permissions.allow(origin: origin),
      isTrue,
      reason: 'allow reports failure only when the store cannot be resolved',
    );

    expect(
      await permissions.getAllowed(origin: origin),
      isTrue,
      reason:
          'the decision just stored could not be read back — if this fails the store is inert, '
          'as WebStorage.getOrigins turned out to be in §170',
    );
    expect(await permissions.getOrigins(), hasLength(1));
  }, skip: false);

  originNormalisation();

  skippableTestWidgets(
    'an origin with no decision is false, and that is an answer',
    (WidgetTester tester) async {
      // `false` and `null` are different answers here and the difference is load-bearing: `null`
      // means the question could not be asked (see profile_scope.dart), `false` means it was asked
      // and nothing is stored. There is no stored "deny" to confuse either with.
      expect(await permissions.getAllowed(origin: origin), isFalse);
      expect(await permissions.getAllowed(origin: origin), isNotNull);
      expect(await permissions.getOrigins(), isEmpty);
    },
    skip: false,
  );

  skippableTestWidgets('clear removes one decision and leaves its neighbour', (
    WidgetTester tester,
  ) async {
    await permissions.allow(origin: origin);
    await permissions.allow(origin: otherOrigin);

    expect(await permissions.clear(origin: origin), isTrue);

    // The pair is the assertion. A `clear` wired to `clearAll` — or one that ignored its argument —
    // passes a single-origin test perfectly, which is the same shape as §167's disjoint-lists
    // reasoning for cookies.
    expect(await permissions.getAllowed(origin: origin), isFalse);
    expect(
      await permissions.getAllowed(origin: otherOrigin),
      isTrue,
      reason: 'clearing one origin removed an unrelated one',
    );
  }, skip: false);

  skippableTestWidgets('clearAll removes every decision', (
    WidgetTester tester,
  ) async {
    await permissions.allow(origin: origin);
    await permissions.allow(origin: otherOrigin);
    expect(await permissions.getOrigins(), hasLength(2));

    expect(await permissions.clearAll(), isTrue);

    expect(await permissions.getOrigins(), isEmpty);
    expect(await permissions.getAllowed(origin: origin), isFalse);
    expect(await permissions.getAllowed(origin: otherOrigin), isFalse);
  }, skip: false);

  skippableTestWidgets('allow is idempotent and does not duplicate the origin', (
    WidgetTester tester,
  ) async {
    await permissions.allow(origin: origin);
    await permissions.allow(origin: origin);

    // Cheap, and it pins that the store is keyed by origin rather than append-only — which is what
    // makes `getOrigins().length` meaningful in the test above.
    expect(
      (await permissions.getOrigins()).where((o) => o == storedOrigin),
      hasLength(1),
    );
  }, skip: false);
}

/// 🚨 **The platform does not hand back the string it was given.**
///
/// `allow(origin: 'https://example.test')` is read back by `getOrigins()` as
/// **`'https://example.test/'`** — with a trailing slash. Found by this group's first run, where it
/// failed four tests at once and looked like four problems.
///
/// This matters beyond cosmetics because the two halves of the public API disagree about the form:
/// [GeolocationPermissions.getAllowed] and [GeolocationPermissions.clear] take the **un-normalised**
/// string happily (the tests above prove it), while [GeolocationPermissions.getOrigins] emits the
/// normalised one. A caller that does the obvious thing — list the origins, then act on each one —
/// is feeding a string back in that is not the string it stored, and nothing in the dartdoc says so.
///
/// So the question that decides whether this is a documentation gap or a real trap is whether
/// `getOrigins()`'s own output survives a round trip back into the other methods. That is what this
/// test measures, rather than reasoning about how Chromium probably normalises.
void originNormalisation() {
  const origin = 'https://inappwebview-geo-norm.test';
  final permissions = GeolocationPermissions.instance();

  skippableTestWidgets('getOrigins normalises the origin, and its output feeds back in', (
    WidgetTester tester,
  ) async {
    await permissions.clearAll();
    try {
      await permissions.allow(origin: origin);

      final origins = await permissions.getOrigins();
      expect(origins, hasLength(1));

      // The finding, pinned as an equality rather than a `contains` so that a future platform
      // change in either direction fails here loudly instead of silently widening.
      expect(
        origins.single,
        '$origin/',
        reason:
            'the platform normalisation changed; every assertion in this group that spells an '
            'origin is affected',
      );
      expect(
        origins.single,
        isNot(origin),
        reason:
            'if this ever passes, the asymmetry is gone and this test should be deleted',
      );

      // The half that decides whether the asymmetry is a trap: can a caller take what getOrigins
      // gave them and use it?
      expect(
        await permissions.getAllowed(origin: origins.single),
        isTrue,
        reason:
            'getOrigins returned a string that getAllowed does not recognise, so listing then '
            'querying is broken for every caller',
      );
      expect(await permissions.clear(origin: origins.single), isTrue);
      expect(
        await permissions.getOrigins(),
        isEmpty,
        reason: 'clear did not accept the very string getOrigins produced',
      );
    } finally {
      await permissions.clearAll();
    }
  }, skip: false);
}
