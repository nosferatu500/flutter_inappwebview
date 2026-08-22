import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire values of the [WebViewFeature] constants added in §15–§28.
///
/// `WebViewFeatureManager` on the Android side does no mapping at all — it takes the string
/// straight off the channel and hands it to `androidx.webkit.WebViewFeature.isFeatureSupported`:
///
/// ```kotlin
/// val feature = call.argument<String>("feature")
/// result.success(WebViewFeature.isFeatureSupported(feature!!))
/// ```
///
/// So the string *is* the whole contract, and getting it wrong fails silently: androidx returns
/// `false` for an unrecognised feature, the guarded code is skipped, and the feature simply appears
/// unsupported on every device. Nothing throws and nothing logs.
///
/// Each expectation below was read out of `webkit-1.17.0.aar` with `javap -constants`. Note the map
/// is keyed by the Dart constant name and valued by the *native* string: those are usually equal,
/// but §34 found five androidx flags where they are not, so this cannot be shortened to a
/// name-equals-value check.
void main() {
  group('WebViewFeature native values', () {
    test('match the androidx.webkit constants exactly', () {
      const expected = <String, String>{
        'MUTE_AUDIO': 'MUTE_AUDIO',
        'PAYMENT_REQUEST': 'PAYMENT_REQUEST',
        'WEB_AUTHENTICATION': 'WEB_AUTHENTICATION',
        'DOWNLOAD_FAVICONS_ENABLED': 'DOWNLOAD_FAVICONS_ENABLED',
        'BACK_FORWARD_CACHE': 'BACK_FORWARD_CACHE',
        'ATTRIBUTION_REGISTRATION_BEHAVIOR':
            'ATTRIBUTION_REGISTRATION_BEHAVIOR',
        'WEBVIEW_MEDIA_INTEGRITY_API_STATUS':
            'WEBVIEW_MEDIA_INTEGRITY_API_STATUS',
        'USER_AGENT_METADATA': 'USER_AGENT_METADATA',
        'USER_AGENT_METADATA_FORM_FACTORS': 'USER_AGENT_METADATA_FORM_FACTORS',
        'DEFAULT_TRAFFICSTATS_TAGGING': 'DEFAULT_TRAFFICSTATS_TAGGING',
        'DELETE_BROWSING_DATA': 'DELETE_BROWSING_DATA',
        'MULTI_PROFILE': 'MULTI_PROFILE',
        // The only entry so far whose native value is NOT its constant name (§34). Read out of the
        // AAR: `PRERENDER_WITH_URL = "PRERENDER_URL_V2"`. Mirroring the name here would produce a
        // string androidx has never heard of, and androidx answers those with a silent `false`.
        'PRERENDER_WITH_URL': 'PRERENDER_URL_V2',
      };

      final actual = <String, String?>{
        'MUTE_AUDIO': WebViewFeature.MUTE_AUDIO.toNativeValue(),
        'PAYMENT_REQUEST': WebViewFeature.PAYMENT_REQUEST.toNativeValue(),
        'WEB_AUTHENTICATION': WebViewFeature.WEB_AUTHENTICATION.toNativeValue(),
        'DOWNLOAD_FAVICONS_ENABLED': WebViewFeature.DOWNLOAD_FAVICONS_ENABLED
            .toNativeValue(),
        'BACK_FORWARD_CACHE': WebViewFeature.BACK_FORWARD_CACHE.toNativeValue(),
        'ATTRIBUTION_REGISTRATION_BEHAVIOR': WebViewFeature
            .ATTRIBUTION_REGISTRATION_BEHAVIOR
            .toNativeValue(),
        'WEBVIEW_MEDIA_INTEGRITY_API_STATUS': WebViewFeature
            .WEBVIEW_MEDIA_INTEGRITY_API_STATUS
            .toNativeValue(),
        'USER_AGENT_METADATA': WebViewFeature.USER_AGENT_METADATA
            .toNativeValue(),
        'USER_AGENT_METADATA_FORM_FACTORS': WebViewFeature
            .USER_AGENT_METADATA_FORM_FACTORS
            .toNativeValue(),
        'DEFAULT_TRAFFICSTATS_TAGGING': WebViewFeature
            .DEFAULT_TRAFFICSTATS_TAGGING
            .toNativeValue(),
        'DELETE_BROWSING_DATA': WebViewFeature.DELETE_BROWSING_DATA
            .toNativeValue(),
        'MULTI_PROFILE': WebViewFeature.MULTI_PROFILE.toNativeValue(),
        'PRERENDER_WITH_URL': WebViewFeature.PRERENDER_WITH_URL.toNativeValue(),
      };

      expect(actual, expected);
    });

    test('round-trip through fromNativeValue', () {
      for (final feature in [
        WebViewFeature.MUTE_AUDIO,
        WebViewFeature.PAYMENT_REQUEST,
        WebViewFeature.WEB_AUTHENTICATION,
        WebViewFeature.DOWNLOAD_FAVICONS_ENABLED,
        WebViewFeature.BACK_FORWARD_CACHE,
        WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR,
        WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS,
        WebViewFeature.USER_AGENT_METADATA,
        WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS,
        WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING,
        WebViewFeature.DELETE_BROWSING_DATA,
        WebViewFeature.MULTI_PROFILE,
        WebViewFeature.PRERENDER_WITH_URL,
      ]) {
        expect(
          WebViewFeature.fromNativeValue(feature.toNativeValue()),
          feature,
          reason: '${feature.toNativeValue()} did not round-trip',
        );
      }
    });
  });
}
