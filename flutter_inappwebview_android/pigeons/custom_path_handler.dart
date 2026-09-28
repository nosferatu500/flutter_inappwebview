// Pigeon schema for the custom `WebViewAssetLoader` path handler's per-instance channel.
//
// Twenty-second channel migrated off hand-written MethodChannel dispatch. It was missing from the
// remaining-channels table until §203's unfiltered survey found it; device coverage came first, as
// its own item (§204).
//
// One event and no host methods: `WebViewAssetLoader` calls `PathHandlerExt.handle(path)` on a
// Chromium worker thread, which must return a `WebResourceResponse?` synchronously, so Kotlin
// **blocks** on the Dart answer. That is §186's shape (`ServiceWorkerChannelDelegate`), and the wait
// keeps the hand-written `Util.invokeMethodAndWaitResult` semantics exactly: posted to the main
// looper, bounded by `Util.SYNC_CALLBACK_TIMEOUT_MILLIS` (a path handler holds no WebView settings to
// read a longer one from), and a timeout, a Dart throw, no Dart handler or a null answer all mean
// "not handled", so the request goes to the network.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No.** The argument is a path string. The *answer* is a
//      `WebResourceResponse`, which crosses as its `toMap()` (item 5), read by
//      `WebResourceResponseExt.fromMap`.
//   2. `@async`? **The FlutterApi method is**, which on a FlutterApi changes only the Dart side: the
//      app's `CustomPathHandler.handle` is async (§186).
//   3. A branch that never answers? **None.** Every path out of the generated reply releases the
//      latch (read in the generated `send`, as §186 did); the timeout is the backstop.
//   4. Dart `int` -> Kotlin `Long`? **One, inside the answer map**: `statusCode`, which
//      `WebResourceResponseExt.fromMap` casts `as Int?`. Kotlin passes the map through
//      `Util.normalizeCodecInts` first (§197). §204's status test asserts it on the device.
//   5. Payload type shared with another channel? **Yes, and deliberately not typed here.** The
//      answer is the same `WebResourceResponseExt` that `service_worker.dart` declares as
//      `WebResourceResponseData`. Pigeon cannot share a type across schema files, so typing it would
//      put this API inside `service_worker.dart`, and that type is already recorded (§186) as
//      moving into `WebViewChannelDelegate`'s schema when that migrates. So the answer stays a map
//      until then, the decision taken for §205. That migration can type it with the rest.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes.** `messageChannelSuffix` is the handler's id: Dart's
//      `AndroidPathHandler._id`, sent in its `toMap()` and read by `WebViewAssetLoaderExt.fromMap`.
//      A mismatch on a FlutterApi is silent (§177): Kotlin would wait out its timeout and load from
//      the network. §204's tests would each fail on that.
//   8. Event named after a callback? **Yes**: `handle` is `PlatformPathHandlerEvents.handle`, which
//      the app-facing `PathHandler` implements. The Dart side forwards through a private class
//      (§14).
//   9. Fields the platform never reads? **`cookies`**, in the answer map: `fromMap` parses it and
//      `PathHandlerExt.handle` never uses it. It is kept, because the map is `toMap()` whole
//      (item 5). The dead callback form of the Kotlin `handle(path, callback)` is not ported (§204
//      measured it has no caller).
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/custom_path_handler.dart
//   dart format lib/src/pigeons/custom_path_handler.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/custom_path_handler.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/CustomPathHandler.g.kt',
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
/// Implemented on the Dart side by a private forwarding class, one per path handler, suffixed by
/// its id.
@FlutterApi()
abstract class CustomPathHandlerFlutterApi {
  /// The response for [path], the part of the URL after the handler's prefix, with no query. Null
  /// means "not handled": the request goes to the network.
  ///
  /// The answer is `WebResourceResponse.toMap()` (checklist item 5).
  @async
  Map<String?, Object?>? handle(String path);
}
