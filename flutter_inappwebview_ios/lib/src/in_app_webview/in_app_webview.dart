import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '_static_channel.dart';
import 'headless_in_app_webview.dart';
import 'in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class IOSInAppWebViewWidgetCreationParams
    extends PlatformInAppWebViewWidgetCreationParams {
  IOSInAppWebViewWidgetCreationParams({
    super.controllerFromPlatform,
    super.key,
    super.layoutDirection,
    super.gestureRecognizers,
    super.headlessWebView,
    super.keepAlive,
    super.preventGestureDelay,
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
    super.onShowFileChooser,
    super.onInsertInputSuggestion,
    super.onRequestFocus,
    super.onWebContentProcessDidTerminate,
    super.onDidReceiveServerRedirectForProvisionalNavigation,
    super.onNavigationResponse,
    super.shouldAllowDeprecatedTLS,
    super.onCameraCaptureStateChanged,
    super.onMicrophoneCaptureStateChanged,
    super.shouldGoToBackForwardListItem,
    super.onWritingToolsActiveChanged,
    super.onContentSizeChanged,
    super.initialUrlRequest,
    super.initialFile,
    super.initialData,
    super.initialSettings,
    super.contextMenu,
    super.initialUserScripts,
    IOSPullToRefreshController? super.pullToRefreshController,
    IOSFindInteractionController? super.findInteractionController,
  });

  /// Constructs a [IOSInAppWebViewWidgetCreationParams] using a
  /// [PlatformInAppWebViewWidgetCreationParams].
  IOSInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
    PlatformInAppWebViewWidgetCreationParams params,
  ) : this(
        controllerFromPlatform: params.controllerFromPlatform,
        key: params.key,
        layoutDirection: params.layoutDirection,
        gestureRecognizers: params.gestureRecognizers,
        headlessWebView: params.headlessWebView,
        keepAlive: params.keepAlive,
        preventGestureDelay: params.preventGestureDelay,
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
        onShowFileChooser: params.onShowFileChooser,
        onInsertInputSuggestion: params.onInsertInputSuggestion,
        onRequestFocus: params.onRequestFocus,
        onWebContentProcessDidTerminate: params.onWebContentProcessDidTerminate,
        onDidReceiveServerRedirectForProvisionalNavigation:
            params.onDidReceiveServerRedirectForProvisionalNavigation,
        onNavigationResponse: params.onNavigationResponse,
        shouldAllowDeprecatedTLS: params.shouldAllowDeprecatedTLS,
        onCameraCaptureStateChanged: params.onCameraCaptureStateChanged,
        onMicrophoneCaptureStateChanged: params.onMicrophoneCaptureStateChanged,
        shouldGoToBackForwardListItem: params.shouldGoToBackForwardListItem,
        onWritingToolsActiveChanged: params.onWritingToolsActiveChanged,
        onContentSizeChanged: params.onContentSizeChanged,
        initialUrlRequest: params.initialUrlRequest,
        initialFile: params.initialFile,
        initialData: params.initialData,
        initialSettings: params.initialSettings,
        contextMenu: params.contextMenu,
        initialUserScripts: params.initialUserScripts,
        pullToRefreshController:
            params.pullToRefreshController as IOSPullToRefreshController?,
        findInteractionController:
            params.findInteractionController as IOSFindInteractionController?,
      );

  @override
  IOSFindInteractionController? get findInteractionController =>
      super.findInteractionController as IOSFindInteractionController?;

  @override
  IOSPullToRefreshController? get pullToRefreshController =>
      super.pullToRefreshController as IOSPullToRefreshController?;
}

///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
class IOSInAppWebViewWidget extends PlatformInAppWebViewWidget {
  /// Constructs a [IOSInAppWebViewWidget].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
  IOSInAppWebViewWidget(PlatformInAppWebViewWidgetCreationParams params)
    : super.implementation(
        params is IOSInAppWebViewWidgetCreationParams
            ? params
            : IOSInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
                params,
              ),
      );

  IOSInAppWebViewWidgetCreationParams get _iosParams =>
      params as IOSInAppWebViewWidgetCreationParams;

  IOSInAppWebViewController? _controller;

  /// The engine's id for this widget's platform view, which the native side disposes by.
  int? _platformViewId;

  IOSHeadlessInAppWebView? get _iosHeadlessInAppWebView =>
      params.headlessWebView as IOSHeadlessInAppWebView?;

  static final IOSInAppWebViewWidget _staticValue = IOSInAppWebViewWidget(
    IOSInAppWebViewWidgetCreationParams(),
  );

  factory IOSInAppWebViewWidget.static() {
    return _staticValue;
  }

  @override
  Widget build(BuildContext context) {
    final initialSettings = params.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap = initialSettings.toMap();

    Map<String, dynamic> pullToRefreshSettings =
        params.pullToRefreshController?.params.settings.toMap() ??
        PullToRefreshSettings(enabled: false).toMap();

    if ((params.headlessWebView?.isRunning() ?? false) &&
        params.keepAlive != null) {
      final headlessId = params.headlessWebView?.id;
      if (headlessId != null) {
        // force keep alive id to match headless webview id
        params.keepAlive?.id = headlessId;
      }
    }

    return UiKitView(
      viewType: 'dev.nosferatu500.inappwebview/inappwebview',
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: params.gestureRecognizers,
      creationParams: <String, dynamic>{
        'initialUrlRequest': params.initialUrlRequest?.toMap(),
        'initialFile': params.initialFile,
        'initialData': params.initialData?.toMap(),
        'initialSettings': settingsMap,
        'contextMenu': params.contextMenu?.toMap() ?? {},
        'windowId': params.windowId,
        'headlessWebViewId': params.headlessWebView?.isRunning() ?? false
            ? params.headlessWebView?.id
            : null,
        'initialUserScripts':
            params.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
        'pullToRefreshSettings': pullToRefreshSettings,
        'keepAliveId': params.keepAlive?.id,
        'preventGestureDelay': params.preventGestureDelay,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    dynamic viewId = id;
    if (params.headlessWebView?.isRunning() ?? false) {
      viewId = params.headlessWebView?.id;
    }
    viewId = params.keepAlive?.id ?? viewId ?? id;
    unawaited(_iosHeadlessInAppWebView?.internalDispose());
    _controller = IOSInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams(
        id: viewId,
        webviewParams: params,
      ),
    );
    _iosParams.pullToRefreshController?.init(viewId);
    _iosParams.findInteractionController?.init(viewId);
    debugLog(
      className: runtimeType.toString(),
      id: viewId?.toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: "onWebViewCreated",
      args: [],
    );
    if (params.onWebViewCreated != null) {
      params.onWebViewCreated!(
        params.controllerFromPlatform?.call(_controller!) ?? _controller!,
      );
    }
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
    if (params.onShowFileChooser != null &&
        settings.useOnShowFileChooser == null) {
      settings.useOnShowFileChooser = true;
    }
    if (params.onInsertInputSuggestion != null &&
        settings.useOnInsertInputSuggestion == null) {
      settings.useOnInsertInputSuggestion = true;
    }
    if (params.shouldGoToBackForwardListItem != null &&
        settings.useShouldGoToBackForwardListItem == null) {
      settings.useShouldGoToBackForwardListItem = true;
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
  }

  @override
  void didUpdateWidget(covariant PlatformInAppWebViewWidget oldWidget) {
    // The same object when the app rebuilds around one platform widget: nothing to move, and
    // clearing the old one's controller would clear this one's.
    if (identical(oldWidget, this) || oldWidget is! IOSInAppWebViewWidget) {
      return;
    }
    _controller = oldWidget._controller;
    oldWidget._controller = null;
    _platformViewId = oldWidget._platformViewId;
    oldWidget._platformViewId = null;
    // And its events go to this widget's callbacks from now on.
    _controller?.updateWebViewParams(params);
  }

  @override
  void dispose() {
    dynamic viewId = _controller?.getViewId();
    debugLog(
      className: runtimeType.toString(),
      id: viewId?.toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: "dispose",
      args: [],
    );
    final isKeepAlive = params.keepAlive != null;
    _controller?.dispose(isKeepAlive: isKeepAlive);
    _controller = null;
    params.pullToRefreshController?.dispose(isKeepAlive: isKeepAlive);
    params.findInteractionController?.dispose(isKeepAlive: isKeepAlive);
    final platformViewId = _platformViewId;
    _platformViewId = null;
    if (!isKeepAlive && platformViewId != null) {
      // The engine releases a platform view, and with it the native WebView, only while it
      // composites a frame that has, or just had, a platform view. A WebView removed before it was
      // ever composited stayed alive, its page running, until some later frame composited one
      // (§268). So the native side disposes it now; whichever of the two comes second does nothing.
      unawaited(
        IN_APP_WEBVIEW_STATIC_CHANNEL.invokeMethod('disposeWebView', {
          'viewId': platformViewId,
        }),
      );
    }
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    // unused
    throw UnimplementedError();
  }
}
