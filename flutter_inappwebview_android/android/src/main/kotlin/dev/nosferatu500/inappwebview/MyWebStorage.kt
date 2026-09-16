package dev.nosferatu500.inappwebview

import android.webkit.ValueCallback
import android.webkit.WebStorage
import androidx.webkit.ProfileStore
import androidx.webkit.WebStorageCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.pigeons.WebStorageManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.WebStorageOriginData
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.replyingOnThrow
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([WebStorageManagerHostApi]) rather than a hand-written
 * `MethodChannel`; the ninth channel migrated, after find_interaction (§14),
 * process_global_config (§157), proxy (§160), webview_feature (§161), tracing_controller (§162),
 * credential_database (§163), both web_message channels (§165) and cookie_manager (§168).
 *
 * There is no `messageChannelSuffix`: `android.webkit.WebStorage` is process-global, so there is one
 * channel rather than one per WebView.
 *
 * **Five of the seven methods are `@async`** — everything that completes through a `ValueCallback`
 * or a `Runnable`. [deleteAllData] and [deleteOrigin] wrap `void` platform calls and answer inline.
 */
class MyWebStorage(plugin: InAppWebViewFlutterPlugin) : Disposable, WebStorageManagerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    WebStorageManagerHostApi.setUp(plugin.messenger, this)
  }

  /**
   * The raw `Map` is forced by the platform signature, which is literally
   * `WebStorage.getOrigins(ValueCallback<Map>)` -- verified against `android.jar`. Parameterizing
   * the callback would no longer match the parameter type, so this cannot be typed away.
   *
   * The suppression is scoped to this function rather than the class (it was class-level before),
   * because the outbound half is now typed: the callback builds [WebStorageOriginData] directly
   * instead of a `hashMapOf` the Dart side had to read back by key.
   */
  @Suppress("UNCHECKED_CAST")
  override fun getOrigins(
    profileName: String?,
    callback: (Result<List<WebStorageOriginData>>) -> Unit
  ) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val manager = getWebStorage(profileName)
      if (manager == null) {
        reply(Result.success(emptyList()))
        return@replyingOnThrow
      }
      manager.getOrigins(
        ValueCallback<Map<*, *>> { value ->
          // `as`, not `filterIsInstance`: the old code cast each value and would throw if the
          // platform ever handed back something that is not an Origin. Filtering would turn that
          // into a silently short list, which is a behaviour change dressed up as a tidy-up.
          //
          // The cast is also the reason this method is worth guarding: it runs inside androidx's
          // callback, and a `ClassCastException` there is exactly the synchronous throw
          // [replyingOnThrow] converts into a named failure.
          val origins = value.values.map {
            val o = it as WebStorage.Origin
            WebStorageOriginData(origin = o.origin, quota = o.quota, usage = o.usage)
          }
          reply(Result.success(origins))
        } as ValueCallback<Map<Any?, Any?>>
      )
    }
  }

  override fun deleteAllData(profileName: String?): Boolean {
    val manager = getWebStorage(profileName) ?: return false
    manager.deleteAllData()
    return true
  }

  override fun deleteOrigin(origin: String, profileName: String?): Boolean {
    val manager = getWebStorage(profileName) ?: return false
    manager.deleteOrigin(origin)
    return true
  }

  /**
   * Uses the [WebStorageCompat] overload that posts the done callback to the main looper rather
   * than the `Executor` one, as [deleteBrowsingDataForSite] does and for the same family of
   * reasons.
   *
   * The feature gate is required rather than defensive: `WebStorageCompat.deleteBrowsingData` throws
   * `UnsupportedOperationException` when `DELETE_BROWSING_DATA` is missing.
   */
  override fun deleteBrowsingData(profileName: String?, callback: (Result<Boolean>) -> Unit) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val manager = getWebStorage(profileName)
      if (manager == null ||
        !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)
      ) {
        reply(Result.success(false))
        return@replyingOnThrow
      }
      WebStorageCompat.deleteBrowsingData(manager) { reply(Result.success(true)) }
    }
  }

  /**
   * Answers the domain the platform actually cleared, which is the registrable domain of [site] --
   * so `"www.example.com"` comes back as `"example.com"`.
   *
   * `deleteBrowsingDataForSite` reports completion through a callback *and* returns that domain.
   * Assigning the return value before the callback can run is safe only because this overload posts
   * the callback to the main looper we are already on; with the `Executor` overload it would be a
   * genuine race.
   *
   * 🚨 **The `IllegalArgumentException` an unparseable site raises must be delivered through
   * [callback], not thrown.** §169 removed the old `try`/`catch` believing Pigeon's `wrapError`
   * would catch it. That is true of a **synchronous** generated handler, which wraps the call in
   * `try { … } catch (Throwable) { wrapError(…) }` -- and false of an `@async` one, which is
   * generated as a bare `api.method(args) { result -> … }` with no `try`/`catch` anywhere. A
   * synchronous throw therefore escapes the message handler, **no reply is ever sent**, and the
   * Dart caller receives `PlatformException(channel-error, "Unable to establish connection on
   * channel…")` -- an error naming the transport rather than the cause. Measured on a device in
   * §170; the unit tests could not see it, because they mock the host and simulate its error
   * envelope.
   *
   * `FlutterError` rather than the raw exception so the `code` stays stable and meaningful:
   * `wrapError` uses `javaClass.simpleName` for anything else, which would make the code depend on
   * which exception type androidx happens to raise.
   */
  override fun deleteBrowsingDataForSite(
    site: String,
    profileName: String?,
    callback: (Result<String?>) -> Unit
  ) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val manager = getWebStorage(profileName)
      if (manager == null ||
        !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)
      ) {
        reply(Result.success(null))
        return@replyingOnThrow
      }
      // The `IllegalArgumentException` an unparseable site raises is caught by the wrapper, which
      // replaces the bespoke try/catch §170 added here -- same behaviour, one shared implementation.
      var domain: String? = null
      domain = WebStorageCompat.deleteBrowsingDataForSite(manager, site) {
        reply(Result.success(domain))
      }
    }
  }

  override fun getQuotaForOrigin(
    origin: String,
    profileName: String?,
    callback: (Result<Long>) -> Unit
  ) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val manager = getWebStorage(profileName)
      if (manager == null) {
        reply(Result.success(0L))
        return@replyingOnThrow
      }
      manager.getQuotaForOrigin(origin) { value -> reply(Result.success(value)) }
    }
  }

  override fun getUsageForOrigin(
    origin: String,
    profileName: String?,
    callback: (Result<Long>) -> Unit
  ) {
    replyingOnThrow(LOG_TAG, callback) { reply ->
      val manager = getWebStorage(profileName)
      if (manager == null) {
        reply(Result.success(0L))
        return@replyingOnThrow
      }
      manager.getUsageForOrigin(origin) { value -> reply(Result.success(value)) }
    }
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { WebStorageManagerHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    private const val LOG_TAG = "MyWebStorage"

    /**
     * Resolved lazily on first use, as the hand-written channel did by calling `init()` at the top
     * of every dispatch.
     *
     * Was a public mutable `@JvmField` static plus a public `init()`; nothing outside this class
     * ever touched either -- measured across the whole module -- so both are private now, matching
     * the same cleanup in §162 and §168.
     */
    private var cachedWebStorage: WebStorage? = null

    private fun defaultWebStorage(): WebStorage {
      if (cachedWebStorage == null) {
        cachedWebStorage = WebStorage.getInstance()
      }
      return cachedWebStorage!!
    }

    /**
     * Resolves the [WebStorage] a call should act on.
     *
     * A null [profileName] means the default profile's storage. A non-null one means that profile's
     * own storage, and returns null -- so the caller reports failure -- when `MULTI_PROFILE` is
     * unsupported or no such profile exists. It never silently falls back to the default profile:
     * reporting "deleted" after clearing the wrong profile's storage is worse than reporting
     * failure.
     *
     * Uses `getProfile`, not `getOrCreateProfile`, for the same reasons as MyCookieManager: reading
     * or clearing a profile's storage must not bring the profile into existence, and `getProfile`
     * returns null for a profile already deleted -- which keeps `Profile.getWebStorage()`, which
     * throws for a deleted profile, out of reach here.
     */
    private fun getWebStorage(profileName: String?): WebStorage? {
      if (profileName == null) {
        return defaultWebStorage()
      }
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        return null
      }
      return ProfileStore.getInstance().getProfile(profileName)?.webStorage
    }
  }
}
