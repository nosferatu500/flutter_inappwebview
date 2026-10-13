part of 'main.dart';

/// Pins the Service Worker half of `COOKIE_INTERCEPT` (§126) —
/// `setIncludeCookiesOnShouldInterceptRequestEnabled` / `get…`.
///
/// **What this does not test, and why.** The *effect* of the switch — a `Cookie` header on a
/// request intercepted for a Service Worker, and [WebResourceResponse.cookies] applied to the
/// response — cannot be exercised in this harness. A Service Worker only registers in a secure
/// context, and the fixture server is reached over a LAN `http://` address, which is not one;
/// the group's other test therefore uses a third-party `https://` site, where cookies are neither
/// ours to set nor stable to assert on. The `WebView` half of the same flag *is* measured end to
/// end in `in_app_webview/cookie_intercept.dart`, and both halves share one Kotlin path for the
/// response, so what is untested here is the platform's behaviour rather than the plugin's wiring.
///
/// What is left is still worth pinning, and one part of it is a genuine platform asymmetry.
void serviceWorkerIncludeCookies() {
  final shouldSkip = !ServiceWorkerController.isMethodSupported(
    PlatformServiceWorkerControllerMethod
        .setIncludeCookiesOnShouldInterceptRequestEnabled,
  );

  skippableTestWidgets('include cookies on intercepted requests round-trips', (
    WidgetTester tester,
  ) async {
    if (!await WebViewFeature.isFeatureSupported(
      WebViewFeature.COOKIE_INTERCEPT,
    )) {
      markTestSkipped('COOKIE_INTERCEPT unsupported on this WebView');
      return;
    }

    // The platform default, before anything is written. androidx documents none; measured off on
    // WebView 149 and 151. Asserted as a real `false` rather than `isNull`, because `null` here
    // would mean "unreachable" and would make every assertion below vacuous.
    expect(
      await ServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled(),
      isFalse,
      reason:
          'expected the default-profile switch to start off and be readable',
    );

    try {
      // Both directions, and back again: a setter that only ever wrote `true` would pass a
      // one-way test.
      for (final value in [true, false, true]) {
        await ServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled(
          value,
        );
        expect(
          await ServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled(),
          value,
          reason: 'the switch did not read back as $value',
        );
      }
    } finally {
      // Process-global state: leave it off, or every later test in the run inherits it.
      await ServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled(
        false,
      );
    }
  }, skip: shouldSkip);

  skippableTestWidgets('the switch is unavailable for a named profile', (
    WidgetTester tester,
  ) async {
    if (!await WebViewFeature.isFeatureSupported(
          WebViewFeature.COOKIE_INTERCEPT,
        ) ||
        !await WebViewFeature.isFeatureSupported(
          WebViewFeature.MULTI_PROFILE,
        )) {
      markTestSkipped('COOKIE_INTERCEPT or MULTI_PROFILE unsupported');
      return;
    }

    // Structural, not versioned. The cookie-intercept API exists only on androidx's
    // ServiceWorkerWebSettingsCompat, and a named profile's Service Worker settings are reachable
    // only through the framework's android.webkit.ServiceWorkerWebSettings — which declares
    // exactly the four older settings and nothing else (checked against android.jar). So no
    // future WebView opens this: there is nothing to call.
    const profile = 'cookieInterceptProfileTest';
    await ProfileStore.instance().getOrCreateProfile(name: profile);

    expect(
      await ServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled(
        profileName: profile,
      ),
      isNull,
      reason: 'a named profile cannot reach the cookie-intercept switch',
    );

    // The control that makes the null above mean something: a setting the framework API *does*
    // have must answer non-null for the very same profile. Without this, the null is equally
    // explained by the profile being unreachable, which would be a different bug.
    expect(
      await ServiceWorkerController.getAllowContentAccess(profileName: profile),
      isNotNull,
      reason:
          'the profile itself is unreachable, so the null above proves nothing',
    );

    // And the setter is a no-op rather than a silent write somewhere else.
    await ServiceWorkerController.setIncludeCookiesOnShouldInterceptRequestEnabled(
      true,
      profileName: profile,
    );
    expect(
      await ServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled(
        profileName: profile,
      ),
      isNull,
      reason: 'setting it on a named profile should stay unavailable',
    );

    // It must also not have leaked onto the default profile.
    expect(
      await ServiceWorkerController.getIncludeCookiesOnShouldInterceptRequestEnabled(),
      isFalse,
      reason:
          'a write scoped to a named profile changed the default profile instead',
    );
  }, skip: shouldSkip);
}
