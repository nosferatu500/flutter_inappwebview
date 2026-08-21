package dev.nosferatu500.inappwebview.webview

import android.os.Handler
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.ValueCallback
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.print_job.PrintJobSettings
import dev.nosferatu500.inappwebview.types.JavaScriptHandlerFunctionData
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class JavaScriptBridgeInterface(
  private var inAppWebView: InAppWebView?,
  private val expectedBridgeSecret: String
) {

  @JavascriptInterface
  fun _hideContextMenu() {
    val webView = inAppWebView ?: return

    Handler(webView.getWebViewLooper()).post {
      if (inAppWebView?.floatingContextMenu != null) {
        inAppWebView?.hideContextMenu()
      }
    }
  }

  @JavascriptInterface
  fun _callHandler(jsonStringifiedData: String) {
    val webView = inAppWebView ?: return

    val data: JSONObject = try {
      JSONObject(jsonStringifiedData)
    } catch (e: Exception) {
      e.printStackTrace()
      Log.e(
        LOG_TAG,
        "Cannot convert jsonStringifiedData parameter of _callHandler method to a valid JSONObject"
      )
      return
    }

    if (!data.has("handlerName") || data.isNull("handlerName")) {
      Log.d(LOG_TAG, "handlerName is null or undefined")
      return
    }

    val handlerName = data.optString("handlerName")
    val bridgeSecret = data.optString("_bridgeSecret")
    val callHandlerID = data.optInt("_callHandlerID")
    val origin = data.optString("origin")
    val requestUrl = data.optString("requestUrl")
    val isMainFrame = data.optBoolean("isMainFrame")
    val args = data.optString("args")

    if (expectedBridgeSecret != bridgeSecret) {
      Log.e(
        LOG_TAG,
        "Bridge access attempt with wrong secret token, possibly from malicious code from " +
          "origin: $origin"
      )
      return
    }

    val allowList = webView.customSettings.javaScriptHandlersOriginAllowList
    // origin is by default allowed if the allow list is null
    val isOriginAllowed = allowList?.any { it.matcher(origin).matches() } ?: true
    if (!isOriginAllowed) {
      Log.e(LOG_TAG, "Bridge access attempt from an origin not allowed: $origin")
      return
    }

    if (webView.customSettings.javaScriptHandlersForMainFrameOnly && !isMainFrame) {
      Log.e(LOG_TAG, "Bridge access attempt from a sub-frame origin: $origin")
      return
    }

    // java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main
    // thread. https://github.com/pichillilorenzo/flutter_inappwebview/issues/98
    Handler(webView.getWebViewLooper()).post {
      // The webview may already have been disposed by the time this runs.
      val view = inAppWebView ?: return@post

      var isInternalHandler = true
      when (handlerName) {
        "onPrintRequest" -> {
          val settings = PrintJobSettings()
          settings.handledByClient = true
          val printJobId = view.printCurrentPage(settings)
          view.channelDelegate?.onPrintRequest(
            view.getUrl(), printJobId,
            object : WebViewChannelDelegate.PrintRequestCallback() {
              override fun nonNullSuccess(result: Boolean): Boolean = !result

              override fun defaultBehaviour(result: Boolean?) {
                val jobs = inAppWebView?.plugin?.printJobManager?.jobs ?: return
                jobs[printJobId]?.disposeNoCancel()
              }

              override fun error(
                errorCode: String,
                errorMessage: String?,
                errorDetails: Any?
              ) {
                Log.e(LOG_TAG, errorCode + ", " + (errorMessage ?: ""))
                defaultBehaviour(null)
              }
            }
          )
        }

        "callAsyncJavaScript" -> {
          try {
            val jsonObject = JSONArray(args).getJSONObject(0)
            val resultUuid = jsonObject.getString("resultUuid")
            val callback = view.callAsyncJavaScriptCallbacks[resultUuid]
            if (callback != null) {
              callback.onReceiveValue(jsonObject.toString())
              view.callAsyncJavaScriptCallbacks.remove(resultUuid)
            }
          } catch (e: JSONException) {
            Log.e(LOG_TAG, "", e)
          }
        }

        "evaluateJavaScriptWithContentWorld" -> {
          try {
            val jsonObject = JSONArray(args).getJSONObject(0)
            val resultUuid = jsonObject.getString("resultUuid")
            val callback = view.evaluateJavaScriptContentWorldCallbacks[resultUuid]
            if (callback != null) {
              callback.onReceiveValue(
                if (jsonObject.has("value")) jsonObject["value"].toString() else "null"
              )
              view.evaluateJavaScriptContentWorldCallbacks.remove(resultUuid)
            }
          } catch (e: JSONException) {
            Log.e(LOG_TAG, "", e)
          }
        }

        else -> isInternalHandler = false
      }

      if (isInternalHandler) {
        inAppWebView?.let {
          val bridge = JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()
          val sourceCode = "if (window.$bridge[$callHandlerID] != null) { " +
            "window.$bridge[$callHandlerID].resolve(); " +
            "delete window.$bridge[$callHandlerID]; " +
            "}"
          it.evaluateJavascript(sourceCode, null as ValueCallback<String>?)
        }
        return@post
      }

      view.channelDelegate?.let { channelDelegate ->
        val functionData =
          JavaScriptHandlerFunctionData(origin, requestUrl, isMainFrame, args)
        // invoke flutter javascript handler and send back flutter data as a JSON Object to
        // javascript
        channelDelegate.onCallJsHandler(
          handlerName, functionData,
          object : WebViewChannelDelegate.CallJsHandlerCallback() {
            override fun defaultBehaviour(result: Any?) {
              // The webview has already been disposed, ignore.
              val current = inAppWebView ?: return
              val bridge = JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()
              val sourceCode = "if (window.$bridge[$callHandlerID] != null) { " +
                "window.$bridge[$callHandlerID].resolve($result); " +
                "delete window.$bridge[$callHandlerID]; " +
                "}"
              current.evaluateJavascript(sourceCode, null as ValueCallback<String>?)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
              val message = errorCode + (if (errorMessage != null) ", $errorMessage" else "")
              Log.e(LOG_TAG, message)

              // The webview has already been disposed, ignore.
              val current = inAppWebView ?: return
              val bridge = JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()
              val sourceCode = "if (window.$bridge[$callHandlerID] != null) { " +
                "window.$bridge[$callHandlerID].reject(new Error(" +
                JSONObject.quote(message) + ")); " +
                "delete window.$bridge[$callHandlerID]; " +
                "}"
              current.evaluateJavascript(sourceCode, null as ValueCallback<String>?)
            }
          }
        )
      }
    }
  }

  fun dispose() {
    inAppWebView = null
  }

  companion object {
    private const val LOG_TAG = "JSBridgeInterface"
  }
}
