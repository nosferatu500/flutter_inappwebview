// Pigeon schema for the proxy-controller channel.
//
// Third channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14) and
// process_global_config (§157). Two methods, both process-global.
//
// No `messageChannelSuffix`: androidx's `ProxyController` is a process-wide singleton
// (`ProxyController.getInstance()`), so there is exactly one channel rather than one per WebView.
//
// The iOS package has its own `IOSProxyController` on a channel of the same name, in its own
// package. Only one platform implementation is live in a given app, so the two never coexist and
// this migration leaves the iOS side entirely alone.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/proxy.dart
//   dart format lib/src/pigeons/proxy.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/proxy.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/Proxy.g.kt',
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
/// Mirrors the **Android-relevant half** of the platform interface's `ProxyRule`.
///
/// `ProxyRule` declares **nine** fields, seven of which are iOS-only (`allowFailover`, `username`,
/// `password`, `excludedDomains`, `matchDomains`, `relayHop1`, `relayHop2`). Its generated
/// `toMap()` emits all nine unconditionally, so the hand-written channel this replaces sent seven
/// fields per rule that the Kotlin side never read.
///
/// Worse, it could not have read them: `ProxySettings.parse` casts the incoming list to
/// `List<Map<String, String>>` and `ProxyRuleExt.fromMap` takes a `Map<String, String>`, while the
/// actual payload holds bools, lists and nested maps. That cast is **false at runtime** and
/// survives only because Kotlin erases generics — it would throw the moment anything iterated the
/// values as `String`. Naming just the two fields Android reads makes the wire honest and deletes
/// the cast along with the lie.
class ProxyRuleData {
  ProxyRuleData({required this.url, this.schemeFilter});

  final String url;

  /// `ProxySchemeFilter`'s native value: `"*"`, `"http"` or `"https"`.
  ///
  /// Stays a `String` rather than becoming a Pigeon enum: androidx types this parameter as
  /// `@ProxyConfig.ProxyScheme String`, and the platform interface's `ProxySchemeFilter` is an
  /// open-ended `_internal(String)` class rather than a closed enum, so a generated enum here
  /// would reject values the public API accepts.
  ///
  /// Null means "no scheme filter", which selects androidx's one-argument
  /// `addProxyRule(url)` overload instead of `addProxyRule(url, schemeFilter)`.
  final String? schemeFilter;
}

/// Mirrors the platform interface's `ProxySettings`.
///
/// Deliberately a separate type, for the same reason as `FindSessionData` and
/// `ProcessGlobalConfigSettingsData`: the platform-interface version is the public API and is
/// shared with iOS, so it cannot be Pigeon-generated without coupling every platform to this
/// schema.
class ProxySettingsData {
  ProxySettingsData({
    required this.bypassRules,
    required this.directs,
    required this.proxyRules,
    required this.reverseBypassEnabled,
    this.bypassSimpleHostnames,
    this.removeImplicitRules,
  });

  final List<String> bypassRules;
  final List<String> directs;
  final List<ProxyRuleData> proxyRules;

  /// **Non-null on purpose.** The platform interface declares `bool reverseBypassEnabled` with a
  /// default of `false`, so Dart can never send null — but the Kotlin side stored it as `Boolean?`
  /// and gated the androidx call on `reverseBypassEnabled != null && isFeatureSupported(...)`.
  /// That null check could never fail, so typing it `required` here changes no behaviour and makes
  /// the guarantee the Kotlin code already relied on part of the wire contract. Same situation as
  /// `ProcessGlobalConfigDirectoryBasePathsData`'s two paths (§157).
  final bool reverseBypassEnabled;

  /// Tri-state, and the third state matters: androidx's `bypassSimpleHostnames()` is a *builder
  /// call*, not a setter, so there is no way to ask for "off". Null and `false` both mean "do not
  /// call it" and only `true` invokes it. The hand-written channel expressed this as a
  /// `== true` comparison; keeping the field nullable preserves it exactly.
  final bool? bypassSimpleHostnames;

  /// Tri-state for the same reason as [bypassSimpleHostnames] — `removeImplicitRules()` is also a
  /// builder call with no inverse.
  final bool? removeImplicitRules;
}

@HostApi()
abstract class ProxyHostApi {
  /// **`@async` is load-bearing, not a style choice.**
  ///
  /// androidx's `ProxyController.setProxyOverride` takes an `Executor` and a completion
  /// `Runnable`; the hand-written channel called `result.success(true)` from *inside* that
  /// callback. Without `@async` Pigeon emits `fun setProxyOverride(...): Boolean`, which must
  /// return before the callback can possibly have run — so `await` would resolve while the proxy
  /// was not yet in effect. That is a silent behaviour change and the reason this pair is
  /// annotated: `@async` gives Kotlin a `(Result<Boolean>) -> Unit` callback to hand the
  /// completion to.
  ///
  /// Returns whether the override was applied.
  ///
  /// `false` means androidx does not support `PROXY_OVERRIDE` on this WebView, so there was no
  /// `ProxyController` to apply the settings to and they were silently dropped.
  ///
  /// The Dart side **discards this value**, because the platform interface declares
  /// `Future<void> setProxyOverride(...)`. Keeping the bool on the wire preserves the hand-written
  /// channel's semantics exactly and keeps the unsupported case distinguishable from success for
  /// anyone who later wants to surface it; collapsing it to `void` would throw that away
  /// silently. Same call as `ProcessGlobalConfigHostApi.apply` (§157).
  ///
  /// Completion is **asynchronous on the platform side**: androidx takes an `Executor` and a
  /// callback, and this only returns once that callback has run, so awaiting it means the proxy is
  /// actually in effect.
  @async
  bool setProxyOverride(ProxySettingsData settings);

  /// Returns whether the override was cleared, with `false` carrying the same
  /// "`PROXY_OVERRIDE` unsupported" meaning as [setProxyOverride], and likewise discarded by Dart.
  ///
  /// `@async` for the same reason as [setProxyOverride] — `clearProxyOverride` is also
  /// executor-plus-callback on the androidx side.
  @async
  bool clearProxyOverride();
}
