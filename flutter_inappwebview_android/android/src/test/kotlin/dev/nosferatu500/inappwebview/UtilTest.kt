package dev.nosferatu500.inappwebview

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The pure-JVM half of [Util].
 *
 * Everything else in that object needs a `Context`, a `WebView` or a live `MethodChannel`, so it
 * belongs to the instrumentation tests this module still does not have (TODO.md P5).
 */
class UtilTest {

  @Test
  fun `getOrDefault distinguishes an absent key from a null value`() {
    val map = mapOf<String, Any?>("present" to "value", "explicitNull" to null)

    assertEquals("value", Util.getOrDefault(map, "present", "fallback"))
    assertEquals("fallback", Util.getOrDefault(map, "absent", "fallback"))

    // The distinction matters: the settings layer treats "key absent" as "leave the platform
    // default alone" and "key present but null" as "the caller sent null on purpose".
    assertNull(Util.getOrDefault<String?>(map, "explicitNull", "fallback"))
  }

  @Test
  fun `objEquals compares by value, including boxed numbers outside the Integer cache`() {
    assertTrue(Util.objEquals(null, null))
    assertFalse(Util.objEquals(null, 1))
    assertFalse(Util.objEquals(1, null))

    // §37: this is why `rendererPriorityPolicy` had to stop using `!==`. Both operands are
    // Integer objects decoded from a channel map; identity holds only inside the autoboxing
    // cache (-128..127), so a reference comparison silently starts reporting spurious changes
    // as soon as a value falls outside it.
    val a: Any = 1000
    val b: Any = 1000
    assertTrue(Util.objEquals(a, b))
    assertFalse("this test is meaningless if the JVM interned these", a === b)
  }

  @Test
  fun `isIPv6 accepts v6 literals`() {
    assertTrue(Util.isIPv6("::1"))
    assertTrue(Util.isIPv6("2001:db8::1"))
  }

  /**
   * **Characterization test for a bug, not a specification.** Invert it when the bug is fixed --
   * see TODO.md P0b.7.
   *
   * `Util.isIPv6` is implemented as `Inet6Address.getByName(address)`. `Inet6Address` declares no
   * `getByName`, so that call resolves to the *inherited* `InetAddress.getByName`, which happily
   * parses an IPv4 literal and returns an `Inet4Address`. Nothing about the result is checked, so
   * the function answers "is this resolvable", not "is this IPv6".
   *
   * Only the literal cases are pinned here: `isIPv6("example.com")` also returns `true`, but
   * asserting that would make this suite depend on a DNS resolver.
   */
  @Test
  fun `isIPv6 wrongly accepts IPv4 literals too`() {
    assertTrue(Util.isIPv6("127.0.0.1"))
    assertTrue(Util.isIPv6("192.168.1.1"))
  }

  @Test
  fun `isIPv6 rejects something that resolves to nothing at all`() {
    assertFalse(Util.isIPv6("nope.invalid"))
  }

  // `Util.normalizeIPv6` is deliberately not exercised here. It returns
  // `InetAddress.getByName(address).canonicalHostName`, which performs a *reverse DNS lookup* on
  // the calling thread and returns a hostname rather than a normalized address -- `::1` comes back
  // as "localhost", not "0:0:0:0:0:0:0:1". Both the value and the latency depend on the machine's
  // resolver, so any assertion here would be environment-dependent. The bug is filed in TODO.md
  // P0b.7; a test can be written once it returns `hostAddress`.

  @Test
  fun `JSONStringify quotes strings so the result can be embedded in JavaScript`() {
    // The output of this method is concatenated straight into injected JS, so a String must come
    // back quoted and escaped -- returning it bare would produce a syntax error, or worse, let a
    // page-supplied value break out of the literal.
    assertEquals("\"hello\"", Util.JSONStringify("hello"))
    assertEquals("\"he said \\\"hi\\\"\"", Util.JSONStringify("he said \"hi\""))
    assertEquals("\"line1\\nline2\"", Util.JSONStringify("line1\nline2"))
  }

  @Test
  fun `JSONStringify handles null, maps, lists and scalars`() {
    assertEquals("null", Util.JSONStringify(null))
    assertEquals("{\"a\":1}", Util.JSONStringify(mapOf("a" to 1)))
    assertEquals("[1,2]", Util.JSONStringify(listOf(1, 2)))
    assertEquals("42", Util.JSONStringify(42))
    assertEquals("true", Util.JSONStringify(true))
  }
}
