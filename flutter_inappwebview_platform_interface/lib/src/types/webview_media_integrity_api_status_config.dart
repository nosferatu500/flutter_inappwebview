import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'webview_media_integrity_api_status.dart';
import 'webview_media_integrity_api_status_override_rule.dart';
import 'enum_method.dart';

part 'webview_media_integrity_api_status_config.g.dart';

///Class that represents the
///[WebView Media Integrity API](https://developer.android.com/privacy-and-security/webview-media-integrity)
///configuration: a default status for every origin, plus optional per-origin overrides.
///
///Used by [InAppWebViewSettings.webViewMediaIntegrityApiStatus].
@ExchangeableObject()
class WebViewMediaIntegrityApiStatusConfig_ {
  ///The status applied to any origin not matched by [overrideRules].
  WebViewMediaIntegrityApiStatus_ defaultStatus;

  ///Per-origin overrides. An origin matched here uses its own status instead of [defaultStatus].
  ///
  ///Use this to grant app identity to one trusted media provider while leaving every other origin
  ///more restricted.
  ///
  ///Modelled as a list rather than the `Map<String, int>` the Android API takes, for two reasons:
  ///a list keeps the status a typed [WebViewMediaIntegrityApiStatus] instead of a bare int, and it
  ///maps directly onto Android's own per-rule `Builder.addOverrideRule(origin, status)`.
  List<WebViewMediaIntegrityApiStatusOverrideRule_>? overrideRules;

  WebViewMediaIntegrityApiStatusConfig_({
    required this.defaultStatus,
    this.overrideRules,
  });
}
