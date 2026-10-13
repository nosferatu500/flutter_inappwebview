part of 'main.dart';

void programmaticScroll() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.scrollTo,
  );

  skippableGroup('Programmatic Scroll', () {
    final shouldSkipTest1 = !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.scrollTo,
    );

    skippableTestWidgets('set and get scroll position', (
      WidgetTester tester,
    ) async {
      const String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

      final String scrollTestPageBase64 = base64Encode(
        const Utf8Encoder().convert(scrollTestPage),
      );

      var url = !kIsWeb
          ? WebUri('data:text/html;charset=utf-8;base64,$scrollTestPageBase64')
          : TEST_WEB_PLATFORM_URL_1;

      final Completer<void> pageLoaded = Completer<void>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await tester.pump();
      await pageLoaded.future;

      await controller.scrollTo(x: 0, y: 0);

      // Polled, not read once. On Android the renderer applies a scroll asynchronously, and a read
      // straight after `scrollTo` / `scrollBy` can still return the previous position for a moment
      // (§264: 2 reads in 120 calls, e.g. `(0,0)` right after `scrollTo(123, 321)`, then `(123,321)`
      // 25 ms later and steady for 1.5 s; never a correct value lost afterwards). That was this
      // test's flake. It still fails if the position never arrives.
      Future<void> expectScrollPosition(int x, int y, String after) async {
        String? seen;
        for (var i = 0; i < 40; i++) {
          seen =
              '${await controller.getScrollX()},${await controller.getScrollY()}';
          if (seen == '$x,$y') return;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        fail('after $after the scroll position was $seen, not $x,$y, for 2 s');
      }

      // Check scrollTo()
      const int X_SCROLL = 123;
      const int Y_SCROLL = 321;

      await controller.scrollTo(x: X_SCROLL, y: Y_SCROLL);
      await expectScrollPosition(X_SCROLL, Y_SCROLL, 'scrollTo');

      // Check scrollBy() (on top of scrollTo())
      await controller.scrollBy(x: X_SCROLL, y: Y_SCROLL);
      await expectScrollPosition(X_SCROLL * 2, Y_SCROLL * 2, 'scrollBy');
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 =
        kIsWeb ||
        !InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.useHybridComposition,
        );

    testWidgets(
      'set and get scroll position on Android without Hybrid Composition',
      (WidgetTester tester) async {
        const String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

        final String scrollTestPageBase64 = base64Encode(
          const Utf8Encoder().convert(scrollTestPage),
        );

        final Completer<void> pageLoaded = Completer<void>();
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
                ),
              ),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialSettings: InAppWebViewSettings(
                useHybridComposition: false,
              ),
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        );

        final InAppWebViewController controller =
            await controllerCompleter.future;
        await pageLoaded.future;
        await controller.scrollTo(x: 0, y: 0);

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Check scrollTo()
        const int X_SCROLL = 123;
        const int Y_SCROLL = 321;

        await controller.scrollTo(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        int? scrollPosX = await controller.getScrollX();
        int? scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL);
        expect(scrollPosY, Y_SCROLL);

        // Check scrollBy() (on top of scrollTo())
        await controller.scrollBy(x: X_SCROLL, y: Y_SCROLL);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        scrollPosX = await controller.getScrollX();
        scrollPosY = await controller.getScrollY();
        expect(scrollPosX, X_SCROLL * 2);
        expect(scrollPosY, Y_SCROLL * 2);
      },
      skip: shouldSkipTest2,
    );
  }, skip: shouldSkip);
}
