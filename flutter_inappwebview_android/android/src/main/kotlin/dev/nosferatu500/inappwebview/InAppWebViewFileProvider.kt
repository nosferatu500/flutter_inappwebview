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
 *     android:authorities="${applicationId}.flutter_inappwebview_android.fileprovider"
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
 */
class InAppWebViewFileProvider : FileProvider() {
  companion object {
    // Not renamed alongside the package: this suffix is part of the FileProvider authority that
    // consuming apps declare in their own AndroidManifest, so changing it would break them.
    const val fileProviderAuthorityExtension = "flutter_inappwebview_android.fileprovider"
  }
}
