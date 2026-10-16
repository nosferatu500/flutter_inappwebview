package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.hardware.display.DisplayManager
import android.hardware.display.DisplayManager.DisplayListener
import android.os.Build
import android.util.Log

/**
 * Works around an Android WebView bug by filtering some DisplayListener invocations.
 * https://github.com/flutter/plugins/blob/master/packages/webview_flutter/android/src/main/java/io/flutter/plugins/webviewflutter/DisplayListenerProxy.java
 *
 * Only does anything below Android P: see [yoinkDisplayListeners].
 */
class DisplayListenerProxy {
  private var listenersBeforeWebView: List<DisplayListener> = emptyList()

  /** Should be called prior to the webview's initialization. */
  fun onPreWebViewInitialization(displayManager: DisplayManager) {
    listenersBeforeWebView = yoinkDisplayListeners(displayManager)
  }

  /** Should be called after the webview's initialization. */
  fun onPostWebViewInitialization(displayManager: DisplayManager) {
    // We recorded the list of listeners prior to initializing webview, any new listeners we see
    // after initializing the webview are listeners added by the webview.
    val webViewListeners = yoinkDisplayListeners(displayManager) - listenersBeforeWebView.toSet()

    if (webViewListeners.isEmpty()) {
      // The Android WebView registers a single display listener per process (even if there
      // are multiple WebView instances) so this list is expected to be non-empty only the
      // first time a webview is initialized.
      // Note that in an add2app scenario if the application had instantiated a non Flutter
      // WebView prior to instantiating the Flutter WebView we are not able to get a reference
      // to the WebView's display listener and can't work around the bug.
      //
      // This means that webview resizes in add2app Flutter apps with a non Flutter WebView
      // running on a system with a webview prior to 58.0.3029.125 may crash (the Android's
      // behavior seems to be racy so it doesn't always happen).
      return
    }

    for (webViewListener in webViewListeners) {
      // Note that while DisplayManager.unregisterDisplayListener throws when given an
      // unregistered listener, this isn't an issue as the WebView code never calls
      // unregisterDisplayListener.
      displayManager.unregisterDisplayListener(webViewListener)

      // We never explicitly unregister this listener as the webview's listener is never
      // unregistered (it's released when the process is terminated).
      displayManager.registerDisplayListener(
        object : DisplayListener {
          override fun onDisplayAdded(displayId: Int) {
            for (listener in webViewListeners) {
              listener.onDisplayAdded(displayId)
            }
          }

          override fun onDisplayRemoved(displayId: Int) {
            for (listener in webViewListeners) {
              listener.onDisplayRemoved(displayId)
            }
          }

          override fun onDisplayChanged(displayId: Int) {
            if (displayManager.getDisplay(displayId) == null) {
              return
            }
            for (listener in webViewListeners) {
              listener.onDisplayChanged(displayId)
            }
          }
        },
        null
      )
    }
  }

  companion object {
    private const val LOG_TAG = "DisplayListenerProxy"

    // Reads DisplayManagerGlobal's private listener list. Reflection on these fields is only
    // attempted below P, where non-SDK interface restrictions do not exist yet -- whatever the
    // targetSdk, which is all SoonBlockedPrivateApi keys on.
    @SuppressLint("PrivateApi", "DiscouragedPrivateApi", "SoonBlockedPrivateApi")
    private fun yoinkDisplayListeners(displayManager: DisplayManager): List<DisplayListener> {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        // We cannot use reflection on Android P, but it shouldn't matter as it shipped
        // with WebView 66.0.3359.158 and the WebView version the bug this code is working around
        // was fixed in 61.0.3116.0.
        return emptyList()
      }
      return try {
        val displayManagerGlobalField = DisplayManager::class.java.getDeclaredField("mGlobal")
        displayManagerGlobalField.isAccessible = true
        val displayManagerGlobal = displayManagerGlobalField.get(displayManager)
          ?: return emptyList()
        val displayListenersField =
          displayManagerGlobal.javaClass.getDeclaredField("mDisplayListeners")
        displayListenersField.isAccessible = true
        val delegates = displayListenersField.get(displayManagerGlobal) as? List<*>
          ?: return emptyList()

        delegates.mapNotNull { delegate ->
          if (delegate == null) return@mapNotNull null
          val listenerField = delegate.javaClass.getField("mListener")
          listenerField.isAccessible = true
          listenerField.get(delegate) as? DisplayListener
        }
      } catch (e: NoSuchFieldException) {
        Log.w(LOG_TAG, "Could not extract WebView's display listeners. $e")
        emptyList()
      } catch (e: IllegalAccessException) {
        Log.w(LOG_TAG, "Could not extract WebView's display listeners. $e")
        emptyList()
      }
    }
  }
}
