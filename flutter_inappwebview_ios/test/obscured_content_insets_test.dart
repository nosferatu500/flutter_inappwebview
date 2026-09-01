import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards `InAppWebViewSettings.obscuredContentInsets` (iOS 26.0+).
///
/// An `EdgeInsets` setting cannot ride on KVC the way a bool can: `ISettings.parse` is
/// selector-based and Swift cannot expose an optional value type to Objective-C at all, so
/// `InAppWebViewSettings.parse` needs an **explicit pre-pass** that reads
/// `settings["obscuredContentInsets"] as? [String: Double]` and then `removeValue(forKey:)`s it. The
/// four map keys are therefore a hand-written contract between the two languages, which is exactly
/// what §24/§36 says a test has to name.
///
/// `minimumViewportInset` / `maximumViewportInset` are the same shape and have had that pre-pass
/// since iOS 15.5; this asserts the new key follows it rather than silently arriving as `null`.
void main() {
  group('InAppWebViewSettings.obscuredContentInsets', () {
    test('serialises to the four keys UIEdgeInsets.fromMap reads', () {
      // Swift: `UIEdgeInsets.fromMap(map:)` over ["top", "left", "bottom", "right"], all Double.
      final map =
          InAppWebViewSettings(
                obscuredContentInsets: const EdgeInsets.fromLTRB(1, 2, 3, 4),
              ).toMap()['obscuredContentInsets']
              as Map<String, dynamic>;

      expect(map.keys.toSet(), <String>{'top', 'left', 'bottom', 'right'});
      // fromLTRB is (left, top, right, bottom) -- spelled out because getting this pairing wrong
      // produces insets on the wrong edges with everything else green.
      expect(map['left'], 1);
      expect(map['top'], 2);
      expect(map['right'], 3);
      expect(map['bottom'], 4);
    });

    test('is absent when unset, leaving WebKit at zero on all sides', () {
      // The Swift applies it with `if let`, so an unset value must not arrive as a zero map: that
      // would overwrite an inset the host app set on the WKWebView itself.
      expect(InAppWebViewSettings().toMap()['obscuredContentInsets'], isNull);
    });

    test('an explicit zero is distinct from unset', () {
      expect(
        InAppWebViewSettings(
          obscuredContentInsets: EdgeInsets.zero,
        ).toMap()['obscuredContentInsets'],
        isNotNull,
      );
    });

    test('round-trips through fromMap', () {
      const insets = EdgeInsets.only(top: 44, bottom: 34);
      final back = InAppWebViewSettings.fromMap(
        InAppWebViewSettings(obscuredContentInsets: insets).toMap(),
      )!;
      expect(back.obscuredContentInsets, insets);
    });

    test('rejects a negative side', () {
      // WebKit's header: "All edge insets must be non-negative." The assert is the only thing
      // between a caller and that requirement, and it is debug-only -- so it is worth pinning that
      // it exists at all.
      expect(
        () => InAppWebViewSettings(
          obscuredContentInsets: const EdgeInsets.only(top: -1),
        ),
        throwsAssertionError,
      );
      expect(
        () => InAppWebViewSettings(
          obscuredContentInsets: const EdgeInsets.only(bottom: -0.5),
        ),
        throwsAssertionError,
      );
    });

    test('does not disturb the viewport-inset assert next to it', () {
      // A control: the two asserts are adjacent in the constructor and both concern EdgeInsets, so
      // this checks the new one did not widen or narrow the old one.
      expect(
        () => InAppWebViewSettings(
          minimumViewportInset: const EdgeInsets.all(20),
          maximumViewportInset: const EdgeInsets.all(10),
        ),
        throwsAssertionError,
      );
      expect(
        InAppWebViewSettings(
          minimumViewportInset: const EdgeInsets.all(10),
          maximumViewportInset: const EdgeInsets.all(20),
          obscuredContentInsets: const EdgeInsets.all(5),
        ).obscuredContentInsets,
        const EdgeInsets.all(5),
      );
    });

    test('is reported iOS-only', () {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.obscuredContentInsets,
          platform: TargetPlatform.iOS,
        ),
        true,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.obscuredContentInsets,
          platform: TargetPlatform.android,
        ),
        false,
      );
    });
  });
}
