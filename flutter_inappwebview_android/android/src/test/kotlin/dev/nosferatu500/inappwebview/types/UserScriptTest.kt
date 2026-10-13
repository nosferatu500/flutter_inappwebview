package dev.nosferatu500.inappwebview.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * [UserScript] and its subclass [PluginScript].
 *
 * These carry six positional constructor arguments, four of which are nullable or boolean, so a
 * mis-ordered call compiles cleanly and fails only as a script injected into the wrong world or
 * frame. §39 rewrapped `PluginScript`'s supertype call across six lines, which is precisely the
 * edit where an off-by-one would hide -- hence the argument-mapping tests below.
 */
class UserScriptTest {

  private val js = "console.log('x');"

  @Test
  fun `each constructor argument lands in its own field`() {
    val world = ContentWorld.world("isolated")
    val script = UserScript(
      "group",
      js,
      UserScriptInjectionTime.AT_DOCUMENT_END,
      world,
      setOf("https://example.com"),
      true
    )

    assertEquals("group", script.groupName)
    assertEquals(js, script.source)
    assertEquals(UserScriptInjectionTime.AT_DOCUMENT_END, script.injectionTime)
    assertEquals(world, script.contentWorld)
    assertEquals(setOf("https://example.com"), script.allowedOriginRules)
    assertTrue(script.isForMainFrameOnly)
  }

  @Test
  fun `PluginScript forwards all six inherited arguments in the right order`() {
    val world = ContentWorld.world("isolated")
    val script = PluginScript(
      "group",
      js,
      UserScriptInjectionTime.AT_DOCUMENT_START,
      world,
      true,
      setOf("https://example.com"),
      false
    )

    assertEquals("group", script.groupName)
    assertEquals(js, script.source)
    assertEquals(UserScriptInjectionTime.AT_DOCUMENT_START, script.injectionTime)
    assertEquals(world, script.contentWorld)
    assertEquals(setOf("https://example.com"), script.allowedOriginRules)
    assertFalse(script.isForMainFrameOnly)
    // The one argument PluginScript keeps for itself, sitting between contentWorld and
    // allowedOriginRules -- the easiest of the seven to shift by one.
    assertTrue(script.isRequiredInAllContentWorlds)
  }

  @Test
  fun `a null contentWorld defaults to PAGE rather than staying null`() {
    val script = UserScript("g", js, UserScriptInjectionTime.AT_DOCUMENT_START, null, null, false)

    assertEquals(ContentWorld.PAGE, script.contentWorld)
  }

  @Test
  fun `null allowedOriginRules defaults to the permissive wildcard`() {
    val script = UserScript("g", js, UserScriptInjectionTime.AT_DOCUMENT_START, null, null, false)

    // Pinned because it is a security-relevant default: absent rules mean "every origin", not
    // "no origin". Anything narrowing this is a deliberate breaking change, not a tidy-up.
    assertEquals(setOf("*"), script.allowedOriginRules)
  }

  @Test
  fun `fromMap reads the keys the Dart side sends`() {
    val script = UserScript.fromMap(
      mapOf(
        "groupName" to "group",
        "source" to js,
        "injectionTime" to UserScriptInjectionTime.AT_DOCUMENT_END.toValue(),
        "contentWorld" to mapOf<String, Any?>("name" to "isolated"),
        "allowedOriginRules" to listOf("https://example.com"),
        "forMainFrameOnly" to true
      )
    )!!

    assertEquals("group", script.groupName)
    assertEquals(js, script.source)
    assertEquals(UserScriptInjectionTime.AT_DOCUMENT_END, script.injectionTime)
    assertEquals("isolated", script.contentWorld.name)
    assertEquals(setOf("https://example.com"), script.allowedOriginRules)
    assertTrue(script.isForMainFrameOnly)
  }

  @Test
  fun `fromMap passes null through`() {
    assertNull(UserScript.fromMap(null))
  }

  @Test
  fun `ContentWorld identity is by name, so PAGE and a hand-built page world match`() {
    assertEquals(ContentWorld.PAGE, ContentWorld.world("page"))
    assertEquals(ContentWorld.PAGE, ContentWorld.fromMap(mapOf("name" to "page")))
    assertEquals("defaultClient", ContentWorld.DEFAULT_CLIENT.name)
  }
}
