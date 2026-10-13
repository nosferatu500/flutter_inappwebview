package dev.nosferatu500.inappwebview.types

import dev.nosferatu500.inappwebview.pigeons.FlutterError
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * [replyingOnThrow] is the guard §172 applied to every `@async` Pigeon host method, and it is the
 * piece that makes that change reviewable: the call sites cannot be tested where no throw can be
 * produced, but the mechanism can be, here, with no device and no WebView.
 *
 * The behaviours below are the whole contract — a synchronous throw becomes a failure, a reply
 * already sent wins, and nothing is sent twice.
 */
class AsyncReplyTest {

  @Test
  fun `a normal reply is passed straight through`() {
    val seen = mutableListOf<Result<String>>()

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      reply(Result.success("ok"))
    }

    assertEquals(1, seen.size)
    assertEquals("ok", seen.single().getOrNull())
  }

  @Test
  fun `a synchronous throw becomes a failure instead of escaping`() {
    val seen = mutableListOf<Result<String>>()

    // Without the guard this call would propagate out of the generated message handler, Flutter
    // would reply null, and the caller would see `channel-error` naming the channel rather than
    // the cause.
    replyingOnThrow<String>("Tag", { seen.add(it) }) {
      throw IllegalArgumentException("Invalid Proxy URL: ://")
    }

    assertEquals(1, seen.size)
    val error = seen.single().exceptionOrNull()
    assertTrue(error is FlutterError)
    assertEquals("Tag", (error as FlutterError).code)
    assertEquals("Invalid Proxy URL: ://", error.message)
  }

  @Test
  fun `an Error is caught too, not only an Exception`() {
    val seen = mutableListOf<Result<String>>()

    replyingOnThrow<String>("Tag", { seen.add(it) }) {
      throw StackOverflowError("boom")
    }

    assertEquals("Tag", (seen.single().exceptionOrNull() as FlutterError).code)
  }

  @Test
  fun `a throwable with no message still reports something`() {
    // `FlutterError.message` is nullable, but a null there reaches Dart as a PlatformException with
    // no message at all -- the §163 failure mode, an error envelope that says nothing.
    val seen = mutableListOf<Result<String>>()

    replyingOnThrow<String>("Tag", { seen.add(it) }) {
      throw IllegalStateException()
    }

    val error = seen.single().exceptionOrNull() as FlutterError
    assertEquals("java.lang.IllegalStateException", error.message)
  }

  @Test
  fun `a throw after a reply does not send a second one`() {
    // The ordering that makes it safe to wrap a call which may already have completed inline: a
    // direct executor runs the completion before the platform call returns, so a later throw must
    // not turn one message into two replies.
    val seen = mutableListOf<Result<String>>()

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      reply(Result.success("delivered"))
      throw IllegalStateException("thrown after the callback already ran")
    }

    assertEquals(1, seen.size)
    assertEquals("delivered", seen.single().getOrNull())
  }

  @Test
  fun `only the first of several replies is delivered`() {
    val seen = mutableListOf<Result<String>>()

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      reply(Result.success("first"))
      reply(Result.success("second"))
      reply(Result.failure(IllegalStateException("third")))
    }

    assertEquals(1, seen.size)
    assertEquals("first", seen.single().getOrNull())
  }

  @Test
  fun `a failure the body reports itself is left alone`() {
    // The guard must not rewrap a failure the caller deliberately produced -- its code and type are
    // the caller's choice.
    val seen = mutableListOf<Result<String>>()
    val deliberate = FlutterError("Deliberate", "chosen by the caller", null)

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      reply(Result.failure(deliberate))
    }

    assertSame(deliberate, seen.single().exceptionOrNull())
  }

  @Test
  fun `a reply deferred past the body is still delivered`() {
    // The common shape: the body hands `reply` to an androidx callback and returns without calling
    // it. Nothing may be sent until that callback fires.
    val seen = mutableListOf<Result<String>>()
    var deferred: ((Result<String>) -> Unit)? = null

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      deferred = reply
    }

    assertTrue(seen.isEmpty())
    deferred!!(Result.success("late"))
    assertEquals("late", seen.single().getOrNull())
  }

  @Test
  fun `a deferred reply is still suppressed after the body threw`() {
    // If the body captured `reply` and then threw, the failure is already sent -- the late callback
    // must not add a second reply.
    val seen = mutableListOf<Result<String>>()
    var deferred: ((Result<String>) -> Unit)? = null

    replyingOnThrow<String>("Tag", { seen.add(it) }) { reply ->
      deferred = reply
      throw IllegalStateException("failed after capturing reply")
    }

    assertEquals(1, seen.size)
    assertTrue(seen.single().isFailure)

    deferred!!(Result.success("too late"))
    assertEquals(1, seen.size)
    assertNull(seen.single().getOrNull())
  }
}
