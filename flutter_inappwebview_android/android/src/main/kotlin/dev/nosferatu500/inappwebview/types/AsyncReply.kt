package dev.nosferatu500.inappwebview.types

import dev.nosferatu500.inappwebview.pigeons.FlutterError

/**
 * Runs [body] so that a **synchronous** throw is delivered to the Pigeon callback instead of
 * escaping the generated message handler.
 *
 * 🚨 **Why this exists.** Pigeon's generated handlers are not symmetric. A *synchronous* host method
 * is wrapped for you:
 *
 * ```kotlin
 * val wrapped: List<Any?> = try { listOf(api.foo(arg)) }
 *                           catch (exception: Throwable) { wrapError(exception) }
 * reply.reply(wrapped)
 * ```
 *
 * An **`@async`** one is not:
 *
 * ```kotlin
 * api.foo(arg) { result -> … }        // no try/catch anywhere
 * ```
 *
 * so only a failure delivered *through the callback* becomes an error envelope. A synchronous throw
 * escapes into `BasicMessageChannel`, which logs "Failed to handle message" and replies **null** —
 * and the Dart caller sees `PlatformException(channel-error, "Unable to establish connection on
 * channel…")`, an error naming the transport rather than the cause, with the message handler left
 * dangling.
 *
 * Two real instances have shipped: `MyWebStorage.deleteBrowsingDataForSite` (§170) and
 * `ProxyManager.setProxyOverride` (§171).
 *
 * **[reply] is idempotent, and that is the point.** §171's first fix tried to reason about *where*
 * the exception came from and guarded only the part of the method that looked like the validator;
 * the throw was somewhere else entirely (inside Chromium, under the androidx call that had been
 * deliberately excluded). Wrapping the whole operation is correct without predicting anything — and
 * it is safe to wrap a call that may already have replied, because a second [reply] is dropped
 * rather than sent. Several of these callers use a direct executor, so their completion runs inline
 * and a later throw would otherwise produce two replies for one message.
 *
 * @param code the `PlatformException.code` a caught throwable is reported under. A [FlutterError] is
 *   used rather than the raw throwable because Pigeon's `wrapError` otherwise derives the code from
 *   `javaClass.simpleName`, making it depend on which exception the platform happens to raise.
 */
internal inline fun <T> replyingOnThrow(
  code: String,
  noinline callback: (Result<T>) -> Unit,
  body: (reply: (Result<T>) -> Unit) -> Unit
) {
  var replied = false
  val reply: (Result<T>) -> Unit = { result ->
    if (!replied) {
      replied = true
      callback(result)
    }
  }
  try {
    body(reply)
  } catch (throwable: Throwable) {
    // Throwable, not Exception: an Error escaping the handler produces exactly the same dead
    // channel, and the caller is better served by a named failure than by silence.
    reply(Result.failure(FlutterError(code, throwable.message ?: throwable.toString(), null)))
  }
}
