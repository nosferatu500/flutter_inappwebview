package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.Uri
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
import dev.nosferatu500.inappwebview.credential_database.CredentialDatabase
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.ClientCertChallenge
import dev.nosferatu500.inappwebview.types.ClientCertResponse
import dev.nosferatu500.inappwebview.types.HttpAuthResponse
import dev.nosferatu500.inappwebview.types.HttpAuthenticationChallenge
import dev.nosferatu500.inappwebview.types.NavigationAction
import dev.nosferatu500.inappwebview.types.NavigationActionPolicy
import dev.nosferatu500.inappwebview.types.ServerTrustAuthResponse
import dev.nosferatu500.inappwebview.types.ServerTrustChallenge
import dev.nosferatu500.inappwebview.types.URLProtectionSpace
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate
import java.io.ByteArrayInputStream
import java.net.URI
import java.net.URISyntaxException
import java.util.Locale

open class InAppWebViewClient(private var inAppBrowserDelegate: InAppBrowserDelegate?) :
  WebViewClient() {

  /**
   * The HTTP-auth conversation state for **this** WebView.
   *
   * It was two `private var`s in the `companion object` — process-global, shared by every WebView
   * in the app. See [HttpAuthState] for what that cost.
   */
  private val httpAuthState = HttpAuthState()

  override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
    val webView = view as InAppWebView

    if (allowSyncUrlLoading(webView, request.url.toString())) {
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

  private fun allowSyncUrlLoading(webView: InAppWebView, url: String): Boolean {
    val regex = webView.customSettings.regexToAllowSyncUrlLoading
    if (regex != null && regex.matcher(url).matches()) {
      Log.d(
        LOG_TAG,
        "Request '$url' automatically allowed as it is a match for " +
          "'regexToAllowSyncUrlLoading'."
      )
      return true
    }
    return false
  }

  private fun allowShouldOverrideUrlLoading(
    webView: WebView,
    url: String,
    headers: Map<String, String>?,
    isForMainFrame: Boolean
  ) {
    if (isForMainFrame) {
      // There isn't any way to load an URL for a frame that is not the main frame,
      // so call this only on main frame.
      if (headers != null) {
        webView.loadUrl(url, headers)
      } else {
        webView.loadUrl(url)
      }
    }
  }

  fun onShouldOverrideUrlLoading(
    webView: InAppWebView,
    url: String,
    method: String?,
    headers: Map<String, String>?,
    isForMainFrame: Boolean,
    hasGesture: Boolean,
    isRedirect: Boolean
  ) {
    val request = URLRequest(url, method, null, headers)
    val navigationAction = NavigationAction(request, isForMainFrame, hasGesture, isRedirect)

    val callback = object : WebViewChannelDelegate.ShouldOverrideUrlLoadingCallback() {
      override fun nonNullSuccess(result: NavigationActionPolicy): Boolean {
        when (result) {
          NavigationActionPolicy.ALLOW ->
            allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame)

          NavigationActionPolicy.CANCEL -> {}
        }
        return false
      }

      override fun defaultBehaviour(result: NavigationActionPolicy?) {
        allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.shouldOverrideUrlLoading(navigationAction, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

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
    httpAuthState.reset()

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
      httpAuthState.reset()

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

  // Kotlin has no `Outer.super.member()` form for use inside an anonymous object, so each super
  // call the callbacks below need is exposed as a private forwarder.
  private fun superOnReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String?,
    realm: String?
  ) = super.onReceivedHttpAuthRequest(view, handler, host, realm)

  override fun onReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String?,
    realm: String?
  ) {
    val url = view.url
    var protocol = "https"
    var port = 0

    if (url != null) {
      try {
        val uri = URI(url)
        protocol = uri.scheme
        port = uri.port
      } catch (e: URISyntaxException) {
        Log.e(LOG_TAG, "", e)
      }
    }

    val failureCount = httpAuthState.beginChallenge(host, protocol, realm, port)

    if (httpAuthState.needsCredentials()) {
      httpAuthState.setCredentials(
        CredentialDatabase.getInstance(view.context)
          .getHttpAuthCredentials(host, protocol, realm, port)
      )
    }

    val credentialProposed = httpAuthState.peekCredential()

    val protectionSpace =
      URLProtectionSpace(host!!, protocol, realm, port, view.certificate, null)
    val challenge = HttpAuthenticationChallenge(
      protectionSpace, failureCount, credentialProposed
    )

    val webView = view as InAppWebView
    val finalProtocol = protocol
    val finalPort = port
    val callback = object : WebViewChannelDelegate.ReceivedHttpAuthRequestCallback() {
      override fun nonNullSuccess(result: HttpAuthResponse): Boolean {
        val action = result.action
        if (action != null) {
          when (action) {
            1 -> {
              val username = result.username
              val password = result.password
              if (result.isPermanentPersistence) {
                CredentialDatabase.getInstance(view.context).setHttpAuthCredential(
                  host, finalProtocol, realm, finalPort, username, password
                )
              }
              handler.proceed(username, password)
            }

            2 -> {
              val credential = httpAuthState.popCredential()
              if (credential != null) {
                handler.proceed(credential.username, credential.password)
              } else {
                handler.cancel()
              }
              // used custom CredentialDatabase!
              // handler.useHttpAuthUsernamePassword();
            }

            else -> {
              httpAuthState.reset()
              handler.cancel()
            }
          }

          return false
        }

        return true
      }

      override fun defaultBehaviour(result: HttpAuthResponse?) {
        superOnReceivedHttpAuthRequest(view, handler, host, realm)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedHttpAuthRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  private fun superOnReceivedSslError(
    view: WebView,
    handler: SslErrorHandler,
    sslError: SslError
  ) = super.onReceivedSslError(view, handler, sslError)

  // The plugin does not decide SSL trust: onReceivedServerTrustAuthRequest is forwarded to Dart
  // and the app answers proceed/cancel. defaultBehaviour() below cancels, so doing nothing is
  // secure by default -- handler.proceed() runs only when the embedding app explicitly asks for
  // it, which is the documented purpose of the callback. Lint cannot see the Dart round-trip.
  @SuppressLint("WebViewClientOnReceivedSslError")
  override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, sslError: SslError) {
    val url = sslError.url
    var host = ""
    var protocol = "https"
    var port = 0

    try {
      val uri = URI(url)
      host = uri.host
      protocol = uri.scheme
      port = uri.port
    } catch (e: URISyntaxException) {
      Log.e(LOG_TAG, "", e)
    }

    val protectionSpace =
      URLProtectionSpace(host, protocol, null, port, sslError.certificate, sslError)
    val challenge = ServerTrustChallenge(protectionSpace)

    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.ReceivedServerTrustAuthRequestCallback() {
      override fun nonNullSuccess(result: ServerTrustAuthResponse): Boolean {
        val action = result.action
        if (action != null) {
          when (action) {
            1 -> handler.proceed()
            else -> handler.cancel()
          }

          return false
        }

        return true
      }

      override fun defaultBehaviour(result: ServerTrustAuthResponse?) {
        superOnReceivedSslError(view, handler, sslError)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedServerTrustAuthRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  private fun superOnReceivedClientCertRequest(view: WebView, request: ClientCertRequest) =
    super.onReceivedClientCertRequest(view, request)

  override fun onReceivedClientCertRequest(view: WebView, request: ClientCertRequest) {
    val url = view.url
    val host = request.host
    var protocol = "https"
    val port = request.port

    if (url != null) {
      try {
        protocol = URI(url).scheme
      } catch (e: URISyntaxException) {
        Log.e(LOG_TAG, "", e)
      }
    }

    val protectionSpace =
      URLProtectionSpace(host, protocol, null, port, view.certificate, null)
    val challenge =
      ClientCertChallenge(protectionSpace, request.principals, request.keyTypes)

    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.ReceivedClientCertRequestCallback() {
      override fun nonNullSuccess(result: ClientCertResponse): Boolean {
        val action = result.action
        val plugin = webView.plugin
        if (action != null && plugin != null) {
          when (action) {
            1 -> {
              val privateKeyAndCertificates = Util.loadPrivateKeyAndCertificate(
                plugin,
                result.certificatePath,
                result.certificatePassword,
                result.keyStoreType
              )
              if (privateKeyAndCertificates != null) {
                request.proceed(
                  privateKeyAndCertificates.privateKey,
                  privateKeyAndCertificates.certificates
                )
              } else {
                request.cancel()
              }
            }

            2 -> request.ignore()

            else -> request.cancel()
          }

          return false
        }

        return true
      }

      override fun defaultBehaviour(result: ClientCertResponse?) {
        superOnReceivedClientCertRequest(view, request)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedClientCertRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
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

  fun shouldInterceptRequest(view: WebView, request: WebResourceRequestExt): WebResourceResponse? {
    val webView = view as InAppWebView

    val loader = webView.webViewAssetLoaderExt?.loader
    if (loader != null) {
      try {
        val webResourceResponse = loader.shouldInterceptRequest(Uri.parse(request.url))
        if (webResourceResponse != null) {
          return webResourceResponse
        }
      } catch (e: Exception) {
        Log.e(LOG_TAG, "", e)
      }
    }

    if (webView.customSettings.useShouldInterceptRequest) {
      var response: WebResourceResponseExt? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        try {
          response = channelDelegate.shouldInterceptRequest(request)
        } catch (e: InterruptedException) {
          Log.e(LOG_TAG, "", e)
          return null
        }
      }

      if (response != null) {
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

      return null
    }

    val url = request.url
    var scheme = url.split(":").toTypedArray()[0].lowercase(Locale.ROOT)
    try {
      scheme = Uri.parse(request.url).scheme!!
    } catch (ignored: Exception) {
    }

    if (webView.customSettings.resourceCustomSchemes.contains(scheme)) {
      var customSchemeResponse: dev.nosferatu500.inappwebview.types.CustomSchemeResponse? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        try {
          customSchemeResponse = channelDelegate.onLoadResourceWithCustomScheme(request)
        } catch (e: InterruptedException) {
          Log.e(LOG_TAG, "", e)
          return null
        }
      }

      if (customSchemeResponse != null) {
        var response: WebResourceResponse? = null
        try {
          response = webView.contentBlockerHandler.checkUrl(
            webView, request, customSchemeResponse.contentType
          )
        } catch (e: Exception) {
          Log.e(LOG_TAG, "", e)
        }
        if (response != null) {
          return response
        }
        return WebResourceResponse(
          customSchemeResponse.contentType,
          customSchemeResponse.contentType,
          ByteArrayInputStream(customSchemeResponse.data)
        )
      }
    }

    var response: WebResourceResponse? = null
    if (webView.contentBlockerHandler.ruleList.isNotEmpty()) {
      try {
        response = webView.contentBlockerHandler.checkUrl(webView, request)
      } catch (e: Exception) {
        Log.e(LOG_TAG, "", e)
      }
    }
    return response
  }

  override fun shouldInterceptRequest(
    view: WebView,
    request: WebResourceRequest
  ): WebResourceResponse? =
    shouldInterceptRequest(view, WebResourceRequestExt.fromWebResourceRequest(request))

  private fun superOnFormResubmission(view: WebView, dontResend: Message, resend: Message) =
    super.onFormResubmission(view, dontResend, resend)

  override fun onFormResubmission(view: WebView, dontResend: Message, resend: Message) {
    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.FormResubmissionCallback() {
      override fun nonNullSuccess(result: Int): Boolean {
        when (result) {
          0 -> resend.sendToTarget()
          else -> dontResend.sendToTarget()
        }
        return false
      }

      override fun defaultBehaviour(result: Int?) {
        superOnFormResubmission(view, dontResend, resend)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onFormResubmission(webView.url, callback)
    } else {
      callback.defaultBehaviour(null)
    }
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
