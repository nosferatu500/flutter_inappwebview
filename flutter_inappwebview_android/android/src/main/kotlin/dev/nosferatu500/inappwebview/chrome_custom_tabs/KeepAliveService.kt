package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

/**
 * Empty service used by the custom tab to bind to, raising the application's importance.
 */
class KeepAliveService : Service() {
  override fun onBind(intent: Intent): IBinder = sBinder

  companion object {
    private val sBinder = Binder()
  }
}
