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
    assertTrue(Util.isIPv6("0:0:0:0:0:0:0:1"))
  }

  @Test
  fun `isIPv6 accepts the bracketed form Uri getHost returns`() {
    // `Uri.getHost()` keeps the brackets for an IPv6 authority, and `isOriginAllowed` passes that
    // value straight through, so both spellings have to work.
    assertTrue(Util.isIPv6("[::1]"))
    assertTrue(Util.isIPv6("[2001:db8::1]"))
  }

  /**
   * The inversion of the characterization test P0b.7 left behind.
   *
   * `isIPv6` was `Inet6Address.getByName(address); true`. `Inet6Address` declares no `getByName`,
   * so that resolved to the inherited `InetAddress.getByName`, which parses IPv4 literals *and
   * resolves hostnames*, and nothing type-checked the result — so it answered "is this
   * resolvable", not "is this IPv6". Both of these returned `true` before the fix.
   */
  @Test
  fun `isIPv6 rejects IPv4 literals`() {
    assertFalse(Util.isIPv6("127.0.0.1"))
    assertFalse(Util.isIPv6("192.168.1.1"))
  }

  @Test
  fun `isIPv6 rejects hostnames without consulting a resolver`() {
    // "localhost" is the case that matters: it resolves on every machine, so the old
    // implementation returned true for it. A hostname cannot contain ':', which is what lets this
    // be decided without a lookup -- and is why this assertion is safe in a unit test at all.
    assertFalse(Util.isIPv6("localhost"))
    assertFalse(Util.isIPv6("example.com"))
    assertFalse(Util.isIPv6("nope.invalid"))
    assertFalse(Util.isIPv6(""))
  }

  @Test
  fun `isIPv6 rejects a malformed literal rather than resolving it`() {
    assertFalse(Util.isIPv6("gg::1"))
    assertFalse(Util.isIPv6(":::"))
  }

  @Test
  fun `normalizeIPv6 returns a normalized address, not a hostname`() {
    // The whole point of P0b.7's second half: this used to return `canonicalHostName`, so `::1`
    // came back as "localhost" via a reverse DNS lookup. `hostAddress` is the field that
    // normalizes, and it needs no lookup -- which is what makes this assertion stable.
    assertEquals("0:0:0:0:0:0:0:1", Util.normalizeIPv6("::1"))
    assertEquals("0:0:0:0:0:0:0:1", Util.normalizeIPv6("[::1]"))
  }

  @Test
  fun `normalizeIPv6 makes two spellings of one address comparable`() {
    // This is the property `isOriginAllowed` actually depends on when it compares a rule's host
    // against the page's host.
    assertEquals(
      Util.normalizeIPv6("2001:db8::1"),
      Util.normalizeIPv6("2001:0db8:0000:0000:0000:0000:0000:0001")
    )
  }

  @Test
  fun `normalizeIPv6 rejects anything that is not an IPv6 literal`() {
    for (bad in listOf("127.0.0.1", "localhost", "example.com", "gg::1", "")) {
      try {
        Util.normalizeIPv6(bad)
        throw AssertionError("normalizeIPv6 should have rejected \"$bad\"")
      } catch (expected: Exception) {
        assertTrue(expected.message!!.startsWith("Invalid address:"))
      }
    }
  }

  /**
   * The wildcard half of `WebMessageListener.isOriginAllowed`.
   *
   * It was `host.contains(suffix)`. Every assertion below that expects `false` for a host
   * containing the suffix returned `true` before the fix.
   */
  @Test
  fun `hostMatchesWildcardRule matches subdomains`() {
    assertTrue(Util.hostMatchesWildcardRule("*.example.com", "foo.example.com"))
    assertTrue(Util.hostMatchesWildcardRule("*.example.com", "a.b.c.example.com"))
    assertTrue(Util.hostMatchesWildcardRule("*.example.com", "www.example.com"))
  }

  @Test
  fun `hostMatchesWildcardRule does not match a host that merely contains the suffix`() {
    // The hole. `.example.com` occurs at index 3, but the registrable domain is evil.test, so an
    // attacker who owns evil.test could reach a listener whose allow-list names example.com.
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "foo.example.com.evil.test"))
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "example.com.evil.test"))
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "a.example.com.b.example.org"))
  }

  @Test
  fun `hostMatchesWildcardRule is subdomains only, so bare host does not match`() {
    // Decided 2026-08-31. Not a change -- "example.com" never contained ".example.com" either --
    // but it is the property the rule exists for, so it is pinned rather than left implicit.
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "example.com"))
  }

  @Test
  fun `hostMatchesWildcardRule anchors on a label boundary for the dotted form`() {
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "notexample.com"))
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", "myexample.com"))
  }

  @Test
  fun `hostMatchesWildcardRule leaves the dotless spelling behaving as it did`() {
    // `*example.com` carries no label boundary to anchor on, so it still matches `notexample.com`.
    // Rejecting the form was considered and not chosen; it belongs to rule validation, not here.
    // End-anchoring still applies to it, which is the only thing that changed.
    assertTrue(Util.hostMatchesWildcardRule("*example.com", "notexample.com"))
    assertTrue(Util.hostMatchesWildcardRule("*example.com", "example.com"))
    assertTrue(Util.hostMatchesWildcardRule("*example.com", "foo.example.com"))
    assertFalse(Util.hostMatchesWildcardRule("*example.com", "example.com.evil.test"))
  }

  @Test
  fun `hostMatchesWildcardRule declines anything that is not a wildcard rule`() {
    // A non-wildcard rule host is compared for equality by the caller; this predicate must not
    // answer for it, or an exact rule would start matching suffixes.
    assertFalse(Util.hostMatchesWildcardRule("example.com", "example.com"))
    assertFalse(Util.hostMatchesWildcardRule("example.com", "foo.example.com"))
    assertFalse(Util.hostMatchesWildcardRule("*.example.com", null))
  }

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

  @Test
  fun `resolveSyncCallbackTimeoutMillis honours a positive setting`() {
    assertEquals(30_000L, Util.resolveSyncCallbackTimeoutMillis(30_000))
    // Lowering it is legitimate too -- a caller may prefer to give up quickly.
    assertEquals(500L, Util.resolveSyncCallbackTimeoutMillis(500))
    assertEquals(1L, Util.resolveSyncCallbackTimeoutMillis(1))
  }

  @Test
  fun `resolveSyncCallbackTimeoutMillis falls back when the setting is absent`() {
    // Null is the ordinary case: the Dart field is nullable and the key is skipped when unset.
    assertEquals(
      Util.SYNC_CALLBACK_TIMEOUT_MILLIS,
      Util.resolveSyncCallbackTimeoutMillis(null)
    )
    assertEquals(10_000L, Util.SYNC_CALLBACK_TIMEOUT_MILLIS)
  }

  @Test
  fun `resolveSyncCallbackTimeoutMillis refuses a non-positive setting`() {
    // `latch.await(0)` returns false immediately, so honouring a 0 would make every synchronous
    // callback a silent no-op -- the resource always loads unintercepted. A mistaken 0 (or a
    // negative from arithmetic on a duration) must not be able to switch interception off.
    assertEquals(Util.SYNC_CALLBACK_TIMEOUT_MILLIS, Util.resolveSyncCallbackTimeoutMillis(0))
    assertEquals(Util.SYNC_CALLBACK_TIMEOUT_MILLIS, Util.resolveSyncCallbackTimeoutMillis(-1))
    assertEquals(
      Util.SYNC_CALLBACK_TIMEOUT_MILLIS,
      Util.resolveSyncCallbackTimeoutMillis(Int.MIN_VALUE)
    )
  }
}
