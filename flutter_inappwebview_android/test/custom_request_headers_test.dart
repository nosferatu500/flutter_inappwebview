import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/profile_store.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for the custom-request-header family on `ProfileStore` (§127). Converted in
/// place from `MethodChannel` mocks to the Pigeon boundary by §173, the tenth channel migration.
///
/// Five Dart methods carry androidx's eight, because Java overloads become optional named
/// arguments here. That mapping is the thing most likely to break silently: an omitted argument
/// arrives as `null` on the Kotlin side, which selects a *different overload* rather than failing —
/// for example a `getCustomHeaders` that drops `headerValue` quietly returns every value under that
/// name. No device test distinguishes that from a platform that ignores the filter.
///
/// Pigeon narrows the hazard without removing it: the arguments are now **positional**, so a
/// dropped one is a compile error rather than a missing map key, but a *swapped* pair of adjacent
/// `String?`s still type-checks perfectly. That is what the argument-order assertions below are for.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ProfileStoreHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.flutter_inappwebview_android.ProfileStoreHostApi.';
  const addChannel = '${prefix}addCustomHeader';
  const hasChannel = '${prefix}hasCustomHeader';
  const getChannel = '${prefix}getCustomHeaders';
  const clearChannel = '${prefix}clearCustomHeader';
  const clearAllChannel = '${prefix}clearAllCustomHeaders';

  const allChannels = [
    addChannel,
    hasChannel,
    getChannel,
    clearChannel,
    clearAllChannel,
  ];

  late AndroidProfileStore store;
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
    replies[getChannel] = <Object?>[];
    replies[hasChannel] = false;
    store = AndroidProfileStore(const PlatformProfileStoreCreationParams());
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

  /// The `CustomHeaderData` the host received on [channel], as the argument at [index].
  CustomHeaderData headerArg(String channel, int index) =>
      received[channel]![index] as CustomHeaderData;

  group('CustomHeader', () {
    test('serialises originRules as a List and restores a Set', () {
      // The public type holds a `Set`; the wire has none. The type must survive the List round trip
      // in both directions — getting it wrong is a runtime cast failure, not a compile error.
      final header = CustomHeader(
        name: 'X-A',
        value: 'v',
        originRules: {'https://a.test', 'https://b.test'},
      );
      final map = header.toMap();
      expect(map['originRules'], isA<List<String>>());
      expect((map['originRules'] as List).toSet(), {
        'https://a.test',
        'https://b.test',
      });

      final restored = CustomHeader.fromMap(map.cast<String, dynamic>());
      expect(restored?.originRules, header.originRules);
      expect(restored?.name, 'X-A');
      expect(restored?.value, 'v');
    });

    test('an empty rule set survives rather than becoming null', () {
      // A header with no rules is never sent anywhere — useless, but it must not silently become
      // "all origins" on the way across.
      final map = CustomHeader(
        name: 'X-A',
        value: 'v',
        originRules: const {},
      ).toMap();
      expect(map['originRules'], isEmpty);
      expect(map['originRules'], isNotNull);
    });
  });

  group('addCustomHeader', () {
    test(
      'sends the header payload and a null profileName by default',
      () async {
        await store.addCustomHeader(
          CustomHeader(name: 'X-A', value: 'v', originRules: const {'*'}),
        );

        final sent = headerArg(addChannel, 0);
        expect(sent.name, 'X-A');
        expect(sent.value, 'v');
        expect(sent.originRules, <String>['*']);
        expect(received[addChannel]![1], isNull);
      },
    );

    test('carries profileName when given', () async {
      await store.addCustomHeader(
        CustomHeader(name: 'X-A', value: 'v', originRules: const {'*'}),
        profileName: 'work',
      );
      expect(received[addChannel]![1], 'work');
    });

    test('an empty rule set crosses as an empty list, not null', () async {
      await store.addCustomHeader(
        CustomHeader(name: 'X-A', value: 'v', originRules: const {}),
      );
      expect(headerArg(addChannel, 0).originRules, isEmpty);
      expect(headerArg(addChannel, 0).originRules, isNotNull);
    });

    test('the host answers nothing and the future still completes', () async {
      // `void` on the host since §173 — the old channel replied a constant `true` that Dart threw
      // away. This pins that the absent reply is not mistaken for a failure.
      await expectLater(
        store.addCustomHeader(
          CustomHeader(name: 'X-A', value: 'v', originRules: const {'*'}),
        ),
        completes,
      );
    });
  });

  group('getCustomHeaders', () {
    test('sends both filter arguments as null when unfiltered', () async {
      // Null is what selects the unfiltered androidx overload on the host side, so the arguments
      // are asserted rather than merely absent.
      expect(await store.getCustomHeaders(), isEmpty);
      expect(received[getChannel], <Object?>[null, null, null]);
    });

    test('sends name alone, and name with value, in that order', () async {
      await store.getCustomHeaders(headerName: 'X-A');
      expect(received[getChannel], <Object?>['X-A', null, null]);

      await store.getCustomHeaders(headerName: 'X-A', headerValue: 'v');
      expect(received[getChannel], <Object?>['X-A', 'v', null]);

      // profileName is third, and is the argument a swap with headerValue would silently take.
      await store.getCustomHeaders(headerName: 'X-A', profileName: 'work');
      expect(received[getChannel], <Object?>['X-A', null, 'work']);
    });

    test('decodes the reply into a Set of CustomHeader', () async {
      replies[getChannel] = <Object?>[
        CustomHeaderData(
          name: 'X-A',
          value: 'v',
          originRules: <String>['https://a.test'],
        ),
      ];
      final result = await store.getCustomHeaders();
      expect(result, hasLength(1));
      expect(result.first.name, 'X-A');
      expect(result.first.value, 'v');
      expect(result.first.originRules, {'https://a.test'});
    });

    test('two values under one name both survive the Set conversion', () async {
      // The reply becomes a `Set<CustomHeader>`, and `CustomHeader` does not override `==`, so
      // identity keeps them distinct. Asserted because a value-equality type would collapse these
      // two into one and the device test for the filtered overloads would then be reading a set
      // that had already lost an element.
      replies[getChannel] = <Object?>[
        CustomHeaderData(name: 'X-M', value: 'one', originRules: <String>['*']),
        CustomHeaderData(name: 'X-M', value: 'two', originRules: <String>['*']),
      ];
      final result = await store.getCustomHeaders(headerName: 'X-M');
      expect(result.map((h) => h.value).toSet(), {'one', 'two'});
    });

    test('an empty reply becomes an empty set, not an exception', () async {
      replies[getChannel] = <Object?>[];
      expect(await store.getCustomHeaders(), isEmpty);
    });
  });

  group('clearCustomHeader', () {
    test('omits headerValue to clear every value under the name', () async {
      await store.clearCustomHeader('X-A');
      expect(received[clearChannel], <Object?>['X-A', null, null]);
    });

    test('sends headerValue to clear one value only', () async {
      await store.clearCustomHeader('X-A', headerValue: 'v');
      expect(received[clearChannel], <Object?>['X-A', 'v', null]);
    });

    test('profileName is the third argument, not the second', () async {
      await store.clearCustomHeader('X-A', profileName: 'work');
      expect(received[clearChannel], <Object?>['X-A', null, 'work']);
    });
  });

  group('clearAllCustomHeaders', () {
    test('sends profileName as its only argument', () async {
      await store.clearAllCustomHeaders();
      expect(received[clearAllChannel], <Object?>[null]);

      await store.clearAllCustomHeaders(profileName: 'work');
      expect(received[clearAllChannel], <Object?>['work']);
    });
  });

  group('hasCustomHeader', () {
    test('sends the name then the profile, and returns the answer', () async {
      replies[hasChannel] = true;
      expect(await store.hasCustomHeader('X-A'), isTrue);
      expect(received[hasChannel], <Object?>['X-A', null]);

      replies[hasChannel] = false;
      expect(await store.hasCustomHeader('X-A', profileName: 'work'), isFalse);
      expect(received[hasChannel], <Object?>['X-A', 'work']);
    });
  });

  group('platform gating', () {
    test('all five methods report Android-only', () {
      for (final m in [
        PlatformProfileStoreMethod.addCustomHeader,
        PlatformProfileStoreMethod.hasCustomHeader,
        PlatformProfileStoreMethod.getCustomHeaders,
        PlatformProfileStoreMethod.clearCustomHeader,
        PlatformProfileStoreMethod.clearAllCustomHeaders,
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

    test('WebViewFeature.CUSTOM_REQUEST_HEADERS mirrors the androidx name', () {
      expect(
        WebViewFeature.CUSTOM_REQUEST_HEADERS.toNativeValue(),
        'CUSTOM_REQUEST_HEADERS',
      );
      expect(
        WebViewFeature.values,
        contains(WebViewFeature.CUSTOM_REQUEST_HEADERS),
      );
    });
  });
}
