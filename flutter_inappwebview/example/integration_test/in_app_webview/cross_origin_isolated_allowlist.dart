part of 'main.dart';

/// Pins `androidx.webkit` 1.18.0's `CROSS_ORIGIN_ISOLATED_ALLOWLIST`, exposed as
/// [ProfileStore.setCrossOriginIsolatedAllowlist] / [ProfileStore.getCrossOriginIsolatedAllowlist].
///
/// The allowlist is **profile-scoped process state**, so every test clears it in a `finally`.
///
/// The effect test serves its page from `shouldInterceptRequest` rather than the fixture server, so
/// the `Document-Isolation-Policy` header is under the test's control. Its load-bearing assertion is
/// the pair: the same page reports `crossOriginIsolated == false` without the allowlist and `true`
/// with it. Either half alone would pass against a WebView that ignored the allowlist (or the header).
void crossOriginIsolatedAllowlist() {
  final shouldSkip = defaultTargetPlatform != TargetPlatform.android;

  Future<bool> available() async =>
      await WebViewFeature.isFeatureSupported(
        WebViewFeature.CROSS_ORIGIN_ISOLATED_ALLOWLIST,
      ) &&
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  skippableTestWidgets(
    'the cross-origin-isolated allowlist reads back, replaces and clears',
    (WidgetTester tester) async {
      if (!await available()) {
        markTestSkipped(
          'CROSS_ORIGIN_ISOLATED_ALLOWLIST or MULTI_PROFILE unsupported',
        );
        return;
      }
      const profile = 'crossOriginIsolatedTest';
      const missing = 'inappwebview_no_such_profile';
      final store = ProfileStore.instance();
      await store.getOrCreateProfile(name: profile);

      try {
        expect(
          await store.setCrossOriginIsolatedAllowlist({'https://a.test'}),
          isTrue,
        );
        // androidx documents the read-back with the port written out.
        expect(await store.getCrossOriginIsolatedAllowlist(), {
          'https://a.test:443',
        });

        // A second set replaces rather than adds.
        expect(
          await store.setCrossOriginIsolatedAllowlist({
            'https://b.test',
            'http://c.test:8080',
          }),
          isTrue,
        );
        expect(await store.getCrossOriginIsolatedAllowlist(), {
          'https://b.test:443',
          'http://c.test:8080',
        });

        // Profile-scoped: the named profile doesn't see the default profile's list.
        expect(
          await store.getCrossOriginIsolatedAllowlist(profileName: profile),
          isEmpty,
        );

        // An empty set clears.
        expect(await store.setCrossOriginIsolatedAllowlist(const {}), isTrue);
        final cleared = await store.getCrossOriginIsolatedAllowlist();
        expect(cleared, isNotNull);
        expect(cleared, isEmpty);

        // A profile that doesn't exist: `false` and `null`, not `true` and `{}`.
        expect(
          await store.setCrossOriginIsolatedAllowlist({
            'https://a.test',
          }, profileName: missing),
          isFalse,
        );
        expect(
          await store.getCrossOriginIsolatedAllowlist(profileName: missing),
          isNull,
        );
      } finally {
        await store.setCrossOriginIsolatedAllowlist(const {});
        await store.setCrossOriginIsolatedAllowlist(
          const {},
          profileName: profile,
        );
      }
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'an unparsable rule throws PlatformException(ProfileStoreManager)',
    (WidgetTester tester) async {
      if (!await available()) {
        markTestSkipped(
          'CROSS_ORIGIN_ISOLATED_ALLOWLIST or MULTI_PROFILE unsupported',
        );
        return;
      }
      final store = ProfileStore.instance();
      try {
        await expectLater(
          store.setCrossOriginIsolatedAllowlist({'not an origin rule'}),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'ProfileStoreManager',
            ),
          ),
        );
      } finally {
        await store.setCrossOriginIsolatedAllowlist(const {});
      }
    },
    skip: shouldSkip,
  );

  skippableTestWidgets(
    'the allowlist makes a Document-Isolation-Policy page cross-origin isolated',
    (WidgetTester tester) async {
      if (!await available()) {
        markTestSkipped(
          'CROSS_ORIGIN_ISOLATED_ALLOWLIST or MULTI_PROFILE unsupported',
        );
        return;
      }
      const origin = 'https://coi.inappwebview.test';
      final store = ProfileStore.instance();
      await store.setCrossOriginIsolatedAllowlist(const {});

      final page = WebResourceResponse(
        contentType: 'text/html',
        contentEncoding: 'utf-8',
        data: Uint8List.fromList(
          utf8.encode('<html><body>isolated?</body></html>'),
        ),
        statusCode: 200,
        reasonPhrase: 'OK',
        headers: {'Document-Isolation-Policy': 'isolate-and-require-corp'},
      );

      InAppWebViewController? controller;
      var loaded = Completer<void>();

      Future<Map<String, Object?>> loadAndProbe() async {
        loaded = Completer<void>();
        await controller!.loadUrl(
          urlRequest: URLRequest(url: WebUri('$origin/')),
        );
        await loaded.future.timeout(const Duration(seconds: 30));
        final isolated = await controller!.evaluateJavascript(
          source: 'self.crossOriginIsolated',
        );
        final sab = await controller!.evaluateJavascript(
          source: 'typeof SharedArrayBuffer',
        );
        return {'crossOriginIsolated': isolated, 'SharedArrayBuffer': sab};
      }

      try {
        final created = Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialSettings: InAppWebViewSettings(
                useShouldInterceptRequest: true,
              ),
              onWebViewCreated: (c) {
                controller = c;
                created.complete();
              },
              onLoadStop: (c, url) {
                if (url?.host == 'coi.inappwebview.test' &&
                    !loaded.isCompleted) {
                  loaded.complete();
                }
              },
              shouldInterceptRequest: (c, request) async =>
                  request.url.host == 'coi.inappwebview.test' ? page : null,
            ),
          ),
        );
        await created.future.timeout(const Duration(seconds: 30));

        final without = await loadAndProbe();
        expect(
          without['crossOriginIsolated'],
          isFalse,
          reason:
              'the control: without the allowlist WebView does not isolate the page '
              '(probe: $without)',
        );

        expect(await store.setCrossOriginIsolatedAllowlist({origin}), isTrue);
        final withList = await loadAndProbe();
        expect(
          withList['crossOriginIsolated'],
          isTrue,
          reason:
              'an allowlisted origin sending Document-Isolation-Policy was not isolated '
              '(probe: $withList)',
        );
        expect(withList['SharedArrayBuffer'], 'function');
      } finally {
        await store.setCrossOriginIsolatedAllowlist(const {});
      }
    },
    skip: shouldSkip,
  );
}
