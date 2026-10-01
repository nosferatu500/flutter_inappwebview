package dev.nosferatu500.inappwebview.types

import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.FlutterError
import io.flutter.plugin.common.MethodChannel

/**
 * Hands a Pigeon FlutterApi reply to the [MethodChannel.Result] callback that the MethodChannel used
 * to drive, so an event moved to Pigeon keeps the outcomes it had there (`WebViewChannelDelegate`
 * W5, §216):
 *
 *  - an answer goes to `success`, after [Util.normalizeCodecInts]: Pigeon's Dart codec writes every
 *    int as 64-bit, and each `decodeResult` reads the `Int` the MethodChannel gave it;
 *  - a Dart throw goes to `error`, with Pigeon's code and message, as the error envelope did;
 *  - **no Dart handler** (`channel-error`) goes to `notImplemented`, which is what the MethodChannel
 *    answered then. It is deliberately not an error: for the JS dialogs and the JS handler the two
 *    branches differ (cancel and reject, against the default), §215.
 *
 * Pigeon fails only with [FlutterError] (the generated `send`), hence the cast: anything else would
 * be a generator change, and should fail loudly.
 */
internal fun <T> deliverToCallback(callback: MethodChannel.Result, reply: Result<T>) {
  reply.fold(
    onSuccess = { callback.success(Util.normalizeCodecInts(it)) },
    onFailure = { e ->
      val error = e as FlutterError
      if (error.code == CHANNEL_ERROR) {
        callback.notImplemented()
      } else {
        callback.error(error.code, error.message, error.details)
      }
    }
  )
}

/** The code of the generated `createConnectionError`: the message reached no Dart handler. */
private const val CHANNEL_ERROR = "channel-error"
