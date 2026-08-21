import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'webview_media_integrity_api_status.dart';
import 'enum_method.dart';

part 'webview_media_integrity_api_status_override_rule.g.dart';

///Class that represents a single per-origin override in
///[WebViewMediaIntegrityApiStatusConfig.overrideRules].
@ExchangeableObject()
class WebViewMediaIntegrityApiStatusOverrideRule_ {
  ///The origin pattern this rule applies to, e.g. `https://*.example.com`.
  String origin;

  ///The status to use for [origin] instead of
  ///[WebViewMediaIntegrityApiStatusConfig.defaultStatus].
  WebViewMediaIntegrityApiStatus_ status;

  WebViewMediaIntegrityApiStatusOverrideRule_({
    required this.origin,
    required this.status,
  });
}
