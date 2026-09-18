// Pigeon schema for the print-job-controller channel.
//
// Twelfth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173) and geolocation_permissions (§175).
//
// 🚨 **The TODO table lists this channel as `4 0` and that is the most misleading row in it.** Four
// methods, no "settings" mentions — and also: a **per-instance** channel, an **event**, and a
// **four-level nested payload**. It is a bigger migration than `geolocation_permissions` was.
//
// Its device group is §176, written first per the rule §169 earned: one test covering all four
// methods over one job's lifetime, because reaching this channel at all raises an OS print dialog
// that nothing can dismiss.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No** — and this one needed checking rather than grepping.
//      `PrintJobSettings` is real and is handed to `PrintJobController`'s *constructor* from
//      `InAppWebView.printCurrentPage`; it never crosses this channel. The channel carries no
//      arguments at all in the Dart -> platform direction.
//   2. `@async`? **None of the four.** Every host method answers inline. [onComplete] is an
//      *event*, not a completion signal for any call — the same distinction as §165's
//      `setWebMessageCallback` and §162's `TracingController.stop`, and the reason the rule is
//      "`@async` iff completion is signalled by a callback" rather than "iff a callback appears".
//   3. A branch that never calls `result`? **None** — all four audited; each has an explicit
//      null-controller arm.
//   4. Dart `int` -> Kotlin `Long`? **Yes, and only outbound, which is the safe direction.** Every
//      numeric here is platform -> Dart, so the Kotlin `Int`s widen with `.toLong()`. §162's bug
//      was the *inbound* narrowing (`.toInt()` for an androidx API that demands an `Int`), and
//      nothing on this channel takes a number from Dart. `creationTime` is already a `Long`.
//   5. Payload type shared with another channel? **No**, and the names are prefixed anyway.
//      `MediaSize` / `Resolution` / `Margins` are generic enough that a future channel could
//      plausibly want them, and §165 is the section where an unprefixed collision forced two
//      channels into a single commit. `PrintJob…Data` costs nothing now and removes that risk.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes** — `messageChannelSuffix` carries the job id, as both
//      web_message channels do. §165's finding applies **in half, and the half matters**: measured
//      here, a mismatch on the *HostApi* direction fails in ~2s with the channel named in full
//      (`PlatformException(channel-error, "Unable to establish connection on channel: …getInfo.<id>")`),
//      because the caller is awaiting a reply. The silent 60-second hang §165 recorded is the
//      *FlutterApi* direction, where nothing awaits the event. See [PrintJobControllerFlutterApi].
//   8. Event named after a callback? **Yes, and it collides** — see [PrintJobControllerFlutterApi].
//   9. Fields the wire carries that the platform never reads? **None. The inverse, at scale.**
//      See [PrintJobInfoData].
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/print_job.dart
//   dart format lib/src/pigeons/print_job.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/print_job.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/PrintJob.g.kt',
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
/// One print job's state, mirroring the platform interface's `PrintJobInfo` **as far as Android
/// populates it**.
///
/// 🚨 **Checklist item 9, in the opposite direction to every previous migration.** §160 found seven
/// fields per proxy rule that the wire carried and the platform never read; §163 nine per
/// credential; §168 one always-null `isSessionOnly`. Here the wire carries nothing dead — instead
/// the **reader expects fourteen fields the wire has never carried**:
///
///  * `PrintJobInfo.fromMap` reads 15 keys; the Kotlin `toMap()` sends **7**. The missing eight —
///    `canSpawnSeparateThread`, `currentPage`, `firstPage`, `isCopyingOperation`, `lastPage`,
///    `preferredRenderingQuality`, `showsPrintPanel`, `showsProgressPanel` — have **zero
///    occurrences in the entire Android Kotlin module**, measured by grep per key.
///  * `PrintJobAttributes.fromMap` reads 12; the Kotlin sends **6**. The missing six are
///    `footerHeight`, `headerHeight`, `maximumContentHeight`, `maximumContentWidth`, `paperRect`
///    and `printableRect`, all likewise absent from the Android source.
///
/// They are iOS-only fields on a shared cross-platform type, and today they arrive as *absent map
/// keys*, which `fromMap` reads as null. So modelling only what Android sends is **exactly
/// behaviour-preserving** — the Dart side passes null for the rest when rebuilding the public type,
/// which is what an absent key already produced. It is also the §168 precedent (drop what is always
/// null) applied to the only case where the alternative was to invent 14 permanently-null wire
/// fields. §176's device test pins all eight of the `PrintJobInfo` ones as null so that a change in
/// either direction is visible.
class PrintJobInfoData {
  PrintJobInfoData({
    required this.state,
    required this.copies,
    this.numberOfPages,
    required this.creationTime,
    required this.label,
    this.printerId,
    this.attributes,
  });

  /// `android.print.PrintJobInfo`'s own constant, rebuilt into `PrintJobState` on the Dart side.
  final int state;

  final int copies;

  /// `info.pages?.size` — null when the job does not describe a page range, which is the common
  /// case for a job that has only just been created.
  final int? numberOfPages;

  /// Epoch milliseconds. Already a Kotlin `Long`, so this is the one number here that needs no
  /// widening (checklist item 4).
  final int creationTime;

  final String label;

  /// 🚨 **Flattened from a nested one-key map, deliberately.** The hand-written Kotlin sent
  /// `"printer" to hashMapOf("id" to printerId)` and the public `Printer` type has exactly one
  /// field, `id`. The nesting bought nothing.
  ///
  /// Note the Dart side must still build a **non-null** `Printer` when this is null: the old map was
  /// always present even when the id inside it was null, so `Printer.fromMap` always returned an
  /// object. Rebuilding it as `Printer(id: printerId)` unconditionally preserves that; making the
  /// `Printer` itself null when the id is null would be a behaviour change dressed up as a tidy-up.
  final String? printerId;

  final PrintJobAttributesData? attributes;
}

/// The job's print attributes, again only as far as Android populates them; see [PrintJobInfoData].
class PrintJobAttributesData {
  PrintJobAttributesData({
    required this.colorMode,
    this.duplex,
    this.orientation,
    this.mediaSize,
    this.resolution,
    this.margins,
  });

  final int colorMode;
  final int? duplex;

  /// **Derived, not read.** `PrintAttributes` has no orientation; the Kotlin computes it as
  /// `if (mediaSize.isPortrait) 0 else 1` and leaves it null when there is no media size at all.
  /// Preserved as-is.
  final int? orientation;

  final PrintJobMediaSizeData? mediaSize;
  final PrintJobResolutionData? resolution;
  final PrintJobMarginsData? margins;
}

/// Matches the public `PrintJobMediaSize` field for field, in both directions — one of the three
/// leaf types on this channel where nothing is added and nothing is dropped.
class PrintJobMediaSizeData {
  PrintJobMediaSizeData({
    required this.id,
    this.label,
    required this.widthMils,
    required this.heightMils,
  });

  final String id;
  final String? label;
  final int widthMils;
  final int heightMils;
}

/// Matches the public `PrintJobResolution` field for field; see [PrintJobMediaSizeData].
class PrintJobResolutionData {
  PrintJobResolutionData({
    required this.id,
    required this.label,
    required this.verticalDpi,
    required this.horizontalDpi,
  });

  final String id;
  final String label;
  final int verticalDpi;
  final int horizontalDpi;
}

/// The job's minimum margins, rebuilt into Flutter's `EdgeInsets` on the Dart side.
///
/// `double`, not `int`: these are the only non-integer numbers on the channel, and they are already
/// `Double` in the Kotlin, so no conversion happens in either direction.
class PrintJobMarginsData {
  PrintJobMarginsData({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  final double top;
  final double right;
  final double bottom;
  final double left;
}

/// Dart -> platform, one channel per `PrintJobController` instance.
///
/// The `messageChannelSuffix` is the job id, so the two halves must agree on it exactly; §165 proved
/// that a mismatch here produces no error at all, just a call that never arrives and a 60-second
/// timeout.
@HostApi()
abstract class PrintJobControllerHostApi {
  /// Cancels the job.
  ///
  /// Answers `false` only when the controller has already been disposed. **It does not mean the job
  /// was cancelled** — `android.print.PrintJob.cancel()` is a no-op while the job is in `CREATED`
  /// state, which is the state it is in for as long as the print dialog is open. Measured in §176,
  /// where `getInfo().state` stays `CREATED` across a `cancel()`; the pre-existing behaviour is
  /// preserved rather than corrected, because correcting it means waiting on a job state no test can
  /// reach.
  bool cancel();

  /// Restarts the job. Answers `false` only when the controller has been disposed.
  ///
  /// Like [cancel], a no-op against the only state a test can produce: `PrintJob.restart()` applies
  /// to a **failed** job. Preserved as-is.
  bool restart();

  /// The job's current state, or null when the controller has been disposed or holds no job.
  ///
  /// Null is the only signal this channel gives that a controller is finished — §176 asserts
  /// `getInfo()` answers null after [dispose], which is that group's one true state transition.
  PrintJobInfoData? getInfo();

  /// Releases the native controller and cancels the underlying job.
  ///
  /// Answers `false` only when it had already been disposed. Note the **facade** drops this answer
  /// twice over: `PlatformPrintJobController.dispose()` is `Future<void>`, and the app-facing
  /// `PrintJobController.dispose()` is plain `void`, so a caller can neither read the result nor
  /// await the teardown. Recorded, not changed — both are public signatures.
  bool dispose();
}

/// Platform -> Dart, on the same per-instance channel.
///
/// 🚨 **This is §14's predicted name collision, arriving for the first time.** P0a item 4 has
/// carried the line *"Expect a private forwarding class per event whose name collides with a
/// platform-interface member"* since the pilot. `PlatformPrintJobController` exposes
/// `PrintJobCompletionHandler? onComplete` as a **field**, and Pigeon generates a **method** of the
/// same name — which Dart rejects as inconsistent inheritance if one class tries to be both.
///
/// So `AndroidPrintJobController` does **not** implement this API directly. A private
/// `_PrintJobControllerFlutterApiImpl` receives the event and forwards it to the controller's
/// callback field, exactly as §14 did for `onFindResultReceived`. §165's two channels escaped this
/// only because `onMessage` and `onPostMessage` happen not to collide with anything.
@FlutterApi()
abstract class PrintJobControllerFlutterApi {
  /// Fires when the print job finishes, from `InAppWebViewPrintDocumentAdapter.onFinish()`.
  ///
  /// [error] is always null on Android today — the adapter's callback has no failure path — but it
  /// is kept nullable because the public `PrintJobCompletionHandler` takes it and iOS supplies it.
  void onComplete(bool completed, String? error);
}
