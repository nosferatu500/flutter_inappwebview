import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the five `androidx.webkit` settings that had no test: `paymentRequestEnabled`,
/// `webAuthenticationSupport`, `downloadFaviconsEnabled`, `backForwardCacheEnabled` and
/// `attributionRegistrationBehavior`.
///
/// Three separate things here fail *silently* rather than loudly:
///
///  * **the map key.** `InAppWebViewSettings.parse` in Kotlin matches on the string, so a renamed
///    key means the setting is simply never applied — no error anywhere.
///  * **the enum's native value.** These are `androidx.webkit` `int` constants that the plugin
///    *copies* rather than reads over the channel. A wrong number applies a different behaviour
///    than the caller asked for, which no compiler can see. The expected values below were read out
///    of `webkit-1.17.0.aar` with
///    `javap -constants androidx.webkit.WebSettingsCompat` (and
///    `androidx.webkit.WebViewMediaIntegrityApiStatusConfig` for the media-integrity trio).
///  * **absence vs. explicit null.** Every nullable field here is applied natively with `?.let`, so
///    "not in the map" must stay distinguishable from "in the map as null" — otherwise the plugin
///    flips a behaviour the caller never asked about (the §18 rule).
void main() {
  group('map keys the Kotlin side parses', () {
    test('each setting serialises under its own name', () {
      final map = InAppWebViewSettings(
        paymentRequestEnabled: true,
        webAuthenticationSupport: WebAuthenticationSupport.FOR_APP,
        downloadFaviconsEnabled: true,
        backForwardCacheEnabled: true,
        attributionRegistrationBehavior:
            AttributionRegistrationBehavior.APP_SOURCE_AND_APP_TRIGGER,
      ).toMap();

      expect(map['paymentRequestEnabled'], true);
      expect(map['downloadFaviconsEnabled'], true);
      expect(map['backForwardCacheEnabled'], true);
      // Enums cross the channel as their native value by default.
      expect(map['webAuthenticationSupport'], 1);
      expect(map['attributionRegistrationBehavior'], 3);
    });

    test('the nullable four stay null when unset, and only paymentRequest defaults', () {
      final map = InAppWebViewSettings().toMap();

      // §16 defaults this one because the platform default is documented and matches.
      expect(map['paymentRequestEnabled'], false);
      // §17/§18/§19/§20 left theirs nullable precisely so the plugin applies nothing.
      expect(map['webAuthenticationSupport'], isNull);
      expect(map['downloadFaviconsEnabled'], isNull);
      expect(map['backForwardCacheEnabled'], isNull);
      expect(map['attributionRegistrationBehavior'], isNull);
    });

    test('all five survive a fromMap round-trip', () {
      final original = InAppWebViewSettings(
        paymentRequestEnabled: true,
        webAuthenticationSupport: WebAuthenticationSupport.FOR_BROWSER,
        downloadFaviconsEnabled: false,
        backForwardCacheEnabled: true,
        attributionRegistrationBehavior:
            AttributionRegistrationBehavior.WEB_SOURCE_AND_WEB_TRIGGER,
      );

      final restored = InAppWebViewSettings.fromMap(original.toMap())!;

      expect(restored.paymentRequestEnabled, isTrue);
      expect(
        restored.webAuthenticationSupport,
        WebAuthenticationSupport.FOR_BROWSER,
      );
      expect(restored.downloadFaviconsEnabled, isFalse);
      expect(restored.backForwardCacheEnabled, isTrue);
      expect(
        restored.attributionRegistrationBehavior,
        AttributionRegistrationBehavior.WEB_SOURCE_AND_WEB_TRIGGER,
      );
    });
  });

  group('native values, pinned against webkit-1.17.0.aar', () {
    test('WebAuthenticationSupport matches WebSettingsCompat', () {
      // WEB_AUTHENTICATION_SUPPORT_NONE / _FOR_APP / _FOR_BROWSER
      expect(WebAuthenticationSupport.NONE.toNativeValue(), 0);
      expect(WebAuthenticationSupport.FOR_APP.toNativeValue(), 1);
      expect(WebAuthenticationSupport.FOR_BROWSER.toNativeValue(), 2);
      expect(WebAuthenticationSupport.values.length, 3);
    });

    test('AttributionRegistrationBehavior matches WebSettingsCompat', () {
      // ATTRIBUTION_BEHAVIOR_DISABLED / _APP_SOURCE_AND_WEB_TRIGGER /
      // _WEB_SOURCE_AND_WEB_TRIGGER / _APP_SOURCE_AND_APP_TRIGGER
      expect(AttributionRegistrationBehavior.DISABLED.toNativeValue(), 0);
      expect(
        AttributionRegistrationBehavior.APP_SOURCE_AND_WEB_TRIGGER
            .toNativeValue(),
        1,
      );
      expect(
        AttributionRegistrationBehavior.WEB_SOURCE_AND_WEB_TRIGGER
            .toNativeValue(),
        2,
      );
      expect(
        AttributionRegistrationBehavior.APP_SOURCE_AND_APP_TRIGGER
            .toNativeValue(),
        3,
      );
      expect(AttributionRegistrationBehavior.values.length, 4);
    });

    test('fromNativeValue is the exact inverse', () {
      for (final v in WebAuthenticationSupport.values) {
        expect(WebAuthenticationSupport.fromNativeValue(v.toNativeValue()), v);
      }
      for (final v in AttributionRegistrationBehavior.values) {
        expect(
          AttributionRegistrationBehavior.fromNativeValue(v.toNativeValue()),
          v,
        );
      }
    });
  });

  group('platform gating', () {
    test('all five report Android-only', () {
      const properties = [
        InAppWebViewSettingsProperty.paymentRequestEnabled,
        InAppWebViewSettingsProperty.webAuthenticationSupport,
        InAppWebViewSettingsProperty.downloadFaviconsEnabled,
        InAppWebViewSettingsProperty.backForwardCacheEnabled,
        InAppWebViewSettingsProperty.attributionRegistrationBehavior,
      ];

      for (final property in properties) {
        expect(
          InAppWebViewSettings.isPropertySupported(
            property,
            platform: TargetPlatform.android,
          ),
          isTrue,
          reason: '$property should be supported on Android',
        );
        expect(
          InAppWebViewSettings.isPropertySupported(
            property,
            platform: TargetPlatform.iOS,
          ),
          isFalse,
          reason: '$property is androidx-only and must not claim iOS',
        );
      }
    });

    test('the enums carry a native value on every constant', () {
      // Both enums are single-platform, so the generator emits `_internal(value, nativeValue)` and
      // `isSupported()` is a null check on that native value rather than a platform test — it
      // cannot answer "is this Android-only?". The property gating above is what does. What this
      // pins is that no constant was added without a native value, which *would* make
      // `isSupported()` false and `toNativeValue()` null on a live platform.
      for (final v in WebAuthenticationSupport.values) {
        expect(v.isSupported(), isTrue, reason: '${v.name()} has no native value');
      }
      for (final v in AttributionRegistrationBehavior.values) {
        expect(v.isSupported(), isTrue, reason: '${v.name()} has no native value');
      }
    });
  });
}
