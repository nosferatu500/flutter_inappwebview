import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/tracing_controller.g.dart';

/// Object specifying creation parameters for creating a [AndroidTracingController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformTracingControllerCreationParams] for
/// more information.
@immutable
class AndroidTracingControllerCreationParams
    extends PlatformTracingControllerCreationParams {
  /// Creates a new [AndroidTracingControllerCreationParams] instance.
  const AndroidTracingControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformTracingControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidTracingControllerCreationParams] instance based on [PlatformTracingControllerCreationParams].
  factory AndroidTracingControllerCreationParams.fromPlatformTracingControllerCreationParams(
    PlatformTracingControllerCreationParams params,
  ) {
    return AndroidTracingControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformTracingController}
///
/// Transport is Pigeon-generated ([TracingControllerHostApi]) rather than a hand-written
/// `MethodChannel`; the fifth channel migrated, after find_interaction (§14),
/// process_global_config (§157), proxy (§160) and webview_feature (§161). There is no
/// `messageChannelSuffix` because androidx's `TracingController` is a process-wide singleton.
class AndroidTracingController extends PlatformTracingController
    implements Disposable {
  /// Creates a new [AndroidTracingController].
  AndroidTracingController(PlatformTracingControllerCreationParams params)
    : super.implementation(
        params is AndroidTracingControllerCreationParams
            ? params
            : AndroidTracingControllerCreationParams.fromPlatformTracingControllerCreationParams(
                params,
              ),
      );

  final TracingControllerHostApi _hostApi = TracingControllerHostApi();

  static AndroidTracingController? _instance;

  ///Gets the [AndroidTracingController] shared instance.
  static AndroidTracingController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidTracingController _init() {
    _instance = AndroidTracingController(
      AndroidTracingControllerCreationParams(
        const PlatformTracingControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Provide static access.
  factory AndroidTracingController.static() {
    return instance();
  }

  @override
  Future<void> start({required TracingSettings settings}) async {
    // `TracingSettings.categories` is a `List<dynamic>` of `String`s and `TracingCategory`s,
    // because androidx accepts both: name patterns go to `addCategories(String...)` and the
    // predefined `CATEGORIES_*` constants to `addCategories(int...)`. The old wire flattened both
    // into one untyped list and the Kotlin side sorted them back out with `is` checks, silently
    // dropping anything that matched neither. Partitioning here sends each to the field that
    // matches the androidx overload it is destined for.
    final categoryNames = <String>[];
    final predefinedCategories = <int>[];
    for (final category in settings.categories) {
      if (category is String) {
        categoryNames.add(category);
      } else if (category is TracingCategory) {
        final nativeValue = category.toNativeValue();
        if (nativeValue != null) {
          predefinedCategories.add(nativeValue);
        }
      }
      // Anything else is not representable by androidx and is dropped here rather than on the
      // platform side -- same outcome as before, but now it happens where the types are known.
    }

    // The bool the host returns is discarded: the platform interface declares
    // `Future<void> start(...)`, and false means only "the feature is unsupported".
    await _hostApi.start(
      TracingSettingsData(
        categoryNames: categoryNames,
        predefinedCategories: predefinedCategories,
        tracingMode: settings.tracingMode?.toNativeValue(),
      ),
    );
  }

  @override
  Future<bool> stop({String? filePath}) async {
    // Returns androidx's answer directly: false if the framework was not tracing. Note this
    // resolves *before* the trace has finished being written -- poll [isTracing] for that.
    return await _hostApi.stop(filePath);
  }

  @override
  Future<bool> isTracing() async {
    return await _hostApi.isTracing();
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton (see createPlatformTracingController).
  }
}
