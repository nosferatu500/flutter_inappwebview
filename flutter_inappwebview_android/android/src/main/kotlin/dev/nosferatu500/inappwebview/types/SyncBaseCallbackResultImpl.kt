package dev.nosferatu500.inappwebview.types

import androidx.annotation.CallSuper
import java.util.concurrent.CountDownLatch

/**
 * A callback whose producer blocks a thread until the Dart side answers.
 *
 * Every path out of this object MUST release [latch]. The waiter is a WebView worker thread
 * (see `Util.invokeMethodAndWaitResult`), so a leaked latch does not merely lose one result --
 * it stalls resource loading for the rest of the WebView's life. That is why the overrides below
 * count down in a `finally` rather than on the success path: `decodeResult` casts a value that
 * came off the Flutter codec and can throw ClassCastException, and [nullSuccess],
 * [nonNullSuccess] and [defaultBehaviour] are all open for subclasses to override.
 *
 * Counting down twice is harmless -- CountDownLatch ignores it once the count reaches zero -- so
 * subclasses do not need to know which paths already released it.
 */
open class SyncBaseCallbackResultImpl<T> : BaseCallbackResultImpl<T>() {
  @JvmField
  val latch: CountDownLatch = CountDownLatch(1)

  @JvmField
  var result: T? = null

  @CallSuper
  override fun defaultBehaviour(result: T?) {
    latch.countDown()
  }

  override fun success(obj: Any?) {
    try {
      val result = decodeResult(obj)
      this.result = result
      val shouldRunDefaultBehaviour = if (result == null) nullSuccess() else nonNullSuccess(result)
      if (shouldRunDefaultBehaviour) {
        defaultBehaviour(result)
      }
    } finally {
      latch.countDown()
    }
  }

  @CallSuper
  override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
    latch.countDown()
  }

  @CallSuper
  override fun notImplemented() {
    try {
      defaultBehaviour(null)
    } finally {
      latch.countDown()
    }
  }
}
