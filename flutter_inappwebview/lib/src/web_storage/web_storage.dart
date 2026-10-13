import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.supported_platforms}
class WebStorage {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage}
  WebStorage({
    required PlatformLocalStorage localStorage,
    required PlatformSessionStorage sessionStorage,
  }) : this.fromPlatformCreationParams(
         params: PlatformWebStorageCreationParams(
           localStorage: localStorage,
           sessionStorage: sessionStorage,
         ),
       );

  /// Constructs a [WebStorage].
  ///
  /// See [WebStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebStorage.fromPlatformCreationParams({
    required PlatformWebStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebStorage(params));

  /// Constructs a [WebStorage] from a specific platform implementation.
  WebStorage.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebStorage] for the current platform.
  final PlatformWebStorage platform;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformWebStorageMethod method, {
    TargetPlatform? platform,
  }) =>
      PlatformWebStorage.static().isMethodSupported(method, platform: platform);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.localStorage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.localStorage.supported_platforms}
  LocalStorage get localStorage =>
      LocalStorage.fromPlatform(platform: platform.localStorage);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.sessionStorage.supported_platforms}
  SessionStorage get sessionStorage =>
      SessionStorage.fromPlatform(platform: platform.sessionStorage);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.dispose}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformWebStorage.dispose.supported_platforms}
  void dispose() => platform.dispose();
}

///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.supported_platforms}
abstract class Storage implements PlatformStorage {
  /// Constructs a [Storage] from a specific platform implementation.
  Storage.fromPlatform({required this.platform});

  /// Implementation of [PlatformStorage] for the current platform.
  final PlatformStorage platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.controller}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.controller.supported_platforms}
  @override
  PlatformInAppWebViewController? get controller => platform.controller;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.webStorageType}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.webStorageType.supported_platforms}
  @override
  WebStorageType get webStorageType => platform.webStorageType;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.length}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.length.supported_platforms}
  @override
  Future<int?> length() => platform.length();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.setItem}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.setItem.supported_platforms}
  @override
  Future<void> setItem({required String key, required dynamic value}) =>
      platform.setItem(key: key, value: value);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.getItem}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.getItem.supported_platforms}
  @override
  Future<dynamic> getItem({required String key}) => platform.getItem(key: key);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.removeItem}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.removeItem.supported_platforms}
  @override
  Future<void> removeItem({required String key}) =>
      platform.removeItem(key: key);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.getItems}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.getItems.supported_platforms}
  @override
  Future<List<WebStorageItem>> getItems() => platform.getItems();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.clear}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.clear.supported_platforms}
  @override
  Future<void> clear() => platform.clear();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.key}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.key.supported_platforms}
  @override
  Future<String> key({required int index}) => platform.key(index: index);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.dispose}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformStorage.dispose.supported_platforms}
  @override
  void dispose() => platform.dispose();
}

///{@macro nosferatu500_inappwebview_platform_interface.PlatformLocalStorage}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformLocalStorage.supported_platforms}
class LocalStorage extends Storage {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformLocalStorage}
  LocalStorage({required InAppWebViewController? controller})
    : this.fromPlatformCreationParams(
        params: PlatformLocalStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller?.platform,
            webStorageType: WebStorageType.LOCAL_STORAGE,
          ),
        ),
      );

  /// Constructs a [LocalStorage].
  ///
  /// See [LocalStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  LocalStorage.fromPlatformCreationParams({
    required PlatformLocalStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformLocalStorage(params));

  /// Constructs a [LocalStorage] from a specific platform implementation.
  LocalStorage.fromPlatform({required PlatformLocalStorage platform})
    : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformLocalStorage] for the current platform.
  @override
  PlatformLocalStorage get platform => super.platform as PlatformLocalStorage;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformLocalStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformLocalStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformLocalStorageMethod method, {
    TargetPlatform? platform,
  }) => PlatformLocalStorage.static().isMethodSupported(
    method,
    platform: platform,
  );
}

///{@macro nosferatu500_inappwebview_platform_interface.PlatformSessionStorage}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformSessionStorage.supported_platforms}
class SessionStorage extends Storage {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformSessionStorage}
  SessionStorage({required InAppWebViewController? controller})
    : this.fromPlatformCreationParams(
        params: PlatformSessionStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller?.platform,
            webStorageType: WebStorageType.SESSION_STORAGE,
          ),
        ),
      );

  /// Constructs a [SessionStorage].
  ///
  /// See [SessionStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  SessionStorage.fromPlatformCreationParams({
    required PlatformSessionStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformSessionStorage(params));

  /// Constructs a [SessionStorage] from a specific platform implementation.
  SessionStorage.fromPlatform({required PlatformSessionStorage platform})
    : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformSessionStorage] for the current platform.
  @override
  PlatformSessionStorage get platform =>
      super.platform as PlatformSessionStorage;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformSessionStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformSessionStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformSessionStorageMethod method, {
    TargetPlatform? platform,
  }) => PlatformSessionStorage.static().isMethodSupported(
    method,
    platform: platform,
  );
}
