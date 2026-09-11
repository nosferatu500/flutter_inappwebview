import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/process_global_config.g.dart';

/// Object specifying creation parameters for creating a [AndroidProcessGlobalConfig].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProcessGlobalConfigCreationParams] for
/// more information.
@immutable
class AndroidProcessGlobalConfigCreationParams
    extends PlatformProcessGlobalConfigCreationParams {
  /// Creates a new [AndroidProcessGlobalConfigCreationParams] instance.
  const AndroidProcessGlobalConfigCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProcessGlobalConfigCreationParams params,
  ) : super();

  /// Creates a [AndroidProcessGlobalConfigCreationParams] instance based on [PlatformProcessGlobalConfigCreationParams].
  factory AndroidProcessGlobalConfigCreationParams.fromPlatformProcessGlobalConfigCreationParams(
    PlatformProcessGlobalConfigCreationParams params,
  ) {
    return AndroidProcessGlobalConfigCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig}
///
/// Transport is Pigeon-generated ([ProcessGlobalConfigHostApi]) rather than a hand-written
/// `MethodChannel`; the second channel migrated, after find_interaction (§14). There is no
/// `messageChannelSuffix` because `ProcessGlobalConfig.apply` is process-global.
class AndroidProcessGlobalConfig extends PlatformProcessGlobalConfig
    implements Disposable {
  /// Creates a new [AndroidProcessGlobalConfig].
  AndroidProcessGlobalConfig(PlatformProcessGlobalConfigCreationParams params)
    : super.implementation(
        params is AndroidProcessGlobalConfigCreationParams
            ? params
            : AndroidProcessGlobalConfigCreationParams.fromPlatformProcessGlobalConfigCreationParams(
                params,
              ),
      );

  final ProcessGlobalConfigHostApi _hostApi = ProcessGlobalConfigHostApi();

  static AndroidProcessGlobalConfig? _instance;

  ///Gets the [AndroidProcessGlobalConfig] shared instance.
  static AndroidProcessGlobalConfig instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProcessGlobalConfig _init() {
    _instance = AndroidProcessGlobalConfig(
      AndroidProcessGlobalConfigCreationParams(
        const PlatformProcessGlobalConfigCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Provide static access.
  factory AndroidProcessGlobalConfig.static() {
    return instance();
  }

  @override
  Future<void> apply({required ProcessGlobalConfigSettings settings}) async {
    final basePaths = settings.directoryBasePaths;
    // The bool the host returns is discarded: the platform interface declares
    // `Future<void> apply(...)`, and false means only "there was no activity". Kept on the wire so
    // the distinction survives for anyone who later wants to surface it -- see the schema.
    await _hostApi.apply(
      ProcessGlobalConfigSettingsData(
        dataDirectorySuffix: settings.dataDirectorySuffix,
        directoryBasePaths: basePaths == null
            ? null
            : ProcessGlobalConfigDirectoryBasePathsData(
                dataDirectoryBasePath: basePaths.dataDirectoryBasePath,
                cacheDirectoryBasePath: basePaths.cacheDirectoryBasePath,
              ),
      ),
    );
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton (see createPlatformProcessGlobalConfig).
  }
}
