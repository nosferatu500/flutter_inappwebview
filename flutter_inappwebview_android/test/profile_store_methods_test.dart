import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/profile_store.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the `WebViewFeature.MULTI_PROFILE` store —
/// `getAllProfileNames` / `getOrCreateProfile` / `deleteProfile`. Converted in place from
/// `MethodChannel` mocks to the Pigeon boundary by §173, the tenth channel migration.
///
/// `PlatformProfileStore.defaultProfileName` and the `profileName` settings key are pinned in
/// `flutter_inappwebview_platform_interface/test/profile_store_test.dart`; this covers the three
/// methods, which that test does not reach. Each has a failure mode a build cannot see:
///
///  * `getAllProfileNames` must survive an empty reply without throwing, and the `MULTI_PROFILE`
///    absent case must be an empty list rather than an error.
///  * `getOrCreateProfile` returns `String?` on purpose — `null` is "could not create", which is a
///    different answer from a profile whose name happens to be empty.
///  * `deleteProfile` returns `false` for "no such profile", and **throws** for the three refusals.
///
/// 🚨 **The `deleteProfile` rationale in this file used to be wrong, and wrong in the way §171
/// warned about.** It read "`deleteProfile` returns `false` for both 'no such profile' and 'profile
/// in use'. androidx throws in the second case, so the Kotlin side converting that to `false` is
/// deliberate." The Kotlin has never done that: it caught the exception and sent
/// `result.error("ProfileStoreManager", …)`, which reaches Dart as a `PlatformException` — exactly
/// as `PlatformProfileStore.deleteProfile`'s own doc comment says, and as §171 relied on. The test
/// underneath that comment set `reply = false` and asserted it came back `false`, so it asserted
/// the shape of its own mock and could never have contradicted the claim above it. The refusal is
/// now covered here *and* on a device (`profile_store_delete.dart`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ProfileStoreHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.ProfileStoreHostApi.';
  const namesChannel = '${prefix}getAllProfileNames';
  const createChannel = '${prefix}getOrCreateProfile';
  const deleteChannel = '${prefix}deleteProfile';

  const allChannels = [namesChannel, createChannel, deleteChannel];

  late AndroidProfileStore profileStore;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[
            replies.containsKey(channel) ? replies[channel] : null,
          ]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    replies[namesChannel] = <Object?>[];
    replies[deleteChannel] = true;
    profileStore = AndroidProfileStore.instance();
    for (final c in allChannels) {
      install(c);
    }
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in allChannels) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  group('AndroidProfileStore.getAllProfileNames', () {
    test('sends no arguments', () async {
      replies[namesChannel] = <Object?>['Default'];
      await profileStore.getAllProfileNames();

      // Pigeon sends `null` rather than an empty argument list for a no-argument method.
      expect(received[namesChannel], isNull);
    });

    test('decodes the reply as List<String>', () async {
      replies[namesChannel] = <Object?>['Default', 'signed_in'];

      final names = await profileStore.getAllProfileNames();

      expect(names, <String>['Default', 'signed_in']);
      expect(names, isA<List<String>>());
    });

    test('an empty list is a valid answer, not a throw', () async {
      // Which is also what the host sends when MULTI_PROFILE is unsupported. The two are
      // indistinguishable by design — see the schema — and in practice the empty list can only mean
      // the feature is missing, because the default profile is always listed otherwise.
      replies[namesChannel] = <Object?>[];
      expect(await profileStore.getAllProfileNames(), isEmpty);
    });

    test(
      'the default profile is always among them on a supporting device',
      () async {
        replies[namesChannel] = <Object?>['Default'];
        expect(
          await profileStore.getAllProfileNames(),
          contains(PlatformProfileStore.defaultProfileName),
        );
      },
    );
  });

  group('AndroidProfileStore.getOrCreateProfile', () {
    test('sends the name as its only argument', () async {
      replies[createChannel] = 'signed_in';
      await profileStore.getOrCreateProfile(name: 'signed_in');

      expect(received[createChannel], <Object?>['signed_in']);
    });

    test('returns the name the platform actually created', () async {
      // Not an echo of the argument: the host reads it back off the created `Profile`.
      replies[createChannel] = 'signed_in';
      expect(
        await profileStore.getOrCreateProfile(name: 'signed_in'),
        'signed_in',
      );
    });

    test(
      'null means "could not create", not "created with an empty name"',
      () async {
        replies[createChannel] = null;
        expect(
          await profileStore.getOrCreateProfile(name: 'signed_in'),
          isNull,
        );
      },
    );
  });

  group('AndroidProfileStore.deleteProfile', () {
    test('sends the name as its only argument', () async {
      replies[deleteChannel] = true;
      await profileStore.deleteProfile(name: 'signed_in');

      expect(received[deleteChannel], <Object?>['signed_in']);
    });

    test('false means "no such profile", and is not a refusal', () async {
      replies[deleteChannel] = false;
      expect(await profileStore.deleteProfile(name: 'signed_in'), isFalse);
    });

    test('a refusal is a PlatformException, not a false', () async {
      // The host normalises androidx's IllegalStateException and IllegalArgumentException to one
      // `FlutterError("ProfileStoreManager", …)`, so both refusals arrive under this single code
      // rather than under two exception-class names. `profile_store_delete.dart` proves the host
      // really does that on a device; this pins what the Dart side does with it.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(deleteChannel, (message) async {
            return codec.encodeMessage(<Object?>[
              'ProfileStoreManager',
              'Cannot delete in-use profile',
              null,
            ]);
          });

      await expectLater(
        profileStore.deleteProfile(name: 'signed_in'),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'ProfileStoreManager')
              .having(
                (e) => e.message,
                'message',
                'Cannot delete in-use profile',
              ),
        ),
      );
    });
  });

  group('platform gating', () {
    test('all three methods report Android-only', () {
      const methods = [
        PlatformProfileStoreMethod.getAllProfileNames,
        PlatformProfileStoreMethod.getOrCreateProfile,
        PlatformProfileStoreMethod.deleteProfile,
      ];

      for (final method in methods) {
        expect(
          profileStore.isMethodSupported(
            method,
            platform: TargetPlatform.android,
          ),
          isTrue,
          reason: '$method should be supported on Android',
        );
        expect(
          profileStore.isMethodSupported(method, platform: TargetPlatform.iOS),
          isFalse,
          reason: '$method is androidx-only and must not claim iOS',
        );
      }
    });
  });
}
