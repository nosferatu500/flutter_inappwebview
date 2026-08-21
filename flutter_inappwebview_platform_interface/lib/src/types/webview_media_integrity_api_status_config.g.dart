// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_media_integrity_api_status_config.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the
///[WebView Media Integrity API](https://developer.android.com/privacy-and-security/webview-media-integrity)
///configuration: a default status for every origin, plus optional per-origin overrides.
///
///Used by [InAppWebViewSettings.webViewMediaIntegrityApiStatus].
class WebViewMediaIntegrityApiStatusConfig {
  ///The status applied to any origin not matched by [overrideRules].
  WebViewMediaIntegrityApiStatus defaultStatus;

  ///Per-origin overrides. An origin matched here uses its own status instead of [defaultStatus].
  ///
  ///Use this to grant app identity to one trusted media provider while leaving every other origin
  ///more restricted.
  ///
  ///Modelled as a list rather than the `Map<String, int>` the Android API takes, for two reasons:
  ///a list keeps the status a typed [WebViewMediaIntegrityApiStatus] instead of a bare int, and it
  ///maps directly onto Android's own per-rule `Builder.addOverrideRule(origin, status)`.
  List<WebViewMediaIntegrityApiStatusOverrideRule>? overrideRules;
  WebViewMediaIntegrityApiStatusConfig({
    required this.defaultStatus,
    this.overrideRules,
  });

  ///Gets a possible [WebViewMediaIntegrityApiStatusConfig] instance from a [Map] value.
  static WebViewMediaIntegrityApiStatusConfig? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewMediaIntegrityApiStatusConfig(
      defaultStatus: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          WebViewMediaIntegrityApiStatus.fromNativeValue(map['defaultStatus']),
        EnumMethod.value => WebViewMediaIntegrityApiStatus.fromValue(
          map['defaultStatus'],
        ),
        EnumMethod.name => WebViewMediaIntegrityApiStatus.byName(
          map['defaultStatus'],
        ),
      }!,
      overrideRules: map['overrideRules'] != null
          ? List<WebViewMediaIntegrityApiStatusOverrideRule>.from(
              map['overrideRules'].map(
                (e) => WebViewMediaIntegrityApiStatusOverrideRule.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "defaultStatus": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => defaultStatus.toNativeValue(),
        EnumMethod.value => defaultStatus.toValue(),
        EnumMethod.name => defaultStatus.name(),
      },
      "overrideRules": overrideRules
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewMediaIntegrityApiStatusConfig{defaultStatus: $defaultStatus, overrideRules: $overrideRules}';
  }
}
