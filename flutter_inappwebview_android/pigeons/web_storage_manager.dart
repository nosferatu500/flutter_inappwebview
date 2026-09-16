// Pigeon schema for the web-storage-manager channel.
//
// Ninth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165) and cookie_manager (§168).
//
// No `messageChannelSuffix`: `android.webkit.WebStorage` is process-global, so there is one channel
// rather than one per WebView.
//
// Pre-schema checklist (§160-§168), all nine run before writing this:
//   1. Settings payload? **No.**
//   2. `@async`? **Five of seven.** `getOrigins`, `deleteBrowsingData`, `deleteBrowsingDataForSite`,
//      `getQuotaForOrigin` and `getUsageForOrigin` all complete through a `ValueCallback` or a
//      `Runnable`. `deleteAllData` and `deleteOrigin` are `void` platform calls that return inline.
//   3. A branch that never calls `result`? **None** -- all seven audited. Two of them answer in a
//      way the Dart side then throws away; see [deleteAllData] and [getQuotaForOrigin].
//   4. Dart `int` -> Kotlin `Long`? **Yes**, and it is free here: `quota`/`usage` are `long` on
//      `WebStorage.Origin` and `ValueCallback<Long>` on the two getters, so the generated `Long` is
//      what the platform already hands over. No narrowing anywhere (contrast §162).
//   5. Payload type shared with another channel? **No.** `GeolocationPermissionsManager` also has a
//      `getOrigins`, but it answers a `Set<String>` -- no object type, so no unprefixed-name
//      collision (§165).
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** Constant channel, no suffix.
//   8. Event named after a callback? **No events at all** -- HostApi-only.
//   9. Fields the wire carries that the platform never reads? **None** -- all three origin fields
//      are populated by the platform and read by Dart. (§168's `isSessionOnly` has no counterpart
//      here.)
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/web_storage_manager.dart
//   dart format lib/src/pigeons/web_storage_manager.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/web_storage_manager.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/WebStorageManager.g.kt',
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
/// One origin's storage figures, mirroring `WebStorage.Origin`.
///
/// **All three fields are non-null here, while the public `WebStorageOrigin` declares all three
/// nullable.** That asymmetry is deliberate and is the honest direction: this type is only ever
/// built by the host from a `WebStorage.Origin` the platform has just handed it, where `origin` is
/// the object's own identifier and `quota`/`usage` are primitive `long`s -- none of the three can
/// be absent. The public type's nullability is a legacy of the untyped map it used to be rebuilt
/// from, and is left alone because changing it is a platform-interface change, not a transport one.
///
/// This is the opposite call from §163's `URLProtectionSpaceData`, and for the opposite reason:
/// there the *public* API could produce a null that a Kotlin `!!` then crashed on, so the wire had
/// to admit it. Here the value only ever travels host → Dart, so the wire records what the platform
/// guarantees rather than what the Dart type happens to allow.
class WebStorageOriginData {
  WebStorageOriginData({
    required this.origin,
    required this.quota,
    required this.usage,
  });

  final String origin;

  /// Bytes, for the Web SQL Database API. Dart `int` -> Kotlin `Long`, which is already what
  /// `WebStorage.Origin.getQuota()` returns.
  final int quota;

  /// Bytes, across all JavaScript storage APIs. See [quota].
  final int usage;
}

@HostApi()
abstract class WebStorageManagerHostApi {
  /// Every origin currently using storage.
  ///
  /// `@async`: `WebStorage.getOrigins` reports through a `ValueCallback<Map>`.
  ///
  /// Answers an empty list when the storage cannot be resolved, as before — which is
  /// indistinguishable from "no origins are using storage". Preserved rather than fixed, because
  /// the alternative is a nullable return and a public-API change; filed in TODO.
  ///
  /// The migration does remove a genuine wart: the platform signature is literally
  /// `getOrigins(ValueCallback<Map>)` — a **raw** `Map` — so the old Kotlin cast the lambda
  /// `as ValueCallback<Map<Any?, Any?>>` behind a class-level `@Suppress("UNCHECKED_CAST")` and
  /// then cast each value `as WebStorage.Origin`. The cast against the platform stays (it is forced
  /// by `android.jar`), but it is now scoped to this one function and the *outbound* half is typed.
  @async
  List<WebStorageOriginData> getOrigins(String? profileName);

  /// Clears storage for every origin.
  ///
  /// 🚨 **The `bool` is computed and then discarded by Dart**, which declares
  /// `Future<void> deleteAllData(...)`. `false` means the storage could not be resolved — no such
  /// profile, or no `MULTI_PROFILE` — so a caller clearing a named profile's storage currently
  /// cannot tell that nothing happened. That is §137's `flush` finding exactly, one channel later.
  ///
  /// It stays on the wire for the same reason §157/§160/§162/§163 kept theirs: the distinction is
  /// real and free to carry, and surfacing it is a platform-interface change that belongs in its own
  /// commit. Filed in TODO.
  ///
  /// Not `@async`: `WebStorage.deleteAllData()` returns `void` and inline.
  bool deleteAllData(String? profileName);

  /// Clears storage for one origin. See [deleteAllData] for the discarded `bool`.
  ///
  /// [origin] is non-null: the public API requires it. The old handler read
  /// `call.argument("origin")` into a nullable and handed that straight to
  /// `WebStorage.deleteOrigin`, so a dropped key reached the platform as null.
  bool deleteOrigin(String origin, String? profileName);

  /// Clears browsing data for every site.
  ///
  /// `@async`: `WebStorageCompat.deleteBrowsingData` signals completion through a `Runnable`.
  ///
  /// Answers `false` when the storage cannot be resolved **or** when
  /// `WebViewFeature.DELETE_BROWSING_DATA` is unsupported — the feature gate is required rather than
  /// defensive, because the compat call throws `UnsupportedOperationException` without it.
  @async
  bool deleteBrowsingData(String? profileName);

  /// Clears browsing data for one site, answering the domain it actually cleared.
  ///
  /// The answer is not [site]: the platform resolves it to the registrable domain, so
  /// `"www.example.com"` comes back as `"example.com"`. Null means the storage could not be resolved
  /// or the feature is unsupported — note this is the **null** counterpart of
  /// [deleteBrowsingData]'s `false`, an inconsistency that predates the migration and is preserved.
  ///
  /// 🚨 **Fails with `PlatformException(code: "MyWebStorage")` when the site cannot be parsed as a
  /// domain name — and the Kotlin must deliver that through the callback rather than throwing.**
  ///
  /// §169 first wrote this as "the exception propagates to Pigeon's `wrapError`", which is **wrong
  /// for an `@async` method**: the generated handler wraps a *synchronous* host call in
  /// `try { … } catch (Throwable) { wrapError(…) }`, but an `@async` one is a bare
  /// `api.method(args) { result -> … }` with no `try`/`catch`. A synchronous throw escapes the
  /// handler, no reply is sent, and the caller gets `channel-error`. Measured on a device in §170
  /// and fixed there; see the Kotlin.
  ///
  /// The code stays the old `"MyWebStorage"` constant, so this is **not** a breaking change after
  /// all — unlike §165's note, which this paragraph replaces.
  ///
  /// `@async`: completion is signalled through a `Runnable`, and the return value is read *inside*
  /// it — safe only because the compat overload posts to the main looper. See the Kotlin.
  @async
  String? deleteBrowsingDataForSite(String site, String? profileName);

  /// The Web SQL quota for one origin, in bytes.
  ///
  /// `@async`: `WebStorage.getQuotaForOrigin` reports through a `ValueCallback<Long>`.
  ///
  /// 🚨 **Answers `0` when the storage cannot be resolved**, which is indistinguishable from an
  /// origin that genuinely has a zero quota. Preserved from the hand-written channel — the Dart side
  /// declares `Future<int>` and coalesced a null reply to `0` as well — but recorded because it is
  /// the same collapse `hasCookies` refuses to make (§168). Making it `int?` is a public-API change;
  /// filed in TODO.
  @async
  int getQuotaForOrigin(String origin, String? profileName);

  /// Bytes currently used by one origin, across all JavaScript storage APIs.
  ///
  /// `@async`, and answers `0` on an unresolvable store; see [getQuotaForOrigin].
  @async
  int getUsageForOrigin(String origin, String? profileName);
}
