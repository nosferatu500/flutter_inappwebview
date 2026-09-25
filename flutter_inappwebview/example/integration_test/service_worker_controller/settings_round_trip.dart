part of 'main.dart';

/// Device coverage for the eight Service Worker settings methods that had none (§185).
///
/// Before this, the group reached `setServiceWorkerClient`, the cookie-intercept pair, and
/// `getAllowContentAccess` once (as a non-null control). `getAllowFileAccess`, `getBlockNetworkLoads`,
/// `getCacheMode` and all four matching setters were never called on a device. Written as its own
/// item before migrating the channel to Pigeon, per rule 2.
///
/// Each setting is round-tripped **in both directions** and restored in a `finally` — these are
/// process-global and persist across tests. Then the same round trip runs on a **named profile**
/// and asserts the default profile did not move: the Kotlin side resolves settings through two
/// different APIs (androidx for the default profile, the framework's `ServiceWorkerWebSettings` for
/// a named one), and a transport that dropped `profileName` would silently write the default
/// instead — which only the isolation assertion can see.
void serviceWorkerSettingsRoundTrip() {
  final shouldSkip = !ServiceWorkerController.isClassSupported();

  /// One boolean setting's accessors, keyed by name for readable failures.
  final boolSettings =
      <
        String,
        (
          Future<bool> Function({String? profileName}),
          Future<void> Function(bool, {String? profileName}),
        )
      >{
        'allowContentAccess': (
          ServiceWorkerController.getAllowContentAccess,
          ServiceWorkerController.setAllowContentAccess,
        ),
        'allowFileAccess': (
          ServiceWorkerController.getAllowFileAccess,
          ServiceWorkerController.setAllowFileAccess,
        ),
        'blockNetworkLoads': (
          ServiceWorkerController.getBlockNetworkLoads,
          ServiceWorkerController.setBlockNetworkLoads,
        ),
      };

  Future<bool> swSupported() => WebViewFeature.isFeatureSupported(
    WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
  );

  skippableTestWidgets('boolean settings round-trip on the default profile', (
    WidgetTester tester,
  ) async {
    if (!await swSupported()) {
      markTestSkipped('SERVICE_WORKER_BASIC_USAGE unsupported');
      return;
    }
    for (final entry in boolSettings.entries) {
      final (get, set) = entry.value;
      final original = await get();
      try {
        // Away from the original and back: a setter that ignored its argument, or always wrote one
        // value, fails one of the two.
        for (final value in [!original, original]) {
          await set(value);
          expect(
            await get(),
            value,
            reason: '${entry.key} did not read back as $value',
          );
        }
      } finally {
        await set(original);
      }
    }
  }, skip: shouldSkip);

  skippableTestWidgets('cacheMode round-trips on the default profile', (
    WidgetTester tester,
  ) async {
    if (!await swSupported()) {
      markTestSkipped('SERVICE_WORKER_BASIC_USAGE unsupported');
      return;
    }
    final original = await ServiceWorkerController.getCacheMode();
    // Non-null before anything is written: null here would mean the call never reached a settings
    // object, and every assertion below would be comparing nulls.
    expect(
      original,
      isNotNull,
      reason: 'the default cache mode was unreadable',
    );
    try {
      for (final mode in [
        CacheMode.LOAD_NO_CACHE,
        CacheMode.LOAD_CACHE_ELSE_NETWORK,
        original!,
      ]) {
        await ServiceWorkerController.setCacheMode(mode);
        expect(await ServiceWorkerController.getCacheMode(), mode);
      }
    } finally {
      await ServiceWorkerController.setCacheMode(original!);
    }
  }, skip: shouldSkip);

  skippableTestWidgets('settings written to a named profile stay on that profile', (
    WidgetTester tester,
  ) async {
    if (!await swSupported() ||
        !await WebViewFeature.isFeatureSupported(
          WebViewFeature.MULTI_PROFILE,
        )) {
      markTestSkipped(
        'SERVICE_WORKER_BASIC_USAGE or MULTI_PROFILE unsupported',
      );
      return;
    }
    const profile = 'serviceWorkerSettingsRoundTripProfile';
    await ProfileStore.instance().getOrCreateProfile(name: profile);

    for (final entry in boolSettings.entries) {
      final (get, set) = entry.value;
      final defaultBefore = await get();
      final profileOriginal = await get(profileName: profile);
      try {
        for (final value in [!profileOriginal, profileOriginal]) {
          await set(value, profileName: profile);
          expect(
            await get(profileName: profile),
            value,
            reason: '${entry.key} did not read back as $value on $profile',
          );
          // The assertion that sees a dropped `profileName`: the write would land here instead.
          expect(
            await get(),
            defaultBefore,
            reason:
                'writing ${entry.key} on $profile changed the default profile',
          );
        }
      } finally {
        await set(profileOriginal, profileName: profile);
      }
    }

    final defaultMode = await ServiceWorkerController.getCacheMode();
    final profileMode = await ServiceWorkerController.getCacheMode(
      profileName: profile,
    );
    expect(
      profileMode,
      isNotNull,
      reason: 'the profile cache mode was unreadable',
    );
    // A mode the default profile is not in, so the isolation check below can fail.
    final probe = defaultMode == CacheMode.LOAD_NO_CACHE
        ? CacheMode.LOAD_CACHE_ELSE_NETWORK
        : CacheMode.LOAD_NO_CACHE;
    try {
      await ServiceWorkerController.setCacheMode(probe, profileName: profile);
      expect(
        await ServiceWorkerController.getCacheMode(profileName: profile),
        probe,
      );
      expect(
        await ServiceWorkerController.getCacheMode(),
        defaultMode,
        reason: 'writing cacheMode on $profile changed the default profile',
      );
    } finally {
      await ServiceWorkerController.setCacheMode(
        profileMode!,
        profileName: profile,
      );
    }
  }, skip: shouldSkip);
}
