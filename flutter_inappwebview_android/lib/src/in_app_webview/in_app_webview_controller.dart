import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_browser/in_app_browser.dart';
import '../print_job/main.dart';
import '../web_message/main.dart';
import '../web_storage/web_storage.dart';
import '../pigeons/in_app_webview.g.dart';
import '../pigeons/in_app_webview_manager.g.dart';
import 'headless_in_app_webview.dart';

/// Object specifying creation parameters for creating a [AndroidInAppWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppWebViewControllerCreationParams] for
/// more information.
@immutable
class AndroidInAppWebViewControllerCreationParams
    extends PlatformInAppWebViewControllerCreationParams {
  /// Creates a new [AndroidInAppWebViewControllerCreationParams] instance.
  const AndroidInAppWebViewControllerCreationParams({
    required super.id,
    super.webviewParams,
  });

  /// Creates a [AndroidInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory AndroidInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return AndroidInAppWebViewControllerCreationParams(
      id: params.id,
      webviewParams: params.webviewParams,
    );
  }
}

/// Receives the fire-and-forget [InAppWebViewFlutterApi] events (W4, §214) and dispatches each one
/// through the controller's `_handleMethod`, rebuilt as the exact [MethodCall] the MethodChannel
/// used to deliver: the same method name, and the arguments Kotlin used to send, key for key.
///
/// So every event keeps its one definition in `_handleMethod` (the widget or browser routing, the
/// `fromMap` parsing, the debug log), and the unit tests that drive `handleMethod` directly stay
/// valid. Each method returns the dispatch's Future, which Pigeon awaits: a throw becomes an error
/// reply, as on the MethodChannel, instead of an unhandled error.
class _InAppWebViewFlutterApiImpl implements InAppWebViewFlutterApi {
  _InAppWebViewFlutterApiImpl(this._controller);

  final AndroidInAppWebViewController _controller;

  Future<void> _dispatch(String method, Object? arguments) async {
    await _controller._handleMethod(MethodCall(method, arguments));
  }

  @override
  Future<void> onLoadStart(String? url) =>
      _dispatch('onLoadStart', {'url': url});

  @override
  Future<void> onLoadStop(String? url) => _dispatch('onLoadStop', {'url': url});

  @override
  Future<void> onReceivedError(
    Map<String?, Object?> request,
    Map<String?, Object?> error,
  ) => _dispatch('onReceivedError', {'request': request, 'error': error});

  @override
  Future<void> onReceivedHttpError(
    Map<String?, Object?> request,
    Map<String?, Object?> errorResponse,
  ) => _dispatch('onReceivedHttpError', {
    'request': request,
    'errorResponse': errorResponse,
  });

  @override
  Future<void> onProgressChanged(int progress) =>
      _dispatch('onProgressChanged', {'progress': progress});

  @override
  Future<void> onConsoleMessage(String? message, int messageLevel) => _dispatch(
    'onConsoleMessage',
    {'message': message, 'messageLevel': messageLevel},
  );

  @override
  Future<void> onScrollChanged(int x, int y) =>
      _dispatch('onScrollChanged', {'x': x, 'y': y});

  @override
  Future<void> onOverScrolled(int x, int y, bool clampedX, bool clampedY) =>
      _dispatch('onOverScrolled', {
        'x': x,
        'y': y,
        'clampedX': clampedX,
        'clampedY': clampedY,
      });

  // Kotlin sent `DownloadStartRequest.toMap()` itself as the arguments.
  @override
  Future<void> onDownloadStarting(Map<String?, Object?> downloadStartRequest) =>
      _dispatch('onDownloadStarting', downloadStartRequest);

  @override
  Future<void> onCloseWindow() => _dispatch('onCloseWindow', {});

  @override
  Future<void> onTitleChanged(String? title) =>
      _dispatch('onTitleChanged', {'title': title});

  @override
  Future<void> onGeolocationPermissionsHidePrompt() =>
      _dispatch('onGeolocationPermissionsHidePrompt', {});

  @override
  Future<void> onReceivedTouchIconUrl(String? url, bool precomposed) =>
      _dispatch('onReceivedTouchIconUrl', {
        'url': url,
        'precomposed': precomposed,
      });

  @override
  Future<void> onPermissionRequestCanceled(
    String? origin,
    List<String?>? resources,
  ) => _dispatch('onPermissionRequestCanceled', {
    'origin': origin,
    'resources': resources,
  });

  @override
  Future<void> onUpdateVisitedHistory(String? url, bool isReload) =>
      _dispatch('onUpdateVisitedHistory', {'url': url, 'isReload': isReload});

  @override
  Future<void> onZoomScaleChanged(double oldScale, double newScale) =>
      _dispatch('onZoomScaleChanged', {
        'oldScale': oldScale,
        'newScale': newScale,
      });

  @override
  Future<void> onPageCommitVisible(String? url) =>
      _dispatch('onPageCommitVisible', {'url': url});

  // Kotlin sent `HitTestResult.toMap()` itself (or null) as the arguments.
  @override
  Future<void> onLongPressHitTestResult(Map<String?, Object?>? hitTestResult) =>
      _dispatch('onLongPressHitTestResult', hitTestResult);

  // Kotlin sent `HitTestResult.toMap()` itself (or null) as the arguments.
  @override
  Future<void> onCreateContextMenu(Map<String?, Object?>? hitTestResult) =>
      _dispatch('onCreateContextMenu', hitTestResult);

  @override
  Future<void> onHideContextMenu() => _dispatch('onHideContextMenu', {});

  @override
  Future<void> onContextMenuActionItemClicked(int id, String? title) =>
      _dispatch('onContextMenuActionItemClicked', {'id': id, 'title': title});

  @override
  Future<void> onEnterFullscreen() => _dispatch('onEnterFullscreen', {});

  @override
  Future<void> onExitFullscreen() => _dispatch('onExitFullscreen', {});

  @override
  Future<void> onRequestFocus() => _dispatch('onRequestFocus', {});

  @override
  Future<void> onRenderProcessGone(bool didCrash, int rendererPriorityAtExit) =>
      _dispatch('onRenderProcessGone', {
        'didCrash': didCrash,
        'rendererPriorityAtExit': rendererPriorityAtExit,
      });

  @override
  Future<void> onReceivedLoginRequest(
    String? realm,
    String? account,
    String? args,
  ) => _dispatch('onReceivedLoginRequest', {
    'realm': realm,
    'account': account,
    'args': args,
  });

  @override
  Future<void> onNavigationStarted(Map<String?, Object?> navigation) =>
      _dispatch('onNavigationStarted', {'navigation': navigation});

  @override
  Future<void> onNavigationRedirected(Map<String?, Object?> navigation) =>
      _dispatch('onNavigationRedirected', {'navigation': navigation});

  @override
  Future<void> onNavigationCompleted(Map<String?, Object?> navigation) =>
      _dispatch('onNavigationCompleted', {'navigation': navigation});

  @override
  Future<void> onPageLoadEvent(Map<String?, Object?> page) =>
      _dispatch('onPageLoadEvent', {'page': page});

  @override
  Future<void> onPageDomContentLoadedEvent(Map<String?, Object?> page) =>
      _dispatch('onPageDomContentLoadedEvent', {'page': page});

  @override
  Future<void> onPageDeleted(Map<String?, Object?> page) =>
      _dispatch('onPageDeleted', {'page': page});

  @override
  Future<void> onFirstContentfulPaintMillis(
    Map<String?, Object?> page,
    int durationMillis,
  ) => _dispatch('onFirstContentfulPaintMillis', {
    'page': page,
    'durationMillis': durationMillis,
  });

  @override
  Future<void> onLargestContentfulPaintMillis(
    Map<String?, Object?> page,
    int durationMillis,
  ) => _dispatch('onLargestContentfulPaintMillis', {
    'page': page,
    'durationMillis': durationMillis,
  });

  @override
  Future<void> onPerformanceMarkMillis(
    Map<String?, Object?> page,
    String markName,
    int markTimeMillis,
  ) => _dispatch('onPerformanceMarkMillis', {
    'page': page,
    'markName': markName,
    'markTimeMillis': markTimeMillis,
  });
}

///Controls a WebView, such as an [InAppWebView] widget instance, a [AndroidHeadlessInAppWebView] instance or [AndroidInAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [AndroidInAppBrowser] instance, you can get it through the [AndroidInAppBrowser.webViewController] attribute.
class AndroidInAppWebViewController extends PlatformInAppWebViewController
    with ChannelController {
  /// Process-wide statics (§188). Replaces the hand-written `inappwebview_manager` channel.
  static final InAppWebViewManagerHostApi _managerHostApi =
      InAppWebViewManagerHostApi();

  // List of properties to be saved and restored for keep alive feature
  Map<String, Function> _javaScriptHandlersMap = HashMap<String, Function>();
  Map<UserScriptInjectionTime, List<UserScript>> _userScripts = {
    UserScriptInjectionTime.AT_DOCUMENT_START: <UserScript>[],
    UserScriptInjectionTime.AT_DOCUMENT_END: <UserScript>[],
  };
  Set<String> _webMessageListenerObjNames = {};
  Map<String, ScriptHtmlTagAttributes> _injectedScriptsFromURL = {};
  Set<AndroidWebMessageChannel> _webMessageChannels = {};
  Set<AndroidWebMessageListener> _webMessageListeners = {};

  // static map that contains the properties to be saved and restored for keep alive feature
  static final Map<InAppWebViewKeepAlive, InAppWebViewControllerKeepAliveProps?>
  _keepAliveMap = {};

  AndroidInAppBrowser? _inAppBrowser;

  /// The Pigeon half of the per-WebView transport (§207 on). Every host method is here since W3
  /// (§212); [channel] now only carries the events not yet moved. Its suffix is [channel]'s name
  /// tail, `inappwebview_$id` or `inappbrowser_$id`, as on the Kotlin side. Null after [dispose], as
  /// [channel] is.
  InAppWebViewHostApi? _hostApi;

  /// The suffix both Pigeon APIs use, kept so [dispose] can unregister [InAppWebViewFlutterApi].
  /// Its events (W4, §214) arrive there, the rest still through [channel].
  late final String _pigeonSuffix;

  void _setUpPigeon(String suffix) {
    _pigeonSuffix = suffix;
    _hostApi = InAppWebViewHostApi(messageChannelSuffix: suffix);
    InAppWebViewFlutterApi.setUp(
      _InAppWebViewFlutterApiImpl(this),
      messageChannelSuffix: suffix,
    );
  }

  PlatformInAppBrowserEvents? get _inAppBrowserEventHandler =>
      _inAppBrowser?.eventHandler;

  dynamic _controllerFromPlatform;

  @override
  late AndroidWebStorage webStorage;

  AndroidInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) : super.implementation(
        params is AndroidInAppWebViewControllerCreationParams
            ? params
            : AndroidInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel('dev.nosferatu500.inappwebview/inappwebview_$id');
    handler = handleMethod;
    initMethodCallHandler();
    _setUpPigeon('inappwebview_$id');

    final initialUserScripts = webviewParams?.initialUserScripts;
    if (initialUserScripts != null) {
      for (final userScript in initialUserScripts) {
        if (userScript.injectionTime ==
            UserScriptInjectionTime.AT_DOCUMENT_START) {
          _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.add(
            userScript,
          );
        } else {
          _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.add(
            userScript,
          );
        }
      }
    }

    _init(params);
  }

  static final AndroidInAppWebViewController _staticValue =
      AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(id: null),
      );

  factory AndroidInAppWebViewController.static() {
    return _staticValue;
  }

  AndroidInAppWebViewController.fromInAppBrowser(
    PlatformInAppWebViewControllerCreationParams params,
    MethodChannel channel,
    AndroidInAppBrowser inAppBrowser,
    UnmodifiableListView<UserScript>? initialUserScripts,
  ) : super.implementation(
        params is AndroidInAppWebViewControllerCreationParams
            ? params
            : AndroidInAppWebViewControllerCreationParams.fromPlatformInAppWebViewControllerCreationParams(
                params,
              ),
      ) {
    this.channel = channel;
    _setUpPigeon('inappbrowser_$id');
    _inAppBrowser = inAppBrowser;

    if (initialUserScripts != null) {
      for (final userScript in initialUserScripts) {
        if (userScript.injectionTime ==
            UserScriptInjectionTime.AT_DOCUMENT_START) {
          _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.add(
            userScript,
          );
        } else {
          _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.add(
            userScript,
          );
        }
      }
    }
    _init(params);
  }

  void _init(PlatformInAppWebViewControllerCreationParams params) {
    _controllerFromPlatform =
        params.webviewParams?.controllerFromPlatform?.call(this) ?? this;

    webStorage = AndroidWebStorage(
      AndroidWebStorageCreationParams(
        localStorage: AndroidLocalStorage.defaultStorage(controller: this),
        sessionStorage: AndroidSessionStorage.defaultStorage(controller: this),
      ),
    );

    if (params.webviewParams is PlatformInAppWebViewWidgetCreationParams) {
      final keepAlive =
          (params.webviewParams as PlatformInAppWebViewWidgetCreationParams)
              .keepAlive;
      if (keepAlive != null) {
        InAppWebViewControllerKeepAliveProps? props = _keepAliveMap[keepAlive];
        if (props == null) {
          // save controller properties to restore it later
          _keepAliveMap[keepAlive] = InAppWebViewControllerKeepAliveProps(
            injectedScriptsFromURL: _injectedScriptsFromURL,
            javaScriptHandlersMap: _javaScriptHandlersMap,
            userScripts: _userScripts,
            webMessageListenerObjNames: _webMessageListenerObjNames,
            webMessageChannels: _webMessageChannels,
            webMessageListeners: _webMessageListeners,
          );
        } else {
          // restore controller properties
          _injectedScriptsFromURL = props.injectedScriptsFromURL;
          _javaScriptHandlersMap = props.javaScriptHandlersMap;
          _userScripts = props.userScripts;
          _webMessageListenerObjNames = props.webMessageListenerObjNames;
          _webMessageChannels =
              props.webMessageChannels as Set<AndroidWebMessageChannel>;
          _webMessageListeners =
              props.webMessageListeners as Set<AndroidWebMessageListener>;
        }
      }
    }
  }

  void _debugLog(String method, dynamic args) {
    debugLog(
      className: runtimeType.toString(),
      name: _inAppBrowser == null
          ? "WebView"
          : _inAppBrowser.runtimeType.toString(),
      id: (getViewId() ?? _inAppBrowser?.id).toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (PlatformInAppWebViewController.debugLoggingSettings.enabled &&
        call.method != "onCallJsHandler") {
      _debugLog(call.method, call.arguments);
    }

    switch (call.method) {
      case "onLoadStart":
        _injectedScriptsFromURL.clear();
        if ((webviewParams != null && webviewParams!.onLoadStart != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null && webviewParams!.onLoadStart != null) {
            webviewParams!.onLoadStart!(_controllerFromPlatform, uri);
          } else {
            _inAppBrowserEventHandler!.onLoadStart(uri);
          }
        }
        break;
      case "onLoadStop":
        if ((webviewParams != null && webviewParams!.onLoadStop != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null && webviewParams!.onLoadStop != null) {
            webviewParams!.onLoadStop!(_controllerFromPlatform, uri);
          } else {
            _inAppBrowserEventHandler!.onLoadStop(uri);
          }
        }
        break;
      case "onReceivedError":
        if ((webviewParams != null && webviewParams!.onReceivedError != null) ||
            _inAppBrowserEventHandler != null) {
          WebResourceRequest request = WebResourceRequest.fromMap(
            call.arguments["request"].cast<String, dynamic>(),
          )!;
          WebResourceError error = WebResourceError.fromMap(
            call.arguments["error"].cast<String, dynamic>(),
          )!;
          if (webviewParams != null) {
            webviewParams!.onReceivedError!(
              _controllerFromPlatform,
              request,
              error,
            );
          } else {
            _inAppBrowserEventHandler!.onReceivedError(request, error);
          }
        }
        break;
      case "onReceivedHttpError":
        if ((webviewParams != null &&
                webviewParams!.onReceivedHttpError != null) ||
            _inAppBrowserEventHandler != null) {
          WebResourceRequest request = WebResourceRequest.fromMap(
            call.arguments["request"].cast<String, dynamic>(),
          )!;
          WebResourceResponse errorResponse = WebResourceResponse.fromMap(
            call.arguments["errorResponse"].cast<String, dynamic>(),
          )!;
          if (webviewParams != null) {
            webviewParams!.onReceivedHttpError!(
              _controllerFromPlatform,
              request,
              errorResponse,
            );
          } else {
            _inAppBrowserEventHandler!.onReceivedHttpError(
              request,
              errorResponse,
            );
          }
        }
        break;
      case "onProgressChanged":
        if ((webviewParams != null &&
                webviewParams!.onProgressChanged != null) ||
            _inAppBrowserEventHandler != null) {
          int progress = call.arguments["progress"];
          if (webviewParams != null &&
              webviewParams!.onProgressChanged != null) {
            webviewParams!.onProgressChanged!(
              _controllerFromPlatform,
              progress,
            );
          } else {
            _inAppBrowserEventHandler!.onProgressChanged(progress);
          }
        }
        break;
      case "shouldOverrideUrlLoading":
        if ((webviewParams != null &&
                webviewParams!.shouldOverrideUrlLoading != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          NavigationAction navigationAction = NavigationAction.fromMap(
            arguments,
          )!;

          if (webviewParams != null &&
              webviewParams!.shouldOverrideUrlLoading != null) {
            return (await webviewParams!.shouldOverrideUrlLoading!(
              _controllerFromPlatform,
              navigationAction,
            ))?.toNativeValue();
          }
          return (await _inAppBrowserEventHandler!.shouldOverrideUrlLoading(
            navigationAction,
          ))?.toNativeValue();
        }
        break;
      case "onConsoleMessage":
        if ((webviewParams != null &&
                webviewParams!.onConsoleMessage != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ConsoleMessage consoleMessage = ConsoleMessage.fromMap(arguments)!;
          if (webviewParams != null &&
              webviewParams!.onConsoleMessage != null) {
            webviewParams!.onConsoleMessage!(
              _controllerFromPlatform,
              consoleMessage,
            );
          } else {
            _inAppBrowserEventHandler!.onConsoleMessage(consoleMessage);
          }
        }
        break;
      case "onScrollChanged":
        if ((webviewParams != null && webviewParams!.onScrollChanged != null) ||
            _inAppBrowserEventHandler != null) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          if (webviewParams != null && webviewParams!.onScrollChanged != null) {
            webviewParams!.onScrollChanged!(_controllerFromPlatform, x, y);
          } else {
            _inAppBrowserEventHandler!.onScrollChanged(x, y);
          }
        }
        break;
      case "onDownloadStarting":
        if ((webviewParams != null &&
                webviewParams!.onDownloadStarting != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          DownloadStartRequest downloadStartRequest =
              DownloadStartRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            await webviewParams!.onDownloadStarting!(
              _controllerFromPlatform,
              downloadStartRequest,
            );
            return null;
          } else {
            await _inAppBrowserEventHandler!.onDownloadStarting(
              downloadStartRequest,
            );
            return null;
          }
        }
        break;
      case "onLoadResourceWithCustomScheme":
        if ((webviewParams != null &&
                webviewParams!.onLoadResourceWithCustomScheme != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> requestMap = call.arguments["request"]
              .cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(requestMap)!;

          if (webviewParams != null) {
            return (await webviewParams!.onLoadResourceWithCustomScheme!(
              _controllerFromPlatform,
              request,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!
                    .onLoadResourceWithCustomScheme(request))
                ?.toMap();
          }
        }
        break;
      case "onCreateWindow":
        if ((webviewParams != null && webviewParams!.onCreateWindow != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          CreateWindowAction createWindowAction = CreateWindowAction.fromMap(
            arguments,
          )!;

          if (webviewParams != null && webviewParams!.onCreateWindow != null) {
            return await webviewParams!.onCreateWindow!(
              _controllerFromPlatform,
              createWindowAction,
            );
          } else {
            return await _inAppBrowserEventHandler!.onCreateWindow(
              createWindowAction,
            );
          }
        }
        break;
      case "onCloseWindow":
        if (webviewParams != null && webviewParams!.onCloseWindow != null) {
          webviewParams!.onCloseWindow!(_controllerFromPlatform);
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onCloseWindow();
        }
        break;
      case "onTitleChanged":
        if ((webviewParams != null && webviewParams!.onTitleChanged != null) ||
            _inAppBrowserEventHandler != null) {
          String? title = call.arguments["title"];
          if (webviewParams != null && webviewParams!.onTitleChanged != null) {
            webviewParams!.onTitleChanged!(_controllerFromPlatform, title);
          } else {
            _inAppBrowserEventHandler!.onTitleChanged(title);
          }
        }
        break;
      case "onGeolocationPermissionsShowPrompt":
        if ((webviewParams != null &&
                webviewParams!.onGeolocationPermissionsShowPrompt != null) ||
            _inAppBrowserEventHandler != null) {
          String origin = call.arguments["origin"];

          if (webviewParams != null) {
            return (await webviewParams!.onGeolocationPermissionsShowPrompt!(
              _controllerFromPlatform,
              origin,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!
                    .onGeolocationPermissionsShowPrompt(origin))
                ?.toMap();
          }
        }
        break;
      case "onGeolocationPermissionsHidePrompt":
        if (webviewParams != null &&
            webviewParams!.onGeolocationPermissionsHidePrompt != null) {
          webviewParams!.onGeolocationPermissionsHidePrompt!(
            _controllerFromPlatform,
          );
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onGeolocationPermissionsHidePrompt();
        }
        break;
      case "shouldInterceptRequest":
        if ((webviewParams != null &&
                webviewParams!.shouldInterceptRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            return (await webviewParams!.shouldInterceptRequest!(
              _controllerFromPlatform,
              request,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.shouldInterceptRequest(
              request,
            ))?.toMap();
          }
        }
        break;
      case "onRenderProcessUnresponsive":
        if ((webviewParams != null &&
                webviewParams!.onRenderProcessUnresponsive != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            return (await webviewParams!.onRenderProcessUnresponsive!(
              _controllerFromPlatform,
              uri,
            ))?.toNativeValue();
          } else {
            return (await _inAppBrowserEventHandler!
                    .onRenderProcessUnresponsive(uri))
                ?.toNativeValue();
          }
        }
        break;
      case "onRenderProcessResponsive":
        if ((webviewParams != null &&
                webviewParams!.onRenderProcessResponsive != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            return (await webviewParams!.onRenderProcessResponsive!(
              _controllerFromPlatform,
              uri,
            ))?.toNativeValue();
          } else {
            return (await _inAppBrowserEventHandler!.onRenderProcessResponsive(
              uri,
            ))?.toNativeValue();
          }
        }
        break;
      case "onRenderProcessGone":
        if ((webviewParams != null &&
                webviewParams!.onRenderProcessGone != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          RenderProcessGoneDetail detail = RenderProcessGoneDetail.fromMap(
            arguments,
          )!;

          if (webviewParams != null) {
            webviewParams!.onRenderProcessGone!(
              _controllerFromPlatform,
              detail,
            );
          } else if (_inAppBrowserEventHandler != null) {
            _inAppBrowserEventHandler!.onRenderProcessGone(detail);
          }
        }
        break;
      case "onFormResubmission":
        if ((webviewParams != null &&
                webviewParams!.onFormResubmission != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            return (await webviewParams!.onFormResubmission!(
              _controllerFromPlatform,
              uri,
            ))?.toNativeValue();
          } else {
            return (await _inAppBrowserEventHandler!.onFormResubmission(
              uri,
            ))?.toNativeValue();
          }
        }
        break;
      case "onZoomScaleChanged":
        if ((webviewParams != null &&
                webviewParams!.onZoomScaleChanged != null) ||
            _inAppBrowserEventHandler != null) {
          double oldScale = call.arguments["oldScale"];
          double newScale = call.arguments["newScale"];

          if (webviewParams != null) {
            webviewParams!.onZoomScaleChanged!(
              _controllerFromPlatform,
              oldScale,
              newScale,
            );
          } else {
            _inAppBrowserEventHandler!.onZoomScaleChanged(oldScale, newScale);
          }
        }
        break;
      case "onReceivedTouchIconUrl":
        if ((webviewParams != null &&
                webviewParams!.onReceivedTouchIconUrl != null) ||
            _inAppBrowserEventHandler != null) {
          String url = call.arguments["url"];
          bool precomposed = call.arguments["precomposed"];
          WebUri uri = WebUri(url);

          if (webviewParams != null) {
            webviewParams!.onReceivedTouchIconUrl!(
              _controllerFromPlatform,
              uri,
              precomposed,
            );
          } else {
            _inAppBrowserEventHandler!.onReceivedTouchIconUrl(uri, precomposed);
          }
        }
        break;
      case "onJsAlert":
        if ((webviewParams != null && webviewParams!.onJsAlert != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsAlertRequest jsAlertRequest = JsAlertRequest.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onJsAlert != null) {
            return (await webviewParams!.onJsAlert!(
              _controllerFromPlatform,
              jsAlertRequest,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onJsAlert(
              jsAlertRequest,
            ))?.toMap();
          }
        }
        break;
      case "onJsConfirm":
        if ((webviewParams != null && webviewParams!.onJsConfirm != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsConfirmRequest jsConfirmRequest = JsConfirmRequest.fromMap(
            arguments,
          )!;

          if (webviewParams != null && webviewParams!.onJsConfirm != null) {
            return (await webviewParams!.onJsConfirm!(
              _controllerFromPlatform,
              jsConfirmRequest,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onJsConfirm(
              jsConfirmRequest,
            ))?.toMap();
          }
        }
        break;
      case "onJsPrompt":
        if ((webviewParams != null && webviewParams!.onJsPrompt != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsPromptRequest jsPromptRequest = JsPromptRequest.fromMap(arguments)!;

          if (webviewParams != null && webviewParams!.onJsPrompt != null) {
            return (await webviewParams!.onJsPrompt!(
              _controllerFromPlatform,
              jsPromptRequest,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onJsPrompt(
              jsPromptRequest,
            ))?.toMap();
          }
        }
        break;
      case "onJsBeforeUnload":
        if ((webviewParams != null &&
                webviewParams!.onJsBeforeUnload != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          JsBeforeUnloadRequest jsBeforeUnloadRequest =
              JsBeforeUnloadRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            return (await webviewParams!.onJsBeforeUnload!(
              _controllerFromPlatform,
              jsBeforeUnloadRequest,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onJsBeforeUnload(
              jsBeforeUnloadRequest,
            ))?.toMap();
          }
        }
        break;
      case "onSafeBrowsingHit":
        if ((webviewParams != null &&
                webviewParams!.onSafeBrowsingHit != null) ||
            _inAppBrowserEventHandler != null) {
          String url = call.arguments["url"];
          SafeBrowsingThreat? threatType = SafeBrowsingThreat.fromNativeValue(
            call.arguments["threatType"],
          );
          WebUri uri = WebUri(url);

          if (webviewParams != null) {
            return (await webviewParams!.onSafeBrowsingHit!(
              _controllerFromPlatform,
              uri,
              threatType,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onSafeBrowsingHit(
              uri,
              threatType,
            ))?.toMap();
          }
        }
        break;
      case "onReceivedLoginRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedLoginRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          LoginRequest loginRequest = LoginRequest.fromMap(arguments)!;

          if (webviewParams != null) {
            webviewParams!.onReceivedLoginRequest!(
              _controllerFromPlatform,
              loginRequest,
            );
          } else {
            _inAppBrowserEventHandler!.onReceivedLoginRequest(loginRequest);
          }
        }
        break;
      case "onPermissionRequestCanceled":
        if ((webviewParams != null &&
                webviewParams!.onPermissionRequestCanceled != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          PermissionRequest permissionRequest = PermissionRequest.fromMap(
            arguments,
          )!;

          if (webviewParams != null &&
              webviewParams!.onPermissionRequestCanceled != null) {
            webviewParams!.onPermissionRequestCanceled!(
              _controllerFromPlatform,
              permissionRequest,
            );
          } else {
            _inAppBrowserEventHandler!.onPermissionRequestCanceled(
              permissionRequest,
            );
          }
        }
        break;
      case "onRequestFocus":
        if ((webviewParams != null && webviewParams!.onRequestFocus != null) ||
            _inAppBrowserEventHandler != null) {
          if (webviewParams != null && webviewParams!.onRequestFocus != null) {
            webviewParams!.onRequestFocus!(_controllerFromPlatform);
          } else {
            _inAppBrowserEventHandler!.onRequestFocus();
          }
        }
        break;
      case "onReceivedHttpAuthRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedHttpAuthRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          HttpAuthenticationChallenge challenge =
              HttpAuthenticationChallenge.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onReceivedHttpAuthRequest != null) {
            return (await webviewParams!.onReceivedHttpAuthRequest!(
              _controllerFromPlatform,
              challenge,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onReceivedHttpAuthRequest(
              challenge,
            ))?.toMap();
          }
        }
        break;
      case "onReceivedServerTrustAuthRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedServerTrustAuthRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ServerTrustChallenge challenge = ServerTrustChallenge.fromMap(
            arguments,
          )!;

          if (webviewParams != null &&
              webviewParams!.onReceivedServerTrustAuthRequest != null) {
            return (await webviewParams!.onReceivedServerTrustAuthRequest!(
              _controllerFromPlatform,
              challenge,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!
                    .onReceivedServerTrustAuthRequest(challenge))
                ?.toMap();
          }
        }
        break;
      case "onReceivedClientCertRequest":
        if ((webviewParams != null &&
                webviewParams!.onReceivedClientCertRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ClientCertChallenge challenge = ClientCertChallenge.fromMap(
            arguments,
          )!;

          if (webviewParams != null &&
              webviewParams!.onReceivedClientCertRequest != null) {
            return (await webviewParams!.onReceivedClientCertRequest!(
              _controllerFromPlatform,
              challenge,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!
                    .onReceivedClientCertRequest(challenge))
                ?.toMap();
          }
        }
        break;
      case "onPermissionRequest":
        if ((webviewParams != null &&
                webviewParams!.onPermissionRequest != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          PermissionRequest permissionRequest = PermissionRequest.fromMap(
            arguments,
          )!;

          if (webviewParams != null) {
            return (await webviewParams!.onPermissionRequest!(
              _controllerFromPlatform,
              permissionRequest,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onPermissionRequest(
              permissionRequest,
            ))?.toMap();
          }
        }
        break;
      case "onUpdateVisitedHistory":
        if ((webviewParams != null &&
                webviewParams!.onUpdateVisitedHistory != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          bool? isReload = call.arguments["isReload"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null &&
              webviewParams!.onUpdateVisitedHistory != null) {
            webviewParams!.onUpdateVisitedHistory!(
              _controllerFromPlatform,
              uri,
              isReload,
            );
          } else {
            _inAppBrowserEventHandler!.onUpdateVisitedHistory(uri, isReload);
          }
        }
        break;
      case "onWebContentProcessDidTerminate":
        if (webviewParams != null &&
            webviewParams!.onWebContentProcessDidTerminate != null) {
          webviewParams!.onWebContentProcessDidTerminate!(
            _controllerFromPlatform,
          );
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onWebContentProcessDidTerminate();
        }
        break;
      case "onPageCommitVisible":
        if ((webviewParams != null &&
                webviewParams!.onPageCommitVisible != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;
          if (webviewParams != null &&
              webviewParams!.onPageCommitVisible != null) {
            webviewParams!.onPageCommitVisible!(_controllerFromPlatform, uri);
          } else {
            _inAppBrowserEventHandler!.onPageCommitVisible(uri);
          }
        }
        break;
      case "onNavigationStarted":
      case "onNavigationRedirected":
      case "onNavigationCompleted":
        // The three share one body: identical payload, identical shape, and the only difference is
        // which handler receives it.
        final navigationHandler = switch (call.method) {
          "onNavigationStarted" => webviewParams?.onNavigationStarted,
          "onNavigationRedirected" => webviewParams?.onNavigationRedirected,
          _ => webviewParams?.onNavigationCompleted,
        };
        if (navigationHandler != null || _inAppBrowserEventHandler != null) {
          final navigation = WebViewNavigation.fromMap(
            call.arguments["navigation"]?.cast<String, dynamic>(),
          );
          if (navigation != null) {
            if (navigationHandler != null) {
              navigationHandler(_controllerFromPlatform, navigation);
            } else {
              switch (call.method) {
                case "onNavigationStarted":
                  _inAppBrowserEventHandler!.onNavigationStarted(navigation);
                  break;
                case "onNavigationRedirected":
                  _inAppBrowserEventHandler!.onNavigationRedirected(navigation);
                  break;
                default:
                  _inAppBrowserEventHandler!.onNavigationCompleted(navigation);
                  break;
              }
            }
          }
        }
        break;
      case "onPageLoadEvent":
      case "onPageDomContentLoadedEvent":
      case "onPageDeleted":
        // Same payload and same shape for all three; only the destination differs.
        final pageHandler = switch (call.method) {
          "onPageLoadEvent" => webviewParams?.onPageLoadEvent,
          "onPageDomContentLoadedEvent" =>
            webviewParams?.onPageDomContentLoadedEvent,
          _ => webviewParams?.onPageDeleted,
        };
        if (pageHandler != null || _inAppBrowserEventHandler != null) {
          final page = WebViewPage.fromMap(
            call.arguments["page"]?.cast<String, dynamic>(),
          );
          if (page != null) {
            if (pageHandler != null) {
              pageHandler(_controllerFromPlatform, page);
            } else {
              switch (call.method) {
                case "onPageLoadEvent":
                  _inAppBrowserEventHandler!.onPageLoadEvent(page);
                  break;
                case "onPageDomContentLoadedEvent":
                  _inAppBrowserEventHandler!.onPageDomContentLoadedEvent(page);
                  break;
                default:
                  _inAppBrowserEventHandler!.onPageDeleted(page);
                  break;
              }
            }
          }
        }
        break;
      case "onFirstContentfulPaintMillis":
      case "onLargestContentfulPaintMillis":
        // Both carry a duration under the same key, so they share a body too.
        final isFirst = call.method == "onFirstContentfulPaintMillis";
        final paintHandler = isFirst
            ? webviewParams?.onFirstContentfulPaintMillis
            : webviewParams?.onLargestContentfulPaintMillis;
        if (paintHandler != null || _inAppBrowserEventHandler != null) {
          final page = WebViewPage.fromMap(
            call.arguments["page"]?.cast<String, dynamic>(),
          );
          final int durationMillis = call.arguments["durationMillis"];
          if (page != null) {
            if (paintHandler != null) {
              paintHandler(_controllerFromPlatform, page, durationMillis);
            } else if (isFirst) {
              _inAppBrowserEventHandler!.onFirstContentfulPaintMillis(
                page,
                durationMillis,
              );
            } else {
              _inAppBrowserEventHandler!.onLargestContentfulPaintMillis(
                page,
                durationMillis,
              );
            }
          }
        }
        break;
      case "onPerformanceMarkMillis":
        if ((webviewParams != null &&
                webviewParams!.onPerformanceMarkMillis != null) ||
            _inAppBrowserEventHandler != null) {
          final page = WebViewPage.fromMap(
            call.arguments["page"]?.cast<String, dynamic>(),
          );
          final String markName = call.arguments["markName"];
          final int markTimeMillis = call.arguments["markTimeMillis"];
          if (page != null) {
            if (webviewParams != null &&
                webviewParams!.onPerformanceMarkMillis != null) {
              webviewParams!.onPerformanceMarkMillis!(
                _controllerFromPlatform,
                page,
                markName,
                markTimeMillis,
              );
            } else {
              _inAppBrowserEventHandler!.onPerformanceMarkMillis(
                page,
                markName,
                markTimeMillis,
              );
            }
          }
        }
        break;
      case "onDidReceiveServerRedirectForProvisionalNavigation":
        if (webviewParams != null &&
            webviewParams!.onDidReceiveServerRedirectForProvisionalNavigation !=
                null) {
          webviewParams!.onDidReceiveServerRedirectForProvisionalNavigation!(
            _controllerFromPlatform,
          );
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!
              .onDidReceiveServerRedirectForProvisionalNavigation();
        }
        break;
      case "onNavigationResponse":
        if ((webviewParams != null &&
                webviewParams!.onNavigationResponse != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          NavigationResponse navigationResponse = NavigationResponse.fromMap(
            arguments,
          )!;

          if (webviewParams != null) {
            return (await webviewParams!.onNavigationResponse!(
              _controllerFromPlatform,
              navigationResponse,
            ))?.toNativeValue();
          } else {
            return (await _inAppBrowserEventHandler!.onNavigationResponse(
              navigationResponse,
            ))?.toNativeValue();
          }
        }
        break;
      case "shouldAllowDeprecatedTLS":
        if ((webviewParams != null &&
                webviewParams!.shouldAllowDeprecatedTLS != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          URLAuthenticationChallenge challenge =
              URLAuthenticationChallenge.fromMap(arguments)!;

          if (webviewParams != null) {
            return (await webviewParams!.shouldAllowDeprecatedTLS!(
              _controllerFromPlatform,
              challenge,
            ))?.toNativeValue();
          } else {
            return (await _inAppBrowserEventHandler!.shouldAllowDeprecatedTLS(
              challenge,
            ))?.toNativeValue();
          }
        }
        break;
      case "onLongPressHitTestResult":
        if ((webviewParams != null &&
                webviewParams!.onLongPressHitTestResult != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          InAppWebViewHitTestResult hitTestResult =
              InAppWebViewHitTestResult.fromMap(arguments)!;

          if (webviewParams != null &&
              webviewParams!.onLongPressHitTestResult != null) {
            webviewParams!.onLongPressHitTestResult!(
              _controllerFromPlatform,
              hitTestResult,
            );
          } else {
            _inAppBrowserEventHandler!.onLongPressHitTestResult(hitTestResult);
          }
        }
        break;
      case "onCreateContextMenu":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null && contextMenu.onCreateContextMenu != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          InAppWebViewHitTestResult hitTestResult =
              InAppWebViewHitTestResult.fromMap(arguments)!;

          contextMenu.onCreateContextMenu!(hitTestResult);
        }
        break;
      case "onHideContextMenu":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null && contextMenu.onHideContextMenu != null) {
          contextMenu.onHideContextMenu!();
        }
        break;
      case "onContextMenuActionItemClicked":
        ContextMenu? contextMenu;
        if (webviewParams != null && webviewParams!.contextMenu != null) {
          contextMenu = webviewParams!.contextMenu;
        } else if (_inAppBrowserEventHandler != null &&
            _inAppBrowser!.contextMenu != null) {
          contextMenu = _inAppBrowser!.contextMenu;
        }

        if (contextMenu != null) {
          dynamic id = call.arguments["id"];
          String title = call.arguments["title"];

          ContextMenuItem menuItemClicked = ContextMenuItem(
            id: id,
            title: title,
            action: null,
          );

          for (var menuItem in contextMenu.menuItems) {
            if (menuItem.id == id) {
              menuItemClicked = menuItem;
              if (menuItem.action != null) {
                menuItem.action!();
              }
              break;
            }
          }

          if (contextMenu.onContextMenuActionItemClicked != null) {
            contextMenu.onContextMenuActionItemClicked!(menuItemClicked);
          }
        }
        break;
      case "onEnterFullscreen":
        if (webviewParams != null && webviewParams!.onEnterFullscreen != null) {
          webviewParams!.onEnterFullscreen!(_controllerFromPlatform);
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onEnterFullscreen();
        }
        break;
      case "onExitFullscreen":
        if (webviewParams != null && webviewParams!.onExitFullscreen != null) {
          webviewParams!.onExitFullscreen!(_controllerFromPlatform);
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onExitFullscreen();
        }
        break;
      case "onOverScrolled":
        if ((webviewParams != null && webviewParams!.onOverScrolled != null) ||
            _inAppBrowserEventHandler != null) {
          int x = call.arguments["x"];
          int y = call.arguments["y"];
          bool clampedX = call.arguments["clampedX"];
          bool clampedY = call.arguments["clampedY"];

          if (webviewParams != null && webviewParams!.onOverScrolled != null) {
            webviewParams!.onOverScrolled!(
              _controllerFromPlatform,
              x,
              y,
              clampedX,
              clampedY,
            );
          } else {
            _inAppBrowserEventHandler!.onOverScrolled(x, y, clampedX, clampedY);
          }
        }
        break;
      case "onWindowFocus":
        if (webviewParams != null && webviewParams!.onWindowFocus != null) {
          webviewParams!.onWindowFocus!(_controllerFromPlatform);
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onWindowFocus();
        }
        break;
      case "onWindowBlur":
        if (webviewParams != null && webviewParams!.onWindowBlur != null) {
          webviewParams!.onWindowBlur!(_controllerFromPlatform);
        } else if (_inAppBrowserEventHandler != null) {
          _inAppBrowserEventHandler!.onWindowBlur();
        }
        break;
      case "onPrintRequest":
        if ((webviewParams != null && webviewParams!.onPrintRequest != null) ||
            _inAppBrowserEventHandler != null) {
          String? url = call.arguments["url"];
          WebUri? uri = url != null ? WebUri(url) : null;

          if (webviewParams != null) {
            return await webviewParams!.onPrintRequest!(
              _controllerFromPlatform,
              uri,
            );
          } else {
            return await _inAppBrowserEventHandler!.onPrintRequest(uri);
          }
        }
        break;
      case "onInjectedScriptLoaded":
        String id = call.arguments[0];
        var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
        if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
            onLoadCallback != null) {
          onLoadCallback();
        }
        break;
      case "onInjectedScriptError":
        String id = call.arguments[0];
        var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
        if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
            onErrorCallback != null) {
          onErrorCallback();
        }
        break;
      case "onCameraCaptureStateChanged":
        if ((webviewParams != null &&
                webviewParams!.onCameraCaptureStateChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldState = MediaCaptureState.fromNativeValue(
            call.arguments["oldState"],
          );
          var newState = MediaCaptureState.fromNativeValue(
            call.arguments["newState"],
          );

          if (webviewParams != null &&
              webviewParams!.onCameraCaptureStateChanged != null) {
            webviewParams!.onCameraCaptureStateChanged!(
              _controllerFromPlatform,
              oldState,
              newState,
            );
          } else {
            _inAppBrowserEventHandler!.onCameraCaptureStateChanged(
              oldState,
              newState,
            );
          }
        }
        break;
      case "onMicrophoneCaptureStateChanged":
        if ((webviewParams != null &&
                webviewParams!.onMicrophoneCaptureStateChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldState = MediaCaptureState.fromNativeValue(
            call.arguments["oldState"],
          );
          var newState = MediaCaptureState.fromNativeValue(
            call.arguments["newState"],
          );

          if (webviewParams != null &&
              webviewParams!.onMicrophoneCaptureStateChanged != null) {
            webviewParams!.onMicrophoneCaptureStateChanged!(
              _controllerFromPlatform,
              oldState,
              newState,
            );
          } else {
            _inAppBrowserEventHandler!.onMicrophoneCaptureStateChanged(
              oldState,
              newState,
            );
          }
        }
        break;
      case "onContentSizeChanged":
        if ((webviewParams != null &&
                webviewParams!.onContentSizeChanged != null) ||
            _inAppBrowserEventHandler != null) {
          var oldContentSize = MapSize.fromMap(
            call.arguments["oldContentSize"]?.cast<String, dynamic>(),
          )!;
          var newContentSize = MapSize.fromMap(
            call.arguments["newContentSize"]?.cast<String, dynamic>(),
          )!;

          if (webviewParams != null &&
              webviewParams!.onContentSizeChanged != null) {
            webviewParams!.onContentSizeChanged!(
              _controllerFromPlatform,
              oldContentSize,
              newContentSize,
            );
          } else {
            _inAppBrowserEventHandler!.onContentSizeChanged(
              oldContentSize,
              newContentSize,
            );
          }
        }
        break;
      case "onRequestVisitedHistory":
        if ((webviewParams != null &&
                webviewParams!.onRequestVisitedHistory != null) ||
            _inAppBrowserEventHandler != null) {
          // `WebUri` cannot cross the channel, and the platform wants a `String[]`. A null result
          // stays null rather than becoming `[]`: Kotlin treats the two differently, null meaning
          // "keep the platform default" and `[]` meaning "nothing has been visited".
          final List<WebUri>? urls =
              webviewParams != null &&
                  webviewParams!.onRequestVisitedHistory != null
              ? await webviewParams!.onRequestVisitedHistory!(
                  _controllerFromPlatform,
                )
              : await _inAppBrowserEventHandler!.onRequestVisitedHistory();
          return urls?.map((url) => url.toString()).toList();
        }
        break;
      case "onShowFileChooser":
        if ((webviewParams != null &&
                webviewParams!.onShowFileChooser != null) ||
            _inAppBrowserEventHandler != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          ShowFileChooserRequest request = ShowFileChooserRequest.fromMap(
            arguments,
          )!;

          if (webviewParams != null &&
              webviewParams!.onShowFileChooser != null) {
            return (await webviewParams!.onShowFileChooser!(
              _controllerFromPlatform,
              request,
            ))?.toMap();
          } else {
            return (await _inAppBrowserEventHandler!.onShowFileChooser(
              request,
            ))?.toMap();
          }
        }
        break;
      case "onCallJsHandler":
        String handlerName = call.arguments["handlerName"];
        Map<String, dynamic> handlerDataMap = call.arguments["data"]
            .cast<String, dynamic>();
        // decode args to json
        handlerDataMap["args"] = jsonDecode(handlerDataMap["args"]);
        final handlerData = JavaScriptHandlerFunctionData.fromMap(
          handlerDataMap,
        )!;

        _debugLog(handlerName, handlerData);

        switch (handlerName) {
          case "onLoadResource":
            if ((webviewParams != null &&
                    webviewParams!.onLoadResource != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              arguments["startTime"] = arguments["startTime"] is int
                  ? arguments["startTime"].toDouble()
                  : arguments["startTime"];
              arguments["duration"] = arguments["duration"] is int
                  ? arguments["duration"].toDouble()
                  : arguments["duration"];

              var response = LoadedResource.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onLoadResource != null) {
                webviewParams!.onLoadResource!(
                  _controllerFromPlatform,
                  response,
                );
              } else {
                _inAppBrowserEventHandler!.onLoadResource(response);
              }
            }
            return null;
          case "shouldInterceptAjaxRequest":
            if ((webviewParams != null &&
                    webviewParams!.shouldInterceptAjaxRequest != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.shouldInterceptAjaxRequest != null) {
                return jsonEncode(
                  await params.webviewParams!.shouldInterceptAjaxRequest!(
                    _controllerFromPlatform,
                    request,
                  ),
                );
              } else {
                return jsonEncode(
                  await _inAppBrowserEventHandler!.shouldInterceptAjaxRequest(
                    request,
                  ),
                );
              }
            }
            return null;
          case "onAjaxReadyStateChange":
            if ((webviewParams != null &&
                    webviewParams!.onAjaxReadyStateChange != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onAjaxReadyStateChange != null) {
                return jsonEncode(
                  (await webviewParams!.onAjaxReadyStateChange!(
                    _controllerFromPlatform,
                    request,
                  ))?.toNativeValue(),
                );
              } else {
                return jsonEncode(
                  (await _inAppBrowserEventHandler!.onAjaxReadyStateChange(
                    request,
                  ))?.toNativeValue(),
                );
              }
            }
            return null;
          case "onAjaxProgress":
            if ((webviewParams != null &&
                    webviewParams!.onAjaxProgress != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              AjaxRequest request = AjaxRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.onAjaxProgress != null) {
                return jsonEncode(
                  (await webviewParams!.onAjaxProgress!(
                    _controllerFromPlatform,
                    request,
                  ))?.toNativeValue(),
                );
              } else {
                return jsonEncode(
                  (await _inAppBrowserEventHandler!.onAjaxProgress(
                    request,
                  ))?.toNativeValue(),
                );
              }
            }
            return null;
          case "shouldInterceptFetchRequest":
            if ((webviewParams != null &&
                    webviewParams!.shouldInterceptFetchRequest != null) ||
                _inAppBrowserEventHandler != null) {
              Map<String, dynamic> arguments = handlerData.args[0]
                  .cast<String, dynamic>();
              FetchRequest request = FetchRequest.fromMap(arguments)!;

              if (webviewParams != null &&
                  webviewParams!.shouldInterceptFetchRequest != null) {
                return jsonEncode(
                  await webviewParams!.shouldInterceptFetchRequest!(
                    _controllerFromPlatform,
                    request,
                  ),
                );
              } else {
                return jsonEncode(
                  await _inAppBrowserEventHandler!.shouldInterceptFetchRequest(
                    request,
                  ),
                );
              }
            }
            return null;
          case "onWindowFocus":
            if (webviewParams != null && webviewParams!.onWindowFocus != null) {
              webviewParams!.onWindowFocus!(_controllerFromPlatform);
            } else if (_inAppBrowserEventHandler != null) {
              _inAppBrowserEventHandler!.onWindowFocus();
            }
            return null;
          case "onWindowBlur":
            if (webviewParams != null && webviewParams!.onWindowBlur != null) {
              webviewParams!.onWindowBlur!(_controllerFromPlatform);
            } else if (_inAppBrowserEventHandler != null) {
              _inAppBrowserEventHandler!.onWindowBlur();
            }
            return null;
          case "onInjectedScriptLoaded":
            String id = handlerData.args[0];
            var onLoadCallback = _injectedScriptsFromURL[id]?.onLoad;
            if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
                onLoadCallback != null) {
              onLoadCallback();
            }
            return null;
          case "onInjectedScriptError":
            String id = handlerData.args[0];
            var onErrorCallback = _injectedScriptsFromURL[id]?.onError;
            if ((webviewParams != null || _inAppBrowserEventHandler != null) &&
                onErrorCallback != null) {
              onErrorCallback();
            }
            return null;
        }

        if (_javaScriptHandlersMap.containsKey(handlerName)) {
          // convert result to json
          try {
            dynamic jsHandlerResult;
            if (_javaScriptHandlersMap[handlerName]
                is JavaScriptHandlerFunction) {
              jsHandlerResult =
                  await (_javaScriptHandlersMap[handlerName]
                      as JavaScriptHandlerFunction)(handlerData);
            } else {
              jsHandlerResult = await _javaScriptHandlersMap[handlerName]!();
            }
            return jsonEncode(jsHandlerResult);
          } catch (error, stacktrace) {
            developer.log(
              '$error\n$stacktrace',
              name: 'JavaScript Handler "$handlerName"',
            );
            throw Exception(error.toString().replaceFirst('Exception: ', ''));
          }
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  Future<WebUri?> getUrl() async {
    String? url = await _hostApi?.getUrl();
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<String?> getTitle() async {
    return await _hostApi?.getTitle();
  }

  @override
  Future<int?> getProgress() async {
    return await _hostApi?.getProgress();
  }

  @override
  Future<String?> getHtml() async {
    String? html;

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      html = await evaluateJavascript(
        source: "window.document.getElementsByTagName('html')[0].outerHTML;",
      );
      if (html != null && html.isNotEmpty) return html;
    }

    var webviewUrl = await getUrl();
    if (webviewUrl == null) {
      return html;
    }

    if (webviewUrl.isScheme("file")) {
      var assetPathSplit = webviewUrl.toString().split("/flutter_assets/");
      var assetPath = assetPathSplit[assetPathSplit.length - 1];
      try {
        var bytes = await rootBundle.load(assetPath);
        html = utf8.decode(bytes.buffer.asUint8List());
      } catch (e) {}
    } else {
      try {
        HttpClient client = HttpClient();
        var htmlRequest = await client.getUrl(webviewUrl);
        html = await (await htmlRequest.close())
            .transform(Utf8Decoder())
            .join();
      } catch (e) {
        developer.log(e.toString(), name: runtimeType.toString());
      }
    }

    return html;
  }

  @override
  Future<List<Favicon>> getFavicons() async {
    List<Favicon> favicons = [];

    var webviewUrl = await getUrl();

    if (webviewUrl == null) {
      return favicons;
    }

    String? manifestUrl;

    var html = await getHtml();
    if (html == null || html.isEmpty) {
      return favicons;
    }
    String? assetPathBase;

    if (webviewUrl.isScheme("file")) {
      var assetPathSplit = webviewUrl.toString().split("/flutter_assets/");
      assetPathBase = "${assetPathSplit[0]}/flutter_assets/";
    }

    InAppWebViewSettings? settings = await getSettings();
    if (settings != null && settings.javaScriptEnabled == true) {
      List<Map<dynamic, dynamic>> links =
          (await evaluateJavascript(
            source: """
(function() {
  var linkNodes = document.head.getElementsByTagName("link");
  var links = [];
  for (var i = 0; i < linkNodes.length; i++) {
    var linkNode = linkNodes[i];
    if (linkNode.rel === 'manifest') {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: null
        }
      );
    } else if (linkNode.rel != null && linkNode.rel.indexOf('icon') >= 0) {
      links.push(
        {
          rel: linkNode.rel,
          href: linkNode.href,
          sizes: linkNode.sizes != null && linkNode.sizes.value != "" ? linkNode.sizes.value : null
        }
      );
    }
  }
  return links;
})();
""",
          ))?.cast<Map<dynamic, dynamic>>() ??
          [];
      for (var link in links) {
        if (link["rel"] == "manifest") {
          manifestUrl = link["href"];
          if (!_isUrlAbsolute(manifestUrl!)) {
            if (manifestUrl.startsWith("/")) {
              manifestUrl = manifestUrl.substring(1);
            }
            manifestUrl =
                ((assetPathBase == null)
                    ? "${webviewUrl.scheme}://${webviewUrl.host}/"
                    : assetPathBase) +
                manifestUrl;
          }
          continue;
        }
        favicons.addAll(
          _createFavicons(
            webviewUrl,
            assetPathBase,
            link["href"],
            link["rel"],
            link["sizes"],
            false,
          ),
        );
      }
    }

    // try to get /favicon.ico
    try {
      HttpClient client = HttpClient();
      var faviconUrl = "${webviewUrl.scheme}://${webviewUrl.host}/favicon.ico";
      var faviconUri = WebUri(faviconUrl);
      var headRequest = await client.headUrl(faviconUri);
      var headResponse = await headRequest.close();
      if (headResponse.statusCode == 200) {
        favicons.add(Favicon(url: faviconUri, rel: "shortcut icon"));
      }
    } catch (e) {
      developer.log(
        "/favicon.ico file not found: $e",
        name: runtimeType.toString(),
      );
    }

    // try to get the manifest file
    HttpClientRequest? manifestRequest;
    HttpClientResponse? manifestResponse;
    bool manifestFound = false;
    manifestUrl ??= "${webviewUrl.scheme}://${webviewUrl.host}/manifest.json";
    try {
      HttpClient client = HttpClient();
      manifestRequest = await client.getUrl(Uri.parse(manifestUrl));
      manifestResponse = await manifestRequest.close();
      manifestFound =
          manifestResponse.statusCode == 200 &&
          manifestResponse.headers.contentType?.mimeType == "application/json";
    } catch (e) {
      developer.log(
        "Manifest file not found: $e",
        name: runtimeType.toString(),
      );
    }

    if (manifestFound) {
      try {
        Map<String, dynamic> manifest = json.decode(
          await manifestResponse!.transform(Utf8Decoder()).join(),
        );
        if (manifest.containsKey("icons")) {
          for (Map<String, dynamic> icon in manifest["icons"]) {
            favicons.addAll(
              _createFavicons(
                webviewUrl,
                assetPathBase,
                icon["src"],
                icon["rel"],
                icon["sizes"],
                true,
              ),
            );
          }
        }
      } catch (e) {
        developer.log(
          "Cannot get favicons from Manifest file. It might not have a valid format: $e",
          error: e,
          name: runtimeType.toString(),
        );
      }
    }

    return favicons;
  }

  bool _isUrlAbsolute(String url) {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  List<Favicon> _createFavicons(
    WebUri url,
    String? assetPathBase,
    String urlIcon,
    String? rel,
    String? sizes,
    bool isManifest,
  ) {
    List<Favicon> favicons = [];

    List<String> urlSplit = urlIcon.split("/");
    if (!_isUrlAbsolute(urlIcon)) {
      if (urlIcon.startsWith("/")) {
        urlIcon = urlIcon.substring(1);
      }
      urlIcon =
          ((assetPathBase == null)
              ? "${url.scheme}://${url.host}/"
              : assetPathBase) +
          urlIcon;
    }
    if (isManifest) {
      rel = (sizes != null)
          ? urlSplit[urlSplit.length - 1]
                .replaceFirst("-$sizes", "")
                .split(" ")[0]
                .split(".")[0]
          : null;
    }
    if (sizes != null && sizes.isNotEmpty && sizes != "any") {
      List<String> sizesSplit = sizes.split(" ");
      for (String size in sizesSplit) {
        int width = int.parse(size.split("x")[0]);
        int height = int.parse(size.split("x")[1]);
        favicons.add(
          Favicon(url: WebUri(urlIcon), rel: rel, width: width, height: height),
        );
      }
    } else {
      favicons.add(
        Favicon(url: WebUri(urlIcon), rel: rel, width: null, height: null),
      );
    }

    return favicons;
  }

  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    WebUri? allowingReadAccessTo,
  }) async {
    assert(urlRequest.url != null && urlRequest.url.toString().isNotEmpty);
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"),
    );

    // `allowingReadAccessTo` is iOS's; the Android side never read it (§212).
    await _hostApi?.loadUrl(urlRequest.toMap());
  }

  @override
  Future<void> postUrl({
    required WebUri url,
    required Uint8List postData,
  }) async {
    assert(url.toString().isNotEmpty);
    await _hostApi?.postUrl(url.toString(), postData);
  }

  @override
  Future<void> loadData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    WebUri? historyUrl,
    WebUri? allowingReadAccessTo,
  }) async {
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo.isScheme("file"),
    );

    // `allowingReadAccessTo` is iOS's: the Android side never read it, so it is not sent (§207).
    await _hostApi?.loadData(
      data,
      mimeType,
      encoding,
      baseUrl?.toString() ?? "about:blank",
      historyUrl?.toString() ?? "about:blank",
    );
  }

  @override
  Future<void> loadFile({required String assetFilePath}) async {
    assert(assetFilePath.isNotEmpty);
    await _hostApi?.loadFile(assetFilePath);
  }

  @override
  Future<void> reload() async {
    await _hostApi?.reload();
  }

  @override
  Future<void> goBack() async {
    await _hostApi?.goBack();
  }

  @override
  Future<bool> canGoBack() async {
    return await _hostApi?.canGoBack() ?? false;
  }

  @override
  Future<void> goForward() async {
    await _hostApi?.goForward();
  }

  @override
  Future<bool> canGoForward() async {
    return await _hostApi?.canGoForward() ?? false;
  }

  @override
  Future<void> goBackOrForward({required int steps}) async {
    await _hostApi?.goBackOrForward(steps);
  }

  @override
  Future<bool> canGoBackOrForward({required int steps}) async {
    return await _hostApi?.canGoBackOrForward(steps) ?? false;
  }

  @override
  Future<void> goTo({required WebHistoryItem historyItem}) async {
    var steps = historyItem.offset;
    if (steps != null) {
      await goBackOrForward(steps: steps);
    }
  }

  @override
  Future<bool> isLoading() async {
    return await _hostApi?.isLoading() ?? false;
  }

  @override
  Future<void> stopLoading() async {
    await _hostApi?.stopLoading();
  }

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    dynamic data = await _hostApi?.evaluateJavascript(
      source,
      contentWorld?.toMap(),
    );
    if (data != null) {
      try {
        // try to json decode the data coming from JavaScript
        // otherwise return it as it is.
        data = json.decode(data);
      } catch (e) {}
    }
    return data;
  }

  @override
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) async {
    assert(urlFile.toString().isNotEmpty);
    var id = scriptHtmlTagAttributes?.id;
    if (scriptHtmlTagAttributes != null && id != null) {
      _injectedScriptsFromURL[id] = scriptHtmlTagAttributes;
    }
    await _hostApi?.injectJavascriptFileFromUrl(
      urlFile.toString(),
      scriptHtmlTagAttributes?.toMap(),
    );
  }

  @override
  Future<dynamic> injectJavascriptFileFromAsset({
    required String assetFilePath,
  }) async {
    String source = await rootBundle.loadString(assetFilePath);
    return await evaluateJavascript(source: source);
  }

  @override
  Future<void> injectCSSCode({required String source}) async {
    await _hostApi?.injectCSSCode(source);
  }

  @override
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) async {
    assert(urlFile.toString().isNotEmpty);
    await _hostApi?.injectCSSFileFromUrl(
      urlFile.toString(),
      cssLinkHtmlTagAttributes?.toMap(),
    );
  }

  @override
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) async {
    String source = await rootBundle.loadString(assetFilePath);
    await injectCSSCode(source: source);
  }

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) {
    assert(
      !kJavaScriptHandlerForbiddenNames.contains(handlerName),
      '"$handlerName" is a forbidden name!',
    );
    _javaScriptHandlersMap[handlerName] = (callback);
  }

  @override
  Function? removeJavaScriptHandler({required String handlerName}) {
    return _javaScriptHandlersMap.remove(handlerName);
  }

  @override
  bool hasJavaScriptHandler({required String handlerName}) {
    return _javaScriptHandlersMap.containsKey(handlerName);
  }

  @override
  Future<Uint8List?> takeScreenshot({
    ScreenshotConfiguration? screenshotConfiguration,
  }) async {
    return await _hostApi?.takeScreenshot(screenshotConfiguration?.toMap());
  }

  @override
  Future<void> setSettings({required InAppWebViewSettings settings}) async {
    await _hostApi?.setSettings(settings.toMap());
  }

  @override
  Future<InAppWebViewSettings?> getSettings() async {
    final settings = await _hostApi?.getSettings();
    if (settings != null) {
      return InAppWebViewSettings.fromMap(settings.cast<String, dynamic>());
    }

    return null;
  }

  @override
  Future<WebHistory?> getCopyBackForwardList() async {
    final result = (await _hostApi?.getCopyBackForwardList())
        ?.cast<String, dynamic>();
    return WebHistory.fromMap(result);
  }

  @override
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) async {
    await _hostApi?.scrollTo(x, y, animated);
  }

  @override
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) async {
    await _hostApi?.scrollBy(x, y, animated);
  }

  @override
  Future<void> pauseTimers() async {
    await _hostApi?.pauseTimers();
  }

  @override
  Future<void> resumeTimers() async {
    await _hostApi?.resumeTimers();
  }

  @override
  Future<AndroidPrintJobController?> printCurrentPage({
    PrintJobSettings? settings,
  }) async {
    final jobId = await _hostApi?.printCurrentPage(settings?.toMap());
    if (jobId != null) {
      return AndroidPrintJobController(
        PlatformPrintJobControllerCreationParams(id: jobId),
      );
    }
    return null;
  }

  @override
  Future<int?> getContentHeight() async {
    int? height = await _hostApi?.getContentHeight();
    if (height == null || height == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
        source: "document.documentElement.scrollHeight;",
      );
      if (scrollHeight != null && scrollHeight is num) {
        height = scrollHeight.toInt();
      }
    }
    return height;
  }

  @override
  Future<int?> getContentWidth() async {
    int? height = await _hostApi?.getContentWidth();
    if (height == null || height == 0) {
      // try to use javascript
      var scrollHeight = await evaluateJavascript(
        source: "document.documentElement.scrollWidth;",
      );
      if (scrollHeight != null && scrollHeight is num) {
        height = scrollHeight.toInt();
      }
    }
    return height;
  }

  @override
  Future<void> zoomBy({
    required double zoomFactor,
    bool animated = false,
  }) async {
    assert(zoomFactor > 0.01 && zoomFactor <= 100.0);

    // `animated` is iOS's; the Android side never read it (§212).
    await _hostApi?.zoomBy(zoomFactor);
  }

  @override
  Future<WebUri?> getOriginalUrl() async {
    String? url = await _hostApi?.getOriginalUrl();
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<double?> getZoomScale() async {
    return await _hostApi?.getZoomScale();
  }

  @override
  Future<String?> getSelectedText() async {
    return await _hostApi?.getSelectedText();
  }

  @override
  Future<InAppWebViewHitTestResult?> getHitTestResult() async {
    final hitTestResultMap = await _hostApi?.getHitTestResult();

    if (hitTestResultMap == null) {
      return null;
    }

    InAppWebViewHitTestResultType? type =
        InAppWebViewHitTestResultType.fromNativeValue(
          (hitTestResultMap["type"] as num?)?.toInt(),
        );
    String? extra = hitTestResultMap["extra"] as String?;
    return InAppWebViewHitTestResult(type: type, extra: extra);
  }

  @override
  Future<bool?> requestFocus({
    FocusDirection? direction,
    InAppWebViewRect? previouslyFocusedRect,
  }) async {
    return await _hostApi?.requestFocus(
      direction?.toNativeValue(),
      previouslyFocusedRect?.toMap(),
    );
  }

  @override
  Future<void> clearFocus() async {
    await _hostApi?.clearFocus();
  }

  @override
  Future<void> showInputMethod() async {
    await _hostApi?.showInputMethod();
  }

  @override
  Future<void> setAudioMuted(bool muted) async {
    await _hostApi?.setAudioMuted(muted);
  }

  @override
  Future<bool> isAudioMuted() async {
    return await _hostApi?.isAudioMuted() ?? false;
  }

  @override
  Future<bool> prerenderUrl(WebUri url) async {
    return await _hostApi?.prerenderUrl(url.toString()) ?? false;
  }

  @override
  Future<void> hideInputMethod() async {
    await _hostApi?.hideInputMethod();
  }

  @override
  Future<void> setContextMenu(ContextMenu? contextMenu) async {
    await _hostApi?.setContextMenu(contextMenu?.toMap());
    _inAppBrowser?.setContextMenu(contextMenu);
  }

  @override
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() async {
    final result = await _hostApi?.requestFocusNodeHref();
    return result != null
        ? RequestFocusNodeHrefResult(
            url: result['url'] != null ? WebUri(result['url'] as String) : null,
            title: result['title'] as String?,
            src: result['src'] as String?,
          )
        : null;
  }

  @override
  Future<RequestImageRefResult?> requestImageRef() async {
    final result = await _hostApi?.requestImageRef();
    return result != null
        ? RequestImageRefResult(
            url: result['url'] != null ? WebUri(result['url'] as String) : null,
          )
        : null;
  }

  @override
  Future<List<MetaTag>> getMetaTags() async {
    List<MetaTag> metaTags = [];

    List<Map<dynamic, dynamic>>? metaTagList = (await evaluateJavascript(
      source: """
(function() {
  var metaTags = [];
  var metaTagNodes = document.head.getElementsByTagName('meta');
  for (var i = 0; i < metaTagNodes.length; i++) {
    var metaTagNode = metaTagNodes[i];
    
    var otherAttributes = metaTagNode.getAttributeNames();
    var nameIndex = otherAttributes.indexOf("name");
    if (nameIndex !== -1) otherAttributes.splice(nameIndex, 1);
    var contentIndex = otherAttributes.indexOf("content");
    if (contentIndex !== -1) otherAttributes.splice(contentIndex, 1);
    
    var attrs = [];
    for (var j = 0; j < otherAttributes.length; j++) {
      var otherAttribute = otherAttributes[j];
      attrs.push(
        {
          name: otherAttribute,
          value: metaTagNode.getAttribute(otherAttribute)
        }
      );
    }

    metaTags.push(
      {
        name: metaTagNode.name,
        content: metaTagNode.content,
        attrs: attrs
      }
    );
  }
  return metaTags;
})();
    """,
    ))?.cast<Map<dynamic, dynamic>>();

    if (metaTagList == null) {
      return metaTags;
    }

    for (var metaTag in metaTagList) {
      var attrs = <MetaTagAttribute>[];

      for (var metaTagAttr in metaTag["attrs"]) {
        attrs.add(
          MetaTagAttribute(
            name: metaTagAttr["name"],
            value: metaTagAttr["value"],
          ),
        );
      }

      metaTags.add(
        MetaTag(
          name: metaTag["name"],
          content: metaTag["content"],
          attrs: attrs,
        ),
      );
    }

    return metaTags;
  }

  @override
  Future<Color?> getMetaThemeColor() async {
    Color? themeColor;

    // Android WebView has no theme-color API, so the meta tag is read with JavaScript. The Kotlin
    // side never handled a `getMetaThemeColor` message: a request for it always failed, was
    // swallowed, and fell through to this same code.
    var metaTags = await getMetaTags();
    MetaTag? metaTagThemeColor;

    for (var metaTag in metaTags) {
      if (metaTag.name == "theme-color") {
        metaTagThemeColor = metaTag;
        break;
      }
    }

    if (metaTagThemeColor == null) {
      return null;
    }

    var colorValue = metaTagThemeColor.content;

    themeColor = colorValue != null
        ? UtilColor.fromStringRepresentation(colorValue)
        : null;

    return themeColor;
  }

  @override
  Future<int?> getScrollX() async {
    return await _hostApi?.getScrollX();
  }

  @override
  Future<int?> getScrollY() async {
    return await _hostApi?.getScrollY();
  }

  @override
  Future<SslCertificate?> getCertificate() async {
    final sslCertificateMap = (await _hostApi?.getCertificate())
        ?.cast<String, dynamic>();
    return SslCertificate.fromMap(sslCertificateMap);
  }

  @override
  Future<void> addUserScript({required UserScript userScript}) async {
    if (!(_userScripts[userScript.injectionTime]?.contains(userScript) ??
        false)) {
      _userScripts[userScript.injectionTime]?.add(userScript);
      await _hostApi?.addUserScript(userScript.toMap());
    }
  }

  @override
  Future<void> addUserScripts({required List<UserScript> userScripts}) async {
    for (var i = 0; i < userScripts.length; i++) {
      await addUserScript(userScript: userScripts[i]);
    }
  }

  @override
  Future<bool> removeUserScript({required UserScript userScript}) async {
    var index = _userScripts[userScript.injectionTime]?.indexOf(userScript);
    if (index == null || index == -1) {
      return false;
    }

    _userScripts[userScript.injectionTime]?.remove(userScript);
    await _hostApi?.removeUserScript(index, userScript.toMap());

    return true;
  }

  @override
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    final List<UserScript> userScriptsAtDocumentStart = List.from(
      _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START] ?? [],
    );
    for (final userScript in userScriptsAtDocumentStart) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    final List<UserScript> userScriptsAtDocumentEnd = List.from(
      _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END] ?? [],
    );
    for (final userScript in userScriptsAtDocumentEnd) {
      if (userScript.groupName == groupName) {
        _userScripts[userScript.injectionTime]?.remove(userScript);
      }
    }

    await _hostApi?.removeUserScriptsByGroupName(groupName);
  }

  @override
  Future<void> removeUserScripts({
    required List<UserScript> userScripts,
  }) async {
    for (final userScript in userScripts) {
      await removeUserScript(userScript: userScript);
    }
  }

  @override
  Future<void> removeAllUserScripts() async {
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_START]?.clear();
    _userScripts[UserScriptInjectionTime.AT_DOCUMENT_END]?.clear();

    await _hostApi?.removeAllUserScripts();
  }

  @override
  bool hasUserScript({required UserScript userScript}) {
    return _userScripts[userScript.injectionTime]?.contains(userScript) ??
        false;
  }

  @override
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const <String, dynamic>{},
    ContentWorld? contentWorld,
  }) async {
    final String? answer = await _hostApi?.callAsyncJavaScript(
      functionBody,
      arguments,
      contentWorld?.toMap(),
    );
    if (answer == null) {
      return null;
    }
    final data = json.decode(answer);
    return CallAsyncJavaScriptResult(
      value: data["value"],
      error: data["error"],
    );
  }

  @override
  Future<String?> saveWebArchive({
    required String filePath,
    bool autoname = false,
  }) async {
    if (!autoname) {
      assert(
        WebArchiveFormat.MHT.isSupported() &&
            filePath.endsWith(".${WebArchiveFormat.MHT.toNativeValue()!}"),
      );
    }

    return await _hostApi?.saveWebArchive(filePath, autoname);
  }

  @override
  Future<bool> isSecureContext() async {
    return await _hostApi?.isSecureContext() ?? false;
  }

  @override
  Future<AndroidWebMessageChannel?> createWebMessageChannel() async {
    final result = (await _hostApi?.createWebMessageChannel())
        ?.cast<String, dynamic>();
    final webMessageChannel = AndroidWebMessageChannel.static().fromMap(result);
    if (webMessageChannel != null) {
      _webMessageChannels.add(webMessageChannel);
    }
    return webMessageChannel;
  }

  @override
  Future<void> postWebMessage({
    required WebMessage message,
    WebUri? targetOrigin,
  }) async {
    targetOrigin ??= WebUri('');
    await _hostApi?.postWebMessage(message.toMap(), targetOrigin.toString());
  }

  @override
  Future<void> addWebMessageListener(
    PlatformWebMessageListener webMessageListener,
  ) async {
    assert(
      !_webMessageListeners.contains(webMessageListener),
      "$webMessageListener was already added.",
    );
    assert(
      !_webMessageListenerObjNames.contains(
        webMessageListener.params.jsObjectName,
      ),
      "jsObjectName ${webMessageListener.params.jsObjectName} was already added.",
    );
    _webMessageListeners.add(webMessageListener as AndroidWebMessageListener);
    _webMessageListenerObjNames.add(webMessageListener.params.jsObjectName);

    await _hostApi?.addWebMessageListener(webMessageListener.toMap());
  }

  @override
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) {
    return _webMessageListeners.contains(webMessageListener) ||
        _webMessageListenerObjNames.contains(
          webMessageListener.params.jsObjectName,
        );
  }

  @override
  Future<bool> canScrollVertically() async {
    return await _hostApi?.canScrollVertically() ?? false;
  }

  @override
  Future<bool> canScrollHorizontally() async {
    return await _hostApi?.canScrollHorizontally() ?? false;
  }

  @override
  Future<void> clearSslPreferences() async {
    await _hostApi?.clearSslPreferences();
  }

  @override
  Future<void> pause() async {
    await _hostApi?.pause();
  }

  @override
  Future<void> resume() async {
    await _hostApi?.resume();
  }

  @override
  Future<void> flingScroll({
    required int velocityX,
    required int velocityY,
  }) async {
    await _hostApi?.flingScroll(velocityX, velocityY);
  }

  @override
  Future<bool> documentHasImages() async {
    return await _hostApi?.documentHasImages() ?? false;
  }

  @override
  Future<void> postVisualStateCallback() async {
    // The native requestId is not exposed: this Future is the correlation, and the Kotlin side
    // supplies an id of its own purely so a logcat trace can tell requests apart.
    await _hostApi?.postVisualStateCallback();
  }

  @override
  Future<bool> pageDown({required bool bottom}) async {
    return await _hostApi?.pageDown(bottom) ?? false;
  }

  @override
  Future<bool> pageUp({required bool top}) async {
    return await _hostApi?.pageUp(top) ?? false;
  }

  @override
  Future<bool> zoomIn() async {
    return await _hostApi?.zoomIn() ?? false;
  }

  @override
  Future<bool> zoomOut() async {
    return await _hostApi?.zoomOut() ?? false;
  }

  @override
  Future<void> clearHistory() async {
    await _hostApi?.clearHistory();
  }

  @override
  Future<bool> isInFullscreen() async {
    return await _hostApi?.isInFullscreen() ?? false;
  }

  @override
  Future<void> clearFormData() async {
    await _hostApi?.clearFormData();
  }

  @override
  Future<Uint8List?> saveState({
    int? maxSize,
    bool? includeForwardState,
  }) async {
    // Sent as null when absent rather than defaulted here: the Kotlin side distinguishes
    // "no constraint asked for" (framework WebView.saveState, no feature needed) from
    // "constrained" (WebViewCompat.saveState, gated on SAVE_STATE), and only null can say the
    // former. A default of Int.MAX_VALUE / true would look identical to an explicit request.
    return await _hostApi?.saveState(maxSize, includeForwardState);
  }

  @override
  Future<bool> restoreState(Uint8List? state) async {
    return await _hostApi?.restoreState(state) ?? false;
  }

  // --- process-wide statics ---------------------------------------------------------------------
  //
  // Transport is Pigeon-generated (`InAppWebViewManagerHostApi`) since §188, not the hand-written
  // `inappwebview_manager` channel. Every `bool` a setter answers is discarded, as it always was.

  @override
  Future<String> getDefaultUserAgent() async {
    // `?? ''` kept: the platform answers null only when the plugin has gone away, and the public
    // return type is non-nullable.
    return await _managerHostApi.getDefaultUserAgent() ?? '';
  }

  @override
  Future<void> clearClientCertPreferences() async {
    await _managerHostApi.clearClientCertPreferences();
  }

  @override
  Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() async {
    final url = await _managerHostApi.getSafeBrowsingPrivacyPolicyUrl();
    return url != null ? WebUri(url) : null;
  }

  @override
  Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) {
    return _managerHostApi.setSafeBrowsingAllowlist(hosts);
  }

  @override
  Future<WebViewPackageInfo?> getCurrentWebViewPackage() async {
    final info = await _managerHostApi.getCurrentWebViewPackage();
    if (info == null) {
      return null;
    }
    return WebViewPackageInfo(
      versionName: info.versionName,
      packageName: info.packageName,
    );
  }

  @override
  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) async {
    await _managerHostApi.setWebContentsDebuggingEnabled(debuggingEnabled);
  }

  @override
  Future<String?> getVariationsHeader() {
    return _managerHostApi.getVariationsHeader();
  }

  @override
  Future<bool> isMultiProcessEnabled() {
    return _managerHostApi.isMultiProcessEnabled();
  }

  @override
  Future<bool> setDefaultTrafficStatsTag(int tag) {
    // The native side takes a 32-bit int. Both the signed range and the unsigned form the
    // androidx javadoc itself uses (0xFFFFFF00 …) are accepted — the Kotlin side keeps the low 32
    // bits — while anything wider would silently change tag, so it is rejected here.
    assert(
      tag >= -0x80000000 && tag <= 0xFFFFFFFF,
      'tag must fit in a 32-bit integer.',
    );
    return _managerHostApi.setDefaultTrafficStatsTag(tag);
  }

  @override
  Future<void> disableWebView() async {
    await _managerHostApi.disableWebView();
  }

  @override
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) async {
    await _managerHostApi.disposeKeepAlive(keepAlive.id);
    _keepAliveMap[keepAlive] = null;
  }

  @override
  Future<void> clearAllCache({bool includeDiskFiles = true}) async {
    await _managerHostApi.clearAllCache(includeDiskFiles);
  }

  @override
  Future<void> enableSlowWholeDocumentDraw() async {
    await _managerHostApi.enableSlowWholeDocumentDraw();
  }

  @override
  Future<void> setJavaScriptBridgeName(String bridgeName) async {
    assert(
      RegExp(r'^[a-zA-Z_]\w*$').hasMatch(bridgeName),
      'bridgeName must be a non-empty string with only alphanumeric and underscore characters. It can\'t start with a number.',
    );
    await _managerHostApi.setJavaScriptBridgeName(bridgeName);
  }

  @override
  Future<String> getJavaScriptBridgeName() {
    // No `?? ''` any more: the host method is typed non-null, and the Kotlin side always answers.
    return _managerHostApi.getJavaScriptBridgeName();
  }

  @override
  Future<String> get tRexRunnerHtml async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html',
  );

  @override
  Future<String> get tRexRunnerCss async => await rootBundle.loadString(
    'packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css',
  );

  @override
  dynamic getViewId() {
    return id;
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
    // The same rule as the MethodChannel handler above: a keep-alive WebView keeps its event
    // handler registered (its Kotlin side outlives this controller), and the next controller for
    // the same keep-alive id registers over it under the same suffix.
    if (!isKeepAlive) {
      InAppWebViewFlutterApi.setUp(null, messageChannelSuffix: _pigeonSuffix);
    }
    _hostApi = null;
    _inAppBrowser = null;
    webStorage.dispose();
    if (!isKeepAlive) {
      _controllerFromPlatform = null;
      _javaScriptHandlersMap.clear();
      _userScripts.clear();
      _webMessageListenerObjNames.clear();
      _injectedScriptsFromURL.clear();
      for (final webMessageChannel in _webMessageChannels) {
        webMessageChannel.dispose();
      }
      _webMessageChannels.clear();
      for (final webMessageListener in _webMessageListeners) {
        webMessageListener.dispose();
      }
      _webMessageListeners.clear();
    }
  }
}

extension InternalInAppWebViewController on AndroidInAppWebViewController {
  Future<dynamic> Function(MethodCall call) get handleMethod => _handleMethod;
}
