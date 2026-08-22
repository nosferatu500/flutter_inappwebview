package dev.nosferatu500.inappwebview.webview

import android.content.Context
import android.net.Uri
import android.net.http.SslCertificate
import android.os.Looper
import android.webkit.ValueCallback
import android.webkit.WebView
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.print_job.PrintJobSettings
import dev.nosferatu500.inappwebview.types.ContentWorld
import dev.nosferatu500.inappwebview.types.HitTestResult
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserContentController
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebViewSettings
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageChannel
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageListener
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

// Declared with getX()/setX() functions rather than Kotlin properties on purpose: the sole
// implementation is a WebView subclass, and many of these (getUrl, getTitle, getProgress,
// getContext, getContentHeight, getScrollX/Y, getCertificate, getHitTestResult) are satisfied by
// methods inherited from android.webkit.WebView. Modelling them as properties would force
// redundant overrides.
interface InAppWebViewInterface {
  fun getContext(): Context
  fun getUrl(): String?
  fun getTitle(): String?
  fun getProgress(): Int
  fun loadUrl(urlRequest: URLRequest)
  fun postUrl(url: String, postData: ByteArray)
  fun loadDataWithBaseURL(
    baseUrl: String?,
    data: String,
    mimeType: String?,
    encoding: String?,
    historyUrl: String?
  )

  @Throws(IOException::class)
  fun loadFile(assetFilePath: String)

  fun evaluateJavascript(
    source: String,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>?
  )

  fun injectJavascriptFileFromUrl(urlFile: String, scriptHtmlTagAttributes: Map<String, Any?>?)
  fun injectCSSCode(source: String)
  fun injectCSSFileFromUrl(urlFile: String, cssLinkHtmlTagAttributes: Map<String, Any?>?)
  fun reload()
  fun goBack()
  fun canGoBack(): Boolean
  fun goForward()
  fun canGoForward(): Boolean
  fun goBackOrForward(steps: Int)
  fun canGoBackOrForward(steps: Int): Boolean
  fun stopLoading()
  fun isLoading(): Boolean
  fun takeScreenshot(screenshotConfiguration: Map<String, Any?>?, result: MethodChannel.Result)
  fun setSettings(newSettings: InAppWebViewSettings, newSettingsMap: HashMap<String, Any?>)
  fun getCustomSettings(): InAppWebViewSettings
  fun getCustomSettingsMap(): Map<String, Any?>?
  fun getCopyBackForwardList(): HashMap<String, Any?>?
  fun clearSslPreferences()
  fun findAllAsync(find: String)
  fun findNext(forward: Boolean)
  fun clearMatches()
  fun scrollTo(x: Int?, y: Int?, animated: Boolean?)
  fun scrollBy(x: Int?, y: Int?, animated: Boolean?)
  fun onPause()
  fun onResume()
  fun pauseTimers()
  fun resumeTimers()
  fun printCurrentPage(settings: PrintJobSettings?): String?
  fun getContentHeight(): Int
  fun getContentHeight(callback: ValueCallback<Int>)
  fun getContentWidth(callback: ValueCallback<Int>)
  fun zoomBy(zoomFactor: Float)
  fun getOriginalUrl(): String?
  fun getSelectedText(callback: ValueCallback<String>)
  fun getHitTestResult(): WebView.HitTestResult?
  fun getHitTestResult(callback: ValueCallback<HitTestResult>)
  fun pageDown(bottom: Boolean): Boolean
  fun pageUp(top: Boolean): Boolean
  fun saveWebArchive(basename: String, autoname: Boolean, callback: ValueCallback<String>?)
  fun zoomIn(): Boolean
  fun zoomOut(): Boolean
  fun clearFocus()
  fun requestFocusNodeHref(): Map<String, Any?>?
  fun requestImageRef(): Map<String, Any?>?
  fun getScrollX(): Int
  fun getScrollY(): Int
  fun getCertificate(): SslCertificate?
  fun clearHistory()
  fun callAsyncJavaScript(
    functionBody: String,
    arguments: Map<String, Any?>,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>?
  )

  fun isSecureContext(resultCallback: ValueCallback<Boolean>)
  fun createCompatWebMessageChannel(): WebMessageChannel?
  fun createWebMessageChannel(callback: ValueCallback<WebMessageChannel>): WebMessageChannel?
  fun postWebMessage(message: android.webkit.WebMessage, targetOrigin: Uri)

  @Throws(Exception::class)
  fun postWebMessage(
    message: dev.nosferatu500.inappwebview.types.WebMessage,
    targetOrigin: Uri,
    callback: ValueCallback<String>?
  )

  @Throws(Exception::class)
  fun addWebMessageListener(webMessageListener: WebMessageListener)

  fun canScrollVertically(): Boolean
  fun canScrollHorizontally(): Boolean
  fun getZoomScale(): Float
  fun getZoomScale(callback: ValueCallback<Float>)
  fun getContextMenu(): Map<String, Any?>?
  fun setContextMenu(contextMenu: Map<String, Any?>?)
  fun getPlugin(): InAppWebViewFlutterPlugin?
  fun setPlugin(plugin: InAppWebViewFlutterPlugin?)
  fun getInAppBrowserDelegate(): InAppBrowserDelegate?
  fun setInAppBrowserDelegate(inAppBrowserDelegate: InAppBrowserDelegate?)
  fun getUserContentController(): UserContentController
  fun setUserContentController(userContentController: UserContentController)
  fun getWebMessageChannels(): MutableMap<String, WebMessageChannel>?
  fun setWebMessageChannels(webMessageChannels: MutableMap<String, WebMessageChannel>?)
  fun disposeWebMessageChannels()
  fun disposeWebMessageListeners()
  fun getWebViewLooper(): Looper
  fun isInFullscreen(): Boolean
  fun setInFullscreen(inFullscreen: Boolean)
  fun getChannelDelegate(): WebViewChannelDelegate?
  fun setChannelDelegate(eventWebViewChannelDelegate: WebViewChannelDelegate?)
  fun showInputMethod()
  fun hideInputMethod()
  fun setAudioMuted(muted: Boolean)
  fun isAudioMuted(): Boolean
  fun prerenderUrl(url: String): Boolean
  fun saveState(): ByteArray?
  fun restoreState(state: ByteArray): Boolean
}
