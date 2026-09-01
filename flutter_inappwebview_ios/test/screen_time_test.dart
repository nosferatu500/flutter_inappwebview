import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the three-API Screen Time family (iOS 26.0+):
/// `WKWebViewConfiguration.showsSystemScreenTimeBlockingView`,
/// `WKWebView.isBlockedByScreenTime` and `WKWebsiteDataTypeScreenTime`.
///
/// The two new members are pinned for the same reason as
/// `InAppWebViewSettings.supportsAdaptiveImageGlyph`: the Swift side reads the setting through KVC
/// by name (`ISettings.parse`) and the method by its wire string, so a typo in either language
/// produces an API that is fully wired, compiles, and is silently ignored.
///
/// The third member needs the opposite guard. `WKWebsiteDataTypeScreenTime` has been a constant
/// since §86 and is **deliberately excluded** from `WebsiteDataType.ALL`, because
/// `removeDataOfTypes:modifiedSince:` terminates the process from inside WebKit when it is present
/// (iOS 26.5, trap 22). Only an integration test could see that, and only on a device — so the
/// exclusion itself is pinned here, where it costs nothing to run.
void main() {
  group('InAppWebViewSettings.showsSystemScreenTimeBlockingView', () {
    test('serialises under the key the Swift side parses', () {
      // Swift: `var showsSystemScreenTimeBlockingView = true`, set by KVC from this exact key.
      expect(
        InAppWebViewSettings(
          showsSystemScreenTimeBlockingView: false,
        ).toMap()['showsSystemScreenTimeBlockingView'],
        false,
      );
    });

    test('defaults to true and is always sent', () {
      // Unlike `supportsAdaptiveImageGlyph`, which is absent when unset: WebKit's documented
      // default here is YES, so the constructor mirrors it and the value always reaches the wire.
      // This is the assertion that fails if the constructor parameter is forgotten (trap 17) — the
      // field would still exist and still serialise, as `null`.
      expect(
        InAppWebViewSettings().toMap()['showsSystemScreenTimeBlockingView'],
        true,
      );
    });

    test('round-trips both states through fromMap', () {
      for (final value in <bool>[false, true]) {
        final back = InAppWebViewSettings.fromMap(
          InAppWebViewSettings(
            showsSystemScreenTimeBlockingView: value,
          ).toMap(),
        )!;
        expect(back.showsSystemScreenTimeBlockingView, value);
      }
    });

    test('is reported iOS-only', () {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.showsSystemScreenTimeBlockingView,
          platform: TargetPlatform.iOS,
        ),
        true,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.showsSystemScreenTimeBlockingView,
          platform: TargetPlatform.android,
        ),
        false,
      );
    });
  });

  group('PlatformInAppWebViewController.isBlockedByScreenTime', () {
    setUpAll(() {
      // `isMethodSupported` is an instance method reached through the `static()` factory, so the
      // platform has to be registered before it can be asked anything — and the factory really
      // builds a controller, which installs a `MethodChannel` handler, which asserts unless the
      // test binding is up. Neither is obvious from the call site.
      TestWidgetsFlutterBinding.ensureInitialized();
      InAppWebViewPlatform.instance = IOSInAppWebViewPlatform();
    });

    test('is reported iOS-only', () {
      final controller = PlatformInAppWebViewController.static();
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.isBlockedByScreenTime,
          platform: TargetPlatform.iOS,
        ),
        true,
      );
      expect(
        controller.isMethodSupported(
          PlatformInAppWebViewControllerMethod.isBlockedByScreenTime,
          platform: TargetPlatform.android,
        ),
        false,
      );
    });
  });

  group('WebsiteDataType.WKWebsiteDataTypeScreenTime', () {
    test('exists as a constant', () {
      expect(
        WebsiteDataType.WKWebsiteDataTypeScreenTime.toNativeValue(),
        'WKWebsiteDataTypeScreenTime',
      );
    });

    test('is NOT in ALL — including it kills the process (§86, trap 22)', () {
      expect(
        WebsiteDataType.ALL,
        isNot(contains(WebsiteDataType.WKWebsiteDataTypeScreenTime)),
      );
    });

    test('ALL still carries the neighbouring iOS 17 types it gained in §86', () {
      // A control: if `ALL` were empty or truncated the assertion above would pass for the wrong
      // reason. These four are the ones §86 added alongside the excluded one.
      expect(
        WebsiteDataType.ALL,
        containsAll(<WebsiteDataType>[
          WebsiteDataType.WKWebsiteDataTypeFileSystem,
          WebsiteDataType.WKWebsiteDataTypeSearchFieldRecentSearches,
          WebsiteDataType.WKWebsiteDataTypeMediaKeys,
          WebsiteDataType.WKWebsiteDataTypeHashSalt,
        ]),
      );
    });
  });
}
