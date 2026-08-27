// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_orientation.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the orientation of a [PlatformPrintJobController].
class PrintJobOrientation {
  final int _value;
  final int? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<int?> _alsoAcceptsNativeValues;
  const PrintJobOrientation._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory PrintJobOrientation._internalMultiPlatform(
    int value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => PrintJobOrientation._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<int?>
        : const [],
  );

  ///Pages are printed in landscape orientation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  static final LANDSCAPE = PrintJobOrientation._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Pages are printed in portrait orientation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  static final PORTRAIT = PrintJobOrientation._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 0;
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobOrientation].
  static final Set<PrintJobOrientation> values = {
    PrintJobOrientation.LANDSCAPE,
    PrintJobOrientation.PORTRAIT,
  };

  ///Gets a possible [PrintJobOrientation] instance from [int] value.
  static PrintJobOrientation? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOrientation.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobOrientation] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static PrintJobOrientation? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOrientation.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return PrintJobOrientation.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [PrintJobOrientation] instance value with name [name].
  ///
  /// Goes through [PrintJobOrientation.values] looking for a value with
  /// name [name], as reported by [PrintJobOrientation.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobOrientation? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobOrientation.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobOrientation] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobOrientation> asNameMap() =>
      <String, PrintJobOrientation>{
        for (final value in PrintJobOrientation.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'LANDSCAPE';
      case 0:
        return 'PORTRAIT';
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
