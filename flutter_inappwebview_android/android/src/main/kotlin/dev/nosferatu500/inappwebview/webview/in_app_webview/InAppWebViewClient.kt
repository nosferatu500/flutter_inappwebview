package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Message
import android.util.Log
import android.view.KeyEvent
import android.webkit.ClientCertRequest
import android.webkit.CookieManager
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SafeBrowsingResponse
import android.webkit.SslErrorHandler
import android.webkit.ValueCallback
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.webkit.WebResourceRequestCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate

open class InAppWebViewClient(private var inAppBrowserDelegate: InAppBrowserDelegate?) :
  WebViewClient() {

  /**
   * The callback bodies this client shares with [InAppWebViewClientCompat], which also holds the
   * per-WebView HTTP-auth state. Only the four callbacks that genuinely differ between the two
   * clients are implemented here; see [InAppWebViewClientCommon] for which and why.
   */
  private val common = InAppWebViewClientCommon(LOG_TAG)

  override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
    val webView = view as InAppWebView

    if (common.allowSyncUrlLoading(webView, request.url.toString())) {
      // Allow the request synchronously.
      return false
    }

    if (webView.customSettings.useShouldOverrideUrlLoading) {
      val isRedirect =
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT)) {
          WebResourceRequestCompat.isRedirect(request)
        } else {
          request.isRedirect
        }
      onShouldOverrideUrlLoading(
        webView,
        request.url.toString(),
        request.method,
        request.requestHeaders,
        request.isForMainFrame,
        request.hasGesture(),
        isRedirect
      )
    }
    val regexToCancelSubFramesLoading = webView.customSettings.regexToCancelSubFramesLoading
    if (regexToCancelSubFramesLoading != null && !request.isForMainFrame) {
      return regexToCancelSubFramesLoading.matcher(request.url.toString()).matches()
    }
    if (webView.customSettings.useShouldOverrideUrlLoading) {
      // There isn't any way to load an URL for a frame that is not the main frame,
      // so if the request is not for the main frame, the navigation is allowed.
      return request.isForMainFrame
    }

    return false
  }

  fun onShouldOverrideUrlLoading(
    webView: InAppWebView,
    url: String,
    method: String?,
    headers: Map<String, String>?,
    isForMainFrame: Boolean,
    hasGesture: Boolean,
    isRedirect: Boolean
  ) = common.onShouldOverrideUrlLoading(
    webView, url, method, headers, isForMainFrame, hasGesture, isRedirect
  )

  @SuppressLint("RestrictedApi")
  fun loadCustomJavaScriptOnPageStarted(view: WebView) {
    val webView = view as InAppWebView

    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      val source = webView.userContentController.generateWrappedCodeForDocumentStart()
      webView.evaluateJavascript(source, null as ValueCallback<String>?)
    }
  }

  fun loadCustomJavaScriptOnPageFinished(view: WebView) {
    val webView = view as InAppWebView

    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      val source = webView.userContentController.generateWrappedCodeForDocumentEnd()
      webView.evaluateJavascript(source, null as ValueCallback<String>?)
    }
  }

  override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
    val webView = view as InAppWebView
    webView.isLoading = true
    webView.disposeWebMessageChannels()
    webView.userContentController.resetContentWorlds()
    loadCustomJavaScriptOnPageStarted(webView)

    super.onPageStarted(view, url, favicon)

    inAppBrowserDelegate?.didStartNavigation(url)

    webView.channelDelegate?.onLoadStart(url)
  }

  override fun onPageFinished(view: WebView, url: String?) {
    val webView = view as InAppWebView
    webView.isLoading = false
    loadCustomJavaScriptOnPageFinished(webView)
    common.httpAuthState.reset()

    super.onPageFinished(view, url)

    inAppBrowserDelegate?.didFinishNavigation(url)

    // WebView not storing cookies reliable to local device storage
    CookieManager.getInstance().flush()

    webView.evaluateJavascript(
      JavaScriptBridgeJS.PLATFORM_READY_JS_SOURCE(), null as ValueCallback<String>?
    )

    webView.channelDelegate?.onLoadStop(url)
  }

  override fun doUpdateVisitedHistory(view: WebView, url: String?, isReload: Boolean) {
    super.doUpdateVisitedHistory(view, url, isReload)

    // url argument sometimes doesn't contain the new changed URL, so we get it again from the
    // webview.
    val currentUrl = view.url

    inAppBrowserDelegate?.didUpdateVisitedHistory(currentUrl)

    val webView = view as InAppWebView
    webView.channelDelegate?.onUpdateVisitedHistory(currentUrl, isReload)
  }

  override fun onReceivedError(
    view: WebView,
    request: WebResourceRequest,
    error: WebResourceError
  ) {
    val webView = view as InAppWebView

    if (request.isForMainFrame) {
      if (webView.customSettings.disableDefaultErrorPage) {
        webView.stopLoading()
        webView.loadUrl("about:blank")
      }

      webView.isLoading = false
      common.httpAuthState.reset()

      inAppBrowserDelegate?.didFailNavigation(
        request.url.toString(), error.errorCode, error.description.toString()
      )
    }

    webView.channelDelegate?.onReceivedError(
      WebResourceRequestExt.fromWebResourceRequest(request),
      WebResourceErrorExt.fromWebResourceError(error)
    )
  }

  override fun onReceivedHttpError(
    view: WebView,
    request: WebResourceRequest,
    errorResponse: WebResourceResponse
  ) {
    super.onReceivedHttpError(view, request, errorResponse)

    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedHttpError(
      WebResourceRequestExt.fromWebResourceRequest(request),
      WebResourceResponseExt.fromWebResourceResponse(errorResponse)
    )
  }

  // The shared bodies live in [InAppWebViewClientCommon]; what cannot move is `super`, which is
  // bound to this class. Kotlin has no `Outer.super.member()` form to call from inside the
  // anonymous callback objects those bodies create, which is what the four private `superOn*`
  // forwarders used to work around. A lambda written *here* has no such restriction, so each
  // shared method takes one `() -> Unit` instead.
  override fun onReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String?,
    realm: String?
  ) = common.onReceivedHttpAuthRequest(view, handler, host, realm) {
    super.onReceivedHttpAuthRequest(view, handler, host, realm)
  }

  // The plugin does not decide SSL trust: onReceivedServerTrustAuthRequest is forwarded to Dart
  // and the app answers proceed/cancel. defaultBehaviour() below cancels, so doing nothing is
  // secure by default -- handler.proceed() runs only when the embedding app explicitly asks for
  // it, which is the documented purpose of the callback. Lint cannot see the Dart round-trip.
  @SuppressLint("WebViewClientOnReceivedSslError")
  override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, sslError: SslError) =
    common.onReceivedSslError(view, handler, sslError) {
      super.onReceivedSslError(view, handler, sslError)
    }

  override fun onReceivedClientCertRequest(view: WebView, request: ClientCertRequest) =
    common.onReceivedClientCertRequest(view, request) {
      super.onReceivedClientCertRequest(view, request)
    }

  override fun onScaleChanged(view: WebView, oldScale: Float, newScale: Float) {
    super.onScaleChanged(view, oldScale, newScale)
    val webView = view as InAppWebView
    webView.zoomScale = newScale / Util.getPixelDensity(webView.context)

    webView.channelDelegate?.onZoomScaleChanged(oldScale, newScale)
  }

  private fun superOnSafeBrowsingHit(
    view: WebView,
    request: WebResourceRequest,
    threatType: Int,
    callback: SafeBrowsingResponse
  ) = super.onSafeBrowsingHit(view, request, threatType, callback)

  override fun onSafeBrowsingHit(
    view: WebView,
    request: WebResourceRequest,
    threatType: Int,
    callback: SafeBrowsingResponse
  ) {
    val webView = view as InAppWebView
    val resultCallback = object : WebViewChannelDelegate.SafeBrowsingHitCallback() {
      override fun nonNullSuccess(
        result: dev.nosferatu500.inappwebview.types.SafeBrowsingResponse
      ): Boolean {
        val action = result.action
        if (action != null) {
          val report = result.isReport
          when (action) {
            0 -> callback.backToSafety(report)
            1 -> callback.proceed(report)
            else -> callback.showInterstitial(report)
          }

          return false
        }

        return true
      }

      override fun defaultBehaviour(
        result: dev.nosferatu500.inappwebview.types.SafeBrowsingResponse?
      ) {
        superOnSafeBrowsingHit(view, request, threatType, callback)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onSafeBrowsingHit(request.url.toString(), threatType, resultCallback)
    } else {
      resultCallback.defaultBehaviour(null)
    }
  }

  fun shouldInterceptRequest(view: WebView, request: WebResourceRequestExt): WebResourceResponse? =
    common.shouldInterceptRequest(view, request)

  override fun shouldInterceptRequest(
    view: WebView,
    request: WebResourceRequest
  ): WebResourceResponse? =
    shouldInterceptRequest(view, WebResourceRequestExt.fromWebResourceRequest(request))

  override fun onFormResubmission(view: WebView, dontResend: Message, resend: Message) =
    common.onFormResubmission(view, dontResend, resend) {
      super.onFormResubmission(view, dontResend, resend)
    }

  override fun onPageCommitVisible(view: WebView, url: String?) {
    super.onPageCommitVisible(view, url)

    val webView = view as InAppWebView
    webView.channelDelegate?.onPageCommitVisible(url)
  }

  override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean {
    val webView = view as InAppWebView

    val channelDelegate = webView.channelDelegate
    if (webView.customSettings.useOnRenderProcessGone && channelDelegate != null) {
      channelDelegate.onRenderProcessGone(detail.didCrash(), detail.rendererPriorityAtExit())
      return true
    }

    return super.onRenderProcessGone(view, detail)
  }

  override fun onReceivedLoginRequest(
    view: WebView,
    realm: String?,
    account: String?,
    args: String?
  ) {
    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedLoginRequest(realm, account, args)
  }

  override fun onUnhandledKeyEvent(view: WebView, event: KeyEvent) {}

  fun dispose() {
    inAppBrowserDelegate = null
  }

  companion object {
    protected const val LOG_TAG = "IAWebViewClient"
  }
}
