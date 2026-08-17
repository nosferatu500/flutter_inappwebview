// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_webview_feature.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature}
class WebViewFeature {
  final String _value;
  final String? _nativeValue;
  const WebViewFeature._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebViewFeature._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => WebViewFeature._internal(value, nativeValue());

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING = WebViewFeature._internal(
    'ALGORITHMIC_DARKENING',
    'ALGORITHMIC_DARKENING',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.createWebMessageChannel].
  static const CREATE_WEB_MESSAGE_CHANNEL = WebViewFeature._internal(
    'CREATE_WEB_MESSAGE_CHANNEL',
    'CREATE_WEB_MESSAGE_CHANNEL',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.disabledActionModeMenuItems].
  static const DISABLED_ACTION_MODE_MENU_ITEMS = WebViewFeature._internal(
    'DISABLED_ACTION_MODE_MENU_ITEMS',
    'DISABLED_ACTION_MODE_MENU_ITEMS',
  );

  ///Feature for [isFeatureSupported]. This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT = WebViewFeature._internal(
    'DOCUMENT_START_SCRIPT',
    'DOCUMENT_START_SCRIPT',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY =
      WebViewFeature._internal(
        'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY',
        'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY',
      );

  ///Feature for [isFeatureSupported]. This feature covers cookie attributes of [CookieManager.getCookie] and [CookieManager.getCookies] methods.
  static const GET_COOKIE_INFO = WebViewFeature._internal(
    'GET_COOKIE_INFO',
    'GET_COOKIE_INFO',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getVariationsHeader].
  static const GET_VARIATIONS_HEADER = WebViewFeature._internal(
    'GET_VARIATIONS_HEADER',
    'GET_VARIATIONS_HEADER',
  );

  ///
  static const GET_WEB_CHROME_CLIENT = WebViewFeature._internal(
    'GET_WEB_CHROME_CLIENT',
    'GET_WEB_CHROME_CLIENT',
  );

  ///
  static const GET_WEB_VIEW_CLIENT = WebViewFeature._internal(
    'GET_WEB_VIEW_CLIENT',
    'GET_WEB_VIEW_CLIENT',
  );

  ///
  static const GET_WEB_VIEW_RENDERER = WebViewFeature._internal(
    'GET_WEB_VIEW_RENDERER',
    'GET_WEB_VIEW_RENDERER',
  );

  ///
  static const MULTI_PROCESS = WebViewFeature._internal(
    'MULTI_PROCESS',
    'MULTI_PROCESS',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.offscreenPreRaster].
  static const OFF_SCREEN_PRERASTER = WebViewFeature._internal(
    'OFF_SCREEN_PRERASTER',
    'OFF_SCREEN_PRERASTER',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.postWebMessage].
  static const POST_WEB_MESSAGE = WebViewFeature._internal(
    'POST_WEB_MESSAGE',
    'POST_WEB_MESSAGE',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ProxyController.setProxyOverride] and [ProxyController.clearProxyOverride].
  static const PROXY_OVERRIDE = WebViewFeature._internal(
    'PROXY_OVERRIDE',
    'PROXY_OVERRIDE',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ProxySettings.reverseBypassEnabled].
  static const PROXY_OVERRIDE_REVERSE_BYPASS = WebViewFeature._internal(
    'PROXY_OVERRIDE_REVERSE_BYPASS',
    'PROXY_OVERRIDE_REVERSE_BYPASS',
  );

  ///
  static const RECEIVE_HTTP_ERROR = WebViewFeature._internal(
    'RECEIVE_HTTP_ERROR',
    'RECEIVE_HTTP_ERROR',
  );

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR = WebViewFeature._internal(
    'RECEIVE_WEB_RESOURCE_ERROR',
    'RECEIVE_WEB_RESOURCE_ERROR',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.setSafeBrowsingAllowlist].
  static const SAFE_BROWSING_ALLOWLIST = WebViewFeature._internal(
    'SAFE_BROWSING_ALLOWLIST',
    'SAFE_BROWSING_ALLOWLIST',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.safeBrowsingEnabled].
  static const SAFE_BROWSING_ENABLE = WebViewFeature._internal(
    'SAFE_BROWSING_ENABLE',
    'SAFE_BROWSING_ENABLE',
  );

  ///
  static const SAFE_BROWSING_HIT = WebViewFeature._internal(
    'SAFE_BROWSING_HIT',
    'SAFE_BROWSING_HIT',
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  static const SAFE_BROWSING_PRIVACY_POLICY_URL = WebViewFeature._internal(
    'SAFE_BROWSING_PRIVACY_POLICY_URL',
    'SAFE_BROWSING_PRIVACY_POLICY_URL',
  );

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY = WebViewFeature._internal(
    'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY',
    'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY',
  );

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED = WebViewFeature._internal(
    'SAFE_BROWSING_RESPONSE_PROCEED',
    'SAFE_BROWSING_RESPONSE_PROCEED',
  );

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      WebViewFeature._internal(
        'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL',
        'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL',
      );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController].
  static const SERVICE_WORKER_BASIC_USAGE = WebViewFeature._internal(
    'SERVICE_WORKER_BASIC_USAGE',
    'SERVICE_WORKER_BASIC_USAGE',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setBlockNetworkLoads] and [ServiceWorkerController.getBlockNetworkLoads].
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS = WebViewFeature._internal(
    'SERVICE_WORKER_BLOCK_NETWORK_LOADS',
    'SERVICE_WORKER_BLOCK_NETWORK_LOADS',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setCacheMode] and [ServiceWorkerController.getCacheMode].
  static const SERVICE_WORKER_CACHE_MODE = WebViewFeature._internal(
    'SERVICE_WORKER_CACHE_MODE',
    'SERVICE_WORKER_CACHE_MODE',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowContentAccess] and [ServiceWorkerController.getAllowContentAccess].
  static const SERVICE_WORKER_CONTENT_ACCESS = WebViewFeature._internal(
    'SERVICE_WORKER_CONTENT_ACCESS',
    'SERVICE_WORKER_CONTENT_ACCESS',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowFileAccess] and [ServiceWorkerController.getAllowFileAccess].
  static const SERVICE_WORKER_FILE_ACCESS = WebViewFeature._internal(
    'SERVICE_WORKER_FILE_ACCESS',
    'SERVICE_WORKER_FILE_ACCESS',
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerClient.shouldInterceptRequest].
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      WebViewFeature._internal(
        'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST',
        'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST',
      );

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS = WebViewFeature._internal(
    'SHOULD_OVERRIDE_WITH_REDIRECTS',
    'SHOULD_OVERRIDE_WITH_REDIRECTS',
  );

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.dataDirectorySuffix].
  static const STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX =
      WebViewFeature._internal(
        'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX',
        'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX',
      );

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.directoryBasePaths].
  static const STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS =
      WebViewFeature._internal(
        'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS',
        'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS',
      );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.startSafeBrowsing].
  static const START_SAFE_BROWSING = WebViewFeature._internal(
    'START_SAFE_BROWSING',
    'START_SAFE_BROWSING',
  );

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE = WebViewFeature._internal(
    'TRACING_CONTROLLER_BASIC_USAGE',
    'TRACING_CONTROLLER_BASIC_USAGE',
  );

  ///
  static const VISUAL_STATE_CALLBACK = WebViewFeature._internal(
    'VISUAL_STATE_CALLBACK',
    'VISUAL_STATE_CALLBACK',
  );

  ///Feature for [isFeatureSupported]. This feature covers [WebMessagePort.postMessage] with `ArrayBuffer` type,
  ///[InAppWebViewController.postWebMessage] with `ArrayBuffer` type, and [JavaScriptReplyProxy.postMessage] with `ArrayBuffer` type.
  static const WEB_MESSAGE_ARRAY_BUFFER = WebViewFeature._internal(
    'WEB_MESSAGE_ARRAY_BUFFER',
    'WEB_MESSAGE_ARRAY_BUFFER',
  );

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE = WebViewFeature._internal(
    'WEB_MESSAGE_CALLBACK_ON_MESSAGE',
    'WEB_MESSAGE_CALLBACK_ON_MESSAGE',
  );

  ///Feature for [isFeatureSupported]. This feature covers [WebMessageListener].
  static const WEB_MESSAGE_LISTENER = WebViewFeature._internal(
    'WEB_MESSAGE_LISTENER',
    'WEB_MESSAGE_LISTENER',
  );

  ///
  static const WEB_MESSAGE_PORT_CLOSE = WebViewFeature._internal(
    'WEB_MESSAGE_PORT_CLOSE',
    'WEB_MESSAGE_PORT_CLOSE',
  );

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE = WebViewFeature._internal(
    'WEB_MESSAGE_PORT_POST_MESSAGE',
    'WEB_MESSAGE_PORT_POST_MESSAGE',
  );

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK = WebViewFeature._internal(
    'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK',
    'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK',
  );

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE = WebViewFeature._internal(
    'WEB_RESOURCE_ERROR_GET_CODE',
    'WEB_RESOURCE_ERROR_GET_CODE',
  );

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION = WebViewFeature._internal(
    'WEB_RESOURCE_ERROR_GET_DESCRIPTION',
    'WEB_RESOURCE_ERROR_GET_DESCRIPTION',
  );

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT = WebViewFeature._internal(
    'WEB_RESOURCE_REQUEST_IS_REDIRECT',
    'WEB_RESOURCE_REQUEST_IS_REDIRECT',
  );

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE = WebViewFeature._internal(
    'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE',
    'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE',
  );

  ///
  static const WEB_VIEW_RENDERER_TERMINATE = WebViewFeature._internal(
    'WEB_VIEW_RENDERER_TERMINATE',
    'WEB_VIEW_RENDERER_TERMINATE',
  );

  ///Set of all values of [WebViewFeature].
  static final Set<WebViewFeature> values = [
    WebViewFeature.ALGORITHMIC_DARKENING,
    WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL,
    WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS,
    WebViewFeature.DOCUMENT_START_SCRIPT,
    WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY,
    WebViewFeature.GET_COOKIE_INFO,
    WebViewFeature.GET_VARIATIONS_HEADER,
    WebViewFeature.GET_WEB_CHROME_CLIENT,
    WebViewFeature.GET_WEB_VIEW_CLIENT,
    WebViewFeature.GET_WEB_VIEW_RENDERER,
    WebViewFeature.MULTI_PROCESS,
    WebViewFeature.OFF_SCREEN_PRERASTER,
    WebViewFeature.POST_WEB_MESSAGE,
    WebViewFeature.PROXY_OVERRIDE,
    WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS,
    WebViewFeature.RECEIVE_HTTP_ERROR,
    WebViewFeature.RECEIVE_WEB_RESOURCE_ERROR,
    WebViewFeature.SAFE_BROWSING_ALLOWLIST,
    WebViewFeature.SAFE_BROWSING_ENABLE,
    WebViewFeature.SAFE_BROWSING_HIT,
    WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL,
    WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY,
    WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED,
    WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL,
    WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
    WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS,
    WebViewFeature.SERVICE_WORKER_CACHE_MODE,
    WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS,
    WebViewFeature.SERVICE_WORKER_FILE_ACCESS,
    WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
    WebViewFeature.SHOULD_OVERRIDE_WITH_REDIRECTS,
    WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
    WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS,
    WebViewFeature.START_SAFE_BROWSING,
    WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE,
    WebViewFeature.VISUAL_STATE_CALLBACK,
    WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER,
    WebViewFeature.WEB_MESSAGE_CALLBACK_ON_MESSAGE,
    WebViewFeature.WEB_MESSAGE_LISTENER,
    WebViewFeature.WEB_MESSAGE_PORT_CLOSE,
    WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE,
    WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK,
    WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE,
    WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION,
    WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT,
    WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE,
    WebViewFeature.WEB_VIEW_RENDERER_TERMINATE,
  ].toSet();

  ///Gets a possible [WebViewFeature] instance from [String] value.
  static WebViewFeature? fromValue(String? value) {
    if (value != null) {
      try {
        return WebViewFeature.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebViewFeature] instance from a native value.
  static WebViewFeature? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebViewFeature.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebViewFeature] instance value with name [name].
  ///
  /// Goes through [WebViewFeature.values] looking for a value with
  /// name [name], as reported by [WebViewFeature.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebViewFeature? byName(String? name) {
    if (name != null) {
      try {
        return WebViewFeature.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebViewFeature] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebViewFeature> asNameMap() => <String, WebViewFeature>{
    for (final value in WebViewFeature.values) value.name(): value,
  };

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported}
  static Future<bool> isFeatureSupported(WebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(feature);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported}
  static Future<bool> isStartupFeatureSupported(
    WebViewFeature startupFeature,
  ) =>
      PlatformWebViewFeature.static().isStartupFeatureSupported(startupFeature);

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'ALGORITHMIC_DARKENING':
        return 'ALGORITHMIC_DARKENING';
      case 'CREATE_WEB_MESSAGE_CHANNEL':
        return 'CREATE_WEB_MESSAGE_CHANNEL';
      case 'DISABLED_ACTION_MODE_MENU_ITEMS':
        return 'DISABLED_ACTION_MODE_MENU_ITEMS';
      case 'DOCUMENT_START_SCRIPT':
        return 'DOCUMENT_START_SCRIPT';
      case 'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY':
        return 'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY';
      case 'GET_COOKIE_INFO':
        return 'GET_COOKIE_INFO';
      case 'GET_VARIATIONS_HEADER':
        return 'GET_VARIATIONS_HEADER';
      case 'GET_WEB_CHROME_CLIENT':
        return 'GET_WEB_CHROME_CLIENT';
      case 'GET_WEB_VIEW_CLIENT':
        return 'GET_WEB_VIEW_CLIENT';
      case 'GET_WEB_VIEW_RENDERER':
        return 'GET_WEB_VIEW_RENDERER';
      case 'MULTI_PROCESS':
        return 'MULTI_PROCESS';
      case 'OFF_SCREEN_PRERASTER':
        return 'OFF_SCREEN_PRERASTER';
      case 'POST_WEB_MESSAGE':
        return 'POST_WEB_MESSAGE';
      case 'PROXY_OVERRIDE':
        return 'PROXY_OVERRIDE';
      case 'PROXY_OVERRIDE_REVERSE_BYPASS':
        return 'PROXY_OVERRIDE_REVERSE_BYPASS';
      case 'RECEIVE_HTTP_ERROR':
        return 'RECEIVE_HTTP_ERROR';
      case 'RECEIVE_WEB_RESOURCE_ERROR':
        return 'RECEIVE_WEB_RESOURCE_ERROR';
      case 'SAFE_BROWSING_ALLOWLIST':
        return 'SAFE_BROWSING_ALLOWLIST';
      case 'SAFE_BROWSING_ENABLE':
        return 'SAFE_BROWSING_ENABLE';
      case 'SAFE_BROWSING_HIT':
        return 'SAFE_BROWSING_HIT';
      case 'SAFE_BROWSING_PRIVACY_POLICY_URL':
        return 'SAFE_BROWSING_PRIVACY_POLICY_URL';
      case 'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY':
        return 'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY';
      case 'SAFE_BROWSING_RESPONSE_PROCEED':
        return 'SAFE_BROWSING_RESPONSE_PROCEED';
      case 'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL':
        return 'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL';
      case 'SERVICE_WORKER_BASIC_USAGE':
        return 'SERVICE_WORKER_BASIC_USAGE';
      case 'SERVICE_WORKER_BLOCK_NETWORK_LOADS':
        return 'SERVICE_WORKER_BLOCK_NETWORK_LOADS';
      case 'SERVICE_WORKER_CACHE_MODE':
        return 'SERVICE_WORKER_CACHE_MODE';
      case 'SERVICE_WORKER_CONTENT_ACCESS':
        return 'SERVICE_WORKER_CONTENT_ACCESS';
      case 'SERVICE_WORKER_FILE_ACCESS':
        return 'SERVICE_WORKER_FILE_ACCESS';
      case 'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST':
        return 'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST';
      case 'SHOULD_OVERRIDE_WITH_REDIRECTS':
        return 'SHOULD_OVERRIDE_WITH_REDIRECTS';
      case 'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX':
        return 'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX';
      case 'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS':
        return 'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS';
      case 'START_SAFE_BROWSING':
        return 'START_SAFE_BROWSING';
      case 'TRACING_CONTROLLER_BASIC_USAGE':
        return 'TRACING_CONTROLLER_BASIC_USAGE';
      case 'VISUAL_STATE_CALLBACK':
        return 'VISUAL_STATE_CALLBACK';
      case 'WEB_MESSAGE_ARRAY_BUFFER':
        return 'WEB_MESSAGE_ARRAY_BUFFER';
      case 'WEB_MESSAGE_CALLBACK_ON_MESSAGE':
        return 'WEB_MESSAGE_CALLBACK_ON_MESSAGE';
      case 'WEB_MESSAGE_LISTENER':
        return 'WEB_MESSAGE_LISTENER';
      case 'WEB_MESSAGE_PORT_CLOSE':
        return 'WEB_MESSAGE_PORT_CLOSE';
      case 'WEB_MESSAGE_PORT_POST_MESSAGE':
        return 'WEB_MESSAGE_PORT_POST_MESSAGE';
      case 'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK':
        return 'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK';
      case 'WEB_RESOURCE_ERROR_GET_CODE':
        return 'WEB_RESOURCE_ERROR_GET_CODE';
      case 'WEB_RESOURCE_ERROR_GET_DESCRIPTION':
        return 'WEB_RESOURCE_ERROR_GET_DESCRIPTION';
      case 'WEB_RESOURCE_REQUEST_IS_REDIRECT':
        return 'WEB_RESOURCE_REQUEST_IS_REDIRECT';
      case 'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE':
        return 'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE';
      case 'WEB_VIEW_RENDERER_TERMINATE':
        return 'WEB_VIEW_RENDERER_TERMINATE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebViewFeatureCreationParamsClassSupported
    on PlatformWebViewFeatureCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeatureCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformWebViewFeatureCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformWebViewFeatureClassSupported on PlatformWebViewFeature {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformWebViewFeature.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebViewFeature]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebViewFeatureMethod {
  ///Can be used to check if the [PlatformWebViewFeature.isFeatureSupported] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewFeature.isFeatureSupported](https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [feature]: all platforms
  ///
  ///Use the [PlatformWebViewFeature.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isFeatureSupported,

  ///Can be used to check if the [PlatformWebViewFeature.isStartupFeatureSupported] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewFeature.isStartupFeatureSupported](https://developer.android.com/reference/androidx/webkit/WebViewFeature#isStartupFeatureSupported(android.content.Context,java.lang.String)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [startupFeature]: all platforms
  ///
  ///Use the [PlatformWebViewFeature.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isStartupFeatureSupported,
}

extension _PlatformWebViewFeatureMethodSupported on PlatformWebViewFeature {
  static bool isMethodSupported(
    PlatformWebViewFeatureMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformWebViewFeatureMethod.isFeatureSupported:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewFeatureMethod.isStartupFeatureSupported:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
