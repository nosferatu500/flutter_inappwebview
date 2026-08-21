import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'user_agent_brand_version.dart';
import 'user_agent_form_factor.dart';

part 'user_agent_metadata.g.dart';

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
@ExchangeableObject()
class UserAgentMetadata_ {
  ///The brand/version pairs reported in `Sec-CH-UA` and `Sec-CH-UA-Full-Version-List`.
  List<UserAgentBrandVersion_>? brandVersionList;

  ///The full browser version, reported in `Sec-CH-UA-Full-Version`.
  String? fullVersion;

  ///The platform name, reported in `Sec-CH-UA-Platform`, e.g. `Android`.
  String? platform;

  ///The platform version, reported in `Sec-CH-UA-Platform-Version`.
  String? platformVersion;

  ///The underlying CPU architecture, reported in `Sec-CH-UA-Arch`, e.g. `arm`.
  String? architecture;

  ///The device model, reported in `Sec-CH-UA-Model`.
  String? model;

  ///Whether the content should be treated as running on a mobile device,
  ///reported in `Sec-CH-UA-Mobile`.
  bool? mobile;

  ///The CPU bitness, reported in `Sec-CH-UA-Bitness`, e.g. `64`.
  ///
  ///`0` means "use the WebView's default".
  int? bitness;

  ///Whether a 32-bit binary is running on 64-bit Windows, reported in `Sec-CH-UA-WoW64`.
  ///Effectively always `false` on Android; present because the hint is part of the standard.
  bool? wow64;

  ///The device form factors, reported in `Sec-CH-UA-Form-Factors`.
  ///
  ///**Gated by a second feature flag.** This field is only applied when
  ///[WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS] is supported, which is separate from
  ///[WebViewFeature.USER_AGENT_METADATA]. On a WebView that has the latter but not the former,
  ///every other field here still applies and this one is skipped.
  List<UserAgentFormFactor_>? formFactors;

  UserAgentMetadata_({
    this.brandVersionList,
    this.fullVersion,
    this.platform,
    this.platformVersion,
    this.architecture,
    this.model,
    this.mobile,
    this.bitness,
    this.wow64,
    this.formFactors,
  });
}
