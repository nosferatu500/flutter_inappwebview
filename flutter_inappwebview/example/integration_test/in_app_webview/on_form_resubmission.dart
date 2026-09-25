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
            } else if (url.toString() == postUrl.toString() &&
                !postLoaded.isCompleted) {
              postLoaded.complete();
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

    await controller.reload();

    expect(
      await resubmissionUrl.future.timeout(const Duration(seconds: 15)),
      postUrl.toString(),
    );
    expect(events, ['requestFocus', 'formResubmission']);
  }, skip: shouldSkip);
}
