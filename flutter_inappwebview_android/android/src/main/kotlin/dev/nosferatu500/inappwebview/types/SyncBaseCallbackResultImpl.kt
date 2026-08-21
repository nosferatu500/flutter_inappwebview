package dev.nosferatu500.inappwebview.types

import androidx.annotation.CallSuper
import java.util.concurrent.CountDownLatch

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
    val result = decodeResult(obj)
    this.result = result
    val shouldRunDefaultBehaviour = if (result == null) nullSuccess() else nonNullSuccess(result)
    if (shouldRunDefaultBehaviour) {
      defaultBehaviour(result)
    } else {
      latch.countDown()
    }
  }

  @CallSuper
  override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
    latch.countDown()
  }

  @CallSuper
  override fun notImplemented() {
    defaultBehaviour(null)
  }
}
