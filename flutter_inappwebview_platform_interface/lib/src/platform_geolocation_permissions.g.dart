// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_geolocation_permissions.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformGeolocationPermissionsCreationParamsClassSupported
    on PlatformGeolocationPermissionsCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformGeolocationPermissionsCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformGeolocationPermissionsClassSupported
    on PlatformGeolocationPermissions {
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions](https://developer.android.com/reference/android/webkit/GeolocationPermissions))
  ///
  ///Use the [PlatformGeolocationPermissions.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformGeolocationPermissions]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformGeolocationPermissionsMethod {
  ///Can be used to check if the [PlatformGeolocationPermissions.allow] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.allow.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions.allow](https://developer.android.com/reference/android/webkit/GeolocationPermissions#allow(java.lang.String)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformGeolocationPermissions.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  allow,

  ///Can be used to check if the [PlatformGeolocationPermissions.clear] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clear.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions.clear](https://developer.android.com/reference/android/webkit/GeolocationPermissions#clear(java.lang.String)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformGeolocationPermissions.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clear,

  ///Can be used to check if the [PlatformGeolocationPermissions.clearAll] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clearAll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions.clearAll](https://developer.android.com/reference/android/webkit/GeolocationPermissions#clearAll()))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformGeolocationPermissions.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearAll,

  ///Can be used to check if the [PlatformGeolocationPermissions.getAllowed] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getAllowed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions.getAllowed](https://developer.android.com/reference/android/webkit/GeolocationPermissions#getAllowed(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformGeolocationPermissions.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllowed,

  ///Can be used to check if the [PlatformGeolocationPermissions.getOrigins] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getOrigins.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - GeolocationPermissions.getOrigins](https://developer.android.com/reference/android/webkit/GeolocationPermissions#getOrigins(android.webkit.ValueCallback%3Cjava.util.Set%3Cjava.lang.String%3E%3E)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformGeolocationPermissions.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getOrigins,
}

extension _PlatformGeolocationPermissionsMethodSupported
    on PlatformGeolocationPermissions {
  static bool isMethodSupported(
    PlatformGeolocationPermissionsMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformGeolocationPermissionsMethod.allow:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformGeolocationPermissionsMethod.clear:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformGeolocationPermissionsMethod.clearAll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformGeolocationPermissionsMethod.getAllowed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformGeolocationPermissionsMethod.getOrigins:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
