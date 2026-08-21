package dev.nosferatu500.inappwebview

import androidx.core.content.FileProvider

class InAppWebViewFileProvider : FileProvider() {
  companion object {
    // Not renamed alongside the package: this suffix is part of the FileProvider authority that
    // consuming apps declare in their own AndroidManifest, so changing it would break them.
    const val fileProviderAuthorityExtension = "flutter_inappwebview_android.fileprovider"
  }
}
