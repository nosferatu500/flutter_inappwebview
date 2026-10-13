part of 'main.dart';

void onFormResubmission() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onFormResubmission,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Reloading a page that was the answer to a POST asks whether to send the form again. It also
  // raises `onRequestFocus`, just before the question, because Chromium activates the page to ask.
  // A plain reload does not (both measured on API 37, §192), which is why `onRequestFocus` is
  // tested here rather than on its own.
  skippableTestWidgets('onFormResubmission', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> blankLoaded = Completer<void>();
    final Completer<void> postLoaded = Completer<void>();
    final Completer<String?> resubmissionUrl = Completer<String?>();
    final events = <String>[];
    final postUrl = WebUri(
      "http://${environment["NODE_SERVER_IP"]}:8082/test-post",
    );
    var postLoads = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>start</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!blankLoaded.isCompleted) {
              blankLoaded.complete();
            } else if (url.toString() == postUrl.toString()) {
              postLoads++;
              if (!postLoaded.isCompleted) postLoaded.complete();
            }
          },
          onRequestFocus: (controller) {
            events.add('requestFocus');
          },
          onFormResubmission: (controller, url) async {
            events.add('formResubmission');
            if (!resubmissionUrl.isCompleted) {
              resubmissionUrl.complete(url?.toString());
            }
            return FormResubmissionAction.DONT_RESEND;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await blankLoaded.future;

    await controller.postUrl(
      url: postUrl,
      postData: Uint8List.fromList(utf8.encode('firstname=Foo&lastname=Bar')),
    );
    await postLoaded.future.timeout(const Duration(seconds: 20));
    expect(
      events,
      isEmpty,
      reason: 'neither event may fire before the POST page is reloaded',
    );
    // Marks this document, so a resent form shows up as a new one.
    await controller.evaluateJavascript(
      source: 'document.body.setAttribute("data-mark", "old");',
    );

    await controller.reload();

    expect(
      await resubmissionUrl.future.timeout(const Duration(seconds: 15)),
      postUrl.toString(),
    );
    expect(events, ['requestFocus', 'formResubmission']);

    // DONT_RESEND is also the platform default, so on its own this proves nothing about the answer
    // being used; it is the contrast for the RESEND test below. Measured on API 37 (§215): the old
    // document stays and no second load arrives.
    await Future.delayed(const Duration(seconds: 3));
    expect(postLoads, 1);
    expect(
      await controller.evaluateJavascript(
        source: 'document.body.getAttribute("data-mark")',
      ),
      'old',
    );
  }, skip: shouldSkip);

  skippableTestWidgets('onFormResubmission RESEND posts the form again', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final postUrl = WebUri(
      "http://${environment["NODE_SERVER_IP"]}:8082/test-post",
    );
    final loads = <String>[];
    var asked = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>start</body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            loads.add(url.toString());
          },
          onFormResubmission: (controller, url) async {
            asked++;
            return FormResubmissionAction.RESEND;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    for (var i = 0; i < 100 && loads.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await controller.postUrl(
      url: postUrl,
      postData: Uint8List.fromList(utf8.encode('name=Resent')),
    );
    for (var i = 0; i < 200 && loads.length < 2; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(loads, ['about:blank', postUrl.toString()]);
    await controller.evaluateJavascript(
      source: 'document.body.setAttribute("data-mark", "old");',
    );

    await controller.reload();
    for (var i = 0; i < 150 && loads.length < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(asked, 1);
    expect(loads, ['about:blank', postUrl.toString(), postUrl.toString()]);
    expect(
      await controller.evaluateJavascript(
        source: 'document.body.getAttribute("data-mark")',
      ),
      isNull,
      reason: 'the reload kept the old document, so the form was not resent',
    );
    // The server echoes the posted field, so the new document is the answer to the resent POST.
    expect(
      await controller.evaluateJavascript(source: 'document.body.innerText'),
      'HELLO Resent!',
    );
  }, skip: shouldSkip);
}
