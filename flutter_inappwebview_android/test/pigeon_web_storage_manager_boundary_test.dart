import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/web_storage_manager.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the ninth channel migrated to Pigeon (§169, `web_storage_manager`), in the
/// shape §156 established and every migration since has reused.
///
/// `web_storage_manager_profile_test.dart` next to this one predates the migration and owns the
/// `profileName` forwarding. This file covers the rest: the origin conversion, the two methods whose
/// answer Dart discards, and the `deleteBrowsingDataForSite` return value that is deliberately *not*
/// the site it was given.
///
/// 🚨 **This group runs zero tests on Android** (`web_storage_manager` is an iOS-only integration
/// group — §158 recorded it as a baseline of 0), so unlike §168 there is **no device run that can
/// catch a mistake here**. That is precisely the situation §168's invented `assert` exploited, so
/// the coverage below is deliberately wider than the transport strictly needs.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = WebStorageManagerHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebStorageManagerHostApi.';
  const getOriginsChannel = '${prefix}getOrigins';
  const deleteAllDataChannel = '${prefix}deleteAllData';
  const deleteOriginChannel = '${prefix}deleteOrigin';
  const deleteBrowsingDataChannel = '${prefix}deleteBrowsingData';
  const deleteForSiteChannel = '${prefix}deleteBrowsingDataForSite';
  const quotaChannel = '${prefix}getQuotaForOrigin';
  const usageChannel = '${prefix}getUsageForOrigin';

  const allChannels = [
    getOriginsChannel,
    deleteAllDataChannel,
    deleteOriginChannel,
    deleteBrowsingDataChannel,
    deleteForSiteChannel,
    quotaChannel,
    usageChannel,
  ];

  late AndroidWebStorageManager manager;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
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
    replies.clear();
    replies[getOriginsChannel] = <Object?>[];
    replies[quotaChannel] = 0;
    replies[usageChannel] = 0;
    replies[deleteForSiteChannel] = null;
    manager = AndroidWebStorageManager(
      const PlatformWebStorageManagerCreationParams(),
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

  group('getOrigins', () {
    test('rebuilds every field of the public WebStorageOrigin', () async {
      replies[getOriginsChannel] = <Object?>[
        WebStorageOriginData(
          origin: 'https://example.com',
          quota: 1234,
          usage: 567,
        ),
      ];

      final origins = await manager.getOrigins();

      expect(origins.length, 1);
      expect(origins.single.origin, 'https://example.com');
      expect(origins.single.quota, 1234);
      expect(origins.single.usage, 567);
    });

    test('carries every origin, in order', () async {
      replies[getOriginsChannel] = <Object?>[
        WebStorageOriginData(origin: 'https://a.com', quota: 1, usage: 2),
        WebStorageOriginData(origin: 'https://b.com', quota: 3, usage: 4),
      ];

      final origins = await manager.getOrigins();

      expect(origins.map((o) => o.origin), ['https://a.com', 'https://b.com']);
      // Ordering is asserted because the Kotlin builds this from a Map's values; a change to how
      // that is iterated would reorder the list silently.
      expect(origins.map((o) => o.usage), [2, 4]);
    });

    test('an empty list is a valid answer, not an error', () async {
      // Which is also what the host sends when the storage could not be resolved — the two are
      // indistinguishable by design, and that is recorded rather than fixed (see the schema).
      replies[getOriginsChannel] = <Object?>[];
      expect(await manager.getOrigins(), isEmpty);
    });

    test('quota and usage survive values beyond 32 bits', () async {
      // Both are `long` on `WebStorage.Origin` and Pigeon maps Dart `int` to Kotlin `Long`, so no
      // narrowing happens anywhere on this channel. A quota above 2^31 is the cheap proof that
      // nothing truncates it — §162's narrowing bug in the one direction it could still appear.
      const big = 8589934592; // 8 GiB, > 2^32
      replies[getOriginsChannel] = <Object?>[
        WebStorageOriginData(origin: 'https://big.com', quota: big, usage: big),
      ];

      final origin = (await manager.getOrigins()).single;
      expect(origin.quota, big);
      expect(origin.usage, big);
    });
  });

  group('the answers Dart discards', () {
    test('deleteAllData completes whatever the host answers', () async {
      // The platform interface declares `Future<void>`, so the host's bool is dropped. Both values
      // are exercised to pin that neither throws nor changes the observable outcome — the point
      // being that a caller cannot currently tell a no-op from a real delete.
      replies[deleteAllDataChannel] = true;
      await expectLater(manager.deleteAllData(), completes);

      replies[deleteAllDataChannel] = false;
      await expectLater(manager.deleteAllData(profileName: 'nope'), completes);
    });

    test('deleteOrigin sends the origin and discards the answer', () async {
      replies[deleteOriginChannel] = false;
      await expectLater(
        manager.deleteOrigin(origin: 'https://example.com'),
        completes,
      );

      expect(received[deleteOriginChannel], <Object?>[
        'https://example.com',
        null,
      ]);
    });
  });

  group('deleteBrowsingData family', () {
    test('deleteBrowsingData returns the host answer', () async {
      replies[deleteBrowsingDataChannel] = true;
      expect(await manager.deleteBrowsingData(), isTrue);

      // false means either an unresolvable store or DELETE_BROWSING_DATA being unsupported.
      replies[deleteBrowsingDataChannel] = false;
      expect(await manager.deleteBrowsingData(), isFalse);
    });

    test(
      'deleteBrowsingDataForSite answers the resolved domain, not the site',
      () async {
        // The platform resolves the argument to its registrable domain, so this is the one method
        // here whose reply is not simply an echo. Pinned because a converter that passed the argument
        // back would look correct in every other test.
        replies[deleteForSiteChannel] = 'example.com';

        final domain = await manager.deleteBrowsingDataForSite(
          site: 'https://www.example.com/some/path',
        );

        expect(domain, 'example.com');
        expect(received[deleteForSiteChannel], <Object?>[
          'https://www.example.com/some/path',
          null,
        ]);
      },
    );

    test('a null domain is preserved, not turned into an empty string', () async {
      // null is the unresolvable-store / unsupported-feature answer, and it is the `String?`
      // counterpart of deleteBrowsingData's `false` — an inconsistency that predates the migration.
      replies[deleteForSiteChannel] = null;
      expect(
        await manager.deleteBrowsingDataForSite(site: 'https://example.com'),
        isNull,
      );
    });

    test('an unparseable site surfaces as a PlatformException', () async {
      // The Kotlin lets IllegalArgumentException propagate so Pigeon reports it through wrapError;
      // the old handler caught it and sent `result.error("MyWebStorage", …)`. The code is now the
      // exception's class name, which is the documented behaviour change.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(deleteForSiteChannel, (message) async {
            return codec.encodeMessage(<Object?>[
              'java.lang.IllegalArgumentException',
              'not a domain',
              null,
            ]);
          });

      await expectLater(
        manager.deleteBrowsingDataForSite(site: 'not a site'),
        throwsA(
          isA<PlatformException>()
              .having(
                (e) => e.code,
                'code',
                'java.lang.IllegalArgumentException',
              )
              .having((e) => e.message, 'message', 'not a domain'),
        ),
      );
    });
  });

  group('quota and usage', () {
    test('both send origin then profileName', () async {
      await manager.getQuotaForOrigin(
        origin: 'https://example.com',
        profileName: 'p',
      );
      await manager.getUsageForOrigin(origin: 'https://example.com');

      expect(received[quotaChannel], <Object?>['https://example.com', 'p']);
      expect(received[usageChannel], <Object?>['https://example.com', null]);
    });

    test('they are not interchangeable', () async {
      // Cheap, and the only thing that catches the two being wired to each other's channel — a
      // swap that type-checks perfectly because both are `Future<int>` of the same arguments.
      replies[quotaChannel] = 111;
      replies[usageChannel] = 222;

      expect(
        await manager.getQuotaForOrigin(origin: 'https://example.com'),
        111,
      );
      expect(
        await manager.getUsageForOrigin(origin: 'https://example.com'),
        222,
      );
    });

    test('zero is returned as zero', () async {
      // The host sends 0 both for a genuine zero and for an unresolvable store; the Dart side no
      // longer needs a `?? 0` because the schema types these non-null. Recorded rather than fixed.
      replies[quotaChannel] = 0;
      expect(await manager.getQuotaForOrigin(origin: 'https://example.com'), 0);
    });

    test('a value beyond 32 bits survives', () async {
      const big = 8589934592;
      replies[usageChannel] = big;
      expect(
        await manager.getUsageForOrigin(origin: 'https://example.com'),
        big,
      );
    });
  });
}
