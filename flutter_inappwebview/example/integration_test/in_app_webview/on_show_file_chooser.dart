part of 'main.dart';

void onShowFileChooser() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onShowFileChooser,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // A file input only opens on a user gesture, so the test taps it. The input fills the page, so any
  // tap lands on it. Measured on API 37: mode OPEN, the `accept` list as written, no capture; and
  // answering "handled, no files" leaves the input empty (§192). The system picker is never shown,
  // because the handler answers.
  skippableTestWidgets('onShowFileChooser', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<ShowFileChooserRequest> chooser =
        Completer<ShowFileChooserRequest>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialSettings: InAppWebViewSettings(useOnShowFileChooser: true),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><head>'
                '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
                '<body style="margin:0"><input id="file" type="file" accept="image/*" '
                'style="display:block;width:100vw;height:100vh"></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
          onShowFileChooser: (controller, request) async {
            if (!chooser.isCompleted) chooser.complete(request);
            return ShowFileChooserResponse(
              handledByClient: true,
              filePaths: [],
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await _pumpFrames(tester);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.tapAt(Offset(size.width / 2, size.height / 2));

    final request = await chooser.future.timeout(const Duration(seconds: 10));
    expect(request.mode, ShowFileChooserRequestMode.OPEN);
    expect(request.acceptTypes, ['image/*']);
    expect(request.isCaptureEnabled, isFalse);

    expect(
      await controller.evaluateJavascript(
        source: "document.getElementById('file').files.length",
      ),
      0,
    );
  }, skip: shouldSkip);
}
