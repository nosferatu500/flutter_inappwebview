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

    // Null unless the caller scoped this single call to a profile; see
    // PlatformServiceWorkerController's class doc for why the scope is per call. Note
    // setServiceWorkerClient below ignores it -- the intercept event carries no profile identity,
    // so a per-profile client could not be told apart in Dart.
    val profileName = call.argument<String>("profileName")
    // Availability gating lives inside the returned object, because it differs between the androidx
    // and framework APIs. See ServiceWorkerSettings.
    val settings = ServiceWorkerManager.getServiceWorkerSettings(profileName)

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

      "getAllowContentAccess" ->
        result.success(settings?.getAllowContentAccess() ?: false)

      "getAllowFileAccess" -> result.success(settings?.getAllowFileAccess() ?: false)

      "getBlockNetworkLoads" ->
        result.success(settings?.getBlockNetworkLoads() ?: false)

      "getCacheMode" -> result.success(settings?.getCacheMode())

      // No `?: false` here, unlike the three getters above: null is a real answer (feature
      // unsupported, or a named profile) and Dart keeps the three states apart.
      "getIncludeCookiesOnShouldInterceptRequestEnabled" ->
        result.success(settings?.getIncludeCookiesOnShouldInterceptRequestEnabled())

      "setAllowContentAccess" -> {
        settings?.setAllowContentAccess(call.argument<Boolean>("allow")!!)
        result.success(true)
      }

      "setAllowFileAccess" -> {
        settings?.setAllowFileAccess(call.argument<Boolean>("allow")!!)
        result.success(true)
      }

      "setBlockNetworkLoads" -> {
        settings?.setBlockNetworkLoads(call.argument<Boolean>("flag")!!)
        result.success(true)
      }

      "setCacheMode" -> {
        settings?.setCacheMode(call.argument<Int>("mode")!!)
        result.success(true)
      }

      "setIncludeCookiesOnShouldInterceptRequestEnabled" -> {
        settings?.setIncludeCookiesOnShouldInterceptRequestEnabled(
          call.argument<Boolean>("enabled")!!
        )
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
