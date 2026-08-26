import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `UpgradeToHTTPSPolicy` against `WKWebpagePreferencesUpgradeToHTTPSPolicy`.
///
/// The Swift side does `WKWebpagePreferences.UpgradeToHTTPSPolicy(rawValue:)`, so a wrong integer
/// silently selects a *different* security posture rather than failing — the worst possible failure
/// mode for this particular setting, since `ERROR_ON_FAILURE` and `AUTOMATIC_FALLBACK_TO_HTTP` are
/// near-opposites. Hence the literal assertions.
///
/// Read out of `WebKit/WKWebpagePreferences.h` in the iOS 26.5 SDK: the enum is declared in
/// KeepAsRequested / AutomaticFallbackToHTTP / UserMediatedFallbackToHTTP / ErrorOnFailure order
/// with no explicit values, so it is 0..3.
void main() {
  group('UpgradeToHTTPSPolicy native values', () {
    test('match WKWebpagePreferencesUpgradeToHTTPSPolicy', () {
      expect(UpgradeToHTTPSPolicy.KEEP_AS_REQUESTED.toNativeValue(), 0);
      expect(
        UpgradeToHTTPSPolicy.AUTOMATIC_FALLBACK_TO_HTTP.toNativeValue(),
        1,
      );
      expect(
        UpgradeToHTTPSPolicy.USER_MEDIATED_FALLBACK_TO_HTTP.toNativeValue(),
        2,
      );
      expect(UpgradeToHTTPSPolicy.ERROR_ON_FAILURE.toNativeValue(), 3);
      expect(UpgradeToHTTPSPolicy.values, hasLength(4));
    });

    test('KEEP_AS_REQUESTED is 0, which is what makes the Swift default safe', () {
      // The Swift field is a non-optional `Int = 0` precisely because WebKit documents its own
      // default as KeepAsRequested. If this value were ever not 0, applying the setting
      // unconditionally would start changing behaviour for callers who never asked.
      expect(UpgradeToHTTPSPolicy.KEEP_AS_REQUESTED.toNativeValue(), 0);
    });

    test('round-trips through fromNativeValue', () {
      for (final p in UpgradeToHTTPSPolicy.values) {
        expect(UpgradeToHTTPSPolicy.fromNativeValue(p.toNativeValue()), p);
      }
    });
  });

  group('InAppWebViewSettings.preferredHTTPSNavigationPolicy', () {
    test('serialises under the key the Swift side parses', () {
      final settings = InAppWebViewSettings(
        preferredHTTPSNavigationPolicy: UpgradeToHTTPSPolicy.ERROR_ON_FAILURE,
      );
      // Swift: `settings?.preferredHTTPSNavigationPolicy` -- a non-optional Int, so ISettings.parse
      // sets it directly with no NSNumber shim (contrast writingToolsBehavior, §47).
      expect(settings.toMap()['preferredHTTPSNavigationPolicy'], 3);
    });

    test('is absent when not set, leaving the Swift default of 0', () {
      expect(
        InAppWebViewSettings().toMap()['preferredHTTPSNavigationPolicy'],
        isNull,
      );
    });

    test('survives a fromMap round-trip', () {
      final map = InAppWebViewSettings(
        preferredHTTPSNavigationPolicy:
            UpgradeToHTTPSPolicy.USER_MEDIATED_FALLBACK_TO_HTTP,
      ).toMap();
      expect(
        InAppWebViewSettings.fromMap(map)!.preferredHTTPSNavigationPolicy,
        UpgradeToHTTPSPolicy.USER_MEDIATED_FALLBACK_TO_HTTP,
      );
    });

    test('coexists with upgradeKnownHostsToHTTPS, which supersedes it', () {
      // Not a behavioural assertion -- WebKit decides that -- but a guard that both keys reach the
      // wire independently, since the docs say one overrides the other for known hosts.
      final map = InAppWebViewSettings(
        upgradeKnownHostsToHTTPS: true,
        preferredHTTPSNavigationPolicy: UpgradeToHTTPSPolicy.ERROR_ON_FAILURE,
      ).toMap();
      expect(map['upgradeKnownHostsToHTTPS'], true);
      expect(map['preferredHTTPSNavigationPolicy'], 3);
    });
  });
}
