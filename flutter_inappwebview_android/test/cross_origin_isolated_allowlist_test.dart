import 'package:flutter/services.dart';
import 'package:nosferatu500_inappwebview_android/nosferatu500_inappwebview_android.dart';
import 'package:nosferatu500_inappwebview_android/src/pigeons/profile_store.g.dart';
import 'package:nosferatu500_inappwebview_platform_interface/nosferatu500_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for `ProfileStore`'s cross-origin-isolated allowlist (androidx.webkit 1.18.0,
/// `CROSS_ORIGIN_ISOLATED_ALLOWLIST`).
///
/// What can break silently here is the read's `null`: it means "profile or feature unreachable",
/// while an empty set is a real answer ("no allowlist"). Collapsing either into the other type-checks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ProfileStoreHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.nosferatu500_inappwebview_android.ProfileStoreHostApi.';
  const setChannel = '${prefix}setCrossOriginIsolatedAllowlist';
  const getChannel = '${prefix}getCrossOriginIsolatedAllowlist';

  late AndroidProfileStore store;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};
  final Map<String, List<Object?>> errors = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          // Pigeon's error envelope is a three-element list: code, message, details.
          if (errors.containsKey(channel)) {
            return codec.encodeMessage(errors[channel]);
          }
          return codec.encodeMessage(<Object?>[replies[channel]]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    errors.clear();
    replies[setChannel] = true;
    replies[getChannel] = <Object?>[];
    store = AndroidProfileStore(const PlatformProfileStoreCreationParams());
    install(setChannel);
    install(getChannel);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(setChannel, null);
    messenger.setMockMessageHandler(getChannel, null);
  });

  group('setCrossOriginIsolatedAllowlist', () {
    test('sends the rules as a list, then a null profileName', () async {
      await store.setCrossOriginIsolatedAllowlist({
        'https://a.test',
        'https://b.test',
      });
      final args = received[setChannel]!;
      expect(args, hasLength(2));
      expect((args[0] as List).toSet(), {'https://a.test', 'https://b.test'});
      expect(args[1], isNull);
    });

    test('carries profileName as the second argument', () async {
      await store.setCrossOriginIsolatedAllowlist({
        'https://a.test',
      }, profileName: 'work');
      expect(received[setChannel]![1], 'work');
    });

    test('an empty set crosses as an empty list, not null', () async {
      // Empty is how the allowlist is cleared, so it must arrive as a value.
      await store.setCrossOriginIsolatedAllowlist(const {});
      expect(received[setChannel]![0], isEmpty);
      expect(received[setChannel]![0], isNotNull);
    });

    test('returns the host answer', () async {
      expect(await store.setCrossOriginIsolatedAllowlist(const {}), isTrue);
      replies[setChannel] = false;
      expect(
        await store.setCrossOriginIsolatedAllowlist(
          const {},
          profileName: 'nope',
        ),
        isFalse,
      );
    });

    test('an unparsable rule surfaces as code ProfileStoreManager', () async {
      // The Kotlin re-throws androidx's IllegalArgumentException as FlutterError("ProfileStoreManager"),
      // so the code is stable rather than an exception-class name.
      errors[setChannel] = <Object?>['ProfileStoreManager', 'bad origin', null];
      await expectLater(
        store.setCrossOriginIsolatedAllowlist({'not a rule'}),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'ProfileStoreManager',
          ),
        ),
      );
    });
  });

  group('getCrossOriginIsolatedAllowlist', () {
    test('sends profileName as its only argument', () async {
      await store.getCrossOriginIsolatedAllowlist();
      expect(received[getChannel], <Object?>[null]);

      await store.getCrossOriginIsolatedAllowlist(profileName: 'work');
      expect(received[getChannel], <Object?>['work']);
    });

    test('decodes the reply into a Set', () async {
      replies[getChannel] = <Object?>[
        'https://a.test:443',
        'https://b.test:443',
      ];
      expect(await store.getCrossOriginIsolatedAllowlist(), {
        'https://a.test:443',
        'https://b.test:443',
      });
    });

    test('an empty reply is an empty set, not null', () async {
      replies[getChannel] = <Object?>[];
      final result = await store.getCrossOriginIsolatedAllowlist();
      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('null, the unreachable-profile answer, is returned as null', () async {
      replies[getChannel] = null;
      expect(
        await store.getCrossOriginIsolatedAllowlist(profileName: 'missing'),
        isNull,
      );
    });
  });

  group('platform gating', () {
    test('both methods report Android-only', () {
      for (final m in [
        PlatformProfileStoreMethod.setCrossOriginIsolatedAllowlist,
        PlatformProfileStoreMethod.getCrossOriginIsolatedAllowlist,
      ]) {
        expect(
          store.isMethodSupported(m, platform: TargetPlatform.android),
          isTrue,
        );
        expect(
          store.isMethodSupported(m, platform: TargetPlatform.iOS),
          isFalse,
        );
      }
    });

    test('WebViewFeature.CROSS_ORIGIN_ISOLATED_ALLOWLIST mirrors the androidx name', () {
      expect(
        WebViewFeature.CROSS_ORIGIN_ISOLATED_ALLOWLIST.toNativeValue(),
        'CROSS_ORIGIN_ISOLATED_ALLOWLIST',
      );
      expect(
        WebViewFeature.values,
        contains(WebViewFeature.CROSS_ORIGIN_ISOLATED_ALLOWLIST),
      );
    });
  });
}
