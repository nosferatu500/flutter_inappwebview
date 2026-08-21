package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.util.Log
import android.webkit.WebView
import androidx.webkit.WebViewFeature
import androidx.webkit.WebViewRenderProcess
import androidx.webkit.WebViewRenderProcessClient
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate

class InAppWebViewRenderProcessClient : WebViewRenderProcessClient() {

  override fun onRenderProcessUnresponsive(view: WebView, renderer: WebViewRenderProcess?) {
    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.RenderProcessUnresponsiveCallback() {
      override fun nonNullSuccess(result: Int): Boolean {
        if (renderer != null) {
          if (result == 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE)
          ) {
            renderer.terminate()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(result: Int?) {
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onRenderProcessUnresponsive(webView.url, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  override fun onRenderProcessResponsive(view: WebView, renderer: WebViewRenderProcess?) {
    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.RenderProcessResponsiveCallback() {
      override fun nonNullSuccess(result: Int): Boolean {
        if (renderer != null) {
          if (result == 0 &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_TERMINATE)
          ) {
            renderer.terminate()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(result: Int?) {
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onRenderProcessResponsive(webView.url, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  fun dispose() {
  }

  companion object {
    protected const val LOG_TAG = "IAWRenderProcessClient"
  }
}
