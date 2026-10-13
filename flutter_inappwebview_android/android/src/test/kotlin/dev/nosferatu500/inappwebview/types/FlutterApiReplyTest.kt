package dev.nosferatu500.inappwebview.types

import dev.nosferatu500.inappwebview.pigeons.FlutterError
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * [deliverToCallback] is the one place W5 (§216) decides what each Pigeon reply means to the
 * MethodChannel-era callbacks, so its four outcomes are pinned here, with no device. The device
 * tests (§215) see the first two; the `channel-error` case needs a reply with no Dart handler, which
 * only a dispose race produces there.
 */
class FlutterApiReplyTest {

  private class Recorder : MethodChannel.Result {
    val calls = mutableListOf<String>()
    var value: Any? = null

    override fun success(result: Any?) {
      calls.add("success")
      value = result
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
      calls.add("error $errorCode $errorMessage $errorDetails")
    }

    override fun notImplemented() {
      calls.add("notImplemented")
    }
  }

  @Test
  fun `an answer reaches success with its ints narrowed, nested ones included`() {
    val recorder = Recorder()

    deliverToCallback(
      recorder,
      Result.success(mapOf<String?, Any?>("action" to 1L, "nested" to listOf(2L, "x")))
    )

    assertEquals(listOf("success"), recorder.calls)
    // `decodeResult`s read `as Int`, as the MethodChannel gave them; a Long would throw.
    assertEquals(mapOf("action" to 1, "nested" to listOf(2, "x")), recorder.value)
    assertEquals(Int::class.javaObjectType, (recorder.value as Map<*, *>)["action"]!!.javaClass)
  }

  @Test
  fun `a top-level int answer is narrowed too`() {
    val recorder = Recorder()

    deliverToCallback(recorder, Result.success(0L))

    assertEquals(0, recorder.value)
    assertEquals(Int::class.javaObjectType, recorder.value!!.javaClass)
  }

  @Test
  fun `null is a success, which each callback reads as no answer`() {
    val recorder = Recorder()

    deliverToCallback<Any?>(recorder, Result.success(null))

    assertEquals(listOf("success"), recorder.calls)
    assertEquals(null, recorder.value)
  }

  @Test
  fun `a Dart throw reaches error with Pigeon's code, message and details`() {
    val recorder = Recorder()

    deliverToCallback<Any?>(
      recorder,
      Result.failure(FlutterError("error", "Bad state: confirm failed", "the-details"))
    )

    assertEquals(listOf("error error Bad state: confirm failed the-details"), recorder.calls)
  }

  @Test
  fun `no Dart handler reaches notImplemented, not error`() {
    val recorder = Recorder()

    deliverToCallback<Any?>(
      recorder,
      Result.failure(
        FlutterError("channel-error", "Unable to establish connection on channel.", "")
      )
    )

    // What the MethodChannel answered with no handler, so each event takes its default rather than
    // its error branch (they differ for the JS dialogs and the JS handler).
    assertEquals(listOf("notImplemented"), recorder.calls)
  }
}
