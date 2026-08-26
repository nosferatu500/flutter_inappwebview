import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `InAppWebViewSettings.supportsAdaptiveImageGlyph` (iOS 18.0+).
///
/// A plain bool, so there is no enum mapping to get wrong — the thing worth pinning is the **key**,
/// because the Swift side reads it through KVC by name (`ISettings.parse`). A typo in either
/// language produces a setting that is fully wired, compiles, and is silently ignored. That is the
/// §16 "silent hole" failure mode, and the only cheap guard against it is naming the key in a test.
///
/// This is also the last iOS 18.0 setting in §44's inventory, so it is the widest-reach item in the
/// feature run.
void main() {
  group('InAppWebViewSettings.supportsAdaptiveImageGlyph', () {
    test('serialises under the key the Swift side parses', () {
      // Swift: `var supportsAdaptiveImageGlyph = false`, set by KVC from this exact key.
      expect(
        InAppWebViewSettings(
          supportsAdaptiveImageGlyph: true,
        ).toMap()['supportsAdaptiveImageGlyph'],
        true,
      );
    });

    test('is absent when not set, leaving the Swift default of false', () {
      // WebKit documents the default as NO, and the Swift field defaults to false, so an unset
      // field must simply not appear -- there is nothing to send.
      expect(
        InAppWebViewSettings().toMap()['supportsAdaptiveImageGlyph'],
        isNull,
      );
    });

    test('false reaches the wire distinctly from unset', () {
      expect(
        InAppWebViewSettings(
          supportsAdaptiveImageGlyph: false,
        ).toMap()['supportsAdaptiveImageGlyph'],
        false,
      );
    });

    test('round-trips all three states through fromMap', () {
      for (final value in <bool?>[null, false, true]) {
        final back = InAppWebViewSettings.fromMap(
          InAppWebViewSettings(supportsAdaptiveImageGlyph: value).toMap(),
        )!;
        expect(back.supportsAdaptiveImageGlyph, value);
      }
    });

    test('coexists with the other iOS 18.0 configuration setting', () {
      // Both are applied in the same `#available(iOS 18.0)` block in preWKWebViewConfiguration, so a
      // guard that neither shadows the other on the way out.
      final map = InAppWebViewSettings(
        supportsAdaptiveImageGlyph: true,
        writingToolsBehavior: WritingToolsBehavior.COMPLETE,
      ).toMap();
      expect(map['supportsAdaptiveImageGlyph'], true);
      expect(map['writingToolsBehavior'], 1);
    });
  });
}
