package dev.nosferatu500.inappwebview.types

import android.content.Context
import android.util.Log
import android.webkit.WebResourceResponse
import androidx.webkit.WebViewAssetLoader
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.File

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class WebViewAssetLoaderExt(
  @JvmField var loader: WebViewAssetLoader?,
  @JvmField var customPathHandlers: MutableList<PathHandlerExt>
) : Disposable {

  override fun dispose() {
    for (pathHandler in customPathHandlers) {
      pathHandler.dispose()
    }
    customPathHandlers.clear()
  }

  class PathHandlerExt(
    @JvmField var id: String,
    plugin: InAppWebViewFlutterPlugin
  ) : WebViewAssetLoader.PathHandler, Disposable {

    @JvmField
    var channelDelegate: PathHandlerExtChannelDelegate?

    init {
      val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id)
      channelDelegate = PathHandlerExtChannelDelegate(this, channel)
    }

    override fun handle(path: String): WebResourceResponse? {
      val delegate = channelDelegate ?: return null

      val response = try {
        delegate.handle(path)
      } catch (e: InterruptedException) {
        Log.e(LOG_TAG, "", e)
        return null
      } ?: return null

      val contentType = response.contentType
      val contentEncoding = response.contentEncoding
      val data = response.data
      val responseHeaders = response.headers
      val statusCode = response.statusCode
      val reasonPhrase = response.reasonPhrase

      val inputStream = if (data != null) ByteArrayInputStream(data) else null

      return if (statusCode != null && reasonPhrase != null) {
        WebResourceResponse(
          contentType, contentEncoding, statusCode, reasonPhrase, responseHeaders, inputStream
        )
      } else {
        WebResourceResponse(contentType, contentEncoding, inputStream)
      }
    }

    override fun dispose() {
      channelDelegate?.dispose()
      channelDelegate = null
    }

    companion object {
      protected const val LOG_TAG = "PathHandlerExt"
      const val METHOD_CHANNEL_NAME_PREFIX =
        "dev.nosferatu500.inappwebview/inappwebview_custompathhandler_"
    }
  }

  class PathHandlerExtChannelDelegate(
    pathHandler: PathHandlerExt,
    channel: MethodChannel
  ) : ChannelDelegateImpl(channel) {

    private var pathHandler: PathHandlerExt? = pathHandler

    class HandleCallback : BaseCallbackResultImpl<WebResourceResponseExt>() {
      override fun decodeResult(obj: Any?): WebResourceResponseExt? =
        WebResourceResponseExt.fromMap(obj as Map<String, Any?>?)
    }

    fun handle(path: String?, callback: HandleCallback) {
      val channel = this.channel ?: return
      channel.invokeMethod("handle", hashMapOf<String, Any?>("path" to path), callback)
    }

    class SyncHandleCallback : SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
      override fun decodeResult(obj: Any?): WebResourceResponseExt? =
        HandleCallback().decodeResult(obj)
    }

    @Throws(InterruptedException::class)
    fun handle(path: String?): WebResourceResponseExt? {
      val channel = this.channel ?: return null
      val callback = SyncHandleCallback()
      return Util.invokeMethodAndWaitResult(
        channel, "handle", hashMapOf<String, Any?>("path" to path), callback
      )
    }

    override fun dispose() {
      super.dispose()
      pathHandler = null
    }
  }

  companion object {
    @JvmStatic
    fun fromMap(
      map: Map<String, Any?>?,
      plugin: InAppWebViewFlutterPlugin,
      context: Context
    ): WebViewAssetLoaderExt? {
      if (map == null) {
        return null
      }
      val builder = WebViewAssetLoader.Builder()
      val domain = map["domain"] as String?
      val httpAllowed = map["httpAllowed"] as Boolean?
      val pathHandlers = map["pathHandlers"] as List<Map<String, Any?>>?
      val customPathHandlers = mutableListOf<PathHandlerExt>()
      if (!domain.isNullOrEmpty()) {
        builder.setDomain(domain)
      }
      if (httpAllowed != null) {
        builder.setHttpAllowed(httpAllowed)
      }
      if (pathHandlers != null) {
        for (pathHandler in pathHandlers) {
          val type = pathHandler["type"] as String?
          val path = pathHandler["path"] as String?
          if (type == null || path == null) {
            continue
          }
          when (type) {
            "AssetsPathHandler" ->
              builder.addPathHandler(path, WebViewAssetLoader.AssetsPathHandler(context))

            "InternalStoragePathHandler" -> {
              val directory = pathHandler["directory"] as String? ?: continue
              builder.addPathHandler(
                path,
                WebViewAssetLoader.InternalStoragePathHandler(context, File(directory))
              )
            }

            "ResourcesPathHandler" ->
              builder.addPathHandler(path, WebViewAssetLoader.ResourcesPathHandler(context))

            else -> {
              val id = pathHandler["id"] as String? ?: continue
              val customPathHandler = PathHandlerExt(id, plugin)
              builder.addPathHandler(path, customPathHandler)
              customPathHandlers.add(customPathHandler)
            }
          }
        }
      }
      return WebViewAssetLoaderExt(builder.build(), customPathHandlers)
    }
  }
}
