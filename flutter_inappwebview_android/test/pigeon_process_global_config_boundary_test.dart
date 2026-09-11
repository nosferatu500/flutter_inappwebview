import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_android/src/pigeons/process_global_config.g.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boundary coverage for the second channel migrated to Pigeon (§157,
/// `process_global_config`), in the shape §156 established for the pilot.
///
/// The migration's whole risk is on the wire: `apply` is the one method, and its
/// argument is a nested object whose fields the hand-written channel passed as
/// an untyped `Map<String, Any?>` and parsed key-by-key on the Kotlin side.
/// Nothing static can see a mismatch there, so these drive the **real generated
/// codec** on the **real generated channel name** and assert the exact payload.
///
/// As in §156 this cannot prove the Kotlin half agrees — both halves cannot run
/// in one process — but they are generated from one schema and ship in the same
/// package, so they cannot be version-skewed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = ProcessGlobalConfigHostApi.pigeonChannelCodec;

  // No messageChannelSuffix: ProcessGlobalConfig.apply is process-global.
  const applyChannel =
      'dev.flutter.pigeon.flutter_inappwebview_android.ProcessGlobalConfigHostApi.apply';

  late AndroidProcessGlobalConfig config;
  Object? sent;
  Object? reply;

  setUp(() {
    sent = null;
    reply = true;
    // The factory returns the process-wide singleton (§155), which is what an
    // app actually gets; using it here keeps the test on the production path.
    config = AndroidInAppWebViewPlatform().createPlatformProcessGlobalConfig(
      const PlatformProcessGlobalConfigCreationParams(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(applyChannel, (message) async {
          sent = codec.decodeMessage(message);
          return codec.encodeMessage(<Object?>[reply]);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(applyChannel, null);
  });

  /// The single argument Dart put on the wire, as the generated data class.
  ProcessGlobalConfigSettingsData sentSettings() {
    final args = sent as List<Object?>;
    return args.single as ProcessGlobalConfigSettingsData;
  }

  test('a suffix-only config sends the suffix and a null base-paths', () async {
    await config.apply(
      settings: ProcessGlobalConfigSettings(dataDirectorySuffix: 'worker'),
    );

    final settings = sentSettings();
    expect(settings.dataDirectorySuffix, 'worker');
    expect(settings.directoryBasePaths, isNull);
  });

  test('the nested base paths survive the round trip', () async {
    await config.apply(
      settings: ProcessGlobalConfigSettings(
        dataDirectorySuffix: 'worker',
        directoryBasePaths: ProcessGlobalConfigDirectoryBasePaths(
          dataDirectoryBasePath: '/data/base',
          cacheDirectoryBasePath: '/cache/base',
        ),
      ),
    );

    final paths = sentSettings().directoryBasePaths;
    expect(paths, isNotNull);
    // Asserted separately rather than as one object: the two fields are both
    // non-null strings of the same type, so a swapped assignment at the
    // boundary is invisible to an equality check on the pair.
    expect(paths!.dataDirectoryBasePath, '/data/base');
    expect(paths.cacheDirectoryBasePath, '/cache/base');
  });

  test(
    'a null suffix stays null rather than becoming an empty string',
    () async {
      // androidx rejects an empty suffix, so "no suffix" and "" are different
      // instructions. The hand-written channel expressed the first by omitting
      // the key; the schema expresses it as null.
      await config.apply(settings: ProcessGlobalConfigSettings());

      final settings = sentSettings();
      expect(settings.dataDirectorySuffix, isNull);
      expect(settings.directoryBasePaths, isNull);
    },
  );

  test('a false result is tolerated, matching Future<void>', () async {
    // false means "no activity, nothing applied". The platform interface
    // declares `Future<void>`, so Dart discards it -- but it must not throw.
    reply = false;
    await expectLater(
      config.apply(
        settings: ProcessGlobalConfigSettings(dataDirectorySuffix: 'worker'),
      ),
      completes,
    );
  });

  test('a host error surfaces to the caller', () async {
    // The Kotlin side throws when androidx rejects the config -- most often
    // because it has already been applied once in this process. Pigeon turns
    // that into an error envelope, which must reach the awaiting caller rather
    // than being swallowed.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(applyChannel, (message) async {
          return codec.encodeMessage(<Object?>[
            'IllegalStateException',
            'already applied',
            'Cause: null, Stacktrace: …',
          ]);
        });

    await expectLater(
      config.apply(
        settings: ProcessGlobalConfigSettings(dataDirectorySuffix: 'worker'),
      ),
      // Asserted on the code, not just the type: with no handler at all Pigeon
      // throws PlatformException(code: 'channel-error') too, so `isA<PlatformException>()`
      // alone passes whether or not the error envelope was really decoded.
      // Found by the anti-vacuity mutant.
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'IllegalStateException')
            .having((e) => e.message, 'message', 'already applied'),
      ),
    );
  });
}
