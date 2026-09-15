import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/web_storage_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument on the web-storage channel.
///
/// The Kotlin side treats null as "the default profile's storage". So a dropped `profileName` does
/// not fail — the call silently acts on the **default** profile, which for a WebView running on
/// another profile means reading quotas that are not its own and, worse, reporting a successful
/// delete after clearing somebody else's storage.
///
/// Before §169 this was a *key* in an argument map and could be renamed to nothing; it is now a
/// positional parameter on a generated signature, so the rename failure mode is gone. What remains
/// worth pinning is that **every method actually forwards the profile it was given** — still
/// invisible to the compiler, since passing `null` instead of the caller's value type-checks.
///
/// Mirrors `cookie_manager_profile_test.dart`, including the `args.last` trick: `profileName` is the
/// last parameter on all seven methods, whatever else they carry.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = WebStorageManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebStorageManagerHostApi.';

  // Every method, with the reply shape its caller accepts.
  const channels = <String, Object?>{
    '${prefix}getOrigins': <Object?>[],
    '${prefix}deleteAllData': true,
    '${prefix}deleteOrigin': true,
    '${prefix}deleteBrowsingData': true,
    '${prefix}deleteBrowsingDataForSite': 'example.com',
    '${prefix}getQuotaForOrigin': 0,
    '${prefix}getUsageForOrigin': 0,
  };

  late AndroidWebStorageManager webStorageManager;
  final Map<String, List<Object?>?> received = {};

  setUp(() {
    received.clear();
    webStorageManager = AndroidWebStorageManager(
      const PlatformWebStorageManagerCreationParams(),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    channels.forEach((channel, reply) {
      messenger.setMockMessageHandler(channel, (message) async {
        received[channel] = message == null
            ? null
            : codec.decodeMessage(message) as List<Object?>;
        return codec.encodeMessage(<Object?>[reply]);
      });
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in channels.keys) {
      messenger.setMockMessageHandler(channel, null);
    }
  });

  group('AndroidWebStorageManager profileName', () {
    test('is sent in the position the Android side reads', () async {
      await webStorageManager.deleteAllData(profileName: 'signed_in');

      expect(received['${prefix}deleteAllData'], <Object?>['signed_in']);
    });

    test('is null when not given, which means the default profile', () async {
      await webStorageManager.deleteAllData();

      expect(received['${prefix}deleteAllData'], <Object?>[null]);
    });

    test('reaches every method that accepts it', () async {
      await webStorageManager.getOrigins(profileName: 'p');
      await webStorageManager.deleteAllData(profileName: 'p');
      await webStorageManager.deleteOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.deleteBrowsingData(profileName: 'p');
      await webStorageManager.deleteBrowsingDataForSite(
        site: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.getQuotaForOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );
      await webStorageManager.getUsageForOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );

      // All seven methods, one channel each — unlike the cookie manager, no method here is built on
      // top of another's channel.
      expect(received.keys.toSet(), channels.keys.toSet());

      received.forEach((channel, args) {
        expect(
          args!.last,
          'p',
          reason: '${channel.split('.').last} dropped profileName',
        );
      });
    });

    test('does not disturb the other arguments', () async {
      await webStorageManager.deleteBrowsingDataForSite(
        site: 'https://www.example.com',
        profileName: 'p',
      );

      expect(received['${prefix}deleteBrowsingDataForSite'], <Object?>[
        'https://www.example.com',
        'p',
      ]);
    });
  });
}
