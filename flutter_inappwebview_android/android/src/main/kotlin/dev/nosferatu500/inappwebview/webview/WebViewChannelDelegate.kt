package dev.nosferatu500.inappwebview.webview

import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import android.webkit.ValueCallback
import android.webkit.WebView
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.FlutterError
import dev.nosferatu500.inappwebview.pigeons.InAppWebViewFlutterApi
import dev.nosferatu500.inappwebview.pigeons.InAppWebViewHostApi
import dev.nosferatu500.inappwebview.print_job.PrintJobSettings
import dev.nosferatu500.inappwebview.types.BaseCallbackResultImpl
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.ClientCertChallenge
import dev.nosferatu500.inappwebview.types.ClientCertResponse
import dev.nosferatu500.inappwebview.types.ContentWorld
import dev.nosferatu500.inappwebview.types.CreateWindowAction
import dev.nosferatu500.inappwebview.types.CustomSchemeResponse
import dev.nosferatu500.inappwebview.types.DownloadStartRequest
import dev.nosferatu500.inappwebview.types.GeolocationPermissionShowPromptResponse
import dev.nosferatu500.inappwebview.types.HitTestResult
import dev.nosferatu500.inappwebview.types.HttpAuthResponse
import dev.nosferatu500.inappwebview.types.HttpAuthenticationChallenge
import dev.nosferatu500.inappwebview.types.InAppWebViewRect
import dev.nosferatu500.inappwebview.types.JavaScriptHandlerFunctionData
import dev.nosferatu500.inappwebview.types.JsAlertResponse
import dev.nosferatu500.inappwebview.types.JsBeforeUnloadResponse
import dev.nosferatu500.inappwebview.types.JsConfirmResponse
import dev.nosferatu500.inappwebview.types.JsPromptResponse
import dev.nosferatu500.inappwebview.types.NavigationAction
import dev.nosferatu500.inappwebview.types.NavigationActionPolicy
import dev.nosferatu500.inappwebview.types.PermissionResponse
import dev.nosferatu500.inappwebview.types.SafeBrowsingResponse
import dev.nosferatu500.inappwebview.types.ServerTrustAuthResponse
import dev.nosferatu500.inappwebview.types.ServerTrustChallenge
import dev.nosferatu500.inappwebview.types.ShowFileChooserRequest
import dev.nosferatu500.inappwebview.types.ShowFileChooserResponse
import dev.nosferatu500.inappwebview.types.SslCertificateExt
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserScript
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import dev.nosferatu500.inappwebview.types.WebViewNavigationExt
import dev.nosferatu500.inappwebview.types.WebViewPageExt
import dev.nosferatu500.inappwebview.types.deliverToCallback
import dev.nosferatu500.inappwebview.types.replyingOnThrow
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebViewSettings
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
//
// Transport is Pigeon since W5 (§216, TODO P0a): host methods on [InAppWebViewHostApi], events on
// [InAppWebViewFlutterApi], both suffixed by [suffix]. [suffix] is the MethodChannel name's tail,
// `inappwebview_$id` or `inappbrowser_$id`; the MethodChannel itself is now unused, and goes next.
@Suppress("UNCHECKED_CAST")
class WebViewChannelDelegate(
  webView: InAppWebView,
  channel: MethodChannel,
  messenger: BinaryMessenger,
  private val suffix: String
) : ChannelDelegateImpl(channel), InAppWebViewHostApi {

  private var webView: InAppWebView? = webView

  private var messenger: BinaryMessenger? = messenger

  /**
   * Every event, under the same suffix as the HostApi: fire-and-forget since W4 (§214),
   * value-returning since W5 (§216). Null after [dispose], so a late event is dropped, or takes its
   * default when it expects an answer, as a null `this.channel` did before.
   */
  private var flutterApi: InAppWebViewFlutterApi? = InAppWebViewFlutterApi(messenger, suffix)

  init {
    InAppWebViewHostApi.setUp(messenger, this, suffix)
  }

  /**
   * Only ever passed to `WebView.postVisualStateCallback` and echoed back to us unread: the channel
   * reply correlates the request, so this exists purely to make concurrent requests distinguishable
   * in a logcat trace. Not thread-safe by design -- every channel call arrives on the main thread.
   */
  private var nextVisualStateRequestId = 1L

  // Every host method is Pigeon since W3 (§212), on [InAppWebViewHostApi], and every event since W5
  // (§216), on [InAppWebViewFlutterApi]. Nothing uses the MethodChannel any more; it goes in the
  // item after W5. Until then, a call that still arrives here gets
  // `notImplemented`, as an unknown method always did, rather than no answer at all from the base
  // class's empty handler.
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    result.notImplemented()
  }

  fun onLongPressHitTestResult(hitTestResult: HitTestResult?) {
    flutterApi?.onLongPressHitTestResult(hitTestResult?.toMap()?.toMap()) {}
  }

  fun onScrollChanged(x: Int, y: Int) {
    flutterApi?.onScrollChanged(x.toLong(), y.toLong()) {}
  }

  fun onDownloadStarting(downloadStartRequest: DownloadStartRequest) {
    flutterApi?.onDownloadStarting(downloadStartRequest.toMap().toMap()) {}
  }

  fun onCreateContextMenu(hitTestResult: HitTestResult?) {
    flutterApi?.onCreateContextMenu(hitTestResult?.toMap()?.toMap()) {}
  }

  fun onOverScrolled(scrollX: Int, scrollY: Int, clampedX: Boolean, clampedY: Boolean) {
    flutterApi?.onOverScrolled(scrollX.toLong(), scrollY.toLong(), clampedX, clampedY) {}
  }

  fun onContextMenuActionItemClicked(itemId: Int, itemTitle: String?) {
    flutterApi?.onContextMenuActionItemClicked(itemId.toLong(), itemTitle) {}
  }

  fun onHideContextMenu() {
    flutterApi?.onHideContextMenu {}
  }

  fun onEnterFullscreen() {
    flutterApi?.onEnterFullscreen {}
  }

  fun onExitFullscreen() {
    flutterApi?.onExitFullscreen {}
  }

  // W5 (§216): each value-returning event below sends on [flutterApi] and hands the reply to the
  // callback its caller built, through [deliverToCallback], so `decodeResult`, `nonNullSuccess`,
  // `defaultBehaviour` and `error` are untouched. A null [flutterApi] (after [dispose]) runs the
  // default, as a null `this.channel` did.

  open class JsAlertCallback : BaseCallbackResultImpl<JsAlertResponse>() {
    override fun decodeResult(obj: Any?): JsAlertResponse? =
      JsAlertResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsAlert(url: String?, message: String?, isMainFrame: Boolean?, callback: JsAlertCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onJsAlert(url, message, isMainFrame) { deliverToCallback(callback, it) }
  }

  open class JsConfirmCallback : BaseCallbackResultImpl<JsConfirmResponse>() {
    override fun decodeResult(obj: Any?): JsConfirmResponse? =
      JsConfirmResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsConfirm(
    url: String?,
    message: String?,
    isMainFrame: Boolean?,
    callback: JsConfirmCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onJsConfirm(url, message, isMainFrame) { deliverToCallback(callback, it) }
  }

  open class JsPromptCallback : BaseCallbackResultImpl<JsPromptResponse>() {
    override fun decodeResult(obj: Any?): JsPromptResponse? =
      JsPromptResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsPrompt(
    url: String?,
    message: String?,
    defaultValue: String?,
    isMainFrame: Boolean?,
    callback: JsPromptCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onJsPrompt(url, message, defaultValue, isMainFrame) { deliverToCallback(callback, it) }
  }

  open class JsBeforeUnloadCallback : BaseCallbackResultImpl<JsBeforeUnloadResponse>() {
    override fun decodeResult(obj: Any?): JsBeforeUnloadResponse? =
      JsBeforeUnloadResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsBeforeUnload(url: String?, message: String?, callback: JsBeforeUnloadCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onJsBeforeUnload(url, message) { deliverToCallback(callback, it) }
  }

  open class CreateWindowCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean = obj is Boolean && obj
  }

  fun onCreateWindow(createWindowAction: CreateWindowAction, callback: CreateWindowCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onCreateWindow(createWindowAction.toMap().toMap()) { deliverToCallback(callback, it) }
  }

  fun onCloseWindow() {
    flutterApi?.onCloseWindow {}
  }

  open class GeolocationPermissionsShowPromptCallback :
    BaseCallbackResultImpl<GeolocationPermissionShowPromptResponse>() {
    override fun decodeResult(obj: Any?): GeolocationPermissionShowPromptResponse? =
      GeolocationPermissionShowPromptResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onGeolocationPermissionsShowPrompt(
    origin: String?,
    callback: GeolocationPermissionsShowPromptCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onGeolocationPermissionsShowPrompt(origin) { deliverToCallback(callback, it) }
  }

  fun onGeolocationPermissionsHidePrompt() {
    flutterApi?.onGeolocationPermissionsHidePrompt {}
  }

  fun onConsoleMessage(message: String?, messageLevel: Int) {
    flutterApi?.onConsoleMessage(message, messageLevel.toLong()) {}
  }

  fun onProgressChanged(progress: Int) {
    flutterApi?.onProgressChanged(progress.toLong()) {}
  }

  fun onTitleChanged(title: String?) {
    flutterApi?.onTitleChanged(title) {}
  }

  fun onReceivedTouchIconUrl(url: String?, precomposed: Boolean) {
    flutterApi?.onReceivedTouchIconUrl(url, precomposed) {}
  }

  open class PermissionRequestCallback : BaseCallbackResultImpl<PermissionResponse>() {
    override fun decodeResult(obj: Any?): PermissionResponse? =
      PermissionResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onPermissionRequest(
    origin: String?,
    resources: List<String>?,
    frame: Any?,
    callback: PermissionRequestCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onPermissionRequest(origin, resources, frame) { deliverToCallback(callback, it) }
  }

  fun onPermissionRequestCanceled(origin: String?, resources: List<String>?) {
    flutterApi?.onPermissionRequestCanceled(origin, resources) {}
  }

  open class ShouldOverrideUrlLoadingCallback :
    BaseCallbackResultImpl<NavigationActionPolicy>() {
    override fun decodeResult(obj: Any?): NavigationActionPolicy {
      val action = if (obj is Int) obj else NavigationActionPolicy.CANCEL.rawValue()
      return NavigationActionPolicy.fromValue(action)
    }
  }

  fun shouldOverrideUrlLoading(
    navigationAction: NavigationAction,
    callback: ShouldOverrideUrlLoadingCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.shouldOverrideUrlLoading(navigationAction.toMap().toMap()) {
      deliverToCallback(callback, it)
    }
  }

  fun onLoadStart(url: String?) {
    flutterApi?.onLoadStart(url) {}
  }

  fun onLoadStop(url: String?) {
    flutterApi?.onLoadStop(url) {}
  }

  fun onUpdateVisitedHistory(url: String?, isReload: Boolean) {
    flutterApi?.onUpdateVisitedHistory(url, isReload) {}
  }

  fun onReceivedError(request: WebResourceRequestExt, error: WebResourceErrorExt) {
    flutterApi?.onReceivedError(request.toMap().toMap(), error.toMap().toMap()) {}
  }

  fun onReceivedHttpError(
    request: WebResourceRequestExt,
    errorResponse: WebResourceResponseExt
  ) {
    flutterApi?.onReceivedHttpError(request.toMap().toMap(), errorResponse.toMap().toMap()) {}
  }

  open class ReceivedHttpAuthRequestCallback : BaseCallbackResultImpl<HttpAuthResponse>() {
    override fun decodeResult(obj: Any?): HttpAuthResponse? =
      HttpAuthResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onReceivedHttpAuthRequest(
    challenge: HttpAuthenticationChallenge,
    callback: ReceivedHttpAuthRequestCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onReceivedHttpAuthRequest(challenge.toMap().toMap()) { deliverToCallback(callback, it) }
  }

  open class ReceivedServerTrustAuthRequestCallback :
    BaseCallbackResultImpl<ServerTrustAuthResponse>() {
    override fun decodeResult(obj: Any?): ServerTrustAuthResponse? =
      ServerTrustAuthResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onReceivedServerTrustAuthRequest(
    challenge: ServerTrustChallenge,
    callback: ReceivedServerTrustAuthRequestCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onReceivedServerTrustAuthRequest(challenge.toMap().toMap()) {
      deliverToCallback(callback, it)
    }
  }

  open class ReceivedClientCertRequestCallback : BaseCallbackResultImpl<ClientCertResponse>() {
    override fun decodeResult(obj: Any?): ClientCertResponse? =
      ClientCertResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onReceivedClientCertRequest(
    challenge: ClientCertChallenge,
    callback: ReceivedClientCertRequestCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onReceivedClientCertRequest(challenge.toMap().toMap()) { deliverToCallback(callback, it) }
  }

  fun onZoomScaleChanged(oldScale: Float, newScale: Float) {
    flutterApi?.onZoomScaleChanged(oldScale.toDouble(), newScale.toDouble()) {}
  }

  open class SafeBrowsingHitCallback : BaseCallbackResultImpl<SafeBrowsingResponse>() {
    override fun decodeResult(obj: Any?): SafeBrowsingResponse? =
      SafeBrowsingResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onSafeBrowsingHit(url: String?, threatType: Int, callback: SafeBrowsingHitCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onSafeBrowsingHit(url, threatType.toLong()) { deliverToCallback(callback, it) }
  }

  open class FormResubmissionCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = if (obj is Int) obj else null
  }

  fun onFormResubmission(url: String?, callback: FormResubmissionCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onFormResubmission(url) { deliverToCallback(callback, it) }
  }

  fun onPageCommitVisible(url: String?) {
    flutterApi?.onPageCommitVisible(url) {}
  }

  fun onNavigationStarted(navigation: WebViewNavigationExt) {
    flutterApi?.onNavigationStarted(navigation.toMap().toMap()) {}
  }

  fun onNavigationRedirected(navigation: WebViewNavigationExt) {
    flutterApi?.onNavigationRedirected(navigation.toMap().toMap()) {}
  }

  fun onNavigationCompleted(navigation: WebViewNavigationExt) {
    flutterApi?.onNavigationCompleted(navigation.toMap().toMap()) {}
  }

  fun onPageLoadEvent(page: WebViewPageExt) {
    flutterApi?.onPageLoadEvent(page.toMap().toMap()) {}
  }

  fun onPageDomContentLoadedEvent(page: WebViewPageExt) {
    flutterApi?.onPageDomContentLoadedEvent(page.toMap().toMap()) {}
  }

  fun onPageDeleted(page: WebViewPageExt) {
    flutterApi?.onPageDeleted(page.toMap().toMap()) {}
  }

  fun onFirstContentfulPaintMillis(page: WebViewPageExt, durationMillis: Long) {
    flutterApi?.onFirstContentfulPaintMillis(page.toMap().toMap(), durationMillis) {}
  }

  fun onLargestContentfulPaintMillis(page: WebViewPageExt, durationMillis: Long) {
    flutterApi?.onLargestContentfulPaintMillis(page.toMap().toMap(), durationMillis) {}
  }

  fun onPerformanceMarkMillis(page: WebViewPageExt, markName: String, markTimeMillis: Long) {
    flutterApi?.onPerformanceMarkMillis(page.toMap().toMap(), markName, markTimeMillis) {}
  }

  fun onRenderProcessGone(didCrash: Boolean, rendererPriorityAtExit: Int) {
    flutterApi?.onRenderProcessGone(didCrash, rendererPriorityAtExit.toLong()) {}
  }

  fun onReceivedLoginRequest(realm: String?, account: String?, args: String?) {
    flutterApi?.onReceivedLoginRequest(realm, account, args) {}
  }

  /**
   * Blocking (W5, §216): asks Dart and **blocks the calling WebView worker thread** until it
   * answers, in `ServiceWorkerChannelDelegate.shouldInterceptRequest`'s shape (§186), keeping the
   * semantics of the `Util.invokeMethodAndWaitResult` call it replaces:
   *
   *  - the call is posted to the main looper, where platform channels must be used;
   *  - the wait is bounded by [syncCallbackTimeoutMillis], read once, at the call;
   *  - a timeout, a Dart throw, no Dart handler or a null answer all come back as null, so the
   *    resource loads normally.
   *
   * [ask] sends the event and hands [reply] a decoder, which runs on the main thread inside the
   * reply, as `decodeResult` did. The latch is released whatever the decoder does: a decoder that
   * throws leaves the answer null, and the throw reaches the messenger's reply handler, which logs
   * it, as before.
   */
  @Throws(InterruptedException::class)
  private fun <T> waitForDart(
    event: String,
    ask: (api: InAppWebViewFlutterApi, reply: (decode: () -> T?) -> Unit) -> Unit
  ): T? {
    val api = flutterApi ?: return null
    val timeoutMillis = syncCallbackTimeoutMillis()
    val latch = CountDownLatch(1)
    // Written on the main thread, read here after `await`: the latch provides the happens-before.
    val answer = AtomicReference<T?>(null)
    Handler(Looper.getMainLooper()).post {
      ask(api) { decode ->
        try {
          answer.set(decode())
        } finally {
          latch.countDown()
        }
      }
    }
    if (!latch.await(timeoutMillis, TimeUnit.MILLISECONDS)) {
      Log.w(
        LOG_TAG,
        "Timed out after ${timeoutMillis}ms waiting for the Dart side to answer \"$event\"; " +
          "continuing as if it had returned null. Check that the corresponding handler returns " +
          "on every path and does not throw."
      )
      return null
    }
    return answer.get()
  }

  @Throws(InterruptedException::class)
  fun onLoadResourceWithCustomScheme(request: WebResourceRequestExt): CustomSchemeResponse? =
    waitForDart("onLoadResourceWithCustomScheme") { api, reply ->
      api.onLoadResourceWithCustomScheme(request.toPigeon()) { result ->
        reply { CustomSchemeResponse.fromMap(result.getOrNull() as Map<String, Any?>?) }
      }
    }

  @Throws(InterruptedException::class)
  fun shouldInterceptRequest(request: WebResourceRequestExt): WebResourceResponseExt? =
    waitForDart("shouldInterceptRequest") { api, reply ->
      api.shouldInterceptRequest(request.toPigeon()) { result ->
        reply { result.getOrNull()?.let { WebResourceResponseExt.fromPigeon(it) } }
      }
    }

  /**
   * Read live from the WebView's current settings rather than captured once, so a `setSettings`
   * call takes effect on the very next callback. Falls back to the default when there is no
   * WebView left -- a delegate can outlive it by the length of one in-flight callback.
   */
  private fun syncCallbackTimeoutMillis(): Long =
    Util.resolveSyncCallbackTimeoutMillis(webView?.customSettings?.syncCallbackTimeoutMillis)

  open class RenderProcessUnresponsiveCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = if (obj is Int) obj else null
  }

  fun onRenderProcessUnresponsive(url: String?, callback: RenderProcessUnresponsiveCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onRenderProcessUnresponsive(url) { deliverToCallback(callback, it) }
  }

  open class RenderProcessResponsiveCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = if (obj is Int) obj else null
  }

  fun onRenderProcessResponsive(url: String?, callback: RenderProcessResponsiveCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onRenderProcessResponsive(url) { deliverToCallback(callback, it) }
  }

  open class CallJsHandlerCallback : BaseCallbackResultImpl<Any>() {
    override fun decodeResult(obj: Any?): Any? = obj
  }

  fun onCallJsHandler(
    handlerName: String?,
    data: JavaScriptHandlerFunctionData,
    callback: CallJsHandlerCallback
  ) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onCallJsHandler(handlerName, data.toMap().toMap()) { deliverToCallback(callback, it) }
  }

  open class PrintRequestCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean = obj is Boolean && obj
  }

  fun onPrintRequest(url: String?, callback: PrintRequestCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onPrintRequest(url) { deliverToCallback(callback, it) }
  }

  fun onRequestFocus() {
    flutterApi?.onRequestFocus {}
  }

  open class RequestVisitedHistoryCallback : BaseCallbackResultImpl<List<String>>() {
    // The codec decodes a Dart `List<String>` to `List<*>`. Filtering by type rather than casting
    // the elements keeps a stray non-string from throwing on the platform thread; the wire shape is
    // pinned by a unit test.
    override fun decodeResult(obj: Any?): List<String>? =
      (obj as? List<*>)?.filterIsInstance<String>()
  }

  fun onRequestVisitedHistory(callback: RequestVisitedHistoryCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onRequestVisitedHistory { deliverToCallback(callback, it) }
  }

  open class ShowFileChooserCallback : BaseCallbackResultImpl<ShowFileChooserResponse>() {
    override fun decodeResult(obj: Any?): ShowFileChooserResponse? =
      ShowFileChooserResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onShowFileChooser(request: ShowFileChooserRequest, callback: ShowFileChooserCallback) {
    val api = flutterApi
    if (api == null) {
      callback.defaultBehaviour(null)
      return
    }
    api.onShowFileChooser(request.toMap().toMap()) { deliverToCallback(callback, it) }
  }

  // --- InAppWebViewHostApi, W1 (§207) --------------------------------------------------------------
  // Each answers exactly what its `when` branch did, including for a WebView already gone: null for
  // the getters, `false` for the queries and `prerenderUrl`, `true` for everything else.

  override fun getUrl(): String? = webView?.url

  override fun getTitle(): String? = webView?.title

  override fun getProgress(): Long? = webView?.progress?.toLong()

  override fun getOriginalUrl(): String? = webView?.originalUrl

  override fun postUrl(url: String, postData: ByteArray): Boolean {
    webView?.postUrl(url, postData)
    return true
  }

  override fun loadData(
    data: String,
    mimeType: String?,
    encoding: String?,
    baseUrl: String?,
    historyUrl: String?
  ): Boolean {
    webView?.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl)
    return true
  }

  // The same code, message and details `result.error` sent, so Dart sees the same PlatformException.
  override fun loadFile(assetFilePath: String): Boolean {
    try {
      webView?.loadFile(assetFilePath)
    } catch (e: IOException) {
      e.printStackTrace()
      throw FlutterError(LOG_TAG, e.message, null)
    }
    return true
  }

  override fun reload(): Boolean {
    webView?.reload()
    return true
  }

  override fun goBack(): Boolean {
    webView?.goBack()
    return true
  }

  override fun canGoBack(): Boolean = webView?.canGoBack() == true

  override fun goForward(): Boolean {
    webView?.goForward()
    return true
  }

  override fun canGoForward(): Boolean = webView?.canGoForward() == true

  override fun goBackOrForward(steps: Long): Boolean {
    webView?.goBackOrForward(steps.toInt())
    return true
  }

  override fun canGoBackOrForward(steps: Long): Boolean =
    webView?.canGoBackOrForward(steps.toInt()) == true

  override fun stopLoading(): Boolean {
    webView?.stopLoading()
    return true
  }

  override fun isLoading(): Boolean = webView?.isLoading() == true

  override fun clearHistory(): Boolean {
    webView?.clearHistory()
    return true
  }

  override fun clearSslPreferences(): Boolean {
    webView?.clearSslPreferences()
    return true
  }

  override fun clearFormData(): Boolean {
    webView?.clearFormData()
    return true
  }

  override fun pause(): Boolean {
    webView?.onPause()
    return true
  }

  override fun resume(): Boolean {
    webView?.onResume()
    return true
  }

  override fun pauseTimers(): Boolean {
    webView?.pauseTimers()
    return true
  }

  override fun resumeTimers(): Boolean {
    webView?.resumeTimers()
    return true
  }

  override fun prerenderUrl(url: String): Boolean = webView?.prerenderUrl(url) == true

  override fun getContentHeight(): Long? = webView?.contentHeight?.toLong()

  // --- InAppWebViewHostApi, W2 (§210): the methods that answer from a callback -------------------
  //
  // Every one is `@async`, whose generated handler has no try/catch, so each body runs inside
  // `replyingOnThrow`: a synchronous throw becomes an error reply instead of a dead channel. Inbound
  // maps go through `Util.normalizeCodecInts`, because Pigeon sends nested ints as `Long` (§197).

  override fun evaluateJavascript(
    source: String,
    contentWorld: Map<String?, Any?>?,
    callback: (Result<String?>) -> Unit
  ) {
    replyingOnThrow("evaluateJavascript", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.evaluateJavascript(source, contentWorldOf(contentWorld)) { value ->
          reply(Result.success(value))
        }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun callAsyncJavaScript(
    functionBody: String,
    arguments: Map<String?, Any?>,
    contentWorld: Map<String?, Any?>?,
    callback: (Result<String?>) -> Unit
  ) {
    replyingOnThrow("callAsyncJavaScript", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.callAsyncJavaScript(
          functionBody,
          Util.normalizeCodecInts(arguments) as Map<String, Any?>,
          contentWorldOf(contentWorld)
        ) { value -> reply(Result.success(value)) }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun takeScreenshot(
    screenshotConfiguration: Map<String?, Any?>?,
    callback: (Result<ByteArray?>) -> Unit
  ) {
    replyingOnThrow("takeScreenshot", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        // `quality` is read `as Int` inside a posted runnable, where a `Long` would crash the app.
        webView.takeScreenshot(
          Util.normalizeCodecInts(screenshotConfiguration) as Map<String, Any?>?
        ) { bytes -> reply(Result.success(bytes)) }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun getContentWidth(callback: (Result<Long?>) -> Unit) {
    replyingOnThrow("getContentWidth", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.getContentWidth { contentWidth -> reply(Result.success(contentWidth?.toLong())) }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun getSelectedText(callback: (Result<String?>) -> Unit) {
    replyingOnThrow("getSelectedText", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.getSelectedText { value -> reply(Result.success(value)) }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun saveWebArchive(
    filePath: String,
    autoname: Boolean,
    callback: (Result<String?>) -> Unit
  ) {
    replyingOnThrow("saveWebArchive", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.saveWebArchive(filePath, autoname) { value -> reply(Result.success(value)) }
      } else {
        reply(Result.success(null))
      }
    }
  }

  override fun isSecureContext(callback: (Result<Boolean>) -> Unit) {
    replyingOnThrow("isSecureContext", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.isSecureContext { value -> reply(Result.success(value)) }
      } else {
        reply(Result.success(false))
      }
    }
  }

  // The reply is deliberately deferred until the frame is on screen -- that IS the feature.
  // `VisualStateCallback` is an abstract *class*, not an interface, so Kotlin cannot SAM-convert
  // a lambda here and the object expression is required.
  //
  // Every path replies exactly once: the platform invokes onComplete at most once per request,
  // and the null-webView branch answers immediately. The one case with no reply is a WebView
  // destroyed before the frame lands, which the platform documents as "callback not invoked" and
  // which the Dart doc tells callers to guard with Future.timeout.
  override fun postVisualStateCallback(callback: (Result<Unit>) -> Unit) {
    replyingOnThrow("postVisualStateCallback", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        webView.postVisualStateCallback(
          nextVisualStateRequestId++,
          object : WebView.VisualStateCallback() {
            override fun onComplete(requestId: Long) {
              reply(Result.success(Unit))
            }
          }
        )
      } else {
        reply(Result.success(Unit))
      }
    }
  }

  // The platform answers by *dispatching a Message* rather than returning a value or taking a
  // listener, so the reply has to come out of a Handler. Three notes on the shape:
  //
  //  - `Handler(Looper, Handler.Callback)` with a lambda, not `object : Handler()`. The no-arg
  //    Handler constructor is deprecated, and an anonymous Handler subclass is what Android
  //    lint's HandlerLeak flags. `Handler.Callback` is an interface, so SAM conversion works
  //    here -- unlike VisualStateCallback in postVisualStateCallback above, which is an
  //    abstract class.
  //  - main looper, because every channel call arrives on it and WebView is thread-affine.
  //  - the documented contract is arg1 == 1 for "references images", 0 for "does not".
  override fun documentHasImages(callback: (Result<Boolean>) -> Unit) {
    replyingOnThrow("documentHasImages", callback) { reply ->
      val webView = this.webView
      if (webView != null) {
        val handler = Handler(Looper.getMainLooper()) { msg ->
          reply(Result.success(msg.arg1 == 1))
          true
        }
        webView.documentHasImages(Message.obtain(handler))
      } else {
        reply(Result.success(false))
      }
    }
  }

  // --- InAppWebViewHostApi, W3 (§212): the rest ------------------------------------------------
  //
  // All synchronous. Inbound maps go through `normalize`, i.e. `Util.normalizeCodecInts`, so the
  // `as Int` reads in the parsers keep working (§197, §211).

  override fun loadUrl(urlRequest: Map<String?, Any?>): Boolean {
    webView?.loadUrl(URLRequest.fromMap(normalize(urlRequest))!!)
    return true
  }

  override fun injectJavascriptFileFromUrl(
    urlFile: String,
    scriptHtmlTagAttributes: Map<String?, Any?>?
  ): Boolean {
    webView?.injectJavascriptFileFromUrl(urlFile, normalize(scriptHtmlTagAttributes))
    return true
  }

  override fun injectCSSCode(source: String): Boolean {
    webView?.injectCSSCode(source)
    return true
  }

  override fun injectCSSFileFromUrl(
    urlFile: String,
    cssLinkHtmlTagAttributes: Map<String?, Any?>?
  ): Boolean {
    webView?.injectCSSFileFromUrl(urlFile, normalize(cssLinkHtmlTagAttributes))
    return true
  }

  // The WebView's own pair, for every WebView, an in-app browser's included (§206). Until §206 a
  // browser's WebView took a `browserActivity` branch here, a leftover from when the browser's
  // own `setSettings`/`getSettings` shared this channel (they are Pigeon since §199). Its map
  // carries no browser keys, so that branch replaced the browser's stored settings with
  // defaults: a toolbar colour and a fixed title set at open read back null (measured, §199 and
  // §206), and the back button and `didChangeTitle` acted on the defaults.
  override fun setSettings(settings: Map<String?, Any?>): Boolean {
    val webView = this.webView
    if (webView != null) {
      val inAppWebViewSettingsMap = normalize(settings) as HashMap<String, Any?>
      val inAppWebViewSettings = InAppWebViewSettings()
      inAppWebViewSettings.parse(inAppWebViewSettingsMap)
      webView.setSettings(inAppWebViewSettings, inAppWebViewSettingsMap)
    }
    return true
  }

  // A browser's WebView used to answer the browser's merged map here. Dart reads it with
  // `InAppWebViewSettings.fromMap`, which ignores the browser keys, so the answer Dart sees is
  // the same.
  override fun getSettings(): Map<String?, Any?>? = webView?.getCustomSettingsMap()?.toMap()

  // `show`, `hide`, `close` and `isHidden` used to arrive on this channel too, because an in-app
  // browser's WebView shares the browser's MethodChannel. They are Pigeon on
  // `InAppBrowserChannelDelegate` (§195).

  override fun getCopyBackForwardList(): Map<String?, Any?>? =
    webView?.getCopyBackForwardList()?.toMap()

  override fun scrollTo(x: Long, y: Long, animated: Boolean): Boolean {
    webView?.scrollTo(x.toInt(), y.toInt(), animated)
    return true
  }

  override fun scrollBy(x: Long, y: Long, animated: Boolean): Boolean {
    webView?.scrollBy(x.toInt(), y.toInt(), animated)
    return true
  }

  override fun printCurrentPage(settings: Map<String?, Any?>?): String? {
    val webView = this.webView ?: return null
    val printJobSettings = PrintJobSettings()
    normalize(settings)?.let { printJobSettings.parse(it) }
    return webView.printCurrentPage(printJobSettings)
  }

  override fun zoomBy(zoomFactor: Double): Boolean {
    webView?.zoomBy(zoomFactor.toFloat())
    return true
  }

  override fun getZoomScale(): Double? = webView?.getZoomScale()?.toDouble()

  override fun getHitTestResult(): Map<String?, Any?>? {
    val webView = this.webView ?: return null
    return HitTestResult.fromWebViewHitTestResult(webView.hitTestResult)?.toMap()?.toMap()
  }

  override fun pageDown(bottom: Boolean): Boolean = webView?.pageDown(bottom) == true

  override fun pageUp(top: Boolean): Boolean = webView?.pageUp(top) == true

  override fun zoomIn(): Boolean = webView?.zoomIn() == true

  override fun zoomOut(): Boolean = webView?.zoomOut() == true

  override fun clearFocus(): Boolean {
    webView?.clearFocus()
    return true
  }

  override fun requestFocus(
    direction: Long?,
    previouslyFocusedRect: Map<String?, Any?>?
  ): Boolean {
    val webView = this.webView ?: return false
    val rect = InAppWebViewRect.fromMap(normalize(previouslyFocusedRect))
    return if (direction != null && rect != null) {
      webView.requestFocus(direction.toInt(), rect.toRect())
    } else if (direction != null) {
      webView.requestFocus(direction.toInt())
    } else {
      webView.requestFocus()
    }
  }

  override fun setContextMenu(contextMenu: Map<String?, Any?>?): Boolean {
    webView?.setContextMenu(normalize(contextMenu))
    return true
  }

  override fun requestFocusNodeHref(): Map<String?, Any?>? =
    webView?.requestFocusNodeHref()?.toMap()

  override fun requestImageRef(): Map<String?, Any?>? = webView?.requestImageRef()?.toMap()

  override fun getScrollX(): Long? = webView?.scrollX?.toLong()

  override fun getScrollY(): Long? = webView?.scrollY?.toLong()

  override fun getCertificate(): Map<String?, Any?>? {
    val webView = this.webView ?: return null
    return SslCertificateExt.toMap(webView.certificate)?.toMap()
  }

  override fun addUserScript(userScript: Map<String?, Any?>): Boolean {
    val webView = this.webView ?: return false
    val script = UserScript.fromMap(normalize(userScript))!!
    return webView.getUserContentController().addUserOnlyScript(script)
  }

  override fun removeUserScript(index: Long, userScript: Map<String?, Any?>): Boolean {
    val webView = this.webView ?: return false
    val script = UserScript.fromMap(normalize(userScript))!!
    return webView.getUserContentController()
      .removeUserOnlyScriptAt(index.toInt(), script.injectionTime)
  }

  override fun removeUserScriptsByGroupName(groupName: String): Boolean {
    webView?.getUserContentController()?.removeUserOnlyScriptsByGroupName(groupName)
    return true
  }

  override fun removeAllUserScripts(): Boolean {
    webView?.getUserContentController()?.removeAllUserOnlyScripts()
    return true
  }

  override fun createWebMessageChannel(): Map<String?, Any?>? {
    val webView = this.webView
    return if (webView != null &&
      WebViewFeature.isFeatureSupported(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)
    ) {
      webView.createCompatWebMessageChannel().toMap().toMap()
    } else {
      null
    }
  }

  override fun postWebMessage(message: Map<String?, Any?>, targetOrigin: String): Boolean {
    val webView = this.webView
    if (webView == null ||
      !WebViewFeature.isFeatureSupported(WebViewFeature.POST_WEB_MESSAGE)
    ) {
      return true
    }
    val messageExt = WebMessageCompatExt.fromMap(normalize(message))!!
    val compatPorts = mutableListOf<WebMessagePortCompat>()
    messageExt.ports?.forEach { portExt ->
      val webMessageChannel = webView.getWebMessageChannels()?.get(portExt.webMessageChannelId)
      if (webMessageChannel != null) {
        compatPorts.add(webMessageChannel.compatPorts[portExt.index])
      }
    }
    val data = messageExt.data
    try {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
        data != null && messageExt.type == WebMessageCompat.TYPE_ARRAY_BUFFER
      ) {
        WebViewCompat.postWebMessage(
          webView,
          WebMessageCompat(data as ByteArray, compatPorts.toTypedArray()),
          Uri.parse(targetOrigin)
        )
      } else {
        WebViewCompat.postWebMessage(
          webView,
          WebMessageCompat(data?.toString(), compatPorts.toTypedArray()),
          Uri.parse(targetOrigin)
        )
      }
    } catch (e: Exception) {
      // The code and message `result.error(LOG_TAG, e.message, null)` sent.
      throw FlutterError(LOG_TAG, e.message, null)
    }
    return true
  }

  override fun addWebMessageListener(webMessageListener: Map<String?, Any?>): Boolean {
    val webView = this.webView ?: return true
    val listener = WebMessageListener.fromMap(
      webView,
      webView.getPlugin()!!.messenger,
      normalize(webMessageListener)
    )!!
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
      try {
        webView.addWebMessageListener(listener)
      } catch (e: Exception) {
        // The code and message `result.error(LOG_TAG, e.message, null)` sent.
        throw FlutterError(LOG_TAG, e.message, null)
      }
    }
    return true
  }

  override fun canScrollVertically(): Boolean = webView?.canScrollVertically() == true

  override fun canScrollHorizontally(): Boolean = webView?.canScrollHorizontally() == true

  override fun isInFullscreen(): Boolean = webView?.isInFullscreen() == true

  override fun hideInputMethod(): Boolean {
    val webView = this.webView ?: return false
    webView.hideInputMethod()
    return true
  }

  override fun showInputMethod(): Boolean {
    val webView = this.webView ?: return false
    webView.showInputMethod()
    return true
  }

  override fun saveState(maxSize: Long?, includeForwardState: Boolean?): ByteArray? =
    webView?.saveState(maxSize?.toInt(), includeForwardState)

  override fun restoreState(state: ByteArray?): Boolean {
    val webView = this.webView ?: return false
    return webView.restoreState(state!!)
  }

  override fun setAudioMuted(muted: Boolean): Boolean {
    val webView = this.webView ?: return false
    webView.setAudioMuted(muted)
    return true
  }

  override fun isAudioMuted(): Boolean = webView?.isAudioMuted() ?: false

  // Fire-and-forget, unlike `postVisualStateCallback` and `documentHasImages` (W2): the platform
  // starts a fling and returns immediately, so there is nothing to await. Where the scroll ends is
  // decided by the platform's deceleration, which is why this reports no position back.
  override fun flingScroll(velocityX: Long, velocityY: Long): Boolean {
    webView?.flingScroll(velocityX.toInt(), velocityY.toInt())
    return true
  }

  private fun normalize(map: Map<String?, Any?>?): Map<String, Any?>? =
    Util.normalizeCodecInts(map) as Map<String, Any?>?

  private fun contentWorldOf(map: Map<String?, Any?>?): ContentWorld? =
    ContentWorld.fromMap(Util.normalizeCodecInts(map) as Map<String, Any?>?)

  override fun dispose() {
    messenger?.let { InAppWebViewHostApi.setUp(it, null, suffix) }
    messenger = null
    flutterApi = null
    super.dispose()
    webView = null
  }

  companion object {
    const val LOG_TAG = "WebViewChannelDelegate"
  }
}
