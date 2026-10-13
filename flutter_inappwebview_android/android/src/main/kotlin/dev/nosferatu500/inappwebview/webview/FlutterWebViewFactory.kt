package dev.nosferatu500.inappwebview.webview

import android.content.Context
import android.view.ViewGroup
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class FlutterWebViewFactory(private val plugin: InAppWebViewFlutterPlugin) :
  PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, id: Int, args: Any?): PlatformView {
    val params = args as HashMap<String, Any?>
    var flutterWebView: FlutterWebView? = null
    var viewId: Any = id

    val keepAliveId = params["keepAliveId"] as String?
    val headlessWebViewId = params["headlessWebViewId"] as String?

    val headlessInAppWebViewManager = plugin.headlessInAppWebViewManager
    if (headlessWebViewId != null && headlessInAppWebViewManager != null) {
      val headlessInAppWebView = headlessInAppWebViewManager.webViews[headlessWebViewId]
      if (headlessInAppWebView != null) {
        flutterWebView = headlessInAppWebView.disposeAndGetFlutterWebView()
        flutterWebView?.keepAliveId = keepAliveId
      }
    }

    val inAppWebViewManager = plugin.inAppWebViewManager
    if (keepAliveId != null && flutterWebView == null && inAppWebViewManager != null) {
      flutterWebView = inAppWebViewManager.keepAliveWebViews[keepAliveId]
      if (flutterWebView != null) {
        // be sure to remove the view from the previous parent.
        val view = flutterWebView.getView()
        val parent = view?.parent as ViewGroup?
        parent?.removeView(view)
      }
    }

    val shouldMakeInitialLoad = flutterWebView == null
    if (flutterWebView == null) {
      if (keepAliveId != null) {
        viewId = keepAliveId
      }
      flutterWebView = FlutterWebView(plugin, context, viewId, params)
    }

    if (keepAliveId != null && inAppWebViewManager != null) {
      inAppWebViewManager.keepAliveWebViews[keepAliveId] = flutterWebView
    }

    if (shouldMakeInitialLoad) {
      flutterWebView.makeInitialLoad(params)
    }

    return flutterWebView
  }

  companion object {
    const val VIEW_TYPE_ID = "dev.nosferatu500.inappwebview/inappwebview"
  }
}
