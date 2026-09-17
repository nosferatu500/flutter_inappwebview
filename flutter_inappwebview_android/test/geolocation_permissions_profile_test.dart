import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/geolocation_permissions.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire contract of the geolocation-permissions channel. Converted in place from
/// `MethodChannel` mocks to the Pigeon boundary by §175, the eleventh channel migration.
///
/// The hazard the original version existed for has **changed shape rather than gone away**. It was:
/// `GeolocationPermissionsManager` read `origin` and `profileName` with `call.argument(...)`, which
/// yields null rather than failing for a key that is not there — so a typo in either surfaced as
/// "the origin `null` was allowed", not as an error. Pigeon removes the typo (arguments are
/// positional and generated from one schema) but introduces the neighbouring one: **`origin` and
/// `profileName` are adjacent `String`/`String?` parameters, and swapping them type-checks**. That
/// is what the per-method order assertions below are for.
///
/// The `getAllowed` null case is asserted separately because it carries a deliberate distinction:
/// null means "could not ask" (feature missing, or no such profile) while false is an answer. §174's
/// `an unknown profile resolves to no store` proves the host really behaves that way on a device;
/// this pins what the Dart side does with each reply.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = GeolocationPermissionsHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.GeolocationPermissionsHostApi.';
  const allowChannel = '${prefix}allow';
  const clearChannel = '${prefix}clear';
  const clearAllChannel = '${prefix}clearAll';
  const getAllowedChannel = '${prefix}getAllowed';
  const getOriginsChannel = '${prefix}getOrigins';

  const allChannels = [
    allowChannel,
    clearChannel,
    clearAllChannel,
    getAllowedChannel,
    getOriginsChannel,
  ];

  late AndroidGeolocationPermissions permissions;
  final Map<String, List<Object?>?> received = {};
  final List<String> callOrder = <String>[];
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          callOrder.add(channel.substring(prefix.length));
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[
            replies.containsKey(channel) ? replies[channel] : true,
          ]);
        });
  }

  setUp(() {
    received.clear();
    callOrder.clear();
    replies.clear();
    replies[getOriginsChannel] = <Object?>[];
    permissions = AndroidGeolocationPermissions(
      const PlatformGeolocationPermissionsCreationParams(),
    );
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

  group('AndroidGeolocationPermissions', () {
    test('each method reaches its own channel', () async {
      await permissions.allow(origin: 'https://example.com');
      await permissions.clear(origin: 'https://example.com');
      await permissions.clearAll();
      await permissions.getAllowed(origin: 'https://example.com');
      await permissions.getOrigins();

      // The Pigeon equivalent of the old method-name assertion: five methods, five distinct
      // channels, in order. Catches two of them being wired to the same generated call.
      expect(callOrder, <String>[
        'allow',
        'clear',
        'clearAll',
        'getAllowed',
        'getOrigins',
      ]);
    });

    test(
      'origin comes first and profileName second, on every method that takes both',
      () async {
        // The swap that type-checks. Asserted per method rather than once, because the arguments are
        // positional now and a single transposed call site would not show up anywhere else.
        await permissions.allow(origin: 'o', profileName: 'p');
        expect(received[allowChannel], <Object?>['o', 'p']);

        await permissions.clear(origin: 'o', profileName: 'p');
        expect(received[clearChannel], <Object?>['o', 'p']);

        await permissions.getAllowed(origin: 'o', profileName: 'p');
        expect(received[getAllowedChannel], <Object?>['o', 'p']);
      },
    );

    test(
      'profileName is the only argument of the two that take it alone',
      () async {
        await permissions.clearAll(profileName: 'p');
        expect(received[clearAllChannel], <Object?>['p']);

        await permissions.getOrigins(profileName: 'p');
        expect(received[getOriginsChannel], <Object?>['p']);
      },
    );

    test(
      'an omitted profileName crosses as null, not as an absent argument',
      () async {
        // Null is what selects the default store on the host side, so it has to actually arrive.
        await permissions.allow(origin: 'o');
        expect(received[allowChannel], <Object?>['o', null]);

        await permissions.clearAll();
        expect(received[clearAllChannel], <Object?>[null]);

        await permissions.getOrigins();
        expect(received[getOriginsChannel], <Object?>[null]);
      },
    );

    test('getAllowed keeps null distinct from false', () async {
      // The load-bearing tri-state. `null` means the store could not be resolved; `false` means it
      // was read and holds no decision. Collapsing them would make a caller skip a prompt it should
      // have shown.
      replies[getAllowedChannel] = null;
      expect(await permissions.getAllowed(origin: 'o'), isNull);

      replies[getAllowedChannel] = false;
      expect(await permissions.getAllowed(origin: 'o'), isFalse);

      replies[getAllowedChannel] = true;
      expect(await permissions.getAllowed(origin: 'o'), isTrue);
    });

    test('the mutating calls report false when nothing happened', () async {
      // `false` is the host's "the store could not be resolved", which is the same condition
      // getAllowed reports as null and getOrigins as an empty list — three spellings, preserved
      // from the hand-written channel rather than harmonised.
      replies[allowChannel] = false;
      replies[clearChannel] = false;
      replies[clearAllChannel] = false;

      expect(
        await permissions.allow(origin: 'o', profileName: 'gone'),
        isFalse,
      );
      expect(
        await permissions.clear(origin: 'o', profileName: 'gone'),
        isFalse,
      );
      expect(await permissions.clearAll(profileName: 'gone'), isFalse);
    });

    test('getOrigins comes back as a typed list', () async {
      replies[getOriginsChannel] = <Object?>[
        'https://a.example/',
        'https://b.example/',
      ];
      final origins = await permissions.getOrigins();

      expect(origins, isA<List<String>>());
      expect(origins, <String>['https://a.example/', 'https://b.example/']);
    });

    test('an empty origins list is a valid answer, not an error', () async {
      // Which is also what the host sends for an unresolvable store; the two are indistinguishable
      // by design. See the schema.
      replies[getOriginsChannel] = <Object?>[];
      expect(await permissions.getOrigins(), isEmpty);
    });

    test(
      'a host failure on an @async method surfaces as a PlatformException',
      () async {
        // The reason `replyingOnThrow` is on both @async methods (§172): Pigeon does not wrap an
        // @async generated handler in try/catch, so without the helper a synchronous throw inside
        // getOrigins would send **no reply at all** and reach here as
        // `PlatformException(channel-error, ...)` — naming the transport, not the cause. With it, the
        // failure arrives under the manager's own code.
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(getOriginsChannel, (message) async {
              return codec.encodeMessage(<Object?>[
                'GeolocationPermissionsManager',
                'boom',
                null,
              ]);
            });

        await expectLater(
          permissions.getOrigins(),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'GeolocationPermissionsManager')
                .having((e) => e.message, 'message', 'boom'),
          ),
        );
      },
    );
  });

  group('platform gating', () {
    test('all five methods report Android-only', () {
      for (final m in [
        PlatformGeolocationPermissionsMethod.allow,
        PlatformGeolocationPermissionsMethod.clear,
        PlatformGeolocationPermissionsMethod.clearAll,
        PlatformGeolocationPermissionsMethod.getAllowed,
        PlatformGeolocationPermissionsMethod.getOrigins,
      ]) {
        expect(
          permissions.isMethodSupported(m, platform: TargetPlatform.android),
          isTrue,
        );
        expect(
          permissions.isMethodSupported(m, platform: TargetPlatform.iOS),
          isFalse,
        );
      }
    });
  });
}
