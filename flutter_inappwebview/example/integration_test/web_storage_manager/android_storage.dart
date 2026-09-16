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
    skippableTestWidgets('getOrigins is empty even with storage in use', (
      WidgetTester tester,
    ) async {
      // 🚨 **Measured, and it is the headline finding of this group.** `WebStorage.getOrigins()`
      // reports origins using the **Web SQL Database** API, which modern Chromium has removed --
      // `typeof openDatabase` is `"undefined"` on the API 37 WebView. So this returns an empty list
      // no matter how much storage a page actually uses.
      //
      // The probe behind this loaded the fixture, wrote **50 000 characters** into `localStorage`
      // (confirmed by reading it back in JS), waited 3 s, and still got `[]`.
      //
      // This is pinned rather than filed as a bug because it is the platform's behaviour, not the
      // plugin's -- but it means `getOrigins`, `getQuotaForOrigin` and `getUsageForOrigin` are
      // effectively dead API on a current WebView, which no unit test could ever reveal.
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
              if (!pageLoaded.isCompleted) pageLoaded.complete(url.toString());
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

      // The negative control for the assertion below: Web SQL is what getOrigins reports on, and it
      // no longer exists. Without this, an empty list would just look like a broken channel.
      final hasWebSql = await controller.evaluateJavascript(
        source: "(typeof openDatabase === 'function')",
      );
      expect(
        hasWebSql,
        isFalse,
        reason:
            'if a future WebView restores Web SQL, getOrigins may start reporting and this '
            'group needs revisiting',
      );

      expect(await manager.getOrigins(), isEmpty);
    }, skip: shouldSkip);

    skippableTest(
      'getQuotaForOrigin reports one global figure, not a per-origin one',
      () async {
        // 🚨 Measured: the same number comes back for every origin, including ones that have never
        // been visited and strings that are not origins at all. It is Chromium's global quota
        // estimate, which is what survives of an API designed around per-origin Web SQL quotas.
        //
        // The plugin is a pure pass-through, so this is documenting the platform -- but it is the
        // difference between "quota for this origin" (what the API name promises, and what
        // `PlatformWebStorageManager.getQuotaForOrigin`'s dartdoc repeats) and what a caller gets.
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

    skippableTest('getUsageForOrigin is zero because Web SQL is gone', () async {
      // Same root cause as getOrigins: usage is Web SQL usage, and there is none.
      final manager = WebStorageManager.instance();
      expect(await manager.getUsageForOrigin(origin: fixtureOrigin), 0);
    }, skip: shouldSkip);

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
