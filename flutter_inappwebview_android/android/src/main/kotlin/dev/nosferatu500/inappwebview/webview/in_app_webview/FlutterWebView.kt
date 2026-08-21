package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.find_interaction.FindInteractionController
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshLayout
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshSettings
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserScript
import dev.nosferatu500.inappwebview.webview.PlatformWebView
import java.io.IOException

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class FlutterWebView(
  plugin: InAppWebViewFlutterPlugin,
  context: Context,
  id: Any,
  params: HashMap<String, Any?>
) : PlatformWebView {

  @JvmField
  var webView: InAppWebView?

  @JvmField
  var pullToRefreshLayout: PullToRefreshLayout?

  @JvmField
  var keepAliveId: String? = params["keepAliveId"] as String?

  init {
    val initialSettings = params["initialSettings"] as Map<String, Any?>
    val contextMenu = params["contextMenu"] as Map<String, Any?>?
    val windowId = params["windowId"] as Int?
    val initialUserScripts = params["initialUserScripts"] as List<Map<String, Any?>>?
    val pullToRefreshInitialSettings = params["pullToRefreshSettings"] as Map<String, Any?>

    val customSettings = InAppWebViewSettings()
    customSettings.parse(initialSettings)

    val userScripts = mutableListOf<UserScript>()
    if (initialUserScripts != null) {
      for (initialUserScript in initialUserScripts) {
        UserScript.fromMap(initialUserScript)?.let { userScripts.add(it) }
      }
    }

    val view = InAppWebView(
      context, plugin, id, windowId, customSettings, contextMenu,
      if (customSettings.useHybridComposition) null else plugin.flutterView, userScripts
    )
    webView = view

    // set MATCH_PARENT layout params to the WebView, otherwise it won't take all the available
    // space!
    view.layoutParams = FrameLayout.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
    )
    val pullToRefreshSettings = PullToRefreshSettings()
    pullToRefreshSettings.parse(pullToRefreshInitialSettings)
    val layout = PullToRefreshLayout(context, plugin, id, pullToRefreshSettings)
    pullToRefreshLayout = layout
    layout.addView(view)
    layout.prepare()

    val findInteractionController = FindInteractionController(view, plugin, id, null)
    view.findInteractionController = findInteractionController
    findInteractionController.prepare()

    view.prepare()
  }

  override fun getView(): View? = pullToRefreshLayout ?: webView

  @SuppressLint("RestrictedApi")
  override fun makeInitialLoad(params: HashMap<String, Any?>) {
    val view = webView ?: return

    val windowId = params["windowId"] as Int?
    val initialUrlRequest = params["initialUrlRequest"] as Map<String, Any?>?
    val initialFile = params["initialFile"] as String?
    val initialData = params["initialData"] as Map<String, String>?

    if (windowId != null) {
      val resultMsg =
        view.plugin?.inAppWebViewManager?.windowWebViewMessages?.get(windowId)
      if (resultMsg != null) {
        (resultMsg.obj as WebView.WebViewTransport).webView = view
        resultMsg.sendToTarget()
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
          // for some reason, if a WebView is created using a window id,
          // the initial plugin and user scripts injected
          // with WebViewCompat.addDocumentStartJavaScript will not be added!
          // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1455
          //
          // Also, calling the prepareAndAddUserScripts method right after won't work,
          // so use the View.post method here.
          view.post { webView?.prepareAndAddUserScripts() }
        }
      }
    } else {
      if (initialFile != null) {
        try {
          view.loadFile(initialFile)
        } catch (e: IOException) {
          Log.e(LOG_TAG, "$initialFile asset file cannot be found!", e)
        }
      } else if (initialData != null) {
        view.loadDataWithBaseURL(
          initialData["baseUrl"],
          initialData["data"]!!,
          initialData["mimeType"],
          initialData["encoding"],
          initialData["historyUrl"]
        )
      } else if (initialUrlRequest != null) {
        URLRequest.fromMap(initialUrlRequest)?.let { view.loadUrl(it) }
      }
    }
  }

  override fun dispose() {
    if (keepAliveId == null && webView != null) {
      webView?.dispose()
      webView = null

      pullToRefreshLayout?.dispose()
      pullToRefreshLayout = null
    }
  }

  override fun onInputConnectionLocked() {
    val view = webView ?: return
    if (view.inAppBrowserDelegate == null && !view.customSettings.useHybridComposition) {
      view.lockInputConnection()
    }
  }

  override fun onInputConnectionUnlocked() {
    val view = webView ?: return
    if (view.inAppBrowserDelegate == null && !view.customSettings.useHybridComposition) {
      view.unlockInputConnection()
    }
  }

  override fun onFlutterViewAttached(flutterView: View) {
    val view = webView ?: return
    if (!view.customSettings.useHybridComposition) {
      view.setContainerView(flutterView)
    }
  }

  override fun onFlutterViewDetached() {
    val view = webView ?: return
    if (!view.customSettings.useHybridComposition) {
      view.setContainerView(null)
    }
  }

  companion object {
    const val LOG_TAG = "IAWFlutterWebView"
  }
}
