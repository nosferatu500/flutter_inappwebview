// Pigeon schema for the chrome-custom-tabs channel.
//
// Thirteenth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163), both web_message channels (§165), cookie_manager (§168),
// web_storage_manager (§169), profile_store (§173), geolocation_permissions (§175) and print_job
// (§177).
//
// 🚨 **The TODO table's `9 0` hides more than print_job's `4 0` did.** Nine host methods, yes — plus
// **thirteen events**, a per-instance channel, and a nested inbound payload. Twenty-two channel
// members, second only to `WebViewChannelDelegate`.
//
// **This migrates the per-instance delegate only.** `AndroidChromeSafariBrowser` talks to *two*
// channels: this one, and a separate static `ChromeSafariBrowserManager` channel carrying `open`,
// `isAvailable`, `getMaxToolbarItems` and `getPackageName`. `open` takes the settings payload, which
// is why the manager shows as `4 7` in the table and stays blocked with `InAppBrowserManager`. After
// this commit the Dart class holds a Pigeon HostApi *and* a raw `MethodChannel` for the manager;
// that is deliberate and the two are independent.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No, on this channel.** `ChromeCustomTabsSettings` is read from the
//      Intent bundle when the activity is created, not sent over this channel. Checked by reading,
//      not by grepping the count.
//   2. `@async`? **None of the nine.** Every host method answers inline. The thirteen events are a
//      `FlutterApi`, not completion signals -- the same distinction as §165's `setWebMessageCallback`
//      and §162's `TracingController.stop`.
//   3. A branch that never calls `result`? **None** -- all nine audited; each has an explicit
//      null-activity or null-session arm that answers.
//   4. Dart `int` -> Kotlin `Long`? **Yes, and exactly one of them is the dangerous direction.**
//      Everything else is outbound and widens safely; [validateRelationship] takes `relation`
//      *inbound* and androidx wants an `Int`. See that method -- §162's `[WrongConstant]` lint trap
//      lives there.
//   5. Payload type shared with another channel? **`AndroidResource` is, and this schema is where it
//      first crosses a Pigeon wire.** It is also used by `InAppBrowserMenuItem` and by
//      `ChromeCustomTabsSettings`. So when `InAppBrowserManager` eventually migrates it will want an
//      `AndroidResourceData` too, and Pigeon emits unprefixed names into one shared Kotlin package --
//      which is precisely the collision that forced §165 to put two channels in one commit. Recorded
//      as a **prediction** rather than pre-empted with an ugly prefix: the resolution (merge the two
//      schemas, as §165 did) is known, and inventing `CustomTabsAndroidResourceData` now would
//      guarantee a duplicate of an identical type later.
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **Yes** -- `messageChannelSuffix` carries the view id. §177 measured
//      what a mismatch costs, and it differs by direction: a HostApi mismatch fails in ~2s naming
//      the channel, a FlutterApi one hangs silently. **This channel's thirteen events make the
//      silent half much larger than it was on print_job.**
//   8. Event named after a callback? **Yes -- eleven of the thirteen**, and every one collides. See
//      [ChromeCustomTabsFlutterApi].
//   9. Fields the wire carries that the platform never reads? **None** -- all nine methods' argument
//      names were diffed against what the Kotlin reads and they match exactly. The one place a
//      field is dropped is deliberate and belongs to Dart: see [CustomTabsSecondaryToolbarData].
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/chrome_custom_tabs.dart
//   dart format lib/src/pigeons/chrome_custom_tabs.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/chrome_custom_tabs.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/ChromeCustomTabs.g.kt',
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
/// An Android resource reference, mirroring the public `AndroidResource`.
///
/// See checklist item 5: this type is shared with `InAppBrowserMenuItem` and
/// `ChromeCustomTabsSettings`, so the name is expected to collide when `InAppBrowserManager`
/// migrates. That is recorded rather than worked around.
class AndroidResourceData {
  AndroidResourceData({required this.name, this.defType, this.defPackage});

  final String name;
  final String? defType;
  final String? defPackage;
}

/// The remote-views toolbar shown below a Custom Tab.
///
/// 🚨 **`clickableIDs` is flattened to a plain list of resources, and that is not a shortcut.** The
/// public `ChromeSafariBrowserSecondaryToolbarClickableID` has two fields -- an `id` and an
/// `onClick` handler -- but `onClick` is a Dart closure and has never crossed the wire: its
/// `toMap()` emits `{"id": …}` and nothing else, and the Kotlin reads exactly
/// `clickableIDMap["id"]`. So the wrapper object was a one-key envelope on both sides. Flattening
/// removes it; the Dart side keeps the handlers, which is where they were always kept and where the
/// `onSecondaryItemActionPerform` event dispatches to them by name.
class CustomTabsSecondaryToolbarData {
  CustomTabsSecondaryToolbarData({
    required this.layout,
    required this.clickableIDs,
  });

  final AndroidResourceData layout;
  final List<AndroidResourceData> clickableIDs;
}

/// Dart -> platform, one channel per Custom Tabs activity instance.
@HostApi()
abstract class ChromeCustomTabsHostApi {
  /// Loads [url] in the already-open Custom Tab.
  ///
  /// Answers `false` when the activity is gone or [url] is null — the hand-written handler required
  /// both and answered `false` otherwise. Preserved.
  bool launchUrl(
    String url,
    Map<String, String>? headers,
    String? referrer,
    List<String>? otherLikelyURLs,
  );

  /// Asks Chrome to pre-warm [url]. Answers Chrome's own answer, or `false` with no activity.
  bool mayLaunchUrl(String? url, List<String>? otherLikelyURLs);

  /// Replaces the toolbar action button's icon and description.
  ///
  /// [icon] is a `Uint8List` and crosses as raw bytes; the hand-written channel sent the same
  /// `ByteArray` through the standard codec.
  bool updateActionButton(Uint8List icon, String description);

  /// Asks Chrome to verify a digital-asset-link relation between this app and [origin].
  ///
  /// 🚨 **The one inbound `int` on this channel, and §162's lint trap is aimed straight at it.**
  /// Pigeon maps Dart `int` to Kotlin `Long`; androidx's
  /// `CustomTabsSession.validateRelationship(@Relation int, Uri, Bundle)` wants an `Int`, and
  /// `@Relation` is an `@IntDef`. §162 found that the obvious `.toInt()` narrowing **compiles
  /// cleanly and fails `lintDebug` with `[WrongConstant]`**, because lint cannot see that a runtime
  /// value is one of the permitted constants. Whether it fires here is measured at the lint gate,
  /// not predicted — §162's own fix (a per-element loop) was specific to a *flag* IntDef and has no
  /// analogue for a single value.
  ///
  /// Answers `false` when there is no session. Note that `true` means only that the request was
  /// *accepted*; the verdict arrives on [ChromeCustomTabsFlutterApi.onRelationshipValidationResult],
  /// and §178 measured that it never arrives for this fork at all — the asset-links file for
  /// `inappwebview.dev` delegates to the upstream package, so the test covering this is skipped.
  bool validateRelationship(int relation, String origin);

  /// Replaces the secondary toolbar. Answers `false` when the activity is gone.
  bool updateSecondaryToolbar(CustomTabsSecondaryToolbarData secondaryToolbar);

  /// Asks Chrome to open a post-message channel from [sourceOrigin].
  ///
  /// 🚨 **`true` here does not mean a channel exists** — it means the request was accepted.
  /// [ChromeCustomTabsFlutterApi.onMessageChannelReady] is what says a channel is open, and Chrome
  /// only fires it after verifying digital asset links. §178 measured the gap: this method answered
  /// `true` and `onMessageChannelReady` never fired, hanging its test for a full 60 seconds.
  ///
  /// **That test is now skipped**, so this method and [postMessage] have *no* device coverage — see
  /// the Residue note in §178. Do not read a green `chrome_safari_browser` run as covering them.
  bool requestPostMessageChannel(String sourceOrigin, String? targetOrigin);

  /// Posts a message through an open channel.
  ///
  /// Answers `CustomTabsService`'s own result code, and **`RESULT_FAILURE_MESSAGING_ERROR` when
  /// there is no session** — a value, not a `false`, which is why this returns `int` rather than
  /// `bool`. Preserved exactly; the Dart side maps it to `CustomTabsPostMessageResultType`.
  int postMessage(String message);

  /// Whether Chrome will deliver engagement signals for this session.
  ///
  /// The hand-written handler wrapped this in `try`/`catch (Throwable)` answering `false`, because
  /// the androidx call throws on builds that do not implement it. Preserved rather than allowed to
  /// propagate: turning "unsupported" into a `PlatformException` would be a behaviour change.
  bool isEngagementSignalsApiAvailable();

  /// Closes the Custom Tab and brings the host activity back. Answers `false` when already gone.
  bool close();
}

/// Platform -> Dart, on the same per-instance channel.
///
/// 🚨 **Eleven of these thirteen names collide with the public API, so none of them can be
/// implemented directly on the controller.** `PlatformChromeSafariBrowserEvents` declares
/// `onServiceConnected`, `onOpened`, `onNavigationEvent` and the rest as **methods with domain
/// types** — `onNavigationEvent(CustomTabsNavigationEventType?)`, not `onNavigationEvent(int)` — and
/// users override them. A class cannot both inherit those and implement the generated ones.
///
/// So the events go through a private forwarder that converts each wire value into its domain type
/// before calling the public method, exactly as §14 did for `onFindResultReceived` and §177 for
/// `onComplete`. This is the third time P0a item 4's prediction has landed, and the largest: it is
/// the difference between a schema that compiles and one that does not.
///
/// Note also checklist item 7: a `messageChannelSuffix` mismatch on *this* direction fails
/// **silently** (§177 measured the asymmetry), and thirteen events is a lot of silence.
@FlutterApi()
abstract class ChromeCustomTabsFlutterApi {
  void onServiceConnected();

  void onOpened();

  /// 🚨 **Takes no argument, although the public callback does.**
  /// `PlatformChromeSafariBrowserEvents.onCompletedInitialLoad(bool? didLoadSuccessfully)` is read
  /// from `call.arguments["didLoadSuccessfully"]` today — and the Kotlin sends
  /// `hashMapOf<String, Any?>()`, an **empty map**. So the value has always been null on Android; it
  /// is an iOS-supplied field on a shared callback.
  ///
  /// Modelling it would put a permanently-null argument on the wire, which is §160's finding
  /// recreated. The forwarder passes `null` explicitly instead, which is exactly what an absent key
  /// already produced — the same call §177 made for `PrintJobInfo`'s fourteen.
  void onCompletedInitialLoad();

  /// `int` on the wire, `CustomTabsNavigationEventType?` in the public callback — the conversion is
  /// the forwarder's job and is the reason the forwarder exists.
  void onNavigationEvent(int navigationEvent);

  void onClosed();

  /// The action button's id, plus the page it was pressed on.
  ///
  /// [url] and [title] are nullable because the Kotlin signature is
  /// `onItemActionPerform(id: Int, url: String?, title: String?)`. Note the Dart side reads them as
  /// **non-null** today (`String url = call.arguments["url"]`), so a null has always been an
  /// implicit-cast crash rather than a handled case. The forwarder preserves that rather than
  /// quietly fixing it — a null here is a platform contract question, not a transport one.
  void onItemActionPerform(int id, String? url, String? title);

  /// [name] is the resource *name* of the secondary-toolbar view that was clicked; the Dart side
  /// matches it against the `clickableIDs` it registered and calls that entry's `onClick`.
  void onSecondaryItemActionPerform(String? name, String? url);

  /// The verdict [ChromeCustomTabsHostApi.validateRelationship] asked for. Never fires in this fork
  /// — see that method.
  void onRelationshipValidationResult(
    int relation,
    String requestedOrigin,
    bool result,
  );

  /// Fires only after Chrome has verified asset links; see
  /// [ChromeCustomTabsHostApi.requestPostMessageChannel].
  void onMessageChannelReady();

  void onPostMessage(String message);

  void onVerticalScrollEvent(bool isDirectionUp);

  void onGreatestScrollPercentageIncreased(int scrollPercentage);

  void onSessionEnded(bool didUserInteract);
}
