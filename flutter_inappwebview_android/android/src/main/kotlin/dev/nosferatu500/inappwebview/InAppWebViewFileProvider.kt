package dev.nosferatu500.inappwebview

import androidx.core.content.FileProvider

/**
 * FileProvider used to hand a `content://` URI to the camera/camcorder app when a page uses
 * `<input type="file" capture>`. It is the plugin's only provider and its only caller is
 * `InAppWebViewChromeClient.getOutputUri()`.
 *
 * Consuming apps declare it themselves, because the authority has to be derived from their own
 * `applicationId`:
 *
 * ```xml
 * <provider
 *     android:name="dev.nosferatu500.inappwebview.InAppWebViewFileProvider"
 *     android:authorities="${applicationId}.dev.nosferatu500.inappwebview.fileprovider"
 *     android:exported="false"
 *     android:grantUriPermissions="true">
 *     <meta-data
 *         android:name="android.support.FILE_PROVIDER_PATHS"
 *         android:resource="@xml/inappwebview_provider_paths" />
 * </provider>
 * ```
 *
 * The paths resource ships with this module and is scoped to the app's own external files
 * directory -- see `res/xml/inappwebview_provider_paths.xml` for why. Point the `meta-data` at that
 * resource, not at a file of your own: substituting a wider one re-opens the grant this provider
 * deliberately does not make.
 *
 * **Breaking in 7.0.0:** the authority suffix was `flutter_inappwebview_android.fileprovider` in
 * 6.x. An app that keeps the old string gets no exception it can see: `getUriForFile` throws
 * `IllegalArgumentException`, `InAppWebViewChromeClient.getOutputUri()` logs it and returns null,
 * and `<input type="file" capture>` produces nothing at all. The whole `<provider>` block above
 * changed in this fork -- `android:name` and the `meta-data` resource too -- so copy it wholesale
 * rather than editing one line of the old one.
 */
class InAppWebViewFileProvider : FileProvider() {
  companion object {
    // Part of the FileProvider authority consuming apps declare in their own AndroidManifest:
    // `${applicationId}.` + this. Changing it is a breaking change for them and needs a migration
    // note, which is why it stayed on the old spelling through the rest of the package rename.
    const val fileProviderAuthorityExtension = "dev.nosferatu500.inappwebview.fileprovider"
  }
}
