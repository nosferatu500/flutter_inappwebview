// Pigeon schema for the tracing-controller channel.
//
// Fifth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160) and webview_feature (§161). Three methods.
//
// No `messageChannelSuffix`: androidx's `TracingController` is a process-wide singleton
// (`TracingController.getInstance()`), so there is one channel rather than one per WebView.
//
// 🚨 **None of these is `@async`, and `stop` is the interesting case.** §160's rule was "look for
// executor/callback APIs"; that is too coarse and `stop` is the counter-example that sharpens it.
// `TracingController.stop(OutputStream, Executor)` does take an `Executor`, but it **returns
// `boolean` synchronously** -- androidx documents the return as "false if the WebView framework was
// not tracing at the time of the call, true otherwise", and the `Executor` is only where the output
// stream's `write()` and `close()` are later invoked. There is no completion callback to hand to
// Pigeon.
//
// So the rule is: **`@async` iff completion is signalled by a callback**, not merely if an
// `Executor` appears in the signature. Making `stop` async here would be wrong twice over -- there
// is nothing to wait on, and pretending to wait would contradict the documented contract that
// `stop` returns before the trace is written. §158 established exactly that empirically: the flush
// takes ~6s for an 8.5 MB trace and the integration test has to poll `isTracing()` afterwards.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/tracing_controller.dart
//   dart format lib/src/pigeons/tracing_controller.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/tracing_controller.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/TracingController.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.nosferatu500.inappwebview.pigeons',
      // Every Pigeon Kotlin output declares its own `FlutterError` by default, and all of this
      // plugin's outputs share one package -- so a second declarer stops the module compiling
      // ("Redeclaration: FlutterError"). `find_interaction` is the designated declarer; every
      // other schema in this package must opt out here. See §157.
      includeErrorClass: false,
    ),
    dartPackageName: 'flutter_inappwebview_android',
  ),
)
/// Mirrors the platform interface's `TracingSettings`.
///
/// **`categories` is deliberately split into two typed lists.** The platform-interface type
/// declares `List<dynamic> categories` holding `String`s and `TracingCategory`s, and serialised it
/// to a heterogeneous `List` of `String`s and `int`s. The Kotlin side then took `List<Any?>` and
/// re-discovered each element's type at runtime:
///
/// ```kotlin
/// if (category is String) builder.addCategories(category)
/// if (category is Int) builder.addCategories(category)
/// ```
///
/// Those are **two different androidx overloads** — `addCategories(vararg String)` for category
/// name patterns and `addCategories(vararg Int)` for the predefined `TracingConfig.CATEGORIES_*`
/// constants — so the heterogeneous list was only ever a way of posting both through one door and
/// sorting them on arrival. Naming them separately makes the wire typed, deletes the runtime type
/// tests, and removes a **silent drop**: an element that was neither a `String` nor an `Int` matched
/// neither `if` and vanished with no error. `null` was such an element, and the platform interface's
/// own serialiser can produce one (its `EnumMethod.name` branch yields `null` for a
/// `TracingCategory`).
class TracingSettingsData {
  TracingSettingsData({
    required this.categoryNames,
    required this.predefinedCategories,
    this.tracingMode,
  });

  /// Category name patterns, e.g. `"blink*"` or `"renderer.scheduler"`. Passed to androidx's
  /// `addCategories(String...)`.
  final List<String> categoryNames;

  /// `TracingCategory` native values — the `TracingConfig.CATEGORIES_*` constants. Passed to
  /// androidx's `addCategories(int...)`.
  final List<int> predefinedCategories;

  /// `TracingMode`'s native value. Null means "not set explicitly", which androidx treats as
  /// `RECORD_CONTINUOUSLY`; the builder's `setTracingMode` is only called when this is non-null,
  /// matching the hand-written channel's `?.let`.
  final int? tracingMode;
}

@HostApi()
abstract class TracingControllerHostApi {
  /// Whether tracing is currently active.
  ///
  /// `false` also covers "androidx does not support `TRACING_CONTROLLER_BASIC_USAGE`", which is
  /// indistinguishable from "not tracing" and was already conflated by the channel this replaces.
  bool isTracing();

  /// Starts tracing, returning whether it actually started.
  ///
  /// `false` means the feature is unsupported. The Dart side **discards this value** because the
  /// platform interface declares `Future<void> start(...)`; it stays on the wire so the unsupported
  /// case remains distinguishable, as with `ProcessGlobalConfigHostApi.apply` (§157) and
  /// `ProxyHostApi.setProxyOverride` (§160).
  bool start(TracingSettingsData settings);

  /// Stops tracing and begins writing the trace to [filePath], returning androidx's own answer:
  /// **false if the framework was not tracing when the call was made**, true otherwise.
  ///
  /// ⚠️ **True does not mean the trace has been written.** The write happens afterwards on an
  /// executor, and for a large trace it takes seconds (§158 measured ~6s for 8.5 MB). A caller that
  /// needs the file on disk must poll [isTracing] until it reports false, which is what the
  /// integration test does. This is androidx's contract, not a limitation of the migration — see
  /// the header for why the method is therefore *not* `@async`.
  ///
  /// A null [filePath] discards the trace data, per androidx.
  bool stop(String? filePath);
}
