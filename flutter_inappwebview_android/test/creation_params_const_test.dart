import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that these creation params can be built in a `const` context (§235,
/// `prefer_const_constructors_in_immutables`). Making a public constructor `const` is a promise to
/// callers, and taking it back would break them; this file stops compiling if it is.
///
/// `identical` holds only because `const` instances are canonicalized, so it also shows the
/// constructors really ran as `const`. `AndroidWebStorageCreationParams` is `const` too, but it needs
/// `PlatformLocalStorage` instances, which can't be `const`, so only the compiler checks that one.
void main() {
  test('AndroidInAppBrowserCreationParams', () {
    const a = AndroidInAppBrowserCreationParams();
    expect(identical(a, const AndroidInAppBrowserCreationParams()), isTrue);
    expect(a.pullToRefreshController, isNull);
  });

  test('AndroidHeadlessInAppWebViewCreationParams', () {
    const a = AndroidHeadlessInAppWebViewCreationParams();
    expect(
      identical(a, const AndroidHeadlessInAppWebViewCreationParams()),
      isTrue,
    );
    expect(a.findInteractionController, isNull);
  });

  test('AndroidStorageCreationParams', () {
    const a = AndroidStorageCreationParams(
      controller: null,
      webStorageType: WebStorageType.LOCAL_STORAGE,
    );
    expect(
      identical(
        a,
        const AndroidStorageCreationParams(
          controller: null,
          webStorageType: WebStorageType.LOCAL_STORAGE,
        ),
      ),
      isTrue,
    );
    expect(a.webStorageType, WebStorageType.LOCAL_STORAGE);
  });
}
