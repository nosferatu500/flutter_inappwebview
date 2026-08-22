import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the two hardcoded contracts of the multi-profile surface.
///
/// Neither one is checked by a compiler. `PlatformProfileStore.defaultProfileName` mirrors
/// `androidx.webkit.Profile.DEFAULT_PROFILE_NAME`, which the plugin copies rather than reads over
/// the channel, and `InAppWebViewSettings.profileName`'s map key is the string
/// `InAppWebViewSettings.parse` matches on in Kotlin. Getting either wrong fails *silently*: a
/// wrong default name just looks like a profile that does not exist, and a renamed key means the
/// profile is never applied and the WebView quietly stays on the default profile.
void main() {
  group('PlatformProfileStore.defaultProfileName', () {
    test('matches androidx Profile.DEFAULT_PROFILE_NAME', () {
      // Read out of webkit-1.17.0.aar with `javap -constants androidx.webkit.Profile`.
      expect(PlatformProfileStore.defaultProfileName, 'Default');
    });
  });

  group('InAppWebViewSettings.profileName', () {
    test('serialises under the key the Android side parses', () {
      final map = InAppWebViewSettings(profileName: 'signed_in').toMap();

      expect(map['profileName'], 'signed_in');
      expect(map['profileName'], isA<String>());
    });

    test('is absent rather than defaulted when not set', () {
      final map = InAppWebViewSettings().toMap();

      // Kotlin's parse() only assigns fields whose value is non-null, and applyProfileName()
      // returns early on null, so "not set" has to stay null rather than becoming "Default" --
      // otherwise every WebView would take the setProfile path it is meant to skip.
      expect(map['profileName'], isNull);
    });

    test('survives a fromMap round-trip', () {
      final settings = InAppWebViewSettings.fromMap(
        InAppWebViewSettings(profileName: 'anonymous').toMap(),
      );

      expect(settings?.profileName, 'anonymous');
    });
  });
}
