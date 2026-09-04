import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidProfileStore].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProfileStoreCreationParams] for
/// more information.
@immutable
class AndroidProfileStoreCreationParams
    extends PlatformProfileStoreCreationParams {
  /// Creates a new [AndroidProfileStoreCreationParams] instance.
  const AndroidProfileStoreCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProfileStoreCreationParams params,
  ) : super();

  /// Creates a [AndroidProfileStoreCreationParams] instance based on [PlatformProfileStoreCreationParams].
  factory AndroidProfileStoreCreationParams.fromPlatformProfileStoreCreationParams(
    PlatformProfileStoreCreationParams params,
  ) {
    return AndroidProfileStoreCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore}
class AndroidProfileStore extends PlatformProfileStore with ChannelController {
  /// Creates a new [AndroidProfileStore].
  AndroidProfileStore(PlatformProfileStoreCreationParams params)
    : super.implementation(
        params is AndroidProfileStoreCreationParams
            ? params
            : AndroidProfileStoreCreationParams.fromPlatformProfileStoreCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'dev.nosferatu500.inappwebview/inappwebview_profilestore',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static AndroidProfileStore? _instance;

  ///Gets the [AndroidProfileStore] shared instance.
  static AndroidProfileStore instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProfileStore _init() {
    _instance = AndroidProfileStore(
      AndroidProfileStoreCreationParams(
        const PlatformProfileStoreCreationParams(),
      ),
    );
    return _instance!;
  }

  static final AndroidProfileStore _staticValue = AndroidProfileStore(
    AndroidProfileStoreCreationParams(
      const PlatformProfileStoreCreationParams(),
    ),
  );

  /// Provide static access.
  factory AndroidProfileStore.static() {
    return _staticValue;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<List<String>> getAllProfileNames() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return (await channel?.invokeMethod<List>(
          'getAllProfileNames',
          args,
        ))?.cast<String>() ??
        <String>[];
  }

  @override
  Future<String?> getOrCreateProfile({required String name}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('name', () => name);
    return await channel?.invokeMethod<String>('getOrCreateProfile', args);
  }

  @override
  Future<void> addCustomHeader(
    CustomHeader header, {
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('header', () => header.toMap());
    await channel?.invokeMethod('addCustomHeader', args);
  }

  @override
  Future<bool> hasCustomHeader(String headerName, {String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('headerName', () => headerName);
    return await channel?.invokeMethod<bool>('hasCustomHeader', args) ?? false;
  }

  @override
  Future<Set<CustomHeader>> getCustomHeaders({
    String? headerName,
    String? headerValue,
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('headerName', () => headerName);
    args.putIfAbsent('headerValue', () => headerValue);
    final result = await channel?.invokeMethod<List<dynamic>?>(
      'getCustomHeaders',
      args,
    );
    return (result ?? <dynamic>[])
        .map((e) => CustomHeader.fromMap(e?.cast<String, dynamic>())!)
        .toSet();
  }

  @override
  Future<void> clearCustomHeader(
    String headerName, {
    String? headerValue,
    String? profileName,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    args.putIfAbsent('headerName', () => headerName);
    args.putIfAbsent('headerValue', () => headerValue);
    await channel?.invokeMethod('clearCustomHeader', args);
  }

  @override
  Future<void> clearAllCustomHeaders({String? profileName}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('profileName', () => profileName);
    await channel?.invokeMethod('clearAllCustomHeaders', args);
  }

  @override
  Future<bool> deleteProfile({required String name}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('name', () => name);
    return await channel?.invokeMethod<bool>('deleteProfile', args) ?? false;
  }

  @override
  void dispose() {
    // empty
  }
}
