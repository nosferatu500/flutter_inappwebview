part of 'main.dart';

/// Pins `androidx.webkit`'s `CUSTOM_REQUEST_HEADERS` (§127), exposed as the custom-header family on
/// [ProfileStore].
///
/// These headers are **profile-scoped process state**, not per-request: once added they ride every
/// matching request the profile makes until cleared. Every test here therefore clears in a
/// `finally`, because a leaked header would travel into unrelated tests further down the group and
/// show up as a mystery header on somebody else's fixture request.
///
/// The load-bearing assertion is the *pair*: one header whose origin rule matches the page being
/// loaded and one whose rule does not. A single-header test would pass against an implementation
/// that ignored the rules entirely and sent everything.
void customRequestHeaders() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  Future<bool> available() async =>
      await WebViewFeature.isFeatureSupported(
        WebViewFeature.CUSTOM_REQUEST_HEADERS,
      ) &&
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  skippableTestWidgets('custom headers are sent only to matching origins', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('CUSTOM_REQUEST_HEADERS or MULTI_PROFILE unsupported');
      return;
    }

    final store = ProfileStore.instance();
    final origin = 'http://${environment['NODE_SERVER_IP']}:8082';
    await store.clearAllCustomHeaders();

    try {
      await store.addCustomHeader(
        CustomHeader(
          name: 'X-Matching-Rule',
          value: 'sent',
          originRules: {origin},
        ),
      );
      // Same profile, same moment — only the rule differs. This is the control.
      await store.addCustomHeader(
        CustomHeader(
          name: 'X-Other-Origin',
          value: 'not-sent',
          originRules: {'https://never.example.test'},
        ),
      );

      String? matching;
      String? other;
      final Completer<void> loaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(origin)),
            initialSettings: InAppWebViewSettings(
              useShouldInterceptRequest: true,
            ),
            onLoadStop: (c, url) {
              if (!loaded.isCompleted) loaded.complete();
            },
            shouldInterceptRequest: (controller, request) async {
              if (request.url.path == '/' && matching == null) {
                String? header(String name) => request.headers?.entries
                    .where((e) => e.key.toLowerCase() == name)
                    .map((e) => e.value)
                    .firstOrNull;
                matching = header('x-matching-rule') ?? '';
                other = header('x-other-origin') ?? '';
              }
              return null;
            },
          ),
        ),
      );
      await loaded.future.timeout(const Duration(seconds: 30));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      expect(
        matching,
        'sent',
        reason:
            'a header whose origin rule matches the loaded origin did not reach the request',
      );
      expect(
        other,
        isEmpty,
        reason:
            'a header scoped to a different origin was sent anyway, so the rules are not applied',
      );
    } finally {
      await store.clearAllCustomHeaders();
    }
  }, skip: shouldSkip);

  skippableTestWidgets('the header family reads back and clears selectively', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('CUSTOM_REQUEST_HEADERS or MULTI_PROFILE unsupported');
      return;
    }

    final store = ProfileStore.instance();
    await store.clearAllCustomHeaders();

    try {
      // Two values under one name, which is the case the filtered overloads exist for and the one
      // a Dart-side `where` would get wrong: androidx matches the name case-insensitively and the
      // value case-sensitively.
      await store.addCustomHeader(
        CustomHeader(name: 'X-Multi', value: 'one', originRules: {'*'}),
      );
      await store.addCustomHeader(
        CustomHeader(name: 'X-Multi', value: 'two', originRules: {'*'}),
      );
      await store.addCustomHeader(
        CustomHeader(name: 'X-Single', value: 'only', originRules: {'*'}),
      );

      expect(await store.hasCustomHeader('X-Multi'), isTrue);
      expect(
        await store.hasCustomHeader('x-multi'),
        isTrue,
        reason: 'header names are documented as case-insensitive',
      );
      expect(await store.hasCustomHeader('X-Absent'), isFalse);

      final all = await store.getCustomHeaders();
      expect(all.map((h) => '${h.name}=${h.value}').toSet(), {
        'X-Multi=one',
        'X-Multi=two',
        'X-Single=only',
      });
      expect(
        all.first.originRules,
        isNotEmpty,
        reason: 'origin rules must survive the round trip, not just name/value',
      );

      expect(
        (await store.getCustomHeaders(
          headerName: 'X-Multi',
        )).map((h) => h.value).toSet(),
        {'one', 'two'},
      );
      expect(
        (await store.getCustomHeaders(
          headerName: 'X-Multi',
          headerValue: 'two',
        )).map((h) => h.value).toSet(),
        {'two'},
      );

      // Clearing one value must leave its namesake alone — the whole point of the two-argument
      // overload, and the assertion that fails if the Kotlin picks the wrong one.
      await store.clearCustomHeader('X-Multi', headerValue: 'one');
      expect(
        (await store.getCustomHeaders(
          headerName: 'X-Multi',
        )).map((h) => h.value).toSet(),
        {'two'},
        reason:
            'clearing one value removed more (or fewer) headers than it should',
      );

      await store.clearCustomHeader('X-Multi');
      expect(await store.hasCustomHeader('X-Multi'), isFalse);
      expect(
        await store.hasCustomHeader('X-Single'),
        isTrue,
        reason: 'clearing one name removed an unrelated header',
      );

      await store.clearAllCustomHeaders();
      expect(await store.getCustomHeaders(), isEmpty);
    } finally {
      await store.clearAllCustomHeaders();
    }
  }, skip: shouldSkip);

  skippableTestWidgets('named profiles keep their own headers', (
    WidgetTester tester,
  ) async {
    if (!await available()) {
      markTestSkipped('CUSTOM_REQUEST_HEADERS or MULTI_PROFILE unsupported');
      return;
    }

    // Unlike the service-worker cookie switch (§126), this family IS reachable for a named
    // profile — it lives on androidx's own Profile interface rather than on the framework class.
    // Asserted both ways: the named profile has it, and the default profile does not see it.
    const profile = 'customHeaderProfileTest';
    final store = ProfileStore.instance();
    await store.getOrCreateProfile(name: profile);
    await store.clearAllCustomHeaders();
    await store.clearAllCustomHeaders(profileName: profile);

    try {
      await store.addCustomHeader(
        CustomHeader(name: 'X-Scoped', value: 'v', originRules: {'*'}),
        profileName: profile,
      );

      expect(
        await store.hasCustomHeader('X-Scoped', profileName: profile),
        isTrue,
      );
      expect(
        await store.hasCustomHeader('X-Scoped'),
        isFalse,
        reason: 'a header added to a named profile leaked into the default one',
      );
    } finally {
      await store.clearAllCustomHeaders(profileName: profile);
      await store.clearAllCustomHeaders();
    }
  }, skip: shouldSkip);
}
