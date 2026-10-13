package dev.nosferatu500.inappwebview.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * [Size2D] is the wire type behind `HeadlessInAppWebView.setSize`/`getSize`.
 *
 * §37 fixed a bug one level above this class -- `setSize`'s height branch tested `size.width`, so
 * `-1` on one axis was read from the other. That fix is *not* covered here, because `setSize` needs
 * a `View` and a `Context`; see the note at the bottom.
 */
class Size2DTest {

  @Test
  fun `toMap uses the keys the Dart side reads`() {
    assertEquals(mapOf("width" to 100.0, "height" to 200.0), Size2D(100.0, 200.0).toMap())
  }

  @Test
  fun `width and height do not get transposed on a round trip`() {
    // Deliberately asymmetric. A transposition -- the §37 MediaSizeExt bug, in the class next
    // door -- survives any test that uses a square.
    val restored = Size2D.fromMap(Size2D(100.0, 200.0).toMap())!!

    assertEquals(100.0, restored.width, 0.0)
    assertEquals(200.0, restored.height, 0.0)
  }

  @Test
  fun `the -1 fullscreen sentinel survives the round trip on each axis independently`() {
    // -1 means "match the corresponding screen dimension" and is documented per-axis, so all four
    // combinations have to make it across intact.
    for (size in listOf(
      Size2D(-1.0, -1.0),
      Size2D(-1.0, 800.0),
      Size2D(400.0, -1.0),
      Size2D(400.0, 800.0)
    )) {
      assertEquals(size, Size2D.fromMap(size.toMap()))
    }
  }

  @Test
  fun `fromMap passes null through rather than substituting a zero size`() {
    assertNull(Size2D.fromMap(null))
  }

  @Test
  fun `equality is by value and is not symmetric under transposition`() {
    assertEquals(Size2D(1.0, 2.0), Size2D(1.0, 2.0))
    assertEquals(Size2D(1.0, 2.0).hashCode(), Size2D(1.0, 2.0).hashCode())
    assertNotEquals(Size2D(1.0, 2.0), Size2D(2.0, 1.0))
  }
}
