// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents how a browser window should be added to the main window.
class WindowType {
  final String _value;
  final String? _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<String?> _alsoAcceptsNativeValues;
  const WindowType._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory WindowType._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => WindowType._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<String?>
        : const [],
  );

  ///Adds the new browser window as a child window of the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  static final CHILD = WindowType._internalMultiPlatform('CHILD', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'CHILD';
      case TargetPlatform.windows:
        return 'CHILD';
      default:
        break;
    }
    return null;
  });

  ///Adds the new browser window as a new tab in a tabbed window of the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView 10.12++
  static final TABBED = WindowType._internalMultiPlatform('TABBED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'TABBED';
      default:
        break;
    }
    return null;
  });

  ///Adds the new browser window as a separate new window from the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  static final WINDOW = WindowType._internalMultiPlatform('WINDOW', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'WINDOW';
      case TargetPlatform.windows:
        return 'WINDOW';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [WindowType].
  static final Set<WindowType> values = {
    WindowType.CHILD,
    WindowType.TABBED,
    WindowType.WINDOW,
  };

  ///Gets a possible [WindowType] instance from [String] value.
  static WindowType? fromValue(String? value) {
    if (value != null) {
      try {
        return WindowType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WindowType] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static WindowType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WindowType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return WindowType.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [WindowType] instance value with name [name].
  ///
  /// Goes through [WindowType.values] looking for a value with
  /// name [name], as reported by [WindowType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WindowType? byName(String? name) {
    if (name != null) {
      try {
        return WindowType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WindowType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WindowType> asNameMap() => <String, WindowType>{
    for (final value in WindowType.values) value.name(): value,
  };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'CHILD':
        return 'CHILD';
      case 'TABBED':
        return 'TABBED';
      case 'WINDOW':
        return 'WINDOW';
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
