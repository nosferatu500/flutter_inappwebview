// Pigeon schema for the cookie-manager channel.
//
// Eighth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
// credential_database (§163) and both web_message channels (§165). Twelve methods -- the largest
// so far, and the first to mix synchronous and `@async` host methods in one API.
//
// No `messageChannelSuffix`: `android.webkit.CookieManager` is process-global, so there is one
// channel rather than one per WebView.
//
// Pre-schema checklist (§160-§165), all nine run before writing this:
//   1. Settings payload? **No** -- this channel carries none, which is why it was pickable at all.
//   2. `@async`? **Five of twelve.** `setCookie`, `setCookies`, `deleteCookie`, `deleteAllCookies`
//      and `removeSessionCookies` signal completion through a `ValueCallback`. `deleteCookies`
//      does **not**, despite looking identical -- see [CookieManagerHostApi.deleteCookies].
//   3. A branch that never calls `result`? **None** -- all twelve audited. What this schema decides
//      instead is *nullability*; see the `bool?` trio below.
//   4. Dart `int` -> Kotlin `Long`? **Yes**, `maxAge` and `expiresDate`. See [CookieToSetData].
//   5. Payload type shared with another channel? **No.** No other Kotlin channel carries a cookie
//      payload -- `WebViewChannelDelegate` was checked explicitly, since an unprefixed name
//      colliding there would force the two into one commit (§165).
//   6. `includeErrorClass: false` -- yes, as every schema but find_interaction.
//   7. Per-instance channel? **No.** Constant channel, no suffix, so §165's silent-mismatch risk
//      does not apply here.
//   8. Event named after a callback? **No events at all** -- this API is HostApi-only, so §14's
//      forwarding-class problem does not arise.
//   9. Fields the wire carries that the platform never reads? **Yes, one** -- see [CookieData].
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/cookie_manager.dart
//   dart format lib/src/pigeons/cookie_manager.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/cookie_manager.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/CookieManager.g.kt',
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
/// One cookie **read back** from the store, mirroring the platform interface's `Cookie`.
///
/// 🚨 **`isSessionOnly` is deliberately absent, and that is a wire finding.** The public `Cookie`
/// declares it, and the old Kotlin seeded it into every map:
///
/// ```kotlin
/// "isSessionOnly" to null,
/// ```
///
/// ...and then **never assigned it again, on either branch**. Measured by grep over the whole
/// module: that line is the only occurrence in the Kotlin source. So Android has always answered
/// `isSessionOnly: null` for every cookie ever returned. Carrying it would be one always-null key
/// per cookie, the same finding as §160's seven-fields-per-proxy-rule and §163's nine-per-credential.
/// The Dart side keeps passing `null` for it when rebuilding the public object, so nothing observable
/// changes.
///
/// Everything else stays nullable because it genuinely can be absent: without
/// `WebViewFeature.GET_COOKIE_INFO` the platform hands back a bare `name=value` string and there is
/// nothing to parse the rest out of, so only [name] and [value] are ever populated on that path.
class CookieData {
  CookieData({
    required this.name,
    required this.value,
    this.expiresDate,
    this.domain,
    this.sameSite,
    this.isSecure,
    this.isHttpOnly,
    this.path,
  });

  /// Always present: parsed from the left of the first `=` in every branch.
  final String name;

  /// Always present, and **empty rather than null** when the cookie has no value -- the old Kotlin
  /// did `if (nameValue.size > 1) ... else ""`. RFC 6265 §4.1.1 permits an empty value, so this
  /// is a real state, not a missing one.
  final String value;

  /// Epoch milliseconds. Crosses as a Dart `int`, which Pigeon maps to Kotlin `Long` -- which is
  /// exactly what the `Expires` parse (`Date.getTime()`) and the `Max-Age` arithmetic already
  /// produce, so this direction needs no narrowing.
  final int? expiresDate;

  final String? domain;

  /// The platform's own spelling (`Lax` / `Strict` / `None`), not the Dart enum: the Dart side
  /// rebuilds `HTTPCookieSameSitePolicy` with `fromNativeValue`, as before.
  final String? sameSite;

  final bool? isSecure;
  final bool? isHttpOnly;
  final String? path;
}

/// One cookie **to write**, mirroring the platform interface's `CookieToSet`.
///
/// 🚨 **This type is what makes the singular and plural writes provably one code path.** The
/// hand-written Dart carried a comment explaining that `setCookies` had to hand-build its per-cookie
/// map rather than use `CookieToSet.toMap()`, because the generated map sent `expiresDate` as an
/// `int` while the singular `setCookie` had always sent it as a **String** -- and that
/// "two spellings of one value on one channel is how a field ends up silently null on the platform
/// side". The fix was to keep both spellings identical by hand.
///
/// One Pigeon type removes the hazard rather than managing it: both methods take this, so there is
/// exactly one spelling and the compiler enforces it. The hand-written `_cookieToSetChannelArgs`
/// helper goes with it.
///
/// [expiresDate] is therefore now a typed `int` on the wire in both directions, and the
/// `toString()` / `toLong()` round trip through a decimal string is gone. Android-only: iOS has its
/// own channel and is untouched by this.
class CookieToSetData {
  CookieToSetData({
    required this.url,
    required this.name,
    required this.value,
    required this.path,
    this.domain,
    this.expiresDate,
    this.maxAge,
    this.isSecure,
    this.isHttpOnly,
    this.sameSite,
  });

  final String url;
  final String name;
  final String value;

  /// Non-null: the public API defaults it to `"/"`, so it is never absent by the time it reaches
  /// the wire.
  final String path;

  final String? domain;

  /// Epoch milliseconds; see [CookieData.expiresDate].
  final int? expiresDate;

  /// Seconds. Dart `int` -> Kotlin **`Long`** (checklist item 4). It is only interpolated into the
  /// `Max-Age=` attribute of a `Set-Cookie` string, so the Kotlin builder takes a `Long?` directly
  /// rather than narrowing with `.toInt()`: a narrowing here would buy nothing and could only lose
  /// information. (§162 hit the narrowing case because androidx demanded an `Int`; nothing does
  /// here.)
  final int? maxAge;

  final bool? isSecure;
  final bool? isHttpOnly;

  /// See [CookieData.sameSite].
  final String? sameSite;
}

@HostApi()
abstract class CookieManagerHostApi {
  /// Writes one cookie, answering whether the platform accepted it.
  ///
  /// `@async`: `CookieManager.setCookie` reports the outcome through a `ValueCallback<Boolean>`,
  /// and the reply is that callback's argument. Without `@async` Pigeon would generate a
  /// synchronous host method and the answer would be sent before the platform had produced one --
  /// §160's finding, where `await` resolved before the proxy was actually in effect.
  @async
  bool setCookie(CookieToSetData cookie, String? profileName);

  /// Writes several cookies in one round trip, answering one bool per cookie **in the order given**.
  ///
  /// `@async` for the same reason as [setCookie], compounded: the Kotlin fills a fixed-size array by
  /// index and replies only once the last callback has landed, because collecting by completion
  /// order would scramble the mapping this return type promises.
  ///
  /// An empty list answers an empty list without touching the platform. That short-circuit lives on
  /// the **Dart** side and is why `setCookies with an empty list is a no-op` survives a dead channel
  /// (§166) -- it is a genuine negative control, not migration coverage.
  @async
  List<bool> setCookies(List<CookieToSetData> cookies, String? profileName);

  /// Every cookie the store holds for [url].
  ///
  /// Synchronous: `CookieManager.getCookie` and `CookieManagerCompat.getCookieInfo` both return
  /// directly. Answers an empty list when the store cannot be resolved, as before.
  List<CookieData> getCookies(String url, String? profileName);

  /// Deletes one cookie by writing it back expired (`Max-Age=-1`).
  ///
  /// `@async`: the expiring write goes through `setCookie`'s `ValueCallback`, and its argument is
  /// the reply.
  @async
  bool deleteCookie(
    String url,
    String name,
    String? domain,
    String path,
    String? profileName,
  );

  /// Deletes every cookie for [url] by expiring each one.
  ///
  /// 🚨 **Not `@async`, although it is the only sibling of [deleteCookie] that isn't.** It expires
  /// each cookie with `manager.setCookie(url, value, null)` -- passing a **null** callback -- and
  /// then answers `true` synchronously. So completion is not callback-signalled here and §162's
  /// rule applies in its corrected form: `@async` iff *completion* is callback-signalled, not
  /// merely if a callback appears nearby. Marking this `@async` would be harmless but would
  /// misdescribe it; leaving [deleteCookie] synchronous would not be.
  ///
  /// Note the consequence, which predates this migration and is preserved: the `true` means "the
  /// expiring writes were issued", not "they succeeded".
  bool deleteCookies(
    String url,
    String? domain,
    String path,
    String? profileName,
  );

  /// Empties the store. `@async` -- `removeAllCookies` is `ValueCallback`-completed.
  @async
  bool deleteAllCookies(String? profileName);

  /// Removes only session cookies. `@async` -- `removeSessionCookies` is `ValueCallback`-completed.
  @async
  bool removeSessionCookies(String? profileName);

  /// Forces pending writes to disk.
  ///
  /// Synchronous: `CookieManager.flush()` returns void and blocks. The reply is a literal `true`,
  /// which is what P0b.9 / §55 was about -- the pre-fix code returned without replying at all and
  /// the Dart future never completed. A MethodChannel has no timeout; Pigeon makes that
  /// unrepresentable.
  bool flush(String? profileName);

  /// Whether the store holds any cookie at all, store-wide.
  ///
  /// 🚨 **`bool?`, and the null is load-bearing.** Null means the store could not be resolved;
  /// `false` means it was read and is empty. Collapsing the two would tell a caller "no cookies"
  /// about a store that may well hold some -- and a caller skipping a logout-time clear on that
  /// basis would skip it wrongly. §167's `an unknown profile resolves to no store` pins this.
  bool? hasCookies(String? profileName);

  /// Whether `file://` pages may use cookies.
  ///
  /// **Takes no `profileName`** -- unlike every other method here. `allowFileSchemeCookies` is a
  /// *static* on the framework class, so there is no instance to scope. The Kotlin still resolves a
  /// manager first, purely as a guard: the static throws if no WebView provider is installed, and
  /// the resolver already turns that case into the same null this returns.
  ///
  /// `bool?` for that reason; see [hasCookies].
  bool? isFileSchemeCookiesAllowed();

  /// The cookie master switch. Answers whether the switch was applied.
  ///
  /// Note this governs cookies flowing through the WebView's own traffic, **not** the app's
  /// programmatic writes -- `setCookie` still succeeds with this off, measured on both platforms
  /// and pinned by `accept cookie master switch`.
  bool setAcceptCookie(bool accept, String? profileName);

  /// Reads the master switch. `bool?`; see [hasCookies] -- "not accepting" and "could not read"
  /// are different answers and the platform default is `true`, so `false` would be the more
  /// misleading collapse of the two.
  bool? isAcceptCookieEnabled(String? profileName);
}
