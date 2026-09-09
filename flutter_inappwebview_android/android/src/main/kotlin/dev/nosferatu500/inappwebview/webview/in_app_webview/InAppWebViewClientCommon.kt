package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.net.Uri
import android.net.http.SslError
import android.os.Message
import android.util.Log
import android.webkit.ClientCertRequest
import android.webkit.HttpAuthHandler
import android.webkit.SslErrorHandler
import android.webkit.WebResourceResponse
import android.webkit.WebView
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.credential_database.CredentialDatabase
import dev.nosferatu500.inappwebview.types.ClientCertChallenge
import dev.nosferatu500.inappwebview.types.ClientCertResponse
import dev.nosferatu500.inappwebview.types.CustomSchemeResponse
import dev.nosferatu500.inappwebview.types.HttpAuthResponse
import dev.nosferatu500.inappwebview.types.HttpAuthenticationChallenge
import dev.nosferatu500.inappwebview.types.NavigationAction
import dev.nosferatu500.inappwebview.types.NavigationActionPolicy
import dev.nosferatu500.inappwebview.types.ServerTrustAuthResponse
import dev.nosferatu500.inappwebview.types.ServerTrustChallenge
import dev.nosferatu500.inappwebview.types.URLProtectionSpace
import dev.nosferatu500.inappwebview.types.URLRequest
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
 * **What is not here, and why.** Four callbacks genuinely differ and stay per-class:
 * - `shouldOverrideUrlLoading` — Compat reads `WebResourceRequestCompat.isRedirect(request)`
 * - `onReceivedError` — Compat feature-guards the error code and description
 * - `onSafeBrowsingHit` — different callback type, and Compat feature-guards each response action
 * - `onPageCommitVisible` — the two signatures disagree on nullability (`String?` vs `String`)
 *
 * **The `superCall` lambdas.** The shared bodies reach `super.X()` at four sites, always from a
 * callback's `defaultBehaviour`. That looks like it forces a multi-method delegate interface; it
 * does not, because no shared method needs more than one, so each takes a single `() -> Unit` that
 * the owning client fills with its own `super`.
 *
 * The [logTag] is per client so the two keep their distinct tags (`IAWebViewClient` /
 * `IAWebViewClientCompat`) — collapsing them would have been an observable change in a commit whose
 * job is to move code.
 */
internal class InAppWebViewClientCommon(private val logTag: String) {

  /**
   * The HTTP-auth conversation state for **this** WebView.
   *
   * It was two `private var`s in the `companion object` of each client — process-global, shared by
   * every WebView in the app. See [HttpAuthState] for what that cost. It lives here because
   * [onReceivedHttpAuthRequest] is shared, but the clients still reset it from their own
   * `onPageFinished` and `onReceivedError`.
   */
  val httpAuthState = HttpAuthState()

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
