part of 'main.dart';

void getCurrentWebViewPackage() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getCurrentWebViewPackage,
  );

  skippableTest('getCurrentWebViewPackage', () async {
    final package = await InAppWebViewController.getCurrentWebViewPackage();
    expect(package, isNotNull);
    // Both fields, not just the object: the payload could arrive with either field lost and still
    // build an instance (§187). And each by its *shape*, not just non-empty — §188 measured a mutant
    // swapping the two fields in the Kotlin conversion passing `isNotEmpty` on both. A package name
    // is dotted and starts with a letter; a version starts with a digit. Neither matches the other.
    expect(
      package!.packageName,
      matches(RegExp(r'^[a-zA-Z][\w]*(\.[\w]+)+$')),
      reason: 'packageName does not look like a package',
    );
    expect(
      package.versionName,
      matches(RegExp(r'^\d')),
      reason: 'versionName does not look like a version',
    );
  }, skip: shouldSkip);
}
