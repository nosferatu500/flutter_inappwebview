// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_profile_store.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformProfileStoreCreationParamsClassSupported
    on PlatformProfileStoreCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformProfileStoreCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformProfileStoreClassSupported on PlatformProfileStore {
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProfileStore](https://developer.android.com/reference/androidx/webkit/ProfileStore)):
  ///    - available on Android only if [WebViewFeature.MULTI_PROFILE] feature is supported.
  ///
  ///Use the [PlatformProfileStore.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformProfileStore]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformProfileStoreMethod {
  ///Can be used to check if the [PlatformProfileStore.addCustomHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.addCustomHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - Profile.addCustomHeader](https://developer.android.com/reference/androidx/webkit/Profile#addCustomHeader(androidx.webkit.CustomHeader))):
  ///    - Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [header]: all platforms
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addCustomHeader,

  ///Can be used to check if the [PlatformProfileStore.clearAllCustomHeaders] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.clearAllCustomHeaders.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - Profile.clearAllCustomHeaders](https://developer.android.com/reference/androidx/webkit/Profile#clearAllCustomHeaders())):
  ///    - Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearAllCustomHeaders,

  ///Can be used to check if the [PlatformProfileStore.clearCustomHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.clearCustomHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - Profile.clearCustomHeader](https://developer.android.com/reference/androidx/webkit/Profile#clearCustomHeader(java.lang.String))):
  ///    - Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [headerName]: all platforms
  ///- [headerValue]:
  ///    - Android WebView
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearCustomHeader,

  ///Can be used to check if the [PlatformProfileStore.deleteProfile] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.deleteProfile.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProfileStore.deleteProfile](https://developer.android.com/reference/androidx/webkit/ProfileStore#deleteProfile(java.lang.String))):
  ///    - Requires [WebViewFeature.MULTI_PROFILE]. Returns `false` and deletes nothing if the feature is not supported.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [name]: all platforms
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteProfile,

  ///Can be used to check if the [PlatformProfileStore.getAllProfileNames] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProfileStore.getAllProfileNames](https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames())):
  ///    - Requires [WebViewFeature.MULTI_PROFILE]. Returns an empty list if the feature is not supported.
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllProfileNames,

  ///Can be used to check if the [PlatformProfileStore.getCustomHeaders] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getCustomHeaders.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - Profile.getCustomHeaders](https://developer.android.com/reference/androidx/webkit/Profile#getCustomHeaders())):
  ///    - Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [headerName]:
  ///    - Android WebView
  ///- [headerValue]:
  ///    - Android WebView
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCustomHeaders,

  ///Can be used to check if the [PlatformProfileStore.getOrCreateProfile] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProfileStore.getOrCreateProfile](https://developer.android.com/reference/androidx/webkit/ProfileStore#getOrCreateProfile(java.lang.String))):
  ///    - Requires [WebViewFeature.MULTI_PROFILE]. Returns `null` and creates nothing if the feature is not supported.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [name]: all platforms
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getOrCreateProfile,

  ///Can be used to check if the [PlatformProfileStore.hasCustomHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.hasCustomHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - Profile.hasCustomHeader](https://developer.android.com/reference/androidx/webkit/Profile#hasCustomHeader(java.lang.String))):
  ///    - Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [headerName]: all platforms
  ///- [profileName]:
  ///    - Android WebView
  ///
  ///Use the [PlatformProfileStore.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasCustomHeader,
}

extension _PlatformProfileStoreMethodSupported on PlatformProfileStore {
  static bool isMethodSupported(
    PlatformProfileStoreMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformProfileStoreMethod.addCustomHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.clearAllCustomHeaders:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.clearCustomHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.deleteProfile:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.getAllProfileNames:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.getCustomHeaders:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.getOrCreateProfile:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformProfileStoreMethod.hasCustomHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
