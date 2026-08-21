import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'user_agent_form_factor.g.dart';

///Class that represents a form factor reported through the
///[User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
///`Sec-CH-UA-Form-Factors` hint, describing the kind of device the content is running on.
///
///Used by [UserAgentMetadata.formFactors].
@ExchangeableEnum()
class UserAgentFormFactor_ {
  // ignore: unused_field
  final String _value;
  const UserAgentFormFactor_._internal(this._value);

  ///A desktop or laptop computer.
  static const DESKTOP = UserAgentFormFactor_._internal("Desktop");

  ///A device built into a vehicle.
  static const AUTOMOTIVE = UserAgentFormFactor_._internal("Automotive");

  ///A phone-sized device.
  static const MOBILE = UserAgentFormFactor_._internal("Mobile");

  ///A tablet-sized device.
  static const TABLET = UserAgentFormFactor_._internal("Tablet");

  ///An extended-reality headset or similar immersive device.
  static const XR = UserAgentFormFactor_._internal("XR");

  ///A device with an electronic-paper display.
  static const EINK = UserAgentFormFactor_._internal("EInk");

  ///A wrist-worn device.
  static const WATCH = UserAgentFormFactor_._internal("Watch");
}
