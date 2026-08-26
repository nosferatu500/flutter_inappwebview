import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `SecurityRestrictionMode` against `WKSecurityRestrictionMode`.
///
/// Same hazard as `UpgradeToHTTPSPolicy` in §48 and worse in degree: the Swift side does
/// `WKSecurityRestrictionMode(rawValue:)`, which accepts any of the three values, so a wrong integer
/// silently selects a *different hardening level* rather than failing. Getting `NONE` where
/// `MAXIMIZE_COMPATIBILITY` was asked for means the JIT stays enabled on untrusted content, with
/// nothing anywhere reporting a problem.
///
/// Read out of `WebKit/WKWebpagePreferences.h` in the iOS 26.5 SDK; the enum is declared
/// None / MaximizeCompatibility / Lockdown with no explicit values, so it is 0..2.
void main() {
  group('SecurityRestrictionMode native values', () {
    test('match WKSecurityRestrictionMode', () {
      expect(SecurityRestrictionMode.NONE.toNativeValue(), 0);
      expect(SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY.toNativeValue(), 1);
      expect(SecurityRestrictionMode.LOCKDOWN.toNativeValue(), 2);
      expect(SecurityRestrictionMode.values, hasLength(3));
    });

    test('NONE is 0, which is what makes the Swift default safe', () {
      // The Swift field is a non-optional `Int = 0` because WebKit documents its default as
      // WKSecurityRestrictionModeNone. If this were ever not 0, applying the setting
      // unconditionally would start hardening WebViews whose owners never asked.
      expect(SecurityRestrictionMode.NONE.toNativeValue(), 0);
    });

    test('round-trips through fromNativeValue', () {
      for (final m in SecurityRestrictionMode.values) {
        expect(SecurityRestrictionMode.fromNativeValue(m.toNativeValue()), m);
      }
    });
  });

  group('InAppWebViewSettings.securityRestrictionMode', () {
    test('serialises under the key the Swift side parses', () {
      final settings = InAppWebViewSettings(
        securityRestrictionMode: SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY,
      );
      expect(settings.toMap()['securityRestrictionMode'], 1);
    });

    test('is absent when not set, leaving the Swift default of 0', () {
      expect(InAppWebViewSettings().toMap()['securityRestrictionMode'], isNull);
    });

    test('survives a fromMap round-trip', () {
      final map = InAppWebViewSettings(
        securityRestrictionMode: SecurityRestrictionMode.LOCKDOWN,
      ).toMap();
      expect(
        InAppWebViewSettings.fromMap(map)!.securityRestrictionMode,
        SecurityRestrictionMode.LOCKDOWN,
      );
    });

    test('coexists with the other WKWebpagePreferences setting', () {
      // Both land on the same per-navigation preferences object in the Swift policy delegate, so a
      // guard that neither shadows the other on the wire.
      final map = InAppWebViewSettings(
        preferredHTTPSNavigationPolicy: UpgradeToHTTPSPolicy.ERROR_ON_FAILURE,
        securityRestrictionMode: SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY,
      ).toMap();
      expect(map['preferredHTTPSNavigationPolicy'], 3);
      expect(map['securityRestrictionMode'], 1);
    });
  });
}
