import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins `WritingToolsBehavior` against `UIWritingToolsBehavior`'s real raw values.
///
/// The Swift side does `UIWritingToolsBehavior(rawValue: settings.writingToolsBehavior)`, so a wrong
/// integer here does not throw — it either selects a *different* behaviour or fails the
/// `init(rawValue:)` and silently leaves WebKit's default in place. Neither is visible to any gate in
/// this repo, which is why the numbers are asserted literally.
///
/// Read out of `UIKit/UITextInputTraits.h` in the iOS 26.5 SDK:
/// ```objc
/// UIWritingToolsBehaviorNone = -1,
/// UIWritingToolsBehaviorDefault = 0,
/// UIWritingToolsBehaviorComplete,   // 1
/// UIWritingToolsBehaviorLimited,    // 2
/// ```
void main() {
  group('WritingToolsBehavior native values', () {
    test('match UIWritingToolsBehavior', () {
      // NONE is -1, not 0 -- the one value an implementer is likely to get wrong by assuming a
      // zero-based enum.
      expect(WritingToolsBehavior.NONE.toNativeValue(), -1);
      expect(WritingToolsBehavior.DEFAULT.toNativeValue(), 0);
      expect(WritingToolsBehavior.COMPLETE.toNativeValue(), 1);
      expect(WritingToolsBehavior.LIMITED.toNativeValue(), 2);
      expect(WritingToolsBehavior.values, hasLength(4));
    });

    test('round-trips through fromNativeValue', () {
      for (final b in WritingToolsBehavior.values) {
        expect(WritingToolsBehavior.fromNativeValue(b.toNativeValue()), b);
      }
    });
  });

  group('InAppWebViewSettings.writingToolsBehavior', () {
    test('serialises under the key the Swift side parses', () {
      final settings = InAppWebViewSettings(
        writingToolsBehavior: WritingToolsBehavior.COMPLETE,
      );

      // Swift: settings["writingToolsBehavior"] reaches the `_writingToolsBehavior` NSNumber ivar
      // through KVC's ivar fallback in ISettings.parse.
      expect(settings.toMap()['writingToolsBehavior'], 1);
    });

    test('is absent rather than defaulted when not set', () {
      // §18's rule: WebKit's default is documented as equivalent to LIMITED (2), while
      // UIWritingToolsBehaviorDefault is 0. Sending either unasked would change behaviour, so an
      // unset field must not appear on the wire with a value.
      expect(InAppWebViewSettings().toMap()['writingToolsBehavior'], isNull);
    });

    test('survives a fromMap round-trip', () {
      final map = InAppWebViewSettings(
        writingToolsBehavior: WritingToolsBehavior.NONE,
      ).toMap();
      final back = InAppWebViewSettings.fromMap(map)!;
      expect(back.writingToolsBehavior, WritingToolsBehavior.NONE);
    });
  });
}
