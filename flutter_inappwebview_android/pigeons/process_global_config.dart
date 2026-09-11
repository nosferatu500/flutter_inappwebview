// Pigeon schema for the process-global-config channel.
//
// Second channel migrated off hand-written MethodChannel dispatch, after
// find_interaction (§14). Chosen as the smallest remaining one: a single method.
//
// Unlike find_interaction there is **no `messageChannelSuffix`** here. androidx's
// `ProcessGlobalConfig.apply` is process-global and may only be called once per process, so there
// is exactly one channel rather than one per WebView.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/process_global_config.dart
//   dart format lib/src/pigeons/process_global_config.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/process_global_config.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/ProcessGlobalConfig.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.nosferatu500.inappwebview.pigeons',
      // Every Pigeon Kotlin output declares its own `FlutterError` by default, and all of this
      // plugin's outputs share one package -- so the second schema added collided with the first
      // ("Redeclaration: FlutterError") and the module stopped compiling. `find_interaction` is
      // the designated declarer; every other schema in this package must opt out here.
      includeErrorClass: false,
    ),
    dartPackageName: 'flutter_inappwebview_android',
  ),
)
/// Mirrors the platform interface's `ProcessGlobalConfigDirectoryBasePaths`.
///
/// **Both fields are non-null on purpose.** The platform-interface type declares them
/// non-nullable, but the Kotlin side stored them as `String?` and force-unwrapped with `!!` when
/// building the `File`s. That only ever worked because Dart could not send null; typing them
/// `required` here makes the guarantee the Kotlin code was already relying on an explicit part of
/// the wire contract.
class ProcessGlobalConfigDirectoryBasePathsData {
  ProcessGlobalConfigDirectoryBasePathsData({
    required this.dataDirectoryBasePath,
    required this.cacheDirectoryBasePath,
  });

  final String dataDirectoryBasePath;
  final String cacheDirectoryBasePath;
}

/// Mirrors the platform interface's `ProcessGlobalConfigSettings`.
///
/// Deliberately a separate type, for the same reason as `FindSessionData`: the
/// platform-interface version is the public API, so it cannot be Pigeon-generated without coupling
/// every platform to this schema.
class ProcessGlobalConfigSettingsData {
  ProcessGlobalConfigSettingsData({
    this.dataDirectorySuffix,
    this.directoryBasePaths,
  });

  /// Null means "no suffix", which is not the same as the empty string — androidx rejects an
  /// empty suffix. The hand-written channel expressed this by omitting the map key.
  final String? dataDirectorySuffix;

  final ProcessGlobalConfigDirectoryBasePathsData? directoryBasePaths;
}

@HostApi()
abstract class ProcessGlobalConfigHostApi {
  /// Returns whether the config was applied.
  ///
  /// `false` means there was no activity to apply it against — the settings were silently not
  /// applied. A thrown error means androidx rejected the config (most often: it had already been
  /// applied once in this process, which it permits only once).
  ///
  /// The Dart side **discards this value**, because the platform interface declares
  /// `Future<void> apply(...)`. Keeping the bool on the wire preserves the hand-written channel's
  /// semantics exactly and keeps the no-activity case distinguishable from success for anyone who
  /// later wants to surface it; collapsing it to `void` would throw that away silently.
  bool apply(ProcessGlobalConfigSettingsData settings);
}
