package dev.nosferatu500.inappwebview.profile

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

    private val profileStore: ProfileStore?
      get() = if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        ProfileStore.getInstance()
      } else {
        null
      }
  }
}
