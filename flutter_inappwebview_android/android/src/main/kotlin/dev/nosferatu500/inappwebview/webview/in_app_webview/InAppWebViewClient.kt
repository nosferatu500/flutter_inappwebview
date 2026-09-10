package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Message
import android.view.KeyEvent
import android.webkit.ClientCertRequest
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SafeBrowsingResponse
import android.webkit.SslErrorHandler
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt

/**
 * The `WebViewClient` used when [InAppWebViewClientCompat] cannot be: the WebView package is
 * unknown, or it is Chromium below 73 (crbug 925887).
 *
 * **Every callback body lives in [InAppWebViewClientCommon]** — this class is the `android.webkit`
 * half of the pair and holds only what is bound to the type it extends: the `super` calls, the
 * platform parameter types, and the two places where a value is read from an `android.webkit` type
 * rather than its `androidx.webkit` equivalent.
 */
open class InAppWebViewClient(inAppBrowserDelegate: InAppBrowserDelegate?) : WebViewClient() {

  // Kotlin has no `Outer.super.member()` form to call from inside the anonymous callback objects
  // the shared bodies create, which is what the four private `superOn*` forwarders here used to
  // work around. A lambda written in this class has no such restriction, so each shared method that
  // needs `super` takes one instead. Where `super` is called first and unconditionally, the
  // override below calls it directly and the shared method takes no lambda at all.
  private val common = InAppWebViewClientCommon(LOG_TAG, inAppBrowserDelegate)

  override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
    common.shouldOverrideUrlLoading(view, request)

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

  // Called from InAppWebViewChromeClient, so it stays on the client rather than only on `common`.
  fun loadCustomJavaScriptOnPageStarted(view: WebView) =
    common.loadCustomJavaScriptOnPageStarted(view)

  fun loadCustomJavaScriptOnPageFinished(view: WebView) =
    common.loadCustomJavaScriptOnPageFinished(view)

  override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) =
    common.onPageStarted(view, url) { super.onPageStarted(view, url, favicon) }

  override fun onPageFinished(view: WebView, url: String?) =
    common.onPageFinished(view, url) { super.onPageFinished(view, url) }

  override fun doUpdateVisitedHistory(view: WebView, url: String?, isReload: Boolean) {
    super.doUpdateVisitedHistory(view, url, isReload)
    common.doUpdateVisitedHistory(view, isReload)
  }

  override fun onReceivedError(
    view: WebView,
    request: WebResourceRequest,
    error: WebResourceError
  ) = common.onReceivedError(
    view,
    request,
    WebResourceErrorExt.fromWebResourceError(error),
    { error.errorCode },
    { error.description.toString() }
  )

  override fun onReceivedHttpError(
    view: WebView,
    request: WebResourceRequest,
    errorResponse: WebResourceResponse
  ) {
    super.onReceivedHttpError(view, request, errorResponse)
    common.onReceivedHttpError(view, request, errorResponse)
  }

  override fun onReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String?,
    realm: String?
  ) = common.onReceivedHttpAuthRequest(view, handler, host, realm) {
    super.onReceivedHttpAuthRequest(view, handler, host, realm)
  }

  // The plugin does not decide SSL trust: onReceivedServerTrustAuthRequest is forwarded to Dart
  // and the app answers proceed/cancel. defaultBehaviour() cancels, so doing nothing is secure by
  // default -- handler.proceed() runs only when the embedding app explicitly asks for it, which is
  // the documented purpose of the callback. Lint cannot see the Dart round-trip.
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
    common.onScaleChanged(view, oldScale, newScale)
  }

  override fun onSafeBrowsingHit(
    view: WebView,
    request: WebResourceRequest,
    threatType: Int,
    callback: SafeBrowsingResponse
  ) = common.onSafeBrowsingHit(
    view,
    request,
    threatType,
    { super.onSafeBrowsingHit(view, request, threatType, callback) },
    { action, report ->
      // Unguarded, unlike the Compat client: these are plain `android.webkit` methods.
      when (action) {
        0 -> callback.backToSafety(report)
        1 -> callback.proceed(report)
        else -> callback.showInterstitial(report)
      }
      true
    }
  )

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
    common.onPageCommitVisible(view, url)
  }

  override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean =
    common.onRenderProcessGone(view, detail) { super.onRenderProcessGone(view, detail) }

  override fun onReceivedLoginRequest(
    view: WebView,
    realm: String?,
    account: String?,
    args: String?
  ) = common.onReceivedLoginRequest(view, realm, account, args)

  override fun onUnhandledKeyEvent(view: WebView, event: KeyEvent) {}

  fun dispose() = common.dispose()

  companion object {
    protected const val LOG_TAG = "IAWebViewClient"
  }
}
