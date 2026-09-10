package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.net.Uri
import android.net.http.SslError
import android.os.Message
import android.util.Log
import android.webkit.ClientCertRequest
import android.webkit.CookieManager
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.ValueCallback
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import androidx.webkit.WebResourceRequestCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.credential_database.CredentialDatabase
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.ClientCertChallenge
import dev.nosferatu500.inappwebview.types.ClientCertResponse
import dev.nosferatu500.inappwebview.types.CustomSchemeResponse
import dev.nosferatu500.inappwebview.types.HttpAuthResponse
import dev.nosferatu500.inappwebview.types.HttpAuthenticationChallenge
import dev.nosferatu500.inappwebview.types.NavigationAction
import dev.nosferatu500.inappwebview.types.NavigationActionPolicy
import dev.nosferatu500.inappwebview.types.SafeBrowsingResponse
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

/**
 * The `WebViewClient` callback bodies that [InAppWebViewClient] and [InAppWebViewClientCompat]
 * share.
 *
 * The two clients exist because `androidx.webkit.WebViewClientCompat` cannot be used on a Chromium
 * WebView below 73 (crbug 925887), and Kotlin has single inheritance, so neither can extend the
 * other — `WebViewClientCompat` already extends `android.webkit.WebViewClient`. Before this class
 * they were 742 and 783 lines that a type-name-normalising `diff` reduced to **6 hunks / 67 lines**:
 * ~95% duplication, and every fix in the area had to be made twice. §97's own note missed the
 * second copy, and §99 found that the class the row named is *not* the one that runs.
 *
 * **What is not here, and why.** Only the platform-bound halves of three callbacks stay per-class:
 * - `onReceivedError` — Compat feature-guards the error code and description
 * - `onSafeBrowsingHit` — different callback type, and Compat feature-guards each response action
 * - `onPageCommitVisible` — the two signatures disagree on nullability (`String?` vs `String`)
 *
 * `shouldOverrideUrlLoading` is **not** in that list, despite the scoping note saying it was. Both
 * clients read the redirect flag through `WebResourceRequestCompat`, which takes a plain
 * `WebResourceRequest`, so the two bodies are byte-identical. The apparent difference was an
 * artifact of the `sed` used to compare the files: normalising `WebResourceRequestCompat` to
 * `WebResourceRequest` rewrote a line that was already the same in both.
 *
 * **The `superCall` lambdas.** The shared bodies reach `super.X()` at four sites, always from a
 * callback's `defaultBehaviour`. That looks like it forces a multi-method delegate interface; it
 * does not, because no shared method needs more than one, so each takes a single `() -> Unit` that
 * the owning client fills with its own `super`.
 *
 * The [logTag] is per client so the two keep their distinct tags (`IAWebViewClient` /
 * `IAWebViewClientCompat`) — collapsing them would have been an observable change in a commit whose
 * job is to move code.
 *
 * **Where a callback differs only in *which platform type* it reads**, the difference is passed in
 * as a lambda rather than duplicating the body: the error code and description for
 * `onReceivedError`, and `respond` for `onSafeBrowsingHit`. Both are *lazy* on purpose — the
 * originals evaluated those expressions only on some paths (inside a `?.`, or behind a feature
 * guard), and an eager parameter would change when they run.
 */
internal class InAppWebViewClientCommon(
  private val logTag: String,
  private var inAppBrowserDelegate: InAppBrowserDelegate?
) {

  /**
   * The HTTP-auth conversation state for **this** WebView.
   *
   * It was two `private var`s in the `companion object` of each client — process-global, shared by
   * every WebView in the app. See [HttpAuthState] for what that cost. It lives here because
   * [onReceivedHttpAuthRequest] is shared, but the clients still reset it from their own
   * `onPageFinished` and `onReceivedError`.
   */
  val httpAuthState = HttpAuthState()

  fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
    val webView = view as InAppWebView

    if (allowSyncUrlLoading(webView, request.url.toString())) {
      // Allow the request synchronously.
      return false
    }

    if (webView.customSettings.useShouldOverrideUrlLoading) {
      // Both clients read this through `WebResourceRequestCompat`, including the one that extends
      // `android.webkit.WebViewClient` -- the androidx helper takes a plain `WebResourceRequest`.
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

  fun onPageStarted(view: WebView, url: String?, superCall: () -> Unit) {
    val webView = view as InAppWebView
    webView.isLoading = true
    webView.disposeWebMessageChannels()
    webView.userContentController.resetContentWorlds()
    loadCustomJavaScriptOnPageStarted(webView)

    superCall()

    inAppBrowserDelegate?.didStartNavigation(url)

    webView.channelDelegate?.onLoadStart(url)
  }

  fun onPageFinished(view: WebView, url: String?, superCall: () -> Unit) {
    val webView = view as InAppWebView
    webView.isLoading = false
    loadCustomJavaScriptOnPageFinished(webView)
    httpAuthState.reset()

    superCall()

    inAppBrowserDelegate?.didFinishNavigation(url)

    // WebView not storing cookies reliable to local device storage
    CookieManager.getInstance().flush()

    webView.evaluateJavascript(
      JavaScriptBridgeJS.PLATFORM_READY_JS_SOURCE(), null as ValueCallback<String>?
    )

    webView.channelDelegate?.onLoadStop(url)
  }

  /** The callers invoke `super` first, so this needs no `superCall`. */
  fun doUpdateVisitedHistory(view: WebView, isReload: Boolean) {
    // url argument sometimes doesn't contain the new changed URL, so we get it again from the
    // webview.
    val currentUrl = view.url

    inAppBrowserDelegate?.didUpdateVisitedHistory(currentUrl)

    val webView = view as InAppWebView
    webView.channelDelegate?.onUpdateVisitedHistory(currentUrl, isReload)
  }

  /**
   * [errorCode] and [description] are lambdas: the Compat client reads each only when the matching
   * `WebViewFeature` is supported, and neither client evaluated them unless a browser delegate was
   * attached (they sat inside a `?.` call).
   */
  fun onReceivedError(
    view: WebView,
    request: WebResourceRequest,
    error: WebResourceErrorExt,
    errorCode: () -> Int,
    description: () -> String
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
        request.url.toString(), errorCode(), description()
      )
    }

    webView.channelDelegate?.onReceivedError(
      WebResourceRequestExt.fromWebResourceRequest(request), error
    )
  }

  /** The callers invoke `super` first, so this needs no `superCall`. */
  fun onReceivedHttpError(
    view: WebView,
    request: WebResourceRequest,
    errorResponse: WebResourceResponse
  ) {
    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedHttpError(
      WebResourceRequestExt.fromWebResourceRequest(request),
      WebResourceResponseExt.fromWebResourceResponse(errorResponse)
    )
  }

  /** The callers invoke `super` first, so this needs no `superCall`. */
  fun onScaleChanged(view: WebView, oldScale: Float, newScale: Float) {
    val webView = view as InAppWebView
    webView.zoomScale = newScale / Util.getPixelDensity(webView.context)

    webView.channelDelegate?.onZoomScaleChanged(oldScale, newScale)
  }

  /**
   * [respond] applies the app's answer and reports whether it could: the Compat client feature-gates
   * each of the three response actions and leaves the challenge unanswered when the WebView does not
   * support it, which is the `return true` — "not handled" — path.
   */
  fun onSafeBrowsingHit(
    view: WebView,
    request: WebResourceRequest,
    threatType: Int,
    superCall: () -> Unit,
    respond: (action: Int, report: Boolean) -> Boolean
  ) {
    val webView = view as InAppWebView
    val resultCallback = object : WebViewChannelDelegate.SafeBrowsingHitCallback() {
      override fun nonNullSuccess(result: SafeBrowsingResponse): Boolean {
        val action = result.action
        if (action != null) {
          if (!respond(action, result.isReport)) {
            return true
          }

          return false
        }

        return true
      }

      override fun defaultBehaviour(result: SafeBrowsingResponse?) {
        superCall()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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

  /** The callers invoke `super` first, so this needs no `superCall`. */
  fun onPageCommitVisible(view: WebView, url: String?) {
    val webView = view as InAppWebView
    webView.channelDelegate?.onPageCommitVisible(url)
  }

  fun onRenderProcessGone(
    view: WebView,
    detail: RenderProcessGoneDetail,
    superCall: () -> Boolean
  ): Boolean {
    val webView = view as InAppWebView

    val channelDelegate = webView.channelDelegate
    if (webView.customSettings.useOnRenderProcessGone && channelDelegate != null) {
      channelDelegate.onRenderProcessGone(detail.didCrash(), detail.rendererPriorityAtExit())
      return true
    }

    return superCall()
  }

  fun onReceivedLoginRequest(view: WebView, realm: String?, account: String?, args: String?) {
    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedLoginRequest(realm, account, args)
  }

  fun dispose() {
    inAppBrowserDelegate = null
  }

  fun allowSyncUrlLoading(webView: InAppWebView, url: String): Boolean {
    val regex = webView.customSettings.regexToAllowSyncUrlLoading
    if (regex != null && regex.matcher(url).matches()) {
      Log.d(
        logTag,
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
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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

  fun onReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String?,
    realm: String?,
    superCall: () -> Unit
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
        Log.e(logTag, "", e)
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
        superCall()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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

  fun onReceivedSslError(
    view: WebView,
    handler: SslErrorHandler,
    sslError: SslError,
    superCall: () -> Unit
  ) {
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
      Log.e(logTag, "", e)
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
        superCall()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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

  fun onReceivedClientCertRequest(
    view: WebView,
    request: ClientCertRequest,
    superCall: () -> Unit
  ) {
    val url = view.url
    val host = request.host
    var protocol = "https"
    val port = request.port

    if (url != null) {
      try {
        protocol = URI(url).scheme
      } catch (e: URISyntaxException) {
        Log.e(logTag, "", e)
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
        superCall()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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

  fun onFormResubmission(
    view: WebView,
    dontResend: Message,
    resend: Message,
    superCall: () -> Unit
  ) {
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
        superCall()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(logTag, errorCode + ", " + (errorMessage ?: ""))
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
        Log.e(logTag, "", e)
      }
    }

    if (webView.customSettings.useShouldInterceptRequest) {
      var response: WebResourceResponseExt? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        try {
          response = channelDelegate.shouldInterceptRequest(request)
        } catch (e: InterruptedException) {
          Log.e(logTag, "", e)
          return null
        }
      }

      if (response != null) {
        // Built on the type, not here: this block used to be duplicated byte-for-byte in the two
        // client classes and near-identically in the service-worker client (trap 32).
        return response.toWebResourceResponse()
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
      var customSchemeResponse: CustomSchemeResponse? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        try {
          customSchemeResponse = channelDelegate.onLoadResourceWithCustomScheme(request)
        } catch (e: InterruptedException) {
          Log.e(logTag, "", e)
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
          Log.e(logTag, "", e)
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
        Log.e(logTag, "", e)
      }
    }
    return response
  }
}
