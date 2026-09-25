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
}
