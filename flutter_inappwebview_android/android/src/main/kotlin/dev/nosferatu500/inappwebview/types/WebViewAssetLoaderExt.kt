package dev.nosferatu500.inappwebview.types

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.webkit.WebResourceResponse
import androidx.webkit.WebViewAssetLoader
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.CustomPathHandlerFlutterApi
import dev.nosferatu500.inappwebview.pigeons.WebResourceResponseData
import io.flutter.plugin.common.BinaryMessenger
import java.io.ByteArrayInputStream
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

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

    // Pigeon since §205, suffixed by this handler's id, which is Dart's `AndroidPathHandler._id`.
    @JvmField
    var channelDelegate: PathHandlerExtChannelDelegate? =
      PathHandlerExtChannelDelegate(plugin.messenger, id)

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
    }
  }

  /**
   * The handler's channel, over Pigeon (§205): one event and no host methods, so nothing is
   * registered on this side and [dispose] only drops the API.
   *
   * The hand-written callback form `handle(path, callback)` was not ported: it had no caller (§204
   * deleted it and everything still compiled and passed).
   */
  class PathHandlerExtChannelDelegate(messenger: BinaryMessenger, id: String) : Disposable {

    private var flutterApi: CustomPathHandlerFlutterApi? =
      CustomPathHandlerFlutterApi(messenger, id)

    /**
     * Asks Dart for the response to [path] and **blocks the calling thread** until it answers, with
     * the semantics of the `Util.invokeMethodAndWaitResult` call it replaces, in
     * `ServiceWorkerChannelDelegate.shouldInterceptRequest`'s shape (§186):
     *
     *  - the call is posted to the main looper, where platform channels must be used;
     *  - the wait is bounded by [Util.SYNC_CALLBACK_TIMEOUT_MILLIS], because a path handler holds no
     *    WebView settings to read a longer timeout from, as before;
     *  - a timeout, a Dart-side throw, no Dart handler, or a null answer all come back as **null**,
     *    which the loader treats as "not handled", so the request goes to the network.
     *
     * The answer is typed since W5 (§216), so `statusCode` narrows in
     * [WebResourceResponseExt.fromPigeon] instead of through `Util.normalizeCodecInts`.
     */
    @Throws(InterruptedException::class)
    fun handle(path: String): WebResourceResponseExt? {
      val api = flutterApi ?: return null
      val latch = CountDownLatch(1)
      // Written on the main thread, read here after `await`: the latch provides the happens-before.
      val answer = AtomicReference<WebResourceResponseData?>(null)
      Handler(Looper.getMainLooper()).post {
        api.handle(path) { result ->
          try {
            answer.set(result.getOrNull())
          } finally {
            latch.countDown()
          }
        }
      }
      if (!latch.await(Util.SYNC_CALLBACK_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)) {
        Log.w(
          LOG_TAG,
          "Timed out after ${Util.SYNC_CALLBACK_TIMEOUT_MILLIS}ms waiting for the Dart side to " +
            "answer \"handle\"; continuing as if it had returned null. Check that the " +
            "CustomPathHandler returns on every path and does not throw."
        )
        return null
      }
      return answer.get()?.let { WebResourceResponseExt.fromPigeon(it) }
    }

    override fun dispose() {
      flutterApi = null
    }

    companion object {
      private const val LOG_TAG = "PathHandlerExtChannelDelegate"
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
