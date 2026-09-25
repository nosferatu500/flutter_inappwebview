import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/in_app_browser.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the in-app browser's own per-instance channel (§195), the eighteenth
/// migrated to Pigeon. Same shape and rationale as `pigeon_headless_webview_boundary_test.dart`:
/// every message goes through the **real generated codec** on the real generated channel names.
/// It cannot prove the Kotlin half agrees; both are generated from one schema and ship together.
///
/// It matters more here than for most channels, because one event has **no device coverage at
/// all**: `onMenuItemClicked` is raised by a tap on the browser Activity's native toolbar, which
/// nothing in the Dart API can press (§195). This file is the only thing that runs its Dart half.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = InAppBrowserHostApi.pigeonChannelCodec;
  const managerChannel = MethodChannel(
    'dev.nosferatu500.inappwebview/inappbrowser',
  );

  late AndroidInAppBrowser browser;
  late _RecordingEvents events;
  final sent = <String>[];
  final clicked = <int>[];

  String hostChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppBrowserHostApi'
      '.$method.${browser.id}';

  String flutterChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.InAppBrowserFlutterApi'
      '.$method.${browser.id}';

  /// Answers one HostApi method with [result], recording that it was called.
  /// Pigeon's success envelope is a one-element list.
  void stubHost(String method, Object? result) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel(method), (message) async {
          sent.add(method);
          return codec.encodeMessage(<Object?>[result]);
        });
  }

  /// Delivers an event and returns the raw reply: an encoded envelope when a handler is
  /// registered, null when none is (§183, §184).
  Future<ByteData?> deliver(String method, List<Object?> args) {
    final reply = Completer<ByteData?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          flutterChannel(method),
          codec.encodeMessage(args),
          reply.complete,
        );
    return reply.future;
  }

  setUp(() async {
    sent.clear();
    clicked.clear();
    // `open` still travels on the manager's hand-written channel and is not part of this
    // migration; stubbing it is what lets `openUrlRequest` complete and wire the Pigeon APIs up.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(managerChannel, (call) async => null);

    browser = AndroidInAppBrowser(AndroidInAppBrowserCreationParams());
    events = _RecordingEvents();
    browser.eventHandler = events;
    // Two items, so a wrong id reaching the wrong item is distinguishable.
    for (final id in [3, 8]) {
      browser.addMenuItem(
        InAppBrowserMenuItem(
          id: id,
          title: 'Item $id',
          onClick: () => clicked.add(id),
        ),
      );
    }
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri('https://example.com')),
    );
  });

  tearDown(() {
    for (final m in ['show', 'hide', 'close', 'isHidden']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostChannel(m), null);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(managerChannel, null);
  });

  group(
    'Dart -> Kotlin (HostApi), on the channel suffixed by the browser id',
    () {
      test('show, hide and close each reach their own method', () async {
        for (final m in ['show', 'hide', 'close']) {
          stubHost(m, true);
        }
        await browser.show();
        await browser.hide();
        await browser.close();
        expect(sent, ['show', 'hide', 'close']);
      });

      test('isHidden returns what the platform answered, both ways', () async {
        stubHost('isHidden', true);
        expect(await browser.isHidden(), isTrue);
        stubHost('isHidden', false);
        expect(await browser.isHidden(), isFalse);
      });
    },
  );

  group('Kotlin -> Dart (FlutterApi events)', () {
    test('onBrowserCreated reaches the event handler', () async {
      expect(await deliver('onBrowserCreated', <Object?>[]), isNotNull);
      expect(events.created, 1);
    });

    test('onMenuItemClicked runs the matching item and no other', () async {
      // Both ids, in the opposite order to insertion. Delivering only one let a mutant that always
      // ran "the first item" pass, because the item map is a HashMap and its first key happened to
      // be the delivered one (§195).
      await deliver('onMenuItemClicked', <Object?>[8]);
      await deliver('onMenuItemClicked', <Object?>[3]);
      expect(clicked, [8, 3]);
    });

    test('onMenuItemClicked with an unknown id runs nothing', () async {
      await deliver('onMenuItemClicked', <Object?>[42]);
      expect(clicked, isEmpty);
    });

    test('onExit closes the browser and then tells the handler', () async {
      expect(browser.isOpened(), isTrue);
      await deliver('onExit', <Object?>[]);
      expect(browser.isOpened(), isFalse);
      expect(browser.webViewController, isNull);
      expect(
        events.exited,
        1,
        reason:
            'captured before dispose() nulls the event handler, then called',
      );
    });
  });

  group('after onExit', () {
    test('the event handlers for this suffix are unregistered', () async {
      // Positive control first: without it, a null below could just mean the channel name is
      // wrong.
      expect(await deliver('onBrowserCreated', <Object?>[]), isNotNull);

      await deliver('onExit', <Object?>[]);

      expect(await deliver('onBrowserCreated', <Object?>[]), isNull);
      expect(await deliver('onMenuItemClicked', <Object?>[3]), isNull);
      expect(clicked, isEmpty);
    });
  });
}

class _RecordingEvents extends PlatformInAppBrowserEvents {
  var created = 0;
  var exited = 0;

  @override
  void onBrowserCreated() => created++;

  @override
  void onExit() => exited++;
}
