part of 'main.dart';

/// A malformed proxy rule must fail as a **named error**, not as a dead channel (§171).
///
/// `ProxyConfig.Builder`'s `addProxyRule`, `addBypassRule`, `addDirect` and `build` all validate
/// their arguments and throw `IllegalArgumentException`, and all of them run **synchronously**
/// inside `setProxyOverride`, which is an `@async` Pigeon host method.
///
/// That combination is the bug §170 first found in `MyWebStorage.deleteBrowsingDataForSite` and
/// §171's audit found again here. Pigeon's generated handlers are not symmetric:
///
///   * synchronous → `val wrapped = try { listOf(api.foo(…)) } catch (e: Throwable) { wrapError(e) }`
///   * `@async`    → `api.foo(…) { result -> … }`, with **no `try`/`catch` anywhere**
///
/// so a synchronous throw escapes the message handler, **no reply is ever sent**, and the caller
/// gets `PlatformException(channel-error, "Unable to establish connection on channel…")` — an error
/// naming the transport rather than the rule that caused it, leaving the handler dangling.
///
/// Every input below was measured producing `channel-error` against the unfixed code. They are kept
/// as a set rather than reduced to one because they enter through three different builder methods,
/// and a fix that guarded only the rule loop would still pass with a single `addProxyRule` case.
///
/// Android only. The test checks androidx's validation and the Pigeon error path, and on iOS it
/// failed before reaching either, calling the Android-only `WebViewFeature.isFeatureSupported`
/// (`UnimplementedError`). iOS has its own test below: it used to return normally for every rule it
/// couldn't parse, dropping it (measured §287); since §303 it throws the same named error.
void malformedRules() {
  final shouldSkip =
      defaultTargetPlatform != TargetPlatform.android ||
      !ProxyController.isMethodSupported(
        PlatformProxyControllerMethod.setProxyOverride,
      );

  /// The failure a caller should see: something that names the plugin, with a message.
  final Matcher failsWithNamedError = throwsA(
    isA<PlatformException>()
        .having((e) => e.code, 'code', isNot('channel-error'))
        .having((e) => e.code, 'code', 'ProxyManager')
        .having((e) => e.message, 'message', isNotNull),
  );

  skippableTestWidgets('a malformed proxy rule fails as a named error', (
    WidgetTester tester,
  ) async {
    if (!await WebViewFeature.isFeatureSupported(
      WebViewFeature.PROXY_OVERRIDE,
    )) {
      markTestSkipped('PROXY_OVERRIDE unsupported');
      return;
    }
    final proxyController = ProxyController.instance();

    // Four rules the platform rejects. `"not a url"` is deliberately absent: androidx **accepts**
    // it, which is the negative control showing these four fail on their own merits rather than
    // because any non-URL string does.
    for (final rule in <String>['://', 'http://[', '%%%', '']) {
      await expectLater(
        proxyController.setProxyOverride(
          settings: ProxySettings(proxyRules: [ProxyRule(url: rule)]),
        ),
        failsWithNamedError,
        reason: 'addProxyRule("$rule")',
      );
    }

    await expectLater(
      proxyController.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: 'http://127.0.0.1:8080')],
          bypassRules: const [' '],
        ),
      ),
      failsWithNamedError,
      reason: 'addBypassRule(" ")',
    );

    await expectLater(
      proxyController.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: 'http://127.0.0.1:8080')],
          directs: const ['bogus'],
        ),
      ),
      failsWithNamedError,
      reason: 'addDirect("bogus")',
    );

    // The negative control, and the reason the list above is what it is: androidx accepts this one,
    // so a fix that simply rejected everything would fail here.
    await expectLater(
      proxyController.setProxyOverride(
        settings: ProxySettings(proxyRules: [ProxyRule(url: 'not a url')]),
      ),
      completes,
      reason: 'androidx accepts this, so the guard must not reject it',
    );

    // And the channel is still alive afterwards — the point of the fix is that the handler is not
    // left dangling by the throw.
    await expectLater(proxyController.clearProxyOverride(), completes);
  }, skip: shouldSkip);

  // iOS: a rule that can't be parsed fails the call, and the override in force stays (§303). It used
  // to be dropped, the call returning normally; with every rule dropped the override became empty
  // and traffic went direct. The override is seen through traffic: a proxy nobody listens on makes a
  // page fail, and only a kept override keeps it failing. Measured first (§303): the LAN fixture
  // bypasses the proxy, and a host already reached keeps its route after a change, so each check
  // loads a public host this test hasn't reached (the control needs the internet). The mixed call
  // comes first, so the last failed call has no rule that parses. iOS 26 and later only: iOS 17
  // doesn't send cleartext HTTP through the proxy (§135).
  final iosMajor = iosMajorVersion();
  skippableTestWidgets(
    'iOS: a proxy rule that can\'t be parsed fails and keeps the override',
    (WidgetTester tester) async {
      final deadline = TestDeadline();
      final proxyController = ProxyController.instance();
      final events = <String>[];
      final controllerCompleter = Completer<InAppWebViewController>();
      await deadline.frame(
        'mounting the WebView',
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(data: 'start'),
              onWebViewCreated: (c) => controllerCompleter.complete(c),
              onLoadStop: (c, url) => events.add('stop $url'),
              onReceivedError: (c, request, error) =>
                  events.add('error ${request.url}'),
            ),
          ),
        ),
      );
      final controller = await deadline.step(
        'onWebViewCreated',
        controllerCompleter.future,
      );
      await deadline.until(
        'the initial load',
        () => events.any((e) => e.startsWith('stop')),
      );

      // Loads [page] and says how it ended: 'stop' or 'error'.
      Future<String> load(String why, WebUri page) async {
        final before = events.length;
        await deadline.step(
          'loadUrl ($why)',
          controller.loadUrl(urlRequest: URLRequest(url: page)),
        );
        await deadline.until(
          '$page ending ($why)',
          () => events.skip(before).any((e) => e.contains('$page')),
          state: () => 'events: $events',
        );
        return events
            .skip(before)
            .firstWhere((e) => e.contains('$page'))
            .split(' ')
            .first;
      }

      try {
        await deadline.step(
          'clearProxyOverride',
          proxyController.clearProxyOverride(),
        );
        await deadline.step(
          'setProxyOverride to a closed port',
          proxyController.setProxyOverride(
            settings: ProxySettings(
              proxyRules: [ProxyRule(url: 'http://127.0.0.1:9')],
            ),
          ),
        );
        expect(
          await load(
            'through the closed proxy',
            WebUri('http://www.example.org/'),
          ),
          'error',
          reason: 'the precondition: the override is in force',
        );

        final failures = <String, Object?>{};
        for (final rules in <List<String>>[
          ['http://127.0.0.1:8080', '://'],
          ['://'],
          ['http://['],
          ['%%%'],
          [''],
        ]) {
          Object? thrown;
          try {
            await deadline.step(
              'setProxyOverride($rules)',
              proxyController.setProxyOverride(
                settings: ProxySettings(
                  proxyRules: [for (final url in rules) ProxyRule(url: url)],
                ),
              ),
            );
          } catch (e) {
            thrown = e;
          }
          failures['$rules'] = thrown is PlatformException
              ? thrown.code
              : thrown;
        }
        expect(failures, {
          '[://]': 'ProxyManager',
          '[http://[]': 'ProxyManager',
          '[%%%]': 'ProxyManager',
          '[]': 'ProxyManager',
          '[http://127.0.0.1:8080, ://]': 'ProxyManager',
        });
        expect(
          await load(
            'after the failed calls',
            WebUri('http://www.example.net/'),
          ),
          'error',
          reason: 'the failed calls must leave the override in force',
        );
      } finally {
        await deadline.step(
          'clearProxyOverride',
          proxyController.clearProxyOverride(),
        );
      }
      expect(
        await load('with the override cleared', WebUri('http://example.com/')),
        'stop',
        reason: 'the control: the page loads without a proxy',
      );
    },
    skip:
        defaultTargetPlatform != TargetPlatform.iOS ||
        iosMajor == null ||
        iosMajor < 26,
  );
}
