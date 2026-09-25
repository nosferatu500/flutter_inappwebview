import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// `init` lives on the internal extension, so the test drives the controller exactly the way
// `InAppWebView`, `HeadlessInAppWebView` and `InAppBrowser` do at runtime.
import 'package:flutter_inappwebview_android/src/pull_to_refresh/pull_to_refresh_controller.dart';
import 'package:flutter_inappwebview_android/src/pigeons/pull_to_refresh.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runtime coverage for the per-instance pull-to-refresh channel (§182), the fifteenth migrated to
/// Pigeon. Same shape and rationale as `pigeon_find_interaction_boundary_test.dart`: every message
/// goes through the **real generated codec** on the real generated channel names, covering the Dart
/// half of the wire and the hand-written conversion. It cannot prove the Kotlin half agrees.
///
/// 🚨 **This file is the only automated coverage the event direction has at all.** `onRefresh` needs
/// a real drag on a platform view, so the device group (§181) cannot fire it, and §182's mutant with
/// a broken Kotlin FlutterApi suffix passed the whole device group. What is testable here is the Dart
/// half: that an arriving `onRefresh` reaches the app's callback through the private forwarder, and
/// that `dispose` stops it arriving.
///
/// 🚨 **"Unregistered" is asserted by delivering the event, never by inspecting handlers.** §180's
/// headless test asserted `checkMockMessageHandler(<flutter channel>, null)`, which inspects the
/// *outbound* mock table — while `FlutterApi.setUp` registers an *inbound* handler. So it is true
/// whatever `dispose` does, and §182 measured it passing with the unregister deleted. Here the event
/// is sent after `dispose` and the callback must stay silent; §182 measured that failing when *this*
/// controller's unregister is deleted.
///
/// ⚠️ **That silence technique is only valid because nothing else here gates the callback.**
/// `onRefresh` forwards straight to `params.onRefresh`, which `dispose` leaves alone. It does **not**
/// transfer to headless: there `_onWebViewCreated` also requires `_webViewController != null`, which
/// `dispose` nulls, so a still-registered handler is silent too — §183 measured the silence technique
/// surviving the headless mutant. The signal that depends on registration alone is the platform
/// reply: an encoded envelope from a registered handler, null from none. See the headless test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const suffix = 'boundary-test';
  const codec = PullToRefreshHostApi.pigeonChannelCodec;

  String hostChannel(String method) =>
      'dev.flutter.pigeon.flutter_inappwebview_android.PullToRefreshHostApi'
      '.$method.$suffix';

  const onRefreshChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.PullToRefreshFlutterApi'
      '.onRefresh.$suffix';

  const hostMethods = [
    'setEnabled',
    'isEnabled',
    'setRefreshing',
    'isRefreshing',
    'setColor',
    'setBackgroundColor',
    'setDistanceToTriggerSync',
    'setSlingshotDistance',
    'getDefaultSlingshotDistance',
    'setSize',
  ];

  late AndroidPullToRefreshController controller;
  late int refreshCount;
  final sent = <String, Object?>{};

  /// Answers one HostApi method with [result], recording what Dart sent.
  void stubHost(String method, Object? result) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(hostChannel(method), (message) async {
          sent[method] = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[result]);
        });
  }

  Future<void> deliverOnRefresh() => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .handlePlatformMessage(
        onRefreshChannel,
        codec.encodeMessage(<Object?>[]),
        (_) {},
      );

  setUp(() {
    sent.clear();
    refreshCount = 0;
    controller = AndroidPullToRefreshController(
      AndroidPullToRefreshControllerCreationParams(
        onRefresh: () {
          refreshCount++;
        },
      ),
    );
    controller.init(suffix);
  });

  tearDown(() {
    for (final m in hostMethods) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(hostChannel(m), null);
    }
    // Leave no handler behind for the next test's fresh controller on the same suffix.
    controller.dispose();
  });

  group('Dart -> Kotlin (HostApi)', () {
    test('setColor sends the #AARRGGBB string Color.parseColor takes', () async {
      stubHost('setColor', true);
      await controller.setColor(const Color(0x80FF0000));
      // Alpha first. `Color.parseColor` reads an 8-digit string as AARRGGBB, so an RRGGBBAA
      // encoding would silently produce a different colour, not an error.
      expect(sent['setColor'], <Object?>['#80ff0000']);
    });

    test('setIndicatorSize sends the native size constant', () async {
      stubHost('setSize', true);
      await controller.setIndicatorSize(PullToRefreshSize.LARGE);
      expect(sent['setSize'], <Object?>[0]);
      await controller.setIndicatorSize(PullToRefreshSize.DEFAULT);
      expect(sent['setSize'], <Object?>[1]);
    });

    test(
      'beginRefreshing and endRefreshing both go through setRefreshing',
      () async {
        stubHost('setRefreshing', true);
        await controller.beginRefreshing();
        expect(sent['setRefreshing'], <Object?>[true]);
        await controller.endRefreshing();
        expect(sent['setRefreshing'], <Object?>[false]);
      },
    );

    test('the two distances cross unchanged', () async {
      stubHost('setDistanceToTriggerSync', true);
      stubHost('setSlingshotDistance', true);
      await controller.setDistanceToTriggerSync(150);
      await controller.setSlingshotDistance(-1);
      expect(sent['setDistanceToTriggerSync'], <Object?>[150]);
      // -1 is `DEFAULT_SLINGSHOT_DISTANCE`'s sentinel (§181); Dart must not clamp it.
      expect(sent['setSlingshotDistance'], <Object?>[-1]);
    });
  });

  group('Kotlin -> Dart (replies)', () {
    test(
      'getDefaultSlingshotDistance returns the platform value, -1 included',
      () async {
        stubHost('getDefaultSlingshotDistance', -1);
        expect(await controller.getDefaultSlingshotDistance(), -1);
      },
    );

    test('isEnabled and isRefreshing return the platform answer', () async {
      stubHost('isEnabled', true);
      stubHost('isRefreshing', true);
      expect(await controller.isEnabled(), isTrue);
      expect(await controller.isRefreshing(), isTrue);
    });
  });

  group('Kotlin -> Dart (FlutterApi event)', () {
    test('onRefresh reaches the creation-params callback', () async {
      await deliverOnRefresh();
      expect(refreshCount, 1);
    });

    test('dispose stops onRefresh from arriving', () async {
      controller.dispose();
      await deliverOnRefresh();
      expect(refreshCount, 0);
    });

    test('a keep-alive dispose leaves onRefresh arriving', () async {
      // Mirrors `disposeChannel(removeMethodCallHandler: !isKeepAlive)`: the hand-written channel
      // kept its handler across a keep-alive dispose, so the widget's next attach finds it.
      controller.dispose(isKeepAlive: true);
      await deliverOnRefresh();
      expect(refreshCount, 1);
    });
  });

  group('an uninitialised or disposed controller', () {
    test('tolerates every call and answers the old fallbacks', () async {
      // `AndroidPullToRefreshController.static()` never calls init(), and a controller that is
      // never attached to a webview never does either. The hand-written channel was null there and
      // `channel?.invokeMethod(...) ?? false / ?? 0` produced these values.
      final uninitialised = AndroidPullToRefreshController(
        AndroidPullToRefreshControllerCreationParams(),
      );
      await uninitialised.setEnabled(true);
      await uninitialised.beginRefreshing();
      await uninitialised.setColor(const Color(0xFF000000));
      await uninitialised.setIndicatorSize(PullToRefreshSize.LARGE);
      expect(await uninitialised.isEnabled(), isFalse);
      expect(await uninitialised.isRefreshing(), isFalse);
      expect(await uninitialised.getDefaultSlingshotDistance(), 0);
    });
  });
}
