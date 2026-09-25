import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import '../pigeons/in_app_browser.g.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

/// Object specifying creation parameters for creating a [AndroidInAppBrowser].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppBrowserCreationParams] for
/// more information.
class AndroidInAppBrowserCreationParams
    extends PlatformInAppBrowserCreationParams {
  /// Creates a new [AndroidInAppBrowserCreationParams] instance.
  AndroidInAppBrowserCreationParams({
    super.contextMenu,
    this.pullToRefreshController,
    this.findInteractionController,
    super.initialUserScripts,
    super.windowId,
  });

  /// Creates a [AndroidInAppBrowserCreationParams] instance based on [PlatformInAppBrowserCreationParams].
  factory AndroidInAppBrowserCreationParams.fromPlatformInAppBrowserCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformInAppBrowserCreationParams params,
  ) {
    return AndroidInAppBrowserCreationParams(
      contextMenu: params.contextMenu,
      pullToRefreshController:
          params.pullToRefreshController as AndroidPullToRefreshController?,
      findInteractionController:
          params.findInteractionController as AndroidFindInteractionController?,
      initialUserScripts: params.initialUserScripts,
      windowId: params.windowId,
    );
  }

  @override
  final AndroidFindInteractionController? findInteractionController;

  @override
  final AndroidPullToRefreshController? pullToRefreshController;
}

/// Receives [InAppBrowserFlutterApi] events and forwards them to the browser.
///
/// A separate class rather than `implements` on [AndroidInAppBrowser]: the generated event names
/// match the platform interface's callbacks, and one class cannot be both (§14).
class _InAppBrowserFlutterApiImpl implements InAppBrowserFlutterApi {
  _InAppBrowserFlutterApiImpl(this._browser);

  final AndroidInAppBrowser _browser;

  @override
  void onBrowserCreated() => _browser._onBrowserCreated();

  @override
  void onMenuItemClicked(int id) => _browser._onMenuItemClicked(id);

  @override
  void onExit() => _browser._onExit();
}

///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser}
///
/// Transport is split (§195): the browser's own methods and events are Pigeon-generated
/// ([InAppBrowserHostApi] / [InAppBrowserFlutterApi], suffixed by [id]). The `inappbrowser_$id`
/// MethodChannel still carries the WebView's surface and the browser's `setSettings` /
/// `getSettings`.
class AndroidInAppBrowser extends PlatformInAppBrowser with ChannelController {
  @override
  final String id = IdGenerator.generate();

  /// Constructs a [AndroidInAppBrowser].
  AndroidInAppBrowser(PlatformInAppBrowserCreationParams params)
    : super.implementation(
        params is AndroidInAppBrowserCreationParams
            ? params
            : AndroidInAppBrowserCreationParams.fromPlatformInAppBrowserCreationParams(
                params,
              ),
      ) {
    _contextMenu = params.contextMenu;
  }

  static final AndroidInAppBrowser _staticValue = AndroidInAppBrowser(
    AndroidInAppBrowserCreationParams(),
  );

  /// Provide static access.
  factory AndroidInAppBrowser.static() {
    return _staticValue;
  }

  AndroidInAppBrowserCreationParams get _androidParams =>
      params as AndroidInAppBrowserCreationParams;

  static const MethodChannel _staticChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappbrowser',
  );

  ContextMenu? _contextMenu;

  @override
  ContextMenu? get contextMenu => _contextMenu;

  final Map<int, InAppBrowserMenuItem> _menuItems = HashMap();
  bool _isOpened = false;
  AndroidInAppWebViewController? _webViewController;
  InAppBrowserHostApi? _hostApi;

  @override
  AndroidInAppWebViewController? get webViewController {
    return _isOpened ? _webViewController : null;
  }

  void _init() {
    channel = MethodChannel('dev.nosferatu500.inappwebview/inappbrowser_$id');
    handler = _handleMethod;
    initMethodCallHandler();
    _hostApi = InAppBrowserHostApi(messageChannelSuffix: id);
    InAppBrowserFlutterApi.setUp(
      _InAppBrowserFlutterApiImpl(this),
      messageChannelSuffix: id,
    );

    _webViewController = AndroidInAppWebViewController.fromInAppBrowser(
      AndroidInAppWebViewControllerCreationParams(id: id),
      channel!,
      this,
      initialUserScripts,
    );
    _androidParams.pullToRefreshController?.init(id);
    _androidParams.findInteractionController?.init(id);
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      id: id,
      debugLoggingSettings: PlatformInAppBrowser.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  /// Everything left on the MethodChannel is the WebView's (§195).
  Future<dynamic> _handleMethod(MethodCall call) async {
    return _webViewController?.handleMethod(call);
  }

  void _onBrowserCreated() {
    _debugLog("onBrowserCreated", <String, dynamic>{});
    eventHandler?.onBrowserCreated();
  }

  void _onMenuItemClicked(int id) {
    _debugLog("onMenuItemClicked", <String, dynamic>{"id": id});
    if (_menuItems[id] != null) {
      if (_menuItems[id]?.onClick != null) {
        _menuItems[id]?.onClick!();
      }
    }
  }

  void _onExit() {
    _debugLog("onExit", <String, dynamic>{});
    _isOpened = false;
    final onExit = eventHandler?.onExit;
    dispose();
    onExit?.call();
  }

  Map<String, dynamic> _prepareOpenRequest({
    InAppBrowserClassSettings? settings,
  }) {
    assert(!_isOpened, 'The browser is already opened.');
    _isOpened = true;
    _init();

    var initialSettings =
        settings?.toMap() ?? InAppBrowserClassSettings().toMap();

    Map<String, dynamic> pullToRefreshSettings =
        pullToRefreshController?.settings.toMap() ??
        PullToRefreshSettings(enabled: false).toMap();

    List<Map<String, dynamic>> menuItemList = [];
    _menuItems.forEach((key, value) {
      menuItemList.add(value.toMap());
    });

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent('settings', () => initialSettings);
    args.putIfAbsent('contextMenu', () => contextMenu?.toMap() ?? {});
    args.putIfAbsent('windowId', () => windowId);
    args.putIfAbsent(
      'initialUserScripts',
      () => initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
    );
    args.putIfAbsent('pullToRefreshSettings', () => pullToRefreshSettings);
    args.putIfAbsent('menuItems', () => menuItemList);
    return args;
  }

  @override
  Future<void> openUrlRequest({
    required URLRequest urlRequest,
    InAppBrowserClassSettings? settings,
  }) async {
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);

    Map<String, dynamic> args = _prepareOpenRequest(settings: settings);
    args.putIfAbsent('urlRequest', () => urlRequest.toMap());
    await _staticChannel.invokeMethod('open', args);
  }

  @override
  Future<void> openFile({
    required String assetFilePath,
    InAppBrowserClassSettings? settings,
  }) async {
    assert(assetFilePath.isNotEmpty);

    Map<String, dynamic> args = _prepareOpenRequest(settings: settings);
    args.putIfAbsent('assetFilePath', () => assetFilePath);
    await _staticChannel.invokeMethod('open', args);
  }

  @override
  Future<void> openData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    WebUri? historyUrl,
    InAppBrowserClassSettings? settings,
  }) async {
    Map<String, dynamic> args = _prepareOpenRequest(settings: settings);
    args.putIfAbsent('data', () => data);
    args.putIfAbsent('mimeType', () => mimeType);
    args.putIfAbsent('encoding', () => encoding);
    args.putIfAbsent('baseUrl', () => baseUrl?.toString() ?? "about:blank");
    args.putIfAbsent(
      'historyUrl',
      () => historyUrl?.toString() ?? "about:blank",
    );
    await _staticChannel.invokeMethod('open', args);
  }

  @override
  Future<void> openWithSystemBrowser({required WebUri url}) async {
    assert(url.toString().isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    return await _staticChannel.invokeMethod('openWithSystemBrowser', args);
  }

  @override
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    _menuItems[menuItem.id] = menuItem;
  }

  @override
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    for (var menuItem in menuItems) {
      _menuItems[menuItem.id] = menuItem;
    }
  }

  @override
  bool removeMenuItem(InAppBrowserMenuItem menuItem) {
    return _menuItems.remove(menuItem.id) != null;
  }

  @override
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    for (final menuItem in menuItems) {
      removeMenuItem(menuItem);
    }
  }

  @override
  void removeAllMenuItem() {
    _menuItems.clear();
  }

  @override
  bool hasMenuItem(InAppBrowserMenuItem menuItem) {
    return _menuItems.containsKey(menuItem.id);
  }

  @override
  Future<void> show() async {
    assert(_isOpened, 'The browser is not opened.');

    await _hostApi?.show();
  }

  @override
  Future<void> hide() async {
    assert(_isOpened, 'The browser is not opened.');

    await _hostApi?.hide();
  }

  @override
  Future<void> close() async {
    assert(_isOpened, 'The browser is not opened.');

    await _hostApi?.close();
  }

  @override
  Future<bool> isHidden() async {
    assert(_isOpened, 'The browser is not opened.');

    return await _hostApi?.isHidden() ?? false;
  }

  @override
  Future<void> setSettings({
    required InAppBrowserClassSettings settings,
  }) async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('settings', () => settings.toMap());
    await channel?.invokeMethod('setSettings', args);
  }

  @override
  Future<InAppBrowserClassSettings?> getSettings() async {
    assert(_isOpened, 'The browser is not opened.');

    Map<String, dynamic> args = <String, dynamic>{};

    Map<dynamic, dynamic>? settings = await channel?.invokeMethod(
      'getSettings',
      args,
    );
    if (settings != null) {
      settings = settings.cast<String, dynamic>();
      return InAppBrowserClassSettings.fromMap(
        settings as Map<String, dynamic>,
      );
    }

    return null;
  }

  @override
  bool isOpened() {
    return _isOpened;
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    disposeChannel();
    // An event handler left registered would outlive the browser it forwards to (§184).
    InAppBrowserFlutterApi.setUp(null, messageChannelSuffix: id);
    _hostApi = null;
    _webViewController?.dispose();
    _webViewController = null;
    pullToRefreshController?.dispose();
    findInteractionController?.dispose();
  }
}

extension InternalInAppBrowser on AndroidInAppBrowser {
  void setContextMenu(ContextMenu? contextMenu) {
    _contextMenu = contextMenu;
  }
}
