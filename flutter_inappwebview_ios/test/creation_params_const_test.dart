import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that these creation params can be built in a `const` context (§235,
/// `prefer_const_constructors_in_immutables`). Making a public constructor `const` is a promise to
/// callers, and taking it back would break them; this file stops compiling if it is.
///
/// `identical` holds only because `const` instances are canonicalized, so it also shows the
/// constructors really ran as `const`. `IOSWebStorageCreationParams` is `const` too, but it needs
/// `PlatformLocalStorage` instances, which can't be `const`, so only the compiler checks that one.
void main() {
  test('IOSInAppBrowserCreationParams', () {
    const a = IOSInAppBrowserCreationParams();
    expect(identical(a, const IOSInAppBrowserCreationParams()), isTrue);
    expect(a.pullToRefreshController, isNull);
  });

  test('IOSHeadlessInAppWebViewCreationParams', () {
    const a = IOSHeadlessInAppWebViewCreationParams();
    expect(identical(a, const IOSHeadlessInAppWebViewCreationParams()), isTrue);
    expect(a.findInteractionController, isNull);
  });

  test('IOSStorageCreationParams', () {
    const a = IOSStorageCreationParams(
      controller: null,
      webStorageType: WebStorageType.LOCAL_STORAGE,
    );
    expect(
      identical(
        a,
        const IOSStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.LOCAL_STORAGE,
        ),
      ),
      isTrue,
    );
    expect(a.webStorageType, WebStorageType.LOCAL_STORAGE);
  });
}
