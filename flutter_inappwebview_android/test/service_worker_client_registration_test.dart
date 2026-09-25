import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/service_worker.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards that a registered [ServiceWorkerClient] keeps receiving `shouldInterceptRequest` after
/// another [AndroidServiceWorkerController] is constructed.
///
/// Every controller registers the event handler for the same channel, and registration is
/// last-writer-wins per channel *name* — so the most recently constructed controller owns every
/// incoming event. `createPlatformServiceWorkerController` returns a new controller on each call,
/// which is exactly what the public `ServiceWorkerController()` constructor does, so a second
/// construction anywhere in an app used to silently orphan the first controller's client:
/// `shouldInterceptRequest` stopped firing, service worker requests went unintercepted, and nothing
/// reported an error.
///
/// The fix is that `_serviceWorkerClient` is `static`, matching the platform — there is one
/// process-wide `ServiceWorkerControllerCompat` and one native client registration for it.
///
/// Transport is Pigeon since §186: events arrive on the generated `ServiceWorkerFlutterApi` channel
/// and the reply carries the app's response back. The assertions are unchanged from the
/// hand-written channel; only how they reach it is new.
///
/// **These tests share that static field**, so `tearDown` clears it. A leaked client would make a
/// later test pass for the wrong reason.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hostBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.ServiceWorkerHostApi';
  const eventChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.ServiceWorkerFlutterApi'
      '.shouldInterceptRequest';
  const codec = ServiceWorkerFlutterApi.pigeonChannelCodec;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Every `setServiceWorkerClient` the controller sent, as its single argument (`isNull`).
  final List<Object?> sentIsNull = <Object?>[];

  /// Delivers one `shouldInterceptRequest` event and returns the raw reply.
  Future<ByteData?> sendIncomingRequest(String url) {
    final reply = Completer<ByteData?>();
    messenger.handlePlatformMessage(
      eventChannel,
      codec.encodeMessage(<Object?>[
        WebResourceRequestData(
          url: url,
          headers: <String, String>{},
          isRedirect: false,
          hasGesture: false,
          isForMainFrame: false,
          method: 'GET',
        ),
      ]),
      reply.complete,
    );
    return reply.future;
  }

  setUp(() {
    sentIsNull.clear();
    messenger.setMockMessageHandler('$hostBase.setServiceWorkerClient', (
      message,
    ) async {
      sentIsNull.add((codec.decodeMessage(message) as List<Object?>).single);
      return codec.encodeMessage(<Object?>[true]);
    });
  });

  tearDown(() async {
    await AndroidServiceWorkerController(
      const PlatformServiceWorkerControllerCreationParams(),
    ).setServiceWorkerClient(null);
    messenger.setMockMessageHandler('$hostBase.setServiceWorkerClient', null);
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

  group('the answer crosses back', () {
    test('a returned response reaches the platform field for field', () async {
      // The Dart half of the direction §185's device test covers end to end. Distinct values in
      // every field, so a transposed or dropped one cannot pass.
      final first = newController();
      await first.setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async => WebResourceResponse(
            contentType: 'text/plain',
            contentEncoding: 'utf-8',
            statusCode: 203,
            reasonPhrase: 'Non-Authoritative Information',
            headers: {'X-Probe': 'dart'},
            data: Uint8List.fromList([1, 2, 3]),
            cookies: ['a=1'],
          ),
        ),
      );

      final reply = await sendIncomingRequest('https://example.com/p.txt');
      final envelope = codec.decodeMessage(reply) as List<Object?>;
      final response = envelope.single as WebResourceResponseData;

      expect(response.contentType, 'text/plain');
      expect(response.contentEncoding, 'utf-8');
      expect(response.statusCode, 203);
      expect(response.reasonPhrase, 'Non-Authoritative Information');
      expect(response.headers, {'X-Probe': 'dart'});
      expect(response.data, Uint8List.fromList([1, 2, 3]));
      expect(response.cookies, ['a=1']);
    });

    test('no client means a null answer, not an error', () async {
      // Null is "not handled" on the platform side: the request goes to the network. An error
      // envelope would take the same path there, but would also be a lie about what happened.
      newController();
      final reply = await sendIncomingRequest('https://example.com/p.txt');
      expect(codec.decodeMessage(reply), <Object?>[null]);
    });
  });

  group('the event handler lifecycle', () {
    test('disposing a controller leaves the event handler registered', () async {
      // The deliberate exception to §184's rule. Every other migrated channel unregisters its
      // event handler in `dispose`; this one must not, because the handler and the client are
      // process-wide and one controller's dispose would silently cut off every other one.
      // Observed through the reply (§183): non-null means a handler answered.
      final controller = newController();
      controller.dispose();
      expect(await sendIncomingRequest('https://example.com/a.js'), isNotNull);
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
      expect(sentIsNull.last, false);

      await controller.setServiceWorkerClient(null);
      expect(sentIsNull.last, true);
    });
  });
}
