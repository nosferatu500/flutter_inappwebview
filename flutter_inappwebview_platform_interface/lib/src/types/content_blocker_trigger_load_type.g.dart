// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_trigger_load_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the possible load type for a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadType {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const ContentBlockerTriggerLoadType._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory ContentBlockerTriggerLoadType._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => ContentBlockerTriggerLoadType._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY = ContentBlockerTriggerLoadType._internal(
    'first-party',
    'first-party',
  );

  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY = ContentBlockerTriggerLoadType._internal(
    'third-party',
    'third-party',
  );

  ///Set of all values of [ContentBlockerTriggerLoadType].
  static final Set<ContentBlockerTriggerLoadType> values = {
    ContentBlockerTriggerLoadType.FIRST_PARTY,
    ContentBlockerTriggerLoadType.THIRD_PARTY,
  };

  ///Gets a possible [ContentBlockerTriggerLoadType] instance from [String] value.
  static ContentBlockerTriggerLoadType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerTriggerLoadType] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static ContentBlockerTriggerLoadType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return ContentBlockerTriggerLoadType.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [ContentBlockerTriggerLoadType] instance value with name [name].
  ///
  /// Goes through [ContentBlockerTriggerLoadType.values] looking for a value with
  /// name [name], as reported by [ContentBlockerTriggerLoadType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ContentBlockerTriggerLoadType? byName(String? name) {
    if (name != null) {
      try {
        return ContentBlockerTriggerLoadType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ContentBlockerTriggerLoadType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ContentBlockerTriggerLoadType> asNameMap() =>
      <String, ContentBlockerTriggerLoadType>{
        for (final value in ContentBlockerTriggerLoadType.values)
          value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'first-party':
        return 'FIRST_PARTY';
      case 'third-party':
        return 'THIRD_PARTY';
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
