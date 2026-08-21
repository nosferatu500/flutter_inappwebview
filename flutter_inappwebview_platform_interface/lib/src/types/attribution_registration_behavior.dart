import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'attribution_registration_behavior.g.dart';

///Class used to configure how a WebView handles registrations for the
///[Attribution Reporting API](https://developer.android.com/design-for-safety/privacy-sandbox/attribution),
///the Privacy Sandbox replacement for cross-site tracking in ad measurement.
///
///A registration has two halves: the **source** (the ad impression or click) and the **trigger**
///(the conversion). Each half can be recorded either against the app, through the platform's
///Attribution Reporting API, or against the web, through the browser-style
///[Attribution Reporting API](https://developer.mozilla.org/en-US/docs/Web/API/Attribution_Reporting_API).
///The values below choose which combination this WebView reports.
///
///Used by [InAppWebViewSettings.attributionRegistrationBehavior].
@ExchangeableEnum()
class AttributionRegistrationBehavior_ {
  // ignore: unused_field
  final int _value;
  const AttributionRegistrationBehavior_._internal(this._value);

  ///No attribution registration is performed. Both `attributionsrc` and the associated JavaScript
  ///APIs stop working.
  static const DISABLED = AttributionRegistrationBehavior_._internal(0);

  ///Sources are registered against the app and triggers against the web.
  ///
  ///Suitable for an app that shows ads in a WebView and wants the impression attributed to the app
  ///while the conversion happens on a website.
  static const APP_SOURCE_AND_WEB_TRIGGER =
      AttributionRegistrationBehavior_._internal(1);

  ///Both sources and triggers are registered against the web, i.e. the WebView behaves like a
  ///browser. Appropriate for apps that are themselves browsers.
  static const WEB_SOURCE_AND_WEB_TRIGGER =
      AttributionRegistrationBehavior_._internal(2);

  ///Both sources and triggers are registered against the app.
  static const APP_SOURCE_AND_APP_TRIGGER =
      AttributionRegistrationBehavior_._internal(3);
}
