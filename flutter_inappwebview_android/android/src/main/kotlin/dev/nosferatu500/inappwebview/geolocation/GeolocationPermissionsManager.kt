package dev.nosferatu500.inappwebview.geolocation

import android.webkit.GeolocationPermissions
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GeolocationPermissionsManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    // Null unless the caller scoped this single call to a profile; see
    // PlatformGeolocationPermissions' class doc for why the scope is per call.
    val profileName = call.argument<String>("profileName")
    val permissions = getGeolocationPermissions(profileName)

    when (call.method) {
      "allow" -> {
        if (permissions == null) {
          result.success(false)
          return
        }
        permissions.allow(call.argument("origin"))
        result.success(true)
      }

      "clear" -> {
        if (permissions == null) {
          result.success(false)
          return
        }
        permissions.clear(call.argument("origin"))
        result.success(true)
      }

      "clearAll" -> {
        if (permissions == null) {
          result.success(false)
          return
        }
        permissions.clearAll()
        result.success(true)
      }

      // null rather than false: "could not ask" is not the same answer as "not allowed".
      "getAllowed" -> {
        if (permissions == null) {
          result.success(null)
          return
        }
        permissions.getAllowed(call.argument("origin")) { allowed ->
          result.success(allowed)
        }
      }

      "getOrigins" -> {
        if (permissions == null) {
          result.success(ArrayList<String>())
          return
        }
        // The callback hands back a Set; the standard codec only writes lists, so it has to be
        // copied rather than passed through.
        permissions.getOrigins { origins -> result.success(ArrayList(origins)) }
      }

      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "GeolocationPermissionsManager"
    const val METHOD_CHANNEL_NAME =
      "dev.nosferatu500.inappwebview/inappwebview_geolocationpermissions"

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
     */
    @JvmStatic
    fun getGeolocationPermissions(profileName: String?): GeolocationPermissions? {
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
