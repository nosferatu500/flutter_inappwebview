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
    expect(userAgent, contains('Android'));
  }, skip: shouldSkip);
}
