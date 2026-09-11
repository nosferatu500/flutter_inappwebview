// Pigeon schema for the credential-database channel.
//
// Sixth channel migrated off hand-written MethodChannel dispatch, after find_interaction (§14),
// process_global_config (§157), proxy (§160), webview_feature (§161) and tracing_controller (§162).
// Six methods, and the first with **structured return values** rather than scalars.
//
// No `messageChannelSuffix`: the credential database is a process-wide singleton keyed on the
// application context, so there is one channel rather than one per WebView.
//
// Pre-schema checks from §160/§161/§162, all applied:
//   * `@async`? **No.** Every call goes to a synchronous SQLite DAO -- no executor, no callback.
//   * A branch that never calls `result`? **None**; every arm answered.
//   * Dart `int` -> Kotlin `Long`? **Yes** -- `port` is an int, so it needs `.toInt()` at the
//     boundary. Only `compileDebugKotlin` catches that (§162).
//
// Regenerate with BOTH steps, from flutter_inappwebview_android/:
//   dart run pigeon --input pigeons/credential_database.dart
//   dart format lib/src/pigeons/credential_database.g.dart
//
// The format pass is not optional: Pigeon's Dart output does not satisfy this repo's
// `dart format --set-exit-if-changed` gate.
//
// Do not edit the generated files; edit this schema and regenerate.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/credential_database.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dev/nosferatu500/inappwebview/pigeons/CredentialDatabase.g.kt',
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
/// Mirrors the **Android-relevant half** of the platform interface's `URLProtectionSpace`.
///
/// `URLProtectionSpace` declares ten fields. Five are iOS-only (`authenticationMethod`,
/// `distinguishedNames`, `receivesCredentialSecurely`, `isProxy`, `proxyType`) and the Kotlin
/// `toMap()` sent every one of them as a **literal null** on the way back:
///
/// ```kotlin
/// "authenticationMethod" to null, "distinguishedNames" to null, …
/// ```
///
/// Two more — `sslCertificate` and `sslError` — are real on Android but **can never be non-null on
/// this channel**: the credential database's DAO builds every row through the five-argument
/// `URLProtectionSpace(id, host, protocol, realm, port)` constructor, which sets both to null, and
/// the insert path does the same. They are populated only for the SSL/auth-challenge callbacks on
/// the WebView channel, which is a different channel. So this type names the four fields the
/// database actually stores; the Dart side rebuilds the public object with the rest left at their
/// defaults, which is exactly what arrived before.
///
/// That is seven always-null keys per protection space removed from the wire — the outbound
/// counterpart of §160's inbound `ProxyRule` finding.
class URLProtectionSpaceData {
  URLProtectionSpaceData({
    required this.host,
    this.protocol,
    this.realm,
    this.port,
  });

  /// Non-null: the platform interface declares `String host` and requires it in the constructor.
  final String host;

  /// 🚨 **Nullable on purpose, and it is the reason this migration is also a fix.**
  ///
  /// The platform interface declares `String? protocol` and `int? port`, and its constructor
  /// requires only `host` — so `URLProtectionSpace(host: 'example.com')` is legal and leaves both
  /// null. The Kotlin handler then did `call.argument("protocol")!!` and `call.argument("port")!!`
  /// inside `setHttpAuthCredential`, because `CredentialDatabase.setHttpAuthCredential` takes them
  /// non-null.
  ///
  /// Measured on an API 37 device against the pre-migration code, that combination produced:
  /// `PlatformException(error, null, null, java.lang.NullPointerException)` — an opaque envelope
  /// with a null message and null details, telling the caller nothing.
  ///
  /// Typing them nullable keeps the wire faithful to what the public API can express, and the
  /// Kotlin side now rejects the case with a message that names the two fields. See
  /// [CredentialDatabaseHostApi.setHttpAuthCredential].
  ///
  /// `getHttpAuthCredentials`, `removeHttpAuthCredential` and `removeHttpAuthCredentials` always
  /// accepted null here — they forward to a `find(host?, protocol?, realm?, port?)` lookup — and
  /// keep doing so.
  final String? protocol;

  final String? realm;

  /// See [protocol]. Crosses as a Dart `int`, which Pigeon maps to Kotlin `Long`, so the manager
  /// narrows it with `.toInt()` for the `Int` the DAO expects (§162).
  final int? port;
}

/// Mirrors the **Android-relevant half** of the platform interface's `URLCredential`.
///
/// `certificates` and `persistence` are iOS-only and the Kotlin `toMap()` sent both as literal
/// nulls; they are omitted here for the same reason as [URLProtectionSpaceData]'s five.
class URLCredentialData {
  URLCredentialData({this.username, this.password});

  final String? username;
  final String? password;
}

/// Mirrors the platform interface's `URLProtectionSpaceHttpAuthCredentials`.
///
/// Both fields are non-null here even though the public type declares them nullable: this is only
/// ever built by the host from a database row it has just read, so there is no way for either to be
/// absent. Making that explicit means the Dart side does no null-handling for a case the host
/// cannot produce.
class URLProtectionSpaceHttpAuthCredentialsData {
  URLProtectionSpaceHttpAuthCredentialsData({
    required this.protectionSpace,
    required this.credentials,
  });

  final URLProtectionSpaceData protectionSpace;
  final List<URLCredentialData> credentials;
}

@HostApi()
abstract class CredentialDatabaseHostApi {
  /// Every protection space in the database, each with its credentials.
  ///
  /// Returns an empty list when there is no database, which is what the hand-written channel did —
  /// it built the list before the null check and answered with whatever it had.
  List<URLProtectionSpaceHttpAuthCredentialsData> getAllAuthCredentials();

  /// The credentials stored for [protectionSpace], or an empty list if it is not in the database.
  List<URLCredentialData> getHttpAuthCredentials(
    URLProtectionSpaceData protectionSpace,
  );

  /// Stores [credential] against [protectionSpace], returning whether it was stored.
  ///
  /// `false` means there was no database. **Throws** — with a message naming the fields — when
  /// `protectionSpace.protocol` or `.port` is null, because the database keys rows on both and
  /// cannot store a row without them. That replaces the bare `NullPointerException` the
  /// force-unwrapped Kotlin produced; see [URLProtectionSpaceData.protocol] for the measurement.
  ///
  /// The Dart side discards the bool because the platform interface declares
  /// `Future<void> setHttpAuthCredential(...)`; it stays on the wire so the no-database case
  /// remains distinguishable, as in §157/§160/§162.
  bool setHttpAuthCredential(
    URLProtectionSpaceData protectionSpace,
    URLCredentialData credential,
  );

  /// Removes one credential. Silently does nothing if the protection space or credential is not
  /// found — a lookup miss is not an error.
  bool removeHttpAuthCredential(
    URLProtectionSpaceData protectionSpace,
    URLCredentialData credential,
  );

  /// Removes the protection space and every credential under it.
  bool removeHttpAuthCredentials(URLProtectionSpaceData protectionSpace);

  /// Clears the plugin's credential database **and** the system
  /// `WebViewDatabase.clearHttpAuthUsernamePassword()`. Both, as before — the second is what
  /// WebView itself consults, so clearing only the plugin's table would leave auth working.
  bool clearAllAuthCredentials();
}
