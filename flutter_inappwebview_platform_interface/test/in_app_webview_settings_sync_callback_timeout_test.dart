import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// `InAppWebViewSettings.syncCallbackTimeoutMillis` (`TODO.md` P0b.5) — the bound on how long the
/// Android side blocks a WebView worker thread waiting for a Dart answer to
/// `shouldInterceptRequest` or `onLoadResourceWithCustomScheme`.
///
/// Two things here fail silently rather than loudly, which is what these assertions are for:
///
///  * **the map key.** `InAppWebViewSettings.parse` in Kotlin matches on the literal string
///    `"syncCallbackTimeoutMillis"`. A rename on either side means the setting is never applied and
///    the WebView keeps the built-in 10s — no error, no warning, nothing to notice.
///  * **absence vs. a value.** Kotlin skips null values (`if (value == null) continue`) and treats
///    a missing setting as "use `Util.SYNC_CALLBACK_TIMEOUT_MILLIS`". Serialising a default here
///    instead of null would hard-code 10000 into every settings map, which is the same value today
///    and would silently freeze the default for every future release.
///
/// The Kotlin half — that a non-positive value is refused rather than obeyed — is pinned by
/// `UtilTest.resolveSyncCallbackTimeoutMillis refuses a non-positive setting`. It cannot be
/// asserted from Dart: the field is a plain `int?` with no setter to validate in, deliberately, so
/// that the decision lives on the side that consumes it.
void main() {
  group('syncCallbackTimeoutMillis wire shape', () {
    test('serialises under the key the Kotlin side parses', () {
      final map = InAppWebViewSettings(
        syncCallbackTimeoutMillis: 30000,
      ).toMap();

      expect(map['syncCallbackTimeoutMillis'], 30000);
    });

    test('stays null when unset, so the native default stands', () {
      final map = InAppWebViewSettings().toMap();

      expect(map.containsKey('syncCallbackTimeoutMillis'), true);
      expect(map['syncCallbackTimeoutMillis'], isNull);
    });

    test('survives a fromMap round-trip', () {
      final original = InAppWebViewSettings(syncCallbackTimeoutMillis: 45000);
      final restored = InAppWebViewSettings.fromMap(original.toMap());

      expect(restored?.syncCallbackTimeoutMillis, 45000);
    });

    test('a non-positive value crosses the channel unchanged', () {
      // Dart does not validate: 0 and negatives are passed through and refused natively, so that
      // the fallback rule has exactly one home. Pinned here so a future Dart-side clamp is a
      // deliberate change rather than a quiet duplication of the rule.
      expect(
        InAppWebViewSettings(
          syncCallbackTimeoutMillis: 0,
        ).toMap()['syncCallbackTimeoutMillis'],
        0,
      );
      expect(
        InAppWebViewSettings(
          syncCallbackTimeoutMillis: -1,
        ).toMap()['syncCallbackTimeoutMillis'],
        -1,
      );
    });
  });

  group('platform support', () {
    test('the property is Android-only', () {
      // The two callbacks it bounds exist only on Android; iOS has no synchronous WebKit callback
      // and ignores the key entirely (ISettings.parse skips a key it has no property for).
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.syncCallbackTimeoutMillis,
          platform: TargetPlatform.android,
        ),
        true,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.syncCallbackTimeoutMillis,
          platform: TargetPlatform.iOS,
        ),
        false,
      );
    });
  });
}
