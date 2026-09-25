import 'dart:ui';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/pull_to_refresh.g.dart';

/// Object specifying creation parameters for creating a [AndroidPullToRefreshController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformPullToRefreshControllerCreationParams] for
/// more information.
class AndroidPullToRefreshControllerCreationParams
    extends PlatformPullToRefreshControllerCreationParams {
  /// Creates a new [AndroidPullToRefreshControllerCreationParams] instance.
  AndroidPullToRefreshControllerCreationParams({
    super.onRefresh,
    super.settings,
  });

  /// Creates a [AndroidPullToRefreshControllerCreationParams] instance based on [PlatformPullToRefreshControllerCreationParams].
  factory AndroidPullToRefreshControllerCreationParams.fromPlatformPullToRefreshControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    return AndroidPullToRefreshControllerCreationParams(
      onRefresh: params.onRefresh,
      settings: params.settings,
    );
  }
}

/// Receives [PullToRefreshFlutterApi] events and forwards them to the controller.
///
/// A separate class rather than having the controller implement the generated API directly:
/// `PlatformPullToRefreshController` already exposes `onRefresh` as a *getter* (the app's callback),
/// and Pigeon generates a *method* of the same name, which Dart rejects as an inconsistent
/// inheritance. §14's collision, back after §180's exception.
class _PullToRefreshFlutterApiImpl implements PullToRefreshFlutterApi {
  _PullToRefreshFlutterApiImpl(this._controller);

  final AndroidPullToRefreshController _controller;

  @override
  void onRefresh() {
    // `{}` rather than null: the hand-written channel logged `call.arguments`, which the Kotlin side
    // sent as an empty map.
    _controller._debugLog('onRefresh', {});
    _controller.onRefresh?.call();
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController}
///
/// Transport is Pigeon-generated ([PullToRefreshHostApi] / [PullToRefreshFlutterApi]) rather than a
/// hand-written `MethodChannel`. The public API is unchanged.
class AndroidPullToRefreshController extends PlatformPullToRefreshController {
  /// Constructs a [AndroidPullToRefreshController].
  AndroidPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) : super.implementation(
        params is AndroidPullToRefreshControllerCreationParams
            ? params
            : AndroidPullToRefreshControllerCreationParams.fromPlatformPullToRefreshControllerCreationParams(
                params,
              ),
      );

  static final AndroidPullToRefreshController _staticValue =
      AndroidPullToRefreshController(
        AndroidPullToRefreshControllerCreationParams(),
      );

  /// Provide static access.
  factory AndroidPullToRefreshController.static() {
    return _staticValue;
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      debugLoggingSettings:
          PlatformPullToRefreshController.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  /// Null until [InternalPullToRefreshController.init], and after [dispose].
  ///
  /// `AndroidPullToRefreshController.static()` never calls `init`, and a controller that is never
  /// attached to a webview never does either, so every method below has to tolerate a null host API.
  /// That matches the previous behaviour, where `channel` was null and `channel?.invokeMethod(...)`
  /// silently did nothing — including the `?? false` / `?? 0` fallbacks of the three getters.
  PullToRefreshHostApi? _hostApi;

  /// Retained so [dispose] can unregister the event handler for this instance's suffix.
  String? _messageChannelSuffix;

  // Every setter's `bool` answer is discarded, as it always has been: it only reports that the
  // layout had not already gone away. See the schema, checklist item 9.

  @override
  Future<void> setEnabled(bool enabled) async {
    await _hostApi?.setEnabled(enabled);
  }

  @override
  Future<bool> isEnabled() async {
    return await _hostApi?.isEnabled() ?? false;
  }

  Future<void> _setRefreshing(bool refreshing) async {
    await _hostApi?.setRefreshing(refreshing);
  }

  @override
  Future<void> beginRefreshing() async {
    return await _setRefreshing(true);
  }

  @override
  Future<void> endRefreshing() async {
    await _setRefreshing(false);
  }

  @override
  Future<bool> isRefreshing() async {
    return await _hostApi?.isRefreshing() ?? false;
  }

  @override
  Future<void> setColor(Color color) async {
    await _hostApi?.setColor(color.toHex());
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    await _hostApi?.setBackgroundColor(color.toHex());
  }

  @override
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {
    await _hostApi?.setDistanceToTriggerSync(distanceToTriggerSync);
  }

  @override
  Future<void> setSlingshotDistance(int slingshotDistance) async {
    await _hostApi?.setSlingshotDistance(slingshotDistance);
  }

  @override
  Future<int> getDefaultSlingshotDistance() async {
    return await _hostApi?.getDefaultSlingshotDistance() ?? 0;
  }

  @override
  Future<void> setIndicatorSize(PullToRefreshSize size) async {
    // `toNativeValue()` is typed nullable only because the generated enum API has one shape for
    // every enum; both of this one's values are platform-independent (`_internal(1, 1)`,
    // `_internal(0, 0)`), so the null is unreachable. `!` rather than a silent early return: the
    // hand-written channel would have failed *loudly* on a null (Kotlin's `!!`), and swallowing it
    // here would be a behaviour change invented by a migration — §168's lesson.
    await _hostApi?.setSize(size.toNativeValue()!);
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    if (!isKeepAlive) {
      // Mirrors disposeChannel(removeMethodCallHandler: true): drop the event handler bound to
      // this instance's suffix, otherwise it outlives the controller. A keep-alive dispose leaves it
      // registered, exactly as the hand-written channel left its method-call handler.
      PullToRefreshFlutterApi.setUp(
        null,
        messageChannelSuffix: _messageChannelSuffix ?? '',
      );
      _messageChannelSuffix = null;
    }
    // disposeChannel() nulled the channel in both cases, so host calls no-op after either kind of
    // dispose.
    _hostApi = null;
  }
}

extension InternalPullToRefreshController on AndroidPullToRefreshController {
  void init(dynamic id) {
    // Pigeon derives one channel per method from the schema and appends this suffix, so the id that
    // used to be interpolated into a single channel name is passed here instead. `'$id'` — the old
    // interpolation — and `toString()` agree for the int view id and the string ids alike.
    final suffix = id.toString();
    _messageChannelSuffix = suffix;
    _hostApi = PullToRefreshHostApi(messageChannelSuffix: suffix);
    PullToRefreshFlutterApi.setUp(
      _PullToRefreshFlutterApiImpl(this),
      messageChannelSuffix: suffix,
    );
  }
}
