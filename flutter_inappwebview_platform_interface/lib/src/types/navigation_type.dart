import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'navigation_type.g.dart';

///Class that represents the type of action triggering a navigation for the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
@ExchangeableEnum()
class NavigationType_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final int? _nativeValue = null;

  const NavigationType_._internal(this._value);

  ///A link with an href attribute was activated by the user.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.linkActivated',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/linkactivated',
        value: 0,
      ),
    ],
  )
  static const LINK_ACTIVATED = NavigationType_._internal('LINK_ACTIVATED');

  ///A form was submitted.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.formSubmitted',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted',
        value: 1,
      ),
    ],
  )
  static const FORM_SUBMITTED = NavigationType_._internal('FORM_SUBMITTED');

  ///An item from the back-forward list was requested.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.formSubmitted',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted',
        value: 2,
      ),
    ],
  )
  static const BACK_FORWARD = NavigationType_._internal('BACK_FORWARD');

  ///The webpage was reloaded.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.reload',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/reload',
        value: 3,
      ),
    ],
  )
  static const RELOAD = NavigationType_._internal('RELOAD');

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.formSubmitted',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/formresubmitted',
        value: 4,
      ),
    ],
  )
  static const FORM_RESUBMITTED = NavigationType_._internal('FORM_RESUBMITTED');

  ///Navigation is taking place for some other reason.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'WKNavigationType.other',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wknavigationtype/other',
        value: -1,
      ),
    ],
  )
  static const OTHER = NavigationType_._internal('OTHER');
}
