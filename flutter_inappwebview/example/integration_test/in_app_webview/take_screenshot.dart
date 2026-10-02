part of 'main.dart';

void takeScreenshot() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.takeScreenshot,
  );

  skippableTestWidgets('takeScreenshot', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    // Without pumped frames the WebView has no size yet (§209: with the rect ignored, the capture
    // failed with "width and height must be > 0"), so the rect below was drawn from a 0 × 0 view.
    await Future.delayed(const Duration(seconds: 1));
    await _pumpFrames(tester);

    var screenshotConfiguration = ScreenshotConfiguration(
      compressFormat: CompressFormat.JPEG,
      quality: 20,
      rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50),
    );
    var screenshot = await controller.takeScreenshot(
      screenshotConfiguration: screenshotConfiguration,
    );
    expect(screenshot, isNotNull);
  }, skip: shouldSkip);

  // The test above can't tell whether the configuration arrived: any screenshot passes. These read
  // each field back out of the image, on a page of four 200 CSS px squares:
  //
  //     red    (0,0)     green  (200,0)
  //     blue   (0,200)   yellow (200,200)
  //
  // Android only: this is the only platform the values were measured on (Pixel_10, API 37, §209).
  // There the rect and snapshotWidth are in CSS px, scaled by the density (2.625, the same as
  // Flutter's devicePixelRatio) and rounded, so a 120 × 60 rect is a 315 × 158 image.
  //
  // Same-typed fields get values only the right field produces: x ≠ y (a swap lands in blue, not
  // green), width ≠ height (a swap transposes the image), and snapshotWidth matches neither.
  skippableGroup(
    'takeScreenshot configuration',
    () {
      Future<InAppWebViewController> loadSquares(WidgetTester tester) async {
        final Completer<InAppWebViewController> controllerCompleter =
            Completer<InAppWebViewController>();
        final Completer<void> pageLoaded = Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialData: InAppWebViewInitialData(
                data:
                    '<!DOCTYPE html><html><head>'
                    '<meta name="viewport" content="width=device-width, initial-scale=1">'
                    '<style>body{margin:0} div{position:absolute;width:200px;height:200px}'
                    '</style></head><body>'
                    '<div style="left:0;top:0;background:#ff0000"></div>'
                    '<div style="left:200px;top:0;background:#00ff00"></div>'
                    '<div style="left:0;top:200px;background:#0000ff"></div>'
                    '<div style="left:200px;top:200px;background:#ffff00"></div>'
                    '</body></html>',
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
        final controller = await controllerCompleter.future;
        await pageLoaded.future;
        await _pumpFrames(tester);
        return controller;
      }

      Future<Uint8List> shoot(
        InAppWebViewController controller,
        ScreenshotConfiguration configuration,
      ) async {
        final bytes = await controller.takeScreenshot(
          screenshotConfiguration: configuration,
        );
        expect(bytes, isNotNull, reason: 'no screenshot at all');
        return bytes!;
      }

      // Decodes [bytes] and returns its size and the RGB at each of [points] (image pixels).
      Future<(int, int, List<List<int>>)> decode(
        Uint8List bytes,
        List<(int, int)> points,
      ) async {
        final image = await decodeImageFromList(bytes);
        final rgba = (await image.toByteData())!;
        final colors = [
          for (final (x, y) in points)
            [
              for (var c = 0; c < 3; c++)
                rgba.getUint8((y * image.width + x) * 4 + c),
            ],
        ];
        return (image.width, image.height, colors);
      }

      const green = [0, 255, 0];
      final rect = InAppWebViewRect(x: 250, y: 50, width: 120, height: 60);

      skippableTestWidgets('rect', (WidgetTester tester) async {
        final controller = await loadSquares(tester);
        final dpr = tester.view.devicePixelRatio;
        final expectedWidth = (120 * dpr).round();
        final expectedHeight = (60 * dpr).round();
        final (width, height, colors) = await decode(
          await shoot(controller, ScreenshotConfiguration(rect: rect)),
          [(5, 5), (expectedWidth - 5, expectedHeight - 5)],
        );
        expect((width, height), (expectedWidth, expectedHeight));
        expect(colors, [
          green,
          green,
        ], reason: 'x = 250, y = 50 lies in the green square');
      });

      skippableTestWidgets('compressFormat', (WidgetTester tester) async {
        final controller = await loadSquares(tester);
        Future<List<int>> magic(CompressFormat? format) async => (await shoot(
          controller,
          ScreenshotConfiguration(rect: rect, compressFormat: format),
        )).sublist(0, 4);

        expect(await magic(null), [0x89, 0x50, 0x4e, 0x47], reason: 'PNG');
        expect(await magic(CompressFormat.JPEG), [0xff, 0xd8, 0xff, 0xe0]);
        expect(await magic(CompressFormat.WEBP), [0x52, 0x49, 0x46, 0x46]);
      });

      // Only a relation: PNG ignores quality, and the exact JPEG sizes are the encoder's business.
      // Measured on a 400 × 400 rect: 13980 bytes at 100, 8251 at 1.
      skippableTestWidgets('quality', (WidgetTester tester) async {
        final controller = await loadSquares(tester);
        Future<int> jpegLength(int quality) async => (await shoot(
          controller,
          ScreenshotConfiguration(
            rect: InAppWebViewRect(x: 0, y: 0, width: 400, height: 400),
            compressFormat: CompressFormat.JPEG,
            quality: quality,
          ),
        )).length;

        expect(await jpegLength(1), lessThan(await jpegLength(100)));
      });

      skippableTestWidgets('snapshotWidth', (WidgetTester tester) async {
        final controller = await loadSquares(tester);
        final dpr = tester.view.devicePixelRatio;
        final rectWidth = (120 * dpr).round();
        final rectHeight = (60 * dpr).round();
        final expectedWidth = (30 * dpr).round();
        final expectedHeight = (expectedWidth / (rectWidth / rectHeight))
            .toInt();
        final (width, height, colors) = await decode(
          await shoot(
            controller,
            ScreenshotConfiguration(rect: rect, snapshotWidth: 30),
          ),
          [(5, 5)],
        );
        expect((width, height), (expectedWidth, expectedHeight));
        expect(colors, [green]);
      });
    },
    skip: shouldSkip || defaultTargetPlatform != TargetPlatform.android,
  );
}
