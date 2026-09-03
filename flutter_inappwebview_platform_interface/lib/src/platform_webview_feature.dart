import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'inappwebview_platform.dart';

part 'platform_webview_feature.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeatureCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebViewFeature].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeatureCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformWebViewFeatureCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebViewFeature].
  const PlatformWebViewFeatureCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeatureCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebViewFeatureCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature}
///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformWebViewFeature extends PlatformInterface {
  /// Creates a new [PlatformWebViewFeature]
  factory PlatformWebViewFeature(PlatformWebViewFeatureCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewFeature webViewFeature = InAppWebViewPlatform.instance!
        .createPlatformWebViewFeature(params);
    PlatformInterface.verify(webViewFeature, _token);
    return webViewFeature;
  }

  /// Creates a new empty [PlatformWebViewFeature] to access static methods.
  factory PlatformWebViewFeature.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewFeature webViewFeatureStatic = InAppWebViewPlatform
        .instance!
        .createPlatformWebViewFeatureStatic();
    PlatformInterface.verify(webViewFeatureStatic, _token);
    return webViewFeatureStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformWebViewFeature].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebViewFeature.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebViewFeature].
  final PlatformWebViewFeatureCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported}
  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Note**: This method is different from [isStartupFeatureSupported] and this
  ///method only accepts certain features.
  ///Please verify that the correct feature checking method is used for a particular feature.
  ///
  ///**Note**: If this method returns `false`, it is not safe to invoke the methods
  ///requiring the desired feature.
  ///Furthermore, if this method returns `false` for a particular feature, any callback guarded by that feature will not be invoked.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewFeature.isFeatureSupported',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)',
      ),
    ],
  )
  Future<bool> isFeatureSupported(WebViewFeature feature) {
    throw UnimplementedError(
      'isFeatureSupported is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported}
  ///Return whether a startup feature is supported at run-time.
  ///On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a startup feature is supported,
  ///depending on the combination of the desired feature,
  ///the Android version of device, and the WebView APK on the device.
  ///If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Note**: This method is different from [isFeatureSupported] and this method only accepts startup features.
  ///Please verify that the correct feature checking method is used for a particular feature.
  ///
  ///**Note**: If this method returns `false`, it is not safe to invoke the methods requiring the desired feature.
  ///Furthermore, if this method returns `false` for a particular feature,
  ///any callback guarded by that feature will not be invoked.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'WebViewFeature.isStartupFeatureSupported',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/WebViewFeature#isStartupFeatureSupported(android.content.Context,java.lang.String)',
      ),
    ],
  )
  Future<bool> isStartupFeatureSupported(WebViewFeature startupFeature) {
    throw UnimplementedError(
      'isStartupFeatureSupported is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeatureCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewFeature.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebViewFeatureMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebViewFeatureMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature}
@ExchangeableEnum()
class WebViewFeature_ {
  // ignore: unused_field
  final String _value;

  const WebViewFeature_._internal(this._value);

  @ExchangeableObjectMethod(ignore: true)
  String toNativeValue() => _value;

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.createWebMessageChannel].
  static const CREATE_WEB_MESSAGE_CHANNEL = WebViewFeature_._internal(
    "CREATE_WEB_MESSAGE_CHANNEL",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.disabledActionModeMenuItems].
  static const DISABLED_ACTION_MODE_MENU_ITEMS = WebViewFeature_._internal(
    "DISABLED_ACTION_MODE_MENU_ITEMS",
  );

  ///
  static const GET_WEB_CHROME_CLIENT = WebViewFeature_._internal(
    "GET_WEB_CHROME_CLIENT",
  );

  ///
  static const GET_WEB_VIEW_CLIENT = WebViewFeature_._internal(
    "GET_WEB_VIEW_CLIENT",
  );

  ///
  static const GET_WEB_VIEW_RENDERER = WebViewFeature_._internal(
    "GET_WEB_VIEW_RENDERER",
  );

  ///
  static const MULTI_PROCESS = WebViewFeature_._internal("MULTI_PROCESS");

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.offscreenPreRaster].
  static const OFF_SCREEN_PRERASTER = WebViewFeature_._internal(
    "OFF_SCREEN_PRERASTER",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.postWebMessage].
  static const POST_WEB_MESSAGE = WebViewFeature_._internal("POST_WEB_MESSAGE");

  ///Feature for [isFeatureSupported]. This feature covers [ProxyController.setProxyOverride] and [ProxyController.clearProxyOverride].
  static const PROXY_OVERRIDE = WebViewFeature_._internal("PROXY_OVERRIDE");

  ///Feature for [isFeatureSupported]. This feature covers [ProxySettings.reverseBypassEnabled].
  static const PROXY_OVERRIDE_REVERSE_BYPASS = WebViewFeature_._internal(
    "PROXY_OVERRIDE_REVERSE_BYPASS",
  );

  ///
  static const RECEIVE_HTTP_ERROR = WebViewFeature_._internal(
    "RECEIVE_HTTP_ERROR",
  );

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR = WebViewFeature_._internal(
    "RECEIVE_WEB_RESOURCE_ERROR",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.setSafeBrowsingAllowlist].
  static const SAFE_BROWSING_ALLOWLIST = WebViewFeature_._internal(
    "SAFE_BROWSING_ALLOWLIST",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.safeBrowsingEnabled].
  static const SAFE_BROWSING_ENABLE = WebViewFeature_._internal(
    "SAFE_BROWSING_ENABLE",
  );

  ///
  static const SAFE_BROWSING_HIT = WebViewFeature_._internal(
    "SAFE_BROWSING_HIT",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  static const SAFE_BROWSING_PRIVACY_POLICY_URL = WebViewFeature_._internal(
    "SAFE_BROWSING_PRIVACY_POLICY_URL",
  );

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      WebViewFeature_._internal("SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY");

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED = WebViewFeature_._internal(
    "SAFE_BROWSING_RESPONSE_PROCEED",
  );

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      WebViewFeature_._internal("SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL");

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController].
  static const SERVICE_WORKER_BASIC_USAGE = WebViewFeature_._internal(
    "SERVICE_WORKER_BASIC_USAGE",
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setBlockNetworkLoads] and [ServiceWorkerController.getBlockNetworkLoads].
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS = WebViewFeature_._internal(
    "SERVICE_WORKER_BLOCK_NETWORK_LOADS",
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setCacheMode] and [ServiceWorkerController.getCacheMode].
  static const SERVICE_WORKER_CACHE_MODE = WebViewFeature_._internal(
    "SERVICE_WORKER_CACHE_MODE",
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowContentAccess] and [ServiceWorkerController.getAllowContentAccess].
  static const SERVICE_WORKER_CONTENT_ACCESS = WebViewFeature_._internal(
    "SERVICE_WORKER_CONTENT_ACCESS",
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowFileAccess] and [ServiceWorkerController.getAllowFileAccess].
  static const SERVICE_WORKER_FILE_ACCESS = WebViewFeature_._internal(
    "SERVICE_WORKER_FILE_ACCESS",
  );

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerClient.shouldInterceptRequest].
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      WebViewFeature_._internal("SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST");

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS = WebViewFeature_._internal(
    "SHOULD_OVERRIDE_WITH_REDIRECTS",
  );

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE = WebViewFeature_._internal(
    "TRACING_CONTROLLER_BASIC_USAGE",
  );

  ///
  static const VISUAL_STATE_CALLBACK = WebViewFeature_._internal(
    "VISUAL_STATE_CALLBACK",
  );

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE = WebViewFeature_._internal(
    "WEB_MESSAGE_CALLBACK_ON_MESSAGE",
  );

  ///Feature for [isFeatureSupported]. This feature covers [WebMessageListener].
  static const WEB_MESSAGE_LISTENER = WebViewFeature_._internal(
    "WEB_MESSAGE_LISTENER",
  );

  ///
  static const WEB_MESSAGE_PORT_CLOSE = WebViewFeature_._internal(
    "WEB_MESSAGE_PORT_CLOSE",
  );

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE = WebViewFeature_._internal(
    "WEB_MESSAGE_PORT_POST_MESSAGE",
  );

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      WebViewFeature_._internal("WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK");

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE = WebViewFeature_._internal(
    "WEB_RESOURCE_ERROR_GET_CODE",
  );

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION = WebViewFeature_._internal(
    "WEB_RESOURCE_ERROR_GET_DESCRIPTION",
  );

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT = WebViewFeature_._internal(
    "WEB_RESOURCE_REQUEST_IS_REDIRECT",
  );

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE = WebViewFeature_._internal(
    "WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE",
  );

  ///
  static const WEB_VIEW_RENDERER_TERMINATE = WebViewFeature_._internal(
    "WEB_VIEW_RENDERER_TERMINATE",
  );

  ///Feature for [isFeatureSupported]. This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT = WebViewFeature_._internal(
    "DOCUMENT_START_SCRIPT",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING = WebViewFeature_._internal(
    "ALGORITHMIC_DARKENING",
  );

  ///Feature for [isFeatureSupported]. This feature covers
  ///[PlatformInAppWebViewController.setAudioMuted] and
  ///[PlatformInAppWebViewController.isAudioMuted].
  static const MUTE_AUDIO = WebViewFeature_._internal("MUTE_AUDIO");

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.paymentRequestEnabled].
  static const PAYMENT_REQUEST = WebViewFeature_._internal("PAYMENT_REQUEST");

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.webAuthenticationSupport].
  static const WEB_AUTHENTICATION = WebViewFeature_._internal(
    "WEB_AUTHENTICATION",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.downloadFaviconsEnabled].
  static const DOWNLOAD_FAVICONS_ENABLED = WebViewFeature_._internal(
    "DOWNLOAD_FAVICONS_ENABLED",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.backForwardCacheEnabled].
  static const BACK_FORWARD_CACHE = WebViewFeature_._internal(
    "BACK_FORWARD_CACHE",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.attributionRegistrationBehavior].
  static const ATTRIBUTION_REGISTRATION_BEHAVIOR = WebViewFeature_._internal(
    "ATTRIBUTION_REGISTRATION_BEHAVIOR",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.webViewMediaIntegrityApiStatus].
  static const WEBVIEW_MEDIA_INTEGRITY_API_STATUS = WebViewFeature_._internal(
    "WEBVIEW_MEDIA_INTEGRITY_API_STATUS",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.userAgentMetadata].
  static const USER_AGENT_METADATA = WebViewFeature_._internal(
    "USER_AGENT_METADATA",
  );

  ///Feature for [isFeatureSupported]. This feature covers [UserAgentMetadata.formFactors],
  ///and is separate from [WebViewFeature.USER_AGENT_METADATA].
  static const USER_AGENT_METADATA_FORM_FACTORS = WebViewFeature_._internal(
    "USER_AGENT_METADATA_FORM_FACTORS",
  );

  ///Feature for [isFeatureSupported]. This feature covers
  ///[PlatformInAppWebViewController.prerenderUrl].
  ///
  ///Note the native value is `PRERENDER_URL_V2`, not the name of this constant.
  static const PRERENDER_WITH_URL = WebViewFeature_._internal(
    "PRERENDER_URL_V2",
  );

  ///Feature for [isFeatureSupported]. This feature covers
  ///[PlatformWebViewCreationParams.onNavigationStarted],
  ///[PlatformWebViewCreationParams.onNavigationRedirected] and
  ///[PlatformWebViewCreationParams.onNavigationCompleted], and is what
  ///[InAppWebViewSettings.useNavigationListener] needs in order to have any effect.
  ///
  ///Note that six neighbouring `NAVIGATION_*` constants in `androidx.webkit` are **tombstones** —
  ///still declared for source compatibility, but `@Deprecated` and no longer registered, so passing
  ///one to `isFeatureSupported` throws rather than returning `false`. This constant and
  ///[NAVIGATION_GET_WEB_RESOURCE_ERROR] are the only two of the family that are real.
  static const NAVIGATION_LISTENER = WebViewFeature_._internal(
    "NAVIGATION_LISTENER",
  );

  ///Feature for [isFeatureSupported]. This feature covers
  ///[WebViewNavigation.webResourceError] alone.
  ///
  ///This is a second, finer gate **inside** [NAVIGATION_LISTENER]: where it is unsupported the
  ///navigation events still fire and every other field of [WebViewNavigation] is still reported,
  ///but [WebViewNavigation.webResourceError] is always `null`.
  static const NAVIGATION_GET_WEB_RESOURCE_ERROR = WebViewFeature_._internal(
    "NAVIGATION_GET_WEB_RESOURCE_ERROR",
  );

  ///Feature for [isFeatureSupported]. This feature covers [PlatformProfileStore] and
  ///[InAppWebViewSettings.profileName].
  static const MULTI_PROFILE = WebViewFeature_._internal("MULTI_PROFILE");

  ///Feature for [isFeatureSupported]. This feature covers
  ///[PlatformWebStorageManager.deleteBrowsingData] and
  ///[PlatformWebStorageManager.deleteBrowsingDataForSite].
  static const DELETE_BROWSING_DATA = WebViewFeature_._internal(
    "DELETE_BROWSING_DATA",
  );

  ///Feature for [isFeatureSupported]. This feature covers
  ///[PlatformInAppWebViewController.setDefaultTrafficStatsTag].
  static const DEFAULT_TRAFFICSTATS_TAGGING = WebViewFeature_._internal(
    "DEFAULT_TRAFFICSTATS_TAGGING",
  );

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY =
      WebViewFeature_._internal("ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY");

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getVariationsHeader].
  static const GET_VARIATIONS_HEADER = WebViewFeature_._internal(
    "GET_VARIATIONS_HEADER",
  );

  ///Feature for [isFeatureSupported]. This feature covers cookie attributes of [CookieManager.getCookie] and [CookieManager.getCookies] methods.
  static const GET_COOKIE_INFO = WebViewFeature_._internal("GET_COOKIE_INFO");

  ///Feature for [isFeatureSupported]. This feature covers [WebMessagePort.postMessage] with `ArrayBuffer` type,
  ///[InAppWebViewController.postWebMessage] with `ArrayBuffer` type, and [JavaScriptReplyProxy.postMessage] with `ArrayBuffer` type.
  static const WEB_MESSAGE_ARRAY_BUFFER = WebViewFeature_._internal(
    "WEB_MESSAGE_ARRAY_BUFFER",
  );

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.dataDirectorySuffix].
  static const STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX =
      WebViewFeature_._internal("STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX");

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.directoryBasePaths].
  static const STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS =
      WebViewFeature_._internal("STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS");

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported}
  static Future<bool> isFeatureSupported(WebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(feature);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported}
  static Future<bool> isStartupFeatureSupported(
    WebViewFeature startupFeature,
  ) =>
      PlatformWebViewFeature.static().isStartupFeatureSupported(startupFeature);
}
