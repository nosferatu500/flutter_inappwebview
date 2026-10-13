part of 'main.dart';

void removeUserScriptsByGroupName() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.removeUserScriptsByGroupName,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // Two scripts in one group, at both injection times, and one in another group. Measured on API
  // 37: after removing the group and reloading, neither of its scripts runs, and the other group's
  // still does (§193). The survivor is what catches a handler that removes everything.
  skippableTestWidgets('removeUserScriptsByGroupName', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    var loadStops = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: '<!DOCTYPE html><html><body>scripts</body></html>',
          ),
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(
              groupName: 'removed',
              source: 'window.atStart = 1;',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
            UserScript(
              groupName: 'removed',
              source: 'window.atEnd = 2;',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
            ),
            UserScript(
              groupName: 'kept',
              source: 'window.kept = 3;',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            loadStops++;
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    Future<void> waitForLoadStop(int previous) async {
      for (var i = 0; i < 150 && loadStops == previous; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      expect(loadStops, greaterThan(previous), reason: 'the page never loaded');
    }

    Future<List<dynamic>> globals() async => [
      await controller.evaluateJavascript(source: 'window.atStart'),
      await controller.evaluateJavascript(source: 'window.atEnd'),
      await controller.evaluateJavascript(source: 'window.kept'),
    ];

    await waitForLoadStop(0);
    expect(await globals(), [1, 2, 3], reason: 'control: all three ran');

    await controller.removeUserScriptsByGroupName(groupName: 'removed');
    final previous = loadStops;
    await controller.reload();
    await waitForLoadStop(previous);

    expect(await globals(), [null, null, 3]);
  }, skip: shouldSkip);
}
