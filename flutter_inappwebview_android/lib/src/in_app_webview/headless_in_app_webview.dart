import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../pigeons/headless_webview.g.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import 'in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [AndroidHeadlessInAppWebView].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformHeadlessInAppWebViewCreationParams] for
/// more information.
@immutable
class AndroidHeadlessInAppWebViewCreationParams
    extends PlatformHeadlessInAppWebViewCreationParams {
  /// Creates a new [AndroidHeadlessInAppWebViewCreationParams] instance.
  AndroidHeadlessInAppWebViewCreationParams({
    super.controllerFromPlatform,
    super.initialSize,
    super.windowId,
    super.onWebViewCreated,
    super.onLoadStart,
    super.onLoadStop,
    super.onReceivedError,
    super.onReceivedHttpError,
    super.onProgressChanged,
    super.onConsoleMessage,
    super.shouldOverrideUrlLoading,
    super.onLoadResource,
    super.onScrollChanged,
    super.onDownloadStarting,
    super.onLoadResourceWithCustomScheme,
    super.onCreateWindow,
    super.onCloseWindow,
    super.onJsAlert,
    super.onJsConfirm,
    super.onJsPrompt,
    super.onReceivedHttpAuthRequest,
    super.onReceivedServerTrustAuthRequest,
    super.onReceivedClientCertRequest,
    super.shouldInterceptAjaxRequest,
    super.onAjaxReadyStateChange,
    super.onAjaxProgress,
    super.shouldInterceptFetchRequest,
    super.onUpdateVisitedHistory,
    super.onPrintRequest,
    super.onLongPressHitTestResult,
    super.onEnterFullscreen,
    super.onExitFullscreen,
    super.onPageCommitVisible,
    super.onNavigationStarted,
    super.onNavigationRedirected,
    super.onNavigationCompleted,
    super.onPageLoadEvent,
    super.onPageDomContentLoadedEvent,
    super.onPageDeleted,
    super.onFirstContentfulPaintMillis,
    super.onLargestContentfulPaintMillis,
    super.onPerformanceMarkMillis,
    super.onRequestVisitedHistory,
    super.onTitleChanged,
    super.onWindowFocus,
    super.onWindowBlur,
    super.onOverScrolled,
    super.onZoomScaleChanged,
    super.onSafeBrowsingHit,
    super.onPermissionRequest,
    super.onGeolocationPermissionsShowPrompt,
    super.onGeolocationPermissionsHidePrompt,
    super.shouldInterceptRequest,
    super.onRenderProcessGone,
    super.onRenderProcessResponsive,
    super.onRenderProcessUnresponsive,
    super.onFormResubmission,
    super.onReceivedTouchIconUrl,
    super.onJsBeforeUnload,
    super.onReceivedLoginRequest,
    super.onPermissionRequestCanceled,
    super.onRequestFocus,
    super.onWebContentProcessDidTerminate,
    super.onDidReceiveServerRedirectForProvisionalNavigation,
    super.onNavigationResponse,
    super.shouldAllowDeprecatedTLS,
    super.onCameraCaptureStateChanged,
    super.onMicrophoneCaptureStateChanged,
    super.onContentSizeChanged,
    super.initialUrlRequest,
    super.initialFile,
    super.initialData,
    super.initialSettings,
    super.contextMenu,
    super.initialUserScripts,
    this.pullToRefreshController,
    this.findInteractionController,
  });

  /// Creates a [AndroidHeadlessInAppWebViewCreationParams] instance based on [PlatformHeadlessInAppWebViewCreationParams].
  AndroidHeadlessInAppWebViewCreationParams.fromPlatformHeadlessInAppWebViewCreationParams(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) : this(
        controllerFromPlatform: params.controllerFromPlatform,
        initialSize: params.initialSize,
        windowId: params.windowId,
        onWebViewCreated: params.onWebViewCreated,
        onLoadStart: params.onLoadStart,
        onLoadStop: params.onLoadStop,
        onReceivedError: params.onReceivedError,
        onReceivedHttpError: params.onReceivedHttpError,
        onProgressChanged: params.onProgressChanged,
        onConsoleMessage: params.onConsoleMessage,
        shouldOverrideUrlLoading: params.shouldOverrideUrlLoading,
        onLoadResource: params.onLoadResource,
        onScrollChanged: params.onScrollChanged,
        onDownloadStarting: params.onDownloadStarting,
        onLoadResourceWithCustomScheme: params.onLoadResourceWithCustomScheme,
        onCreateWindow: params.onCreateWindow,
        onCloseWindow: params.onCloseWindow,
        onJsAlert: params.onJsAlert,
        onJsConfirm: params.onJsConfirm,
        onJsPrompt: params.onJsPrompt,
        onReceivedHttpAuthRequest: params.onReceivedHttpAuthRequest,
        onReceivedServerTrustAuthRequest:
            params.onReceivedServerTrustAuthRequest,
        onReceivedClientCertRequest: params.onReceivedClientCertRequest,
        shouldInterceptAjaxRequest: params.shouldInterceptAjaxRequest,
        onAjaxReadyStateChange: params.onAjaxReadyStateChange,
        onAjaxProgress: params.onAjaxProgress,
        shouldInterceptFetchRequest: params.shouldInterceptFetchRequest,
        onUpdateVisitedHistory: params.onUpdateVisitedHistory,
        onPrintRequest: params.onPrintRequest,
        onLongPressHitTestResult: params.onLongPressHitTestResult,
        onEnterFullscreen: params.onEnterFullscreen,
        onExitFullscreen: params.onExitFullscreen,
        onPageCommitVisible: params.onPageCommitVisible,
        onNavigationStarted: params.onNavigationStarted,
        onNavigationRedirected: params.onNavigationRedirected,
        onNavigationCompleted: params.onNavigationCompleted,
        onPageLoadEvent: params.onPageLoadEvent,
        onPageDomContentLoadedEvent: params.onPageDomContentLoadedEvent,
        onPageDeleted: params.onPageDeleted,
        onFirstContentfulPaintMillis: params.onFirstContentfulPaintMillis,
        onLargestContentfulPaintMillis: params.onLargestContentfulPaintMillis,
        onPerformanceMarkMillis: params.onPerformanceMarkMillis,
        onRequestVisitedHistory: params.onRequestVisitedHistory,
        onTitleChanged: params.onTitleChanged,
        onWindowFocus: params.onWindowFocus,
        onWindowBlur: params.onWindowBlur,
        onOverScrolled: params.onOverScrolled,
        onZoomScaleChanged: params.onZoomScaleChanged,
        onSafeBrowsingHit: params.onSafeBrowsingHit,
        onPermissionRequest: params.onPermissionRequest,
        onGeolocationPermissionsShowPrompt:
            params.onGeolocationPermissionsShowPrompt,
        onGeolocationPermissionsHidePrompt:
            params.onGeolocationPermissionsHidePrompt,
        shouldInterceptRequest: params.shouldInterceptRequest,
        onRenderProcessGone: params.onRenderProcessGone,
        onRenderProcessResponsive: params.onRenderProcessResponsive,
        onRenderProcessUnresponsive: params.onRenderProcessUnresponsive,
        onFormResubmission: params.onFormResubmission,
        onReceivedTouchIconUrl: params.onReceivedTouchIconUrl,
        onJsBeforeUnload: params.onJsBeforeUnload,
        onReceivedLoginRequest: params.onReceivedLoginRequest,
        onPermissionRequestCanceled: params.onPermissionRequestCanceled,
        onRequestFocus: params.onRequestFocus,
        onWebContentProcessDidTerminate: params.onWebContentProcessDidTerminate,
        onDidReceiveServerRedirectForProvisionalNavigation:
            params.onDidReceiveServerRedirectForProvisionalNavigation,
        onNavigationResponse: params.onNavigationResponse,
        shouldAllowDeprecatedTLS: params.shouldAllowDeprecatedTLS,
        onCameraCaptureStateChanged: params.onCameraCaptureStateChanged,
        onMicrophoneCaptureStateChanged: params.onMicrophoneCaptureStateChanged,
        onContentSizeChanged: params.onContentSizeChanged,
        initialUrlRequest: params.initialUrlRequest,
        initialFile: params.initialFile,
        initialData: params.initialData,
        initialSettings: params.initialSettings,
        contextMenu: params.contextMenu,
        initialUserScripts: params.initialUserScripts,
        pullToRefreshController:
            params.pullToRefreshController as AndroidPullToRefreshController?,
        findInteractionController:
            params.findInteractionController
                as AndroidFindInteractionController?,
      );

  @override
  final AndroidFindInteractionController? findInteractionController;

  @override
  final AndroidPullToRefreshController? pullToRefreshController;
}

/// Receives [HeadlessWebViewFlutterApi] events and forwards them to the headless webview.
///
/// A separate class rather than having [AndroidHeadlessInAppWebView] implement the generated API
/// directly. Unlike §14's three previous cases this is **not** forced by the compiler: the callback
/// this event feeds is `params.onWebViewCreated`, a field on the creation-params object, so a
/// same-named method on the class would not be an inconsistent inheritance. It is kept separate
/// because the two would read as the same thing and be different: one is the app's callback, the
/// other is the wire arrival that invokes it.
class _HeadlessWebViewFlutterApiImpl implements HeadlessWebViewFlutterApi {
  _HeadlessWebViewFlutterApiImpl(this._headlessWebView);

  final AndroidHeadlessInAppWebView _headlessWebView;

  @override
  void onWebViewCreated() {
    _headlessWebView._onWebViewCreated();
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView}
///
/// Transport for the per-instance channel is Pigeon-generated ([HeadlessWebViewHostApi] /
/// [HeadlessWebViewFlutterApi]) rather than a hand-written `MethodChannel`. The *manager* channel
/// that carries [run] is still a raw `MethodChannel` ([_sharedChannel]); the two are independent
/// and the manager is the follow-on commit. The public API is unchanged.
class AndroidHeadlessInAppWebView extends PlatformHeadlessInAppWebView {
  @override
  late final String id;

  bool _started = false;
  bool _running = false;

  /// The manager channel, deliberately still hand-written — it carries `run`, which this commit
  /// does not migrate. See the schema header.
  static const MethodChannel _sharedChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/headless_inappwebview',
  );

  /// Null until [run] calls `_init`, and after [dispose].
  ///
  /// `AndroidHeadlessInAppWebView.static()` never runs, so every method below has to tolerate a null
  /// host API. That matches the previous behaviour, where `channel` was null and
  /// `channel?.invokeMethod(...)` silently did nothing.
  HeadlessWebViewHostApi? _hostApi;

  /// Retained so [dispose] can unregister the event handler for this instance's suffix.
  String? _messageChannelSuffix;

  AndroidInAppWebViewController? _webViewController;

  /// Constructs a [AndroidHeadlessInAppWebView].
  AndroidHeadlessInAppWebView(PlatformHeadlessInAppWebViewCreationParams params)
    : super.implementation(
        params is AndroidHeadlessInAppWebViewCreationParams
            ? params
            : AndroidHeadlessInAppWebViewCreationParams.fromPlatformHeadlessInAppWebViewCreationParams(
                params,
              ),
      ) {
    id = IdGenerator.generate();
  }

  static final AndroidHeadlessInAppWebView _staticValue =
      AndroidHeadlessInAppWebView(AndroidHeadlessInAppWebViewCreationParams());

  factory AndroidHeadlessInAppWebView.static() {
    return _staticValue;
  }

  @override
  AndroidInAppWebViewController? get webViewController => _webViewController;

  dynamic _controllerFromPlatform;

  AndroidHeadlessInAppWebViewCreationParams get _androidParams =>
      params as AndroidHeadlessInAppWebViewCreationParams;

  void _init() {
    _webViewController = AndroidInAppWebViewController(
      AndroidInAppWebViewControllerCreationParams(
        id: id,
        webviewParams: params,
      ),
    );
    _controllerFromPlatform =
        params.controllerFromPlatform?.call(_webViewController!) ??
        _webViewController!;
    _androidParams.pullToRefreshController?.init(id);
    _androidParams.findInteractionController?.init(id);
    // Pigeon derives one channel per method from the schema and appends this suffix, so the id that
    // used to be interpolated into a single channel name is passed here instead.
    //
    // 🚨 Registration order is load-bearing and unchanged: `run()` calls this *before* invoking
    // `run` on the manager channel, because the platform fires `onWebViewCreated` while handling
    // that very call. Registering afterwards would be a race, and a missed event on a FlutterApi is
    // silent — `run and dispose` would hang for 60s rather than report anything.
    _messageChannelSuffix = id;
    _hostApi = HeadlessWebViewHostApi(messageChannelSuffix: id);
    HeadlessWebViewFlutterApi.setUp(
      _HeadlessWebViewFlutterApiImpl(this),
      messageChannelSuffix: id,
    );
  }

  void _onWebViewCreated() {
    if (params.onWebViewCreated != null && _webViewController != null) {
      params.onWebViewCreated!(_controllerFromPlatform);
    }
  }

  @override
  Future<void> run() async {
    if (_started) {
      return;
    }
    _started = true;
    _init();

    final initialSettings = params.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap = initialSettings.toMap();

    Map<String, dynamic> pullToRefreshSettings =
        _androidParams.pullToRefreshController?.params.settings.toMap() ??
        PullToRefreshSettings(enabled: false).toMap();

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent(
      'params',
      () => <String, dynamic>{
        'initialUrlRequest': params.initialUrlRequest?.toMap(),
        'initialFile': params.initialFile,
        'initialData': params.initialData?.toMap(),
        'initialSettings': settingsMap,
        'contextMenu': params.contextMenu?.toMap() ?? {},
        'windowId': params.windowId,
        'initialUserScripts':
            params.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
        'pullToRefreshSettings': pullToRefreshSettings,
        'initialSize': params.initialSize.toMap(),
      },
    );
    await _sharedChannel.invokeMethod('run', args);
    _running = true;
  }

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (params.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (params.onLoadResource != null && settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if (params.onDownloadStarting != null &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if ((params.shouldInterceptAjaxRequest != null ||
        params.onAjaxProgress != null ||
        params.onAjaxReadyStateChange != null)) {
      settings.useShouldInterceptAjaxRequest ??= true;
      if (params.onAjaxReadyStateChange != null &&
          settings.useOnAjaxReadyStateChange == null) {
        settings.useOnAjaxReadyStateChange = true;
      }
      if (params.onAjaxProgress != null && settings.useOnAjaxProgress == null) {
        settings.useOnAjaxProgress = true;
      }
    }
    if (params.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (params.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (params.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (params.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
    // One platform listener carries all nine of these events, so ANY of their handlers infers the
    // registration. Without this a handler compiles, reads correctly and never fires.
    if ((params.onNavigationStarted != null ||
            params.onNavigationRedirected != null ||
            params.onNavigationCompleted != null ||
            params.onPageLoadEvent != null ||
            params.onPageDomContentLoadedEvent != null ||
            params.onPageDeleted != null ||
            params.onFirstContentfulPaintMillis != null ||
            params.onLargestContentfulPaintMillis != null ||
            params.onPerformanceMarkMillis != null) &&
        settings.useNavigationListener == null) {
      settings.useNavigationListener = true;
    }
    // `onPerformanceMarkMillis` is inferred ONLY from its own handler, never from the eight
    // others. It is the one unbounded event in the family -- a page can call `performance.mark()`
    // hundreds of times per load -- so opting into the cheap events must not silently opt the app
    // into a channel message per mark.
    if (params.onPerformanceMarkMillis != null &&
        settings.useOnPerformanceMarkMillis == null) {
      settings.useOnPerformanceMarkMillis = true;
    }
    if (params.onShowFileChooser != null &&
        settings.useOnShowFileChooser == null) {
      settings.useOnShowFileChooser = true;
    }
  }

  @override
  bool isRunning() {
    return _running;
  }

  @override
  Future<void> setSize(Size size) async {
    if (!_running) {
      return;
    }

    // The bool the platform answers is discarded, as it always has been: it reports that the
    // webview had not already gone away, which `_running` has just been checked for. See the
    // schema, checklist item 9.
    await _hostApi?.setSize(Size2DData(width: size.width, height: size.height));
  }

  @override
  Future<Size?> getSize() async {
    if (!_running) {
      return null;
    }

    final size = await _hostApi?.getSize();
    if (size == null) {
      return null;
    }
    return Size(size.width, size.height);
  }

  @override
  Future<void> dispose() async {
    if (!_running) {
      return;
    }
    await _hostApi?.dispose();
    // Mirrors disposeChannel(removeMethodCallHandler: true): drop the event handler bound to this
    // instance's suffix, otherwise it outlives the webview.
    HeadlessWebViewFlutterApi.setUp(
      null,
      messageChannelSuffix: _messageChannelSuffix ?? '',
    );
    _messageChannelSuffix = null;
    _hostApi = null;
    _started = false;
    _running = false;
    _webViewController?.dispose();
    _webViewController = null;
    _controllerFromPlatform = null;
    _androidParams.pullToRefreshController?.dispose();
    _androidParams.findInteractionController?.dispose();
  }
}

extension InternalHeadlessInAppWebView on AndroidHeadlessInAppWebView {
  Future<void> internalDispose() async {
    _started = false;
    _running = false;
  }
}
