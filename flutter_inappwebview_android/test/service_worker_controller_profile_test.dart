import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/service_worker.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument on the service-worker channel, and the deliberate exception to
/// it.
///
/// `ServiceWorkerChannelDelegate` treats a null `profileName` as "the default profile". A dropped
/// argument therefore fails silently: the settings call acts on the default profile's service
/// workers instead of the profile the caller named. (§185's device test measures that from the
/// other end; this pins which argument slot carries it.)
///
/// Since §186 the transport is Pigeon, so the profile is a **positional** argument — the last one of
/// every settings method — rather than a map key. What the tests assert is unchanged.
///
/// `setServiceWorkerClient` is the one method that must *not* carry it — the intercept event has no
/// profile identity, so a per-profile client could not be told apart in Dart. Asserted here so the
/// exception stays deliberate rather than becoming an oversight.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hostBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.ServiceWorkerHostApi';
  const codec = ServiceWorkerHostApi.pigeonChannelCodec;
  const methods = [
    'setServiceWorkerClient',
    'getAllowContentAccess',
    'getAllowFileAccess',
    'getBlockNetworkLoads',
    'getCacheMode',
    'getIncludeCookiesOnShouldInterceptRequestEnabled',
    'setAllowContentAccess',
    'setAllowFileAccess',
    'setBlockNetworkLoads',
    'setCacheMode',
    'setIncludeCookiesOnShouldInterceptRequestEnabled',
  ];

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AndroidServiceWorkerController controller;

  /// Every host call, as (method, positional arguments).
  final List<(String, List<Object?>)> calls = <(String, List<Object?>)>[];

  setUp(() {
    calls.clear();
    controller = AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    );
    for (final method in methods) {
      messenger.setMockMessageHandler('$hostBase.$method', (message) async {
        calls.add((method, codec.decodeMessage(message) as List<Object?>));
        // Each answer must match the generated return type, or the Dart side rejects it.
        final Object? answer = method == 'getCacheMode'
            ? CacheMode.LOAD_DEFAULT.toNativeValue()
            : true;
        return codec.encodeMessage(<Object?>[answer]);
      });
    }
  });

  tearDown(() {
    for (final method in methods) {
      messenger.setMockMessageHandler('$hostBase.$method', null);
    }
  });

  group('AndroidServiceWorkerController profileName', () {
    test('travels as the last argument, after the value', () async {
      await controller.setCacheMode(
        CacheMode.LOAD_NO_CACHE,
        profileName: 'signed_in',
      );

      final (method, args) = calls.single;
      expect(method, 'setCacheMode');
      expect(args, <Object?>[
        CacheMode.LOAD_NO_CACHE.toNativeValue(),
        'signed_in',
      ]);
    });

    test('is null when not given, which means the default profile', () async {
      await controller.getCacheMode();

      final (method, args) = calls.single;
      expect(method, 'getCacheMode');
      // Present and null — not absent. Pigeon always sends every positional argument.
      expect(args, <Object?>[null]);
    });

    test('reaches every settings method', () async {
      await controller.getAllowContentAccess(profileName: 'p');
      await controller.getAllowFileAccess(profileName: 'p');
      await controller.getBlockNetworkLoads(profileName: 'p');
      await controller.getCacheMode(profileName: 'p');
      await controller.setAllowContentAccess(true, profileName: 'p');
      await controller.setAllowFileAccess(true, profileName: 'p');
      await controller.setBlockNetworkLoads(true, profileName: 'p');
      await controller.setCacheMode(CacheMode.LOAD_DEFAULT, profileName: 'p');

      expect(calls.length, 8);
      for (final (method, args) in calls) {
        expect(args.last, 'p', reason: '$method dropped profileName');
      }
    });

    test('setServiceWorkerClient deliberately sends none', () async {
      await controller.setServiceWorkerClient(ServiceWorkerClient());

      final (method, args) = calls.single;
      expect(method, 'setServiceWorkerClient');
      expect(
        args,
        <Object?>[false],
        reason:
            'isNull only: the intercept event carries no profile identity, so the '
            'client is default-profile only by design',
      );
    });
  });
}
