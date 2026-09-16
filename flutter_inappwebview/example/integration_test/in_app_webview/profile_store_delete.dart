part of 'main.dart';

/// Device coverage for [ProfileStore.deleteProfile], the one `ProfileStoreManager` method that had
/// none (§173).
///
/// **Why this exists, and why it is three tests and not four.** androidx's contract
/// (`ProfileStore.deleteProfile`, read from the 1.17.0 sources rather than inferred) has four
/// outcomes, and exactly one of them is unreachable from a test process:
///
///  * returns `false` — no such profile. Reachable.
///  * `IllegalStateException` — a living WebView uses the profile, **or** the profile was loaded
///    into memory this run by `getOrCreateProfile`/`getProfile`. Reachable.
///  * `IllegalArgumentException` — the name is the default profile. Reachable.
///  * returns `true` — the profile exists *and* was never loaded this run. **Unreachable**: the
///    only way this plugin can bring a profile into existence is `getOrCreateProfile`, which is
///    precisely what loads it, and a profile left over from an earlier run cannot be named without
///    reading the list, which does not load it — but nothing in the suite creates one to leave
///    behind. §171 wrote a test that measured nothing and said so; this one says so instead of
///    writing it.
///
/// 🚨 **The load-bearing assertion is that both refusals carry the *same* `code`.** They arrive from
/// androidx as two different exception classes, and the plugin normalises both to
/// `"ProfileStoreManager"`. That normalisation is invisible under the hand-written `MethodChannel`
/// — `result.error(LOG_TAG, …)` had no other spelling available — but it is a real decision under
/// Pigeon, whose `wrapError` derives the code from `javaClass.simpleName` unless the host throws a
/// `FlutterError`. A migration that simply let the exceptions propagate would turn one stable code
/// into two exception-class names, and a single-refusal test would not notice: it would report
/// `"IllegalStateException"` and look like a rename rather than a contract break. The pair is what
/// makes the normalisation observable.
void profileStoreDelete() {
  final shouldSkip =
      !ProfileStore.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  Future<bool> available() async =>
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  skippableTestWidgets('deleting an unknown profile answers false, not an error', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('MULTI_PROFILE unsupported');
      return;
    }

    final store = ProfileStore.instance();
    const missing = 'inappwebview_no_such_profile_to_delete';

    // Vacuity guard: the assertion below means nothing if this name happens to exist, because then
    // `false` would be the wrong answer for a different reason. `getAllProfileNames` is used rather
    // than a lookup on purpose — a lookup would load the profile and change what delete does.
    expect(
      await store.getAllProfileNames(),
      isNot(contains(missing)),
      reason: 'the test is vacuous if this name happens to exist',
    );

    expect(
      await store.deleteProfile(name: missing),
      isFalse,
      reason:
          'a missing profile is a false, not a throw — the two refusal cases below are what throw',
    );
  }, skip: shouldSkip);

  skippableTestWidgets(
    'deleting a profile loaded this run is refused under the plugin code',
    (WidgetTester tester) async {
      if (!await available()) {
        markTestSkipped('MULTI_PROFILE unsupported');
        return;
      }

      final store = ProfileStore.instance();
      // Its own name, not one of the names the header/cookie tests reuse: creating a profile is
      // irreversible within the process, so a shared name would couple this test to their ordering.
      const profile = 'inappwebview_delete_refusal_test';

      expect(
        await store.getOrCreateProfile(name: profile),
        isNotNull,
        reason:
            'the refusal below is meaningless without a profile that exists',
      );

      // androidx raises IllegalStateException here: the profile was loaded into memory by the call
      // above and stays loaded for the life of the process.
      await expectLater(
        store.deleteProfile(name: profile),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'ProfileStoreManager',
          ),
        ),
      );
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'deleting the default profile is refused under the same code',
    (WidgetTester tester) async {
      if (!await available()) {
        markTestSkipped('MULTI_PROFILE unsupported');
        return;
      }

      final store = ProfileStore.instance();

      // androidx raises IllegalArgumentException here — a *different* class from the test above, and
      // that is the whole point: the code the caller sees must not depend on which one androidx
      // happened to pick.
      await expectLater(
        store.deleteProfile(name: ProfileStore.defaultProfileName),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'ProfileStoreManager',
          ),
        ),
      );

      // And the refusal is a refusal, not a silent partial delete.
      expect(
        await store.getAllProfileNames(),
        contains(ProfileStore.defaultProfileName),
        reason: 'the default profile must still be there after the refusal',
      );
    },
    skip: shouldSkip,
  );
}
