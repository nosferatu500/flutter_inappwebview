part of 'main.dart';

void muteAudio() {
  // Android only: `MUTE_AUDIO` is an androidx.webkit feature, and API 37 is the only platform the
  // values below were measured on.
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.setAudioMuted,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // The Dart unit test `mute_audio_test.dart` pins the wire shape over a mocked channel. This is
  // the platform half. Measured on API 37: not muted → muted → not muted, each read back from
  // `WebViewCompat.isAudioMuted` rather than from anything the plugin stores (§193).
  skippableTestWidgets('setAudioMuted / isAudioMuted', (
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
            data: '<!DOCTYPE html><html><body>audio</body></html>',
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

    expect(await controller.isAudioMuted(), isFalse);
    await controller.setAudioMuted(true);
    expect(await controller.isAudioMuted(), isTrue);
    await controller.setAudioMuted(false);
    expect(await controller.isAudioMuted(), isFalse);
  }, skip: shouldSkip);
}
