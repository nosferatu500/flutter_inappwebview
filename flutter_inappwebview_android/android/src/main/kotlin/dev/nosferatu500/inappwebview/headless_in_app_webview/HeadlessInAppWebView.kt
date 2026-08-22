package dev.nosferatu500.inappwebview.headless_in_app_webview

import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.Size2D
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodChannel

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
//
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
@Suppress("UNCHECKED_CAST")
class HeadlessInAppWebView(
  plugin: InAppWebViewFlutterPlugin,
  @JvmField val id: String,
  flutterWebView: FlutterWebView
) : Disposable {

  @JvmField
  var channelDelegate: HeadlessWebViewChannelDelegate?

  @JvmField
  var flutterWebView: FlutterWebView? = flutterWebView

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  init {
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = HeadlessWebViewChannelDelegate(this, channel)
  }

  fun onWebViewCreated() {
    channelDelegate?.onWebViewCreated()
  }

  fun prepare(params: Map<String, Any?>) {
    flutterWebView?.getView()?.let { view ->
      val size = Size2D.fromMap(params["initialSize"] as Map<String, Any?>?)
        ?: Size2D(-1.0, -1.0)
      setSize(size)
      view.visibility = View.INVISIBLE
    }
    val activity = plugin?.activity
    if (activity != null) {
      // Add the headless WebView to the view hierarchy.
      // This way is also possible to take screenshots.
      val contentView = activity.findViewById<ViewGroup>(android.R.id.content)
      val mainView = contentView?.getChildAt(0) as ViewGroup?
      val view = flutterWebView?.getView()
      if (mainView != null && view != null) {
        mainView.addView(view, 0)
      }
    }
  }

  fun setSize(size: Size2D) {
    if (flutterWebView?.webView == null) return
    val view = flutterWebView?.getView() ?: return
    val scale = Util.getPixelDensity(view.context)
    val fullscreenSize = Util.getFullscreenSize(view.context)
    // -1.0 means "fullscreen on this axis". Upstream's height branch tested size.width, so
    // Size2D(-1.0, h) forced fullscreen height and Size2D(w, -1.0) never got it (TODO.md P0b.1).
    val width = (if (size.width == -1.0) fullscreenSize.width else size.width * scale).toInt()
    val height = (if (size.height == -1.0) fullscreenSize.height else size.height * scale).toInt()
    view.layoutParams = FrameLayout.LayoutParams(width, height)
  }

  fun getSize(): Size2D? {
    if (flutterWebView?.webView == null) return null
    val view = flutterWebView?.getView() ?: return null
    val scale = Util.getPixelDensity(view.context)
    val fullscreenSize = Util.getFullscreenSize(view.context)
    val layoutParams = view.layoutParams
    return Size2D(
      if (fullscreenSize.width == layoutParams.width.toDouble()) {
        layoutParams.width.toDouble()
      } else {
        layoutParams.width / scale.toDouble()
      },
      if (fullscreenSize.height == layoutParams.height.toDouble()) {
        layoutParams.height.toDouble()
      } else {
        layoutParams.height / scale.toDouble()
      }
    )
  }

  fun disposeAndGetFlutterWebView(): FlutterWebView? {
    val newFlutterWebView = flutterWebView
    if (newFlutterWebView != null) {
      val view = newFlutterWebView.getView()
      if (view != null) {
        // restore WebView layout params and visibility
        view.layoutParams = FrameLayout.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
        )
        view.visibility = View.VISIBLE
        // remove from parent
        (view.parent as ViewGroup?)?.removeView(view)
      }
      // set to null to avoid to be disposed before calling "dispose()"
      flutterWebView = null
      dispose()
    }
    return newFlutterWebView
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    val currentPlugin = plugin
    if (currentPlugin != null) {
      val headlessInAppWebViewManager = currentPlugin.headlessInAppWebViewManager
      if (headlessInAppWebViewManager != null &&
        headlessInAppWebViewManager.webViews.containsKey(id)
      ) {
        headlessInAppWebViewManager.webViews[id] = null
      }
      val activity = currentPlugin.activity
      if (activity != null) {
        val contentView = activity.findViewById<ViewGroup>(android.R.id.content)
        val mainView = contentView?.getChildAt(0) as ViewGroup?
        val view = flutterWebView?.getView()
        if (mainView != null && view != null) {
          mainView.removeView(view)
        }
      }
    }
    flutterWebView?.dispose()
    flutterWebView = null
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "HeadlessInAppWebView"
    const val METHOD_CHANNEL_NAME_PREFIX =
      "dev.nosferatu500.inappwebview/headless_inappwebview_"
  }
}
