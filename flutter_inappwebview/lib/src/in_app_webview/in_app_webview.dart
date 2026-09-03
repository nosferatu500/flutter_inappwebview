import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/main.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import 'headless_in_app_webview.dart';
import 'in_app_webview_controller.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
class InAppWebView extends StatefulWidget {
  /// Constructs a [InAppWebView].
  ///
  /// See [InAppWebView.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InAppWebView.fromPlatformCreationParams({
    Key? key,
    required PlatformInAppWebViewWidgetCreationParams params,
  }) : this.fromPlatform(
         key: key,
         platform: PlatformInAppWebViewWidget(params),
       );

  /// Constructs a [InAppWebView] from a specific platform implementation.
  InAppWebView.fromPlatform({super.key, required this.platform});

  /// Implementation of [PlatformInAppWebView] for the current platform.
  final PlatformInAppWebViewWidget platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.supported_platforms}
  InAppWebView({
    Key? key,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    int? windowId,
    HeadlessInAppWebView? headlessWebView,
    InAppWebViewKeepAlive? keepAlive,
    bool? preventGestureDelay,
    TextDirection? layoutDirection,
    InAppWebViewInitialData? initialData,
    String? initialFile,
    InAppWebViewSettings? initialSettings,
    URLRequest? initialUrlRequest,
    UnmodifiableListView<UserScript>? initialUserScripts,
    PullToRefreshController? pullToRefreshController,
    FindInteractionController? findInteractionController,
    ContextMenu? contextMenu,
    void Function(InAppWebViewController controller, WebUri? url)?
    onPageCommitVisible,
    void Function(
      InAppWebViewController controller,
      WebViewNavigation navigation,
    )?
    onNavigationStarted,
    void Function(
      InAppWebViewController controller,
      WebViewNavigation navigation,
    )?
    onNavigationRedirected,
    void Function(
      InAppWebViewController controller,
      WebViewNavigation navigation,
    )?
    onNavigationCompleted,
    void Function(InAppWebViewController controller, WebViewPage page)?
    onPageLoadEvent,
    void Function(InAppWebViewController controller, WebViewPage page)?
    onPageDomContentLoadedEvent,
    void Function(InAppWebViewController controller, WebViewPage page)?
    onPageDeleted,
    void Function(
      InAppWebViewController controller,
      WebViewPage page,
      int durationMillis,
    )?
    onFirstContentfulPaintMillis,
    void Function(
      InAppWebViewController controller,
      WebViewPage page,
      int durationMillis,
    )?
    onLargestContentfulPaintMillis,
    void Function(
      InAppWebViewController controller,
      WebViewPage page,
      String markName,
      int markTimeMillis,
    )?
    onPerformanceMarkMillis,
    FutureOr<List<WebUri>?> Function(InAppWebViewController controller)?
    onRequestVisitedHistory,
    void Function(InAppWebViewController controller, String? title)?
    onTitleChanged,
    FutureOr<AjaxRequestAction?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    onAjaxProgress,
    FutureOr<AjaxRequestAction?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    onAjaxReadyStateChange,
    void Function(
      InAppWebViewController controller,
      ConsoleMessage consoleMessage,
    )?
    onConsoleMessage,
    FutureOr<bool?> Function(
      InAppWebViewController controller,
      CreateWindowAction createWindowAction,
    )?
    onCreateWindow,
    void Function(InAppWebViewController controller)? onCloseWindow,
    void Function(InAppWebViewController controller)? onWindowFocus,
    void Function(InAppWebViewController controller)? onWindowBlur,
    FutureOr<void> Function(
      InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest,
    )?
    onDownloadStarting,
    FutureOr<JsAlertResponse?> Function(
      InAppWebViewController controller,
      JsAlertRequest jsAlertRequest,
    )?
    onJsAlert,
    FutureOr<JsConfirmResponse?> Function(
      InAppWebViewController controller,
      JsConfirmRequest jsConfirmRequest,
    )?
    onJsConfirm,
    FutureOr<JsPromptResponse?> Function(
      InAppWebViewController controller,
      JsPromptRequest jsPromptRequest,
    )?
    onJsPrompt,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceError error,
    )?
    onReceivedError,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse errorResponse,
    )?
    onReceivedHttpError,
    void Function(InAppWebViewController controller, LoadedResource resource)?
    onLoadResource,
    FutureOr<CustomSchemeResponse?> Function(
      InAppWebViewController controller,
      WebResourceRequest request,
    )?
    onLoadResourceWithCustomScheme,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStart,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStop,
    void Function(
      InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult,
    )?
    onLongPressHitTestResult,
    FutureOr<bool?> Function(InAppWebViewController controller, WebUri? url)?
    onPrintRequest,
    void Function(InAppWebViewController controller, int progress)?
    onProgressChanged,
    FutureOr<ClientCertResponse?> Function(
      InAppWebViewController controller,
      ClientCertChallenge challenge,
    )?
    onReceivedClientCertRequest,
    FutureOr<HttpAuthResponse?> Function(
      InAppWebViewController controller,
      HttpAuthenticationChallenge challenge,
    )?
    onReceivedHttpAuthRequest,
    FutureOr<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      ServerTrustChallenge challenge,
    )?
    onReceivedServerTrustAuthRequest,
    void Function(InAppWebViewController controller, int x, int y)?
    onScrollChanged,
    void Function(
      InAppWebViewController controller,
      WebUri? url,
      bool? isReload,
    )?
    onUpdateVisitedHistory,
    void Function(InAppWebViewController controller)? onWebViewCreated,
    FutureOr<AjaxRequest?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    shouldInterceptAjaxRequest,
    FutureOr<FetchRequest?> Function(
      InAppWebViewController controller,
      FetchRequest fetchRequest,
    )?
    shouldInterceptFetchRequest,
    FutureOr<NavigationActionPolicy?> Function(
      InAppWebViewController controller,
      NavigationAction navigationAction,
    )?
    shouldOverrideUrlLoading,
    void Function(InAppWebViewController controller)? onEnterFullscreen,
    void Function(InAppWebViewController controller)? onExitFullscreen,
    void Function(
      InAppWebViewController controller,
      int x,
      int y,
      bool clampedX,
      bool clampedY,
    )?
    onOverScrolled,
    void Function(
      InAppWebViewController controller,
      double oldScale,
      double newScale,
    )?
    onZoomScaleChanged,
    void Function(InAppWebViewController controller)?
    onDidReceiveServerRedirectForProvisionalNavigation,
    FutureOr<FormResubmissionAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onFormResubmission,
    void Function(InAppWebViewController controller)?
    onGeolocationPermissionsHidePrompt,
    FutureOr<GeolocationPermissionShowPromptResponse?> Function(
      InAppWebViewController controller,
      String origin,
    )?
    onGeolocationPermissionsShowPrompt,
    FutureOr<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest,
    )?
    onJsBeforeUnload,
    FutureOr<NavigationResponseAction?> Function(
      InAppWebViewController controller,
      NavigationResponse navigationResponse,
    )?
    onNavigationResponse,
    FutureOr<PermissionResponse?> Function(
      InAppWebViewController controller,
      PermissionRequest permissionRequest,
    )?
    onPermissionRequest,
    void Function(InAppWebViewController controller, LoginRequest loginRequest)?
    onReceivedLoginRequest,
    void Function(
      InAppWebViewController controller,
      PermissionRequest permissionRequest,
    )?
    onPermissionRequestCanceled,
    void Function(InAppWebViewController controller)? onRequestFocus,
    void Function(
      InAppWebViewController controller,
      WebUri url,
      bool precomposed,
    )?
    onReceivedTouchIconUrl,
    void Function(
      InAppWebViewController controller,
      RenderProcessGoneDetail detail,
    )?
    onRenderProcessGone,
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onRenderProcessResponsive,
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onRenderProcessUnresponsive,
    FutureOr<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      WebUri url,
      SafeBrowsingThreat? threatType,
    )?
    onSafeBrowsingHit,
    void Function(InAppWebViewController controller)?
    onWebContentProcessDidTerminate,
    FutureOr<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge,
    )?
    shouldAllowDeprecatedTLS,
    FutureOr<WebResourceResponse?> Function(
      InAppWebViewController controller,
      WebResourceRequest request,
    )?
    shouldInterceptRequest,
    FutureOr<void> Function(
      InAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )?
    onCameraCaptureStateChanged,
    FutureOr<void> Function(
      InAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )?
    onMicrophoneCaptureStateChanged,
    FutureOr<ShouldGoToBackForwardListItemAction?> Function(
      InAppWebViewController controller,
      WebHistoryItem backForwardListItem,
      bool willUseInstantBack,
    )?
    shouldGoToBackForwardListItem,
    void Function(InAppWebViewController controller, bool active)?
    onWritingToolsActiveChanged,
    void Function(
      InAppWebViewController controller,
      Size oldContentSize,
      Size newContentSize,
    )?
    onContentSizeChanged,
    FutureOr<ShowFileChooserResponse?> Function(
      InAppWebViewController controller,
      ShowFileChooserRequest request,
    )?
    onShowFileChooser,
    onInsertInputSuggestion,
  }) : this.fromPlatformCreationParams(
         key: key,
         params: PlatformInAppWebViewWidgetCreationParams(
           controllerFromPlatform:
               (PlatformInAppWebViewController controller) =>
                   InAppWebViewController.fromPlatform(platform: controller),
           windowId: windowId,
           keepAlive: keepAlive,
           initialUrlRequest: initialUrlRequest,
           initialFile: initialFile,
           initialData: initialData,
           initialSettings: initialSettings,
           initialUserScripts: initialUserScripts,
           pullToRefreshController: pullToRefreshController?.platform,
           findInteractionController: findInteractionController?.platform,
           contextMenu: contextMenu,
           layoutDirection: layoutDirection,
           onWebViewCreated: onWebViewCreated != null
               ? (controller) => onWebViewCreated.call(controller)
               : null,
           onLoadStart: onLoadStart != null
               ? (controller, url) => onLoadStart.call(controller, url)
               : null,
           onLoadStop: onLoadStop != null
               ? (controller, url) => onLoadStop.call(controller, url)
               : null,
           onReceivedError: onReceivedError != null
               ? (controller, request, error) =>
                     onReceivedError.call(controller, request, error)
               : null,
           onReceivedHttpError: onReceivedHttpError != null
               ? (controller, request, errorResponse) => onReceivedHttpError
                     .call(controller, request, errorResponse)
               : null,
           onConsoleMessage: onConsoleMessage != null
               ? (controller, consoleMessage) =>
                     onConsoleMessage.call(controller, consoleMessage)
               : null,
           onProgressChanged: onProgressChanged != null
               ? (controller, progress) =>
                     onProgressChanged.call(controller, progress)
               : null,
           shouldOverrideUrlLoading: shouldOverrideUrlLoading != null
               ? (controller, navigationAction) =>
                     shouldOverrideUrlLoading(controller, navigationAction)
               : null,
           onLoadResource: onLoadResource != null
               ? (controller, resource) =>
                     onLoadResource.call(controller, resource)
               : null,
           onScrollChanged: onScrollChanged != null
               ? (controller, x, y) => onScrollChanged.call(controller, x, y)
               : null,
           onDownloadStarting: onDownloadStarting != null
               ? (controller, downloadStartRequest) =>
                     onDownloadStarting.call(controller, downloadStartRequest)
               : null,
           onLoadResourceWithCustomScheme:
               onLoadResourceWithCustomScheme != null
               ? (controller, request) =>
                     onLoadResourceWithCustomScheme.call(controller, request)
               : null,
           onCreateWindow: onCreateWindow != null
               ? (controller, createWindowAction) =>
                     onCreateWindow.call(controller, createWindowAction)
               : null,
           onCloseWindow: onCloseWindow != null
               ? (controller) => onCloseWindow.call(controller)
               : null,
           onJsAlert: onJsAlert != null
               ? (controller, jsAlertRequest) =>
                     onJsAlert.call(controller, jsAlertRequest)
               : null,
           onJsConfirm: onJsConfirm != null
               ? (controller, jsConfirmRequest) =>
                     onJsConfirm.call(controller, jsConfirmRequest)
               : null,
           onJsPrompt: onJsPrompt != null
               ? (controller, jsPromptRequest) =>
                     onJsPrompt.call(controller, jsPromptRequest)
               : null,
           onReceivedHttpAuthRequest: onReceivedHttpAuthRequest != null
               ? (controller, challenge) =>
                     onReceivedHttpAuthRequest.call(controller, challenge)
               : null,
           onReceivedServerTrustAuthRequest:
               onReceivedServerTrustAuthRequest != null
               ? (controller, challenge) => onReceivedServerTrustAuthRequest
                     .call(controller, challenge)
               : null,
           onReceivedClientCertRequest: onReceivedClientCertRequest != null
               ? (controller, challenge) =>
                     onReceivedClientCertRequest.call(controller, challenge)
               : null,
           shouldInterceptAjaxRequest: shouldInterceptAjaxRequest != null
               ? (controller, ajaxRequest) =>
                     shouldInterceptAjaxRequest.call(controller, ajaxRequest)
               : null,
           onAjaxReadyStateChange: onAjaxReadyStateChange != null
               ? (controller, ajaxRequest) =>
                     onAjaxReadyStateChange.call(controller, ajaxRequest)
               : null,
           onAjaxProgress: onAjaxProgress != null
               ? (controller, ajaxRequest) =>
                     onAjaxProgress.call(controller, ajaxRequest)
               : null,
           shouldInterceptFetchRequest: shouldInterceptFetchRequest != null
               ? (controller, fetchRequest) =>
                     shouldInterceptFetchRequest.call(controller, fetchRequest)
               : null,
           onUpdateVisitedHistory: onUpdateVisitedHistory != null
               ? (controller, url, isReload) =>
                     onUpdateVisitedHistory.call(controller, url, isReload)
               : null,
           onPrintRequest: onPrintRequest != null
               ? (controller, url) => onPrintRequest.call(controller, url)
               : null,
           onLongPressHitTestResult: onLongPressHitTestResult != null
               ? (controller, hitTestResult) =>
                     onLongPressHitTestResult.call(controller, hitTestResult)
               : null,
           onEnterFullscreen: onEnterFullscreen != null
               ? (controller) => onEnterFullscreen.call(controller)
               : null,
           onExitFullscreen: onExitFullscreen != null
               ? (controller) => onExitFullscreen.call(controller)
               : null,
           onPageCommitVisible: onPageCommitVisible != null
               ? (controller, url) => onPageCommitVisible.call(controller, url)
               : null,
           onNavigationStarted: onNavigationStarted != null
               ? (controller, navigation) =>
                     onNavigationStarted.call(controller, navigation)
               : null,
           onNavigationRedirected: onNavigationRedirected != null
               ? (controller, navigation) =>
                     onNavigationRedirected.call(controller, navigation)
               : null,
           onNavigationCompleted: onNavigationCompleted != null
               ? (controller, navigation) =>
                     onNavigationCompleted.call(controller, navigation)
               : null,
           onPageLoadEvent: onPageLoadEvent != null
               ? (controller, page) => onPageLoadEvent.call(controller, page)
               : null,
           onPageDomContentLoadedEvent: onPageDomContentLoadedEvent != null
               ? (controller, page) =>
                     onPageDomContentLoadedEvent.call(controller, page)
               : null,
           onPageDeleted: onPageDeleted != null
               ? (controller, page) => onPageDeleted.call(controller, page)
               : null,
           onFirstContentfulPaintMillis: onFirstContentfulPaintMillis != null
               ? (controller, page, durationMillis) =>
                     onFirstContentfulPaintMillis.call(
                       controller,
                       page,
                       durationMillis,
                     )
               : null,
           onLargestContentfulPaintMillis:
               onLargestContentfulPaintMillis != null
               ? (controller, page, durationMillis) =>
                     onLargestContentfulPaintMillis.call(
                       controller,
                       page,
                       durationMillis,
                     )
               : null,
           onPerformanceMarkMillis: onPerformanceMarkMillis != null
               ? (controller, page, markName, markTimeMillis) =>
                     onPerformanceMarkMillis.call(
                       controller,
                       page,
                       markName,
                       markTimeMillis,
                     )
               : null,
           onRequestVisitedHistory: onRequestVisitedHistory != null
               ? (controller) => onRequestVisitedHistory.call(controller)
               : null,
           onTitleChanged: onTitleChanged != null
               ? (controller, title) => onTitleChanged.call(controller, title)
               : null,
           onWindowFocus: onWindowFocus != null
               ? (controller) => onWindowFocus.call(controller)
               : null,
           onWindowBlur: onWindowBlur != null
               ? (controller) => onWindowBlur.call(controller)
               : null,
           onOverScrolled: onOverScrolled != null
               ? (controller, x, y, clampedX, clampedY) =>
                     onOverScrolled.call(controller, x, y, clampedX, clampedY)
               : null,
           onZoomScaleChanged: onZoomScaleChanged != null
               ? (controller, oldScale, newScale) =>
                     onZoomScaleChanged.call(controller, oldScale, newScale)
               : null,
           onSafeBrowsingHit: onSafeBrowsingHit != null
               ? (controller, url, threatType) =>
                     onSafeBrowsingHit.call(controller, url, threatType)
               : null,
           onPermissionRequest: onPermissionRequest != null
               ? (controller, permissionRequest) =>
                     onPermissionRequest.call(controller, permissionRequest)
               : null,
           onGeolocationPermissionsShowPrompt:
               onGeolocationPermissionsShowPrompt != null
               ? (controller, origin) =>
                     onGeolocationPermissionsShowPrompt.call(controller, origin)
               : null,
           onGeolocationPermissionsHidePrompt:
               onGeolocationPermissionsHidePrompt != null
               ? (controller) =>
                     onGeolocationPermissionsHidePrompt.call(controller)
               : null,
           shouldInterceptRequest: shouldInterceptRequest != null
               ? (controller, request) =>
                     shouldInterceptRequest.call(controller, request)
               : null,
           onRenderProcessGone: onRenderProcessGone != null
               ? (controller, detail) =>
                     onRenderProcessGone.call(controller, detail)
               : null,
           onRenderProcessResponsive: onRenderProcessResponsive != null
               ? (controller, url) =>
                     onRenderProcessResponsive.call(controller, url)
               : null,
           onRenderProcessUnresponsive: onRenderProcessUnresponsive != null
               ? (controller, url) =>
                     onRenderProcessUnresponsive.call(controller, url)
               : null,
           onFormResubmission: onFormResubmission != null
               ? (controller, url) => onFormResubmission.call(controller, url)
               : null,
           onReceivedTouchIconUrl: onReceivedTouchIconUrl != null
               ? (controller, url, precomposed) =>
                     onReceivedTouchIconUrl.call(controller, url, precomposed)
               : null,
           onJsBeforeUnload: onJsBeforeUnload != null
               ? (controller, jsBeforeUnloadRequest) =>
                     onJsBeforeUnload.call(controller, jsBeforeUnloadRequest)
               : null,
           onReceivedLoginRequest: onReceivedLoginRequest != null
               ? (controller, loginRequest) =>
                     onReceivedLoginRequest.call(controller, loginRequest)
               : null,
           onPermissionRequestCanceled: onPermissionRequestCanceled != null
               ? (controller, permissionRequest) => onPermissionRequestCanceled
                     .call(controller, permissionRequest)
               : null,
           onRequestFocus: onRequestFocus != null
               ? (controller) => onRequestFocus.call(controller)
               : null,
           onWebContentProcessDidTerminate:
               onWebContentProcessDidTerminate != null
               ? (controller) =>
                     onWebContentProcessDidTerminate.call(controller)
               : null,
           onDidReceiveServerRedirectForProvisionalNavigation:
               onDidReceiveServerRedirectForProvisionalNavigation != null
               ? (controller) =>
                     onDidReceiveServerRedirectForProvisionalNavigation.call(
                       controller,
                     )
               : null,
           onNavigationResponse: onNavigationResponse != null
               ? (controller, navigationResponse) =>
                     onNavigationResponse.call(controller, navigationResponse)
               : null,
           shouldAllowDeprecatedTLS: shouldAllowDeprecatedTLS != null
               ? (controller, challenge) =>
                     shouldAllowDeprecatedTLS.call(controller, challenge)
               : null,
           onCameraCaptureStateChanged: onCameraCaptureStateChanged != null
               ? (controller, oldState, newState) => onCameraCaptureStateChanged
                     .call(controller, oldState, newState)
               : null,
           onMicrophoneCaptureStateChanged:
               onMicrophoneCaptureStateChanged != null
               ? (controller, oldState, newState) =>
                     onMicrophoneCaptureStateChanged.call(
                       controller,
                       oldState,
                       newState,
                     )
               : null,
           shouldGoToBackForwardListItem: shouldGoToBackForwardListItem != null
               ? (controller, backForwardListItem, willUseInstantBack) =>
                     shouldGoToBackForwardListItem.call(
                       controller,
                       backForwardListItem,
                       willUseInstantBack,
                     )
               : null,
           onWritingToolsActiveChanged: onWritingToolsActiveChanged != null
               ? (controller, active) =>
                     onWritingToolsActiveChanged.call(controller, active)
               : null,
           onContentSizeChanged: onContentSizeChanged != null
               ? (controller, oldContentSize, newContentSize) =>
                     onContentSizeChanged.call(
                       controller,
                       oldContentSize,
                       newContentSize,
                     )
               : null,
           onShowFileChooser: onShowFileChooser != null
               ? (controller, request) =>
                     onShowFileChooser.call(controller, request)
               : null,
           onInsertInputSuggestion: onInsertInputSuggestion != null
               ? (controller, inputSuggestion) =>
                     onInsertInputSuggestion.call(controller, inputSuggestion)
               : null,
           gestureRecognizers: gestureRecognizers,
           headlessWebView: headlessWebView?.platform,
           preventGestureDelay: preventGestureDelay,
         ),
       );

  @override
  _InAppWebViewState createState() => _InAppWebViewState();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppWebViewWidget.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformInAppWebViewWidget.static().isPropertySupported(
    property,
    platform: platform,
  );
}

class _InAppWebViewState extends State<InAppWebView> {
  @override
  Widget build(BuildContext context) {
    return widget.platform.build(context);
  }

  @override
  void dispose() {
    widget.platform.dispose();
    super.dispose();
  }
}
