import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/web_message.g.dart';
// Imported directly: `main.dart` hides `InternalWebMessagePort`, the extension exposing a port's
// `onMessage` callback and its owning channel.
import 'package:flutter_inappwebview_android/src/web_message/web_message_port.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the two web-message channels (§165), in the shape §156 established.
///
/// These are the **first per-instance channels** migrated since the pilot, so the risk is new:
/// every host call and every event is addressed by a `messageChannelSuffix`, and a suffix that is
/// built differently at the two ends fails *silently* — the call is simply delivered to a channel
/// nobody listens on. Half this file exists to pin the suffix, including that two instances do not
/// share one.
///
/// The other half pins the payload split: `WebMessage.data` is `dynamic` and holds a `String` or a
/// `Uint8List` keyed by `type`, and the schema carries those as two separately typed fields.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = WebMessageChannelHostApi.pigeonChannelCodec;
  const chBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebMessageChannelHostApi';
  const chEventBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebMessageChannelFlutterApi';
  const lsBase =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebMessageListenerHostApi';

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final Map<String, List<Object?>?> received = {};
  final List<String> installed = [];

  void install(String channel) {
    installed.add(channel);
    messenger.setMockMessageHandler(channel, (message) async {
      received[channel] = message == null
          ? null
          : codec.decodeMessage(message) as List<Object?>;
      return codec.encodeMessage(<Object?>[true]);
    });
  }

  setUp(() {
    received.clear();
  });

  tearDown(() {
    for (final c in installed) {
      messenger.setMockMessageHandler(c, null);
    }
    installed.clear();
  });

  AndroidWebMessagePort portOf(AndroidWebMessageChannel c, int index) =>
      (index == 0 ? c.port1 : c.port2) as AndroidWebMessagePort;

  AndroidWebMessageChannel makeChannel(String id) => AndroidWebMessageChannel(
    AndroidWebMessageChannelCreationParams(
      id: id,
      port1: AndroidWebMessagePort(
        AndroidWebMessagePortCreationParams(index: 0),
      ),
      port2: AndroidWebMessagePort(
        AndroidWebMessagePortCreationParams(index: 1),
      ),
    ),
  );

  group('the per-instance suffix addresses the right channel', () {
    test('host calls carry the channel id as the suffix', () async {
      final channel = makeChannel('chan-A');
      // Ports are linked to their channel by the factory in production; done by hand here.
      portOf(channel, 0).webMessageChannel = channel;
      install('$chBase.close.chan-A');

      await portOf(channel, 0).close();

      expect(received['$chBase.close.chan-A'], isNotNull);
      expect((received['$chBase.close.chan-A'] as List<Object?>).first, 0);
    });

    test('two channels do not share a suffix', () async {
      final a = makeChannel('chan-A');
      final b = makeChannel('chan-B');
      portOf(a, 0).webMessageChannel = a;
      portOf(b, 0).webMessageChannel = b;
      install('$chBase.close.chan-A');
      install('$chBase.close.chan-B');

      await portOf(b, 0).close();

      // The whole point of the suffix. If both instances built the same channel name, A would see
      // B's call and this would pass for the wrong reason -- so B is asserted present *and* A
      // absent.
      expect(received.containsKey('$chBase.close.chan-B'), isTrue);
      expect(received.containsKey('$chBase.close.chan-A'), isFalse);
    });

    test('the port index selects the port, not the channel', () async {
      final channel = makeChannel('chan-A');
      portOf(channel, 0).webMessageChannel = channel;
      portOf(channel, 1).webMessageChannel = channel;
      install('$chBase.close.chan-A');

      await portOf(channel, 1).close();

      // Same channel, different first argument -- index 1, not 0.
      expect((received['$chBase.close.chan-A'] as List<Object?>).first, 1);
    });
  });

  group('the payload split', () {
    test(
      'a string message fills stringData and leaves the bytes null',
      () async {
        final channel = makeChannel('chan-A');
        portOf(channel, 0).webMessageChannel = channel;
        install('$chBase.postMessage.chan-A');

        await portOf(channel, 0).postMessage(WebMessage(data: 'hello'));

        final args = received['$chBase.postMessage.chan-A'] as List<Object?>;
        final message = args[1] as WebMessageData;
        expect(message.stringData, 'hello');
        expect(message.arrayBufferData, isNull);
        expect(message.type, WebMessageType.STRING.toNativeValue());
      },
    );

    test(
      'an array-buffer message fills the bytes and leaves stringData null',
      () async {
        final channel = makeChannel('chan-A');
        portOf(channel, 0).webMessageChannel = channel;
        install('$chBase.postMessage.chan-A');

        final bytes = Uint8List.fromList([1, 2, 3, 250]);
        await portOf(channel, 0).postMessage(
          WebMessage(data: bytes, type: WebMessageType.ARRAY_BUFFER),
        );

        final args = received['$chBase.postMessage.chan-A'] as List<Object?>;
        final message = args[1] as WebMessageData;
        // Crosses as real bytes, not as a stringified value -- the Kotlin side used to recover this
        // with `data as ByteArray` from an untyped field.
        expect(message.arrayBufferData, bytes);
        expect(message.stringData, isNull);
        expect(message.type, WebMessageType.ARRAY_BUFFER.toNativeValue());
      },
    );

    test('a string message with null data keeps its type', () async {
      final channel = makeChannel('chan-A');
      portOf(channel, 0).webMessageChannel = channel;
      install('$chBase.postMessage.chan-A');

      await portOf(channel, 0).postMessage(WebMessage());

      final message =
          (received['$chBase.postMessage.chan-A'] as List<Object?>)[1]
              as WebMessageData;
      // Both payload fields null: this is why `type` stays on the wire rather than being inferred
      // from which field is populated.
      expect(message.stringData, isNull);
      expect(message.arrayBufferData, isNull);
      expect(message.type, WebMessageType.STRING.toNativeValue());
    });

    test('ports cross with their index and owning channel id', () async {
      final channel = makeChannel('chan-A');
      final other = makeChannel('chan-B');
      portOf(channel, 0).webMessageChannel = channel;
      portOf(other, 1).webMessageChannel = other;
      install('$chBase.postMessage.chan-A');

      await portOf(
        channel,
        0,
      ).postMessage(WebMessage(data: 'with-ports', ports: [portOf(other, 1)]));

      final message =
          (received['$chBase.postMessage.chan-A'] as List<Object?>)[1]
              as WebMessageData;
      final port = message.ports!.single;
      // Asserted separately: a port carries an index and a channel id, and the transferred port
      // belongs to a *different* channel than the one the message is posted on.
      expect(port.index, 1);
      expect(port.webMessageChannelId, 'chan-B');
    });
  });

  group('inbound events', () {
    /// Delivers an event the way the platform would: encoded with the real codec, on the real
    /// suffixed event channel.
    Future<void> sendEvent(String channel, List<Object?> args) async {
      await messenger.handlePlatformMessage(
        channel,
        codec.encodeMessage(args),
        (_) {},
      );
    }

    test('onMessage reaches the port named by the index', () async {
      final channel = makeChannel('chan-A');
      WebMessage? got0;
      WebMessage? got1;
      portOf(channel, 0).onMessage = (m) => got0 = m;
      portOf(channel, 1).onMessage = (m) => got1 = m;

      await sendEvent('$chEventBase.onMessage.chan-A', <Object?>[
        1,
        WebMessageData(type: 0, stringData: 'to-port-2'),
      ]);

      // Index 1 is port2. Asserting port1 stayed null is the half that catches an off-by-one.
      expect(got1?.data, 'to-port-2');
      expect(got0, isNull);
    });

    test('onMessage rebuilds an array-buffer payload', () async {
      final channel = makeChannel('chan-A');
      WebMessage? got;
      portOf(channel, 0).onMessage = (m) => got = m;

      final bytes = Uint8List.fromList([9, 8, 7]);
      await sendEvent('$chEventBase.onMessage.chan-A', <Object?>[
        0,
        WebMessageData(type: 1, arrayBufferData: bytes),
      ]);

      expect(got?.type, WebMessageType.ARRAY_BUFFER);
      expect(got?.data, bytes);
    });

    test('onMessage on another channel id does not reach this one', () async {
      final channel = makeChannel('chan-A');
      var called = false;
      portOf(channel, 0).onMessage = (_) => called = true;

      await sendEvent('$chEventBase.onMessage.chan-B', <Object?>[
        0,
        WebMessageData(type: 0, stringData: 'for-B'),
      ]);

      expect(called, isFalse);
    });
  });

  test('the listener posts on its own suffixed channel', () async {
    final listener = AndroidWebMessageListener(
      AndroidWebMessageListenerCreationParams(
        jsObjectName: 'myObject',
        allowedOriginRules: {'*'},
      ),
    );
    final proxy = AndroidJavaScriptReplyProxy(
      PlatformJavaScriptReplyProxyCreationParams(webMessageListener: listener),
    );

    // The suffix is `<generated id>_<jsObjectName>` and the id is random, so it is read back from
    // the listener's own `toMap()` rather than hard-coded. Rebuilding it here from the same two
    // parts the implementation uses is the assertion: if the implementation changed the shape,
    // the call would land on a channel this test never installed and `received` would be empty.
    final suffix = '${listener.toMap()['id']}_myObject';
    final channelName = '$lsBase.postMessage.$suffix';
    install(channelName);

    await proxy.postMessage(WebMessage(data: 'reply'));

    final args = received[channelName] as List<Object?>;
    expect((args.single as WebMessageData).stringData, 'reply');
  });
}
