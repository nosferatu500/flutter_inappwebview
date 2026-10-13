package dev.nosferatu500.inappwebview.credential_database

import android.webkit.WebViewDatabase
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.CredentialDatabaseHostApi
import dev.nosferatu500.inappwebview.pigeons.URLCredentialData
import dev.nosferatu500.inappwebview.pigeons.URLProtectionSpaceData
import dev.nosferatu500.inappwebview.pigeons.URLProtectionSpaceHttpAuthCredentialsData
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([CredentialDatabaseHostApi]) rather than a hand-written
 * `MethodChannel`; the sixth channel migrated, after find_interaction (§14),
 * process_global_config (§157), proxy (§160), webview_feature (§161) and tracing_controller (§162).
 *
 * There is no `messageChannelSuffix`: the credential database is a process-wide singleton keyed on
 * the application context, so there is one channel rather than one per WebView.
 *
 * No method is `@async`: every call goes to a synchronous SQLite DAO.
 *
 * This is the first migrated channel with **structured return values**. The generated types name
 * only the fields the database stores, which drops seven always-null keys per protection space and
 * two per credential from the reply — the five iOS-only fields the old `toMap()` sent as literal
 * nulls, plus `sslCertificate`/`sslError`, which this channel can never populate.
 */
class CredentialDatabaseHandler(plugin: InAppWebViewFlutterPlugin) :
  Disposable, CredentialDatabaseHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    CredentialDatabaseHostApi.setUp(plugin.messenger, this)
  }

  /**
   * Resolved lazily on first use, as the hand-written channel did at the top of every dispatch.
   *
   * Returns null only after [dispose], when there is no plugin left to take an application context
   * from; a disposed handler should no longer be receiving calls, since [dispose] unregisters the
   * generated handler.
   */
  private fun database(): CredentialDatabase? {
    val currentPlugin = plugin ?: return null
    if (credentialDatabase == null) {
      credentialDatabase = CredentialDatabase.getInstance(currentPlugin.applicationContext)
    }
    return credentialDatabase
  }

  override fun getAllAuthCredentials(): List<URLProtectionSpaceHttpAuthCredentialsData> {
    val database = database() ?: return emptyList()
    return database.protectionSpaceDao.getAll().map { protectionSpace ->
      URLProtectionSpaceHttpAuthCredentialsData(
        protectionSpace = URLProtectionSpaceData(
          host = protectionSpace.host,
          protocol = protectionSpace.protocol,
          realm = protectionSpace.realm,
          port = protectionSpace.port.toLong()
        ),
        credentials = database.credentialDao
          .getAllByProtectionSpaceId(protectionSpace.id)
          .map { URLCredentialData(username = it.username, password = it.password) }
      )
    }
  }

  override fun getHttpAuthCredentials(
    protectionSpace: URLProtectionSpaceData
  ): List<URLCredentialData> {
    val database = database() ?: return emptyList()
    return database.getHttpAuthCredentials(
      protectionSpace.host,
      protectionSpace.protocol,
      protectionSpace.realm,
      protectionSpace.port?.toInt()
    ).map { URLCredentialData(username = it.username, password = it.password) }
  }

  /**
   * Stores the credential, or answers false when there is no database.
   *
   * Throws when `protocol` or `port` is null. The public Dart type makes both optional while the
   * database keys rows on both, and the previous code force-unwrapped them -- which produced
   * `PlatformException(error, null, null, java.lang.NullPointerException)`, measured on a device.
   * The message below is the whole improvement: same failure, but it says which fields are missing.
   */
  override fun setHttpAuthCredential(
    protectionSpace: URLProtectionSpaceData,
    credential: URLCredentialData
  ): Boolean {
    val protocol = protectionSpace.protocol
    val port = protectionSpace.port
    require(protocol != null && port != null) {
      "setHttpAuthCredential requires protectionSpace.protocol and protectionSpace.port to be " +
        "non-null, because the credential database keys rows on both. Got protocol=$protocol, " +
        "port=$port for host=${protectionSpace.host}."
    }
    val database = database() ?: return false
    database.setHttpAuthCredential(
      protectionSpace.host,
      protocol,
      protectionSpace.realm,
      port.toInt(),
      credential.username,
      credential.password
    )
    return true
  }

  override fun removeHttpAuthCredential(
    protectionSpace: URLProtectionSpaceData,
    credential: URLCredentialData
  ): Boolean {
    val database = database() ?: return false
    database.removeHttpAuthCredential(
      protectionSpace.host,
      protectionSpace.protocol,
      protectionSpace.realm,
      protectionSpace.port?.toInt(),
      credential.username,
      credential.password
    )
    return true
  }

  override fun removeHttpAuthCredentials(
    protectionSpace: URLProtectionSpaceData
  ): Boolean {
    val database = database() ?: return false
    database.removeHttpAuthCredentials(
      protectionSpace.host,
      protectionSpace.protocol,
      protectionSpace.realm,
      protectionSpace.port?.toInt()
    )
    return true
  }

  /**
   * Clears the plugin's table *and* WebView's own stored HTTP auth.
   *
   * Both, as before: `WebViewDatabase` is what WebView itself consults, so clearing only the
   * plugin's table would leave authentication working.
   */
  override fun clearAllAuthCredentials(): Boolean {
    val database = database() ?: return false
    database.clearAllAuthCredentials()
    plugin?.let {
      WebViewDatabase.getInstance(it.applicationContext).clearHttpAuthUsernamePassword()
    }
    return true
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed handler
    // for the life of the messenger.
    messenger?.let { CredentialDatabaseHostApi.setUp(it, null) }
    messenger = null
    plugin = null
    credentialDatabase = null
  }

  companion object {
    /**
     * Was a public mutable `@JvmField` static alongside a public `init(plugin)`; nothing outside
     * this class ever touched either, so both are private now (as in §160's `ProxyManager` and
     * §162's `TracingControllerManager`). [database] replaces `init`.
     */
    private var credentialDatabase: CredentialDatabase? = null
  }
}
