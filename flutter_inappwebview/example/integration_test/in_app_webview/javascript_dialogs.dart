part of 'main.dart';

void javascriptDialogs() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onJsAlert,
  );

  skippableTestWidgets('javascript dialogs', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<JsAlertRequest> alertCompleter =
        Completer<JsAlertRequest>();
    final Completer<bool> confirmCompleter = Completer<bool>();
    final Completer<String> promptCompleter = Completer<String>();
    await InAppWebViewController.clearAllCache();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_on_js_dialog_test.html",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(
              handlerName: 'confirm',
              callback: (data) {
                confirmCompleter.complete(data.args[0] as bool);
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'prompt',
              callback: (data) {
                promptCompleter.complete(data.args[0] as String);
              },
            );
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onJsAlert: (controller, jsAlertRequest) async {
            JsAlertResponseAction action = JsAlertResponseAction.CONFIRM;
            alertCompleter.complete(jsAlertRequest);
            return JsAlertResponse(handledByClient: true, action: action);
          },
          onJsConfirm: (controller, jsConfirmRequest) async {
            JsConfirmResponseAction action = JsConfirmResponseAction.CONFIRM;
            return JsConfirmResponse(handledByClient: true, action: action);
          },
          onJsPrompt: (controller, jsPromptRequest) async {
            JsPromptResponseAction action = JsPromptResponseAction.CONFIRM;
            return JsPromptResponse(
              handledByClient: true,
              action: action,
              value: 'new value',
            );
          },
        ),
      ),
    );

    await pageLoaded.future;

    final JsAlertRequest jsAlertRequest = await alertCompleter.future;
    expect(jsAlertRequest.message, 'alert message');

    final bool onJsConfirmValue = await confirmCompleter.future;
    expect(onJsConfirmValue, true);

    final String onJsPromptValue = await promptCompleter.future;
    expect(onJsPromptValue, 'new value');
  }, skip: shouldSkip);

  // A handler that throws is the one answer these dialogs treat differently from no answer: the
  // plugin cancels the dialog instead of showing its own (§215). Measured on API 37: `confirm`
  // returns false. Had the throw been treated as no answer, the plugin's dialog would be up, and
  // that blocks the page: measured with the cancel removed, the poll's evaluateJavascript never
  // returned. Each poll therefore has its own timeout and reports "blocked".
  skippableTestWidgets(
    'javascript dialogs: a throwing onJsConfirm cancels',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final messages = <String?>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  '<!DOCTYPE html><html><body>confirm<script>var answer = "pending";</script>'
                  '</body></html>',
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) pageLoaded.complete();
            },
            onJsConfirm: (controller, jsConfirmRequest) async {
              messages.add(jsConfirmRequest.message);
              throw Exception('onJsConfirm throws on purpose');
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      // From a timer, so the blocking `confirm` does not hold up this evaluateJavascript reply.
      await controller.evaluateJavascript(
        source: 'setTimeout(function() { answer = String(confirm("q")); }, 0);',
      );

      String? answer;
      for (var i = 0; i < 50; i++) {
        answer = await controller
            .evaluateJavascript(source: 'answer')
            .timeout(const Duration(seconds: 2), onTimeout: () => 'blocked');
        if (answer != 'pending') break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      expect(messages, ['q']);
      expect(answer, 'false');
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
  );
}
