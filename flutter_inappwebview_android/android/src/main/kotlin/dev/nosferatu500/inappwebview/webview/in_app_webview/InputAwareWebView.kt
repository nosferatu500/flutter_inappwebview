package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.webkit.WebView

/**
 * A WebView subclass that mirrors the same implementation hacks that the system WebView does in
 * order to correctly create an InputConnection.
 *
 * These hacks are only needed in Android versions below N and exist to create an InputConnection
 * on the WebView's dedicated input, or IME, thread. The majority of this proxying logic is in
 * https://github.com/flutter/plugins/blob/main/packages/webview_flutter/webview_flutter_android/android/src/main/java/io/flutter/plugins/webviewflutter/InputAwareWebView.java
 */
open class InputAwareWebView : WebView {

  @JvmField
  var containerView: View? = null

  private var threadedInputConnectionProxyView: View? = null
  private var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null
  private var useHybridComposition = false

  constructor(
    context: Context,
    containerView: View?,
    useHybridComposition: Boolean?
  ) : super(context) {
    this.containerView = containerView
    this.useHybridComposition = useHybridComposition ?: false
  }

  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
    containerView = null
  }

  constructor(context: Context) : super(context) {
    containerView = null
  }

  constructor(context: Context, attrs: AttributeSet?, defaultStyle: Int) :
    super(context, attrs, defaultStyle) {
    containerView = null
  }

  fun setContainerView(containerView: View?) {
    this.containerView = containerView

    val proxy = proxyAdapterView ?: return

    Log.w(LOG_TAG, "The containerView has changed while the proxyAdapterView exists.")
    if (containerView != null) {
      setInputConnectionTarget(proxy)
    }
  }

  /**
   * Set our proxy adapter view to use its cached input connection instead of creating new ones.
   *
   * This is used to avoid losing our input connection when the virtual display is resized.
   */
  fun lockInputConnection() {
    proxyAdapterView?.setLocked(true)
  }

  /** Sets the proxy adapter view back to its default behavior. */
  fun unlockInputConnection() {
    proxyAdapterView?.setLocked(false)
  }

  /** Restore the original InputConnection, if needed. */
  open fun dispose() {
    if (useHybridComposition) {
      return
    }
    resetInputConnection()
  }

  /**
   * Creates an InputConnection from the IME thread when needed.
   *
   * We only need to create a [ThreadedInputConnectionProxyAdapterView] and create an
   * InputConnectionProxy on the IME thread when WebView is doing the same thing. So we rely on the
   * system calling this method for WebView's proxy view in order to know when we need to create
   * our own.
   *
   * This method would normally be called for any View that used the InputMethodManager. We rely
   * on flutter/engine filtering the calls we receive down to the ones in our hierarchy and the
   * system WebView in order to know whether or not the system WebView expects an InputConnection
   * on the IME thread.
   */
  override fun checkInputConnectionProxy(view: View): Boolean {
    if (useHybridComposition) {
      return super.checkInputConnectionProxy(view)
    }
    // Check to see if the view param is WebView's ThreadedInputConnectionProxyView.
    val previousProxy = threadedInputConnectionProxyView
    threadedInputConnectionProxyView = view
    if (previousProxy === view) {
      // This isn't a new ThreadedInputConnectionProxyView. Ignore it.
      return super.checkInputConnectionProxy(view)
    }
    val currentContainerView = containerView
    if (currentContainerView == null) {
      Log.e(
        LOG_TAG,
        "Can't create a proxy view because there's no container view. Text input may not work."
      )
      return super.checkInputConnectionProxy(view)
    }

    // We've never seen this before, so we make the assumption that this is WebView's
    // ThreadedInputConnectionProxyView. We are making the assumption that the only view that could
    // possibly be interacting with the IMM here is WebView's ThreadedInputConnectionProxyView.
    val proxy = ThreadedInputConnectionProxyAdapterView(
      currentContainerView,
      view,
      view.handler
    )
    proxyAdapterView = proxy
    setInputConnectionTarget(proxy)
    return super.checkInputConnectionProxy(view)
  }

  /**
   * Ensure that input creation happens back on [containerView]'s thread once this view no
   * longer has focus.
   *
   * The logic in [checkInputConnectionProxy] forces input creation to happen on Webview's
   * thread for all connections. We undo it here so users will be able to go back to typing in
   * Flutter UIs as expected.
   */
  override fun clearFocus() {
    super.clearFocus()

    if (useHybridComposition) {
      return
    }
    resetInputConnection()
  }

  /**
   * Ensure that input creation happens back on [containerView].
   *
   * The logic in [checkInputConnectionProxy] forces input creation to happen on Webview's
   * thread for all connections. We undo it here so users will be able to go back to typing in
   * Flutter UIs as expected.
   */
  private fun resetInputConnection() {
    if (proxyAdapterView == null) {
      // No need to reset the InputConnection to the default thread if we've never changed it.
      return
    }
    val currentContainerView = containerView
    if (currentContainerView == null) {
      Log.e(
        LOG_TAG, "Can't reset the input connection to the container view because there is none."
      )
      return
    }
    setInputConnectionTarget(currentContainerView)
  }

  /**
   * This is the crucial trick that gets the InputConnection creation to happen on the correct
   * thread pre Android N.
   * https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169&rcl=f0698ee3e4483fad5b0c34159276f71cfaf81f3a
   *
   * `targetView` should have a [View.getHandler] method with the thread that future
   * InputConnections should be created on.
   */
  private fun setInputConnectionTarget(targetView: View) {
    val currentContainerView = containerView
    if (currentContainerView == null) {
      Log.e(
        LOG_TAG,
        "Can't set the input connection target because there is no containerView to use as a " +
          "handler."
      )
      return
    }

    targetView.requestFocus()
    currentContainerView.post {
      if (containerView == null) {
        Log.e(
          LOG_TAG,
          "Can't set the input connection target because there is no containerView to use as a " +
            "handler."
        )
        return@post
      }

      // The Java fetched an InputMethodManager here and never used it (step 2 below is commented
      // out upstream), so the lookup is dropped rather than kept as a dead local.
      //
      // This is a hack to make InputMethodManager believe that the target view now has focus.
      // As a result, InputMethodManager will think that targetView is focused, and will call
      // getHandler() of the view when creating input connection.

      // Step 1: Set targetView as InputMethodManager#mNextServedView. This does not affect
      // the real window focus.
      targetView.onWindowFocusChanged(true)

      // Step 2: Have InputMethodManager focus in on targetView. As a result, IMM will call
      // onCreateInputConnection() on targetView on the same thread as
      // targetView.getHandler(). It will also call subsequent InputConnection methods on this
      // thread. This is the IME thread in cases where targetView is our proxyAdapterView.
    }
  }

  override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
    super.onFocusChanged(focused, direction, previouslyFocusedRect)
  }

  companion object {
    private const val LOG_TAG = "InputAwareWebView"
  }
}
