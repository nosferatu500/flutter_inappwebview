part of 'main.dart';

void onReceivedTouchIconUrl() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedTouchIconUrl,
  );

  skippableTestWidgets('onReceivedTouchIconUrl', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> onReceivedTouchIconUrlCompleter =
        Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="apple-touch-icon" sizes="72x72" href="https://placehold.it/72x72">
    </head>
    <body></body>
</html>
                    """,
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onReceivedTouchIconUrl: (controller, url, precomposed) {
            onReceivedTouchIconUrlCompleter.complete(url.toString());
          },
        ),
      ),
    );

    final String url = await onReceivedTouchIconUrlCompleter.future;

    expect(url, "https://placehold.it/72x72");
  }, skip: shouldSkip);

  // The test above never reads `precomposed`. With both kinds of link on one page, measured on API
  // 37 (§213): the plain icon reports false and the precomposed one true. A dropped or constant
  // flag fails one of the two.
  skippableTestWidgets(
    'onReceivedTouchIconUrl reports precomposed',
    (WidgetTester tester) async {
      final icons = <String, bool>{};
      final Completer<void> both = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              baseUrl: WebUri('https://example.com/'),
              data:
                  '<!DOCTYPE html><html><head>'
                  '<link rel="apple-touch-icon" href="https://example.com/plain.png">'
                  '<link rel="apple-touch-icon-precomposed" '
                  'href="https://example.com/precomposed.png">'
                  '</head><body>icons</body></html>',
            ),
            onReceivedTouchIconUrl: (controller, url, precomposed) {
              icons[url.toString()] = precomposed;
              if (icons.length == 2 && !both.isCompleted) both.complete();
            },
          ),
        ),
      );

      await both.future.timeout(const Duration(seconds: 15));
      expect(icons, {
        'https://example.com/plain.png': false,
        'https://example.com/precomposed.png': true,
      });
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
  );
}
