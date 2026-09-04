import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for `COOKIE_INTERCEPT` (§125).
///
/// Everything here is invisible to the compiler and to the device tests alike. The map keys are
/// read by name on the Kotlin side, so a rename analyzes clean and arrives as `null`; and the
/// nullability of the setting is load-bearing in a way a `bool` default would quietly destroy.
void main() {
  group('InAppWebViewSettings.includeCookiesOnShouldInterceptRequest', () {
    test('defaults to null rather than false', () {
      // Not cosmetic. `null` means "leave the WebView's own value alone" and is why the Kotlin
      // applies it with `?.let`. A `false` default would make every WebView write the setting at
      // creation, turning a plugin default into a platform write on a value androidx documents
      // no default for.
      expect(
        InAppWebViewSettings().includeCookiesOnShouldInterceptRequest,
        isNull,
      );
    });

    test('is omitted from the map when null, and present when set', () {
      expect(
        InAppWebViewSettings()
            .toMap()['includeCookiesOnShouldInterceptRequest'],
        isNull,
      );
      for (final v in [true, false]) {
        final map = InAppWebViewSettings(
          includeCookiesOnShouldInterceptRequest: v,
        ).toMap();
        expect(
          map['includeCookiesOnShouldInterceptRequest'],
          v,
          reason: 'an explicit $v must reach the native side',
        );
      }
    });

    test('round-trips through fromMap', () {
      final restored = InAppWebViewSettings.fromMap({
        'includeCookiesOnShouldInterceptRequest': true,
      });
      expect(restored?.includeCookiesOnShouldInterceptRequest, isTrue);
    });

    test('is reported Android-only', () {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.includeCookiesOnShouldInterceptRequest,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.includeCookiesOnShouldInterceptRequest,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });

  group('WebResourceResponse.cookies', () {
    test('defaults to null and survives the map round trip', () {
      expect(WebResourceResponse().cookies, isNull);
      expect(WebResourceResponse().toMap()['cookies'], isNull);

      const values = ['a=1; Path=/', 'b=2; HttpOnly'];
      final map = WebResourceResponse(cookies: values).toMap();
      expect(map['cookies'], values);
      expect(WebResourceResponse.fromMap(map)?.cookies, values);
    });

    test('an empty list is preserved, not collapsed to null', () {
      // The Kotlin treats null and empty the same way (both skip the compat path), but the Dart
      // object must not rewrite the caller's value — a test that only checked the non-empty case
      // would pass against an implementation that dropped `[]` on the floor.
      final map = WebResourceResponse(cookies: const <String>[]).toMap();
      expect(map['cookies'], isEmpty);
      expect(map['cookies'], isNotNull);
    });

    test('order is preserved', () {
      // Set-Cookie order decides which value wins for a repeated cookie name, so a Set or an
      // unordered map here would be a real defect.
      const values = ['x=1', 'x=2', 'x=3'];
      expect(WebResourceResponse(cookies: values).toMap()['cookies'], values);
    });
  });

  group('WebViewFeature.COOKIE_INTERCEPT', () {
    test('mirrors the androidx constant name exactly', () {
      // Passed straight to androidx's isFeatureSupported, which THROWS for an unknown string.
      expect(
        WebViewFeature.COOKIE_INTERCEPT.toNativeValue(),
        'COOKIE_INTERCEPT',
      );
      expect(WebViewFeature.fromNativeValue('COOKIE_INTERCEPT'), isNotNull);
      expect(WebViewFeature.values, contains(WebViewFeature.COOKIE_INTERCEPT));
    });
  });
}
