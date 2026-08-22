package dev.nosferatu500.inappwebview.in_app_browser

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.webkit.WebView
import android.widget.ProgressBar
import android.widget.RelativeLayout
import android.widget.SearchView
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.view.menu.MenuBuilder
import androidx.appcompat.widget.Toolbar
import androidx.core.os.BundleCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import dev.nosferatu500.inappwebview.R
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.find_interaction.FindInteractionController
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshChannelDelegate
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshLayout
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshSettings
import dev.nosferatu500.inappwebview.types.AndroidResource
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.InAppBrowserMenuItem
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserScript
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebView
import dev.nosferatu500.inappwebview.webview.in_app_webview.InAppWebViewSettings
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class InAppBrowserActivity : AppCompatActivity(), InAppBrowserDelegate, Disposable {

  @JvmField var windowId: Int? = null
  @JvmField var id: String? = null
  @JvmField var webView: InAppWebView? = null
  @JvmField var pullToRefreshLayout: PullToRefreshLayout? = null
  @JvmField var actionBar: ActionBar? = null
  @JvmField var toolbar: Toolbar? = null
  @JvmField var menu: Menu? = null
  @JvmField var searchView: SearchView? = null
  @JvmField var customSettings = InAppBrowserSettings()
  @JvmField var progressBar: ProgressBar? = null
  @JvmField var isHidden = false
  @JvmField var fromActivity: String? = null

  private val activityResultListeners: MutableList<ActivityResultListener> = ArrayList()

  @JvmField var manager: InAppBrowserManager? = null
  @JvmField var channelDelegate: InAppBrowserChannelDelegate? = null
  @JvmField var menuItems: MutableList<InAppBrowserMenuItem> = ArrayList()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val b = intent.extras
    if (b == null) {
      if (savedInstanceState != null) {
        finish()
      }
      return
    }

    val viewId = b.getString("id")
    id = viewId

    val managerId = b.getString("managerId")
    val currentManager = InAppBrowserManager.shared[managerId]
    manager = currentManager
    val plugin = currentManager?.plugin
    if (currentManager == null || plugin == null) {
      if (savedInstanceState != null) {
        finish()
      }
      return
    }

    val settingsMap =
      BundleCompat.getSerializable(b, "settings", HashMap::class.java) as Map<String, Any?>
    customSettings.parse(settingsMap)

    val currentWindowId = b.getInt("windowId")
    windowId = currentWindowId

    setContentView(R.layout.activity_web_view)

    WindowCompat.setDecorFitsSystemWindows(window, false)
    val currentToolbar = findViewById<Toolbar>(R.id.toolbar)
    toolbar = currentToolbar
    setSupportActionBar(currentToolbar)

    ViewCompat.setOnApplyWindowInsetsListener(currentToolbar) { v, insets ->
      val systemBars = insets.getInsets(WindowInsetsCompat.Type.statusBars())
      v.setPadding(v.paddingLeft, systemBars.top, v.paddingRight, v.paddingBottom)
      insets
    }

    val pullToRefreshInitialSettings = BundleCompat.getSerializable(
      b, "pullToRefreshInitialSettings", HashMap::class.java
    ) as Map<String, Any?>
    val pullToRefreshLayoutChannel = MethodChannel(
      plugin.messenger, PullToRefreshLayout.METHOD_CHANNEL_NAME_PREFIX + viewId
    )
    val pullToRefreshSettings = PullToRefreshSettings()
    pullToRefreshSettings.parse(pullToRefreshInitialSettings)
    val currentPullToRefreshLayout = findViewById<PullToRefreshLayout>(R.id.pullToRefresh)
    pullToRefreshLayout = currentPullToRefreshLayout
    currentPullToRefreshLayout.channelDelegate =
      PullToRefreshChannelDelegate(currentPullToRefreshLayout, pullToRefreshLayoutChannel)
    currentPullToRefreshLayout.settings = pullToRefreshSettings
    currentPullToRefreshLayout.prepare()

    val currentWebView = findViewById<InAppWebView>(R.id.webView)
    webView = currentWebView
    currentWebView.id = viewId
    if (currentWindowId != -1) {
      currentWebView.windowId = currentWindowId
    }
    currentWebView.inAppBrowserDelegate = this
    currentWebView.plugin = plugin

    val findInteractionController =
      FindInteractionController(currentWebView, plugin, viewId!!, null)
    currentWebView.findInteractionController = findInteractionController
    findInteractionController.prepare()

    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + viewId)
    channelDelegate = InAppBrowserChannelDelegate(channel)
    currentWebView.channelDelegate = WebViewChannelDelegate(currentWebView, channel)

    fromActivity = b.getString("fromActivity")

    val contextMenu =
      BundleCompat.getSerializable(b, "contextMenu", HashMap::class.java) as Map<String, Any?>?
    val initialUserScripts = BundleCompat.getSerializable(
      b, "initialUserScripts", ArrayList::class.java
    ) as List<Map<String, Any?>>?
    val menuItemList = BundleCompat.getSerializable(
      b, "menuItems", ArrayList::class.java
    ) as List<Map<String, Any?>>
    for (menuItem in menuItemList) {
      InAppBrowserMenuItem.fromMap(menuItem)?.let { menuItems.add(it) }
    }

    val webViewSettings = InAppWebViewSettings()
    webViewSettings.parse(settingsMap)
    currentWebView.customSettings = webViewSettings
    currentWebView.contextMenu = contextMenu

    // Must precede prepareView(), which calls prepare(): setProfile throws once the WebView has
    // had JavaScript evaluated on it. windowId is already assigned above, so the window case is
    // correctly skipped inside applyProfileName().
    currentWebView.applyProfileName()

    val userScripts = mutableListOf<UserScript>()
    if (initialUserScripts != null) {
      for (initialUserScript in initialUserScripts) {
        UserScript.fromMap(initialUserScript)?.let { userScripts.add(it) }
      }
    }
    currentWebView.userContentController.addUserOnlyScripts(userScripts)

    actionBar = getSupportActionBar()

    prepareView()

    if (currentWindowId != -1) {
      val resultMsg =
        currentWebView.plugin?.inAppWebViewManager?.windowWebViewMessages?.get(currentWindowId)
      if (resultMsg != null) {
        (resultMsg.obj as WebView.WebViewTransport).webView = currentWebView
        resultMsg.sendToTarget()
      }
    } else {
      val initialFile = b.getString("initialFile")
      val initialUrlRequest = BundleCompat.getSerializable(
        b, "initialUrlRequest", HashMap::class.java
      ) as Map<String, Any?>?
      val initialData = b.getString("initialData")
      if (initialFile != null) {
        try {
          currentWebView.loadFile(initialFile)
        } catch (e: IOException) {
          Log.e(LOG_TAG, "$initialFile asset file cannot be found!", e)
          return
        }
      } else if (initialData != null) {
        currentWebView.loadDataWithBaseURL(
          b.getString("initialBaseUrl"),
          initialData,
          b.getString("initialMimeType"),
          b.getString("initialEncoding"),
          b.getString("initialHistoryUrl")
        )
      } else if (initialUrlRequest != null) {
        URLRequest.fromMap(initialUrlRequest)?.let { currentWebView.loadUrl(it) }
      }
    }

    channelDelegate?.onBrowserCreated()
  }

  private fun prepareView() {
    webView?.prepare()

    if (customSettings.hidden) {
      hide()
    } else {
      show()
    }

    val currentProgressBar = findViewById<ProgressBar>(R.id.progressBar)
    progressBar = currentProgressBar

    if (currentProgressBar != null) {
      currentProgressBar.max = if (customSettings.hideProgressBar) 0 else 100
    }

    actionBar?.let { bar ->
      bar.setDisplayShowTitleEnabled(!customSettings.hideTitleBar)

      if (customSettings.hideToolbarTop) {
        bar.hide()
      }

      customSettings.toolbarTopBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
        bar.setBackgroundDrawable(ColorDrawable(Color.parseColor(it)))
      }

      customSettings.toolbarTopFixedTitle?.takeIf { it.isNotEmpty() }?.let { bar.title = it }
    }
  }

  @SuppressLint("RestrictedApi")
  override fun onCreateOptionsMenu(m: Menu): Boolean {
    menu = m

    if (actionBar != null && customSettings.toolbarTopFixedTitle.isNullOrEmpty()) {
      actionBar?.title = webView?.title ?: ""
    }

    if (m is MenuBuilder) {
      m.setOptionalIconsVisible(true)
    }

    try {
      // Inflate menu to add items to action bar if it is present.
      menuInflater.inflate(R.menu.menu_main, m)
    } catch (e: Exception) {
      e.printStackTrace()
      Log.e(
        LOG_TAG,
        "Cannot inflate dev.nosferatu500.inappwebview.R.menu.menu_main." +
          "To make it work, you need to set minifyEnabled false and shrinkResources false in " +
          "your build.gradle file."
      )
      return super.onCreateOptionsMenu(m)
    }

    val menuSearchItem = m.findItem(R.id.menu_search)
    if (menuSearchItem != null) {
      if (customSettings.hideUrlBar) {
        menuSearchItem.isVisible = false
      }

      val currentSearchView = menuSearchItem.actionView as SearchView?
      searchView = currentSearchView
      if (currentSearchView != null) {
        currentSearchView.isFocusable = true

        currentSearchView.setQuery(webView?.url ?: "", false)

        currentSearchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
          override fun onQueryTextSubmit(query: String): Boolean {
            if (query.isNotEmpty()) {
              webView?.loadUrl(query)
              searchView?.let {
                it.setQuery("", false)
                it.isIconified = true
              }
              return true
            }
            return false
          }

          override fun onQueryTextChange(newText: String): Boolean = false
        })

        currentSearchView.setOnCloseListener {
          val sv = searchView
          if (sv != null && sv.query.toString().isEmpty()) {
            sv.setQuery(webView?.url ?: "", false)
          }
          false
        }

        currentSearchView.setOnQueryTextFocusChangeListener { _, hasFocus ->
          if (!hasFocus) {
            searchView?.let {
              it.setQuery("", false)
              it.isIconified = true
            }
          }
        }
      }
    }

    if (customSettings.hideDefaultMenuItems) {
      setDefaultMenuItemsVisible(m, false)
    }

    for (menuItem in menuItems) {
      val order = menuItem.order ?: Menu.NONE
      val item = m.add(Menu.NONE, menuItem.id, order, menuItem.title)
      if (menuItem.isShowAsAction) {
        // Deliberate: these are menu items the embedding app explicitly declared for the
        // InAppBrowser toolbar. SHOW_AS_ACTION_IF_ROOM would silently move them into the overflow
        // menu on narrow screens, so an app that asked for a toolbar button would not get one.
        @Suppress("AlwaysShowAction")
        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      }
      val icon = menuItem.icon
      if (icon != null) {
        if (icon is AndroidResource) {
          item.setIcon(icon.getIdentifier(this))
        } else {
          item.icon = Util.drawableFromBytes(this, icon as ByteArray)
        }
        menuItem.iconColor?.takeIf { it.isNotEmpty() }?.let {
          item.icon?.setTint(Color.parseColor(it))
        }
      }
      item.setOnMenuItemClickListener {
        channelDelegate?.onMenuItemClicked(menuItem)
        true
      }
    }

    return true
  }

  private fun setDefaultMenuItemsVisible(m: Menu, visible: Boolean) {
    for (itemId in DEFAULT_MENU_ITEM_IDS) {
      m.findItem(itemId)?.isVisible = visible
    }
  }

  override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
    if (keyCode == KeyEvent.KEYCODE_BACK) {
      if (customSettings.shouldCloseOnBackButtonPressed) {
        close(null)
        return true
      }
      if (customSettings.allowGoBackWithBackButton) {
        if (canGoBack()) {
          goBack()
        } else if (customSettings.closeOnCannotGoBack) {
          close(null)
        }
        return true
      }
      if (!customSettings.shouldCloseOnBackButtonPressed) {
        return true
      }
    }
    return super.onKeyDown(keyCode, event)
  }

  fun close(result: MethodChannel.Result?) {
    channelDelegate?.onExit()

    dispose()

    result?.success(true)
  }

  fun reload() {
    webView?.reload()
  }

  fun goBack() {
    if (canGoBack()) {
      webView?.goBack()
    }
  }

  fun canGoBack(): Boolean = webView?.canGoBack() ?: false

  fun goForward() {
    if (canGoForward()) {
      webView?.goForward()
    }
  }

  fun canGoForward(): Boolean = webView?.canGoForward() ?: false

  fun hide() {
    val from = fromActivity ?: return
    try {
      isHidden = true
      val openActivity = Intent(this, Class.forName(from))
      openActivity.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
      startActivityIfNeeded(openActivity, 0)
    } catch (e: ClassNotFoundException) {
      Log.d(LOG_TAG, "", e)
    }
  }

  fun show() {
    isHidden = false
    val openActivity = Intent(this, InAppBrowserActivity::class.java)
    openActivity.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
    startActivityIfNeeded(openActivity, 0)
  }

  // Referenced from menu_main.xml via android:onClick, so the (MenuItem) signature is load-bearing.
  fun goBackButtonClicked(item: MenuItem) {
    goBack()
  }

  fun goForwardButtonClicked(item: MenuItem) {
    goForward()
  }

  fun shareButtonClicked(item: MenuItem) {
    val share = Intent(Intent.ACTION_SEND)
    share.type = "text/plain"
    share.putExtra(Intent.EXTRA_TEXT, webView?.url ?: "")
    startActivity(Intent.createChooser(share, "Share"))
  }

  fun reloadButtonClicked(item: MenuItem) {
    reload()
  }

  fun closeButtonClicked(item: MenuItem) {
    close(null)
  }

  fun setSettings(newSettings: InAppBrowserSettings, newSettingsMap: HashMap<String, Any?>) {
    val newInAppWebViewSettings = InAppWebViewSettings()
    newInAppWebViewSettings.parse(newSettingsMap)
    webView?.setSettings(newInAppWebViewSettings, newSettingsMap)

    if (newSettingsMap["hidden"] != null && customSettings.hidden != newSettings.hidden) {
      if (newSettings.hidden) hide() else show()
    }

    val bar = actionBar
    val currentProgressBar = progressBar

    if (newSettingsMap["hideProgressBar"] != null &&
      customSettings.hideProgressBar != newSettings.hideProgressBar && currentProgressBar != null
    ) {
      currentProgressBar.max = if (newSettings.hideProgressBar) 0 else 100
    }

    if (bar != null && newSettingsMap["hideTitleBar"] != null &&
      customSettings.hideTitleBar != newSettings.hideTitleBar
    ) {
      bar.setDisplayShowTitleEnabled(!newSettings.hideTitleBar)
    }

    if (bar != null && newSettingsMap["hideToolbarTop"] != null &&
      customSettings.hideToolbarTop != newSettings.hideToolbarTop
    ) {
      if (newSettings.hideToolbarTop) bar.hide() else bar.show()
    }

    if (bar != null && newSettingsMap["toolbarTopBackgroundColor"] != null &&
      !Util.objEquals(
        customSettings.toolbarTopBackgroundColor, newSettings.toolbarTopBackgroundColor
      ) && !newSettings.toolbarTopBackgroundColor.isNullOrEmpty()
    ) {
      bar.setBackgroundDrawable(
        ColorDrawable(Color.parseColor(newSettings.toolbarTopBackgroundColor))
      )
    }

    if (bar != null && newSettingsMap["toolbarTopFixedTitle"] != null &&
      !Util.objEquals(customSettings.toolbarTopFixedTitle, newSettings.toolbarTopFixedTitle) &&
      !newSettings.toolbarTopFixedTitle.isNullOrEmpty()
    ) {
      bar.title = newSettings.toolbarTopFixedTitle
    }

    val currentMenu = menu

    if (currentMenu != null && newSettingsMap["hideUrlBar"] != null &&
      customSettings.hideUrlBar != newSettings.hideUrlBar
    ) {
      currentMenu.findItem(R.id.menu_search)?.isVisible = !newSettings.hideUrlBar
    }

    if (currentMenu != null && newSettingsMap["hideDefaultMenuItems"] != null &&
      customSettings.hideDefaultMenuItems != newSettings.hideDefaultMenuItems
    ) {
      setDefaultMenuItemsVisible(currentMenu, !newSettings.hideDefaultMenuItems)
    }

    customSettings = newSettings
  }

  fun getCustomSettingsMap(): Map<String, Any?>? {
    val webViewSettingsMap = webView?.getCustomSettingsMap() ?: return null

    val settingsMap = customSettings.getRealSettings(this)
    settingsMap.putAll(webViewSettingsMap)
    return settingsMap
  }

  override fun getActivity(): Activity = this

  override fun didChangeTitle(title: String?) {
    if (actionBar != null && customSettings.toolbarTopFixedTitle.isNullOrEmpty()) {
      actionBar?.title = title
    }
  }

  override fun didStartNavigation(url: String?) {
    progressBar?.progress = 0
    searchView?.setQuery(url, false)
  }

  override fun didUpdateVisitedHistory(url: String?) {
    searchView?.setQuery(url, false)
  }

  override fun didFinishNavigation(url: String?) {
    searchView?.setQuery(url, false)
    progressBar?.progress = 0
  }

  override fun didFailNavigation(url: String?, errorCode: Int, description: String?) {
    progressBar?.progress = 0
  }

  override fun didChangeProgress(progress: Int) {
    progressBar?.let { bar ->
      bar.visibility = View.VISIBLE
      bar.setProgress(progress, true)

      if (progress == 100) {
        bar.visibility = View.GONE
      }
    }
  }

  override fun getActivityResultListeners(): MutableList<ActivityResultListener> =
    activityResultListeners

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    for (listener in activityResultListeners) {
      if (listener.onActivityResult(requestCode, resultCode, data)) {
        return
      }
    }
    super.onActivityResult(requestCode, resultCode, data)
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    activityResultListeners.clear()
    val currentWebView = webView
    if (currentWebView != null) {
      val binding = manager?.plugin?.activityPluginBinding
      val chromeClient = currentWebView.inAppWebViewChromeClient
      if (binding != null && chromeClient != null) {
        binding.removeActivityResultListener(chromeClient)
      }
      findViewById<RelativeLayout>(R.id.container)?.removeAllViews()
      currentWebView.dispose()
      webView = null
      finish()
    }
  }

  override fun onDestroy() {
    dispose()
    super.onDestroy()
  }

  companion object {
    protected const val LOG_TAG = "InAppBrowserActivity"
    const val METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappbrowser_"

    private val DEFAULT_MENU_ITEM_IDS = intArrayOf(
      R.id.action_close,
      R.id.action_go_back,
      R.id.action_reload,
      R.id.action_go_forward,
      R.id.action_share
    )
  }
}
