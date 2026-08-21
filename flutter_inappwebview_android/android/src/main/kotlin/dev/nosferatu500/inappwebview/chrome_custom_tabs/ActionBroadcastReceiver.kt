package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.browser.customtabs.CustomTabsIntent

class ActionBroadcastReceiver : BroadcastReceiver() {

  override fun onReceive(context: Context, intent: Intent) {
    val clickedId = intent.getIntExtra(CustomTabsIntent.EXTRA_REMOTEVIEWS_CLICKED_ID, -1)
    val url = intent.dataString ?: return

    val b = intent.extras ?: return
    val viewId = b.getString(KEY_ACTION_VIEW_ID)
    val managerId = b.getString(KEY_ACTION_MANAGER_ID) ?: return

    val chromeSafariBrowserManager = ChromeSafariBrowserManager.shared[managerId] ?: return
    val browser = chromeSafariBrowserManager.browsers[viewId] ?: return
    val channelDelegate = browser.channelDelegate ?: return

    if (clickedId == -1) {
      channelDelegate.onItemActionPerform(b.getInt(KEY_ACTION_ID), url, b.getString(KEY_URL_TITLE))
    } else {
      channelDelegate.onSecondaryItemActionPerform(
        browser.resources.getResourceName(clickedId), url
      )
    }
  }

  companion object {
    protected const val LOG_TAG = "ActionBroadcastReceiver"
    const val KEY_ACTION_ID = "dev.nosferatu500.inappwebview.ChromeCustomTabs.ACTION_ID"
    const val KEY_ACTION_VIEW_ID = "dev.nosferatu500.inappwebview.ChromeCustomTabs.ACTION_VIEW_ID"
    const val KEY_ACTION_MANAGER_ID =
      "dev.nosferatu500.inappwebview.ChromeCustomTabs.ACTION_MANAGER_ID"
    const val KEY_URL_TITLE = "android.intent.extra.SUBJECT"
  }
}
