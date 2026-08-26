import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'security_restriction_mode.g.dart';

///Class used to specify how much additional security hardening a WebView applies to a navigation.
///
///Intended for high-risk browsing contexts — content whose origin you do not control.
@ExchangeableEnum()
class SecurityRestrictionMode_ {
  // ignore: unused_field
  final int _value;
  const SecurityRestrictionMode_._internal(this._value);

  ///No additional security restrictions beyond the WebKit defaults.
  ///
  ///This is the default.
  static const NONE = SecurityRestrictionMode_._internal(0);

  ///Enhanced security protections optimized for maintaining web compatibility.
  ///
  ///Concretely: JavaScript JIT compilation is disabled (interpreter-only execution) and Memory
  ///Tagging Extension coverage is increased across allocations in the WebContent process. Full web
  ///compatibility is retained, so the trade-off is JavaScript performance rather than functionality.
  static const MAXIMIZE_COMPATIBILITY = SecurityRestrictionMode_._internal(1);

  ///Maximum security restrictions, including feature disablement.
  ///
  ///This is the mode the system applies by itself when the device is in Lockdown Mode. Setting it
  ///explicitly opts a single WebView into the same restrictions, which do disable web features and
  ///so may break pages.
  static const LOCKDOWN = SecurityRestrictionMode_._internal(2);
}
