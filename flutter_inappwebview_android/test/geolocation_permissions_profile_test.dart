import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the wire contract of the geolocation-permissions channel.
///
/// This is a brand-new surface, so both halves are unproven: the method names and the argument
/// keys. `GeolocationPermissionsManager` reads `origin` and `profileName` with
/// `call.argument(...)`, which yields null rather than failing for a key that is not there — so a
/// typo in either would surface as "the origin `null` was allowed", not as an error.
///
/// The `getAllowed` null case is asserted separately because it carries a deliberate distinction:
/// null means "could not ask" (feature missing, or no such profile) while false is an answer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_geolocationpermissions',
  );

  late AndroidGeolocationPermissions permissions;
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = true;
    permissions = AndroidGeolocationPermissions(
      const PlatformGeolocationPermissionsCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          if (call.method == 'getOrigins') {
            return reply ?? <dynamic>[];
          }
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidGeolocationPermissions', () {
    test('sends the method names the Android side dispatches on', () async {
      await permissions.allow(origin: 'https://example.com');
      await permissions.clear(origin: 'https://example.com');
      await permissions.clearAll();
      await permissions.getAllowed(origin: 'https://example.com');
      reply = <dynamic>[];
      await permissions.getOrigins();

      expect(calls.map((c) => c.method).toList(), <String>[
        'allow',
        'clear',
        'clearAll',
        'getAllowed',
        'getOrigins',
      ]);
    });

    test('sends origin and profileName under the keys Kotlin reads', () async {
      await permissions.allow(
        origin: 'https://example.com',
        profileName: 'signed_in',
      );

      expect(argsOf(calls.single)['origin'], 'https://example.com');
      expect(argsOf(calls.single)['profileName'], 'signed_in');
    });

    test(
      'profileName is null when omitted, and reaches every method',
      () async {
        await permissions.allow(origin: 'o', profileName: 'p');
        await permissions.clear(origin: 'o', profileName: 'p');
        await permissions.clearAll(profileName: 'p');
        await permissions.getAllowed(origin: 'o', profileName: 'p');
        reply = <dynamic>[];
        await permissions.getOrigins(profileName: 'p');

        expect(calls.length, 5);
        for (final call in calls) {
          expect(
            argsOf(call)['profileName'],
            'p',
            reason: '${call.method} dropped profileName',
          );
        }

        calls.clear();
        reply = true;
        await permissions.clearAll();
        expect(argsOf(calls.single).containsKey('profileName'), isTrue);
        expect(argsOf(calls.single)['profileName'], isNull);
      },
    );

    test('getAllowed keeps null distinct from false', () async {
      reply = null;
      expect(await permissions.getAllowed(origin: 'o'), isNull);

      reply = false;
      expect(await permissions.getAllowed(origin: 'o'), isFalse);

      reply = true;
      expect(await permissions.getAllowed(origin: 'o'), isTrue);
    });

    test('the mutating calls report false when nothing happened', () async {
      reply = false;
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
      reply = <dynamic>['https://a.example', 'https://b.example'];
      final origins = await permissions.getOrigins();

      expect(origins, isA<List<String>>());
      expect(origins, <String>['https://a.example', 'https://b.example']);
    });
  });
}
