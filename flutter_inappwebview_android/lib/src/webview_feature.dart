import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/webview_feature.g.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewFeature].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewFeatureCreationParams] for
/// more information.
@immutable
class AndroidWebViewFeatureCreationParams
    extends PlatformWebViewFeatureCreationParams {
  /// Creates a new [AndroidWebViewFeatureCreationParams] instance.
  const AndroidWebViewFeatureCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewFeatureCreationParams params,
  ) : super();

  /// Creates a [AndroidWebViewFeatureCreationParams] instance based on [PlatformWebViewFeatureCreationParams].
  factory AndroidWebViewFeatureCreationParams.fromPlatformWebViewFeatureCreationParams(
    PlatformWebViewFeatureCreationParams params,
  ) {
    return AndroidWebViewFeatureCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature}
///
/// Transport is Pigeon-generated ([WebViewFeatureHostApi]) rather than a hand-written
/// `MethodChannel`; the fourth channel migrated, after find_interaction (§14),
/// process_global_config (§157) and proxy (§160). There is no `messageChannelSuffix` because both
/// androidx entry points are statics.
class AndroidWebViewFeature extends PlatformWebViewFeature
    implements Disposable {
  /// Creates a new [AndroidWebViewFeature].
  AndroidWebViewFeature(PlatformWebViewFeatureCreationParams params)
    : super.implementation(
        params is AndroidWebViewFeatureCreationParams
            ? params
            : AndroidWebViewFeatureCreationParams.fromPlatformWebViewFeatureCreationParams(
                params,
              ),
      );

  factory AndroidWebViewFeature.static() {
    return instance();
  }

  final WebViewFeatureHostApi _hostApi = WebViewFeatureHostApi();

  static AndroidWebViewFeature? _instance;

  ///Gets the [AndroidWebViewFeature] shared instance.
  static AndroidWebViewFeature instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidWebViewFeature _init() {
    _instance = AndroidWebViewFeature(
      AndroidWebViewFeatureCreationParams(
        const PlatformWebViewFeatureCreationParams(),
      ),
    );
    return _instance!;
  }

  @override
  Future<bool> isFeatureSupported(WebViewFeature feature) async {
    // `toNativeValue()` is typed `String?` because the platform interface's WebViewFeature is an
    // open `_internal(String)` class. All 60 declared constants carry a non-null native value, so
    // this branch is unreachable today -- but it replaces a Kotlin `feature!!` that would have
    // thrown, and answering false is what "a feature androidx cannot be asked about" means.
    final nativeValue = feature.toNativeValue();
    if (nativeValue == null) {
      return false;
    }
    return await _hostApi.isFeatureSupported(nativeValue);
  }

  @override
  Future<bool> isStartupFeatureSupported(WebViewFeature startupFeature) async {
    final nativeValue = startupFeature.toNativeValue();
    if (nativeValue == null) {
      return false;
    }
    return await _hostApi.isStartupFeatureSupported(nativeValue);
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton (see createPlatformWebViewFeature).
  }
}
