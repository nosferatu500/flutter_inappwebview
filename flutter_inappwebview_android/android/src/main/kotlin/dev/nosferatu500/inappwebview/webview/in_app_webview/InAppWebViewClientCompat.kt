package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Message
import android.view.KeyEvent
import android.webkit.ClientCertRequest
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import androidx.webkit.SafeBrowsingResponseCompat
import androidx.webkit.WebResourceErrorCompat
import androidx.webkit.WebViewClientCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt

/**
 * The `WebViewClient` used on every realistic device: `WebViewClientCompat` is selected whenever the
 * WebView package is known and is Chromium 73 or newer (crbug 925887 is the exception).
 *
 * **Every callback body lives in [InAppWebViewClientCommon]** — this class is the `androidx.webkit`
 * half of the pair and holds only what is bound to the type it extends: the `super` calls, the
 * platform parameter types, and the feature guards that the Compat types require and the plain ones
 * do not.
 */
open class InAppWebViewClientCompat(inAppBrowserDelegate: InAppBrowserDelegate?) :
  WebViewClientCompat() {

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
    error: WebResourceErrorCompat
  ) = common.onReceivedError(
    view,
    request,
    WebResourceErrorExt.fromWebResourceError(error),
    // Both are lazy: reading either from a WebResourceErrorCompat throws when the WebView does not
    // support the corresponding feature, and the fallbacks below are what the old code reported.
    {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE)) {
        error.errorCode
      } else {
        -1
      }
    },
    {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION)) {
        error.description.toString()
      } else {
        ""
      }
    }
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
    callback: SafeBrowsingResponseCompat
  ) = common.onSafeBrowsingHit(
    view,
    request,
    threatType,
    { super.onSafeBrowsingHit(view, request, threatType, callback) },
    { action, report ->
      // Each response action is separately feature-gated on a SafeBrowsingResponseCompat. Returning
      // false leaves the challenge unanswered, which is what the old code's `return true` did.
      when (action) {
        0 ->
          if (WebViewFeature.isFeatureSupported(
              WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY
            )
          ) {
            callback.backToSafety(report)
            true
          } else {
            false
          }

        1 ->
          if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED)) {
            callback.proceed(report)
            true
          } else {
            false
          }

        else ->
          if (WebViewFeature.isFeatureSupported(
              WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL
            )
          ) {
            callback.showInterstitial(report)
            true
          } else {
            false
          }
      }
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

  // `url` is non-null here and nullable on InAppWebViewClient -- the one signature the two clients
  // genuinely disagree on. The shared body takes the nullable form, which both can call.
  override fun onPageCommitVisible(view: WebView, url: String) {
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
    protected const val LOG_TAG = "IAWebViewClientCompat"
  }
}
