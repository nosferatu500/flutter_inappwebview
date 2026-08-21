// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_agent_form_factor.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a form factor reported through the
///[User-Agent Client Hints](https://developer.mozilla.org/en-US/docs/Web/HTTP/Client_hints#user-agent_client_hints)
///`Sec-CH-UA-Form-Factors` hint, describing the kind of device the content is running on.
///
///Used by [UserAgentMetadata.formFactors].
class UserAgentFormFactor {
  final String _value;
  final String? _nativeValue;
  const UserAgentFormFactor._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory UserAgentFormFactor._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => UserAgentFormFactor._internal(value, nativeValue());

  ///A device built into a vehicle.
  static const AUTOMOTIVE = UserAgentFormFactor._internal(
    'Automotive',
    'Automotive',
  );

  ///A desktop or laptop computer.
  static const DESKTOP = UserAgentFormFactor._internal('Desktop', 'Desktop');

  ///A device with an electronic-paper display.
  static const EINK = UserAgentFormFactor._internal('EInk', 'EInk');

  ///A phone-sized device.
  static const MOBILE = UserAgentFormFactor._internal('Mobile', 'Mobile');

  ///A tablet-sized device.
  static const TABLET = UserAgentFormFactor._internal('Tablet', 'Tablet');

  ///A wrist-worn device.
  static const WATCH = UserAgentFormFactor._internal('Watch', 'Watch');

  ///An extended-reality headset or similar immersive device.
  static const XR = UserAgentFormFactor._internal('XR', 'XR');

  ///Set of all values of [UserAgentFormFactor].
  static final Set<UserAgentFormFactor> values = {
    UserAgentFormFactor.AUTOMOTIVE,
    UserAgentFormFactor.DESKTOP,
    UserAgentFormFactor.EINK,
    UserAgentFormFactor.MOBILE,
    UserAgentFormFactor.TABLET,
    UserAgentFormFactor.WATCH,
    UserAgentFormFactor.XR,
  };

  ///Gets a possible [UserAgentFormFactor] instance from [String] value.
  static UserAgentFormFactor? fromValue(String? value) {
    if (value != null) {
      try {
        return UserAgentFormFactor.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UserAgentFormFactor] instance from a native value.
  static UserAgentFormFactor? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return UserAgentFormFactor.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [UserAgentFormFactor] instance value with name [name].
  ///
  /// Goes through [UserAgentFormFactor.values] looking for a value with
  /// name [name], as reported by [UserAgentFormFactor.name].
  /// Returns the first value with the given name, otherwise `null`.
  static UserAgentFormFactor? byName(String? name) {
    if (name != null) {
      try {
        return UserAgentFormFactor.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [UserAgentFormFactor] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, UserAgentFormFactor> asNameMap() =>
      <String, UserAgentFormFactor>{
        for (final value in UserAgentFormFactor.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'Automotive':
        return 'AUTOMOTIVE';
      case 'Desktop':
        return 'DESKTOP';
      case 'EInk':
        return 'EINK';
      case 'Mobile':
        return 'MOBILE';
      case 'Tablet':
        return 'TABLET';
      case 'Watch':
        return 'WATCH';
      case 'XR':
        return 'XR';
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
    return _value;
  }
}
