package dev.nosferatu500.inappwebview.in_app_browser

import android.content.Intent

interface ActivityResultListener {
  /** @return true if the result has been handled. */
  fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean
}
