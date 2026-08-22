import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';

part 'platform_geolocation_permissions.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams}
/// Object specifying creation parameters for creating a [PlatformGeolocationPermissions].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformGeolocationPermissionsCreationParams {
  /// Used by the platform implementation to create a new [PlatformGeolocationPermissions].
  const PlatformGeolocationPermissionsCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformGeolocationPermissionsCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions}
///Manages which origins are allowed to use the Geolocation API.
///
///These are the *stored* decisions, and they are what a WebView consults before it asks again. They
///are separate from [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt], which fires
///when a page requests location and no decision has been stored yet: answering that prompt is a
///one-off, while [allow] and [clear] are the persistent record.
///
///Storage is per profile. Every method operates on the default profile unless a `profileName` is
///given — the same profile a WebView is put on with [InAppWebViewSettings.profileName]. Scoping is
///per call rather than per instance, matching [PlatformCookieManager] and
///[PlatformWebStorageManager], and omitting it acts on the default profile rather than failing.
///
///`profileName` requires [WebViewFeature.MULTI_PROFILE]. Without that feature, or when no profile
///of that name exists, nothing is read or changed and the call reports failure — it never falls back
///to the default profile. Use [PlatformProfileStore] to create profiles.
///
///Note that none of this has any effect while
///[InAppWebViewSettings.geolocationEnabled] is `false`, which switches the Geolocation API off for
///the WebView regardless of what is stored here.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'GeolocationPermissions',
      apiUrl:
          'https://developer.android.com/reference/android/webkit/GeolocationPermissions',
    ),
  ],
)
abstract class PlatformGeolocationPermissions extends PlatformInterface {
  /// Creates a new [PlatformGeolocationPermissions]
  factory PlatformGeolocationPermissions(
    PlatformGeolocationPermissionsCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformGeolocationPermissions geolocationPermissions =
        InAppWebViewPlatform.instance!.createPlatformGeolocationPermissions(
          params,
        );
    PlatformInterface.verify(geolocationPermissions, _token);
    return geolocationPermissions;
  }

  /// Creates a new [PlatformGeolocationPermissions] to access static methods.
  factory PlatformGeolocationPermissions.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformGeolocationPermissions geolocationPermissionsStatic =
        InAppWebViewPlatform.instance!
            .createPlatformGeolocationPermissionsStatic();
    PlatformInterface.verify(geolocationPermissionsStatic, _token);
    return geolocationPermissionsStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformGeolocationPermissions].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformGeolocationPermissions.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformGeolocationPermissions].
  final PlatformGeolocationPermissionsCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.allow}
  ///Stores a decision allowing [origin] to use the Geolocation API.
  ///
  ///[origin] must be a web origin — scheme, host and, when it is not the default for the scheme,
  ///port, as in `https://example.com` or `https://example.com:8443`. It is not a URL: a path is not
  ///part of the identity a decision is stored against.
  ///
  ///Returns `true` once the decision is stored, or `false` when
  ///[WebViewFeature.MULTI_PROFILE] is not supported or the named profile does not exist, in which
  ///case nothing was stored.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.allow.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'GeolocationPermissions.allow',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/GeolocationPermissions#allow(java.lang.String)',
      ),
    ],
  )
  Future<bool> allow({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'allow is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clear}
  ///Removes any stored decision for [origin], so the next request from it prompts again.
  ///
  ///Clearing is not the same as denying: there is no stored "deny". An origin with no decision is
  ///one the WebView will ask about.
  ///
  ///Returns `true` once the decision is cleared, or `false` when
  ///[WebViewFeature.MULTI_PROFILE] is not supported or the named profile does not exist, in which
  ///case nothing was cleared.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clear.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'GeolocationPermissions.clear',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/GeolocationPermissions#clear(java.lang.String)',
      ),
    ],
  )
  Future<bool> clear({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'clear is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clearAll}
  ///Removes every stored decision, so all origins prompt again.
  ///
  ///Returns `true` once the decisions are cleared, or `false` when
  ///[WebViewFeature.MULTI_PROFILE] is not supported or the named profile does not exist, in which
  ///case nothing was cleared.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.clearAll.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'GeolocationPermissions.clearAll',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/GeolocationPermissions#clearAll()',
      ),
    ],
  )
  Future<bool> clearAll({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'clearAll is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getAllowed}
  ///Returns whether [origin] has a stored decision allowing the Geolocation API.
  ///
  ///`false` means no decision is stored, which is also the state after [clear] — there is no stored
  ///"deny" to distinguish it from.
  ///
  ///Returns `null` when the question could not be asked at all: [WebViewFeature.MULTI_PROFILE] is
  ///not supported, or the named profile does not exist. That is deliberately distinct from `false`,
  ///which is an answer.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getAllowed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'GeolocationPermissions.getAllowed',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/GeolocationPermissions#getAllowed(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)',
      ),
    ],
  )
  Future<bool?> getAllowed({
    required String origin,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getAllowed is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getOrigins}
  ///Returns the origins that have a stored decision allowing the Geolocation API.
  ///
  ///Returns an empty list when nothing is stored, and also when
  ///[WebViewFeature.MULTI_PROFILE] is not supported or the named profile does not exist.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.getOrigins.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'GeolocationPermissions.getOrigins',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/GeolocationPermissions#getOrigins(android.webkit.ValueCallback%3Cjava.util.Set%3Cjava.lang.String%3E%3E)',
      ),
    ],
  )
  Future<List<String>> getOrigins({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getOrigins is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformGeolocationPermissionsCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformGeolocationPermissions.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformGeolocationPermissionsMethod method, {
    TargetPlatform? platform,
  }) => _PlatformGeolocationPermissionsMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
