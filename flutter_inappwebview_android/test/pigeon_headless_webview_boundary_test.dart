import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// `run()` is what wires the Pigeon APIs up, so the test drives the headless
// webview exactly the way an app does at runtime.
import 'package:flutter_inappwebview_android/src/in_app_webview/headless_in_app_webview.dart';
import 'package:flutter_inappwebview_android/src/pigeons/headless_webview.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart'
    show PullToRefreshSettings;
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-instance headless-webview channel (§180), the
/// fourteenth migrated to Pigeon. Same shape and same rationale as
/// `pigeon_find_interaction_boundary_test.dart`: every message goes through the
/// **real generated codec** on the real generated channel names, so it covers
/// the Dart half of the wire plus the hand-written conversion at the boundary.
/// It cannot prove the Kotlin half agrees — both halves cannot run in one
/// process — but both are generated from one schema and ship together.
///
/// 🚨 WHY THE `Size` MAPPING IS PINNED HERE AND NOT LEFT TO THE DEVICE GROUP.
/// A symmetric `width`/`height` transposition — swapping both directions of the
/// conversion at once — is the one mutation a round-trip assertion cannot see,
/// and `set and get custom size` is exactly such an assertion. It survives that
/// test today only because of two accidents, **both of which are outside this
/// schema**:
///
///   1. `initialSize` does not travel on this channel at all. It rides the
///      manager's `run`, which is still a hand-written `MethodChannel`, so it is
///      applied unswapped and only the read-back is swapped — which breaks the
///      symmetry and fails the assertion.
///   2. A `-1` axis is resolved to a real, asymmetric screen size *natively*
///      before it crosses back, so the sentinel is not swap-identical by the
///      time Dart sees it.
///
/// Measured, not reasoned: the swap mutant failed `set and get custom size`
/// with `Size(800.0, 600.0)` and the `-1` test with `845.33` against a
/// `412.43` bound. **Accident 1 disappeared in §203**, when the manager
/// migrated and `initialSize` became a [Size2DData] through the same Kotlin
/// converters. These tests do not depend on which channel carries
/// `initialSize`, so they keep holding; `run sends initialSize ...` below pins
/// the new one.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = HeadlessWebViewHostApi.pigeonChannelCodec;
  // The manager's `run`, Pigeon since §203. Answering it is what lets `run()`
  // complete.
  const managerRun =
      'dev.flutter.pigeon.flutter_inappwebview_android.HeadlessInAppWebViewManagerHostApi.run';

  late AndroidHeadlessInAppWebView headlessWebView;
  late String suffix;
  final sent = <String, Object?>{};
  final received = <String, Object?>{};

  String hostChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.HeadlessWebViewHostApi'
      '.$method.$suffix';

  String flutterChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.HeadlessWebViewFlutterApi'
      '.$method.$suffix';

  /// Answers one HostApi method with [result], recording what Dart sent.
  /// Pigeon's success envelope is a one-element list.
  void stubHost(String method, Object? result) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel(method), (message) async {
          sent[method] = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[result]);
        });
  }

  setUp(() async {
    sent.clear();
    received.clear();
    // Stubbing the manager's `run` is what lets `run()` complete and wire up
    // the per-instance Pigeon APIs. What it was sent is kept for the `run`
    // group below.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(managerRun, (message) async {
          sent['run'] = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[true]);
        });

    headlessWebView = AndroidHeadlessInAppWebView(
      AndroidHeadlessInAppWebViewCreationParams(
        initialSize: const Size(600, 800),
        initialFile: 'assets/page.html',
        windowId: 7,
        onWebViewCreated: (controller) {
          received['controller'] = controller;
        },
      ),
    );
    await headlessWebView.run();
    suffix = headlessWebView.id;
  });

  tearDown(() {
    for (final m in ['dispose', 'setSize', 'getSize']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostChannel(m), null);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(managerRun, null);
  });

  group('the manager\'s run (§203)', () {
    test('sends the id, the creation map, and initialSize typed', () {
      final args = sent['run'] as List<Object?>;
      expect(args[0], headlessWebView.id);

      final params = args[1] as Map<Object?, Object?>;
      expect(params['initialFile'], 'assets/page.html');
      expect(params['windowId'], 7);
      expect(params['initialSettings'], isA<Map<Object?, Object?>>());
      expect(
        params['pullToRefreshSettings'],
        PullToRefreshSettings(enabled: false).toMap(),
      );
      // It left the map: only the typed argument carries it now.
      expect(params.containsKey('initialSize'), isFalse);

      // Asymmetric, as setSize's test is: `Size(600, 600)` would pass a swap.
      final size = args[2] as Size2DData;
      expect(size.width, 600);
      expect(size.height, 800);
    });
  });

  group('Dart -> Kotlin (HostApi)', () {
    test('setSize puts width and height on the wire, in that order', () async {
      stubHost('setSize', true);
      await headlessWebView.setSize(const Size(600, 800));

      // Asserted as an asymmetric pair on purpose: `Size(600, 600)` here would
      // pass under a transposed conversion and prove nothing.
      final args = sent['setSize'] as List<Object?>;
      final size = args.single as Size2DData;
      expect(size.width, 600);
      expect(size.height, 800);
    });

    test('setSize sends the -1 sentinel through untouched', () async {
      // -1 means "match the screen on this axis" and is resolved natively, so
      // Dart must not substitute anything for it on the way out.
      stubHost('setSize', true);
      await headlessWebView.setSize(const Size(-1, -1));

      final size = (sent['setSize'] as List<Object?>).single as Size2DData;
      expect(size.width, -1);
      expect(size.height, -1);
    });
  });

  group('Kotlin -> Dart (replies, and the hand-written conversion)', () {
    test('getSize maps width to width and height to height', () async {
      stubHost('getSize', Size2DData(width: 600, height: 800));

      final size = await headlessWebView.getSize();

      expect(size, isNotNull);
      expect(size!.width, 600);
      expect(size.height, 800);
    });

    test('a null size stays null rather than becoming Size.zero', () async {
      // The platform answers null once the webview has gone away. Turning that
      // into a zero size would be a silent lie about a live webview.
      stubHost('getSize', null);
      expect(await headlessWebView.getSize(), isNull);
    });
  });

  group('Kotlin -> Dart (FlutterApi event)', () {
    test('onWebViewCreated reaches the creation-params callback', () async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            flutterChannel('onWebViewCreated'),
            codec.encodeMessage(<Object?>[]),
            (_) {},
          );

      // The event carries no payload; what it delivers is the controller, and
      // delivering the wrong one would make every `onWebViewCreated` callback
      // in the plugin talk to a different webview.
      expect(received['controller'], isNotNull);
      expect(
        identical(received['controller'], headlessWebView.webViewController),
        isTrue,
      );
    });
  });

  group('after dispose', () {
    /// Delivers `onWebViewCreated` and returns the raw reply. A registered
    /// Pigeon handler always answers with an encoded envelope; a channel with
    /// no handler answers null. That is the registration itself, observed
    /// directly.
    Future<ByteData?> deliverOnWebViewCreated() {
      final reply = Completer<ByteData?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            flutterChannel('onWebViewCreated'),
            codec.encodeMessage(<Object?>[]),
            reply.complete,
          );
      return reply.future;
    }

    test('the event handler for this suffix is unregistered', () async {
      // Positive control first: without it, a null below could just mean the
      // channel name is wrong.
      expect(await deliverOnWebViewCreated(), isNotNull);

      stubHost('dispose', true);
      await headlessWebView.dispose();

      // A live handler here would outlive the webview it forwards to.
      //
      // 🚨 Two tempting assertions here measure nothing (§183: both pass
      // against a mutant that deletes the unregister; this one fails it):
      //   * `checkMockMessageHandler(<this channel>, null)` — inspects the
      //     *outbound* mock table, while `FlutterApi.setUp` registers an
      //     *inbound* handler, so it is true whatever `dispose` does. This
      //     test shipped that way in §180.
      //   * "the callback stays silent" — `_onWebViewCreated` also checks
      //     `_webViewController != null`, which `dispose` nulls, so a
      //     still-registered handler is silent too.
      // The reply is the one signal that depends on registration alone.
      expect(await deliverOnWebViewCreated(), isNull);
    });

    test('further calls no-op instead of throwing', () async {
      stubHost('dispose', true);
      await headlessWebView.dispose();

      // `_running` is false and `_hostApi` is null, matching the previous
      // behaviour where `channel` was null and `channel?.invokeMethod` silently
      // did nothing.
      await headlessWebView.setSize(const Size(10, 10));
      expect(await headlessWebView.getSize(), isNull);
      await headlessWebView.dispose();
    });
  });
}
