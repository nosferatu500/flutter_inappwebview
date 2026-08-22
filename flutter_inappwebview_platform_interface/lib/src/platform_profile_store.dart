import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';

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
