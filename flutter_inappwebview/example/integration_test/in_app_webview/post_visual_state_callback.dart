part of 'main.dart';

/// Verifies `WebView.postVisualStateCallback` (§60) — that the returned `Future` actually
/// completes, and that it completes *after* a DOM mutation that involved no navigation.
///
/// The second part is the whole reason this API is not a duplicate of `onPageCommitVisible`: that
/// event fires once per navigation, so it cannot answer "has my `innerHTML` change been painted?".
///
/// Both awaits carry an explicit `.timeout`. The native contract is that the callback is never
/// invoked if the WebView is destroyed first, and there is no platform timeout, so the failure mode
/// under test is a future that never completes — and a bare `await` would surface that as an opaque
/// 60-second stall rather than a named failure (§56).
void postVisualStateCallback() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.postVisualStateCallback,
  );

  skippableTestWidgets('postVisualStateCallback', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          // Inline content: this is about painting, not about the network.
          initialData: InAppWebViewInitialData(
            data: """
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>visual state</title></head>
<body><h1 id="title">first</h1></body>
</html>
""",
          ),
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
    await tester.pump();
    await pageLoaded.future;

    await expectLater(
      controller.postVisualStateCallback().timeout(const Duration(seconds: 15)),
      completes,
      reason:
          'the visual state callback never fired for the initial content -- the native handler is '
          'not replying, or the WebView never drew',
    );

    // No navigation here, so onPageCommitVisible would not fire again: this is the case only
    // postVisualStateCallback can answer.
    await controller.evaluateJavascript(
      source: "document.getElementById('title').innerHTML = 'second';",
    );

    await expectLater(
      controller.postVisualStateCallback().timeout(const Duration(seconds: 15)),
      completes,
      reason: 'the callback did not fire for a navigation-free DOM mutation',
    );

    // The mutation really did land, so the callback above was about the new content.
    final title = await controller.evaluateJavascript(
      source: "document.getElementById('title').innerHTML;",
    );
    expect(title, 'second');
  }, skip: shouldSkip);
}
