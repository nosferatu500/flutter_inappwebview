import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/custom_path_handler.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the custom path handler's channel (§205), the twenty-second migrated to
/// Pigeon. Every message goes through the **real generated codec** on the real channel name, so it
/// covers the Dart half: the event reaches the app's `handle`, and its `WebResourceResponse` goes
/// back as the map Kotlin's `WebResourceResponseExt.fromMap` reads. The Kotlin half (wait, map →
/// `WebResourceResponse`, what the page sees) is pinned on the device by §204.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = CustomPathHandlerFlutterApi.pigeonChannelCodec;

  late AndroidCustomPathHandler handler;
  late _RecordingEvents events;

  String channel() =>
      'dev.flutter.pigeon.flutter_inappwebview_android.CustomPathHandlerFlutterApi'
      '.handle.${handler.toMap()['id']}';

  /// Delivers `handle(path)` and returns the raw reply: an encoded envelope when a handler is
  /// registered, null when none is (§183, §184).
  Future<ByteData?> deliver(String path) {
    final reply = Completer<ByteData?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel(),
          codec.encodeMessage(<Object?>[path]),
          reply.complete,
        );
    return reply.future;
  }

  /// The answer inside a success envelope, which is a one-element list.
  Object? answer(ByteData? reply) =>
      (codec.decodeMessage(reply) as List<Object?>).single;

  setUp(() {
    handler = AndroidCustomPathHandler(
      PlatformCustomPathHandlerCreationParams(
        PlatformPathHandlerCreationParams(path: '/custom/'),
      ),
    );
    events = _RecordingEvents();
    handler.eventHandler = events;
  });

  test(
    'handle reaches the app with the path, and answers its response map',
    () async {
      events.response = WebResourceResponse(
        contentType: 'text/plain',
        contentEncoding: 'ISO-8859-1',
        statusCode: 404,
        reasonPhrase: 'Not Here',
        headers: {'X-Probe': 'probe-value'},
        data: Uint8List.fromList([1, 2, 3]),
      );

      final reply = await deliver('page.html');

      expect(events.paths, ['page.html']);
      expect(answer(reply), events.response!.toMap());
    },
  );

  test(
    'a null response answers null, which Kotlin reads as "not handled"',
    () async {
      events.response = null;
      expect(answer(await deliver('declined.txt')), isNull);
      expect(events.paths, ['declined.txt']);
    },
  );

  test('dispose unregisters the handler for this id, then throws', () async {
    // Positive control first, so a null below cannot just mean a misspelt channel.
    expect(await deliver('before.txt'), isNotNull);
    // 🚨 Pinned, not endorsed (§205). `eventHandler` is `late final` and already set, so dispose's
    // `eventHandler = null` throws, as it did after `disposeChannel()` before. Nothing in the
    // plugin calls it: the public `PathHandler` has no `dispose`. The order is what matters here:
    // the unregister runs first, so it happens despite the throw.
    expect(handler.dispose, throwsA(isA<Error>()));
    expect(await deliver('after.txt'), isNull);
    expect(events.paths, ['before.txt']);
  });
}

class _RecordingEvents implements PlatformPathHandlerEvents {
  WebResourceResponse? response;
  final paths = <String>[];

  @override
  Future<WebResourceResponse?> handle(String path) async {
    paths.add(path);
    return response;
  }
}
