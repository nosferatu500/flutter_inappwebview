import 'package:flutter/foundation.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';

///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController}
///
///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.supported_platforms}
class FindInteractionController {
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.supported_platforms}
  FindInteractionController({
    void Function(
      PlatformFindInteractionController controller,
      int activeMatchOrdinal,
      int numberOfMatches,
      bool isDoneCounting,
    )?
    onFindResultReceived,
  }) : this.fromPlatformCreationParams(
         params: PlatformFindInteractionControllerCreationParams(
           onFindResultReceived: onFindResultReceived,
         ),
       );

  /// Constructs a [FindInteractionController].
  ///
  /// See [FindInteractionController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  FindInteractionController.fromPlatformCreationParams({
    required PlatformFindInteractionControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformFindInteractionController(params));

  /// Constructs a [FindInteractionController] from a specific platform implementation.
  FindInteractionController.fromPlatform({required this.platform});

  /// Implementation of [PlatformFindInteractionController] for the current platform.
  final PlatformFindInteractionController platform;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived.supported_platforms}
  void Function(
    PlatformFindInteractionController controller,
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  )?
  get onFindResultReceived => platform.onFindResultReceived;

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.findAll}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.findAll.supported_platforms}
  Future<void> findAll({String? find}) => platform.findAll(find: find);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.findNext}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.findNext.supported_platforms}
  Future<void> findNext({bool forward = true}) =>
      platform.findNext(forward: forward);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.clearMatches}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.clearMatches.supported_platforms}
  Future<void> clearMatches() => platform.clearMatches();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.setSearchText}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.setSearchText.supported_platforms}
  Future<void> setSearchText(String? searchText) =>
      platform.setSearchText(searchText);

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.getSearchText}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.getSearchText.supported_platforms}
  Future<String?> getSearchText() => platform.getSearchText();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.isFindNavigatorVisible}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.isFindNavigatorVisible.supported_platforms}
  Future<bool?> isFindNavigatorVisible() => platform.isFindNavigatorVisible();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.updateResultCount}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.updateResultCount.supported_platforms}
  Future<void> updateResultCount() => platform.updateResultCount();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.presentFindNavigator}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.presentFindNavigator.supported_platforms}
  Future<void> presentFindNavigator() => platform.presentFindNavigator();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.dismissFindNavigator}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.dismissFindNavigator.supported_platforms}
  Future<void> dismissFindNavigator() => platform.dismissFindNavigator();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.getActiveFindSession}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.getActiveFindSession.supported_platforms}
  Future<FindSession?> getActiveFindSession() =>
      platform.getActiveFindSession();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.dispose}
  ///
  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) => platform.dispose();

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformFindInteractionController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.isPropertySupported}
  static bool isPropertySupported(
    PlatformFindInteractionControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformFindInteractionController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro nosferatu500_inappwebview_platform_interface.PlatformFindInteractionController.isMethodSupported}
  static bool isMethodSupported(
    PlatformFindInteractionControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformFindInteractionController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
