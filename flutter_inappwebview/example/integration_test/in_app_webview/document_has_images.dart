part of 'main.dart';

/// Verifies `WebView.documentHasImages` (§62) on a device — both answers, from two documents.
///
/// A one-sided test would pass against a stub that always said `true`, so the point of this one is
/// the pair: an image-free document must answer `false` and a document with an `<img>` must answer
/// `true`. That is also what proves the `Message.arg1 == 1` decoding is right rather than
/// accidentally always-truthy.
///
/// The image is a `data:` URI so nothing is fetched — this is about a document reference, not about
/// the network (§57).
void documentHasImages() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.documentHasImages,
  );

  // 1x1 transparent GIF.
  const imageDataUri =
      'data:image/gif;base64,'
      'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

  Future<bool> loadAndAsk(WidgetTester tester, String body) async {
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
                '<!DOCTYPE html><html><head><meta charset="UTF-8"></head>'
                '<body>$body</body></html>',
          ),
          onWebViewCreated: (controller) =>
              controllerCompleter.complete(controller),
          onLoadStop: (controller, url) => pageLoaded.complete(),
        ),
      ),
    );

    final controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    // The platform replies through a dispatched Message; a bare await would surface a handler that
    // never fires as an opaque 60s stall rather than a named failure (§56).
    return await controller.documentHasImages().timeout(
      const Duration(seconds: 15),
    );
  }

  skippableTestWidgets('documentHasImages', (WidgetTester tester) async {
    expect(
      await loadAndAsk(tester, '<p>no pictures here</p>'),
      isFalse,
      reason: 'a document with no image reference reported one',
    );

    expect(
      await loadAndAsk(tester, '<img src="$imageDataUri" alt="dot">'),
      isTrue,
      reason: 'a document containing an <img> reported no image reference',
    );
  }, skip: shouldSkip);
}
