package dev.nosferatu500.inappwebview.headless_in_app_webview

import dev.nosferatu500.inappwebview.types.Size2D
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test

/**
 * The arithmetic behind `HeadlessInAppWebView.setSize` / `getSize` (`TODO.md` P0b.8).
 *
 * `setSize` and `getSize` themselves need a `View`, a `Context` and a `WindowManager`, none of
 * which a JVM unit test in this module can touch -- which is why the arithmetic lives in
 * [HeadlessWebViewSize] and takes the density and the screen size as plain numbers.
 *
 * **Density 2.4375 is the interesting one.** The test AVDs run at density 420 (scale 2.625), where
 * 600, 800, 1080 and 1920 are all whole numbers of physical pixels -- so the existing integration
 * assertions passed on those devices while the bug was live. 2.4375 is the density that first
 * reported it, and a non-integer logical size reproduces it at *every* density.
 */
class HeadlessWebViewSizeTest {

  private val fullscreen = Size2D(1080.0, 2400.0)

  @Test
  fun `a fractional pixel product rounds instead of truncating`() {
    // 600 * 2.4375 = 1462.5. Truncation gave 1462, which is what made getSize answer 599.795.
    assertEquals(1463, HeadlessWebViewSize.toPhysicalPixels(600.0, 2.4375, 1080.0))
    assertNotEquals(1462, HeadlessWebViewSize.toPhysicalPixels(600.0, 2.4375, 1080.0))
    // 800 * 2.4375 = 1950 exactly: the height axis survived truncation, which is why the bug
    // presented as a width-only defect and read like a transposition.
    assertEquals(1950, HeadlessWebViewSize.toPhysicalPixels(800.0, 2.4375, 2400.0))
  }

  @Test
  fun `an integer pixel product is unchanged`() {
    // Density 420, the test AVDs: nothing to round, and rounding must not perturb it.
    assertEquals(1575, HeadlessWebViewSize.toPhysicalPixels(600.0, 2.625, 1080.0))
    assertEquals(2100, HeadlessWebViewSize.toPhysicalPixels(800.0, 2.625, 2400.0))
    // Density 1.0: logical and physical pixels coincide.
    assertEquals(600, HeadlessWebViewSize.toPhysicalPixels(600.0, 1.0, 1080.0))
  }

  @Test
  fun `MATCH_SCREEN applies the screen dimension and ignores the density`() {
    assertEquals(1080, HeadlessWebViewSize.toPhysicalPixels(-1.0, 2.625, 1080.0))
    assertEquals(2400, HeadlessWebViewSize.toPhysicalPixels(-1.0, 2.625, 2400.0))
    assertEquals(-1.0, HeadlessWebViewSize.MATCH_SCREEN, 0.0)
  }

  @Test
  fun `the requested size is remembered exactly, so a set-then-get round trip is lossless`() {
    // The whole point of the memo: 600.25 logical pixels cannot be an Int number of physical
    // pixels at any density, so anything derived from the layout params loses it.
    val requested = Size2D(600.25, 800.75)

    val resolved = HeadlessWebViewSize.resolveRequested(requested, 2.625, fullscreen)

    assertEquals(requested, resolved)
    // ... and what the old getSize would have answered instead, at the same density:
    val applied = HeadlessWebViewSize.toPhysicalPixels(600.25, 2.625, 1080.0)
    assertNotEquals(600.25, HeadlessWebViewSize.toLogicalPixels(applied, 2.625, 1080.0), 0.0)
  }

  @Test
  fun `a MATCH_SCREEN axis resolves to the screen size in logical pixels, not physical ones`() {
    // The second half of P0b.8: getSize answered 1080 for a screen 411.43 logical pixels wide,
    // a physical count in a field every other path fills with logical pixels.
    val resolved = HeadlessWebViewSize.resolveRequested(Size2D(-1.0, -1.0), 2.625, fullscreen)

    assertEquals(1080.0 / 2.625, resolved.width, 0.0)
    assertEquals(2400.0 / 2.625, resolved.height, 0.0)
    assertNotEquals(1080.0, resolved.width, 0.0)
  }

  @Test
  fun `MATCH_SCREEN resolves per axis, independently`() {
    // §37's bug was one axis reading the other's value; assert asymmetrically so a transposition
    // cannot pass.
    val widthOnly = HeadlessWebViewSize.resolveRequested(Size2D(-1.0, 800.0), 2.625, fullscreen)
    assertEquals(1080.0 / 2.625, widthOnly.width, 0.0)
    assertEquals(800.0, widthOnly.height, 0.0)

    val heightOnly = HeadlessWebViewSize.resolveRequested(Size2D(400.0, -1.0), 2.625, fullscreen)
    assertEquals(400.0, heightOnly.width, 0.0)
    assertEquals(2400.0 / 2.625, heightOnly.height, 0.0)
  }

  @Test
  fun `toLogicalPixels divides, and reports the layout constants as the screen size`() {
    assertEquals(600.0, HeadlessWebViewSize.toLogicalPixels(1575, 2.625, 1080.0), 0.0)
    // MATCH_PARENT (-1) and WRAP_CONTENT (-2) are not pixel counts. Dividing them would answer
    // -0.38 logical pixels; the screen dimension is the honest reading.
    assertEquals(1080.0 / 2.625, HeadlessWebViewSize.toLogicalPixels(-1, 2.625, 1080.0), 0.0)
    assertEquals(1080.0 / 2.625, HeadlessWebViewSize.toLogicalPixels(-2, 2.625, 1080.0), 0.0)
  }
}
