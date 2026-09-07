import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards that a registered [ServiceWorkerClient] keeps receiving `shouldInterceptRequest` after
/// another [AndroidServiceWorkerController] is constructed.
///
/// Every controller attaches a method-call handler to the same `const MethodChannel`, and
/// `setMethodCallHandler` is last-writer-wins per channel *name* — so the most recently constructed
/// controller owns every incoming call. `createPlatformServiceWorkerController` returns a new
/// controller on each call, which is exactly what the public `ServiceWorkerController()` constructor
/// does, so a second construction anywhere in an app used to silently orphan the first controller's
/// client: `shouldInterceptRequest` stopped firing, service worker requests went unintercepted,
/// and nothing reported an error.
///
/// The fix is that `_serviceWorkerClient` is `static`, matching the platform — there is one
/// process-wide `ServiceWorkerControllerCompat` and one native client registration for it.
///
/// **These tests share that static field**, so `tearDown` clears it. A leaked client would make a
/// later test pass for the wrong reason.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName =
      'dev.nosferatu500.inappwebview/inappwebview_serviceworkercontroller';
  const channel = MethodChannel(channelName);
  const codec = StandardMethodCodec();

  final List<MethodCall> outgoing = <MethodCall>[];

  Future<void> sendIncomingRequest(String url) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channelName,
          codec.encodeMethodCall(
            MethodCall('shouldInterceptRequest', <String, dynamic>{
              'url': url,
              'method': 'GET',
              'headers': <String, String>{},
              'isForMainFrame': false,
              'hasGesture': false,
              'isRedirect': false,
            }),
          ),
          (_) {},
        );
  }

  setUp(() {
    outgoing.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          outgoing.add(call);
          return null;
        });
  });

  tearDown(() async {
    await AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    ).setServiceWorkerClient(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  AndroidServiceWorkerController newController() =>
      AndroidServiceWorkerController(
        const PlatformServiceWorkerControllerCreationParams(),
      );

  group('the registered client survives another controller', () {
    test(
      'shouldInterceptRequest still fires after a second construction',
      () async {
        final first = newController();
        var fired = 0;
        await first.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              fired++;
              return null;
            },
          ),
        );

        await sendIncomingRequest('https://example.com/a.js');
        expect(fired, 1, reason: 'baseline: the only controller receives it');

        // Anything at all that builds a second controller -- `ServiceWorkerController()` routes here.
        newController();

        await sendIncomingRequest('https://example.com/b.js');
        expect(
          fired,
          2,
          reason:
              'the client registered on `first` must keep receiving after another '
              'controller takes over the shared channel',
        );
      },
    );

    test(
      'the request reaches the client intact through the new owner',
      () async {
        final first = newController();
        WebResourceRequest? seen;
        await first.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              seen = request;
              return null;
            },
          ),
        );

        newController();
        await sendIncomingRequest('https://example.com/sw.js');

        expect(seen, isNotNull);
        expect(seen!.url.toString(), 'https://example.com/sw.js');
        expect(seen!.method, 'GET');
      },
    );
  });

  group('the client is process-wide, and reads as such', () {
    test('every controller reports the same registered client', () async {
      final first = newController();
      final client = ServiceWorkerClient(
        shouldInterceptRequest: (request) async => null,
      );
      await first.setServiceWorkerClient(client);

      final second = newController();

      expect(second.serviceWorkerClient, same(client));
      expect(first.serviceWorkerClient, same(client));
    });

    test('clearing through one controller clears it for all', () async {
      final first = newController();
      await first.setServiceWorkerClient(
        ServiceWorkerClient(shouldInterceptRequest: (request) async => null),
      );

      final second = newController();
      await second.setServiceWorkerClient(null);

      expect(first.serviceWorkerClient, isNull);
    });

    test('a cleared client stops receiving requests', () async {
      final first = newController();
      var fired = 0;
      await first.setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            fired++;
            return null;
          },
        ),
      );
      await sendIncomingRequest('https://example.com/a.js');
      expect(fired, 1);

      await first.setServiceWorkerClient(null);
      await sendIncomingRequest('https://example.com/b.js');
      expect(fired, 1, reason: 'no further calls after clearing');
    });
  });

  group('the native registration is still told', () {
    // Independent of where the client is held: `setServiceWorkerClient` must keep telling the
    // Kotlin whether a client exists, or the native side never installs its own callback.
    test('setServiceWorkerClient sends isNull both ways', () async {
      final controller = newController();

      await controller.setServiceWorkerClient(
        ServiceWorkerClient(shouldInterceptRequest: (request) async => null),
      );
      expect(outgoing.last.method, 'setServiceWorkerClient');
      expect(
        (outgoing.last.arguments as Map<Object?, Object?>)['isNull'],
        false,
      );

      await controller.setServiceWorkerClient(null);
      expect(
        (outgoing.last.arguments as Map<Object?, Object?>)['isNull'],
        true,
      );
    });
  });
}
