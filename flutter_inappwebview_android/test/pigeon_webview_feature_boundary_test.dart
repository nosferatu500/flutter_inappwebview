import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/webview_feature.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the fourth channel migrated to Pigeon (§161, `webview_feature`), in the
/// shape §156 established and §157/§160 reused.
///
/// The two methods are near-identical in signature — `String` in, `bool` out — and they live on
/// **separate generated channels** whose names differ only in the method segment. That is the
/// specific failure this file exists for: a migration that wires both Dart methods to one channel
/// still compiles, still type-checks, and still returns plausible answers.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
///
/// **One thing no test here can catch.** All 60 `WebViewFeature` constants have `_value ==
/// _nativeValue`, so a swap between `toNativeValue()` and `toValue()` is invisible on the wire.
/// Both are correct today; if a constant with differing values is ever added, add the assertion.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const isFeatureChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebViewFeatureHostApi.isFeatureSupported';
  const isStartupChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.WebViewFeatureHostApi.isStartupFeatureSupported';
  const codec = WebViewFeatureHostApi.pigeonChannelCodec;

  late AndroidWebViewFeature feature;
  final Map<String, List<Object?>> received = {};
  final Map<String, Object?> replies = {};
  List<Object?>? errorReply;

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = codec.decodeMessage(message) as List<Object?>;
          if (errorReply != null) return codec.encodeMessage(errorReply);
          return codec.encodeMessage(<Object?>[replies[channel] ?? true]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    errorReply = null;
    // The factory returns the process-wide singleton (§155), which is what an app actually gets.
    feature = AndroidInAppWebViewPlatform().createPlatformWebViewFeature(
      const PlatformWebViewFeatureCreationParams(),
    );
    install(isFeatureChannel);
    install(isStartupChannel);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(isFeatureChannel, null);
    messenger.setMockMessageHandler(isStartupChannel, null);
  });

  test('isFeatureSupported sends androidx\'s own feature string', () async {
    expect(
      await feature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING),
      isTrue,
    );

    expect(received[isFeatureChannel]!.single, 'ALGORITHMIC_DARKENING');
  });

  test('isFeatureSupported relays a false answer rather than defaulting', () async {
    replies[isFeatureChannel] = false;

    // The old Dart read `invokeMethod<bool>(...) ?? false`, so a genuine false and an absent reply
    // were the same value. They are different things and only one of them is an answer.
    expect(
      await feature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING),
      isFalse,
    );
  });

  test(
    'isStartupFeatureSupported uses its own channel, not the other one',
    () async {
      expect(
        await feature.isStartupFeatureSupported(
          WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
        ),
        isTrue,
      );

      expect(
        received[isStartupChannel]!.single,
        'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX',
      );
      // The whole point of the pair: the two generated channel names differ only in the method
      // segment, so wiring both Dart methods to one channel would pass every other assertion here.
      expect(received.containsKey(isFeatureChannel), isFalse);
    },
  );

  test('isFeatureSupported does not reach the startup channel', () async {
    await feature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING);

    expect(received.containsKey(isStartupChannel), isFalse);
  });

  test('the two startup features are not conflated', () async {
    await feature.isStartupFeatureSupported(
      WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS,
    );

    expect(
      received[isStartupChannel]!.single,
      'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS',
    );
  });

  test('a host error surfaces with its code and message', () async {
    // androidx's isFeatureSupported *throws* `RuntimeException("Unknown feature ...")` for a
    // declared-but-unregistered feature rather than answering false. The six such tombstones §36
    // found are deliberately not Dart constants in this fork, so that path is no longer reachable
    // by passing one -- but the envelope still has to work, because any androidx-side failure
    // arrives the same way.
    errorReply = <Object?>[
      'java.lang.RuntimeException',
      'Unknown feature',
      null,
    ];

    // Asserted on code and message, not just isA<PlatformException>(): with no handler at all
    // Pigeon also throws a PlatformException (code 'channel-error'), so the loose form passes
    // while proving nothing about the envelope -- the vacuity §157's mutant B exposed.
    await expectLater(
      feature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'java.lang.RuntimeException')
            .having((e) => e.message, 'message', 'Unknown feature'),
      ),
    );
  });
}
