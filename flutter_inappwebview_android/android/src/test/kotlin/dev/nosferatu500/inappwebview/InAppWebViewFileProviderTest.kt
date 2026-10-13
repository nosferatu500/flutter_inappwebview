package dev.nosferatu500.inappwebview

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

/**
 * [InAppWebViewFileProvider.fileProviderAuthorityExtension] is a **wire string**, in the same sense
 * as the channel names: consuming apps repeat it verbatim in their own `AndroidManifest.xml`, and
 * the plugin looks the provider up by `applicationId + "." + this`. The two sides are joined by
 * nothing but the spelling.
 *
 * Nothing else in this repo can see a change to it. There is no integration test -- reaching
 * `getOutputUri()` needs a page with `<input type="file" capture>`, a real file-chooser intent and a
 * camera, none of which `WidgetTester` can drive -- and a wrong authority does not fail the build,
 * fail lint, or throw where Dart can see it: `FileProvider.getUriForFile` throws
 * `IllegalArgumentException`, `InAppWebViewChromeClient` catches and logs it, and the capture
 * silently yields nothing (`TODO.md` P0b.4).
 */
class InAppWebViewFileProviderTest {

  @Test
  fun `the authority suffix is the one the documented manifest block declares`() {
    // Renamed in 7.0.0 from "flutter_inappwebview_android.fileprovider". Changing this string is a
    // breaking change for every consuming app: keep it in step with the KDoc snippet on
    // InAppWebViewFileProvider, the example app's AndroidManifest.xml and the migration note.
    assertEquals(
      "dev.nosferatu500.inappwebview.fileprovider",
      InAppWebViewFileProvider.fileProviderAuthorityExtension
    )
  }

  @Test
  fun `the suffix carries no upstream package name`() {
    // The point of the rename: no part of the authority may still say "flutter_inappwebview" or
    // "pichillilorenzo", so that this fork's provider cannot collide with upstream's in an app that
    // installs both.
    val suffix = InAppWebViewFileProvider.fileProviderAuthorityExtension

    assertFalse(suffix, suffix.contains("flutter_inappwebview"))
    assertFalse(suffix, suffix.contains("pichillilorenzo"))
  }

  @Test
  fun `the suffix is a valid authority segment sequence`() {
    // It is concatenated onto "${applicationId}." -- a leading or trailing dot, whitespace or an
    // empty label would produce an authority no provider can ever match.
    val suffix = InAppWebViewFileProvider.fileProviderAuthorityExtension

    assertFalse(suffix.startsWith("."))
    assertFalse(suffix.endsWith("."))
    assertFalse(suffix.contains(".."))
    assertEquals(suffix, suffix.trim())
    assertEquals(suffix, suffix.lowercase())
  }
}
