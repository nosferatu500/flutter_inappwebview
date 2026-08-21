package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import androidx.annotation.CallSuper
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsCallback
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.customtabs.CustomTabsService
import androidx.browser.customtabs.CustomTabsSession
import androidx.browser.customtabs.EngagementSignalsCallback
import androidx.core.os.BundleCompat
import dev.nosferatu500.inappwebview.R
import dev.nosferatu500.inappwebview.types.CustomTabsActionButton
import dev.nosferatu500.inappwebview.types.CustomTabsMenuItem
import dev.nosferatu500.inappwebview.types.CustomTabsSecondaryToolbar
import dev.nosferatu500.inappwebview.types.Disposable
import io.flutter.plugin.common.MethodChannel

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
open class ChromeCustomTabsActivity : Activity(), Disposable {

  @JvmField var id: String? = null
  @JvmField var builder: CustomTabsIntent.Builder? = null
  @JvmField var customSettings = ChromeCustomTabsSettings()
  @JvmField var customTabActivityHelper = CustomTabActivityHelper()
  @JvmField var customTabsSession: CustomTabsSession? = null

  protected var onOpened = false
  protected var onCompletedInitialLoad = false
  protected var isBindSuccess = false

  @JvmField var manager: ChromeSafariBrowserManager? = null
  @JvmField var initialUrl: String? = null
  @JvmField var initialOtherLikelyURLs: List<String>? = null
  @JvmField var initialHeaders: Map<String, String>? = null
  @JvmField var initialReferrer: String? = null
  @JvmField var menuItems: MutableList<CustomTabsMenuItem> = ArrayList()
  @JvmField var actionButton: CustomTabsActionButton? = null
  @JvmField var secondaryToolbar: CustomTabsSecondaryToolbar? = null
  @JvmField var channelDelegate: ChromeCustomTabsChannelDelegate? = null

  @CallSuper
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    setContentView(R.layout.chrome_custom_tabs_layout)

    val b = intent.extras
    if (b == null) {
      if (savedInstanceState != null) {
        close()
      }
      return
    }

    val viewId = b.getString("id")
    id = viewId

    val managerId = b.getString("managerId")
    val currentManager = ChromeSafariBrowserManager.shared[managerId]
    manager = currentManager
    val plugin = currentManager?.plugin
    if (currentManager == null || plugin == null || viewId == null) {
      if (savedInstanceState != null) {
        close()
      }
      return
    }

    currentManager.browsers[viewId] = this

    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + viewId)
    channelDelegate = ChromeCustomTabsChannelDelegate(this, channel)

    initialUrl = b.getString("url")
    initialHeaders =
      BundleCompat.getSerializable(b, "headers", HashMap::class.java) as Map<String, String>?
    initialReferrer = b.getString("referrer")
    initialOtherLikelyURLs = b.getStringArrayList("otherLikelyURLs")

    customSettings = ChromeCustomTabsSettings()
    customSettings.parse(
      BundleCompat.getSerializable(b, "settings", HashMap::class.java) as Map<String, Any?>
    )
    actionButton = CustomTabsActionButton.fromMap(
      BundleCompat.getSerializable(b, "actionButton", HashMap::class.java) as Map<String, Any?>?
    )
    secondaryToolbar = CustomTabsSecondaryToolbar.fromMap(
      BundleCompat.getSerializable(b, "secondaryToolbar", HashMap::class.java)
        as Map<String, Any?>?
    )
    val menuItemList = BundleCompat.getSerializable(b, "menuItemList", ArrayList::class.java)
      as List<Map<String, Any?>>
    for (menuItem in menuItemList) {
      CustomTabsMenuItem.fromMap(menuItem)?.let { menuItems.add(it) }
    }

    if (customSettings.noHistory) {
      plugin.noHistoryCustomTabsActivityCallbacks?.noHistoryBrowserIDs?.put(viewId, viewId)
    }

    customTabActivityHelper.setConnectionCallback(
      object : CustomTabActivityHelper.ConnectionCallback {
        override fun onCustomTabsConnected() {
          customTabsConnected()
          channelDelegate?.onServiceConnected()
        }

        override fun onCustomTabsDisconnected() {
          close()
          dispose()
        }
      }
    )

    customTabActivityHelper.setCustomTabsCallback(object : CustomTabsCallback() {
      override fun onNavigationEvent(navigationEvent: Int, extras: Bundle?) {
        if (navigationEvent == TAB_SHOWN && !onOpened) {
          onOpened = true
          channelDelegate?.onOpened()
        }

        if (navigationEvent == NAVIGATION_FINISHED && !onCompletedInitialLoad) {
          onCompletedInitialLoad = true
          channelDelegate?.onCompletedInitialLoad()
        }

        channelDelegate?.onNavigationEvent(navigationEvent)
      }

      override fun extraCallback(callbackName: String, args: Bundle?) {
      }

      override fun onMessageChannelReady(extras: Bundle?) {
        channelDelegate?.onMessageChannelReady()
      }

      override fun onPostMessage(message: String, extras: Bundle?) {
        channelDelegate?.onPostMessage(message)
      }

      override fun onRelationshipValidationResult(
        @CustomTabsService.Relation relation: Int,
        requestedOrigin: Uri,
        result: Boolean,
        extras: Bundle?
      ) {
        channelDelegate?.onRelationshipValidationResult(relation, requestedOrigin, result)
      }
    })
  }

  open fun launchUrl(
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ) {
    launchUrlWithSession(customTabsSession, url, headers, referrer, otherLikelyURLs)
  }

  fun launchUrlWithSession(
    session: CustomTabsSession?,
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ) {
    mayLaunchUrl(url, otherLikelyURLs)
    val intentBuilder = CustomTabsIntent.Builder(session)
    builder = intentBuilder
    prepareCustomTabs(intentBuilder)

    val customTabsIntent = intentBuilder.build()
    prepareCustomTabsIntent(customTabsIntent)

    CustomTabActivityHelper.openCustomTab(
      this, customTabsIntent, Uri.parse(url), headers,
      referrer?.let { Uri.parse(it) }, CHROME_CUSTOM_TAB_REQUEST_CODE
    )
  }

  fun mayLaunchUrl(url: String?, otherLikelyURLs: List<String>?): Boolean {
    val uri = url?.let { Uri.parse(it) }

    // NOTE: carried over from the Java verbatim -- the bundle built here is never added to the
    // list, so an empty list is always passed. Changing it would alter what is prefetched.
    val bundleOtherLikelyURLs = mutableListOf<Bundle>()
    if (otherLikelyURLs != null) {
      val bundleOtherLikelyURL = Bundle()
      for (otherLikelyURL in otherLikelyURLs) {
        bundleOtherLikelyURL.putString(CustomTabsService.KEY_URL, otherLikelyURL)
      }
    }
    return customTabActivityHelper.mayLaunchUrl(uri, null, bundleOtherLikelyURLs)
  }

  @CallSuper
  open fun customTabsConnected() {
    val session = customTabActivityHelper.getSession()
    customTabsSession = session

    if (session != null) {
      try {
        val bundle = Bundle()
        if (session.isEngagementSignalsApiAvailable(bundle)) {
          session.setEngagementSignalsCallback(
            object : EngagementSignalsCallback {
              override fun onVerticalScrollEvent(isDirectionUp: Boolean, extras: Bundle) {
                channelDelegate?.onVerticalScrollEvent(isDirectionUp)
              }

              override fun onGreatestScrollPercentageIncreased(
                scrollPercentage: Int,
                extras: Bundle
              ) {
                channelDelegate?.onGreatestScrollPercentageIncreased(scrollPercentage)
              }

              override fun onSessionEnded(didUserInteract: Boolean, extras: Bundle) {
                channelDelegate?.onSessionEnded(didUserInteract)
              }
            },
            bundle
          )
        }
      } catch (e: Throwable) {
        Log.d(LOG_TAG, "Custom Tabs Engagement Signals API not supported", e)
      }
    }

    // avoid webpage reopen if isBindSuccess is false: onServiceConnected->launchUrl
    val url = initialUrl
    if (isBindSuccess && url != null) {
      launchUrl(url, initialHeaders, initialReferrer, initialOtherLikelyURLs)
    }
  }

  private fun prepareCustomTabs(builder: CustomTabsIntent.Builder) {
    builder.setShareState(customSettings.shareState)

    val defaultColorSchemeBuilder = CustomTabColorSchemeParams.Builder()
    customSettings.toolbarBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setToolbarColor(Color.parseColor(it))
    }
    customSettings.navigationBarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarColor(Color.parseColor(it))
    }
    customSettings.navigationBarDividerColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarDividerColor(Color.parseColor(it))
    }
    customSettings.secondaryToolbarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setSecondaryToolbarColor(Color.parseColor(it))
    }
    builder.setDefaultColorSchemeParams(defaultColorSchemeBuilder.build())

    builder.setShowTitle(customSettings.showTitle)
    builder.setUrlBarHidingEnabled(customSettings.enableUrlBarHiding)
    builder.setInstantAppsEnabled(customSettings.instantAppsEnabled)
    if (customSettings.startAnimations.size == 2) {
      builder.setStartAnimations(
        this,
        customSettings.startAnimations[0].getIdentifier(this),
        customSettings.startAnimations[1].getIdentifier(this)
      )
    }
    if (customSettings.exitAnimations.size == 2) {
      builder.setExitAnimations(
        this,
        customSettings.exitAnimations[0].getIdentifier(this),
        customSettings.exitAnimations[1].getIdentifier(this)
      )
    }

    for (menuItem in menuItems) {
      builder.addMenuItem(menuItem.label, createPendingIntent(menuItem.id))
    }

    actionButton?.let { button ->
      val data = button.icon
      val bitmapOptions = BitmapFactory.Options()
      bitmapOptions.inMutable = true
      val bmp = BitmapFactory.decodeByteArray(data, 0, data.size, bitmapOptions)
      builder.setActionButton(
        bmp, button.description, createPendingIntent(button.id), button.isShouldTint
      )
    }

    secondaryToolbar?.let { toolbar ->
      val layout = toolbar.layout
      val remoteViews = RemoteViews(layout.defPackage, layout.getIdentifier(this))
      val clickableIDs = IntArray(toolbar.clickableIDs.size) {
        toolbar.clickableIDs[it].getIdentifier(this)
      }
      builder.setSecondaryToolbarViews(
        remoteViews, clickableIDs, getSecondaryToolbarOnClickPendingIntent()
      )
    }
  }

  fun getSecondaryToolbarOnClickPendingIntent(): PendingIntent {
    val broadcastIntent = Intent(this, ActionBroadcastReceiver::class.java)

    val extras = Bundle()
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_VIEW_ID, id)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_MANAGER_ID, manager?.id)
    broadcastIntent.putExtras(extras)

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      PendingIntent.getBroadcast(
        this, 0, broadcastIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      )
    } else {
      PendingIntent.getBroadcast(this, 0, broadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }
  }

  private fun prepareCustomTabsIntent(customTabsIntent: CustomTabsIntent) {
    val packageName = customSettings.packageName
    if (packageName != null) {
      customTabsIntent.intent.setPackage(packageName)
    } else {
      customTabsIntent.intent.setPackage(CustomTabsHelper.getPackageNameToUse(this))
    }

    if (customSettings.keepAliveEnabled) {
      CustomTabsHelper.addKeepAliveExtra(this, customTabsIntent.intent)
    }

    if (customSettings.alwaysUseBrowserUI) {
      CustomTabsIntent.setAlwaysUseBrowserUI(customTabsIntent.intent)
    }
  }

  fun updateActionButton(icon: ByteArray, description: String) {
    val session = customTabsSession ?: return
    val button = actionButton ?: return
    val bitmapOptions = BitmapFactory.Options()
    bitmapOptions.inMutable = true
    val bmp = BitmapFactory.decodeByteArray(icon, 0, icon.size, bitmapOptions)
    session.setActionButton(bmp, description)
    button.icon = icon
    button.description = description
  }

  fun updateSecondaryToolbar(secondaryToolbar: CustomTabsSecondaryToolbar?) {
    val session = customTabsSession ?: return
    val toolbar = secondaryToolbar ?: return
    val layout = toolbar.layout
    val remoteViews = RemoteViews(layout.defPackage, layout.getIdentifier(this))
    val clickableIDs = IntArray(toolbar.clickableIDs.size) {
      toolbar.clickableIDs[it].getIdentifier(this)
    }
    session.setSecondaryToolbarViews(
      remoteViews, clickableIDs, getSecondaryToolbarOnClickPendingIntent()
    )
    this.secondaryToolbar = toolbar
  }

  override fun onStart() {
    super.onStart()
    isBindSuccess = customTabActivityHelper.bindCustomTabsService(this)

    val url = initialUrl
    if (!isBindSuccess && url != null) {
      // chrome process not running, start tab directly
      launchUrlWithSession(null, url, initialHeaders, initialReferrer, initialOtherLikelyURLs)
    }
  }

  // public rather than protected: ChromeCustomTabsChannelDelegate calls these directly. Java's
  // protected also grants package access, Kotlin's does not.
  public override fun onStop() {
    super.onStop()
    customTabActivityHelper.unbindCustomTabsService(this)
    isBindSuccess = false
  }

  public override fun onDestroy() {
    super.onDestroy()
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == CHROME_CUSTOM_TAB_REQUEST_CODE) {
      close()
      dispose()
    }
  }

  private fun createPendingIntent(actionSourceId: Int): PendingIntent {
    val actionIntent = Intent(this, ActionBroadcastReceiver::class.java)

    val extras = Bundle()
    extras.putInt(ActionBroadcastReceiver.KEY_ACTION_ID, actionSourceId)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_VIEW_ID, id)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_MANAGER_ID, manager?.id)
    actionIntent.putExtras(extras)

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      PendingIntent.getBroadcast(
        this, actionSourceId, actionIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      )
    } else {
      PendingIntent.getBroadcast(
        this, actionSourceId, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT
      )
    }
  }

  override fun dispose() {
    onStop()
    onDestroy()
    channelDelegate?.dispose()
    channelDelegate = null
    val currentManager = manager
    val viewId = id
    if (currentManager != null && viewId != null && currentManager.browsers.containsKey(viewId)) {
      currentManager.browsers[viewId] = null
    }
    manager = null
  }

  fun close() {
    onStop()
    onDestroy()
    customTabsSession = null
    finish()
    channelDelegate?.onClosed()
  }

  companion object {
    protected const val LOG_TAG = "CustomTabsActivity"
    const val METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/chromesafaribrowser_"
    const val CHROME_CUSTOM_TAB_REQUEST_CODE = 100
    const val NO_HISTORY_CHROME_CUSTOM_TAB_REQUEST_CODE = 101
  }
}
