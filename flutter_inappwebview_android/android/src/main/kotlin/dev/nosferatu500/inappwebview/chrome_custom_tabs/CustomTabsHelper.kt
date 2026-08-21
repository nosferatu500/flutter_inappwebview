package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.text.TextUtils
import android.util.Log
import androidx.browser.customtabs.CustomTabsService

/**
 * Helper class for Custom Tabs.
 */
object CustomTabsHelper {
  const val TAG = "CustomTabsHelper"
  const val STABLE_PACKAGE = "com.android.chrome"
  const val BETA_PACKAGE = "com.chrome.beta"
  const val DEV_PACKAGE = "com.chrome.dev"
  const val LOCAL_PACKAGE = "com.google.android.apps.chrome"
  const val EXTRA_CUSTOM_TABS_KEEP_ALIVE =
    "android.support.customtabs.extra.KEEP_ALIVE"

  private var sPackageNameToUse: String? = null

  @JvmStatic
  fun addKeepAliveExtra(context: Context, intent: Intent) {
    val keepAliveIntent = Intent().setClassName(
      context.packageName, KeepAliveService::class.java.canonicalName!!
    )
    intent.putExtra(EXTRA_CUSTOM_TABS_KEEP_ALIVE, keepAliveIntent)
  }

  /**
   * Goes through all apps that handle VIEW intents and have a warmup service. Picks
   * the one chosen by the user if there is one, otherwise makes a best effort to return a
   * valid package name.
   *
   * This is **not** threadsafe.
   *
   * @param context [Context] to use for accessing [PackageManager].
   * @return The package name recommended to use for connecting to custom tabs related components.
   */
  @JvmStatic
  fun getPackageNameToUse(context: Context): String? {
    sPackageNameToUse?.let { return it }

    val pm = context.packageManager
    // Get default VIEW intent handler.
    val activityIntent = Intent(Intent.ACTION_VIEW, Uri.parse("http://www.example.com"))
    activityIntent.addCategory(Intent.CATEGORY_BROWSABLE)
    val defaultViewHandlerPackageName =
      pm.resolveActivity(activityIntent, 0)?.activityInfo?.packageName

    // Get all apps that can handle VIEW intents.
    val flags = PackageManager.MATCH_ALL

    val resolvedActivityList = pm.queryIntentActivities(activityIntent, flags)
    val packagesSupportingCustomTabs = mutableListOf<String>()
    for (info in resolvedActivityList) {
      val serviceIntent = Intent()
      serviceIntent.action = CustomTabsService.ACTION_CUSTOM_TABS_CONNECTION
      serviceIntent.setPackage(info.activityInfo.packageName)
      if (pm.resolveService(serviceIntent, 0) != null) {
        packagesSupportingCustomTabs.add(info.activityInfo.packageName)
      }
    }

    // Now packagesSupportingCustomTabs contains all apps that can handle both VIEW intents
    // and service calls.
    sPackageNameToUse = when {
      packagesSupportingCustomTabs.isEmpty() -> null
      packagesSupportingCustomTabs.size == 1 -> packagesSupportingCustomTabs[0]
      !TextUtils.isEmpty(defaultViewHandlerPackageName) &&
        !hasSpecializedHandlerIntents(context, activityIntent) &&
        packagesSupportingCustomTabs.contains(defaultViewHandlerPackageName) ->
        defaultViewHandlerPackageName
      packagesSupportingCustomTabs.contains(STABLE_PACKAGE) -> STABLE_PACKAGE
      packagesSupportingCustomTabs.contains(BETA_PACKAGE) -> BETA_PACKAGE
      packagesSupportingCustomTabs.contains(DEV_PACKAGE) -> DEV_PACKAGE
      packagesSupportingCustomTabs.contains(LOCAL_PACKAGE) -> LOCAL_PACKAGE
      // Matches the Java: none of the branches assigned, so the field keeps its previous value.
      else -> sPackageNameToUse
    }
    return sPackageNameToUse
  }

  /**
   * Used to check whether there is a specialized handler for a given intent.
   * @param intent The intent to check with.
   * @return Whether there is a specialized handler for the given intent.
   */
  private fun hasSpecializedHandlerIntents(context: Context, intent: Intent): Boolean {
    try {
      val handlers = context.packageManager.queryIntentActivities(
        intent, PackageManager.GET_RESOLVED_FILTER
      )
      if (handlers.isEmpty()) {
        return false
      }
      for (resolveInfo in handlers) {
        val filter = resolveInfo.filter ?: continue
        if (filter.countDataAuthorities() == 0 || filter.countDataPaths() == 0) continue
        if (resolveInfo.activityInfo == null) continue
        return true
      }
    } catch (e: RuntimeException) {
      Log.e(TAG, "Runtime exception while getting specialized handlers")
    }
    return false
  }

  /**
   * @return All possible chrome package names that provide custom tabs feature.
   */
  @JvmStatic
  fun getPackages(): Array<String> =
    arrayOf("", STABLE_PACKAGE, BETA_PACKAGE, DEV_PACKAGE, LOCAL_PACKAGE)
}
