part of 'main.dart';

void getDefaultUserAgent() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getDefaultUserAgent,
  );

  skippableTest('getDefaultUserAgent', () async {
    // Not `isNotNull`: the Dart side answers `?? ''`, so that assertion could never fail on a live
    // channel — a platform answering null would pass it (§187). The content is what proves the value
    // crossed.
    final userAgent = await InAppWebViewController.getDefaultUserAgent();
    expect(userAgent, contains('Mozilla/5.0'));
    if (defaultTargetPlatform == TargetPlatform.android) {
      expect(userAgent, contains('Android'));
    } else {
      // Measured on the iOS 26.5 simulator: `Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X)
      // AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148`. WebKit reports a frozen OS
      // version (18_7 on 26.5), so the version isn't asserted.
      expect(userAgent, contains('AppleWebKit'));
      expect(userAgent, isNot(contains('Android')));
    }
  }, skip: shouldSkip);
}
