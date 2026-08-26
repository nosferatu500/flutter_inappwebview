import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'upgrade_to_https_policy.g.dart';

///Class used to indicate whether a top-level navigation should prefer HTTPS,
///and how a failure to upgrade should be handled.
@ExchangeableEnum()
class UpgradeToHTTPSPolicy_ {
  // ignore: unused_field
  final int _value;
  const UpgradeToHTTPSPolicy_._internal(this._value);

  ///Maintains the current behaviour without preferring HTTPS.
  ///
  ///This is the default.
  static const KEEP_AS_REQUESTED = UpgradeToHTTPSPolicy_._internal(0);

  ///Upgrades HTTP requests to HTTPS, and silently re-attempts the request with HTTP on failure.
  ///
  ///The most permissive of the upgrading modes: a site that cannot serve HTTPS still loads.
  static const AUTOMATIC_FALLBACK_TO_HTTP = UpgradeToHTTPSPolicy_._internal(1);

  ///Upgrades HTTP requests to HTTPS, and shows a warning page on failure,
  ///letting the user decide whether to continue over HTTP.
  static const USER_MEDIATED_FALLBACK_TO_HTTP = UpgradeToHTTPSPolicy_._internal(
    2,
  );

  ///Upgrades HTTP requests to HTTPS, and fails with an error if HTTPS is not available.
  ///
  ///The strictest mode — the HTTPS-Only equivalent. There is no HTTP fallback at all.
  static const ERROR_ON_FAILURE = UpgradeToHTTPSPolicy_._internal(3);
}
