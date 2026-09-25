package dev.nosferatu500.inappwebview.service_worker

import android.os.Handler
import android.os.Looper
import android.util.Log
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.ServiceWorkerFlutterApi
import dev.nosferatu500.inappwebview.pigeons.ServiceWorkerHostApi
import dev.nosferatu500.inappwebview.pigeons.WebResourceRequestData
import dev.nosferatu500.inappwebview.pigeons.WebResourceResponseData
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import io.flutter.plugin.common.BinaryMessenger
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

/**
 * Transport is Pigeon-generated ([ServiceWorkerHostApi] / [ServiceWorkerFlutterApi]) rather than a
 * hand-written `MethodChannel`; the sixteenth channel migrated, at **eleven host methods plus one
 * event that returns a value** — the first such event in the plugin.
 *
 * **Not per-instance**: one process-wide `ServiceWorkerControllerCompat`, one native client, one
 * channel. No `messageChannelSuffix`.
 *
 * **None of the eleven host methods is `@async`**: each answers inline, so Pigeon's own `try`/`catch`
 * around the synchronous handlers is the only error path and §172's `replyingOnThrow` has nothing to
 * wrap. Verified by reading the generated output (eleven wrapped handlers).
 *
 * The class-level `@Suppress("UNCHECKED_CAST")` is **gone**, with the `call.argument` reads and the
 * `obj as Map<String, Any?>?` cast in the old `ShouldInterceptRequestCallback`. So is that class's
 * async `shouldInterceptRequest(request, callback)` overload, which had **no caller** (§185).
 *
 * **No `dispose` host method**, so this keeps `Disposable` and its teardown keeps the name.
 */
class ServiceWorkerChannelDelegate(
  serviceWorkerManager: ServiceWorkerManager,
  messenger: BinaryMessenger
) : Disposable, ServiceWorkerHostApi {

  private var serviceWorkerManager: ServiceWorkerManager? = serviceWorkerManager

  private var messenger: BinaryMessenger? = messenger

  private var flutterApi: ServiceWorkerFlutterApi? = ServiceWorkerFlutterApi(messenger)

  init {
    ServiceWorkerHostApi.setUp(messenger, this)
  }

  /**
   * The settings a call acts on. Also where [ServiceWorkerManager.init] runs, which the hand-written
   * dispatch called at the top of **every** method — so a first call of any kind brings the
   * controller into existence.
   *
   * [profileName] is null unless the caller scoped this single call to a profile; see
   * `PlatformServiceWorkerController`'s class doc for why the scope is per call. Availability gating
   * lives inside the returned object, because it differs between the androidx and framework APIs.
   */
  private fun settings(profileName: String?): ServiceWorkerSettings? {
    ServiceWorkerManager.init()
    return ServiceWorkerManager.getServiceWorkerSettings(profileName)
  }

  /**
   * Ignores profiles on purpose: the intercept event carries no profile identity, so a per-profile
   * client could not be told apart in Dart.
   */
  override fun setServiceWorkerClient(isNull: Boolean): Boolean {
    ServiceWorkerManager.init()
    val manager = serviceWorkerManager ?: return false
    manager.setServiceWorkerClient(isNull)
    return true
  }

  override fun getAllowContentAccess(profileName: String?): Boolean =
    settings(profileName)?.getAllowContentAccess() ?: false

  override fun getAllowFileAccess(profileName: String?): Boolean =
    settings(profileName)?.getAllowFileAccess() ?: false

  override fun getBlockNetworkLoads(profileName: String?): Boolean =
    settings(profileName)?.getBlockNetworkLoads() ?: false

  override fun getCacheMode(profileName: String?): Long? =
    settings(profileName)?.getCacheMode()?.toLong()

  /**
   * No `?: false` here, unlike the three getters above: null is a real answer (feature unsupported,
   * or a named profile) and Dart keeps the three states apart.
   */
  override fun getIncludeCookiesOnShouldInterceptRequestEnabled(profileName: String?): Boolean? =
    settings(profileName)?.getIncludeCookiesOnShouldInterceptRequestEnabled()

  // Every setter answers `true` whether or not the settings were reachable, exactly as the
  // hand-written channel did (`settings?.set…(); result.success(true)`). Dart discards it.

  override fun setAllowContentAccess(allow: Boolean, profileName: String?): Boolean {
    settings(profileName)?.setAllowContentAccess(allow)
    return true
  }

  override fun setAllowFileAccess(allow: Boolean, profileName: String?): Boolean {
    settings(profileName)?.setAllowFileAccess(allow)
    return true
  }

  override fun setBlockNetworkLoads(flag: Boolean, profileName: String?): Boolean {
    settings(profileName)?.setBlockNetworkLoads(flag)
    return true
  }

  /** Narrows Pigeon's `Long` into `@CacheMode int` — §162's shape; `lintDebug` settles it. */
  override fun setCacheMode(mode: Long, profileName: String?): Boolean {
    settings(profileName)?.setCacheMode(mode.toInt())
    return true
  }

  override fun setIncludeCookiesOnShouldInterceptRequestEnabled(
    enabled: Boolean,
    profileName: String?
  ): Boolean {
    settings(profileName)?.setIncludeCookiesOnShouldInterceptRequestEnabled(enabled)
    return true
  }

  /**
   * Asks Dart for a response and **blocks the calling thread** until it answers — the Pigeon twin of
   * `Util.invokeMethodAndWaitResult`, whose semantics it keeps:
   *
   *  - the call is posted to the main looper, where platform channels must be used;
   *  - the wait is bounded by [Util.SYNC_CALLBACK_TIMEOUT_MILLIS] — this client is process-wide and
   *    has no WebView settings to read a longer timeout from, as before;
   *  - a timeout, a Dart-side throw, no Dart handler at all, or a null answer all come back as
   *    **null**, which the caller treats as "not handled" and the request goes to the network.
   *
   * Every path out of the generated reply releases the latch: the callback is invoked exactly once
   * for success, error envelope and connection error alike (read in the generated `send`). The one
   * way it could not be is a `ClassCastException` on the reply's cast *before* the callback — which
   * requires the two generated halves to disagree, and they come from one schema. The timeout is the
   * backstop for that, as it was for the hand-written path.
   *
   * Not reused from `Util` because that helper takes a raw `MethodChannel` and still serves two
   * `WebViewChannelDelegate` calls and `WebViewAssetLoaderExt`.
   */
  @Throws(InterruptedException::class)
  fun shouldInterceptRequest(request: WebResourceRequestExt): WebResourceResponseExt? {
    val api = flutterApi ?: return null
    val latch = CountDownLatch(1)
    // Written on the main thread, read here after `await`: the latch provides the happens-before.
    val answer = AtomicReference<WebResourceResponseData?>(null)
    Handler(Looper.getMainLooper()).post {
      api.shouldInterceptRequest(request.toPigeon()) { result ->
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
          "answer \"shouldInterceptRequest\"; continuing as if it had returned null. Check that " +
          "the ServiceWorkerClient handler returns on every path and does not throw."
      )
      return null
    }
    return answer.get()?.toNative()
  }

  override fun dispose() {
    messenger?.let { ServiceWorkerHostApi.setUp(it, null) }
    messenger = null
    flutterApi = null
    serviceWorkerManager = null
  }

  companion object {
    private const val LOG_TAG = "ServiceWorkerChannelDelegate"
  }
}

// --- WebResourceRequestExt / WebResourceResponseExt <-> Pigeon -----------------------------------
//
// Kept local rather than added to `types/`, as §177, §179 and §180 did: both native types also serve
// `WebViewChannelDelegate`'s own `shouldInterceptRequest`, which is still hand-written. When that
// channel migrates, these two conversions and the two data classes should move with it (see the
// schema, checklist item 5).

private fun WebResourceRequestExt.toPigeon(): WebResourceRequestData = WebResourceRequestData(
  url = url,
  headers = headers,
  isRedirect = isRedirect,
  hasGesture = hasGesture,
  isForMainFrame = isForMainFrame,
  method = method
)

/**
 * `statusCode` narrows from Pigeon's `Long` to the `Int` `WebResourceResponse` takes — a plain `int`,
 * not an `@IntDef`. Every other field crosses unchanged, nullability included, because
 * [WebResourceResponseExt.toWebResourceResponse] branches on which are present.
 */
private fun WebResourceResponseData.toNative(): WebResourceResponseExt = WebResourceResponseExt(
  contentType = contentType,
  contentEncoding = contentEncoding,
  statusCode = statusCode?.toInt(),
  reasonPhrase = reasonPhrase,
  headers = headers,
  data = data,
  cookies = cookies
)
