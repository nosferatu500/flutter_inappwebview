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
void malformedRules() {
  final shouldSkip = !ProxyController.isMethodSupported(
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
}
