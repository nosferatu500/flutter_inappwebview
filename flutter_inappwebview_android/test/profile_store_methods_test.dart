import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire shape of the `WebViewFeature.MULTI_PROFILE` store —
/// `getAllProfileNames` / `getOrCreateProfile` / `deleteProfile`.
///
/// `PlatformProfileStore.defaultProfileName` and the `profileName` settings key are pinned in
/// `flutter_inappwebview_platform_interface/test/profile_store_test.dart`; this covers the three
/// methods, which that test does not reach. Each has a failure mode a build cannot see:
///
///  * `getAllProfileNames` casts the reply to `List<String>`. An untyped `List` from the platform
///    (which is what the standard codec produces) must survive the cast, and an absent reply must
///    become an empty list rather than throwing inside the caller.
///  * `getOrCreateProfile` returns `String?` on purpose — `null` is "could not create", which is a
///    different answer from a profile whose name happens to be empty.
///  * `deleteProfile` returns `false` for both "no such profile" and "profile in use". androidx
///    throws in the second case, so the Kotlin side converting that to `false` is deliberate.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_profilestore',
  );

  late AndroidProfileStore profileStore;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    profileStore = AndroidProfileStore.instance();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidProfileStore.getAllProfileNames', () {
    test('sends no arguments', () async {
      reply = <Object?>['Default'];
      await profileStore.getAllProfileNames();

      expect(calls.single.method, 'getAllProfileNames');
      expect(argsOf(calls.single), isEmpty);
    });

    test('casts the untyped platform list to List<String>', () async {
      // The standard codec hands back List<Object?>, never List<String>.
      reply = <Object?>['Default', 'signed_in'];

      final names = await profileStore.getAllProfileNames();

      expect(names, <String>['Default', 'signed_in']);
      expect(names, isA<List<String>>());
    });

    test('an absent reply is an empty list, not a throw', () async {
      reply = null;
      expect(await profileStore.getAllProfileNames(), isEmpty);
    });

    test(
      'the default profile is always among them on a supporting device',
      () async {
        reply = <Object?>['Default'];
        expect(
          await profileStore.getAllProfileNames(),
          contains(PlatformProfileStore.defaultProfileName),
        );
      },
    );
  });

  group('AndroidProfileStore.getOrCreateProfile', () {
    test('sends the name under the key Kotlin reads', () async {
      reply = 'signed_in';
      await profileStore.getOrCreateProfile(name: 'signed_in');

      expect(calls.single.method, 'getOrCreateProfile');
      expect(argsOf(calls.single)['name'], 'signed_in');
    });

    test('returns the name the platform actually created', () async {
      reply = 'signed_in';
      expect(
        await profileStore.getOrCreateProfile(name: 'signed_in'),
        'signed_in',
      );
    });

    test(
      'null means "could not create", not "created with an empty name"',
      () async {
        reply = null;
        expect(
          await profileStore.getOrCreateProfile(name: 'signed_in'),
          isNull,
        );
      },
    );
  });

  group('AndroidProfileStore.deleteProfile', () {
    test('sends the name under the key Kotlin reads', () async {
      reply = true;
      await profileStore.deleteProfile(name: 'signed_in');

      expect(calls.single.method, 'deleteProfile');
      expect(argsOf(calls.single)['name'], 'signed_in');
    });

    test('false covers both "no such profile" and "profile in use"', () async {
      reply = false;
      expect(await profileStore.deleteProfile(name: 'signed_in'), isFalse);

      reply = null;
      expect(await profileStore.deleteProfile(name: 'signed_in'), isFalse);
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
