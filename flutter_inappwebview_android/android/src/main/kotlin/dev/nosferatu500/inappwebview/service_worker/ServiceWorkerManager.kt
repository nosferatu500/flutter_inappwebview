package dev.nosferatu500.inappwebview.service_worker

import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import androidx.webkit.ProfileStore
import androidx.webkit.ServiceWorkerClientCompat
import androidx.webkit.ServiceWorkerControllerCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream

// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
class ServiceWorkerManager(plugin: InAppWebViewFlutterPlugin) : Disposable {

  @JvmField
  var channelDelegate: ServiceWorkerChannelDelegate?

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  init {
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)
    channelDelegate = ServiceWorkerChannelDelegate(this, channel)
  }

  fun setServiceWorkerClient(isNull: Boolean?) {
    val controller = serviceWorkerController ?: return
    // set ServiceWorkerClient as null makes the app crashes, so just set a dummy
    // ServiceWorkerClientCompat.
    // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1151
    controller.setServiceWorkerClient(
      if (isNull == true) {
        DummyServiceWorkerClientCompat.INSTANCE
      } else {
        object : ServiceWorkerClientCompat() {
          override fun shouldInterceptRequest(request: WebResourceRequest): WebResourceResponse? {
            val requestExt = WebResourceRequestExt.fromWebResourceRequest(request)

            val response = try {
              channelDelegate?.shouldInterceptRequest(requestExt)
            } catch (e: InterruptedException) {
              Log.e(LOG_TAG, "", e)
              return null
            } ?: return null

            val data = response.data
            val inputStream = if (data != null) ByteArrayInputStream(data) else null

            val statusCode = response.statusCode
            val reasonPhrase = response.reasonPhrase
            return if (statusCode != null && reasonPhrase != null) {
              WebResourceResponse(
                response.contentType, response.contentEncoding, statusCode, reasonPhrase,
                response.headers, inputStream
              )
            } else {
              WebResourceResponse(response.contentType, response.contentEncoding, inputStream)
            }
          }
        }
      }
    )
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    plugin = null
  }

  private class DummyServiceWorkerClientCompat private constructor() : ServiceWorkerClientCompat() {
    override fun shouldInterceptRequest(request: WebResourceRequest): WebResourceResponse? = null

    companion object {
      val INSTANCE: ServiceWorkerClientCompat = DummyServiceWorkerClientCompat()
    }
  }

  companion object {
    protected const val LOG_TAG = "ServiceWorkerManager"
    const val METHOD_CHANNEL_NAME =
      "dev.nosferatu500.inappwebview/inappwebview_serviceworkercontroller"

    @JvmField
    var serviceWorkerController: ServiceWorkerControllerCompat? = null

    @JvmStatic
    fun init() {
      if (serviceWorkerController == null &&
        WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE)
      ) {
        serviceWorkerController = ServiceWorkerControllerCompat.getInstance()
      }
    }

    /**
     * Resolves the service-worker settings a call should act on, over whichever API can reach them.
     *
     * A null [profileName] means the default profile and goes through androidx, exactly as before.
     * A non-null one means that profile's own service-worker settings, and returns null -- so the
     * caller reports failure -- when `MULTI_PROFILE` is unsupported or no such profile exists.
     * It never silently falls back to the default profile.
     *
     * Uses `getProfile`, not `getOrCreateProfile`, as in MyCookieManager and MyWebStorage: reading
     * or changing a profile's settings must not bring the profile into existence, and `getProfile`
     * returns null for a profile already deleted -- which keeps `Profile.getServiceWorkerController()`,
     * which throws for a deleted profile, out of reach here.
     */
    @JvmStatic
    internal fun getServiceWorkerSettings(
      profileName: String?
    ): ServiceWorkerSettings? {
      if (profileName == null) {
        return serviceWorkerController?.serviceWorkerWebSettings
          ?.let { CompatServiceWorkerSettings(it) }
      }
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
        return null
      }
      return ProfileStore.getInstance().getProfile(profileName)
        ?.serviceWorkerController
        ?.serviceWorkerWebSettings
        ?.let { FrameworkServiceWorkerSettings(it) }
    }
  }
}
