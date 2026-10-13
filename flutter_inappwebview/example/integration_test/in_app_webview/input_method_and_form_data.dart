part of 'main.dart';

void inputMethodAndFormData() {
  // Android only: this is the only platform these were run on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.showInputMethod,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // 🚨 ROUTING ONLY: these tests prove the call reaches a handler and comes back, and nothing more.
  // A handler that is missing or misrouted throws and fails them. A handler that replies without
  // doing anything passes them.
  //
  // Why nothing more (§193): the test AVD has a hardware keyboard and `show_ime_with_hard_keyboard`
  // = 0, so Android never shows the soft keyboard. `showInputMethod` left the insets at 0, and so
  // did tapping an input. `clearFormData` only dismisses an autocomplete popup, which a test cannot
  // produce. An emulator configured to show the soft keyboard would make the first pair observable
  // through `MediaQuery.viewInsets`.
  skippableTestWidgets('showInputMethod / hideInputMethod / clearFormData', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body><input id="field"></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await expectLater(controller.showInputMethod(), completes);
    await expectLater(controller.hideInputMethod(), completes);
    await expectLater(controller.clearFormData(), completes);
  }, skip: shouldSkip);

  // The tap-outside-to-dismiss workaround in `InAppWebView.onCreateInputConnection` (§294). It
  // pins what users see: the keyboard stays up on the input, and a tap outside dismisses it.
  //
  // Needs a docked soft keyboard, which the test AVDs (hardware keyboard, see above) do not show
  // by default, so it skips once the input has focus and no keyboard inset arrived. Measured:
  // - API 33 (Pixel_7 AVD, `show_ime_with_hard_keyboard` = 1): the keyboard comes up on focus.
  // - API 37 (Pixel_10 AVD): needs `adb shell settings put secure show_ime_with_hard_keyboard 1`,
  //   then Alt+K (the emulator's Option+K) once the input has focus, sent by hand or with
  //   `adb shell input keycombination KEYCODE_ALT_LEFT KEYCODE_K`. A floating Gboard reports no
  //   inset, so it must be docked.
  //
  // What it can catch: on API 33 the keyboard is up before the workaround's 128 ms check, so
  // dropping its `isAcceptingText` guard fails the settled-inset expectation. On API 37 the
  // keyboard only comes up after the check, so that is a race. Deleting the workaround's hide does
  // not fail it on either: the keyboard is hidden without it.
  skippableTestWidgets(
    'tapping outside an input hides the soft keyboard without Hybrid Composition',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: '''
<!DOCTYPE html><html>
<head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
<body style="margin: 0">
<input id="field" style="display: block; width: 100%; height: 100px; box-sizing: border-box">
<div style="height: 400px"></div>
</body></html>''',
            ),
            initialSettings: InAppWebViewSettings(useHybridComposition: false),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      double keyboardInset() =>
          tester.binding.platformDispatcher.views.first.viewInsets.bottom;
      Future<String?> focusedId() async => (await controller.evaluateJavascript(
        source: 'document.activeElement.id',
      ))?.toString();
      // Bounded: returns the milliseconds it took, or null when [done] never held.
      Future<int?> waitFor(bool Function() done) async {
        final stopwatch = Stopwatch()..start();
        while (stopwatch.elapsedMilliseconds < 5000) {
          if (done()) return stopwatch.elapsedMilliseconds;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await tester.pump();
        }
        return null;
      }

      // A tap sent before a frame has been pumped since load is lost (§192).
      await _pumpFrames(tester);
      await tester.tapAt(const Offset(100, 50));
      await tester.pump();
      final bool shown = await waitFor(() => keyboardInset() > 0) != null;
      final String? focusedOnShow = await focusedId();
      expect(
        focusedOnShow,
        'field',
        reason:
            'the tap did not focus the input (keyboard inset ${keyboardInset()})',
      );
      if (!shown) {
        markTestSkipped('no docked soft keyboard came up (see the comment)');
        return;
      }
      // The first non-zero inset is read mid-animation; let it settle.
      await Future<void>.delayed(const Duration(seconds: 1));
      await tester.pump();
      final double shownInset = keyboardInset();
      expect(
        shownInset,
        greaterThan(0),
        reason:
            'the keyboard came up and went down again before the outside tap',
      );

      await tester.tapAt(const Offset(100, 300));
      await tester.pump();
      final int? hiddenAfter = await waitFor(() => keyboardInset() == 0);
      final String? focusedOnHide = await focusedId();
      expect(
        hiddenAfter,
        isNotNull,
        reason:
            'keyboard still up 5 s after tapping outside: inset ${keyboardInset()}, '
            'focused element "$focusedOnHide"',
      );
    },
    skip: shouldSkip,
  );
}
