part of 'main.dart';

void onJsBeforeUnload() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onJsBeforeUnload,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Chromium only asks before unloading a page the user has interacted with, so each test taps the
  // page first. Measured on API 37 (§215): without the tap the event never fires and the navigation
  // goes through, which is why the previous version of this test (a timer navigating away on its
  // own) never saw the event and was skipped everywhere. The page is data with an http base URL;
  // the event reports its URL as `about:blank`.
  //
  // The two answers are asserted as a pair. The platform default shows a dialog nothing in the test
  // can answer, which leaves the navigation pending, so only CONFIRM navigating and CANCEL staying
  // put prove the plugin used the action Dart returned.
  Future<List<String>> navigateAway(
    WidgetTester tester,
    JsBeforeUnloadResponseAction action,
    List<JsBeforeUnloadRequest> requests,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final loads = <String>[];
    final base = "http://${environment["NODE_SERVER_IP"]}:8082/";
    final target = "${base}test-index";

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data:
                '<!DOCTYPE html><html><body style="height:100vh">unload<script>'
                'window.addEventListener("beforeunload", function (e) {'
                ' e.preventDefault(); e.returnValue = ""; });</script></body></html>',
            baseUrl: WebUri(base),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            loads.add(url.toString());
          },
          onJsBeforeUnload: (controller, jsBeforeUnloadRequest) async {
            requests.add(jsBeforeUnloadRequest);
            return JsBeforeUnloadResponse(
              handledByClient: true,
              action: action,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    for (var i = 0; i < 100 && loads.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(loads, [base]);
    await _pumpFrames(tester);

    final size = tester.getSize(find.byType(InAppWebView));
    await tester.tapAt(Offset(size.width / 2, size.height / 2));
    await _pumpFrames(tester);

    await controller.evaluateJavascript(source: 'location.href = "$target";');
    for (var i = 0; i < 50 && loads.length < 2; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return [...loads, (await controller.getUrl()).toString()];
  }

  skippableTestWidgets('onJsBeforeUnload CANCEL keeps the page', (
    WidgetTester tester,
  ) async {
    final requests = <JsBeforeUnloadRequest>[];
    final base = "http://${environment["NODE_SERVER_IP"]}:8082/";

    final loadsThenUrl = await navigateAway(
      tester,
      JsBeforeUnloadResponseAction.CANCEL,
      requests,
    );

    expect(requests, hasLength(1));
    expect(requests.single.url.toString(), 'about:blank');
    expect(requests.single.message, 'Changes you made may not be saved.');
    expect(loadsThenUrl, [base, 'about:blank']);
  }, skip: shouldSkip);

  skippableTestWidgets('onJsBeforeUnload CONFIRM leaves the page', (
    WidgetTester tester,
  ) async {
    final requests = <JsBeforeUnloadRequest>[];
    final base = "http://${environment["NODE_SERVER_IP"]}:8082/";
    final target = "${base}test-index";

    final loadsThenUrl = await navigateAway(
      tester,
      JsBeforeUnloadResponseAction.CONFIRM,
      requests,
    );

    expect(requests, hasLength(1));
    expect(loadsThenUrl, [base, target, target]);
  }, skip: shouldSkip);
}
