part of 'main.dart';

/// Pins the two bounds [PlatformInAppWebViewController.saveState] gained in §124 —
/// `maxSize` and `includeForwardState`, both backed by `WebViewCompat.saveState` and both
/// Android-only.
///
/// **Nothing here asserts an absolute byte count.** The state's size depends on the WebView build
/// (API 33 ships WebView 151 here, API 37 ships 149) and on how Chromium encodes a history entry,
/// so every assertion is relative to an unbounded save taken in the same run on the same WebView.
/// Trap 63: a number that is true on one AVD and false on the other is an assertion about the
/// platform's internals, not about this feature.
///
/// The unbounded call is deliberately the *first* thing measured, and is the control for the rest:
/// with no arguments the plugin still uses the framework `WebView.saveState`, which needs no
/// feature and which the compat API was measured to reproduce byte-for-byte.
void saveStateBounds() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.saveState,
  );

  // Android-only arguments, and gated on a feature the WebView may not have.
  Future<bool> boundsAvailable() async =>
      defaultTargetPlatform == TargetPlatform.android &&
      await WebViewFeature.isFeatureSupported(WebViewFeature.SAVE_STATE);

  /// Builds a WebView with [entries] fat history entries and leaves the cursor in the middle, so
  /// there is both back and forward history to bound.
  ///
  /// Each page is a `data:` URL padded to ~40 KB: the padding is what makes one dropped entry a
  /// difference of tens of thousands of bytes rather than of a handful, i.e. far above any
  /// encoding noise. No fixture server is involved, so this test cannot fail for network reasons.
  Future<InAppWebViewController> buildHistory(
    WidgetTester tester,
    int entries,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    var loads = <String>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: WebUri('about:blank')),
          onWebViewCreated: (c) => controllerCompleter.complete(c),
          onLoadStop: (c, url) => loads.add('$url'),
        ),
      ),
    );
    final controller = await controllerCompleter.future;
    await tester.pump();

    final pad = 'A' * 40000;
    for (var i = 1; i <= entries; i++) {
      // Wait for THIS navigation, not for "a" navigation. Waiting on any onLoadStop let the
      // initial about:blank's late event satisfy the wait for page 1, so page 2 was issued before
      // page 1 had committed and replaced it instead of pushing — the source ended up with one
      // history entry, and the failure surfaced two steps later as "the restore lost an entry".
      // 1 run in ~12 on API 33. Trap 60: a url (or a bare event) does not identify a navigation.
      //
      // The marker is plain letters and digits so it survives percent-encoding of the data: URL
      // unchanged, and is suffixed so `SSMARK1X` cannot prefix-match `SSMARK11X`.
      final marker = 'SSMARK${i}X';
      loads = <String>[];
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(
            'data:text/html,<title>p$i</title><!--$marker--><!--$pad-->',
          ),
        ),
      );
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!loads.any((u) => u.contains(marker)) &&
          DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      expect(
        loads.any((u) => u.contains(marker)),
        isTrue,
        reason: 'navigation $i of $entries never finished loading',
      );
    }
    return controller;
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  skippableTestWidgets('saveState maxSize and includeForwardState', (
    WidgetTester tester,
  ) async {
    final controller = await buildHistory(tester, 6);

    // Step back so there is forward history for includeForwardState to drop.
    await controller.goBack();
    await settle(tester);
    await controller.goBack();
    await settle(tester);

    final history = await controller.getCopyBackForwardList();
    expect(
      history?.currentIndex,
      isNotNull,
      reason: 'no back/forward list to bound',
    );
    expect(
      history!.currentIndex! > 0 &&
          history.currentIndex! < history.list!.length - 1,
      isTrue,
      reason:
          'the cursor must sit between entries for this test to mean anything; '
          'got index ${history.currentIndex} of ${history.list!.length}',
    );

    // Control, and the baseline every other number is relative to.
    final unbounded = await controller.saveState();
    expect(
      unbounded,
      isNotNull,
      reason: 'an unbounded saveState() must work on every platform',
    );

    if (!await boundsAvailable()) {
      // Still worth asserting on iOS and on any Android WebView without SAVE_STATE: the arguments
      // must never quietly hand back an unconstrained state.
      if (defaultTargetPlatform == TargetPlatform.android) {
        expect(
          await controller.saveState(maxSize: 1024),
          isNull,
          reason:
              'without SAVE_STATE a bounded request must return null, not an unbounded state',
        );
      }
      return;
    }

    // --- includeForwardState. Same WebView, same instant, one argument apart.
    final withForward = await controller.saveState(includeForwardState: true);
    final withoutForward = await controller.saveState(
      includeForwardState: false,
    );
    expect(withForward, isNotNull);
    expect(withoutForward, isNotNull);
    expect(
      withoutForward!.length,
      lessThan(withForward!.length),
      reason:
          'includeForwardState: false must drop the entries ahead of the cursor '
          '(${withoutForward.length} vs ${withForward.length} bytes)',
    );

    // --- maxSize. Derived from the measured unbounded size rather than hardcoded, so this holds
    // whatever a given WebView build charges per entry.
    final half = unbounded!.length ~/ 2;
    final capped = await controller.saveState(maxSize: half);
    expect(
      capped,
      isNotNull,
      reason:
          'half of the unbounded size must still fit several entries; got null at maxSize=$half',
    );
    expect(
      capped!.length,
      lessThan(unbounded.length),
      reason:
          'maxSize did not reduce the state (${capped.length} vs ${unbounded.length} bytes)',
    );
    // NOT `lessThanOrEqualTo(half)`. `maxSize` bounds the WebView's own serialized state, and what
    // comes back to Dart is that state inside a marshalled Bundle, so the array can be slightly
    // larger than the cap — measured on API 33 at 602900 bytes against a requested 602860, i.e.
    // 40 bytes over. It only shows when the truncation happens to land just under the cap instead
    // of well under it, which is why it took several runs to appear (1 run in 6).
    const framingAllowance = 4096;
    expect(
      capped.length,
      lessThanOrEqualTo(half + framingAllowance),
      reason:
          'the state overshot maxSize=$half by more than the Bundle framing allowance '
          '(${capped.length} bytes)',
    );

    // --- The sharp edge: below one entry's own size nothing is saved at all. A partial state is
    // not returned and nothing throws — measured, and the reason the Kotlin reads the result off
    // the Bundle instead of trusting the void return.
    expect(
      await controller.saveState(maxSize: 1),
      isNull,
      reason:
          'maxSize below a single entry must return null rather than a truncated or unbounded state',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('an unbounded saveState still round-trips', (
    WidgetTester tester,
  ) async {
    // The characterisation half: the arguments are additive and the no-argument call must behave
    // exactly as it did before them. Proved red by making the Kotlin route the unconstrained case
    // through WebViewCompat with SAVE_STATE unavailable, which returns null here.
    final controller = await buildHistory(tester, 2);
    final sourceList = await controller.getCopyBackForwardList();
    final sourceTitled =
        sourceList?.list?.where((e) => '${e.url}'.contains('title')).length ??
        0;
    final state = await controller.saveState();
    expect(state, isNotNull);

    // **No `initialUrlRequest`.** [PlatformInAppWebViewController.restoreState] documents that
    // restoring into a WebView which "has had a chance to build state" has undesirable
    // side-effects, and this test was quietly violating that: with an `about:blank` initial load
    // racing the restore, one run in twelve came back with a single history entry instead of two.
    // The destination must be empty, which is also how a real state-restore is done.
    final Completer<InAppWebViewController> restoredCompleter =
        Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          onWebViewCreated: (c) => restoredCompleter.complete(c),
        ),
      ),
    );
    final restored = await restoredCompleter.future;
    await tester.pump();
    await settle(tester);

    expect(await restored.restoreState(state!), isTrue);

    // Poll rather than sample once. `restoreState` returning true only means the Bundle was
    // accepted; the back/forward list is repopulated on the platform's own schedule, and a single
    // read after a fixed settle saw 1 entry instead of 2 on one run out of several (trap 66 — the
    // flake showed up under a mutant that could not possibly have affected this path, which is what
    // identified it as the test's own timing rather than the change's).
    var entries = 0;
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (entries < 2 && DateTime.now().isBefore(deadline)) {
      await settle(tester);
      final list = await restored.getCopyBackForwardList();
      entries =
          list?.list?.where((e) => '${e.url}'.contains('title')).length ?? 0;
    }
    expect(
      entries,
      greaterThanOrEqualTo(2),
      reason:
          'the restored WebView lost the saved history entries '
          '(source had $sourceTitled, restored had $entries)',
    );
  }, skip: shouldSkip);
}
