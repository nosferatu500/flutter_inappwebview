package dev.nosferatu500.inappwebview.webview

import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.webkit.ValueCallback
import android.webkit.WebView
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserActivity
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserSettings
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
import dev.nosferatu500.inappwebview.types.SyncBaseCallbackResultImpl
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserScript
import dev.nosferatu500.inappwebview.types.WebMessageCompatExt
import dev.nosferatu500.inappwebview.types.WebResourceErrorExt
import dev.nosferatu500.inappwebview.types.WebResourceRequestExt
import dev.nosferatu500.inappwebview.types.WebResourceResponseExt
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebViewSettings
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class WebViewChannelDelegate(webView: InAppWebView, channel: MethodChannel) :
  ChannelDelegateImpl(channel) {

  private var webView: InAppWebView? = webView

  /**
   * Only ever passed to `WebView.postVisualStateCallback` and echoed back to us unread: the channel
   * reply correlates the request, so this exists purely to make concurrent requests distinguishable
   * in a logcat trace. Not thread-safe by design -- every channel call arrives on the main thread.
   */
  private var nextVisualStateRequestId = 1L

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val method = try {
      WebViewChannelDelegateMethods.valueOf(call.method)
    } catch (e: IllegalArgumentException) {
      result.notImplemented()
      return
    }

    val webView = this.webView
    val browserActivity = webView?.getInAppBrowserDelegate() as? InAppBrowserActivity

    when (method) {
      WebViewChannelDelegateMethods.getUrl -> result.success(webView?.url)

      WebViewChannelDelegateMethods.getTitle -> result.success(webView?.title)

      WebViewChannelDelegateMethods.getProgress -> result.success(webView?.progress)

      WebViewChannelDelegateMethods.loadUrl -> {
        if (webView != null) {
          val urlRequest = call.argument<Map<String, Any?>>("urlRequest")
          webView.loadUrl(URLRequest.fromMap(urlRequest)!!)
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.postUrl -> {
        if (webView != null) {
          webView.postUrl(call.argument("url")!!, call.argument<ByteArray>("postData")!!)
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.loadData -> {
        if (webView != null) {
          webView.loadDataWithBaseURL(
            call.argument("baseUrl"),
            call.argument("data")!!,
            call.argument("mimeType"),
            call.argument("encoding"),
            call.argument("historyUrl")
          )
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.loadFile -> {
        if (webView != null) {
          try {
            webView.loadFile(call.argument("assetFilePath")!!)
          } catch (e: IOException) {
            e.printStackTrace()
            result.error(LOG_TAG, e.message, null)
            return
          }
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.evaluateJavascript -> {
        if (webView != null) {
          val source = call.argument<String>("source")!!
          val contentWorld =
            ContentWorld.fromMap(call.argument<Map<String, Any?>>("contentWorld"))
          webView.evaluateJavascript(source, contentWorld) { value -> result.success(value) }
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.injectJavascriptFileFromUrl -> {
        webView?.injectJavascriptFileFromUrl(
          call.argument("urlFile")!!,
          call.argument<Map<String, Any?>>("scriptHtmlTagAttributes")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.injectCSSCode -> {
        webView?.injectCSSCode(call.argument("source")!!)
        result.success(true)
      }

      WebViewChannelDelegateMethods.injectCSSFileFromUrl -> {
        webView?.injectCSSFileFromUrl(
          call.argument("urlFile")!!,
          call.argument<Map<String, Any?>>("cssLinkHtmlTagAttributes")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.reload -> {
        webView?.reload()
        result.success(true)
      }

      WebViewChannelDelegateMethods.goBack -> {
        webView?.goBack()
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoBack -> result.success(webView?.canGoBack() == true)

      WebViewChannelDelegateMethods.goForward -> {
        webView?.goForward()
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoForward ->
        result.success(webView?.canGoForward() == true)

      WebViewChannelDelegateMethods.goBackOrForward -> {
        webView?.goBackOrForward(call.argument<Int>("steps")!!)
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoBackOrForward ->
        result.success(webView?.canGoBackOrForward(call.argument<Int>("steps")!!) == true)

      WebViewChannelDelegateMethods.stopLoading -> {
        webView?.stopLoading()
        result.success(true)
      }

      WebViewChannelDelegateMethods.isLoading -> result.success(webView?.isLoading() == true)

      WebViewChannelDelegateMethods.takeScreenshot -> {
        if (webView != null) {
          webView.takeScreenshot(
            call.argument<Map<String, Any?>>("screenshotConfiguration"), result
          )
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.setSettings -> {
        if (browserActivity != null) {
          val inAppBrowserSettings = InAppBrowserSettings()
          val inAppBrowserSettingsMap = call.argument<HashMap<String, Any?>>("settings")!!
          inAppBrowserSettings.parse(inAppBrowserSettingsMap)
          browserActivity.setSettings(inAppBrowserSettings, inAppBrowserSettingsMap)
        } else if (webView != null) {
          val inAppWebViewSettings = InAppWebViewSettings()
          val inAppWebViewSettingsMap = call.argument<HashMap<String, Any?>>("settings")!!
          inAppWebViewSettings.parse(inAppWebViewSettingsMap)
          webView.setSettings(inAppWebViewSettings, inAppWebViewSettingsMap)
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.getSettings -> {
        if (browserActivity != null) {
          result.success(browserActivity.getCustomSettingsMap())
        } else {
          result.success(webView?.getCustomSettingsMap())
        }
      }

      WebViewChannelDelegateMethods.close -> {
        if (browserActivity != null) {
          browserActivity.close(result)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.show -> {
        if (browserActivity != null) {
          browserActivity.show()
          result.success(true)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.hide -> {
        if (browserActivity != null) {
          browserActivity.hide()
          result.success(true)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.isHidden -> {
        if (browserActivity != null) {
          result.success(browserActivity.isHidden)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.getCopyBackForwardList ->
        result.success(webView?.getCopyBackForwardList())

      WebViewChannelDelegateMethods.clearSslPreferences -> {
        webView?.clearSslPreferences()
        result.success(true)
      }

      WebViewChannelDelegateMethods.scrollTo -> {
        webView?.scrollTo(
          call.argument("x"), call.argument("y"), call.argument("animated")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.scrollBy -> {
        webView?.scrollBy(
          call.argument("x"), call.argument("y"), call.argument("animated")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.pause -> {
        webView?.onPause()
        result.success(true)
      }

      WebViewChannelDelegateMethods.resume -> {
        webView?.onResume()
        result.success(true)
      }

      WebViewChannelDelegateMethods.pauseTimers -> {
        webView?.pauseTimers()
        result.success(true)
      }

      WebViewChannelDelegateMethods.resumeTimers -> {
        webView?.resumeTimers()
        result.success(true)
      }

      WebViewChannelDelegateMethods.printCurrentPage -> {
        if (webView != null) {
          val settings = PrintJobSettings()
          call.argument<Map<String, Any?>>("settings")?.let { settings.parse(it) }
          result.success(webView.printCurrentPage(settings))
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.getContentHeight -> result.success(webView?.contentHeight)

      WebViewChannelDelegateMethods.getContentWidth -> {
        if (webView != null) {
          webView.getContentWidth { contentWidth -> result.success(contentWidth) }
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.zoomBy -> {
        webView?.zoomBy(call.argument<Double>("zoomFactor")!!.toFloat())
        result.success(true)
      }

      WebViewChannelDelegateMethods.getOriginalUrl -> result.success(webView?.originalUrl)

      WebViewChannelDelegateMethods.getZoomScale -> result.success(webView?.getZoomScale())

      WebViewChannelDelegateMethods.getSelectedText -> {
        if (webView != null) {
          webView.getSelectedText { value -> result.success(value) }
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.getHitTestResult -> {
        if (webView != null) {
          result.success(HitTestResult.fromWebViewHitTestResult(webView.hitTestResult)?.toMap())
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.pageDown -> {
        if (webView != null) {
          result.success(webView.pageDown(call.argument<Boolean>("bottom")!!))
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.pageUp -> {
        if (webView != null) {
          result.success(webView.pageUp(call.argument<Boolean>("top")!!))
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.saveWebArchive -> {
        if (webView != null) {
          webView.saveWebArchive(
            call.argument("filePath")!!, call.argument<Boolean>("autoname")!!
          ) { value -> result.success(value) }
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.zoomIn -> {
        if (webView != null) {
          result.success(webView.zoomIn())
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.zoomOut -> {
        if (webView != null) {
          result.success(webView.zoomOut())
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.clearFocus -> {
        webView?.clearFocus()
        result.success(true)
      }

      WebViewChannelDelegateMethods.requestFocus -> {
        if (webView != null) {
          val direction = call.argument<Int>("direction")
          val previouslyFocusedRect = InAppWebViewRect.fromMap(
            call.argument<Map<String, Any?>>("previouslyFocusedRect")
          )
          val resultValue = if (direction != null && previouslyFocusedRect != null) {
            webView.requestFocus(direction, previouslyFocusedRect.toRect())
          } else if (direction != null) {
            webView.requestFocus(direction)
          } else {
            webView.requestFocus()
          }
          result.success(resultValue)
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.setContextMenu -> {
        webView?.setContextMenu(call.argument<Map<String, Any?>>("contextMenu"))
        result.success(true)
      }

      WebViewChannelDelegateMethods.requestFocusNodeHref ->
        result.success(webView?.requestFocusNodeHref())

      WebViewChannelDelegateMethods.requestImageRef ->
        result.success(webView?.requestImageRef())

      WebViewChannelDelegateMethods.getScrollX -> result.success(webView?.scrollX)

      WebViewChannelDelegateMethods.getScrollY -> result.success(webView?.scrollY)

      WebViewChannelDelegateMethods.getCertificate -> {
        if (webView != null) {
          result.success(SslCertificateExt.toMap(webView.certificate))
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.clearHistory -> {
        webView?.clearHistory()
        result.success(true)
      }

      WebViewChannelDelegateMethods.addUserScript -> {
        if (webView != null) {
          val userScript = UserScript.fromMap(call.argument<Map<String, Any?>>("userScript"))!!
          result.success(webView.getUserContentController().addUserOnlyScript(userScript))
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.removeUserScript -> {
        if (webView != null) {
          val index = call.argument<Int>("index")!!
          val userScript = UserScript.fromMap(call.argument<Map<String, Any?>>("userScript"))!!
          result.success(
            webView.getUserContentController()
              .removeUserOnlyScriptAt(index, userScript.injectionTime)
          )
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.removeUserScriptsByGroupName -> {
        webView?.getUserContentController()
          ?.removeUserOnlyScriptsByGroupName(call.argument("groupName"))
        result.success(true)
      }

      WebViewChannelDelegateMethods.removeAllUserScripts -> {
        webView?.getUserContentController()?.removeAllUserOnlyScripts()
        result.success(true)
      }

      WebViewChannelDelegateMethods.callAsyncJavaScript -> {
        if (webView != null) {
          val functionBody = call.argument<String>("functionBody")!!
          val functionArguments = call.argument<Map<String, Any?>>("arguments")!!
          val contentWorld =
            ContentWorld.fromMap(call.argument<Map<String, Any?>>("contentWorld"))
          webView.callAsyncJavaScript(functionBody, functionArguments, contentWorld) { value ->
            result.success(value)
          }
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.isSecureContext -> {
        if (webView != null) {
          webView.isSecureContext { value -> result.success(value) }
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.createWebMessageChannel -> {
        if (webView != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)
        ) {
          result.success(webView.createCompatWebMessageChannel().toMap())
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.postWebMessage -> {
        if (webView != null &&
          WebViewFeature.isFeatureSupported(WebViewFeature.POST_WEB_MESSAGE)
        ) {
          val message = WebMessageCompatExt.fromMap(
            call.argument<Map<String, Any?>>("message")
          )!!
          val targetOrigin = call.argument<String>("targetOrigin")
          val compatPorts = mutableListOf<WebMessagePortCompat>()
          message.ports?.forEach { portExt ->
            val webMessageChannel =
              webView.getWebMessageChannels()?.get(portExt.webMessageChannelId)
            if (webMessageChannel != null) {
              compatPorts.add(webMessageChannel.compatPorts[portExt.index])
            }
          }
          val data = message.data
          try {
            if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
              data != null && message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
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
            result.success(true)
          } catch (e: Exception) {
            result.error(LOG_TAG, e.message, null)
          }
        } else {
          result.success(true)
        }
      }

      WebViewChannelDelegateMethods.addWebMessageListener -> {
        if (webView != null) {
          val webMessageListener = WebMessageListener.fromMap(
            webView,
            webView.getPlugin()!!.messenger,
            call.argument<Map<String, Any?>>("webMessageListener")
          )!!
          if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
            try {
              webView.addWebMessageListener(webMessageListener)
              result.success(true)
            } catch (e: Exception) {
              result.error(LOG_TAG, e.message, null)
            }
          } else {
            result.success(true)
          }
        } else {
          result.success(true)
        }
      }

      WebViewChannelDelegateMethods.canScrollVertically -> {
        if (webView != null) {
          result.success(webView.canScrollVertically())
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.canScrollHorizontally -> {
        if (webView != null) {
          result.success(webView.canScrollHorizontally())
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.isInFullscreen -> {
        if (webView != null) {
          result.success(webView.isInFullscreen())
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.clearFormData -> {
        webView?.clearFormData()
        result.success(true)
      }

      WebViewChannelDelegateMethods.hideInputMethod -> {
        if (webView != null) {
          webView.hideInputMethod()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.showInputMethod -> {
        if (webView != null) {
          webView.showInputMethod()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.setAudioMuted -> {
        if (webView != null) {
          webView.setAudioMuted(call.argument<Boolean>("muted")!!)
          result.success(true)
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.isAudioMuted -> result.success(webView?.isAudioMuted() ?: false)

      WebViewChannelDelegateMethods.prerenderUrl ->
        result.success(webView?.prerenderUrl(call.argument<String>("url")!!) == true)

      // The reply is deliberately deferred until the frame is on screen -- that IS the feature.
      // `VisualStateCallback` is an abstract *class*, not an interface, so Kotlin cannot SAM-convert
      // a lambda here and the object expression is required.
      //
      // Every path replies exactly once: the platform invokes onComplete at most once per request,
      // and the null-webView branch answers immediately. The one case with no reply is a WebView
      // destroyed before the frame lands, which the platform documents as "callback not invoked" and
      // which the Dart doc tells callers to guard with Future.timeout.
      WebViewChannelDelegateMethods.postVisualStateCallback -> {
        if (webView != null) {
          webView.postVisualStateCallback(
            nextVisualStateRequestId++,
            object : WebView.VisualStateCallback() {
              override fun onComplete(requestId: Long) {
                result.success(null)
              }
            }
          )
        } else {
          result.success(null)
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
      WebViewChannelDelegateMethods.documentHasImages -> {
        if (webView != null) {
          val handler = Handler(Looper.getMainLooper()) { msg ->
            result.success(msg.arg1 == 1)
            true
          }
          webView.documentHasImages(Message.obtain(handler))
        } else {
          result.success(false)
        }
      }

      // Fire-and-forget, unlike its two neighbours above: the platform starts a fling and returns
      // immediately, so there is nothing to await. Where the scroll ends is decided by the
      // platform's deceleration, which is why this reports no position back.
      WebViewChannelDelegateMethods.flingScroll -> {
        webView?.flingScroll(call.argument("velocityX")!!, call.argument("velocityY")!!)
        result.success(true)
      }

      WebViewChannelDelegateMethods.saveState -> result.success(webView?.saveState())

      WebViewChannelDelegateMethods.restoreState -> {
        if (webView != null) {
          result.success(webView.restoreState(call.argument<ByteArray>("state")!!))
        } else {
          result.success(false)
        }
      }
    }
  }

  fun onLongPressHitTestResult(hitTestResult: HitTestResult?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onLongPressHitTestResult", hitTestResult?.toMap())
  }

  fun onScrollChanged(x: Int, y: Int) {
    val channel = this.channel ?: return
    channel.invokeMethod("onScrollChanged", hashMapOf<String, Any?>("x" to x, "y" to y))
  }

  fun onDownloadStarting(downloadStartRequest: DownloadStartRequest) {
    val channel = this.channel ?: return
    channel.invokeMethod("onDownloadStarting", downloadStartRequest.toMap())
  }

  fun onCreateContextMenu(hitTestResult: HitTestResult?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onCreateContextMenu", hitTestResult?.toMap())
  }

  fun onOverScrolled(scrollX: Int, scrollY: Int, clampedX: Boolean, clampedY: Boolean) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onOverScrolled",
      hashMapOf<String, Any?>(
        "x" to scrollX, "y" to scrollY, "clampedX" to clampedX, "clampedY" to clampedY
      )
    )
  }

  fun onContextMenuActionItemClicked(itemId: Int, itemTitle: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onContextMenuActionItemClicked",
      hashMapOf<String, Any?>("id" to itemId, "title" to itemTitle)
    )
  }

  fun onHideContextMenu() {
    val channel = this.channel ?: return
    channel.invokeMethod("onHideContextMenu", hashMapOf<String, Any?>())
  }

  fun onEnterFullscreen() {
    val channel = this.channel ?: return
    channel.invokeMethod("onEnterFullscreen", hashMapOf<String, Any?>())
  }

  fun onExitFullscreen() {
    val channel = this.channel ?: return
    channel.invokeMethod("onExitFullscreen", hashMapOf<String, Any?>())
  }

  open class JsAlertCallback : BaseCallbackResultImpl<JsAlertResponse>() {
    override fun decodeResult(obj: Any?): JsAlertResponse? =
      JsAlertResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsAlert(url: String?, message: String?, isMainFrame: Boolean?, callback: JsAlertCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onJsAlert",
      hashMapOf<String, Any?>(
        "url" to url, "message" to message, "isMainFrame" to isMainFrame
      ),
      callback
    )
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onJsConfirm",
      hashMapOf<String, Any?>(
        "url" to url, "message" to message, "isMainFrame" to isMainFrame
      ),
      callback
    )
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onJsPrompt",
      hashMapOf<String, Any?>(
        "url" to url,
        "message" to message,
        "defaultValue" to defaultValue,
        "isMainFrame" to isMainFrame
      ),
      callback
    )
  }

  open class JsBeforeUnloadCallback : BaseCallbackResultImpl<JsBeforeUnloadResponse>() {
    override fun decodeResult(obj: Any?): JsBeforeUnloadResponse? =
      JsBeforeUnloadResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onJsBeforeUnload(url: String?, message: String?, callback: JsBeforeUnloadCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onJsBeforeUnload",
      hashMapOf<String, Any?>("url" to url, "message" to message),
      callback
    )
  }

  open class CreateWindowCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean = obj is Boolean && obj
  }

  fun onCreateWindow(createWindowAction: CreateWindowAction, callback: CreateWindowCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onCreateWindow", createWindowAction.toMap(), callback)
  }

  fun onCloseWindow() {
    val channel = this.channel ?: return
    channel.invokeMethod("onCloseWindow", hashMapOf<String, Any?>())
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onGeolocationPermissionsShowPrompt",
      hashMapOf<String, Any?>("origin" to origin),
      callback
    )
  }

  fun onGeolocationPermissionsHidePrompt() {
    val channel = this.channel ?: return
    channel.invokeMethod("onGeolocationPermissionsHidePrompt", hashMapOf<String, Any?>())
  }

  fun onConsoleMessage(message: String?, messageLevel: Int) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onConsoleMessage",
      hashMapOf<String, Any?>("message" to message, "messageLevel" to messageLevel)
    )
  }

  fun onProgressChanged(progress: Int) {
    val channel = this.channel ?: return
    channel.invokeMethod("onProgressChanged", hashMapOf<String, Any?>("progress" to progress))
  }

  fun onTitleChanged(title: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onTitleChanged", hashMapOf<String, Any?>("title" to title))
  }

  fun onReceivedTouchIconUrl(url: String?, precomposed: Boolean) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onReceivedTouchIconUrl",
      hashMapOf<String, Any?>("url" to url, "precomposed" to precomposed)
    )
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onPermissionRequest",
      hashMapOf<String, Any?>(
        "origin" to origin, "resources" to resources, "frame" to frame
      ),
      callback
    )
  }

  fun onPermissionRequestCanceled(origin: String?, resources: List<String>?) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onPermissionRequestCanceled",
      hashMapOf<String, Any?>("origin" to origin, "resources" to resources)
    )
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("shouldOverrideUrlLoading", navigationAction.toMap(), callback)
  }

  fun onLoadStart(url: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onLoadStart", hashMapOf<String, Any?>("url" to url))
  }

  fun onLoadStop(url: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onLoadStop", hashMapOf<String, Any?>("url" to url))
  }

  fun onUpdateVisitedHistory(url: String?, isReload: Boolean) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onUpdateVisitedHistory",
      hashMapOf<String, Any?>("url" to url, "isReload" to isReload)
    )
  }

  fun onReceivedError(request: WebResourceRequestExt, error: WebResourceErrorExt) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onReceivedError",
      hashMapOf<String, Any?>("request" to request.toMap(), "error" to error.toMap())
    )
  }

  fun onReceivedHttpError(
    request: WebResourceRequestExt,
    errorResponse: WebResourceResponseExt
  ) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onReceivedHttpError",
      hashMapOf<String, Any?>(
        "request" to request.toMap(), "errorResponse" to errorResponse.toMap()
      )
    )
  }

  open class ReceivedHttpAuthRequestCallback : BaseCallbackResultImpl<HttpAuthResponse>() {
    override fun decodeResult(obj: Any?): HttpAuthResponse? =
      HttpAuthResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onReceivedHttpAuthRequest(
    challenge: HttpAuthenticationChallenge,
    callback: ReceivedHttpAuthRequestCallback
  ) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedHttpAuthRequest", challenge.toMap(), callback)
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedServerTrustAuthRequest", challenge.toMap(), callback)
  }

  open class ReceivedClientCertRequestCallback : BaseCallbackResultImpl<ClientCertResponse>() {
    override fun decodeResult(obj: Any?): ClientCertResponse? =
      ClientCertResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onReceivedClientCertRequest(
    challenge: ClientCertChallenge,
    callback: ReceivedClientCertRequestCallback
  ) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedClientCertRequest", challenge.toMap(), callback)
  }

  fun onZoomScaleChanged(oldScale: Float, newScale: Float) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onZoomScaleChanged",
      hashMapOf<String, Any?>("oldScale" to oldScale, "newScale" to newScale)
    )
  }

  open class SafeBrowsingHitCallback : BaseCallbackResultImpl<SafeBrowsingResponse>() {
    override fun decodeResult(obj: Any?): SafeBrowsingResponse? =
      SafeBrowsingResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onSafeBrowsingHit(url: String?, threatType: Int, callback: SafeBrowsingHitCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onSafeBrowsingHit",
      hashMapOf<String, Any?>("url" to url, "threatType" to threatType),
      callback
    )
  }

  open class FormResubmissionCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = if (obj is Int) obj else null
  }

  fun onFormResubmission(url: String?, callback: FormResubmissionCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onFormResubmission", hashMapOf<String, Any?>("url" to url), callback)
  }

  fun onPageCommitVisible(url: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod("onPageCommitVisible", hashMapOf<String, Any?>("url" to url))
  }

  fun onRenderProcessGone(didCrash: Boolean, rendererPriorityAtExit: Int) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onRenderProcessGone",
      hashMapOf<String, Any?>(
        "didCrash" to didCrash, "rendererPriorityAtExit" to rendererPriorityAtExit
      )
    )
  }

  fun onReceivedLoginRequest(realm: String?, account: String?, args: String?) {
    val channel = this.channel ?: return
    channel.invokeMethod(
      "onReceivedLoginRequest",
      hashMapOf<String, Any?>("realm" to realm, "account" to account, "args" to args)
    )
  }

  open class LoadResourceWithCustomSchemeCallback :
    BaseCallbackResultImpl<CustomSchemeResponse>() {
    override fun decodeResult(obj: Any?): CustomSchemeResponse? =
      CustomSchemeResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onLoadResourceWithCustomScheme(
    request: WebResourceRequestExt,
    callback: LoadResourceWithCustomSchemeCallback
  ) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onLoadResourceWithCustomScheme",
      hashMapOf<String, Any?>("request" to request.toMap()),
      callback
    )
  }

  open class SyncLoadResourceWithCustomSchemeCallback :
    SyncBaseCallbackResultImpl<CustomSchemeResponse>() {
    override fun decodeResult(obj: Any?): CustomSchemeResponse? =
      LoadResourceWithCustomSchemeCallback().decodeResult(obj)
  }

  @Throws(InterruptedException::class)
  fun onLoadResourceWithCustomScheme(request: WebResourceRequestExt): CustomSchemeResponse? {
    val channel = this.channel ?: return null
    val callback = SyncLoadResourceWithCustomSchemeCallback()
    return Util.invokeMethodAndWaitResult(
      channel,
      "onLoadResourceWithCustomScheme",
      hashMapOf<String, Any?>("request" to request.toMap()),
      callback,
      syncCallbackTimeoutMillis()
    )
  }

  open class ShouldInterceptRequestCallback : BaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      WebResourceResponseExt.fromMap(obj as Map<String, Any?>?)
  }

  fun shouldInterceptRequest(
    request: WebResourceRequestExt,
    callback: ShouldInterceptRequestCallback
  ) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("shouldInterceptRequest", request.toMap(), callback)
  }

  open class SyncShouldInterceptRequestCallback :
    SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      ShouldInterceptRequestCallback().decodeResult(obj)
  }

  @Throws(InterruptedException::class)
  fun shouldInterceptRequest(request: WebResourceRequestExt): WebResourceResponseExt? {
    val channel = this.channel ?: return null
    val callback = SyncShouldInterceptRequestCallback()
    return Util.invokeMethodAndWaitResult(
      channel, "shouldInterceptRequest", request.toMap(), callback, syncCallbackTimeoutMillis()
    )
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
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onRenderProcessUnresponsive", hashMapOf<String, Any?>("url" to url), callback
    )
  }

  open class RenderProcessResponsiveCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = if (obj is Int) obj else null
  }

  fun onRenderProcessResponsive(url: String?, callback: RenderProcessResponsiveCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onRenderProcessResponsive", hashMapOf<String, Any?>("url" to url), callback
    )
  }

  open class CallJsHandlerCallback : BaseCallbackResultImpl<Any>() {
    override fun decodeResult(obj: Any?): Any? = obj
  }

  fun onCallJsHandler(
    handlerName: String?,
    data: JavaScriptHandlerFunctionData,
    callback: CallJsHandlerCallback
  ) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod(
      "onCallJsHandler",
      hashMapOf<String, Any?>("handlerName" to handlerName, "data" to data.toMap()),
      callback
    )
  }

  open class PrintRequestCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean = obj is Boolean && obj
  }

  fun onPrintRequest(url: String?, callback: PrintRequestCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onPrintRequest", hashMapOf<String, Any?>("url" to url), callback)
  }

  fun onRequestFocus() {
    val channel = this.channel ?: return
    channel.invokeMethod("onRequestFocus", hashMapOf<String, Any?>())
  }

  open class ShowFileChooserCallback : BaseCallbackResultImpl<ShowFileChooserResponse>() {
    override fun decodeResult(obj: Any?): ShowFileChooserResponse? =
      ShowFileChooserResponse.fromMap(obj as Map<String, Any?>?)
  }

  fun onShowFileChooser(request: ShowFileChooserRequest, callback: ShowFileChooserCallback) {
    val channel = this.channel
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onShowFileChooser", request.toMap(), callback)
  }

  override fun dispose() {
    super.dispose()
    webView = null
  }

  companion object {
    const val LOG_TAG = "WebViewChannelDelegate"
  }
}
