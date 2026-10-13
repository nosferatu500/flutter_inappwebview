// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_agent_metadata.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the
///[User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
///a WebView reports.
///
///Client Hints are the structured replacement for parsing the User-Agent string, which is frozen
///and progressively reduced. Setting this overrides what the WebView reports through the `Sec-CH-UA-*`
///request headers and `navigator.userAgentData`.
///
///Every field is optional: leave one `null` and the WebView keeps its own value for that hint,
///so a caller can override just the brand list without having to restate the platform, model and
///the rest.
///
///Used by [InAppWebViewSettings.userAgentMetadata].
class UserAgentMetadata {
  ///The underlying CPU architecture, reported in `Sec-CH-UA-Arch`, e.g. `arm`.
  String? architecture;

  ///The CPU bitness, reported in `Sec-CH-UA-Bitness`, e.g. `64`.
  ///
  ///`0` means "use the WebView's default".
  int? bitness;

  ///The brand/version pairs reported in `Sec-CH-UA` and `Sec-CH-UA-Full-Version-List`.
  List<UserAgentBrandVersion>? brandVersionList;

  ///The device form factors, reported in `Sec-CH-UA-Form-Factors`.
  ///
  ///**Gated by a second feature flag.** This field is only applied when
  ///[WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS] is supported, which is separate from
  ///[WebViewFeature.USER_AGENT_METADATA]. On a WebView that has the latter but not the former,
  ///every other field here still applies and this one is skipped.
  List<UserAgentFormFactor>? formFactors;

  ///The full browser version, reported in `Sec-CH-UA-Full-Version`.
  String? fullVersion;

  ///Whether the content should be treated as running on a mobile device,
  ///reported in `Sec-CH-UA-Mobile`.
  bool? mobile;

  ///The device model, reported in `Sec-CH-UA-Model`.
  String? model;

  ///The platform name, reported in `Sec-CH-UA-Platform`, e.g. `Android`.
  String? platform;

  ///The platform version, reported in `Sec-CH-UA-Platform-Version`.
  String? platformVersion;

  ///Whether a 32-bit binary is running on 64-bit Windows, reported in `Sec-CH-UA-WoW64`.
  ///Effectively always `false` on Android; present because the hint is part of the standard.
  bool? wow64;
  UserAgentMetadata({
    this.architecture,
    this.bitness,
    this.brandVersionList,
    this.formFactors,
    this.fullVersion,
    this.mobile,
    this.model,
    this.platform,
    this.platformVersion,
    this.wow64,
  });

  ///Gets a possible [UserAgentMetadata] instance from a [Map] value.
  static UserAgentMetadata? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = UserAgentMetadata(
      architecture: map['architecture'],
      bitness: map['bitness'],
      brandVersionList: map['brandVersionList'] != null
          ? List<UserAgentBrandVersion>.from(
              map['brandVersionList'].map(
                (e) => UserAgentBrandVersion.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
      formFactors: map['formFactors'] != null
          ? List<UserAgentFormFactor>.from(
              map['formFactors'].map(
                (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue => UserAgentFormFactor.fromNativeValue(
                    e,
                  ),
                  EnumMethod.value => UserAgentFormFactor.fromValue(e),
                  EnumMethod.name => UserAgentFormFactor.byName(e),
                }!,
              ),
            )
          : null,
      fullVersion: map['fullVersion'],
      mobile: map['mobile'],
      model: map['model'],
      platform: map['platform'],
      platformVersion: map['platformVersion'],
      wow64: map['wow64'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "architecture": architecture,
      "bitness": bitness,
      "brandVersionList": brandVersionList
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "formFactors": formFactors
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "fullVersion": fullVersion,
      "mobile": mobile,
      "model": model,
      "platform": platform,
      "platformVersion": platformVersion,
      "wow64": wow64,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UserAgentMetadata{architecture: $architecture, bitness: $bitness, brandVersionList: $brandVersionList, formFactors: $formFactors, fullVersion: $fullVersion, mobile: $mobile, model: $model, platform: $platform, platformVersion: $platformVersion, wow64: $wow64}';
  }
}
