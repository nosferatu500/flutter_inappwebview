part of 'main.dart';

/// The **Android** half of `WebStorageManager`, which had no device coverage at all until §170 —
/// this group was iOS-only, so on Android it ran zero tests and exited 79 (§158, re-measured in
/// §169).
///
/// That gap is why it exists. §169 migrated this channel to Pigeon with every static gate green and
/// no device run available to contradict them, and §168 had just demonstrated what that costs: an
/// invented `assert` that passed analyze, format, 45 Dart tests, the Kotlin compile, lint and ktlint,
/// and was caught by an integration test in six seconds.
///
/// **Most of what is asserted below was measured on a device first and contradicted what the code's
/// own documentation said.** Each such case says so at the assertion.
void androidStorage() {
  final shouldSkip =
      !WebStorageManager.isClassSupported() ||
      defaultTargetPlatform != TargetPlatform.android;

  // Every origin the tests use is a real http origin from the fixture server, because storage is
  // partitioned by origin and a `data:` URL has an opaque one.
  final fixtureOrigin = 'http://${environment['NODE_SERVER_IP']}:8082';

  skippableGroup('android storage', () {
    skippableTestWidgets(
      "getOrigins doesn't list an origin that only uses localStorage",
      (WidgetTester tester) async {
        // 🚨 **Measured.** `WebStorage.getOrigins()` lists origins holding quota-managed storage
        // (IndexedDB, Cache Storage, the origin-private file system, service workers; §308), not the
        // Web SQL its Android documentation names. `localStorage` doesn't count: the probe behind
        // this wrote **50 000 characters** into it (read back in JS), waited 3 s, and got `[]`.
        // The positive control, that it does list an origin using IndexedDB, is the test
        // `getOrigins and getUsageForOrigin count IndexedDB and Cache Storage…` below.
        final manager = WebStorageManager.instance();

        final controllerCompleter = Completer<InAppWebViewController>();
        final pageLoaded = Completer<String>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: WebUri('$fixtureOrigin/')),
              initialSettings: InAppWebViewSettings(
                databaseEnabled: true,
                domStorageEnabled: true,
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (controller, url) {
                if (!pageLoaded.isCompleted) {
                  pageLoaded.complete(url.toString());
                }
              },
            ),
          ),
        );

        final controller = await controllerCompleter.future;
        await pageLoaded.future;

        final written = await controller.evaluateJavascript(
          source:
              "(function(){localStorage.setItem('probe','x'.repeat(50000));"
              "return localStorage.getItem('probe').length;})();",
        );
        expect(
          written,
          50000,
          reason: 'the page really did store 50 000 characters',
        );

        final origins = await manager.getOrigins();
        expect(
          origins.map((o) => o.origin),
          isNot(anyElement(startsWith(fixtureOrigin))),
          reason:
              'localStorage alone should not make getOrigins list the origin: $origins',
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'getQuotaForOrigin reports one global figure, not a per-origin one',
      () async {
        // 🚨 Measured: the same number comes back for every origin, including ones that have never
        // been visited and strings that are not origins at all. It is Chromium's global quota
        // estimate, which is what survives of an API designed around per-origin Web SQL quotas.
        //
        // The plugin is a pure pass-through, so this is documenting the platform -- but it is the
        // difference between "quota for this origin" (what the API name promises) and what a caller
        // gets, which `PlatformWebStorageManager.getQuotaForOrigin`'s dartdoc now says (§308).
        final manager = WebStorageManager.instance();

        final visited = await manager.getQuotaForOrigin(origin: fixtureOrigin);
        final neverVisited = await manager.getQuotaForOrigin(
          origin: 'https://never-visited.invalid',
        );
        final notAnOrigin = await manager.getQuotaForOrigin(origin: 'garbage');

        expect(
          visited,
          greaterThan(0),
          reason: 'a resolvable store always answers the global quota',
        );
        expect(neverVisited, visited);
        expect(
          notAnOrigin,
          visited,
          reason:
              'the origin argument does not affect the answer -- pinning this so a future WebView '
              'that starts honouring it is noticed rather than assumed',
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'getUsageForOrigin is zero for an origin that only uses localStorage',
      () async {
        // Same reason as getOrigins: usage counts quota-managed storage only (§308), and the
        // fixture origin's only storage is the first test's localStorage.
        final manager = WebStorageManager.instance();
        expect(await manager.getUsageForOrigin(origin: fixtureOrigin), 0);
      },
      skip: shouldSkip,
    );

    // The positive control for the two tests above, and what `deleteOrigin` clears (§308, measured
    // on Android 17 / WebView 153): IndexedDB and Cache Storage both count, `deleteOrigin` clears the
    // IndexedDB and keeps the Cache Storage, so the origin stays listed. Both need a secure context
    // for Cache Storage, hence `InAppLocalhostServer` on 127.0.0.1.
    skippableTestWidgets(
      'getOrigins and getUsageForOrigin count IndexedDB and Cache Storage; '
      'deleteOrigin clears only the IndexedDB',
      (WidgetTester tester) async {
        final deadline = TestDeadline();
        final manager = WebStorageManager.instance();
        const origin = 'http://127.0.0.1:8080';
        final server = InAppLocalhostServer();
        await deadline.step('starting the localhost server', server.start());
        addTearDown(server.close);
        if (!await deadline.step(
          'deleteBrowsingData',
          manager.deleteBrowsingData(),
        )) {
          markTestSkipped(
            'needs DELETE_BROWSING_DATA to start from no storage',
          );
          return;
        }
        addTearDown(manager.deleteBrowsingData);
        Future<WebStorageOrigin?> listed() async => (await deadline.step(
          'getOrigins',
          manager.getOrigins(),
        )).where((o) => o.origin == '$origin/').firstOrNull;
        expect(
          await listed(),
          isNull,
          reason: 'the control: no storage after deleteBrowsingData',
        );

        final loaded = Completer<InAppWebViewController>();
        await deadline.frame(
          'mounting the WebView',
          tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView(
                key: GlobalKey(),
                initialUrlRequest: URLRequest(
                  url: WebUri('$origin/test_assets/page-1.html'),
                ),
                onLoadStop: (controller, url) {
                  if (!loaded.isCompleted) loaded.complete(controller);
                },
              ),
            ),
          ),
        );
        final controller = await deadline.step('the page load', loaded.future);
        Future<String?> js(String what, String body) async {
          final result = await deadline.step(
            what,
            controller.callAsyncJavaScript(functionBody: body),
          );
          return '${result?.value} ${result?.error}';
        }

        expect(
          await js('storing 50 000 characters in each', """
            const db = await new Promise((ok, ko) => {
              const r = indexedDB.open('zz', 1);
              r.onupgradeneeded = () => r.result.createObjectStore('s');
              r.onsuccess = () => ok(r.result); r.onerror = () => ko(r.error);
            });
            await new Promise((ok, ko) => {
              const t = db.transaction('s', 'readwrite');
              t.objectStore('s').put('x'.repeat(50000), 'k');
              t.oncomplete = ok; t.onerror = () => ko(t.error);
            });
            db.close();
            await (await caches.open('zz')).put('/zz', new Response('x'.repeat(50000)));
            return 'stored';"""),
          'stored null',
        );
        // Bounded polls: measured, the listing and usage were current within 1 s of each change.
        Future<WebStorageOrigin?> pollListed(
          bool Function(WebStorageOrigin? o) done,
        ) async {
          WebStorageOrigin? o = await listed();
          for (var i = 0; i < 10 && !done(o); i++) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            o = await listed();
          }
          return o;
        }

        final before = await pollListed((o) => o != null);
        expect(
          before,
          isNotNull,
          reason: 'IndexedDB and Cache Storage should make getOrigins list it',
        );
        final usage = await deadline.step(
          'getUsageForOrigin',
          manager.getUsageForOrigin(origin: origin),
        );
        expect(
          usage,
          greaterThan(100000),
          reason: 'both 50 000-character stores count toward the usage',
        );
        expect(
          before!.usage,
          usage,
          reason: 'the listing reports the same usage',
        );

        await deadline.step(
          'deleteOrigin',
          manager.deleteOrigin(origin: origin),
        );
        // deleteOrigin's future completes before Chromium has deleted anything (measured §308:
        // 0-1 ms, the usage dropping 4-17 ms later), and an IndexedDB call the page makes in
        // between can be lost: `indexedDB.databases()` never resolved in 1 of 10 tries (3 of 9
        // runs of this test before it waited). So wait for the usage to drop, then read back.
        final after = await pollListed(
          (o) => o != null && o.usage! < usage - 50000,
        );
        expect(
          after?.usage,
          allOf(greaterThan(50000), lessThan(usage - 50000)),
          reason:
              'still listed, with only the Cache Storage counted: before $usage, '
              'after ${after?.usage}',
        );
        expect(
          await js(
            'reading the IndexedDB back',
            "return (await indexedDB.databases()).some(d => d.name === 'zz');",
          ),
          'false null',
          reason: 'deleteOrigin clears the IndexedDB',
        );
        expect(
          await js(
            'reading the Cache Storage back',
            "return (await caches.keys()).includes('zz');",
          ),
          'true null',
          reason: 'deleteOrigin keeps the Cache Storage',
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'an unresolvable profile answers 0, which a real origin never does',
      () async {
        // The null-manager branch, and the one case where `0` is meaningful. Paired with the quota
        // test above, which shows a resolvable store always answers non-zero: that pairing is what
        // makes `0` diagnostic rather than ambiguous *in practice*, even though the type cannot say
        // so. `PlatformWebStorageManager.getQuotaForOrigin` returns `int`, not `int?`, which is the
        // TODO row §169 filed.
        final manager = WebStorageManager.instance();
        expect(
          await manager.getQuotaForOrigin(
            origin: fixtureOrigin,
            profileName: 'inappwebview_no_such_profile',
          ),
          0,
        );
        expect(
          await manager.getOrigins(profileName: 'inappwebview_no_such_profile'),
          isEmpty,
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'deleteAllData and deleteOrigin complete, answer discarded',
      () async {
        // Both are `Future<void>` while the host computes a bool -- §137's `flush` finding, filed by
        // §169. This pins that the unresolvable-profile case is *silent* rather than throwing, which
        // is the behaviour a caller currently gets and cannot distinguish from success.
        final manager = WebStorageManager.instance();
        await expectLater(manager.deleteAllData(), completes);
        await expectLater(
          manager.deleteOrigin(origin: fixtureOrigin),
          completes,
        );
        await expectLater(
          manager.deleteAllData(profileName: 'inappwebview_no_such_profile'),
          completes,
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'deleteBrowsingData reports true, and false for an unknown profile',
      () async {
        final manager = WebStorageManager.instance();
        if (!await WebViewFeature.isFeatureSupported(
          WebViewFeature.DELETE_BROWSING_DATA,
        )) {
          markTestSkipped('DELETE_BROWSING_DATA unsupported');
          return;
        }

        expect(await manager.deleteBrowsingData(), isTrue);
        // The null-manager branch again, and here the bool *is* surfaced.
        expect(
          await manager.deleteBrowsingData(
            profileName: 'inappwebview_no_such_profile',
          ),
          isFalse,
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'deleteBrowsingDataForSite answers the registrable domain',
      () async {
        final manager = WebStorageManager.instance();
        if (!await WebViewFeature.isFeatureSupported(
          WebViewFeature.DELETE_BROWSING_DATA,
        )) {
          markTestSkipped('DELETE_BROWSING_DATA unsupported');
          return;
        }

        // The one reply on this channel that is not an echo, measured: the platform strips the
        // subdomain. An implementation that returned its own argument would look correct everywhere
        // except here.
        expect(
          await manager.deleteBrowsingDataForSite(
            site: 'https://www.example.com',
          ),
          'example.com',
        );
        // An IP-literal host has no registrable domain to strip, and the port goes.
        expect(
          await manager.deleteBrowsingDataForSite(site: '$fixtureOrigin/'),
          environment['NODE_SERVER_IP'],
        );
      },
      skip: shouldSkip,
    );

    skippableTest(
      'an unparseable site fails as a named error, not a dead channel',
      () async {
        // 🚨 **Regression test for the bug this group was written to find (§170).**
        //
        // `WebStorageCompat.deleteBrowsingDataForSite` throws `IllegalArgumentException` for a site it
        // cannot parse. The pre-Pigeon handler caught it and answered
        // `result.error("MyWebStorage", message, null)`. §169's migration deleted that catch on the
        // stated grounds that "Pigeon reports it through `wrapError`" — which is **true for a
        // synchronous host method and false for an `@async` one**:
        //
        //   * sync  -> `val wrapped = try { listOf(api.foo()) } catch (e: Throwable) { wrapError(e) }`
        //   * async -> `api.foo(args) { result -> ... }`, with **no try/catch at all**
        //
        // So a synchronous throw inside an `@async` method escapes the handler, **no reply is ever
        // sent**, and the caller gets `PlatformException(channel-error, Unable to establish
        // connection on channel…)` — an error that names the transport rather than the cause, and
        // leaves the message handler dangling. Measured on a device; the boundary unit test could not
        // see it because it mocks the host and simulates the error envelope.
        //
        // The code is pinned because it is a deliberate choice, not an accident: the Kotlin raises a
        // `FlutterError("MyWebStorage", …)` rather than letting the raw exception through, because
        // `wrapError` would otherwise derive the code from `javaClass.simpleName` and make it depend
        // on which exception type androidx happens to raise. `isNot('channel-error')` is asserted
        // alongside it as the thing that actually regressed.
        final manager = WebStorageManager.instance();
        if (!await WebViewFeature.isFeatureSupported(
          WebViewFeature.DELETE_BROWSING_DATA,
        )) {
          markTestSkipped('DELETE_BROWSING_DATA unsupported');
          return;
        }

        // The empty string is the shortest input the platform rejects; " " and "::::" behave the same.
        await expectLater(
          manager.deleteBrowsingDataForSite(site: ''),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', isNot('channel-error'))
                .having((e) => e.code, 'code', 'MyWebStorage')
                .having((e) => e.message, 'message', isNotNull),
          ),
        );
      },
      skip: shouldSkip,
    );
  }, skip: shouldSkip);
}
