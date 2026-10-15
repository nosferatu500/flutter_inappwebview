import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `InAppWebViewSettings.globalPrivacyControlEnabled` on the wire. The Swift side reads the key
/// with `responds(to:)` + key-value coding into an optional (`_globalPrivacyControlEnabled`, an
/// `NSNumber`) and assigns it to each navigation's `WKWebpagePreferences` only when present: assigning
/// `false` is observable (`navigator.globalPrivacyControl` becomes `false` instead of `undefined`, §351),
/// so an unset setting must stay off the wire and an explicit `false` must stay on it. That the signal
/// really goes out is the device test's job (`in_app_webview/global_privacy_control.dart`, iOS 27).
void main() {
  group('InAppWebViewSettings.globalPrivacyControlEnabled', () {
    test('serialises under the key the Swift side parses', () {
      expect(
        InAppWebViewSettings(globalPrivacyControlEnabled: true)
            .toMap()['globalPrivacyControlEnabled'],
        true,
      );
    });

    test('is absent when not set, so WebKit is left untouched', () {
      expect(
        InAppWebViewSettings().toMap()['globalPrivacyControlEnabled'],
        isNull,
      );
    });

    test('an explicit false is sent, not dropped', () {
      expect(
        InAppWebViewSettings(globalPrivacyControlEnabled: false)
            .toMap()['globalPrivacyControlEnabled'],
        isFalse,
      );
    });

    test('survives a fromMap round-trip', () {
      final map = InAppWebViewSettings(globalPrivacyControlEnabled: false)
          .toMap();
      expect(
        InAppWebViewSettings.fromMap(map)!.globalPrivacyControlEnabled,
        isFalse,
      );
    });

    test(
      'coexists with the other per-navigation WKWebpagePreferences settings',
      () {
        final map = InAppWebViewSettings(
          securityRestrictionMode:
              SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY,
          globalPrivacyControlEnabled: true,
        ).toMap();
        expect(map['securityRestrictionMode'], 1);
        expect(map['globalPrivacyControlEnabled'], true);
      },
    );
  });
}
