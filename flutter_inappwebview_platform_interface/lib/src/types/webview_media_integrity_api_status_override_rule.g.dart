// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_media_integrity_api_status_override_rule.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a single per-origin override in
///[WebViewMediaIntegrityApiStatusConfig.overrideRules].
class WebViewMediaIntegrityApiStatusOverrideRule {
  ///The origin pattern this rule applies to, e.g. `https://*.example.com`.
  String origin;

  ///The status to use for [origin] instead of
  ///[WebViewMediaIntegrityApiStatusConfig.defaultStatus].
  WebViewMediaIntegrityApiStatus status;
  WebViewMediaIntegrityApiStatusOverrideRule({
    required this.origin,
    required this.status,
  });

  ///Gets a possible [WebViewMediaIntegrityApiStatusOverrideRule] instance from a [Map] value.
  static WebViewMediaIntegrityApiStatusOverrideRule? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewMediaIntegrityApiStatusOverrideRule(
      origin: map['origin'],
      status: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          WebViewMediaIntegrityApiStatus.fromNativeValue(map['status']),
        EnumMethod.value => WebViewMediaIntegrityApiStatus.fromValue(
          map['status'],
        ),
        EnumMethod.name => WebViewMediaIntegrityApiStatus.byName(map['status']),
      }!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "origin": origin,
      "status": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => status.toNativeValue(),
        EnumMethod.value => status.toValue(),
        EnumMethod.name => status.name(),
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewMediaIntegrityApiStatusOverrideRule{origin: $origin, status: $status}';
  }
}
