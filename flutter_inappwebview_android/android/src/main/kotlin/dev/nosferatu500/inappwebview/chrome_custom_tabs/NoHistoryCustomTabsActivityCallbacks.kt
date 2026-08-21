package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Activity
import android.app.Application
import android.os.Bundle
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.embedding.android.FlutterActivity

class NoHistoryCustomTabsActivityCallbacks(plugin: InAppWebViewFlutterPlugin) : Disposable {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  // Entries are nulled rather than removed, so the browser id stays known after it is closed.
  @JvmField
  val noHistoryBrowserIDs: MutableMap<String, String?> = HashMap()

  @JvmField
  var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks =
    object : Application.ActivityLifecycleCallbacks {
      override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

      override fun onActivityStarted(activity: Activity) {}

      override fun onActivityResumed(activity: Activity) {
        val manager = plugin?.chromeSafariBrowserManager
        if (activity is FlutterActivity && manager != null) {
          for (browserId in noHistoryBrowserIDs.values.toList()) {
            if (browserId != null) {
              noHistoryBrowserIDs[browserId] = null
              val browser = manager.browsers[browserId]
              if (browser != null) {
                browser.close()
                browser.dispose()
              }
            }
          }
        }
      }

      override fun onActivityPaused(activity: Activity) {}

      override fun onActivityStopped(activity: Activity) {}

      override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

      override fun onActivityDestroyed(activity: Activity) {}
    }

  override fun dispose() {
    noHistoryBrowserIDs.clear()
    plugin = null
  }
}
