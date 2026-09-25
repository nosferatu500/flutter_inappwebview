part of 'main.dart';

void renderProcessResponsiveness() {
  // Android only: this is the only platform the values below were measured on (API 37).
  final shouldSkip =
      !InAppWebView.isPropertySupported(
        PlatformWebViewCreationParamsProperty.onRenderProcessUnresponsive,
      ) ||
      defaultTargetPlatform != TargetPlatform.android;

  // A renderer counts as unresponsive when it stops acknowledging input, so the page is kept busy
  // with a 15 s loop while the test keeps tapping. Measured on API 37: `onRenderProcessUnresponsive`
  // fires (more than once) while the loop runs, then `onRenderProcessResponsive` once it ends, both
  // with the page URL (§192). About 20 s long.
  skippableTestWidgets(
    'onRenderProcessUnresponsive / onRenderProcessResponsive',
    (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String?> responsive = Completer<String?>();
      final events = <String>[];
      String? unresponsiveUrl;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  '<!DOCTYPE html><html><body style="height:100vh">busy</body></html>',
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) pageLoaded.complete();
            },
            onRenderProcessUnresponsive: (controller, url) async {
              events.add('unresponsive');
              unresponsiveUrl ??= url?.toString();
              return null;
            },
            onRenderProcessResponsive: (controller, url) async {
              events.add('responsive');
              if (!responsive.isCompleted) responsive.complete(url?.toString());
              return null;
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;
      await _pumpFrames(tester);

      // Deliberately not awaited: the reply only comes once the loop ends.
      unawaited(
        controller.evaluateJavascript(
          source:
              'var t = Date.now(); while (Date.now() - t < 15000) {} "done";',
        ),
      );

      final size = tester.getSize(find.byType(InAppWebView));
      for (var i = 0; i < 40 && !responsive.isCompleted; i++) {
        await tester.tapAt(Offset(size.width / 2, size.height / 2));
        await tester.pump(const Duration(milliseconds: 500));
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final responsiveUrl = await responsive.future.timeout(
        const Duration(seconds: 10),
      );
      expect(events.first, 'unresponsive');
      expect(events.last, 'responsive');
      expect(unresponsiveUrl, 'about:blank');
      expect(responsiveUrl, 'about:blank');
    },
    skip: shouldSkip,
  );
}
