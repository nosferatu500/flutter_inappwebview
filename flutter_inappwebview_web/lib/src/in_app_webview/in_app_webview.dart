import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import '../../web/in_app_webview_manager.dart';
import 'headless_in_app_webview.dart';

import 'in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class WebPlatformInAppWebViewWidgetCreationParams
    extends PlatformInAppWebViewWidgetCreationParams {
  WebPlatformInAppWebViewWidgetCreationParams({
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
    @Deprecated('Use onReceivedTouchIconUrl instead')
    super.onReceivedTouchIconUrl,
    super.onJsBeforeUnload,
    @Deprecated('Use onReceivedLoginRequest instead')
    super.onReceivedLoginRequest,
    super.onPermissionRequestCanceled,
    super.onRequestFocus,
    super.onWebContentProcessDidTerminate,
    @Deprecated(
      'Use onDidReceiveServerRedirectForProvisionalNavigation instead',
    )
    super.onDidReceiveServerRedirectForProvisionalNavigation,
    super.onNavigationResponse,
    super.shouldAllowDeprecatedTLS,
    super.onCameraCaptureStateChanged,
    super.onMicrophoneCaptureStateChanged,
    super.onContentSizeChanged,
    super.initialUrlRequest,
    super.initialFile,
    super.initialData,
    @Deprecated('Use initialSettings instead') super.initialOptions,
    super.initialSettings,
    super.contextMenu,
    super.initialUserScripts,
    super.pullToRefreshController,
    super.findInteractionController,
  });

  /// Constructs a [WebPlatformInAppWebViewWidgetCreationParams] using a
  /// [PlatformInAppWebViewWidgetCreationParams].
  WebPlatformInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
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
        initialOptions: params.initialOptions,
        initialSettings: params.initialSettings,
        contextMenu: params.contextMenu,
        initialUserScripts: params.initialUserScripts,
        pullToRefreshController: params.pullToRefreshController,
        findInteractionController: params.findInteractionController,
      );
}

///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
class WebPlatformInAppWebViewWidget extends PlatformInAppWebViewWidget {
  /// Constructs a [WebPlatformInAppWebViewWidget].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
  WebPlatformInAppWebViewWidget(PlatformInAppWebViewWidgetCreationParams params)
    : super.implementation(
        params is WebPlatformInAppWebViewWidgetCreationParams
            ? params
            : WebPlatformInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
                params,
              ),
      );

  WebPlatformInAppWebViewWidgetCreationParams get _webPlatformParams =>
      params as WebPlatformInAppWebViewWidgetCreationParams;

  WebPlatformInAppWebViewController? _controller;

  WebPlatformHeadlessInAppWebView? get _macosHeadlessInAppWebView =>
      _webPlatformParams.headlessWebView as WebPlatformHeadlessInAppWebView?;

  static final WebPlatformInAppWebViewWidget _staticValue =
      WebPlatformInAppWebViewWidget(
        WebPlatformInAppWebViewWidgetCreationParams(),
      );

  factory WebPlatformInAppWebViewWidget.static() {
    return _staticValue;
  }

  @override
  Widget build(BuildContext context) {
    final initialSettings =
        _webPlatformParams.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    if ((_webPlatformParams.headlessWebView?.isRunning() ?? false) &&
        _webPlatformParams.keepAlive != null) {
      final headlessId = _webPlatformParams.headlessWebView?.id;
      if (headlessId != null) {
        // force keep alive id to match headless webview id
        _webPlatformParams.keepAlive?.id = headlessId;
      }
    }

    return HtmlElementView(
      viewType: 'com.pichillilorenzo/flutter_inappwebview',
      onPlatformViewCreated: (int viewId) {
        var webViewHtmlElement = InAppWebViewManager.webViews[viewId]!;
        webViewHtmlElement.initialSettings = initialSettings;
        webViewHtmlElement.initialUrlRequest =
            _webPlatformParams.initialUrlRequest;
        webViewHtmlElement.initialFile = _webPlatformParams.initialFile;
        webViewHtmlElement.initialData = _webPlatformParams.initialData;
        webViewHtmlElement.initialUserScripts =
            _webPlatformParams.initialUserScripts;
        webViewHtmlElement.headlessWebViewId =
            _webPlatformParams.headlessWebView?.isRunning() ?? false
            ? _webPlatformParams.headlessWebView?.id
            : null;
        webViewHtmlElement.windowId = _webPlatformParams.windowId;
        webViewHtmlElement.prepare();
        if (webViewHtmlElement.headlessWebViewId == null) {
          webViewHtmlElement.makeInitialLoad();
        }
        _onPlatformViewCreated(viewId);
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    dynamic viewId = id;
    _macosHeadlessInAppWebView?.internalDispose();
    _controller = WebPlatformInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams(
        id: viewId,
        webviewParams: params,
      ),
    );
    debugLog(
      className: runtimeType.toString(),
      id: viewId?.toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: "onWebViewCreated",
      args: [],
    );
    if (_webPlatformParams.onWebViewCreated != null) {
      _webPlatformParams.onWebViewCreated!(
        params.controllerFromPlatform?.call(_controller!) ?? _controller!,
      );
    }
  }

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (_webPlatformParams.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (_webPlatformParams.onLoadResource != null &&
        settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if (_webPlatformParams.onDownloadStarting != null &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if (_webPlatformParams.shouldInterceptAjaxRequest != null &&
        settings.useShouldInterceptAjaxRequest == null) {
      settings.useShouldInterceptAjaxRequest = true;
    }
    if (_webPlatformParams.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (_webPlatformParams.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (_webPlatformParams.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (_webPlatformParams.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
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
    final isKeepAlive = _webPlatformParams.keepAlive != null;
    _controller?.dispose(isKeepAlive: isKeepAlive);
    _controller = null;
    _webPlatformParams.pullToRefreshController?.dispose(
      isKeepAlive: isKeepAlive,
    );
    _webPlatformParams.findInteractionController?.dispose(
      isKeepAlive: isKeepAlive,
    );
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    // unused
    throw UnimplementedError();
  }
}
