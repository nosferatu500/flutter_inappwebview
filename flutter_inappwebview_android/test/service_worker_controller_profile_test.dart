import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `profileName` argument key on the service-worker channel, and the deliberate
/// exception to it.
///
/// `ServiceWorkerChannelDelegate` reads it with `call.argument<String>("profileName")` and treats
/// null as "the default profile". A renamed or dropped key therefore fails silently: the settings
/// call acts on the default profile's service workers instead of the profile the caller named.
///
/// `setServiceWorkerClient` is the one method that must *not* carry it — the intercept event has no
/// profile identity, so a per-profile client could not be told apart in Dart. Asserted here so the
/// exception stays deliberate rather than becoming an oversight.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappwebview_serviceworkercontroller',
  );

  late AndroidServiceWorkerController controller;
  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    controller = AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          if (call.method == 'getCacheMode') {
            return CacheMode.LOAD_DEFAULT.toNativeValue();
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<Object?, Object?> argsOf(MethodCall call) =>
      call.arguments as Map<Object?, Object?>;

  group('AndroidServiceWorkerController profileName', () {
    test('is sent under the key the Android side reads', () async {
      await controller.setCacheMode(
        CacheMode.LOAD_NO_CACHE,
        profileName: 'signed_in',
      );

      expect(calls.single.method, 'setCacheMode');
      expect(argsOf(calls.single)['profileName'], 'signed_in');
      expect(
        argsOf(calls.single)['mode'],
        CacheMode.LOAD_NO_CACHE.toNativeValue(),
      );
    });

    test('is null when not given, which means the default profile', () async {
      await controller.getCacheMode();

      expect(argsOf(calls.single).containsKey('profileName'), isTrue);
      expect(argsOf(calls.single)['profileName'], isNull);
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
      for (final call in calls) {
        expect(
          argsOf(call)['profileName'],
          'p',
          reason: '${call.method} dropped profileName',
        );
      }
    });

    test('setServiceWorkerClient deliberately sends none', () async {
      await controller.setServiceWorkerClient(ServiceWorkerClient());

      expect(calls.single.method, 'setServiceWorkerClient');
      expect(argsOf(calls.single)['isNull'], isFalse);
      expect(
        argsOf(calls.single).containsKey('profileName'),
        isFalse,
        reason:
            'the intercept event carries no profile identity, so the client is '
            'default-profile only by design',
      );
    });
  });
}
