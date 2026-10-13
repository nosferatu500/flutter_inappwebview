package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Browser
import androidx.browser.customtabs.CustomTabsCallback
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.customtabs.CustomTabsServiceConnection
import androidx.browser.customtabs.CustomTabsSession
import androidx.browser.trusted.TrustedWebActivityIntent

/**
 * This is a helper class to manage the connection to the Custom Tabs Service.
 */
class CustomTabActivityHelper : ServiceConnectionCallback {
  private var mCustomTabsSession: CustomTabsSession? = null
  private var mClient: CustomTabsClient? = null
  private var mConnection: CustomTabsServiceConnection? = null
  private var mConnectionCallback: ConnectionCallback? = null
  private var mCustomTabsCallback: CustomTabsCallback? = null

  /**
   * Unbinds the Activity from the Custom Tabs Service.
   * @param activity the activity that is connected to the service.
   */
  fun unbindCustomTabsService(activity: Activity) {
    val connection = mConnection ?: return
    activity.unbindService(connection)
    mClient = null
    mCustomTabsSession = null
    mConnection = null
  }

  /**
   * Creates or retrieves an exiting CustomTabsSession.
   *
   * @return a CustomTabsSession.
   */
  fun getSession(): CustomTabsSession? {
    val client = mClient
    if (client == null) {
      mCustomTabsSession = null
    } else if (mCustomTabsSession == null) {
      mCustomTabsSession = client.newSession(mCustomTabsCallback)
    }
    return mCustomTabsSession
  }

  /**
   * Register a Callback to be called when connected or disconnected from the Custom Tabs Service.
   */
  fun setConnectionCallback(connectionCallback: ConnectionCallback?) {
    mConnectionCallback = connectionCallback
  }

  fun setCustomTabsCallback(customTabsCallback: CustomTabsCallback?) {
    mCustomTabsCallback = customTabsCallback
  }

  /**
   * Binds the Activity to the Custom Tabs Service.
   * @param activity the activity to be binded to the service.
   */
  fun bindCustomTabsService(activity: Activity): Boolean {
    if (mClient != null) return true

    val packageName = CustomTabsHelper.getPackageNameToUse(activity) ?: return false

    val connection = ServiceConnection(this)
    mConnection = connection
    return CustomTabsClient.bindCustomTabsService(activity, packageName, connection)
  }

  /**
   * @see CustomTabsSession.mayLaunchUrl
   * @return true if call to mayLaunchUrl was accepted.
   */
  fun mayLaunchUrl(uri: Uri?, extras: Bundle?, otherLikelyBundles: List<Bundle>?): Boolean {
    if (mClient == null) return false
    val session = getSession() ?: return false
    return session.mayLaunchUrl(uri, extras, otherLikelyBundles)
  }

  override fun onServiceConnected(client: CustomTabsClient) {
    mClient = client
    client.warmup(0L)
    mConnectionCallback?.onCustomTabsConnected()
  }

  override fun onServiceDisconnected() {
    mClient = null
    mCustomTabsSession = null
    mConnectionCallback?.onCustomTabsDisconnected()
  }

  /**
   * A Callback for when the service is connected or disconnected. Use those callbacks to
   * handle UI changes when the service is connected or disconnected.
   */
  interface ConnectionCallback {
    /**
     * Called when the service is connected.
     */
    fun onCustomTabsConnected()

    /**
     * Called when the service is disconnected.
     */
    fun onCustomTabsDisconnected()
  }

  companion object {
    /**
     * Opens the URL on a Custom Tab if possible.
     *
     * @param activity The host activity.
     * @param intent a intent to be used if Custom Tabs is available.
     * @param uri the Uri to be opened.
     */
    @JvmStatic
    fun openCustomTab(
      activity: Activity,
      intent: Intent,
      uri: Uri,
      headers: Map<String, String>?,
      referrer: Uri?,
      requestCode: Int
    ) {
      intent.data = uri
      if (headers != null) {
        val bundleHeaders = Bundle()
        for ((name, value) in headers) {
          bundleHeaders.putString(name, value)
        }
        intent.putExtra(Browser.EXTRA_HEADERS, bundleHeaders)
      }
      if (referrer != null) {
        intent.putExtra(Intent.EXTRA_REFERRER, referrer)
      }
      activity.startActivityForResult(intent, requestCode)
    }

    @JvmStatic
    fun openCustomTab(
      activity: Activity,
      customTabsIntent: CustomTabsIntent,
      uri: Uri,
      headers: Map<String, String>?,
      referrer: Uri?,
      requestCode: Int
    ) = openCustomTab(activity, customTabsIntent.intent, uri, headers, referrer, requestCode)

    @JvmStatic
    fun openTrustedWebActivity(
      activity: Activity,
      trustedWebActivityIntent: TrustedWebActivityIntent,
      uri: Uri,
      headers: Map<String, String>?,
      referrer: Uri?,
      requestCode: Int
    ) = openCustomTab(
      activity, trustedWebActivityIntent.intent, uri, headers, referrer, requestCode
    )

    @JvmStatic
    fun isAvailable(activity: Activity): Boolean =
      CustomTabsHelper.getPackageNameToUse(activity) != null
  }
}
