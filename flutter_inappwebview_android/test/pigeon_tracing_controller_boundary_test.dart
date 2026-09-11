import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/tracing_controller.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the fifth channel migrated to Pigeon (§162, `tracing_controller`), in the
/// shape §156 established and §157/§160/§161 reused.
///
/// The migration's real work is the **partition**: `TracingSettings.categories` is a
/// `List<dynamic>` of `String`s and `TracingCategory`s that used to cross the wire as one
/// heterogeneous list and get sorted out by `is` checks on the Kotlin side. It now leaves Dart as
/// two typed lists, one per androidx `addCategories` overload. Everything below exists to pin that
/// split, because nothing static can see a category routed to the wrong list — both destinations
/// are real fields and either way the call succeeds.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run in one process —
/// but they are generated from one schema and ship in the same package, so they cannot be
/// version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = TracingControllerHostApi.pigeonChannelCodec;
  const startChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.TracingControllerHostApi.start';
  const stopChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.TracingControllerHostApi.stop';
  const isTracingChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.TracingControllerHostApi.isTracing';

  late AndroidTracingController tracing;
  final Map<String, List<Object?>?> received = {};
  final Map<String, Object?> replies = {};

  void install(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel, (message) async {
          received[channel] = message == null
              ? null
              : codec.decodeMessage(message) as List<Object?>;
          return codec.encodeMessage(<Object?>[replies[channel] ?? true]);
        });
  }

  setUp(() {
    received.clear();
    replies.clear();
    tracing = AndroidInAppWebViewPlatform().createPlatformTracingController(
      const PlatformTracingControllerCreationParams(),
    );
    install(startChannel);
    install(stopChannel);
    install(isTracingChannel);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final c in [startChannel, stopChannel, isTracingChannel]) {
      messenger.setMockMessageHandler(c, null);
    }
  });

  TracingSettingsData sentSettings() =>
      (received[startChannel] as List<Object?>).single as TracingSettingsData;

  test('a mixed category list is split by destination overload', () async {
    await tracing.start(
      settings: TracingSettings(
        categories: [
          TracingCategory.CATEGORIES_ANDROID_WEBVIEW,
          'blink*',
          TracingCategory.CATEGORIES_FRAME_VIEWER,
          'renderer.scheduler',
        ],
      ),
    );

    final settings = sentSettings();
    // Order within each list is preserved, and the two lists are asserted separately with
    // distinct values -- a category sent to the wrong list is invisible to any check that only
    // counts them.
    expect(settings.categoryNames, ['blink*', 'renderer.scheduler']);
    expect(settings.predefinedCategories, [
      TracingCategory.CATEGORIES_ANDROID_WEBVIEW.toNativeValue(),
      TracingCategory.CATEGORIES_FRAME_VIEWER.toNativeValue(),
    ]);
  });

  test('string-only categories leave the predefined list empty', () async {
    await tracing.start(settings: TracingSettings(categories: ['blink*']));

    final settings = sentSettings();
    expect(settings.categoryNames, ['blink*']);
    // Empty, not null: the Kotlin side skips the androidx call when the list is empty, and a null
    // here would be a decoding error rather than an empty category set.
    expect(settings.predefinedCategories, isEmpty);
  });

  test('predefined-only categories leave the name list empty', () async {
    await tracing.start(
      settings: TracingSettings(
        categories: [TracingCategory.CATEGORIES_ANDROID_WEBVIEW],
      ),
    );

    final settings = sentSettings();
    expect(settings.categoryNames, isEmpty);
    expect(settings.predefinedCategories, [
      TracingCategory.CATEGORIES_ANDROID_WEBVIEW.toNativeValue(),
    ]);
  });

  test('a category of neither type is dropped, not sent', () async {
    await tracing.start(
      settings: TracingSettings(categories: [42, 3.14, 'blink*']),
    );

    final settings = sentSettings();
    // Same outcome as the hand-written path, which dropped these on the Kotlin side. The point is
    // that they reach neither typed list rather than arriving as an untyped element.
    expect(settings.categoryNames, ['blink*']);
    expect(settings.predefinedCategories, isEmpty);
  });

  test('tracingMode crosses as its native value, and null stays null', () async {
    await tracing.start(
      settings: TracingSettings(
        categories: ['blink*'],
        tracingMode: TracingMode.RECORD_UNTIL_FULL,
      ),
    );
    expect(
      sentSettings().tracingMode,
      TracingMode.RECORD_UNTIL_FULL.toNativeValue(),
    );

    received.clear();
    await tracing.start(settings: TracingSettings(categories: ['blink*']));
    // Null means "not set", which androidx treats as RECORD_CONTINUOUSLY. Sending a concrete
    // default here would take that choice away from androidx.
    expect(sentSettings().tracingMode, isNull);
  });

  test('stop sends the file path on its own channel', () async {
    expect(await tracing.stop(filePath: '/tmp/trace.json'), isTrue);

    expect((received[stopChannel] as List<Object?>).single, '/tmp/trace.json');
    expect(received.containsKey(startChannel), isFalse);
  });

  test('stop with no path sends null, which discards the trace', () async {
    await tracing.stop();

    expect((received[stopChannel] as List<Object?>).single, isNull);
  });

  test('stop relays false rather than defaulting it', () async {
    replies[stopChannel] = false;

    // androidx returns false when the framework was not tracing at the time of the call. The old
    // Dart read `?? false`, which made a real false and an absent reply the same value.
    expect(await tracing.stop(filePath: '/tmp/trace.json'), isFalse);
  });

  test('isTracing takes no arguments and relays both answers', () async {
    expect(await tracing.isTracing(), isTrue);
    expect(received[isTracingChannel], isNull);

    replies[isTracingChannel] = false;
    expect(await tracing.isTracing(), isFalse);
  });
}
