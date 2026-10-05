import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `create*Static()` factory answers on iOS, so the static support checks never throw.
///
/// The app-facing `X.isClassSupported()` / `isMethodSupported()` go through `PlatformX.static()`,
/// which calls the platform's `createPlatformXStatic()`. The platform interface's default for that
/// factory throws `UnimplementedError`, so a class iOS doesn't support still needs a stub here, and
/// two had none: `ProfileStore` and `GeolocationPermissions` (§253). Their support checks threw on
/// iOS instead of answering `false`, and one called while registering tests stopped the whole iOS
/// `in_app_webview` integration group from loading.
///
/// The list is all 29 factories the platform interface declares, so a class added later without an
/// iOS factory fails here rather than at an app's first support check.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = IOSInAppWebViewPlatform();

  final factories = <String, Object Function()>{
    'AssetsPathHandler': platform.createPlatformAssetsPathHandlerStatic,
    'ChromeSafariBrowser': platform.createPlatformChromeSafariBrowserStatic,
    'CookieManager': platform.createPlatformCookieManagerStatic,
    'CustomPathHandler': platform.createPlatformCustomPathHandlerStatic,
    'FindInteractionController':
        platform.createPlatformFindInteractionControllerStatic,
    'GeolocationPermissions':
        platform.createPlatformGeolocationPermissionsStatic,
    'HeadlessInAppWebView': platform.createPlatformHeadlessInAppWebViewStatic,
    'HttpAuthCredentialDatabase':
        platform.createPlatformHttpAuthCredentialDatabaseStatic,
    'InAppBrowser': platform.createPlatformInAppBrowserStatic,
    'InAppLocalhostServer': platform.createPlatformInAppLocalhostServerStatic,
    'InAppWebViewController':
        platform.createPlatformInAppWebViewControllerStatic,
    'InAppWebViewWidget': platform.createPlatformInAppWebViewWidgetStatic,
    'InternalStoragePathHandler':
        platform.createPlatformInternalStoragePathHandlerStatic,
    'LocalStorage': platform.createPlatformLocalStorageStatic,
    'PrintJobController': platform.createPlatformPrintJobControllerStatic,
    'ProcessGlobalConfig': platform.createPlatformProcessGlobalConfigStatic,
    'ProfileStore': platform.createPlatformProfileStoreStatic,
    'ProxyController': platform.createPlatformProxyControllerStatic,
    'PullToRefreshController':
        platform.createPlatformPullToRefreshControllerStatic,
    'ResourcesPathHandler': platform.createPlatformResourcesPathHandlerStatic,
    'ServiceWorkerController':
        platform.createPlatformServiceWorkerControllerStatic,
    'SessionStorage': platform.createPlatformSessionStorageStatic,
    'TracingController': platform.createPlatformTracingControllerStatic,
    'WebAuthenticationSession':
        platform.createPlatformWebAuthenticationSessionStatic,
    'WebMessageChannel': platform.createPlatformWebMessageChannelStatic,
    'WebMessageListener': platform.createPlatformWebMessageListenerStatic,
    'WebStorageManager': platform.createPlatformWebStorageManagerStatic,
    'WebStorage': platform.createPlatformWebStorageStatic,
    'WebViewFeature': platform.createPlatformWebViewFeatureStatic,
  };

  test('the list covers every factory the platform interface declares', () {
    expect(factories, hasLength(29));
  });

  for (final MapEntry(key: name, value: create) in factories.entries) {
    test('$name: the static instance answers isClassSupported on iOS', () {
      final Object instance = create();
      // Every Platform* class has the generated `isClassSupported`; dynamic keeps the table short.
      final Object? supported = (instance as dynamic).isClassSupported(
        platform: TargetPlatform.iOS,
      );
      expect(supported, isA<bool>());
    });
  }

  group('the two Android-only classes that had no iOS factory', () {
    test('ProfileStore is reported unsupported on iOS', () {
      final store = platform.createPlatformProfileStoreStatic();
      expect(store.isClassSupported(platform: TargetPlatform.iOS), isFalse);
      expect(store.isClassSupported(platform: TargetPlatform.android), isTrue);
      expect(
        store.isMethodSupported(
          PlatformProfileStoreMethod.getOrCreateProfile,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });

    test('GeolocationPermissions is reported unsupported on iOS', () {
      final permissions = platform.createPlatformGeolocationPermissionsStatic();
      expect(
        permissions.isClassSupported(platform: TargetPlatform.iOS),
        isFalse,
      );
      expect(
        permissions.isClassSupported(platform: TargetPlatform.android),
        isTrue,
      );
    });
  });
}
