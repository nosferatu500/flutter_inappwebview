part of 'main.dart';

/// A page split into a link (top half) and an image (bottom half), for the two tests that read
/// the WebView's last hit test: `requestFocusNodeHref` and `requestImageRef`. The link's click is
/// cancelled so tapping it does not navigate away.
const String _hitTestPage =
    '<!DOCTYPE html><html><head>'
    '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
    '<body style="margin:0">'
    '<a href="https://example.com/target" onclick="event.preventDefault()" '
    'style="display:block;height:50vh;background:#ccc">Link text</a>'
    '<img src="$_onePixelPng" style="display:block;width:100vw;height:50vh">'
    '</body></html>';

const String _onePixelPng =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQG'
    'AhKmMIQAAAABJRU5ErkJggg==';

/// Taps [position] twice. Measured on API 37: the first tap into a freshly loaded page left the hit
/// test empty (every field null), and the second reported the link. Why is not known, and the
/// second tap is what the assertions depend on.
Future<void> _tapTwice(WidgetTester tester, Offset position) async {
  for (var i = 0; i < 2; i++) {
    await tester.tapAt(position);
    await tester.pump(const Duration(seconds: 1));
    await Future.delayed(const Duration(seconds: 1));
  }
}

void requestFocusNodeHref() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.requestFocusNodeHref,
  );

  skippableTestWidgets('requestFocusNodeHref', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(data: _hitTestPage),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    if (defaultTargetPlatform != TargetPlatform.android) {
      await expectLater(controller.requestFocusNodeHref(), completes);
      return;
    }

    // Before this, the test only checked that the call completed, and a Kotlin handler that
    // answered null passed it. Values measured on API 37.
    final size = tester.getSize(find.byType(InAppWebView));

    await _tapTwice(tester, Offset(size.width / 2, size.height / 4));
    final link = await controller.requestFocusNodeHref();
    expect(link?.url?.toString(), 'https://example.com/target');
    expect(link?.title, 'Link text');
    expect(link?.src, isNull, reason: 'the link holds no image');

    // An image outside any link: `src` is the only field, and `url` must not keep the link's.
    await _tapTwice(tester, Offset(size.width / 2, size.height * 3 / 4));
    final image = await controller.requestFocusNodeHref();
    expect(image?.src, _onePixelPng);
    expect(image?.url, isNull);
  }, skip: shouldSkip);
}
