import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'pigeons/credential_database.g.dart';

/// Object specifying creation parameters for creating a [AndroidHttpAuthCredentialDatabase].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformHttpAuthCredentialDatabaseCreationParams] for
/// more information.
@immutable
class AndroidHttpAuthCredentialDatabaseCreationParams
    extends PlatformHttpAuthCredentialDatabaseCreationParams {
  /// Creates a new [AndroidHttpAuthCredentialDatabaseCreationParams] instance.
  const AndroidHttpAuthCredentialDatabaseCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super();

  /// Creates a [AndroidHttpAuthCredentialDatabaseCreationParams] instance based on [PlatformHttpAuthCredentialDatabaseCreationParams].
  factory AndroidHttpAuthCredentialDatabaseCreationParams.fromPlatformHttpAuthCredentialDatabaseCreationParams(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return AndroidHttpAuthCredentialDatabaseCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformHttpAuthCredentialDatabase}
///
/// Transport is Pigeon-generated ([CredentialDatabaseHostApi]) rather than a hand-written
/// `MethodChannel`; the sixth channel migrated, after find_interaction (§14),
/// process_global_config (§157), proxy (§160), webview_feature (§161) and
/// tracing_controller (§162). There is no `messageChannelSuffix` because the credential database
/// is a process-wide singleton.
class AndroidHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase
    implements Disposable {
  /// Creates a new [AndroidHttpAuthCredentialDatabase].
  AndroidHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super.implementation(
        params is AndroidHttpAuthCredentialDatabaseCreationParams
            ? params
            : AndroidHttpAuthCredentialDatabaseCreationParams.fromPlatformHttpAuthCredentialDatabaseCreationParams(
                params,
              ),
      );

  final CredentialDatabaseHostApi _hostApi = CredentialDatabaseHostApi();

  static AndroidHttpAuthCredentialDatabase? _instance;

  ///Gets the database shared instance.
  static AndroidHttpAuthCredentialDatabase instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidHttpAuthCredentialDatabase _init() {
    _instance = AndroidHttpAuthCredentialDatabase(
      AndroidHttpAuthCredentialDatabaseCreationParams(
        const PlatformHttpAuthCredentialDatabaseCreationParams(),
      ),
    );
    return _instance!;
  }

  factory AndroidHttpAuthCredentialDatabase.static() {
    return instance();
  }

  /// Only the four fields the credential database stores cross the wire. The five iOS-only fields
  /// on [URLProtectionSpace] never applied here, and `sslCertificate`/`sslError` are populated
  /// only by the SSL/auth-challenge callbacks on a different channel -- the database's DAO builds
  /// every row with both null. See the schema.
  URLProtectionSpaceData _toData(URLProtectionSpace protectionSpace) =>
      URLProtectionSpaceData(
        host: protectionSpace.host,
        protocol: protectionSpace.protocol,
        realm: protectionSpace.realm,
        port: protectionSpace.port,
      );

  URLProtectionSpace _fromData(URLProtectionSpaceData data) =>
      URLProtectionSpace(
        host: data.host,
        protocol: data.protocol,
        realm: data.realm,
        port: data.port,
      );

  URLCredential _fromCredentialData(URLCredentialData data) =>
      URLCredential(username: data.username, password: data.password);

  @override
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
  getAllAuthCredentials() async {
    final all = await _hostApi.getAllAuthCredentials();
    return all
        .map(
          (entry) => URLProtectionSpaceHttpAuthCredentials(
            protectionSpace: _fromData(entry.protectionSpace),
            credentials: entry.credentials.map(_fromCredentialData).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<List<URLCredential>> getHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) async {
    final credentials = await _hostApi.getHttpAuthCredentials(
      _toData(protectionSpace),
    );
    return credentials.map(_fromCredentialData).toList();
  }

  @override
  Future<void> setHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) async {
    // Throws a `PlatformException` naming the fields when `protectionSpace.protocol` or `.port` is
    // null -- the database keys rows on both and the public type makes both optional. Before this
    // migration the same call produced `PlatformException(error, null, null,
    // java.lang.NullPointerException)` with no message at all. The bool is discarded because the
    // platform interface declares `Future<void>`.
    await _hostApi.setHttpAuthCredential(
      _toData(protectionSpace),
      URLCredentialData(
        username: credential.username,
        password: credential.password,
      ),
    );
  }

  @override
  Future<void> removeHttpAuthCredential({
    required URLProtectionSpace protectionSpace,
    required URLCredential credential,
  }) async {
    await _hostApi.removeHttpAuthCredential(
      _toData(protectionSpace),
      URLCredentialData(
        username: credential.username,
        password: credential.password,
      ),
    );
  }

  @override
  Future<void> removeHttpAuthCredentials({
    required URLProtectionSpace protectionSpace,
  }) async {
    await _hostApi.removeHttpAuthCredentials(_toData(protectionSpace));
  }

  @override
  Future<void> clearAllAuthCredentials() async {
    await _hostApi.clearAllAuthCredentials();
  }

  @override
  void dispose() {
    // empty -- the host API holds no per-instance registration to tear down, and this class is a
    // process-wide singleton (see createPlatformHttpAuthCredentialDatabase).
  }
}
