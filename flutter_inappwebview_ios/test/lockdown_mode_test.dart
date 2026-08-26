import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `InAppWebViewSettings.lockdownModeEnabled`, where the dangerous case is not a wrong value
/// but a **collapsed** one.
///
/// WebKit's default for `WKWebpagePreferences.isLockdownModeEnabled` "depends on the system
/// setting", so this is the one security setting in the package with no safe constant default:
///
/// - `null`  -> the Swift side skips the assignment entirely, and the device's own Lockdown Mode
///              setting stands.
/// - `false` -> the Swift side assigns `false`, **overriding a user who enabled Lockdown Mode**.
///
/// If anything ever makes an unset field serialise as `false` — a default in the Dart constructor, a
/// `?? false` in the generator, a non-optional Swift field — Lockdown Mode silently stops working for
/// every user who turned it on, and nothing else in this repo would notice. Hence a test whose whole
/// job is to assert an absence.
void main() {
  group('InAppWebViewSettings.lockdownModeEnabled', () {
    test('is ABSENT from the wire when not set', () {
      // The load-bearing assertion. `isNull` here means the Swift `if let` never fires.
      expect(InAppWebViewSettings().toMap()['lockdownModeEnabled'], isNull);
    });

    test('false is distinct from unset and does reach the wire', () {
      // Explicitly opting out must still be expressible -- it is a deliberate override.
      expect(
        InAppWebViewSettings(
          lockdownModeEnabled: false,
        ).toMap()['lockdownModeEnabled'],
        false,
      );
    });

    test('true reaches the wire', () {
      expect(
        InAppWebViewSettings(
          lockdownModeEnabled: true,
        ).toMap()['lockdownModeEnabled'],
        true,
      );
    });

    test('round-trips all three states through fromMap', () {
      for (final value in <bool?>[null, false, true]) {
        final back = InAppWebViewSettings.fromMap(
          InAppWebViewSettings(lockdownModeEnabled: value).toMap(),
        )!;
        expect(back.lockdownModeEnabled, value);
      }
    });

    test('is independent of securityRestrictionMode', () {
      // Both land on the same per-navigation WKWebpagePreferences, and the docs recommend
      // MAXIMIZE_COMPATIBILITY over Lockdown for untrusted content -- so a caller may well set the
      // mode while leaving Lockdown alone. That combination must not put a value on the wire.
      final map = InAppWebViewSettings(
        securityRestrictionMode: SecurityRestrictionMode.MAXIMIZE_COMPATIBILITY,
      ).toMap();
      expect(map['securityRestrictionMode'], 1);
      expect(map['lockdownModeEnabled'], isNull);
    });
  });
}
