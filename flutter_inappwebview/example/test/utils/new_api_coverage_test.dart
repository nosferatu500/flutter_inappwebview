import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/controller_methods_registry.dart';
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins that every API this fork added is actually reachable from the example app.
///
/// The example is the only place a reader can see these APIs used, and nothing else notices when a
/// new setting or method ships without a demo — the app compiles and runs exactly the same. This
/// test is the reminder: adding a platform API means adding it here too.
///
/// Two settings are deliberately *not* in the settings editor: `userAgentMetadata` and
/// `webViewMediaIntegrityApiStatus` are object-valued, and `SettingDefinition` only models bools,
/// numbers, strings and enums. They are demonstrated through `setSettings` in the controller-methods
/// registry instead, which is what the second group checks.
void main() {
  final settingProperties = getSettingDefinitions().values
      .expand((definitions) => definitions)
      .map((definition) => definition.property)
      .toSet();

  final registryMethods = ControllerMethodsRegistry.instance.allMethods;
  final registryMethodEnums = registryMethods
      .map((entry) => entry.methodEnum)
      .toSet();

  group('settings editor covers the new settings', () {
    test('the androidx settings are editable', () {
      expect(
        settingProperties,
        containsAll(<InAppWebViewSettingsProperty>[
          InAppWebViewSettingsProperty.paymentRequestEnabled,
          InAppWebViewSettingsProperty.webAuthenticationSupport,
          InAppWebViewSettingsProperty.downloadFaviconsEnabled,
          InAppWebViewSettingsProperty.backForwardCacheEnabled,
          InAppWebViewSettingsProperty.attributionRegistrationBehavior,
          InAppWebViewSettingsProperty.profileName,
          // Not an androidx feature flag but the same shape of addition: Android-only, and
          // invisible unless the example lets you change it.
          InAppWebViewSettingsProperty.syncCallbackTimeoutMillis,
        ]),
      );
    });

    test('the WebKit settings are editable', () {
      expect(
        settingProperties,
        containsAll(<InAppWebViewSettingsProperty>[
          InAppWebViewSettingsProperty.lockdownModeEnabled,
          InAppWebViewSettingsProperty.securityRestrictionMode,
          InAppWebViewSettingsProperty.preferredHTTPSNavigationPolicy,
          InAppWebViewSettingsProperty.supportsAdaptiveImageGlyph,
          InAppWebViewSettingsProperty.writingToolsBehavior,
          InAppWebViewSettingsProperty.showsSystemScreenTimeBlockingView,
        ]),
      );
    });
  });

  group('controller methods registry covers the new methods', () {
    test('every new controller method has an entry', () {
      expect(
        registryMethodEnums,
        containsAll(<PlatformInAppWebViewControllerMethod>[
          PlatformInAppWebViewControllerMethod.setAudioMuted,
          PlatformInAppWebViewControllerMethod.isAudioMuted,
          PlatformInAppWebViewControllerMethod.setDefaultTrafficStatsTag,
          PlatformInAppWebViewControllerMethod.prerenderUrl,
          PlatformInAppWebViewControllerMethod.postVisualStateCallback,
          PlatformInAppWebViewControllerMethod.documentHasImages,
          PlatformInAppWebViewControllerMethod.flingScroll,
          PlatformInAppWebViewControllerMethod.isBlockedByScreenTime,
        ]),
      );
    });

    test('the object-valued settings are demonstrated through setSettings', () {
      final setSettings = registryMethods
          .where(
            (entry) =>
                entry.methodEnum ==
                PlatformInAppWebViewControllerMethod.setSettings,
          )
          .toList();

      // Exactly one, because the registry derives a method's id from its methodEnum: a second
      // setSettings entry would collide with this one in findMethodById and in the result history.
      expect(setSettings, hasLength(1));
      expect(setSettings.single.description, contains('userAgentMetadata'));
      expect(setSettings.single.description, contains('Media Integrity'));
      expect(
        setSettings.single.parameters.keys,
        containsAll(<String>['brand', 'majorVersion', 'trustedOrigin']),
      );
    });

    test('registry ids stay unique', () {
      // The guard the previous test relies on, stated once for the whole registry.
      final ids = registryMethods.map((entry) => entry.id).toList();
      expect(ids.length, ids.toSet().length);
    });
  });
}
