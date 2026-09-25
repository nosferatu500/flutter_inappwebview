part of 'main.dart';

void fullscreenEvents() {
  // Android only: this is the only platform the values below were measured on (API 37). The
  // cross-platform fullscreen tests in video_playback_policy.dart don't run on Android at all: they
  // are gated on settings Android does not support (§189).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onEnterFullscreen,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // `requestFullscreen` needs a user gesture, so the page asks for it on a tap. Measured on API 37,
  // 2 of 2 probes: `onRequestFocus` fires just before `onEnterFullscreen`, because Chromium
  // activates the page to show it fullscreen. `exitFullscreen` needs no gesture (§192).
  skippableTestWidgets('fullscreen events', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> entered = Completer<void>();
    final Completer<void> exited = Completer<void>();
    final events = <String>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><div onclick="this.requestFullscreen()" '
                'style="height:100vh;background:#0a0">fullscreen</div></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onRequestFocus: (controller) {
            events.add('requestFocus');
          },
          onEnterFullscreen: (controller) {
            events.add('enter');
            if (!entered.isCompleted) entered.complete();
          },
          onExitFullscreen: (controller) {
            events.add('exit');
            if (!exited.isCompleted) exited.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.tapAt(Offset(size.width / 2, size.height / 2));

    try {
      await entered.future.timeout(const Duration(seconds: 10));
      expect(
        await controller.evaluateJavascript(
          source: '!!document.fullscreenElement',
        ),
        isTrue,
      );
    } finally {
      // Leave fullscreen even if an assertion above failed: the custom view sits on top of the
      // Flutter view and would cover every test after this one.
      await controller.evaluateJavascript(source: 'document.exitFullscreen();');
    }

    await exited.future.timeout(const Duration(seconds: 10));
    expect(events, ['requestFocus', 'enter', 'exit']);
  }, skip: shouldSkip);
}
