package dev.nosferatu500.inappwebview.profile

import androidx.webkit.CustomHeader
import androidx.webkit.Profile
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.CustomHeaderData
import dev.nosferatu500.inappwebview.pigeons.FlutterError
import dev.nosferatu500.inappwebview.pigeons.ProfileStoreHostApi
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.BinaryMessenger

/**
 * Transport is Pigeon-generated ([ProfileStoreHostApi]) rather than a hand-written `MethodChannel`;
 * the tenth channel migrated, after find_interaction (§14), process_global_config (§157), proxy
 * (§160), webview_feature (§161), tracing_controller (§162), credential_database (§163), both
 * web_message channels (§165), cookie_manager (§168) and web_storage_manager (§169).
 *
 * There is no `messageChannelSuffix`: `androidx.webkit.ProfileStore` is process-global, so there is
 * one channel rather than one per WebView.
 *
 * **None of the eight methods is `@async`** — every androidx call this class makes returns
 * directly, so Pigeon's own `try`/`catch` around each synchronous handler is the only error path
 * needed and §172's `replyingOnThrow` has nothing to wrap. [deleteProfile] depends on that wrapper
 * rather than working around it.
 */
class ProfileStoreManager(plugin: InAppWebViewFlutterPlugin) : Disposable, ProfileStoreHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    ProfileStoreHostApi.setUp(plugin.messenger, this)
  }

  override fun getAllProfileNames(): List<String> = profileStore?.allProfileNames ?: emptyList()

  /**
   * `getOrCreateProfile` returns the `Profile` itself, which cannot cross the channel. Its name is
   * the part the caller needs — it is what `InAppWebViewSettings.profileName` takes — and reading it
   * back off the object rather than echoing the argument means the reply reflects what the platform
   * actually created.
   */
  override fun getOrCreateProfile(name: String): String? =
    profileStore?.getOrCreateProfile(name)?.name

  /**
   * 🚨 **Both refusals are re-thrown as [FlutterError] carrying [LOG_TAG], and that is load-bearing.**
   * androidx raises two different classes for them, and Pigeon's `wrapError` derives
   * `PlatformException.code` from `javaClass.simpleName` for anything that is *not* a `FlutterError`
   * — so letting these propagate would turn the single stable `"ProfileStoreManager"` code the
   * hand-written channel always sent into two exception-class names. §171 used that code as its
   * example of a clean platform error; `profile_store_delete.dart` pins both refusals on a device so
   * the normalisation is observable rather than implied.
   *
   * `e.message` is passed through unchanged rather than defaulted, because that is exactly what
   * `result.error(LOG_TAG, e.message, null)` sent before and `FlutterError.message` is nullable too.
   */
  override fun deleteProfile(name: String): Boolean {
    val store = profileStore ?: return false
    return try {
      store.deleteProfile(name)
    } catch (e: IllegalStateException) {
      // Living WebViews on this profile, or the profile was loaded into memory this process.
      throw FlutterError(LOG_TAG, e.message, null)
    } catch (e: IllegalArgumentException) {
      // Trying to delete the default profile.
      throw FlutterError(LOG_TAG, e.message, null)
    }
  }

  /**
   * Answers nothing. The hand-written handler replied a constant `true` here even when the elvis
   * below swallowed the call, and the Dart side discarded it; see the schema.
   */
  override fun addCustomHeader(header: CustomHeaderData, profileName: String?) {
    customHeaderProfile(profileName)?.addCustomHeader(
      CustomHeader(header.name, header.value, header.originRules.toSet())
    )
  }

  override fun hasCustomHeader(headerName: String, profileName: String?): Boolean =
    customHeaderProfile(profileName)?.hasCustomHeader(headerName) ?: false

  /**
   * The three androidx overloads collapse into one method with optional arguments, so this branch
   * picks the overload rather than letting Dart do the filtering — the platform's name matching is
   * case-insensitive and its value matching is not, which a Dart `where` would get wrong.
   */
  override fun getCustomHeaders(
    headerName: String?,
    headerValue: String?,
    profileName: String?
  ): List<CustomHeaderData> {
    val profile = customHeaderProfile(profileName)
    val headers = when {
      profile == null -> emptySet()
      headerName == null -> profile.customHeaders
      headerValue == null -> profile.getCustomHeaders(headerName)
      else -> profile.getCustomHeaders(headerName, headerValue)
    }
    return headers.map {
      CustomHeaderData(name = it.name, value = it.value, originRules = it.rules.toList())
    }
  }

  override fun clearCustomHeader(
    headerName: String,
    headerValue: String?,
    profileName: String?
  ) {
    val profile = customHeaderProfile(profileName)
    if (headerValue == null) {
      profile?.clearCustomHeader(headerName)
    } else {
      profile?.clearCustomHeader(headerName, headerValue)
    }
  }

  override fun clearAllCustomHeaders(profileName: String?) {
    customHeaderProfile(profileName)?.clearAllCustomHeaders()
  }

  override fun dispose() {
    // Unregisters the generated handler. Skipping it would leave it bound to a disposed manager for
    // the life of the messenger.
    messenger?.let { ProfileStoreHostApi.setUp(it, null) }
    messenger = null
    plugin = null
  }

  companion object {
    /**
     * Also the `PlatformException.code` both [deleteProfile] refusals carry, which is why it is a
     * constant rather than a literal at the throw sites.
     */
    private const val LOG_TAG = "ProfileStoreManager"

    /**
     * The profile a custom-header call applies to, or null if it cannot be reached.
     *
     * Two features are needed, not one. `CUSTOM_REQUEST_HEADERS` covers the header methods
     * themselves; `MULTI_PROFILE` is what makes any `Profile` reachable at all, and every
     * `ProfileStore` method throws `UnsupportedOperationException` without it -- which is why the
     * store is resolved behind that gate below.
     *
     * A null [profileName] means the default profile, matching every other profile-scoped surface
     * in this plugin. Unlike the service-worker cookie switch (see `ServiceWorkerSettings`), there
     * is no default-profile-only asymmetry here: these methods are on androidx's own `Profile`
     * interface, so a named profile reaches them too -- measured, with the default profile as the
     * control to confirm the two do not share state.
     */
    private fun customHeaderProfile(profileName: String?): Profile? {
      // Direct isFeatureSupported, deliberately: unlike COOKIE_INTERCEPT (§126), this flag IS
      // present in androidx's @StringDef, so lint accepts it and no suppression is warranted.
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.CUSTOM_REQUEST_HEADERS)) {
        return null
      }
      return profileStore?.getProfile(profileName ?: DEFAULT_PROFILE_NAME)
    }

    /** androidx's own name for the default profile; `ProfileStore.getProfile` takes a name. */
    private const val DEFAULT_PROFILE_NAME = "Default"

    /**
     * Every `ProfileStore` method, `getInstance()` included, throws `UnsupportedOperationException`
     * when `MULTI_PROFILE` is missing, so the store is resolved behind the gate rather than eagerly.
     */
    private val profileStore: ProfileStore?
      get() = if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        ProfileStore.getInstance()
      } else {
        null
      }
  }
}
