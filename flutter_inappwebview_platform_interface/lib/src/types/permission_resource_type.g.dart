// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_resource_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a type of resource used to ask user's permission.
class PermissionResourceType {
  final String _value;
  final dynamic _nativeValue;

  /// Native values accepted *in addition* to [_nativeValue] when resolving from a
  /// native value. Inbound only -- [toNativeValue] still returns [_nativeValue].
  // ignore: unused_field
  final List<dynamic> _alsoAcceptsNativeValues;
  const PermissionResourceType._internal(
    this._value,
    this._nativeValue, [
    this._alsoAcceptsNativeValues = const [],
  ]);
  // ignore: unused_element
  factory PermissionResourceType._internalMultiPlatform(
    String value,
    Function nativeValue, [
    Function? alsoAcceptsNativeValues,
  ]) => PermissionResourceType._internal(
    value,
    nativeValue(),
    alsoAcceptsNativeValues != null
        ? alsoAcceptsNativeValues() as List<dynamic>
        : const [],
  );

  ///Resource belongs to video capture device, like camera.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PermissionRequest.RESOURCE_VIDEO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE))
  ///- iOS WKWebView 15.0+ ([Official API - WKMediaCaptureType.camera](https://developer.apple.com/documentation/webkit/wkmediacapturetype/camera))
  static final CAMERA = PermissionResourceType._internalMultiPlatform(
    'CAMERA',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android.webkit.resource.VIDEO_CAPTURE';
        case TargetPlatform.iOS:
          return 0;
        default:
          break;
      }
      return null;
    },
  );

  ///A media device or devices that can capture audio and video.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKMediaCaptureType.cameraAndMicrophone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/cameraandmicrophone))
  static final CAMERA_AND_MICROPHONE =
      PermissionResourceType._internalMultiPlatform(
        'CAMERA_AND_MICROPHONE',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return 2;
            default:
              break;
          }
          return null;
        },
      );

  ///Resource belongs to the device’s orientation and motion.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+
  static final DEVICE_ORIENTATION_AND_MOTION =
      PermissionResourceType._internalMultiPlatform(
        'DEVICE_ORIENTATION_AND_MOTION',
        () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS:
              return 'deviceOrientationAndMotion';
            default:
              break;
          }
          return null;
        },
      );

  ///Resource belongs to audio capture device, like microphone.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PermissionRequest.RESOURCE_AUDIO_CAPTURE](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE))
  ///- iOS WKWebView 15.0+ ([Official API - WKMediaCaptureType.microphone](https://developer.apple.com/documentation/webkit/wkmediacapturetype/microphone))
  static final MICROPHONE = PermissionResourceType._internalMultiPlatform(
    'MICROPHONE',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android.webkit.resource.AUDIO_CAPTURE';
        case TargetPlatform.iOS:
          return 1;
        default:
          break;
      }
      return null;
    },
  );

  ///Resource will allow sysex messages to be sent to or received from MIDI devices.
  ///These messages are privileged operations, e.g. modifying sound libraries and sampling data, or even updating the MIDI device's firmware.
  ///Permission may be requested for this resource in API levels 21 and above, if the Android device has been updated to WebView 45 or above.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PermissionRequest.RESOURCE_MIDI_SYSEX](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX))
  static final MIDI_SYSEX = PermissionResourceType._internalMultiPlatform(
    'MIDI_SYSEX',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android.webkit.resource.MIDI_SYSEX';
        default:
          break;
      }
      return null;
    },
  );

  ///Resource belongs to protected media identifier. After the user grants this resource, the origin can use EME APIs to generate the license requests.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID](https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_PROTECTED_MEDIA_ID))
  static final PROTECTED_MEDIA_ID =
      PermissionResourceType._internalMultiPlatform('PROTECTED_MEDIA_ID', () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return 'android.webkit.resource.PROTECTED_MEDIA_ID';
          default:
            break;
        }
        return null;
      });

  ///A resource this version of the plugin does not recognise.
  ///
  ///This constant exists as the **catch-all**: it is what [PermissionRequest] and
  ///[PermissionResponse] resolve to when Android reports a `PermissionRequest.RESOURCE_*`
  ///string, or iOS a `WKMediaCaptureType` raw value, that is not mapped above. Without it
  ///the generated `fromMap` force-unwraps a `null` and throws inside the channel handler,
  ///so `onPermissionRequest` never reaches app code at all.
  ///
  ///Deliberately carries **no** [EnumSupportedPlatforms]: it describes no platform API, and
  ///must survive any future sweep that removes constants by their platform annotation.
  ///It therefore takes its own name as its native value, which neither platform ever sends.
  ///Passing it back in a [PermissionResponse] grants nothing — Android's
  ///`PermissionRequest.grant` ignores resources the request did not ask for, and iOS reads
  ///only the response's action.
  ///
  ///Treat it as "deny unless you know better": there is no way to tell what was asked for.
  static const UNKNOWN = PermissionResourceType._internal('UNKNOWN', 'UNKNOWN');

  ///Set of all values of [PermissionResourceType].
  static final Set<PermissionResourceType> values = {
    PermissionResourceType.CAMERA,
    PermissionResourceType.CAMERA_AND_MICROPHONE,
    PermissionResourceType.DEVICE_ORIENTATION_AND_MOTION,
    PermissionResourceType.MICROPHONE,
    PermissionResourceType.MIDI_SYSEX,
    PermissionResourceType.PROTECTED_MEDIA_ID,
    PermissionResourceType.UNKNOWN,
  };

  ///Gets a possible [PermissionResourceType] instance from [String] value.
  static PermissionResourceType? fromValue(String? value) {
    if (value != null) {
      try {
        return PermissionResourceType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PermissionResourceType] instance from a native value.
  ///
  ///Falls back to constants that declare [value] among their additionally accepted
  ///native values, so a platform reporting more than one code for the same condition
  ///still resolves instead of returning `null`.
  static PermissionResourceType? fromNativeValue(dynamic value) {
    if (value != null) {
      try {
        return PermissionResourceType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        try {
          return PermissionResourceType.values.firstWhere(
            (element) => element._alsoAcceptsNativeValues.contains(value),
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  /// Gets a possible [PermissionResourceType] instance value with name [name].
  ///
  /// Goes through [PermissionResourceType.values] looking for a value with
  /// name [name], as reported by [PermissionResourceType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PermissionResourceType? byName(String? name) {
    if (name != null) {
      try {
        return PermissionResourceType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PermissionResourceType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PermissionResourceType> asNameMap() =>
      <String, PermissionResourceType>{
        for (final value in PermissionResourceType.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [dynamic] native value if supported by the current platform, otherwise `null`.
  dynamic toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'CAMERA':
        return 'CAMERA';
      case 'CAMERA_AND_MICROPHONE':
        return 'CAMERA_AND_MICROPHONE';
      case 'DEVICE_ORIENTATION_AND_MOTION':
        return 'DEVICE_ORIENTATION_AND_MOTION';
      case 'MICROPHONE':
        return 'MICROPHONE';
      case 'MIDI_SYSEX':
        return 'MIDI_SYSEX';
      case 'PROTECTED_MEDIA_ID':
        return 'PROTECTED_MEDIA_ID';
      case 'UNKNOWN':
        return 'UNKNOWN';
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
