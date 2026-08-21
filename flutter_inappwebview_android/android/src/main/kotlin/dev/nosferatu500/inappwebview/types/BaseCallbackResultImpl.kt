package dev.nosferatu500.inappwebview.types

open class BaseCallbackResultImpl<T> : ICallbackResult<T> {
  override fun nonNullSuccess(result: T & Any): Boolean = true

  override fun nullSuccess(): Boolean = true

  override fun defaultBehaviour(result: T?) {}

  override fun success(obj: Any?) {
    val result = decodeResult(obj)
    val shouldRunDefaultBehaviour = if (result == null) nullSuccess() else nonNullSuccess(result)
    if (shouldRunDefaultBehaviour) {
      defaultBehaviour(result)
    }
  }

  override fun decodeResult(obj: Any?): T? = null

  override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}

  override fun notImplemented() {
    defaultBehaviour(null)
  }
}
