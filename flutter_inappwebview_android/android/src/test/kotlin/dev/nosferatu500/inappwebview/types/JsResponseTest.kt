package dev.nosferatu500.inappwebview.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The three JS dialog responses. They share a shape but not a supertype, which is exactly how
 * §37's `JsBeforeUnloadResponse.toString()` came to print `"JsConfirmResponse"` -- the class was
 * written by copying its neighbour.
 */
class JsResponseTest {

  @Test
  fun `each response names itself in toString`() {
    // The regression §37 fixed. Cheap to pin, and a copy-paste of one of these classes into a
    // fourth would reintroduce it silently -- toString output is not covered by anything else.
    assertTrue(
      JsBeforeUnloadResponse("m", "ok", "cancel", true, 1).toString()
        .startsWith("JsBeforeUnloadResponse{")
    )
    assertTrue(
      JsConfirmResponse("m", "ok", "cancel", true, 1).toString().startsWith("JsConfirmResponse{")
    )
    assertTrue(JsAlertResponse("m", "ok", true, 1).toString().startsWith("JsAlertResponse{"))
  }

  @Test
  fun `JsBeforeUnloadResponse fromMap reads handledByClient, not isHandledByClient`() {
    // The Kotlin property is `isHandledByClient` but the wire key is `handledByClient`; Kotlin's
    // `is` prefix makes it easy to "fix" the map key to match the property and break the channel.
    val response = JsBeforeUnloadResponse.fromMap(
      mapOf(
        "message" to "leaving?",
        "confirmButtonTitle" to "Leave",
        "cancelButtonTitle" to "Stay",
        "handledByClient" to true,
        "action" to 1
      )
    )!!

    assertEquals("leaving?", response.message)
    assertEquals("Leave", response.confirmButtonTitle)
    assertEquals("Stay", response.cancelButtonTitle)
    assertTrue(response.isHandledByClient)
    assertEquals(1, response.action)
  }

  @Test
  fun `fromMap passes null through for all three`() {
    assertNull(JsBeforeUnloadResponse.fromMap(null))
    assertNull(JsConfirmResponse.fromMap(null))
    assertNull(JsAlertResponse.fromMap(null))
  }

  @Test
  fun `a null action survives rather than collapsing to a default`() {
    // `action` selects confirm vs cancel on the native side. Defaulting a missing one to 0 would
    // silently turn "the handler did not answer" into "the user pressed OK".
    val response = JsBeforeUnloadResponse.fromMap(
      mapOf(
        "message" to "m",
        "confirmButtonTitle" to "ok",
        "cancelButtonTitle" to "cancel",
        "handledByClient" to false,
        "action" to null
      )
    )!!

    assertNull(response.action)
  }
}
