// Pigeon schema for the geolocation-permissions channel.
//
// Eleventh channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169) and profile_store (§173). Five methods.
//
// No `messageChannelSuffix`: `android.webkit.GeolocationPermissions` is process-global, so there is
// one channel rather than one per WebView.
//
// 🚨 **Rule 2 was satisfied before this item started, by §174 rather than by luck.** This channel
// had *zero* device coverage — measured, not assumed. §174 wrote the `geolocation_permissions`
// integration group (8 tests, 8/8, mutant-checked) as its own item precisely so that this migration
// would land on a net that exists. Do not fold the two together in future; the whole point is that
// a first-run failure here is attributable to the migration and nothing else.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No.** The file mentions "settings" once and it is a *comment* referring
//      to `ServiceWorkerSettings` — the smell that turned out not to be a verdict, which is why the
//      TODO table says to read the file rather than trust the count.
//   2. `@async`? **Two of five.** [getAllowed] and [getOrigins] complete through a `ValueCallback`;
//      `allow`, `clear` and `clearAll` wrap `void` platform calls and answer inline. Both `@async`
//      methods therefore take `replyingOnThrow` (§172's standing rule), applied **unconditionally**
//      rather than where a throw looks likely — §171's guard was mis-scoped exactly by reasoning
//      that way.
//   3. A branch that never calls `result`? **None** -- all five audited. Every one has an explicit
//      null-store early return, and those returns **disagree with each other on purpose**; see
//      [getAllowed].
//   4. Dart `int` -> Kotlin `Long`? **No ints on this channel at all.**
//   5. Payload type shared with another channel? **Not applicable, and that is a first**: this
//      schema declares **no data classes whatsoever**. Every argument and return is a `String`,
//      `bool` or `List<String>`, so §165's unprefixed-name collision cannot arise.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** Constant channel, no suffix.
//   8. Event named after a callback? **No events at all** -- HostApi-only.
//   9. Fields the wire carries that the platform never reads? **None.** Only `origin` and
//      `profileName` cross, and the Kotlin reads both on every method that takes them.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/geolocation_permissions.dart
//   dart format lib/src/pigeons/geolocation_permissions.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/geolocation_permissions.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/GeolocationPermissions.g.kt',
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
@HostApi()
abstract class GeolocationPermissionsHostApi {
  /// Stores a decision allowing [origin] to use the Geolocation API.
  ///
  /// Answers `false` when the store could not be resolved — `MULTI_PROFILE` unsupported, or no
  /// profile of that name — in which case **nothing was stored**. It never falls back to the default
  /// store: granting an origin location access in the wrong profile is a privacy decision applied to
  /// the wrong session.
  ///
  /// Synchronous: `GeolocationPermissions.allow` returns `void` and the `true` is this plugin's
  /// "the store was resolved and the call was made".
  bool allow(String origin, String? profileName);

  /// Removes any stored decision for [origin], so the next request from it prompts again.
  ///
  /// Clearing is not denying: there is no stored "deny". Answers `false` on an unresolvable store;
  /// see [allow].
  bool clear(String origin, String? profileName);

  /// Removes every stored decision. Answers `false` on an unresolvable store; see [allow].
  bool clearAll(String? profileName);

  /// Whether [origin] has a stored decision allowing the Geolocation API.
  ///
  /// 🚨 **`bool?`, and the null is load-bearing — it is the only such null on this channel.** Null
  /// means the question *could not be asked* (unresolvable store); `false` means it was asked and
  /// nothing is stored. Collapsing them would report "no decision" for a profile that was never
  /// consulted, and a caller deciding whether to prompt on that basis would prompt wrongly.
  ///
  /// This is the branch the migration most had to preserve, and the one the four other methods
  /// deliberately disagree with: they answer `false` (or an empty list) for the same condition.
  /// Pigeon makes an unanswered branch unrepresentable, so each is restated by hand in the Kotlin.
  /// §174's `an unknown profile resolves to no store` pins all five on a device.
  ///
  /// `@async`: `GeolocationPermissions.getAllowed` reports through a `ValueCallback<Boolean>`.
  @async
  bool? getAllowed(String origin, String? profileName);

  /// The origins that have a stored decision allowing the Geolocation API.
  ///
  /// 🚨 **These come back normalised, with a trailing `/`** — `allow("https://x.test")` is listed
  /// here as `"https://x.test/"`. Measured in §174, where it failed four tests at once and looked
  /// like four problems. The other four methods accept **either** form, so listing then acting
  /// works; only comparing against the string you passed to [allow] does not. The public dartdoc on
  /// `getOrigins` and `allow` now says so.
  ///
  /// Answers an empty list on an unresolvable store — which is a *third* spelling of the same
  /// condition, alongside [allow]'s `false` and [getAllowed]'s `null`. Preserved as-is rather than
  /// harmonised; harmonising is a platform-interface change.
  ///
  /// `@async`: `GeolocationPermissions.getOrigins` reports through a `ValueCallback<Set<String>>`.
  /// The platform's `Set` has no wire representation, so the Kotlin copies it into a list — order is
  /// therefore whatever the set iterates, and nothing should depend on it.
  @async
  List<String> getOrigins(String? profileName);
}
