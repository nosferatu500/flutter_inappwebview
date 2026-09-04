package dev.nosferatu500.inappwebview.profile

import androidx.webkit.CustomHeader
import androidx.webkit.Profile
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ProfileStoreManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    // Every ProfileStore method, getInstance() included, throws UnsupportedOperationException when
    // MULTI_PROFILE is missing, so the store is resolved behind the gate rather than eagerly.
    val store = profileStore
    when (call.method) {
      "getAllProfileNames" -> result.success(store?.allProfileNames ?: ArrayList<String>())

      "getOrCreateProfile" -> {
        val name = call.argument<String>("name")!!
        // getOrCreateProfile returns the Profile itself, which cannot cross the channel. Its name
        // is the part the caller needs -- it is what InAppWebViewSettings.profileName takes -- and
        // reading it back from the object rather than echoing the argument means the reply reflects
        // what the platform actually created.
        result.success(store?.getOrCreateProfile(name)?.name)
      }

      "deleteProfile" -> {
        val name = call.argument<String>("name")!!
        if (store == null) {
          result.success(false)
          return
        }
        try {
          result.success(store.deleteProfile(name))
        } catch (e: IllegalStateException) {
          // Living WebViews on this profile, or the profile was loaded into memory this process.
          result.error(LOG_TAG, e.message, null)
        } catch (e: IllegalArgumentException) {
          // Trying to delete the default profile.
          result.error(LOG_TAG, e.message, null)
        }
      }

      "addCustomHeader" -> {
        val map = call.argument<Map<String, Any?>>("header")!!
        customHeaderProfile(call)?.addCustomHeader(
          CustomHeader(
            map["name"] as String,
            map["value"] as String,
            (map["originRules"] as List<*>).map { it as String }.toSet()
          )
        )
        result.success(true)
      }

      "hasCustomHeader" ->
        result.success(
          customHeaderProfile(call)?.hasCustomHeader(call.argument<String>("headerName")!!)
            ?: false
        )

      "getCustomHeaders" -> {
        val profile = customHeaderProfile(call)
        val name = call.argument<String>("headerName")
        val value = call.argument<String>("headerValue")
        // The three androidx overloads collapse into one Dart method with optional arguments, so
        // the branch picks the overload rather than Dart doing the filtering -- the platform's
        // name matching is case-insensitive and its value matching is not, which a Dart `where`
        // would get wrong.
        val headers = when {
          profile == null -> emptySet()
          name == null -> profile.customHeaders
          value == null -> profile.getCustomHeaders(name)
          else -> profile.getCustomHeaders(name, value)
        }
        result.success(
          headers.map {
            mapOf(
              "name" to it.name,
              "value" to it.value,
              "originRules" to it.rules.toList()
            )
          }
        )
      }

      "clearCustomHeader" -> {
        val profile = customHeaderProfile(call)
        val name = call.argument<String>("headerName")!!
        val value = call.argument<String>("headerValue")
        if (value == null) {
          profile?.clearCustomHeader(name)
        } else {
          profile?.clearCustomHeader(name, value)
        }
        result.success(true)
      }

      "clearAllCustomHeaders" -> {
        customHeaderProfile(call)?.clearAllCustomHeaders()
        result.success(true)
      }

      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "ProfileStoreManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_profilestore"

    /**
     * The profile a custom-header call applies to, or null if it cannot be reached.
     *
     * Two features are needed, not one. `CUSTOM_REQUEST_HEADERS` covers the header methods
     * themselves; `MULTI_PROFILE` is what makes any `Profile` reachable at all, and every
     * `ProfileStore` method throws `UnsupportedOperationException` without it -- which is why the
     * store is already resolved behind that gate above.
     *
     * A null `profileName` means the default profile, matching every other profile-scoped surface
     * in this plugin. Unlike the service-worker cookie switch (see `ServiceWorkerSettings`), there
     * is no default-profile-only asymmetry here: these methods are on androidx's own `Profile`
     * interface, so a named profile reaches them too -- measured, with the default profile as the
     * control to confirm the two do not share state.
     */
    private fun customHeaderProfile(call: MethodCall): Profile? {
      // Direct isFeatureSupported, deliberately: unlike COOKIE_INTERCEPT (§126), this flag IS
      // present in androidx's @StringDef, so lint accepts it and no suppression is warranted.
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.CUSTOM_REQUEST_HEADERS)) {
        return null
      }
      return profileStore?.getProfile(call.argument<String>("profileName") ?: DEFAULT_PROFILE_NAME)
    }

    /** androidx's own name for the default profile; `ProfileStore.getProfile` takes a name. */
    private const val DEFAULT_PROFILE_NAME = "Default"

    private val profileStore: ProfileStore?
      get() = if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        ProfileStore.getInstance()
      } else {
        null
      }
  }
}
