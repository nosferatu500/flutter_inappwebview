import 'package:flutter/services.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.supported_platforms}
class PullToRefreshController {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.supported_platforms}
  PullToRefreshController({
    void Function()? onRefresh,
    PullToRefreshSettings? settings,
  }) : this.fromPlatformCreationParams(
         params: PlatformPullToRefreshControllerCreationParams(
           onRefresh: onRefresh,
           settings: settings,
         ),
       );

  /// Constructs a [PullToRefreshController].
  ///
  /// See [PullToRefreshController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  PullToRefreshController.fromPlatformCreationParams({
    required PlatformPullToRefreshControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformPullToRefreshController(params));

  /// Constructs a [PullToRefreshController] from a specific platform implementation.
  PullToRefreshController.fromPlatform({required this.platform});

  /// Implementation of [PlatformPullToRefreshController] for the current platform.
  final PlatformPullToRefreshController platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.settings}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.settings.supported_platforms}
  PullToRefreshSettings get settings => platform.settings;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh.supported_platforms}
  void Function()? get onRefresh => platform.onRefresh;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setEnabled.supported_platforms}
  Future<void> setEnabled(bool enabled) => platform.setEnabled(enabled);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isEnabled}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isEnabled.supported_platforms}
  Future<bool> isEnabled() => platform.isEnabled();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.beginRefreshing}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.beginRefreshing.supported_platforms}
  Future<void> beginRefreshing() => platform.beginRefreshing();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.endRefreshing}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.endRefreshing.supported_platforms}
  Future<void> endRefreshing() => platform.endRefreshing();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isRefreshing}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isRefreshing.supported_platforms}
  Future<bool> isRefreshing() => platform.isRefreshing();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setColor}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setColor.supported_platforms}
  Future<void> setColor(Color color) => platform.setColor(color);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setBackgroundColor}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setBackgroundColor.supported_platforms}
  Future<void> setBackgroundColor(Color color) =>
      platform.setBackgroundColor(color);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setDistanceToTriggerSync}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setDistanceToTriggerSync.supported_platforms}
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) =>
      platform.setDistanceToTriggerSync(distanceToTriggerSync);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setSlingshotDistance}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setSlingshotDistance.supported_platforms}
  Future<void> setSlingshotDistance(int slingshotDistance) =>
      platform.setSlingshotDistance(slingshotDistance);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.getDefaultSlingshotDistance}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.getDefaultSlingshotDistance.supported_platforms}
  Future<int> getDefaultSlingshotDistance() =>
      platform.getDefaultSlingshotDistance();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setIndicatorSize}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setIndicatorSize.supported_platforms}
  Future<void> setIndicatorSize(PullToRefreshSize size) =>
      platform.setIndicatorSize(size);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setStyledTitle}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.setStyledTitle.supported_platforms}
  Future<void> setStyledTitle(AttributedString attributedTitle) =>
      platform.setStyledTitle(attributedTitle);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.dispose}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPullToRefreshController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isPropertySupported}
  static bool isPropertySupported(
    PlatformPullToRefreshControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformPullToRefreshController.isMethodSupported}
  static bool isMethodSupported(
    PlatformPullToRefreshControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
