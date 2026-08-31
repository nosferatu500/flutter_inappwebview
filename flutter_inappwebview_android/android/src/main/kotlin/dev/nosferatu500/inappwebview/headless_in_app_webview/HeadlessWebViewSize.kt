package dev.nosferatu500.inappwebview.headless_in_app_webview

import dev.nosferatu500.inappwebview.types.Size2D
import kotlin.math.roundToInt

/**
 * The logical-pixel <-> physical-pixel arithmetic behind [HeadlessInAppWebView.setSize] and
 * [HeadlessInAppWebView.getSize].
 *
 * Deliberately free of every `android.*` type so it can be unit-tested: this module leaves
 * `returnDefaultValues` off, so a JVM unit test that reaches a framework class throws `Stub!`
 * (`DEPRECATION_CLEANUP.md` trap 23). Both callers pass the density and the screen size in.
 *
 * The Dart API is in logical pixels -- Flutter's own unit -- on both platforms. On iOS those are
 * UIKit points and no conversion happens at all; here a `View`'s layout params are `Int` physical
 * pixels, so the conversion is lossy in one direction and [HeadlessInAppWebView] has to remember
 * what was asked for to answer [HeadlessInAppWebView.getSize] exactly.
 */
internal object HeadlessWebViewSize {
  /** The value of a [Size2D] axis meaning "match the screen on this axis". */
  const val MATCH_SCREEN = -1.0

  /**
   * The physical pixel count to apply for one axis of a requested size.
   *
   * Rounds rather than truncates: a layout param is an `Int`, so 600.0 logical pixels at density
   * 2.4375 is either 1462 or 1463 px, and 1463 is the one within half a pixel of what was asked
   * for. Truncation is what made `Size(600, 800)` come back as `Size(599.795, 800)` on an AVD at
   * density 390 (`TODO.md` P0b.8).
   */
  fun toPhysicalPixels(logical: Double, scale: Double, fullscreenPixels: Double): Int =
    if (logical == MATCH_SCREEN) fullscreenPixels.roundToInt() else (logical * scale).roundToInt()

  /**
   * One axis of the size to report when the view's layout params are *not* the ones this plugin
   * applied -- i.e. when something outside [HeadlessInAppWebView] resized the view.
   *
   * `MATCH_PARENT` (-1) and `WRAP_CONTENT` (-2) are not pixel counts, so they are reported as the
   * screen dimension rather than divided into a small negative number. Unreachable through the
   * plugin's own code today: the one place that installs `MATCH_PARENT` is
   * [HeadlessInAppWebView.disposeAndGetFlutterWebView], which disposes the webview in the same
   * breath, after which `getSize` returns null.
   */
  fun toLogicalPixels(physical: Int, scale: Double, fullscreenPixels: Double): Double =
    if (physical < 0) fullscreenPixels / scale else physical / scale

  /**
   * The size to remember for a [HeadlessInAppWebView.getSize] that has to be exact: the requested
   * size, with each [MATCH_SCREEN] axis resolved to the logical size it was applied as.
   *
   * A `-1` axis has no requested value to echo back, so it resolves to what the screen actually
   * measures -- in logical pixels, the unit the API accepts. Reporting the *physical* pixel count
   * there was the second half of P0b.8: `Size(-1, -1)` on a density-420 device answered
   * `Size(1080, 2400)` for a screen 411.4 logical pixels wide.
   */
  fun resolveRequested(requested: Size2D, scale: Double, fullscreenPixels: Size2D): Size2D = Size2D(
    if (requested.width == MATCH_SCREEN) {
      fullscreenPixels.width / scale
    } else {
      requested.width
    },
    if (requested.height == MATCH_SCREEN) {
      fullscreenPixels.height / scale
    } else {
      requested.height
    }
  )
}
