package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.os.Handler
import android.os.IBinder
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection

/**
 * A fake View only exposed to InputMethodManager.
 *
 * https://github.com/flutter/plugins/blob/main/packages/webview_flutter/webview_flutter_android/android/src/main/java/io/flutter/plugins/webviewflutter/ThreadedInputConnectionProxyAdapterView.java
 */
// Not inflatable from XML by design: this is a fake View handed only to InputMethodManager,
// always constructed programmatically with the container/root/target views it proxies. A
// (Context, AttributeSet) constructor could not populate those and would produce a broken proxy.
@SuppressLint("ViewConstructor")
internal class ThreadedInputConnectionProxyAdapterView(
  @JvmField val containerView: View,
  @JvmField val targetView: View,
  @JvmField val imeHandler: Handler?
) : View(containerView.context) {

  @JvmField
  val windowToken: IBinder? = containerView.windowToken

  @JvmField
  val rootView: View = containerView.rootView

  /** Returns whether or not this is currently asynchronously acquiring an input connection. */
  var isTriggerDelayed = true
    private set

  private var isLocked = false
  private var cachedConnection: InputConnection? = null

  init {
    isFocusable = true
    isFocusableInTouchMode = true
    visibility = VISIBLE
  }

  /** Sets whether or not this should use its previously cached input connection. */
  fun setLocked(locked: Boolean) {
    isLocked = locked
  }

  /**
   * This is expected to be called on the IME thread. See the setup required for this in
   * [InputAwareWebView.checkInputConnectionProxy].
   *
   * Delegates to ThreadedInputConnectionProxyView to get WebView's input connection.
   */
  override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
    isTriggerDelayed = false
    val inputConnection =
      if (isLocked) cachedConnection else targetView.onCreateInputConnection(outAttrs)
    isTriggerDelayed = true
    cachedConnection = inputConnection
    return inputConnection
  }

  override fun checkInputConnectionProxy(view: View?): Boolean = true

  override fun hasWindowFocus(): Boolean {
    // None of our views here correctly report they have window focus because of how we're
    // embedding the platform view inside of a virtual display.
    return true
  }

  override fun getRootView(): View = rootView

  override fun onCheckIsTextEditor(): Boolean = true

  override fun isFocused(): Boolean = true

  override fun getWindowToken(): IBinder? = windowToken

  override fun getHandler(): Handler? = imeHandler
}
