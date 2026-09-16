// Pigeon schema for the profile-store channel.
//
// Tenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168) and
// web_storage_manager (§169). Eight methods.
//
// No `messageChannelSuffix`: `androidx.webkit.ProfileStore` is process-global, so there is one
// channel rather than one per WebView.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No** -- this channel carries none, which is why it was pickable.
//   2. `@async`? **None of the eight, and that is measured rather than assumed.** Every method this
//      channel calls is a plain synchronous return on `ProfileStore` or `Profile` -- read from the
//      androidx 1.17.0 sources, not inferred from the call site. `Profile` does have
//      callback-shaped methods (`prefetchUrlAsync`), but this channel calls none of them. So the
//      §172 standing rule ("every new `@async` host method gets `replyingOnThrow`") has **nothing
//      to apply to here**: Pigeon wraps synchronous host methods in `try`/`catch` itself, and
//      [ProfileStoreHostApi.deleteProfile] relies on exactly that wrapping. Adding the helper
//      anyway would not compile -- there is no callback to reply through.
//   3. A branch that never calls `result`? **None** -- all eight audited. What this schema decides
//      instead is which replies were *meaningless*; see the three `void` methods below.
//   4. Dart `int` -> Kotlin `Long`? **No ints on this channel at all.**
//   5. Payload type shared with another channel? **No.** `androidx.webkit.CustomHeader` is imported
//      by exactly one Kotlin file in the module (`ProfileStoreManager.kt`, measured by grep), and
//      `CustomHeaderData` collides with none of the 14 data classes the other nine schemas already
//      generate into this one package -- the check §165 learned to run first.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** Constant channel, no suffix, so §165's silent-mismatch risk
//      does not apply here.
//   8. Event named after a callback? **No events at all** -- this API is HostApi-only, so §14's
//      forwarding-class problem does not arise.
//   9. Fields the wire carries that the platform never reads? **None** -- the first schema in this
//      run that can say that. `CustomHeader.toMap()` emits exactly `name`, `value` and
//      `originRules`, the Kotlin reads all three on the way in and writes all three on the way
//      out, and the Dart `fromMap` reads all three back. Contrast §160 (seven dead fields per proxy
//      rule), §163 (nine per credential) and §168 (one always-null `isSessionOnly`).
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/profile_store.dart
//   dart format lib/src/pigeons/profile_store.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/profile_store.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/ProfileStore.g.kt',
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
/// One custom request header, mirroring the platform interface's `CustomHeader` and
/// `androidx.webkit.CustomHeader` alike.
///
/// **One type for both directions, deliberately.** The same shape goes in on [addCustomHeader] and
/// comes back out of [getCustomHeaders], so there is exactly one spelling of it on the wire and the
/// compiler enforces that they agree -- §168's reason for a single `CookieToSetData`, applied here
/// before a second spelling could appear rather than after.
class CustomHeaderData {
  CustomHeaderData({
    required this.name,
    required this.value,
    required this.originRules,
  });

  /// Matched **case-insensitively** by the platform. The casing first added is the casing sent.
  final String name;

  /// Matched **case-sensitively** by the platform -- the asymmetry with [name] is why
  /// [ProfileStoreHostApi.getCustomHeaders] picks an androidx overload rather than letting Dart
  /// filter the full set.
  final String value;

  /// A `Set<String>` on both public sides, a `List<String>` here because the wire has no set.
  /// Never null: a header with no rules is useless but is a real, representable state, and
  /// collapsing empty to null would read as "every origin" (pinned by
  /// `an empty rule set survives rather than becoming null`).
  final List<String> originRules;
}

@HostApi()
abstract class ProfileStoreHostApi {
  /// Every profile that exists, including the default one.
  ///
  /// Answers an **empty list** when `MULTI_PROFILE` is unsupported, which is indistinguishable from
  /// a device that genuinely has no profiles -- except that it cannot happen, because the default
  /// profile is always listed. So the empty list is unambiguous in practice: it means the feature is
  /// missing. Preserved from the hand-written channel.
  List<String> getAllProfileNames();

  /// Creates the profile called [name] if needed, answering the name the platform actually gave it.
  ///
  /// 🚨 **`String?`, and the null is load-bearing.** Null means `MULTI_PROFILE` is unsupported and
  /// *nothing was created*; it is not the same as a profile whose name is empty. Collapsing the two
  /// would let a caller hand `""` to `InAppWebViewSettings.profileName` believing it had a profile.
  ///
  /// The name is read back off the returned `Profile` rather than echoing [name], so the reply
  /// reflects what the platform created. That also means the reply is not free of consequence:
  /// creating a profile **loads it into memory for the life of the process**, which is what makes
  /// [deleteProfile] refuse it afterwards.
  String? getOrCreateProfile(String name);

  /// Deletes the profile called [name].
  ///
  /// Answers `false` for "no such profile" and for "`MULTI_PROFILE` unsupported". It **throws** for
  /// the two refusals, and that is the interesting part of this method.
  ///
  /// 🚨 **The Kotlin must throw `FlutterError("ProfileStoreManager", …)`, not let androidx's
  /// exception propagate.** androidx raises two different classes -- `IllegalStateException` when a
  /// living WebView holds the profile or the profile was loaded this run, `IllegalArgumentException`
  /// when the name is the default profile -- and Pigeon's `wrapError` derives
  /// `PlatformException.code` from `javaClass.simpleName` for anything that is not a `FlutterError`.
  /// Letting them propagate would therefore replace one stable code with two exception-class names.
  ///
  /// That code is not incidental: §171 leaned on `PlatformException(code: "ProfileStoreManager",
  /// "Cannot delete in-use profile")` as its example of a *clean* platform error, in contrast to the
  /// `channel-error` a dead handler produces. `profile_store_delete.dart` pins it on a device, with
  /// both refusals asserted so that the normalisation is observable rather than implied -- a single
  /// refusal would report `"IllegalStateException"` under the broken version and look like a rename.
  ///
  /// Not `@async` despite throwing: see checklist item 2. Pigeon's synchronous wrapper is precisely
  /// what carries the `FlutterError` into the error envelope.
  bool deleteProfile(String name);

  /// Adds [header] to the profile named [profileName], or to the default profile when it is null.
  ///
  /// 🚨 **`void`, where the old channel answered a constant `true`.** The hand-written handler ran
  /// `customHeaderProfile(call)?.addCustomHeader(...)` and then replied `true` unconditionally --
  /// including when `CUSTOM_REQUEST_HEADERS` was missing, and when the named profile did not exist,
  /// in which case the elvis swallowed the call and nothing was added. The Dart side declares
  /// `Future<void>` and discarded that `true` anyway, so dropping it changes nothing observable and
  /// stops the wire carrying a value that never meant anything.
  ///
  /// This is the mirror image of §169's finding on `web_storage_manager`, where the host computed a
  /// meaningful answer that Dart threw away. Here the host threw away the meaning and Dart was
  /// discarding the husk. Making it honestly answerable is a platform-interface change (`Future<bool>`
  /// on five methods), not a transport one, and is filed rather than done here.
  void addCustomHeader(CustomHeaderData header, String? profileName);

  /// Whether the profile carries any header called [headerName], matched case-insensitively.
  ///
  /// `bool`, not `bool?`: `false` here collapses "no such header" with "the profile or the feature
  /// could not be resolved". That collapse predates this migration -- the Kotlin had `?: false` and
  /// the Dart `?? false` -- and is preserved rather than fixed, because widening it is a change to
  /// `PlatformProfileStore.hasCustomHeader`'s declared `Future<bool>`. Contrast `hasCookies` in
  /// `cookie_manager.dart`, where §168 *did* have a `bool?` to preserve.
  bool hasCustomHeader(String headerName, String? profileName);

  /// The profile's headers, optionally filtered.
  ///
  /// The three androidx overloads collapse into one method with two optional arguments, and **the
  /// Kotlin picks the overload** -- it does not filter a full set in Dart. That is not a style
  /// preference: androidx matches [CustomHeaderData.name] case-insensitively and
  /// [CustomHeaderData.value] case-sensitively, so a Dart-side `where` would get the mixed-case
  /// cases wrong. A null [headerName] selects the unfiltered overload; a non-null [headerName] with
  /// a null [headerValue] selects the name-only one.
  ///
  /// Answers an empty list when the profile or the feature could not be resolved.
  List<CustomHeaderData> getCustomHeaders(
    String? headerName,
    String? headerValue,
    String? profileName,
  );

  /// Removes headers called [headerName] -- every value under that name when [headerValue] is null,
  /// otherwise only the one with that exact value.
  ///
  /// `void`; see [addCustomHeader] for why the old constant `true` is gone.
  void clearCustomHeader(
    String headerName,
    String? headerValue,
    String? profileName,
  );

  /// Removes every header from the profile. `void`; see [addCustomHeader].
  void clearAllCustomHeaders(String? profileName);
}
