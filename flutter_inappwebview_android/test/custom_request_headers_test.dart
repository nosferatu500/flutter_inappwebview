import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wire-shape guards for the custom-request-header family on `ProfileStore` (§127).
///
/// Five Dart methods carry androidx's eight, because Java overloads become optional named
/// arguments here. That mapping is the thing most likely to break silently: an omitted key arrives
/// as `null` on the Kotlin side, which selects a *different overload* rather than failing — for
/// example a `getCustomHeaders` that drops `headerValue` quietly returns every value under that
/// name. No device test distinguishes that from a platform that ignores the filter.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_profilestore',
  );

  late AndroidProfileStore store;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    store = AndroidProfileStore(const PlatformProfileStoreCreationParams());
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

  group('CustomHeader', () {
    test('serialises originRules as a List and restores a Set', () {
      // The channel codec has no Set, so the type must survive a List round trip. Getting this
      // wrong yields a runtime cast failure inside the generated code, not a compile error.
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
    test('sends the header map and a null profileName by default', () async {
      await store.addCustomHeader(
        CustomHeader(name: 'X-A', value: 'v', originRules: const {'*'}),
      );

      expect(calls.single.method, 'addCustomHeader');
      final header = argsOf(calls.single)['header'] as Map<Object?, Object?>;
      expect(header['name'], 'X-A');
      expect(header['value'], 'v');
      expect((header['originRules'] as List).toSet(), {'*'});
      expect(argsOf(calls.single)['profileName'], isNull);
    });

    test('carries profileName when given', () async {
      await store.addCustomHeader(
        CustomHeader(name: 'X-A', value: 'v', originRules: const {'*'}),
        profileName: 'work',
      );
      expect(argsOf(calls.single)['profileName'], 'work');
    });
  });

  group('getCustomHeaders', () {
    test('sends both filter keys as null when unfiltered', () async {
      // Null is what selects the unfiltered androidx overload on the Kotlin side, so the keys are
      // asserted rather than merely absent.
      reply = <dynamic>[];
      await store.getCustomHeaders();

      expect(argsOf(calls.single)['headerName'], isNull);
      expect(argsOf(calls.single)['headerValue'], isNull);
    });

    test('sends name alone, and name with value', () async {
      reply = <dynamic>[];
      await store.getCustomHeaders(headerName: 'X-A');
      expect(argsOf(calls.single)['headerName'], 'X-A');
      expect(argsOf(calls.single)['headerValue'], isNull);

      calls.clear();
      await store.getCustomHeaders(headerName: 'X-A', headerValue: 'v');
      expect(argsOf(calls.single)['headerName'], 'X-A');
      expect(argsOf(calls.single)['headerValue'], 'v');
    });

    test('decodes the reply into a Set of CustomHeader', () async {
      reply = <dynamic>[
        <Object?, Object?>{
          'name': 'X-A',
          'value': 'v',
          'originRules': <Object?>['https://a.test'],
        },
      ];
      final result = await store.getCustomHeaders();
      expect(result, hasLength(1));
      expect(result.first.name, 'X-A');
      expect(result.first.originRules, {'https://a.test'});
    });

    test('a null reply becomes an empty set, not an exception', () async {
      reply = null;
      expect(await store.getCustomHeaders(), isEmpty);
    });
  });

  group('clearCustomHeader', () {
    test('omits headerValue to clear every value under the name', () async {
      await store.clearCustomHeader('X-A');
      expect(argsOf(calls.single)['headerName'], 'X-A');
      expect(argsOf(calls.single)['headerValue'], isNull);
    });

    test('sends headerValue to clear one value only', () async {
      await store.clearCustomHeader('X-A', headerValue: 'v');
      expect(argsOf(calls.single)['headerValue'], 'v');
    });
  });

  group('hasCustomHeader', () {
    test('a null reply reads as false', () async {
      // Non-nullable `bool` return: the platform answers false where the feature is missing, and
      // a missing reply must not throw.
      reply = null;
      expect(await store.hasCustomHeader('X-A'), isFalse);
      reply = true;
      expect(await store.hasCustomHeader('X-A'), isTrue);
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
