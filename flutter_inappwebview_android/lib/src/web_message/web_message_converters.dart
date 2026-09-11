import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../pigeons/web_message.g.dart';
// Imported directly rather than through `main.dart`, which hides `InternalWebMessagePort` —
// the extension that exposes a port's owning channel.
import 'web_message_port.dart';

/// Conversions between the public `WebMessage` and the Pigeon transport type (§165).
///
/// Shared by both web-message channels, which is also why they are one schema: Pigeon emits
/// unprefixed class names into a single Kotlin package, so two schemas could not both declare a
/// `WebMessageData`.
///
/// Not exported from `web_message/main.dart` — this is transport glue, not API.
/// Converts a public [WebMessage] into its wire form.
///
/// `WebMessage.data` is `dynamic` and holds either a `String` or a `Uint8List`, keyed by `type`;
/// the schema splits those into two typed fields so the bytes can cross as a real `ByteArray`
/// rather than an untyped value the Kotlin side casts. The public type's own constructor already
/// asserts that pairing, so this reads the field that `type` says is populated rather than
/// sniffing the value.
WebMessageData webMessageToData(WebMessage message) {
  final isArrayBuffer = message.type == WebMessageType.ARRAY_BUFFER;
  final data = message.data;
  return WebMessageData(
    // `toNativeValue()` is `int?` because `WebMessageType` is an open `_internal(int)` class; both
    // declared constants carry a value, so the fallback is unreachable and STRING (0) is the
    // documented default of the public constructor.
    type: message.type.toNativeValue() ?? 0,
    stringData: isArrayBuffer ? null : data as String?,
    arrayBufferData: isArrayBuffer ? data as Uint8List? : null,
    ports: message.ports
        ?.map(
          (port) => WebMessagePortData(
            index: (port as AndroidWebMessagePort).params.index,
            webMessageChannelId: port.webMessageChannel.params.id,
          ),
        )
        .toList(),
  );
}

/// Rebuilds a public [WebMessage] from an inbound event.
///
/// `ports` is never carried inbound — the platform side has no ports to report on an incoming
/// message — so the rebuilt message has none, which is what the old map-based path produced too.
WebMessage webMessageFromData(WebMessageData data) {
  final type =
      WebMessageType.fromNativeValue(data.type) ?? WebMessageType.STRING;
  return WebMessage(
    data: type == WebMessageType.ARRAY_BUFFER
        ? data.arrayBufferData
        : data.stringData,
    type: type,
  );
}
