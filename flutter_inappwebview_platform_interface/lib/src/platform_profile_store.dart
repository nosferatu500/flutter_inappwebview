import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';
import 'types/custom_header.dart';

part 'platform_profile_store.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams}
/// Object specifying creation parameters for creating a [PlatformProfileStore].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformProfileStoreCreationParams {
  /// Used by the platform implementation to create a new [PlatformProfileStore].
  const PlatformProfileStoreCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformProfileStoreCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformProfileStore}
///Manages the creation and deletion of WebView browsing profiles.
///
///A profile is one browsing session: it owns its own cookies, its own web storage, its own
///geolocation permissions and its own service workers. Two WebViews on different profiles share
///none of that, which is what makes it possible to keep, for example, a signed-in session and an
///anonymous one side by side in the same app.
///
///Assign a profile to a WebView with [InAppWebViewSettings.profileName]. That has to be done when
///the WebView is created — a profile cannot be swapped afterwards.
///
///Every profile persists on disk until [deleteProfile] removes it, so profile names are app-level
///identity, not per-session scratch space. The default profile is named [defaultProfileName] and
///cannot be deleted.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'ProfileStore',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProfileStore',
      note:
          'available on Android only if [WebViewFeature.MULTI_PROFILE] feature is supported.',
    ),
  ],
)
abstract class PlatformProfileStore extends PlatformInterface {
  /// Creates a new [PlatformProfileStore]
  factory PlatformProfileStore(PlatformProfileStoreCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProfileStore profileStore = InAppWebViewPlatform.instance!
        .createPlatformProfileStore(params);
    PlatformInterface.verify(profileStore, _token);
    return profileStore;
  }

  /// Creates a new [PlatformProfileStore] to access static methods.
  factory PlatformProfileStore.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProfileStore profileStoreStatic = InAppWebViewPlatform
        .instance!
        .createPlatformProfileStoreStatic();
    PlatformInterface.verify(profileStoreStatic, _token);
    return profileStoreStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformProfileStore].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformProfileStore.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformProfileStore].
  final PlatformProfileStoreCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.defaultProfileName}
  ///The name of the profile every WebView uses unless [InAppWebViewSettings.profileName] says
  ///otherwise.
  ///
  ///It always exists, it is always listed by [getAllProfileNames], and [deleteProfile] refuses to
  ///remove it.
  ///{@endtemplate}
  static const String defaultProfileName = 'Default';

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames}
  ///Returns the names of every profile that currently exists, including [defaultProfileName].
  ///
  ///This is also the right way to test whether a profile exists. The native API has a lookup that
  ///returns the profile itself, but reading a profile that way loads it into memory and
  ///**permanently prevents [deleteProfile] from removing it** for the lifetime of the process, so
  ///it is deliberately not exposed. Checking this list costs nothing and has no such side effect.
  ///
  ///Returns an empty list when [WebViewFeature.MULTI_PROFILE] is not supported.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getAllProfileNames.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getAllProfileNames',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames()',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE]. Returns an empty list if the feature is not supported.',
      ),
    ],
  )
  Future<List<String>> getAllProfileNames() {
    throw UnimplementedError(
      'getAllProfileNames is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile}
  ///Creates the profile called [name] if it does not exist yet, and returns its name.
  ///
  ///The returned name is the profile's own name as the platform reports it, so it can be handed
  ///straight to [InAppWebViewSettings.profileName].
  ///
  ///**This loads the profile into memory, and a profile that has been loaded cannot be deleted
  ///again until the app process restarts** — [deleteProfile] will fail for it. That is a platform
  ///rule, not a plugin limitation. Create profiles you intend to keep; do not create one just to
  ///find out whether it exists (use [getAllProfileNames]) and do not create-then-delete in the
  ///same run.
  ///
  ///Returns `null` when [WebViewFeature.MULTI_PROFILE] is not supported, in which case no profile
  ///was created.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getOrCreateProfile.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getOrCreateProfile',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#getOrCreateProfile(java.lang.String)',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE]. Returns `null` and creates nothing if the feature is not supported.',
      ),
    ],
  )
  Future<String?> getOrCreateProfile({required String name}) {
    throw UnimplementedError(
      'getOrCreateProfile is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.deleteProfile}
  ///Deletes the profile called [name] and the data it owns.
  ///
  ///Returns `true` if the profile existed and its data is being deleted, `false` if there was no
  ///such profile, and `false` when [WebViewFeature.MULTI_PROFILE] is not supported. Some of the
  ///data is removed asynchronously, so it is not guaranteed to be off disk by the time this
  ///returns.
  ///
  ///Throws a `PlatformException` when the platform refuses the deletion, which it does in three
  ///cases:
  ///
  ///- a WebView using this profile is still alive — dispose those WebViews first;
  ///- the profile has been loaded into memory this run, by [getOrCreateProfile] or by a WebView
  ///  that used it. **There is no way to clear that state short of restarting the process**, so a
  ///  profile created and used in this run generally cannot be deleted until the next one;
  ///- [name] is [defaultProfileName], which can never be deleted.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.deleteProfile.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.deleteProfile',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#deleteProfile(java.lang.String)',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE]. Returns `false` and deletes nothing if the feature is not supported.',
      ),
    ],
  )
  Future<bool> deleteProfile({required String name}) {
    throw UnimplementedError(
      'deleteProfile is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.addCustomHeader}
  ///Adds a [CustomHeader] sent on every request this profile makes to an origin matching the
  ///header's [CustomHeader.originRules].
  ///
  ///It applies to requests started **after** this call, and covers subresources, prefetches and
  ///requests made by service workers — not just navigations. `WebSocket` requests are excluded.
  ///Headers added here also appear in the request handed to
  ///[PlatformWebViewCreationParams.shouldInterceptRequest].
  ///
  ///Adding the same name and value again **merges** the two rule sets rather than replacing them,
  ///and there is no "replace" operation — clear the header first if that is what you want.
  ///
  ///A no-op where the feature is unsupported.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.addCustomHeader.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.addCustomHeader',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#addCustomHeader(androidx.webkit.CustomHeader)',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. '
            'The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.',
      ),
    ],
  )
  Future<void> addCustomHeader(
    CustomHeader header, {
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'addCustomHeader is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.hasCustomHeader}
  ///Whether this profile has any custom header with the given [headerName], **case-insensitively**.
  ///
  ///Returns `false` where the feature is unsupported, which is indistinguishable from "no such
  ///header" — check [WebViewFeature.CUSTOM_REQUEST_HEADERS] first if you need to tell them apart.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.hasCustomHeader.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.hasCustomHeader',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#hasCustomHeader(java.lang.String)',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. '
            'The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.',
      ),
    ],
  )
  Future<bool> hasCustomHeader(
    String headerName, {
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'hasCustomHeader is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.getCustomHeaders}
  ///All custom headers set on this profile.
  ///
  ///Pass [headerName] to keep only headers with that name (case-insensitive), and [headerValue]
  ///as well to keep only the one with that exact value (case-sensitive). Passing [headerValue]
  ///without [headerName] is meaningless and is ignored.
  ///
  ///Returns an empty set where the feature is unsupported.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.getCustomHeaders.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.getCustomHeaders',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#getCustomHeaders()',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. '
            'The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.',
      ),
    ],
  )
  Future<Set<CustomHeader>> getCustomHeaders({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? headerName,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? headerValue,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'getCustomHeaders is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.clearCustomHeader}
  ///Removes custom headers with the given [headerName] (case-insensitive).
  ///
  ///Pass [headerValue] to remove only the header with that exact value (case-sensitive), leaving
  ///any others that share the name. Omit it to remove every header with that name.
  ///
  ///A no-op where the feature is unsupported, and a no-op when nothing matches.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.clearCustomHeader.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.clearCustomHeader',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#clearCustomHeader(java.lang.String)',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. '
            'The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.',
      ),
    ],
  )
  Future<void> clearCustomHeader(
    String headerName, {
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? headerValue,
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'clearCustomHeader is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.clearAllCustomHeaders}
  ///Removes every custom header from this profile.
  ///
  ///A no-op where the feature is unsupported.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStore.clearAllCustomHeaders.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.clearAllCustomHeaders',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#clearAllCustomHeaders()',
        note:
            'Requires [WebViewFeature.MULTI_PROFILE] and [WebViewFeature.CUSTOM_REQUEST_HEADERS]. '
            'The androidx API is on `Profile`; this class reaches it by name, which is how every other profile-scoped surface in this plugin works.',
      ),
    ],
  )
  Future<void> clearAllCustomHeaders({
    @SupportedPlatforms(platforms: [AndroidPlatform()]) String? profileName,
  }) {
    throw UnimplementedError(
      'clearAllCustomHeaders is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformProfileStoreCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformProfileStore.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformProfileStoreMethod method, {
    TargetPlatform? platform,
  }) => _PlatformProfileStoreMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
