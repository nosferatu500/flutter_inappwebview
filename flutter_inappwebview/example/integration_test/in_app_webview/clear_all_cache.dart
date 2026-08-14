part of 'main.dart';

void clearAllCache() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.clearAllCache,
  );

  skippableTestWidgets('clearAllCache', (WidgetTester tester) async {
    await expectLater(
      InAppWebViewController.clearAllCache(includeDiskFiles: true),
      completes,
    );
  }, skip: shouldSkip);
}
