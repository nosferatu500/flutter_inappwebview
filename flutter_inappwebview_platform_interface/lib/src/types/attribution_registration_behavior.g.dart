// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribution_registration_behavior.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

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
class AttributionRegistrationBehavior {
  final int _value;
  final int? _nativeValue;
  const AttributionRegistrationBehavior._internal(
    this._value,
    this._nativeValue,
  );
  // ignore: unused_element
  factory AttributionRegistrationBehavior._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AttributionRegistrationBehavior._internal(value, nativeValue());

  ///Both sources and triggers are registered against the app.
  static const APP_SOURCE_AND_APP_TRIGGER =
      AttributionRegistrationBehavior._internal(3, 3);

  ///Sources are registered against the app and triggers against the web.
  ///
  ///Suitable for an app that shows ads in a WebView and wants the impression attributed to the app
  ///while the conversion happens on a website.
  static const APP_SOURCE_AND_WEB_TRIGGER =
      AttributionRegistrationBehavior._internal(1, 1);

  ///No attribution registration is performed. Both `attributionsrc` and the associated JavaScript
  ///APIs stop working.
  static const DISABLED = AttributionRegistrationBehavior._internal(0, 0);

  ///Both sources and triggers are registered against the web, i.e. the WebView behaves like a
  ///browser. Appropriate for apps that are themselves browsers.
  static const WEB_SOURCE_AND_WEB_TRIGGER =
      AttributionRegistrationBehavior._internal(2, 2);

  ///Set of all values of [AttributionRegistrationBehavior].
  static final Set<AttributionRegistrationBehavior> values = {
    AttributionRegistrationBehavior.APP_SOURCE_AND_APP_TRIGGER,
    AttributionRegistrationBehavior.APP_SOURCE_AND_WEB_TRIGGER,
    AttributionRegistrationBehavior.DISABLED,
    AttributionRegistrationBehavior.WEB_SOURCE_AND_WEB_TRIGGER,
  };

  ///Gets a possible [AttributionRegistrationBehavior] instance from [int] value.
  static AttributionRegistrationBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return AttributionRegistrationBehavior.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AttributionRegistrationBehavior] instance from a native value.
  static AttributionRegistrationBehavior? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AttributionRegistrationBehavior.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AttributionRegistrationBehavior] instance value with name [name].
  ///
  /// Goes through [AttributionRegistrationBehavior.values] looking for a value with
  /// name [name], as reported by [AttributionRegistrationBehavior.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AttributionRegistrationBehavior? byName(String? name) {
    if (name != null) {
      try {
        return AttributionRegistrationBehavior.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AttributionRegistrationBehavior] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AttributionRegistrationBehavior> asNameMap() =>
      <String, AttributionRegistrationBehavior>{
        for (final value in AttributionRegistrationBehavior.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'APP_SOURCE_AND_APP_TRIGGER';
      case 1:
        return 'APP_SOURCE_AND_WEB_TRIGGER';
      case 0:
        return 'DISABLED';
      case 2:
        return 'WEB_SOURCE_AND_WEB_TRIGGER';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
