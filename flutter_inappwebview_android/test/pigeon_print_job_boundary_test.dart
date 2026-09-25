import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/print_job.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the print-job channel's **event direction** (§184), which had none at any
/// level: §177 migrated it with host-half device coverage only, because `onComplete` fires when a
/// real print job finishes and no automated test can finish one (§176).
///
/// What is testable without a device is the Dart half: that an arriving `onComplete` reaches the
/// controller's callback through the private forwarder, and that `dispose` unregisters the handler.
///
/// "Unregistered" is observed through the **platform reply** — an encoded envelope from a registered
/// Pigeon handler, null from a channel with none. §183 measured two other assertions blind against a
/// delete-the-unregister mutant (an outbound-mock check, and "the callback stayed silent"); the reply
/// depends on registration alone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const id = 'print-job-boundary-test';
  const codec = PrintJobControllerHostApi.pigeonChannelCodec;
  const onCompleteChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.PrintJobControllerFlutterApi'
      '.onComplete.$id';
  const hostDispose =
      'dev.flutter.pigeon.flutter_inappwebview_android.PrintJobControllerHostApi'
      '.dispose.$id';

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late AndroidPrintJobController controller;

  /// Delivers `onComplete` and returns the raw platform reply.
  Future<ByteData?> deliverOnComplete(bool completed, String? error) {
    final reply = Completer<ByteData?>();
    messenger.handlePlatformMessage(
      onCompleteChannel,
      codec.encodeMessage(<Object?>[completed, error]),
      reply.complete,
    );
    return reply.future;
  }

  setUp(() {
    controller = AndroidPrintJobController(
      AndroidPrintJobControllerCreationParams(id: id),
    );
    // `dispose` awaits the host call before unregistering, so the host side has to answer.
    messenger.setMockMessageHandler(
      hostDispose,
      (_) async => codec.encodeMessage(<Object?>[true]),
    );
  });

  tearDown(() {
    messenger.setMockMessageHandler(hostDispose, null);
  });

  test(
    'onComplete reaches the controller callback with both arguments',
    () async {
      bool? completed;
      String? error;
      controller.onComplete = (c, e) async {
        completed = c;
        error = e;
      };

      await deliverOnComplete(false, 'boom');

      // `false` and a non-null error on purpose: a forwarder that dropped or swapped the arguments
      // would not produce this pair by accident.
      expect(completed, isFalse);
      expect(error, 'boom');
    },
  );

  test('dispose unregisters the event handler for this job id', () async {
    // Positive control first, so a null below cannot just mean a misspelt channel.
    expect(await deliverOnComplete(true, null), isNotNull);
    await controller.dispose();
    expect(await deliverOnComplete(true, null), isNull);
  });
}
