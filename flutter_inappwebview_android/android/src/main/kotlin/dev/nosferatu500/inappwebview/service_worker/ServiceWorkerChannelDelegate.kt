package dev.nosferatu500.inappwebview.service_worker

import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.types.BaseCallbackResultImpl
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.SyncBaseCallbackResultImpl
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class ServiceWorkerChannelDelegate(
  serviceWorkerManager: ServiceWorkerManager,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var serviceWorkerManager: ServiceWorkerManager? = serviceWorkerManager

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    ServiceWorkerManager.init()
    val serviceWorkerWebSettings = ServiceWorkerManager.serviceWorkerController
      ?.serviceWorkerWebSettings

    when (call.method) {
      "setServiceWorkerClient" -> {
        val manager = serviceWorkerManager
        if (manager != null) {
          manager.setServiceWorkerClient(call.argument("isNull"))
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "getAllowContentAccess" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)
        ) {
          result.success(serviceWorkerWebSettings.allowContentAccess)
        } else {
          result.success(false)
        }
      }

      "getAllowFileAccess" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)
        ) {
          result.success(serviceWorkerWebSettings.allowFileAccess)
        } else {
          result.success(false)
        }
      }

      "getBlockNetworkLoads" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)
        ) {
          result.success(serviceWorkerWebSettings.blockNetworkLoads)
        } else {
          result.success(false)
        }
      }

      "getCacheMode" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)
        ) {
          result.success(serviceWorkerWebSettings.cacheMode)
        } else {
          result.success(null)
        }
      }

      "setAllowContentAccess" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)
        ) {
          serviceWorkerWebSettings.allowContentAccess = call.argument<Boolean>("allow")!!
        }
        result.success(true)
      }

      "setAllowFileAccess" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)
        ) {
          serviceWorkerWebSettings.allowFileAccess = call.argument<Boolean>("allow")!!
        }
        result.success(true)
      }

      "setBlockNetworkLoads" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)
        ) {
          serviceWorkerWebSettings.blockNetworkLoads = call.argument<Boolean>("flag")!!
        }
        result.success(true)
      }

      "setCacheMode" -> {
        if (serviceWorkerWebSettings != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)
        ) {
          serviceWorkerWebSettings.cacheMode = call.argument<Int>("mode")!!
        }
        result.success(true)
      }

      else -> result.notImplemented()
    }
  }

  class ShouldInterceptRequestCallback : BaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      WebResourceResponseExt.fromMap(obj as Map<String, Any?>?)
  }

  fun shouldInterceptRequest(
    request: WebResourceRequestExt,
    callback: ShouldInterceptRequestCallback
  ) {
    val channel = this.channel ?: return
    channel.invokeMethod("shouldInterceptRequest", request.toMap(), callback)
  }

  class SyncShouldInterceptRequestCallback : SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      ShouldInterceptRequestCallback().decodeResult(obj)
  }

  @Throws(InterruptedException::class)
  fun shouldInterceptRequest(request: WebResourceRequestExt): WebResourceResponseExt? {
    val channel = this.channel ?: return null
    val callback = SyncShouldInterceptRequestCallback()
    return Util.invokeMethodAndWaitResult(
      channel, "shouldInterceptRequest", request.toMap(), callback
    )
  }

  override fun dispose() {
    super.dispose()
    serviceWorkerManager = null
  }
}
