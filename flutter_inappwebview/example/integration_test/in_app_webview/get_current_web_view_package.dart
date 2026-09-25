part of 'main.dart';

void getCurrentWebViewPackage() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getCurrentWebViewPackage,
  );

  skippableTest('getCurrentWebViewPackage', () async {
    final package = await InAppWebViewController.getCurrentWebViewPackage();
    expect(package, isNotNull);
    // Both fields, not just the object: the map the platform sends could arrive with either key
    // lost and `fromMap` would still build an instance (§187).
    expect(package!.packageName, isNotEmpty);
    expect(package.versionName, isNotEmpty);
  }, skip: shouldSkip);
}
