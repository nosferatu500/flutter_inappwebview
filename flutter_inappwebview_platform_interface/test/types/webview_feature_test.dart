import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the wire values of the [WebViewFeature] constants added in §15–§25.
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
/// Each expectation below was read out of `webkit-1.17.0.aar` with `javap -constants`.
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
