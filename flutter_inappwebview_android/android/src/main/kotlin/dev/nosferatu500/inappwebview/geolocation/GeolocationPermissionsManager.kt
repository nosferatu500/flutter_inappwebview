package dev.nosferatu500.inappwebview.geolocation

import android.webkit.GeolocationPermissions
import android.webkit.ValueCallback
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.GeolocationPermissionsHostApi
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.replyingOnThrow
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([GeolocationPermissionsHostApi]) rather than a hand-written
 * `MethodChannel`; the eleventh channel migrated, after find_interaction (§14),
 * process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
 * credential_database (§163), both web_message channels (§165), cookie_manager (§168),
 * web_storage_manager (§169) and profile_store (§173).
 *
 * There is no `messageChannelSuffix`: `android.webkit.GeolocationPermissions` is process-global, so
 * there is one channel rather than one per WebView.
 *
 * **Two of the five methods are `@async`** — [getAllowed] and [getOrigins], which complete through a
 * `ValueCallback`. Both are wrapped in [replyingOnThrow] per §172's standing rule: Pigeon wraps
 * *synchronous* generated handlers in `try`/`catch` and `@async` ones in **nothing**, so a
 * synchronous throw inside one of these would escape the handler, send no reply at all, and reach
 * Dart as `PlatformException(channel-error, …)` — naming the transport rather than the cause.
 *
 * The wrap covers the **whole** body including the store resolution, not just the part where a throw
 * looks likely. §171's first attempt at this scoped a guard by reasoning about where the exception
 * came from and put it in the wrong place; the rule is to stop predicting.
 */
class GeolocationPermissionsManager(plugin: InAppWebViewFlutterPlugin) :
  Disposable, GeolocationPermissionsHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    GeolocationPermissionsHostApi.setUp(plugin.messenger, this)
  }

  override fun allow(origin: String, profileName: String?): Boolean {
    val permissions = getGeolocationPermissions(profileName) ?: return false
    permissions.allow(origin)
    return true
  }

  override fun clear(origin: String, profileName: String?): Boolean {
    val permissions = getGeolocationPermissions(profileName) ?: return false
    permissions.clear(origin)
    return true
  }

  override fun clearAll(profileName: String?): Boolean {
    val permissions = getGeolocationPermissions(profileName) ?: return false
    permissions.clearAll()
    return true
  }

  /**
   * `null` rather than `false` when the store cannot be resolved: "could not ask" is not the same
   * answer as "no decision stored", and a caller deciding whether to prompt needs to tell them
   * apart. This is the only such null on the channel — its four siblings answer `false` or an empty
   * list for the identical condition, deliberately.
   */
  override fun getAllowed(
    origin: String,
    profileName: String?,
    callback: (Result<Boolean?>) -> Unit
  ) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val permissions = getGeolocationPermissions(profileName)
      if (permissions == null) {
        reply(Result.success(null))
        return@replyingOnThrow
      }
      permissions.getAllowed(origin) { allowed -> reply(Result.success(allowed)) }
    }
  }

  /**
   * The callback hands back a `Set`; the wire has no set, so it is copied into a list. Order is
   * whatever the set iterates and nothing should depend on it.
   *
   * Note the origins come back **normalised with a trailing `/`** — an origin stored as
   * `https://x.test` is listed as `https://x.test/`. That is the platform's doing, not this
   * plugin's; measured in §174 and documented on the public `getOrigins`.
   */
  override fun getOrigins(profileName: String?, callback: (Result<List<String>>) -> Unit) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val permissions = getGeolocationPermissions(profileName)
      if (permissions == null) {
        reply(Result.success(emptyList()))
        return@replyingOnThrow
      }
      permissions.getOrigins(
        ValueCallback<Set<String>> { origins -> reply(Result.success(origins.toList())) }
      )
    }
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager for
    // the life of the messenger.
    messenger?.let { GeolocationPermissionsHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    private const val LOG_TAG = "GeolocationPermissionsManager"

    /**
     * Resolves the [GeolocationPermissions] store a call should act on.
     *
     * A null [profileName] means the default store. A non-null one means that profile's own store,
     * and returns null -- so the caller reports failure -- when `MULTI_PROFILE` is unsupported or no
     * such profile exists. It never silently falls back to the default store: granting an origin
     * location access in the wrong profile is a privacy decision applied to the wrong session.
     *
     * Uses `getProfile`, not `getOrCreateProfile`, as in MyCookieManager, MyWebStorage and
     * ServiceWorkerManager: reading or changing a profile's stored decisions must not bring the
     * profile into existence, and `getProfile` returns null for a profile already deleted -- which
     * keeps `Profile.getGeolocationPermissions()`, which throws for a deleted profile, out of reach
     * here.
     *
     * Unlike the service-worker case (see ServiceWorkerSettings), no adapter is needed: androidx has
     * no `GeolocationPermissionsCompat`, so both paths yield the same framework type.
     *
     * Was a public `@JvmStatic`; nothing outside this class ever called it -- measured across the
     * whole module -- so it is private now, matching the same cleanup in §162, §168, §169 and §173.
     */
    private fun getGeolocationPermissions(profileName: String?): GeolocationPermissions? {
      if (profileName == null) {
        return GeolocationPermissions.getInstance()
      }
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        return null
      }
      return ProfileStore.getInstance().getProfile(profileName)?.geolocationPermissions
    }
  }
}
