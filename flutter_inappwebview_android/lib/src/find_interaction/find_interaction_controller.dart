import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/find_interaction.g.dart';

/// Object specifying creation parameters for creating a [AndroidFindInteractionController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformFindInteractionControllerCreationParams] for
/// more information.
@immutable
class AndroidFindInteractionControllerCreationParams
    extends PlatformFindInteractionControllerCreationParams {
  /// Creates a new [AndroidFindInteractionControllerCreationParams] instance.
  const AndroidFindInteractionControllerCreationParams({
    super.onFindResultReceived,
  });

  /// Creates a [AndroidFindInteractionControllerCreationParams] instance based on [PlatformFindInteractionControllerCreationParams].
  factory AndroidFindInteractionControllerCreationParams.fromPlatformFindInteractionControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return AndroidFindInteractionControllerCreationParams(
      onFindResultReceived: params.onFindResultReceived,
    );
  }
}

/// Receives [FindInteractionFlutterApi] events and forwards them to the controller.
///
/// A separate class rather than having the controller implement the generated API directly:
/// `PlatformFindInteractionController` already exposes `onFindResultReceived` as a *getter* (the
/// user-supplied callback), and Pigeon generates a *method* of the same name, which Dart rejects
/// as an inconsistent inheritance.
class _FindInteractionFlutterApiImpl implements FindInteractionFlutterApi {
  _FindInteractionFlutterApiImpl(this._controller);

  final AndroidFindInteractionController _controller;

  @override
  void onFindResultReceived(
    int activeMatchOrdinal,
    int numberOfMatches,
    bool isDoneCounting,
  ) {
    _controller._debugLog('onFindResultReceived', {
      'activeMatchOrdinal': activeMatchOrdinal,
      'numberOfMatches': numberOfMatches,
      'isDoneCounting': isDoneCounting,
    });
    _controller.onFindResultReceived?.call(
      _controller,
      activeMatchOrdinal,
      numberOfMatches,
      isDoneCounting,
    );
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController}
///
/// Transport is Pigeon-generated ([FindInteractionHostApi] / [FindInteractionFlutterApi]) rather
/// than a hand-written `MethodChannel`; this is the pilot for migrating the rest of the plugin.
/// The public API is unchanged: everything this class exposes is still platform-interface types,
/// and the generated ones are converted at the boundary.
class AndroidFindInteractionController
    extends PlatformFindInteractionController {
  /// Constructs a [AndroidFindInteractionController].
  AndroidFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) : super.implementation(
        params is AndroidFindInteractionControllerCreationParams
            ? params
            : AndroidFindInteractionControllerCreationParams.fromPlatformFindInteractionControllerCreationParams(
                params,
              ),
      );

  static final AndroidFindInteractionController _staticValue =
      AndroidFindInteractionController(
        AndroidFindInteractionControllerCreationParams(),
      );

  /// Provide static access.
  factory AndroidFindInteractionController.static() {
    return _staticValue;
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      debugLoggingSettings:
          PlatformFindInteractionController.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  /// Null until [InternalFindInteractionController.init], and after [dispose].
  ///
  /// `AndroidFindInteractionController.static()` never calls `init`, so every method below has to
  /// tolerate a null host API. That matches the previous behaviour, where `channel` was null and
  /// `channel?.invokeMethod(...)` silently did nothing.
  FindInteractionHostApi? _hostApi;

  /// Retained so [dispose] can unregister the handler for this instance's suffix.
  String? _messageChannelSuffix;

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.findAll}
  @override
  Future<void> findAll({String? find}) async {
    _debugLog('findAll', {'find': find});
    await _hostApi?.findAll(find);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.findNext}
  @override
  Future<void> findNext({bool forward = true}) async {
    _debugLog('findNext', {'forward': forward});
    await _hostApi?.findNext(forward);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.clearMatches}
  @override
  Future<void> clearMatches() async {
    _debugLog('clearMatches', {});
    await _hostApi?.clearMatches();
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.setSearchText}
  @override
  Future<void> setSearchText(String? searchText) async {
    _debugLog('setSearchText', {'searchText': searchText});
    await _hostApi?.setSearchText(searchText);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.getSearchText}
  @override
  Future<String?> getSearchText() async {
    _debugLog('getSearchText', {});
    return await _hostApi?.getSearchText();
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.getActiveFindSession}
  @override
  Future<FindSession?> getActiveFindSession() async {
    _debugLog('getActiveFindSession', {});
    final session = await _hostApi?.getActiveFindSession();
    if (session == null) {
      return null;
    }
    return FindSession(
      resultCount: session.resultCount,
      highlightedResultIndex: session.highlightedResultIndex,
      // Android always reports NONE; fromNativeValue returns null for an unknown value, and the
      // platform-interface field is non-nullable, so fall back rather than force-unwrap.
      searchResultDisplayStyle:
          SearchResultDisplayStyle.fromNativeValue(
            session.searchResultDisplayStyle,
          ) ??
          SearchResultDisplayStyle.NONE,
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.dispose}
  @override
  void dispose({bool isKeepAlive = false}) {
    if (!isKeepAlive) {
      // Mirrors disposeChannel(removeMethodCallHandler: true): drop the event handler bound to
      // this instance's suffix, otherwise it outlives the controller.
      FindInteractionFlutterApi.setUp(
        null,
        messageChannelSuffix: _messageChannelSuffix ?? '',
      );
      _messageChannelSuffix = null;
    }
    _hostApi = null;
  }
}

extension InternalFindInteractionController
    on AndroidFindInteractionController {
  void init(dynamic id) {
    // Pigeon derives one channel per method from the schema and appends this suffix, so the id
    // that used to be interpolated into a single channel name is passed here instead.
    final suffix = id.toString();
    _messageChannelSuffix = suffix;
    _hostApi = FindInteractionHostApi(messageChannelSuffix: suffix);
    FindInteractionFlutterApi.setUp(
      _FindInteractionFlutterApiImpl(this),
      messageChannelSuffix: suffix,
    );
  }
}
