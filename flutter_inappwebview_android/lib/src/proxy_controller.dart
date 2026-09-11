import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/proxy.g.dart';

/// Object specifying creation parameters for creating a [AndroidProxyController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProxyControllerCreationParams] for
/// more information.
@immutable
class AndroidProxyControllerCreationParams
    extends PlatformProxyControllerCreationParams {
  /// Creates a new [AndroidProxyControllerCreationParams] instance.
  const AndroidProxyControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProxyControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidProxyControllerCreationParams] instance based on [PlatformProxyControllerCreationParams].
  factory AndroidProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
    PlatformProxyControllerCreationParams params,
  ) {
    return AndroidProxyControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformProxyController}
///
/// Transport is Pigeon-generated ([ProxyHostApi]) rather than a hand-written `MethodChannel`; the
/// third channel migrated, after find_interaction (§14) and process_global_config (§157). There is
/// no `messageChannelSuffix` because androidx's `ProxyController` is a process-wide singleton.
class AndroidProxyController extends PlatformProxyController
    implements Disposable {
  /// Creates a new [AndroidProxyController].
  AndroidProxyController(PlatformProxyControllerCreationParams params)
    : super.implementation(
        params is AndroidProxyControllerCreationParams
            ? params
            : AndroidProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
                params,
              ),
      );

  final ProxyHostApi _hostApi = ProxyHostApi();

  static AndroidProxyController? _instance;

  ///Gets the [AndroidProxyController] shared instance.
  static AndroidProxyController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProxyController _init() {
    _instance = AndroidProxyController(
      AndroidProxyControllerCreationParams(
        const PlatformProxyControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  /// Provide static access.
  factory AndroidProxyController.static() {
    return instance();
  }

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    // The bool the host returns is discarded: the platform interface declares
    // `Future<void> setProxyOverride(...)`, and false means only "androidx does not support
    // PROXY_OVERRIDE". Kept on the wire so the distinction survives -- see the schema.
    await _hostApi.setProxyOverride(
      ProxySettingsData(
        bypassRules: settings.bypassRules,
        directs: settings.directs,
        // Only `url` and `schemeFilter` cross the wire. `ProxyRule` carries seven further fields,
        // all iOS-only, and its `toMap()` used to send every one of them to a Kotlin side that
        // read neither -- see the schema for why that was worse than merely wasteful.
        proxyRules: settings.proxyRules
            .map(
              (rule) => ProxyRuleData(
                url: rule.url,
                schemeFilter: rule.schemeFilter?.toNativeValue(),
              ),
            )
            .toList(),
        reverseBypassEnabled: settings.reverseBypassEnabled,
        bypassSimpleHostnames: settings.bypassSimpleHostnames,
        removeImplicitRules: settings.removeImplicitRules,
      ),
    );
  }

  @override
  Future<void> clearProxyOverride() async {
    await _hostApi.clearProxyOverride();
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton (see createPlatformProxyController).
  }
}
