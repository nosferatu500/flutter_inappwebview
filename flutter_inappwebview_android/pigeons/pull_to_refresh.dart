// Pigeon schema for the per-instance pull-to-refresh channel.
//
// Fifteenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175), print_job
// (§177), chrome_custom_tabs (§179) and headless_webview (§180).
//
// Its device group was written first, as its own item (§181), because the channel had **no**
// coverage: the one test that looked like coverage passes with the channel name broken.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No, on this channel** -- and checked by following the payload, per §181's
//      correction, not by the table's count. `PullToRefreshSettings` rides the *webview creation*
//      payload into `PullToRefreshLayout.prepare()`. Every argument here is a primitive.
//   2. `@async`? **None of the ten.** Each answers inline, so Pigeon's own `try`/`catch` is the only
//      error path and §172's `replyingOnThrow` has nothing to wrap.
//   3. A branch that never calls `result`? **None** -- all ten audited.
//   4. Dart `int` -> Kotlin `Long`? **Yes, three inbound, and one is §162's shape.**
//      `setDistanceToTriggerSync` and `setSlingshotDistance` take a plain `Int`; `setSize` narrows
//      into `SwipeRefreshLayout.setSize(@Size int)`, an `@IntDef`. §179 measured that a *single*
//      narrowed value passes lint, and §162's failure was a flag-`@IntDef` varargs array — so this
//      is not pre-emptively worked around; `lintDebug` decides. `getDefaultSlingshotDistance`
//      widens outbound, which is always safe.
//   5. Payload type shared with another channel? **None.** No data classes at all: colours cross as
//      the hex string `Color.parseColor` already takes, which keeps the conversion where it was.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes** -- the suffix is the owning webview's id, stringified on both
//      sides (`'$id'` in Dart, `id.toString()` in Kotlin). **Three owners share this channel**: the
//      `InAppWebView` widget (an int view id), `HeadlessInAppWebView` and `InAppBrowser` (string
//      ids). The device group drives the widget path only.
//      Direction coverage, per §177/§179: the **host half is covered** (§181's group, 5 tests); the
//      **event half is not**. `onRefresh` needs a real drag on a platform view, so a wrong FlutterApi
//      suffix would produce §179's 60-second silence and nothing would notice.
//   8. Event named after a callback? **Yes, and this time the collision fires.**
//      `PlatformPullToRefreshController` exposes `onRefresh` as a *getter* (the app's callback), so
//      a generated `void onRefresh()` on the same class is an inconsistent inheritance. §180 was the
//      exception (a params field); this is the rule. See `_PullToRefreshFlutterApiImpl`.
//   9. Fields the wire carries that the platform never reads? **None** -- but eight of the ten
//      answer a `bool` the Dart side discards (every setter). Preserved, as §177 and §180 did: it
//      distinguishes "the layout had already gone away" from "done", and a migration is the wrong
//      commit in which to drop a value. §180's negative-control mutant measured that such a bool is
//      genuinely unobserved.
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/pull_to_refresh.dart
//   dart format lib/src/pigeons/pull_to_refresh.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/pull_to_refresh.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/PullToRefresh.g.kt',
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
/// Every setter answers `false` when the layout has already been disposed and `true` otherwise.
/// The Dart side has never bound that value (checklist item 9).
@HostApi()
abstract class PullToRefreshHostApi {
  bool setEnabled(bool enabled);

  /// `false` also when the layout has gone away — indistinguishable from "disabled", as before.
  bool isEnabled();

  /// Backs both `beginRefreshing` (`true`) and `endRefreshing` (`false`). Moving the indicator
  /// this way does **not** fire `onRefresh`; §181 pins that.
  bool setRefreshing(bool refreshing);

  bool isRefreshing();

  /// A `#AARRGGBB` string, parsed by `Color.parseColor` on the platform side exactly as before.
  bool setColor(String color);

  /// See [setColor].
  bool setBackgroundColor(String color);

  bool setDistanceToTriggerSync(int distanceToTriggerSync);

  bool setSlingshotDistance(int slingshotDistance);

  /// `SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE`, which is **-1** — a sentinel meaning "compute
  /// the default", not a distance (§181, read out of the AAR).
  int getDefaultSlingshotDistance();

  /// The native `SwipeRefreshLayout` size constant: `LARGE = 0`, `DEFAULT = 1`. Narrowed into an
  /// `@IntDef` on the platform side (checklist item 4).
  bool setSize(int size);
}

@FlutterApi()
abstract class PullToRefreshFlutterApi {
  /// The user pulled far enough to trigger a refresh. Never fired by `setRefreshing`.
  void onRefresh();
}
