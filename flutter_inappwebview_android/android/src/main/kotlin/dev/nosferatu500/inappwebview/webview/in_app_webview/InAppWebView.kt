package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Point
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Parcel
import android.print.InAppWebViewPrintDocumentAdapter
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintManager
import android.text.TextUtils
import android.util.AttributeSet
import android.util.Log
import android.view.ActionMode
import android.view.ContextMenu
import android.view.GestureDetector
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.webkit.CookieManager
import android.webkit.DownloadListener
import android.webkit.URLUtil
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.webkit.PrerenderException
import androidx.webkit.PrerenderOperationCallback
import androidx.webkit.UserAgentMetadata
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import androidx.webkit.WebViewMediaIntegrityApiStatusConfig
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.R
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.content_blocker.ContentBlocker
import dev.nosferatu500.inappwebview.content_blocker.ContentBlockerAction
import dev.nosferatu500.inappwebview.content_blocker.ContentBlockerHandler
import dev.nosferatu500.inappwebview.content_blocker.ContentBlockerTrigger
import dev.nosferatu500.inappwebview.find_interaction.FindInteractionController
import dev.nosferatu500.inappwebview.in_app_browser.InAppBrowserDelegate
import dev.nosferatu500.inappwebview.plugin_scripts_js.InterceptAjaxRequestJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.InterceptFetchRequestJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.OnLoadResourceJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.OnWindowBlurEventJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.OnWindowFocusEventJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.PluginScriptsUtil
import dev.nosferatu500.inappwebview.plugin_scripts_js.PrintJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.PromisePolyfillJS
import dev.nosferatu500.inappwebview.print_job.PrintJobController
import dev.nosferatu500.inappwebview.print_job.PrintJobSettings
import dev.nosferatu500.inappwebview.pull_to_refresh.PullToRefreshLayout
import dev.nosferatu500.inappwebview.types.ContentWorld
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.DownloadStartRequest
import dev.nosferatu500.inappwebview.types.PluginScript
import dev.nosferatu500.inappwebview.types.PreferredContentModeOptionType
import dev.nosferatu500.inappwebview.types.URLRequest
import dev.nosferatu500.inappwebview.types.UserContentController
import dev.nosferatu500.inappwebview.types.UserScript
import dev.nosferatu500.inappwebview.types.WebViewAssetLoaderExt
import dev.nosferatu500.inappwebview.webview.ContextMenuSettings
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import dev.nosferatu500.inappwebview.webview.JavaScriptBridgeInterface
import dev.nosferatu500.inappwebview.webview.WebViewChannelDelegate
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageChannel
import dev.nosferatu500.inappwebview.webview.web_message.WebMessageListener
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executor

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class InAppWebView : WebView, InAppWebViewInterface, Disposable {

  @JvmField var plugin: InAppWebViewFlutterPlugin? = null
  @JvmField var inAppBrowserDelegate: InAppBrowserDelegate? = null

  /**
   * The FlutterView this WebView is displayed inside, or null under hybrid composition.
   *
   * Set by [FlutterWebView.onFlutterViewAttached]. Only used by the three workarounds below that
   * need the *Flutter* view's window token or focus state rather than this WebView's:
   * hiding the keyboard when a tap lands on something non-focusable, the Android 10 clipboard fix
   * in `onWindowStartingActionMode` (issue #678), and [hideInputMethod].
   *
   * This is all that survives of `InputAwareWebView`, which used to be this class's superclass and
   * carried a pre-Android-N hack for creating InputConnections on the WebView's IME thread. That
   * hack was dead code: it only ever ran below API 24 and this module's minSdk is 30.
   */
  @JvmField var containerView: View? = null

  fun setContainerView(containerView: View?) {
    this.containerView = containerView
  }

  // Shadows View's int id on purpose: this is the plugin-side view identifier (a String for
  // keep-alive views, an Int otherwise), not the Android resource id.
  @JvmField var id: Any? = null

  @JvmField var windowId: Int? = null
  @JvmField var inAppWebViewClient: InAppWebViewClient? = null
  @JvmField var inAppWebViewClientCompat: InAppWebViewClientCompat? = null
  @JvmField var inAppWebViewChromeClient: InAppWebViewChromeClient? = null
  @JvmField var inAppWebViewRenderProcessClient: InAppWebViewRenderProcessClient? = null
  @JvmField var channelDelegate: WebViewChannelDelegate? = null

  /**
   * Non-null only while a navigation listener is registered, i.e. only when
   * `useNavigationListener` is on and the feature is supported. Held so that `dispose()` can
   * unregister it — androidx keys removal on the listener instance.
   */
  private var inAppWebViewNavigationListener: InAppWebViewNavigationListener? = null
  @JvmField var javaScriptBridgeInterface: JavaScriptBridgeInterface? = null
  @JvmField var customSettings = InAppWebViewSettings()
  @JvmField var isLoading = false

  private var inFullscreen = false

  @JvmField var zoomScale = 1.0f
  @JvmField var contentBlockerHandler = ContentBlockerHandler()
  @JvmField var gestureDetector: GestureDetector? = null
  @JvmField var floatingContextMenu: LinearLayout? = null
  @JvmField var contextMenu: Map<String, Any?>? = null
  @JvmField var mainLooperHandler = Handler(getWebViewLooper())

  @JvmField var checkScrollStoppedTask: Runnable? = null
  @JvmField var initialPositionScrollStoppedTask = 0
  @JvmField var newCheckScrollStoppedTask = 100 // ms

  @JvmField var checkContextMenuShouldBeClosedTask: Runnable? = null
  @JvmField var newCheckContextMenuShouldBeClosedTaskTask = 100 // ms

  @JvmField var userContentController = UserContentController(this)

  @JvmField
  var callAsyncJavaScriptCallbacks: MutableMap<String, ValueCallback<String>> = HashMap()

  @JvmField
  var evaluateJavaScriptContentWorldCallbacks: MutableMap<String, ValueCallback<String>> = HashMap()

  @JvmField var webMessageChannels: MutableMap<String, WebMessageChannel> = HashMap()
  @JvmField var webMessageListeners: MutableList<WebMessageListener> = ArrayList()

  private var initialUserOnlyScripts: List<UserScript> = ArrayList()

  @JvmField var findInteractionController: FindInteractionController? = null
  @JvmField var webViewAssetLoaderExt: WebViewAssetLoaderExt? = null

  private var interceptOnlyAsyncAjaxRequestsPluginScript: PluginScript? = null

  private val expectedBridgeSecret = UUID.randomUUID().toString()
  private var javaScriptBridgeEnabled = true

  private var contextMenuPoint = Point(0, 0)
  private var lastTouch = Point(0, 0)

  constructor(context: Context) : super(context)

  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

  constructor(context: Context, attrs: AttributeSet?, defaultStyle: Int) :
    super(context, attrs, defaultStyle)

  constructor(
    context: Context,
    plugin: InAppWebViewFlutterPlugin,
    id: Any,
    windowId: Int?,
    customSettings: InAppWebViewSettings,
    contextMenu: Map<String, Any?>?,
    containerView: View?,
    userScripts: List<UserScript>
  ) : super(context) {
    this.containerView = containerView
    this.plugin = plugin
    this.id = id
    val channel = MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = WebViewChannelDelegate(this, channel)
    this.windowId = windowId
    this.customSettings = customSettings
    this.contextMenu = contextMenu
    initialUserOnlyScripts = userScripts
    plugin.activity?.registerForContextMenu(this)
  }

  fun createWebViewClient(inAppBrowserDelegate: InAppBrowserDelegate?): WebViewClient {
    // bug https://bugs.chromium.org/p/chromium/issues/detail?id=925887
    val packageInfo = WebViewCompat.getCurrentWebViewPackage(context)
    if (packageInfo == null) {
      Log.d(LOG_TAG, "Using InAppWebViewClient implementation")
      return InAppWebViewClient(inAppBrowserDelegate)
    }

    val isChromiumWebView = "com.android.webview" == packageInfo.packageName ||
      "com.google.android.webview" == packageInfo.packageName ||
      "com.android.chrome" == packageInfo.packageName
    var isChromiumWebViewBugFixed = false
    if (isChromiumWebView) {
      val versionName = packageInfo.versionName ?: ""
      try {
        val majorVersion =
          if (versionName.contains(".")) versionName.split("\\.".toRegex())[0].toInt() else 0
        isChromiumWebViewBugFixed = majorVersion >= 73
      } catch (ignored: NumberFormatException) {
      }
    }

    return if (isChromiumWebViewBugFixed || !isChromiumWebView) {
      Log.d(LOG_TAG, "Using InAppWebViewClientCompat implementation")
      InAppWebViewClientCompat(inAppBrowserDelegate)
    } else {
      Log.d(LOG_TAG, "Using InAppWebViewClient implementation")
      InAppWebViewClient(inAppBrowserDelegate)
    }
  }

  override fun setAlpha(alpha: Float) {
    val parent = parent
    if (parent is PullToRefreshLayout) {
      parent.alpha = alpha
    } else {
      super.setAlpha(alpha)
    }
  }

  /**
   * Puts this WebView on the profile named by [InAppWebViewSettings.profileName].
   *
   * Must run before [prepare], and before anything else touches this WebView: androidx's
   * `setProfile` throws once the WebView has navigated, had `evaluateJavascript` called on it, or
   * had its profile read or set already. [prepare] does the first two, so this is not a
   * "call it whenever" method -- the two creation paths (`FlutterWebView.init` and
   * `InAppBrowserActivity`) call it at the only point where it can succeed.
   */
  fun applyProfileName() {
    val name = customSettings.profileName ?: return
    if (windowId != null) {
      // This WebView is about to be handed to a WebViewTransport for a window another WebView
      // opened, so it inherits that opener's session. Setting a profile on it is not attempted.
      return
    }
    if (!WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
      return
    }
    try {
      WebViewCompat.setProfile(this, name)
    } catch (e: IllegalStateException) {
      // Reached only if this WebView was already used, i.e. if the call moved out of the creation
      // path. Logged rather than thrown: a profile that could not be applied leaves the WebView on
      // the default profile, which is the pre-feature behaviour.
      Log.e(LOG_TAG, "profileName \"$name\" could not be applied to this WebView", e)
    }
  }

  @SuppressLint("RestrictedApi")
  fun prepare() {
    customSettings.alpha?.let { setAlpha(it.toFloat()) }

    javaScriptBridgeEnabled = customSettings.javaScriptBridgeEnabled
    if (customSettings.javaScriptBridgeOriginAllowList?.isEmpty() == true) {
      // an empty list means that the JavaScript Bridge is not allowed for any origin.
      javaScriptBridgeEnabled = false
    }

    plugin?.let {
      webViewAssetLoaderExt =
        WebViewAssetLoaderExt.fromMap(customSettings.webViewAssetLoader, it, context)
    }

    if (javaScriptBridgeEnabled) {
      val bridge = JavaScriptBridgeInterface(this, expectedBridgeSecret)
      javaScriptBridgeInterface = bridge
      addJavascriptInterface(bridge, JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())
    }

    // plugin is @NonNull for the chrome client; prepare() is only ever called after the plugin
    // has been assigned (constructor, or InAppBrowserActivity before prepare()).
    val chromeClient = InAppWebViewChromeClient(plugin!!, this, inAppBrowserDelegate)
    inAppWebViewChromeClient = chromeClient
    webChromeClient = chromeClient

    val client = createWebViewClient(inAppBrowserDelegate)
    if (client is InAppWebViewClientCompat) {
      inAppWebViewClientCompat = client
      webViewClient = client
    } else if (client is InAppWebViewClient) {
      inAppWebViewClient = client
      webViewClient = client
    }

    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)) {
      val renderProcessClient = InAppWebViewRenderProcessClient()
      inAppWebViewRenderProcessClient = renderProcessClient
      WebViewCompat.setWebViewRenderProcessClient(this, renderProcessClient)
    }

    if (windowId == null ||
      !WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
    ) {
      // for some reason, if a WebView is created using a window id,
      // the initial plugin and user scripts injected
      // with WebViewCompat.addDocumentStartJavaScript will not be added!
      // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1455
      prepareAndAddUserScripts()
    }

    if (customSettings.useOnDownloadStart) {
      setDownloadListener(DownloadStartListener())
    }

    // Registered only when asked for: one listener carries every navigation callback, so a WebView
    // nobody is listening to should not pay a channel message per navigation phase. The feature
    // check is not optional — `addNavigationListener` throws `UnsupportedOperationException`
    // rather than degrading when the WebView provider is too old.
    if (customSettings.useNavigationListener &&
      WebViewFeature.isFeatureSupported(WebViewFeature.NAVIGATION_LISTENER)
    ) {
      val navigationListener = InAppWebViewNavigationListener(this)
      inAppWebViewNavigationListener = navigationListener
      WebViewCompat.addNavigationListener(this, navigationListener)
    }

    val settings = settings

    settings.javaScriptEnabled = customSettings.javaScriptEnabled
    settings.javaScriptCanOpenWindowsAutomatically =
      customSettings.javaScriptCanOpenWindowsAutomatically
    settings.builtInZoomControls = customSettings.builtInZoomControls
    settings.displayZoomControls = customSettings.displayZoomControls
    settings.setSupportMultipleWindows(customSettings.supportMultipleWindows)

    if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
      WebSettingsCompat.setSafeBrowsingEnabled(settings, customSettings.safeBrowsingEnabled)
    } else {
      settings.safeBrowsingEnabled = customSettings.safeBrowsingEnabled
    }

    settings.mediaPlaybackRequiresUserGesture = customSettings.mediaPlaybackRequiresUserGesture

    applyDatabaseEnabled(settings, customSettings.databaseEnabled)
    settings.domStorageEnabled = customSettings.domStorageEnabled

    if (customSettings.userAgent.isNotEmpty()) {
      settings.userAgentString = customSettings.userAgent
    } else {
      settings.userAgentString = WebSettings.getDefaultUserAgent(context)
    }

    if (customSettings.applicationNameForUserAgent.isNotEmpty()) {
      val userAgent = customSettings.userAgent.ifEmpty {
        WebSettings.getDefaultUserAgent(context)
      }
      settings.userAgentString = userAgent + " " + customSettings.applicationNameForUserAgent
    }

    CookieManager.getInstance()
      .setAcceptThirdPartyCookies(this, customSettings.thirdPartyCookiesEnabled)

    settings.loadWithOverviewMode = customSettings.loadWithOverviewMode
    settings.useWideViewPort = customSettings.useWideViewPort
    settings.setSupportZoom(customSettings.supportZoom)
    customSettings.textZoom?.let { settings.textZoom = it }

    isVerticalScrollBarEnabled =
      !customSettings.disableVerticalScroll && customSettings.verticalScrollBarEnabled
    isHorizontalScrollBarEnabled =
      !customSettings.disableHorizontalScroll && customSettings.horizontalScrollBarEnabled

    if (customSettings.transparentBackground) {
      setBackgroundColor(Color.TRANSPARENT)
    }

    customSettings.mixedContentMode?.let { settings.mixedContentMode = it }

    settings.allowContentAccess = customSettings.allowContentAccess
    settings.allowFileAccess = customSettings.allowFileAccess
    applyAllowFileAccessFromFileURLs(settings, customSettings.allowFileAccessFromFileURLs)
    applyAllowUniversalAccessFromFileURLs(
      settings, customSettings.allowUniversalAccessFromFileURLs
    )
    setCacheEnabled(customSettings.cacheEnabled)
    if (!customSettings.appCachePath.isNullOrEmpty() && customSettings.cacheEnabled) {
      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCachePath(customSettings.appCachePath);
      Util.invokeMethodIfExists(settings, "setAppCachePath", customSettings.appCachePath)
    }
    settings.blockNetworkImage = customSettings.blockNetworkImage
    settings.blockNetworkLoads = customSettings.blockNetworkLoads
    settings.cacheMode = customSettings.cacheMode
    settings.cursiveFontFamily = customSettings.cursiveFontFamily
    settings.defaultFixedFontSize = customSettings.defaultFixedFontSize
    settings.defaultFontSize = customSettings.defaultFontSize
    settings.defaultTextEncodingName = customSettings.defaultTextEncodingName
    customSettings.disabledActionModeMenuItems?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
        WebSettingsCompat.setDisabledActionModeMenuItems(settings, it)
      } else {
        settings.disabledActionModeMenuItems = it
      }
    }
    settings.fantasyFontFamily = customSettings.fantasyFontFamily
    settings.fixedFontFamily = customSettings.fixedFontFamily
    settings.setGeolocationEnabled(customSettings.geolocationEnabled)
    customSettings.layoutAlgorithm?.let { settings.layoutAlgorithm = it }
    settings.loadsImagesAutomatically = customSettings.loadsImagesAutomatically
    settings.minimumFontSize = customSettings.minimumFontSize
    settings.minimumLogicalFontSize = customSettings.minimumLogicalFontSize
    setInitialScale(customSettings.initialScale)
    settings.setNeedInitialFocus(customSettings.needInitialFocus)
    if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
      WebSettingsCompat.setOffscreenPreRaster(settings, customSettings.offscreenPreRaster)
    } else {
      settings.offscreenPreRaster = customSettings.offscreenPreRaster
    }
    settings.sansSerifFontFamily = customSettings.sansSerifFontFamily
    settings.serifFontFamily = customSettings.serifFontFamily
    settings.standardFontFamily = customSettings.standardFontFamily
    if (customSettings.preferredContentMode ==
      PreferredContentModeOptionType.DESKTOP.toValue()
    ) {
      setDesktopMode(true)
    }
    // WebSettings.setSaveFormData/setSavePassword have been no-ops since API 26
    // and API 18 respectively; form data is handled by the Autofill framework.
    if (customSettings.incognito) {
      setIncognito(true)
    }
    if (customSettings.useHybridComposition) {
      if (customSettings.hardwareAcceleration) {
        setLayerType(LAYER_TYPE_HARDWARE, null)
      } else {
        setLayerType(LAYER_TYPE_NONE, null)
      }
    }
    scrollBarStyle = customSettings.scrollBarStyle
    val delayBeforeFade = customSettings.scrollBarDefaultDelayBeforeFade
    if (delayBeforeFade != null) {
      scrollBarDefaultDelayBeforeFade = delayBeforeFade
    } else {
      customSettings.scrollBarDefaultDelayBeforeFade = scrollBarDefaultDelayBeforeFade
    }
    isScrollbarFadingEnabled = customSettings.scrollbarFadingEnabled
    val fadeDuration = customSettings.scrollBarFadeDuration
    if (fadeDuration != null) {
      scrollBarFadeDuration = fadeDuration
    } else {
      customSettings.scrollBarFadeDuration = scrollBarFadeDuration
    }
    verticalScrollbarPosition = customSettings.verticalScrollbarPosition

    customSettings.verticalScrollbarThumbColor?.let {
      verticalScrollbarThumbDrawable = ColorDrawable(Color.parseColor(it))
    }
    customSettings.verticalScrollbarTrackColor?.let {
      verticalScrollbarTrackDrawable = ColorDrawable(Color.parseColor(it))
    }
    customSettings.horizontalScrollbarThumbColor?.let {
      horizontalScrollbarThumbDrawable = ColorDrawable(Color.parseColor(it))
    }
    customSettings.horizontalScrollbarTrackColor?.let {
      horizontalScrollbarTrackDrawable = ColorDrawable(Color.parseColor(it))
    }

    overScrollMode = customSettings.overScrollMode
    customSettings.networkAvailable?.let { setNetworkAvailable(it) }
    customSettings.rendererPriorityPolicy?.takeIf { it.isNotEmpty() }?.let { policy ->
      setRendererPriorityPolicy(
        policy["rendererRequestedPriority"] as Int,
        policy["waivedWhenNotVisible"] as Boolean
      )
    }

    if (WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING)) {
      WebSettingsCompat.setAlgorithmicDarkeningAllowed(
        settings, customSettings.algorithmicDarkeningAllowed
      )
    }
    if (WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)) {
      WebSettingsCompat.setPaymentRequestEnabled(
        settings, customSettings.paymentRequestEnabled
      )
    }
    // Null means "leave the platform default" -- androidx documents none for this one, so the
    // plugin must not pick one on the caller's behalf.
    customSettings.includeCookiesOnShouldInterceptRequest?.let {
      if (Util.isCookieInterceptSupported()) {
        WebSettingsCompat.setCookiesIncludedInShouldInterceptRequest(settings, it)
      }
    }
    // Null means "leave the platform default" (WEB_AUTHENTICATION_SUPPORT_NONE), so only apply an
    // explicit choice -- same convention as mixedContentMode and the other nullable enum settings.
    customSettings.webAuthenticationSupport?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_AUTHENTICATION)) {
        WebSettingsCompat.setWebAuthenticationSupport(settings, it)
      }
    }
    // Null keeps the platform default, so never apply it unless the caller asked. This only
    // controls whether the favicon is *requested* -- the framework callback that used to deliver
    // the downloaded bitmap (WebChromeClient.onReceivedIcon) is no longer dispatched by a modern
    // WebView, so there is no event behind this setting any more.
    customSettings.downloadFaviconsEnabled?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.DOWNLOAD_FAVICONS_ENABLED)) {
        WebSettingsCompat.setDownloadFaviconsEnabled(settings, it)
      }
    }
    // Null keeps the platform default. Enabling this changes when the load lifecycle runs: a page
    // restored from the back/forward cache is not re-loaded, so callbacks that fire per navigation
    // will not fire on a cached back.
    customSettings.backForwardCacheEnabled?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.BACK_FORWARD_CACHE)) {
        WebSettingsCompat.setBackForwardCacheEnabled(settings, it)
      }
    }
    // Null keeps the platform default, which is deliberate here: this decides whether ad
    // attribution is recorded against the app or the web, so guessing on the caller's behalf
    // would be choosing a privacy-relevant behaviour they never asked for.
    customSettings.attributionRegistrationBehavior?.let {
      if (WebViewFeature.isFeatureSupported(
          WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR
        )
      ) {
        WebSettingsCompat.setAttributionRegistrationBehavior(settings, it)
      }
    }
    customSettings.webViewMediaIntegrityApiStatus?.let {
      if (WebViewFeature.isFeatureSupported(
          WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS
        )
      ) {
        WebSettingsCompat.setWebViewMediaIntegrityApiStatus(
          settings, buildMediaIntegrityConfig(it)
        )
      }
    }
    customSettings.userAgentMetadata?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.USER_AGENT_METADATA)) {
        WebSettingsCompat.setUserAgentMetadata(settings, buildUserAgentMetadata(it))
      }
    }
    if (WebViewFeature.isFeatureSupported(
        WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY
      )
    ) {
      WebSettingsCompat.setEnterpriseAuthenticationAppLinkPolicyEnabled(
        settings, customSettings.enterpriseAuthenticationAppLinkPolicyEnabled
      )
    }

    contentBlockerHandler.ruleList.clear()
    customSettings.contentBlockers?.forEach { contentBlocker ->
      // compile ContentBlockerTrigger urlFilter
      val trigger = ContentBlockerTrigger.fromMap(contentBlocker["trigger"]!!)
      val action = ContentBlockerAction.fromMap(contentBlocker["action"]!!)
      contentBlockerHandler.ruleList.add(ContentBlocker(trigger, action))
    }

    setFindListener { activeMatchOrdinal, numberOfMatches, isDoneCounting ->
      findInteractionController?.onFindResultReceived(
        activeMatchOrdinal, numberOfMatches, isDoneCounting
      )
    }

    gestureDetector = GestureDetector(
      context,
      object : GestureDetector.SimpleOnGestureListener() {
        override fun onSingleTapUp(ev: MotionEvent): Boolean {
          if (floatingContextMenu != null) {
            hideContextMenu()
          }
          return super.onSingleTapUp(ev)
        }
      }
    )

    checkScrollStoppedTask = object : Runnable {
      override fun run() {
        val newPosition = scrollY
        if (initialPositionScrollStoppedTask - newPosition == 0) {
          // has stopped
          onScrollStopped()
        } else {
          initialPositionScrollStoppedTask = scrollY
          mainLooperHandler.postDelayed(this, newCheckScrollStoppedTask.toLong())
        }
      }
    }

    if (!customSettings.useHybridComposition) {
      checkContextMenuShouldBeClosedTask = object : Runnable {
        override fun run() {
          val task = this
          if (floatingContextMenu != null) {
            evaluateJavascript(
              PluginScriptsUtil.CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE
            ) { value ->
              if (value == null || value == "true") {
                if (floatingContextMenu != null) {
                  hideContextMenu()
                }
              } else {
                mainLooperHandler.postDelayed(
                  task, newCheckContextMenuShouldBeClosedTaskTask.toLong()
                )
              }
            }
          }
        }
      }
    }

    setOnTouchListener(object : OnTouchListener {
      var mDownX = 0f
      var mDownY = 0f

      // The listener only measures drag distance to decide whether to dismiss the floating
      // context menu; it never consumes a click, and returns false so the WebView still receives
      // the event and performs its own click/accessibility handling. Calling performClick() here
      // would fire a second, synthetic click for every touch.
      @SuppressLint("ClickableViewAccessibility")
      override fun onTouch(v: View, event: MotionEvent): Boolean {
        gestureDetector?.onTouchEvent(event)

        if (event.action == MotionEvent.ACTION_UP) {
          checkScrollStoppedTask?.run()
        }

        if (customSettings.disableHorizontalScroll && customSettings.disableVerticalScroll) {
          return event.action == MotionEvent.ACTION_MOVE
        } else if (customSettings.disableHorizontalScroll ||
          customSettings.disableVerticalScroll
        ) {
          when (event.action) {
            MotionEvent.ACTION_DOWN -> {
              // save the x
              mDownX = event.x
              // save the y
              mDownY = event.y
            }

            MotionEvent.ACTION_MOVE, MotionEvent.ACTION_CANCEL, MotionEvent.ACTION_UP -> {
              if (customSettings.disableHorizontalScroll) {
                // set x so that it doesn't move
                event.setLocation(mDownX, event.y)
              } else {
                // set y so that it doesn't move
                event.setLocation(event.x, mDownY)
              }
            }
          }
        }
        return false
      }
    })

    setOnLongClickListener {
      val hitTestResult =
        dev.nosferatu500.inappwebview.types.HitTestResult.fromWebViewHitTestResult(
          getHitTestResult()
        )
      channelDelegate?.onLongPressHitTestResult(hitTestResult)
      false
    }
  }

  fun prepareAndAddUserScripts() {
    if (javaScriptBridgeEnabled) {
      // all the plugin scripts are using the JavaScript Bridge to work
      userContentController.addPluginScript(
        PromisePolyfillJS.PROMISE_POLYFILL_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly
        )
      )

      val javaScriptBridgeOriginAllowList = customSettings.javaScriptBridgeOriginAllowList
        ?: customSettings.pluginScriptsOriginAllowList
      val javaScriptBridgeForMainFrameOnly = customSettings.javaScriptBridgeForMainFrameOnly
        ?: customSettings.pluginScriptsForMainFrameOnly
      userContentController.addPluginScript(
        JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(
          expectedBridgeSecret, javaScriptBridgeOriginAllowList, javaScriptBridgeForMainFrameOnly
        )
      )

      userContentController.addPluginScript(
        PrintJS.PRINT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly
        )
      )
      userContentController.addPluginScript(
        OnWindowBlurEventJS.ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList
        )
      )
      userContentController.addPluginScript(
        OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList
        )
      )
      val interceptOnlyAsync =
        InterceptAjaxRequestJS.createInterceptOnlyAsyncAjaxRequestsPluginScript(
          customSettings.interceptOnlyAsyncAjaxRequests
        )
      interceptOnlyAsyncAjaxRequestsPluginScript = interceptOnlyAsync
      if (customSettings.useShouldInterceptAjaxRequest) {
        userContentController.addPluginScript(interceptOnlyAsync)
        userContentController.addPluginScript(
          InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly,
            customSettings.useOnAjaxReadyStateChange,
            customSettings.useOnAjaxProgress
          )
        )
      }
      if (customSettings.useShouldInterceptFetchRequest) {
        userContentController.addPluginScript(
          InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly
          )
        )
      }
      if (customSettings.useOnLoadResource) {
        userContentController.addPluginScript(
          OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly
          )
        )
      }
      if (!customSettings.useHybridComposition) {
        userContentController.addPluginScript(
          PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly
          )
        )
      }
    }
    userContentController.addUserOnlyScripts(initialUserOnlyScripts)
  }

  fun setIncognito(enabled: Boolean) {
    val settings = settings
    if (enabled) {
      CookieManager.getInstance().removeAllCookies(null)

      // Disable caching
      settings.cacheMode = WebSettings.LOAD_NO_CACHE

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(false);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false)

      clearHistory()
      clearCache(true)

      // No form data or autofill enabled
      clearFormData()
    } else {
      settings.cacheMode = WebSettings.LOAD_DEFAULT

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(true);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true)
    }
  }

  fun setCacheEnabled(enabled: Boolean) {
    val settings = settings
    if (enabled) {
      val ctx: Context? = context
      if (ctx != null) {
        // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
        // settings.setAppCachePath(ctx.getCacheDir().getAbsolutePath());
        Util.invokeMethodIfExists(settings, "setAppCachePath", ctx.cacheDir.absolutePath)

        settings.cacheMode = WebSettings.LOAD_DEFAULT

        // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
        // settings.setAppCacheEnabled(true);
        Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true)
      }
    } else {
      settings.cacheMode = WebSettings.LOAD_NO_CACHE

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(false);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false)
    }
  }

  override fun loadUrl(urlRequest: URLRequest) {
    val url = urlRequest.url!!
    val method = urlRequest.method
    if (method == "POST") {
      postUrl(url, urlRequest.body!!)
      return
    }
    val headers = urlRequest.headers
    if (headers != null) {
      loadUrl(url, headers)
      return
    }
    loadUrl(url)
  }

  @Throws(IOException::class)
  override fun loadFile(assetFilePath: String) {
    val currentPlugin = plugin ?: return
    loadUrl(Util.getUrlAsset(currentPlugin, assetFilePath))
  }

  override fun isLoading(): Boolean = isLoading

  override fun takeScreenshot(
    screenshotConfiguration: Map<String, Any?>?,
    result: MethodChannel.Result
  ) {
    val pixelDensity = Util.getPixelDensity(context)

    mainLooperHandler.post {
      try {
        var bitmapWidth = measuredWidth
        var bitmapHeight = measuredHeight
        var bitmapScrollX = scrollX
        var bitmapScrollY = scrollY

        var compressFormat = Bitmap.CompressFormat.PNG
        var quality = 100

        if (screenshotConfiguration != null) {
          val rect = screenshotConfiguration["rect"] as Map<String, Double>?
          if (rect != null) {
            bitmapScrollX = Math.floor(rect["x"]!! * pixelDensity + 0.5).toInt()
            bitmapScrollY = Math.floor(rect["y"]!! * pixelDensity + 0.5).toInt()
            bitmapWidth = Math.floor(rect["width"]!! * pixelDensity + 0.5).toInt()
            bitmapHeight = Math.floor(rect["height"]!! * pixelDensity + 0.5).toInt()
          }

          try {
            compressFormat = Bitmap.CompressFormat.valueOf(
              screenshotConfiguration["compressFormat"] as String
            )
          } catch (e: IllegalArgumentException) {
            Log.e(LOG_TAG, "", e)
          }

          quality = screenshotConfiguration["quality"] as Int
        }

        var screenshotBitmap =
          Bitmap.createBitmap(bitmapWidth, bitmapHeight, Bitmap.Config.ARGB_8888)
        val c = Canvas(screenshotBitmap)
        c.translate(-bitmapScrollX.toFloat(), -bitmapScrollY.toFloat())
        draw(c)

        val byteArrayOutputStream = ByteArrayOutputStream()

        if (screenshotConfiguration != null) {
          val snapshotWidth = screenshotConfiguration["snapshotWidth"] as Double?
          if (snapshotWidth != null) {
            val dstWidth = Math.floor(snapshotWidth * pixelDensity + 0.5).toInt()
            val ratioBitmap =
              screenshotBitmap.width.toFloat() / screenshotBitmap.height.toFloat()
            val dstHeight = (dstWidth.toFloat() / ratioBitmap).toInt()
            screenshotBitmap =
              Bitmap.createScaledBitmap(screenshotBitmap, dstWidth, dstHeight, true)
          }
        }

        val compressed =
          screenshotBitmap.compress(compressFormat, quality, byteArrayOutputStream)
        if (!compressed) {
          Log.e(
            LOG_TAG,
            "Screenshot cannot be compressed using compressFormat " + compressFormat.name +
              " with quality " + quality,
            null
          )
        }

        try {
          byteArrayOutputStream.close()
        } catch (e: IOException) {
          Log.e(LOG_TAG, "", e)
        }
        screenshotBitmap.recycle()
        result.success(byteArrayOutputStream.toByteArray())
      } catch (e: IllegalArgumentException) {
        Log.e(LOG_TAG, "", e)
        result.success(null)
      }
    }
  }

  /**
   * Builds an androidx [WebViewMediaIntegrityApiStatusConfig] from the map Dart sends.
   *
   * Dart models the overrides as a list of `{origin, status}` objects rather than Android's
   * `Map<String, Integer>`, so that the status stays a typed enum on the Dart side. The list maps
   * one-to-one onto the builder's own per-rule `addOverrideRule`.
   */
  @SuppressLint("RestrictedApi")
  private fun buildMediaIntegrityConfig(
    map: Map<String, Any?>
  ): WebViewMediaIntegrityApiStatusConfig {
    val defaultStatus = map["defaultStatus"] as Int
    val builder = WebViewMediaIntegrityApiStatusConfig.Builder(defaultStatus)
    val rules = map["overrideRules"] as? List<Map<String, Any?>>
    rules?.forEach { rule ->
      val origin = rule["origin"] as? String
      val status = rule["status"] as? Int
      if (origin != null && status != null) {
        builder.addOverrideRule(origin, status)
      }
    }
    return builder.build()
  }

  /**
   * Builds an androidx [UserAgentMetadata] from the map Dart sends.
   *
   * Every field is optional on the Dart side, so only the ones actually provided are set and the
   * builder's own defaults survive for the rest. That is what lets a caller override, say, just the
   * brand list without having to restate platform, model and architecture.
   *
   * [UserAgentMetadata.Builder.setFormFactors] is gated on a *second* feature,
   * USER_AGENT_METADATA_FORM_FACTORS, which a WebView can lack while still supporting the rest of
   * the metadata API. Calling it unguarded throws there, so the field is skipped rather than
   * failing the whole assignment.
   */
  private fun buildUserAgentMetadata(map: Map<String, Any?>): UserAgentMetadata {
    val builder = UserAgentMetadata.Builder()
    (map["brandVersionList"] as? List<Map<String, Any?>>)?.let { list ->
      builder.setBrandVersionList(
        list.mapNotNull { item ->
          val brand = item["brand"] as? String
          val majorVersion = item["majorVersion"] as? String
          val fullVersion = item["fullVersion"] as? String
          if (brand != null && majorVersion != null && fullVersion != null) {
            UserAgentMetadata.BrandVersion.Builder()
              .setBrand(brand)
              .setMajorVersion(majorVersion)
              .setFullVersion(fullVersion)
              .build()
          } else {
            null
          }
        }
      )
    }
    (map["fullVersion"] as? String)?.let { builder.setFullVersion(it) }
    (map["platform"] as? String)?.let { builder.setPlatform(it) }
    (map["platformVersion"] as? String)?.let { builder.setPlatformVersion(it) }
    (map["architecture"] as? String)?.let { builder.setArchitecture(it) }
    (map["model"] as? String)?.let { builder.setModel(it) }
    (map["mobile"] as? Boolean)?.let { builder.setMobile(it) }
    (map["bitness"] as? Int)?.let { builder.setBitness(it) }
    (map["wow64"] as? Boolean)?.let { builder.setWow64(it) }
    if (WebViewFeature.isFeatureSupported(
        WebViewFeature.USER_AGENT_METADATA_FORM_FACTORS
      )
    ) {
      (map["formFactors"] as? List<String>)?.let { builder.setFormFactors(it) }
    }
    return builder.build()
  }

  override fun setSettings(
    newSettings: InAppWebViewSettings,
    newSettingsMap: HashMap<String, Any?>
  ) {
    val newCustomSettings = newSettings
    val settings = settings

    if (newSettingsMap["javaScriptEnabled"] != null &&
      customSettings.javaScriptEnabled != newCustomSettings.javaScriptEnabled
    ) {
      settings.javaScriptEnabled = newCustomSettings.javaScriptEnabled
    }

    if (newSettingsMap["useShouldInterceptAjaxRequest"] != null &&
      customSettings.useShouldInterceptAjaxRequest !=
      newCustomSettings.useShouldInterceptAjaxRequest
    ) {
      enablePluginScriptAtRuntime(
        InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE(),
        newCustomSettings.useShouldInterceptAjaxRequest,
        InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly,
          newCustomSettings.useOnAjaxReadyStateChange,
          newCustomSettings.useOnAjaxProgress
        )
      )
    }

    if (newSettingsMap["useOnAjaxReadyStateChange"] != null &&
      customSettings.useOnAjaxReadyStateChange != newCustomSettings.useOnAjaxReadyStateChange
    ) {
      evaluateJavascript(
        "((window.top == null || window.top === window) ? window : window.top)." +
          InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_ON_AJAX_READY_STATE_CHANGE() + " = " +
          newCustomSettings.useOnAjaxReadyStateChange + ";",
        null
      )
    }

    if (newSettingsMap["useOnAjaxProgress"] != null &&
      customSettings.useOnAjaxProgress != newCustomSettings.useOnAjaxProgress
    ) {
      evaluateJavascript(
        "((window.top == null || window.top === window) ? window : window.top)." +
          InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_ON_AJAX_PROGRESS() + " = " +
          newCustomSettings.useOnAjaxProgress + ";",
        null
      )
    }

    if (newSettingsMap["interceptOnlyAsyncAjaxRequests"] != null &&
      customSettings.interceptOnlyAsyncAjaxRequests !=
      newCustomSettings.interceptOnlyAsyncAjaxRequests
    ) {
      enablePluginScriptAtRuntime(
        InterceptAjaxRequestJS
          .FLAG_VARIABLE_FOR_INTERCEPT_ONLY_ASYNC_AJAX_REQUESTS_JS_SOURCE(),
        newCustomSettings.interceptOnlyAsyncAjaxRequests,
        interceptOnlyAsyncAjaxRequestsPluginScript
      )
    }

    if (newSettingsMap["useShouldInterceptFetchRequest"] != null &&
      customSettings.useShouldInterceptFetchRequest !=
      newCustomSettings.useShouldInterceptFetchRequest
    ) {
      enablePluginScriptAtRuntime(
        InterceptFetchRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE(),
        newCustomSettings.useShouldInterceptFetchRequest,
        InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly
        )
      )
    }

    if (newSettingsMap["useOnLoadResource"] != null &&
      customSettings.useOnLoadResource != newCustomSettings.useOnLoadResource
    ) {
      enablePluginScriptAtRuntime(
        OnLoadResourceJS.FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE(),
        newCustomSettings.useOnLoadResource,
        OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly
        )
      )
    }

    if (newSettingsMap["javaScriptCanOpenWindowsAutomatically"] != null &&
      customSettings.javaScriptCanOpenWindowsAutomatically !=
      newCustomSettings.javaScriptCanOpenWindowsAutomatically
    ) {
      settings.javaScriptCanOpenWindowsAutomatically =
        newCustomSettings.javaScriptCanOpenWindowsAutomatically
    }

    if (newSettingsMap["builtInZoomControls"] != null &&
      customSettings.builtInZoomControls != newCustomSettings.builtInZoomControls
    ) {
      settings.builtInZoomControls = newCustomSettings.builtInZoomControls
    }

    if (newSettingsMap["displayZoomControls"] != null &&
      customSettings.displayZoomControls != newCustomSettings.displayZoomControls
    ) {
      settings.displayZoomControls = newCustomSettings.displayZoomControls
    }

    if (newSettingsMap["safeBrowsingEnabled"] != null &&
      customSettings.safeBrowsingEnabled != newCustomSettings.safeBrowsingEnabled
    ) {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
        WebSettingsCompat.setSafeBrowsingEnabled(settings, newCustomSettings.safeBrowsingEnabled)
      } else {
        settings.safeBrowsingEnabled = newCustomSettings.safeBrowsingEnabled
      }
    }

    if (newSettingsMap["mediaPlaybackRequiresUserGesture"] != null &&
      customSettings.mediaPlaybackRequiresUserGesture !=
      newCustomSettings.mediaPlaybackRequiresUserGesture
    ) {
      settings.mediaPlaybackRequiresUserGesture =
        newCustomSettings.mediaPlaybackRequiresUserGesture
    }

    if (newSettingsMap["databaseEnabled"] != null &&
      customSettings.databaseEnabled != newCustomSettings.databaseEnabled
    ) {
      applyDatabaseEnabled(settings, newCustomSettings.databaseEnabled)
    }

    if (newSettingsMap["domStorageEnabled"] != null &&
      customSettings.domStorageEnabled != newCustomSettings.domStorageEnabled
    ) {
      settings.domStorageEnabled = newCustomSettings.domStorageEnabled
    }

    if (newSettingsMap["userAgent"] != null &&
      customSettings.userAgent != newCustomSettings.userAgent &&
      newCustomSettings.userAgent.isNotEmpty()
    ) {
      settings.userAgentString = newCustomSettings.userAgent
    }

    if (newSettingsMap["applicationNameForUserAgent"] != null &&
      customSettings.applicationNameForUserAgent !=
      newCustomSettings.applicationNameForUserAgent &&
      newCustomSettings.applicationNameForUserAgent.isNotEmpty()
    ) {
      val userAgent = newCustomSettings.userAgent.ifEmpty {
        WebSettings.getDefaultUserAgent(context)
      }
      settings.userAgentString = userAgent + " " + customSettings.applicationNameForUserAgent
    }

    if (newSettingsMap["thirdPartyCookiesEnabled"] != null &&
      customSettings.thirdPartyCookiesEnabled != newCustomSettings.thirdPartyCookiesEnabled
    ) {
      CookieManager.getInstance()
        .setAcceptThirdPartyCookies(this, newCustomSettings.thirdPartyCookiesEnabled)
    }

    if (newSettingsMap["useWideViewPort"] != null &&
      customSettings.useWideViewPort != newCustomSettings.useWideViewPort
    ) {
      settings.useWideViewPort = newCustomSettings.useWideViewPort
    }

    if (newSettingsMap["supportZoom"] != null &&
      customSettings.supportZoom != newCustomSettings.supportZoom
    ) {
      settings.setSupportZoom(newCustomSettings.supportZoom)
    }

    if (newSettingsMap["textZoom"] != null &&
      customSettings.textZoom != newCustomSettings.textZoom
    ) {
      settings.textZoom = newCustomSettings.textZoom!!
    }

    if (newSettingsMap["verticalScrollBarEnabled"] != null &&
      customSettings.verticalScrollBarEnabled != newCustomSettings.verticalScrollBarEnabled
    ) {
      isVerticalScrollBarEnabled = newCustomSettings.verticalScrollBarEnabled
    }

    if (newSettingsMap["horizontalScrollBarEnabled"] != null &&
      customSettings.horizontalScrollBarEnabled != newCustomSettings.horizontalScrollBarEnabled
    ) {
      isHorizontalScrollBarEnabled = newCustomSettings.horizontalScrollBarEnabled
    }

    if (newSettingsMap["transparentBackground"] != null &&
      customSettings.transparentBackground != newCustomSettings.transparentBackground
    ) {
      if (newCustomSettings.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT)
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"))
      }
    }

    if (newSettingsMap["mixedContentMode"] != null &&
      customSettings.mixedContentMode != newCustomSettings.mixedContentMode
    ) {
      settings.mixedContentMode = newCustomSettings.mixedContentMode!!
    }

    if (newSettingsMap["supportMultipleWindows"] != null &&
      customSettings.supportMultipleWindows != newCustomSettings.supportMultipleWindows
    ) {
      settings.setSupportMultipleWindows(newCustomSettings.supportMultipleWindows)
    }

    if (newSettingsMap["useOnDownloadStart"] != null &&
      customSettings.useOnDownloadStart != newCustomSettings.useOnDownloadStart
    ) {
      if (newCustomSettings.useOnDownloadStart) {
        setDownloadListener(DownloadStartListener())
      } else {
        setDownloadListener(null)
      }
    }

    if (newSettingsMap["allowContentAccess"] != null &&
      customSettings.allowContentAccess != newCustomSettings.allowContentAccess
    ) {
      settings.allowContentAccess = newCustomSettings.allowContentAccess
    }

    if (newSettingsMap["allowFileAccess"] != null &&
      customSettings.allowFileAccess != newCustomSettings.allowFileAccess
    ) {
      settings.allowFileAccess = newCustomSettings.allowFileAccess
    }

    if (newSettingsMap["allowFileAccessFromFileURLs"] != null &&
      customSettings.allowFileAccessFromFileURLs !=
      newCustomSettings.allowFileAccessFromFileURLs
    ) {
      applyAllowFileAccessFromFileURLs(
        settings, newCustomSettings.allowFileAccessFromFileURLs
      )
    }

    if (newSettingsMap["allowUniversalAccessFromFileURLs"] != null &&
      customSettings.allowUniversalAccessFromFileURLs !=
      newCustomSettings.allowUniversalAccessFromFileURLs
    ) {
      applyAllowUniversalAccessFromFileURLs(
        settings, newCustomSettings.allowUniversalAccessFromFileURLs
      )
    }

    if (newSettingsMap["cacheEnabled"] != null &&
      customSettings.cacheEnabled != newCustomSettings.cacheEnabled
    ) {
      setCacheEnabled(newCustomSettings.cacheEnabled)
    }

    if (newSettingsMap["appCachePath"] != null &&
      customSettings.appCachePath != newCustomSettings.appCachePath
    ) {
      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCachePath(newCustomSettings.appCachePath);
      Util.invokeMethodIfExists(settings, "setAppCachePath", newCustomSettings.appCachePath)
    }

    if (newSettingsMap["blockNetworkImage"] != null &&
      customSettings.blockNetworkImage != newCustomSettings.blockNetworkImage
    ) {
      settings.blockNetworkImage = newCustomSettings.blockNetworkImage
    }

    if (newSettingsMap["blockNetworkLoads"] != null &&
      customSettings.blockNetworkLoads != newCustomSettings.blockNetworkLoads
    ) {
      settings.blockNetworkLoads = newCustomSettings.blockNetworkLoads
    }

    if (newSettingsMap["cacheMode"] != null &&
      customSettings.cacheMode != newCustomSettings.cacheMode
    ) {
      settings.cacheMode = newCustomSettings.cacheMode
    }

    if (newSettingsMap["cursiveFontFamily"] != null &&
      customSettings.cursiveFontFamily != newCustomSettings.cursiveFontFamily
    ) {
      settings.cursiveFontFamily = newCustomSettings.cursiveFontFamily
    }

    if (newSettingsMap["defaultFixedFontSize"] != null &&
      customSettings.defaultFixedFontSize != newCustomSettings.defaultFixedFontSize
    ) {
      settings.defaultFixedFontSize = newCustomSettings.defaultFixedFontSize
    }

    if (newSettingsMap["defaultFontSize"] != null &&
      customSettings.defaultFontSize != newCustomSettings.defaultFontSize
    ) {
      settings.defaultFontSize = newCustomSettings.defaultFontSize
    }

    if (newSettingsMap["defaultTextEncodingName"] != null &&
      customSettings.defaultTextEncodingName != newCustomSettings.defaultTextEncodingName
    ) {
      settings.defaultTextEncodingName = newCustomSettings.defaultTextEncodingName
    }

    if (newSettingsMap["disabledActionModeMenuItems"] != null &&
      customSettings.disabledActionModeMenuItems !=
      newCustomSettings.disabledActionModeMenuItems
    ) {
      val items = newCustomSettings.disabledActionModeMenuItems!!
      if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
        WebSettingsCompat.setDisabledActionModeMenuItems(settings, items)
      } else {
        settings.disabledActionModeMenuItems = items
      }
    }

    if (newSettingsMap["fantasyFontFamily"] != null &&
      customSettings.fantasyFontFamily != newCustomSettings.fantasyFontFamily
    ) {
      settings.fantasyFontFamily = newCustomSettings.fantasyFontFamily
    }

    if (newSettingsMap["fixedFontFamily"] != null &&
      customSettings.fixedFontFamily != newCustomSettings.fixedFontFamily
    ) {
      settings.fixedFontFamily = newCustomSettings.fixedFontFamily
    }

    if (newSettingsMap["geolocationEnabled"] != null &&
      customSettings.geolocationEnabled != newCustomSettings.geolocationEnabled
    ) {
      settings.setGeolocationEnabled(newCustomSettings.geolocationEnabled)
    }

    if (newSettingsMap["layoutAlgorithm"] != null &&
      customSettings.layoutAlgorithm != newCustomSettings.layoutAlgorithm
    ) {
      settings.layoutAlgorithm = newCustomSettings.layoutAlgorithm!!
    }

    if (newSettingsMap["loadWithOverviewMode"] != null &&
      customSettings.loadWithOverviewMode != newCustomSettings.loadWithOverviewMode
    ) {
      settings.loadWithOverviewMode = newCustomSettings.loadWithOverviewMode
    }

    if (newSettingsMap["loadsImagesAutomatically"] != null &&
      customSettings.loadsImagesAutomatically != newCustomSettings.loadsImagesAutomatically
    ) {
      settings.loadsImagesAutomatically = newCustomSettings.loadsImagesAutomatically
    }

    if (newSettingsMap["minimumFontSize"] != null &&
      customSettings.minimumFontSize != newCustomSettings.minimumFontSize
    ) {
      settings.minimumFontSize = newCustomSettings.minimumFontSize
    }

    if (newSettingsMap["minimumLogicalFontSize"] != null &&
      customSettings.minimumLogicalFontSize != newCustomSettings.minimumLogicalFontSize
    ) {
      settings.minimumLogicalFontSize = newCustomSettings.minimumLogicalFontSize
    }

    if (newSettingsMap["initialScale"] != null &&
      customSettings.initialScale != newCustomSettings.initialScale
    ) {
      setInitialScale(newCustomSettings.initialScale)
    }

    if (newSettingsMap["needInitialFocus"] != null &&
      customSettings.needInitialFocus != newCustomSettings.needInitialFocus
    ) {
      settings.setNeedInitialFocus(newCustomSettings.needInitialFocus)
    }

    if (newSettingsMap["offscreenPreRaster"] != null &&
      customSettings.offscreenPreRaster != newCustomSettings.offscreenPreRaster
    ) {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
        WebSettingsCompat.setOffscreenPreRaster(settings, newCustomSettings.offscreenPreRaster)
      } else {
        settings.offscreenPreRaster = newCustomSettings.offscreenPreRaster
      }
    }

    if (newSettingsMap["sansSerifFontFamily"] != null &&
      customSettings.sansSerifFontFamily != newCustomSettings.sansSerifFontFamily
    ) {
      settings.sansSerifFontFamily = newCustomSettings.sansSerifFontFamily
    }

    if (newSettingsMap["serifFontFamily"] != null &&
      customSettings.serifFontFamily != newCustomSettings.serifFontFamily
    ) {
      settings.serifFontFamily = newCustomSettings.serifFontFamily
    }

    if (newSettingsMap["standardFontFamily"] != null &&
      customSettings.standardFontFamily != newCustomSettings.standardFontFamily
    ) {
      settings.standardFontFamily = newCustomSettings.standardFontFamily
    }

    if (newSettingsMap["preferredContentMode"] != null &&
      customSettings.preferredContentMode != newCustomSettings.preferredContentMode
    ) {
      when (PreferredContentModeOptionType.fromValue(newCustomSettings.preferredContentMode)) {
        PreferredContentModeOptionType.DESKTOP -> setDesktopMode(true)
        PreferredContentModeOptionType.MOBILE,
        PreferredContentModeOptionType.RECOMMENDED -> setDesktopMode(false)
      }
    }

    if (newSettingsMap["incognito"] != null &&
      customSettings.incognito != newCustomSettings.incognito
    ) {
      setIncognito(newCustomSettings.incognito)
    }

    if (customSettings.useHybridComposition) {
      if (newSettingsMap["hardwareAcceleration"] != null &&
        customSettings.hardwareAcceleration != newCustomSettings.hardwareAcceleration
      ) {
        if (newCustomSettings.hardwareAcceleration) {
          setLayerType(LAYER_TYPE_HARDWARE, null)
        } else {
          setLayerType(LAYER_TYPE_NONE, null)
        }
      }
    }

    newCustomSettings.contentBlockers?.let { blockers ->
      contentBlockerHandler.ruleList.clear()
      for (contentBlocker in blockers) {
        // compile ContentBlockerTrigger urlFilter
        val trigger = ContentBlockerTrigger.fromMap(contentBlocker["trigger"]!!)
        val action = ContentBlockerAction.fromMap(contentBlocker["action"]!!)
        contentBlockerHandler.ruleList.add(ContentBlocker(trigger, action))
      }
    }

    if (newSettingsMap["scrollBarStyle"] != null &&
      customSettings.scrollBarStyle != newCustomSettings.scrollBarStyle
    ) {
      scrollBarStyle = newCustomSettings.scrollBarStyle
    }

    if (newSettingsMap["scrollBarDefaultDelayBeforeFade"] != null &&
      customSettings.scrollBarDefaultDelayBeforeFade !=
      newCustomSettings.scrollBarDefaultDelayBeforeFade
    ) {
      scrollBarDefaultDelayBeforeFade = newCustomSettings.scrollBarDefaultDelayBeforeFade!!
    }

    if (newSettingsMap["scrollbarFadingEnabled"] != null &&
      customSettings.scrollbarFadingEnabled != newCustomSettings.scrollbarFadingEnabled
    ) {
      isScrollbarFadingEnabled = newCustomSettings.scrollbarFadingEnabled
    }

    if (newSettingsMap["scrollBarFadeDuration"] != null &&
      customSettings.scrollBarFadeDuration != newCustomSettings.scrollBarFadeDuration
    ) {
      scrollBarFadeDuration = newCustomSettings.scrollBarFadeDuration!!
    }

    if (newSettingsMap["verticalScrollbarPosition"] != null &&
      customSettings.verticalScrollbarPosition != newCustomSettings.verticalScrollbarPosition
    ) {
      verticalScrollbarPosition = newCustomSettings.verticalScrollbarPosition
    }

    if (newSettingsMap["disableVerticalScroll"] != null &&
      customSettings.disableVerticalScroll != newCustomSettings.disableVerticalScroll
    ) {
      isVerticalScrollBarEnabled =
        !newCustomSettings.disableVerticalScroll && newCustomSettings.verticalScrollBarEnabled
    }

    if (newSettingsMap["disableHorizontalScroll"] != null &&
      customSettings.disableHorizontalScroll != newCustomSettings.disableHorizontalScroll
    ) {
      isHorizontalScrollBarEnabled = !newCustomSettings.disableHorizontalScroll &&
        newCustomSettings.horizontalScrollBarEnabled
    }

    if (newSettingsMap["overScrollMode"] != null &&
      customSettings.overScrollMode != newCustomSettings.overScrollMode
    ) {
      overScrollMode = newCustomSettings.overScrollMode
    }

    if (newSettingsMap["networkAvailable"] != null &&
      customSettings.networkAvailable != newCustomSettings.networkAvailable
    ) {
      setNetworkAvailable(newCustomSettings.networkAvailable!!)
    }

    // These are boxed Integer/Boolean out of a channel map. Upstream compared them by reference,
    // so any priority outside the Integer autoboxing cache read as changed on every setSettings
    // call and re-applied the policy. Structural comparison, like every other branch here
    // (TODO.md P0b.1).
    if (newSettingsMap["rendererPriorityPolicy"] != null &&
      (
        customSettings.rendererPriorityPolicy == null ||
          !Util.objEquals(
            customSettings.rendererPriorityPolicy!!["rendererRequestedPriority"],
            newCustomSettings.rendererPriorityPolicy!!["rendererRequestedPriority"]
          ) ||
          !Util.objEquals(
            customSettings.rendererPriorityPolicy!!["waivedWhenNotVisible"],
            newCustomSettings.rendererPriorityPolicy!!["waivedWhenNotVisible"]
          )
        )
    ) {
      setRendererPriorityPolicy(
        newCustomSettings.rendererPriorityPolicy!!["rendererRequestedPriority"] as Int,
        newCustomSettings.rendererPriorityPolicy!!["waivedWhenNotVisible"] as Boolean
      )
    }

    if (newSettingsMap["verticalScrollbarThumbColor"] != null &&
      !Util.objEquals(
        customSettings.verticalScrollbarThumbColor,
        newCustomSettings.verticalScrollbarThumbColor
      )
    ) {
      verticalScrollbarThumbDrawable =
        ColorDrawable(Color.parseColor(newCustomSettings.verticalScrollbarThumbColor))
    }

    if (newSettingsMap["verticalScrollbarTrackColor"] != null &&
      !Util.objEquals(
        customSettings.verticalScrollbarTrackColor,
        newCustomSettings.verticalScrollbarTrackColor
      )
    ) {
      verticalScrollbarTrackDrawable =
        ColorDrawable(Color.parseColor(newCustomSettings.verticalScrollbarTrackColor))
    }

    if (newSettingsMap["horizontalScrollbarThumbColor"] != null &&
      !Util.objEquals(
        customSettings.horizontalScrollbarThumbColor,
        newCustomSettings.horizontalScrollbarThumbColor
      )
    ) {
      horizontalScrollbarThumbDrawable =
        ColorDrawable(Color.parseColor(newCustomSettings.horizontalScrollbarThumbColor))
    }

    if (newSettingsMap["horizontalScrollbarTrackColor"] != null &&
      !Util.objEquals(
        customSettings.horizontalScrollbarTrackColor,
        newCustomSettings.horizontalScrollbarTrackColor
      )
    ) {
      horizontalScrollbarTrackDrawable =
        ColorDrawable(Color.parseColor(newCustomSettings.horizontalScrollbarTrackColor))
    }

    if (newSettingsMap["algorithmicDarkeningAllowed"] != null &&
      !Util.objEquals(
        customSettings.algorithmicDarkeningAllowed,
        newCustomSettings.algorithmicDarkeningAllowed
      ) &&
      WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING)
    ) {
      WebSettingsCompat.setAlgorithmicDarkeningAllowed(
        settings, newCustomSettings.algorithmicDarkeningAllowed
      )
    }
    if (newSettingsMap["paymentRequestEnabled"] != null &&
      !Util.objEquals(
        customSettings.paymentRequestEnabled,
        newCustomSettings.paymentRequestEnabled
      ) &&
      WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)
    ) {
      WebSettingsCompat.setPaymentRequestEnabled(
        settings, newCustomSettings.paymentRequestEnabled
      )
    }
    if (newSettingsMap["includeCookiesOnShouldInterceptRequest"] != null &&
      !Util.objEquals(
        customSettings.includeCookiesOnShouldInterceptRequest,
        newCustomSettings.includeCookiesOnShouldInterceptRequest
      ) &&
      Util.isCookieInterceptSupported()
    ) {
      newCustomSettings.includeCookiesOnShouldInterceptRequest?.let {
        WebSettingsCompat.setCookiesIncludedInShouldInterceptRequest(settings, it)
      }
    }
    if (newSettingsMap["webAuthenticationSupport"] != null &&
      customSettings.webAuthenticationSupport !=
      newCustomSettings.webAuthenticationSupport &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_AUTHENTICATION)
    ) {
      WebSettingsCompat.setWebAuthenticationSupport(
        settings, newCustomSettings.webAuthenticationSupport!!
      )
    }
    if (newSettingsMap["downloadFaviconsEnabled"] != null &&
      customSettings.downloadFaviconsEnabled !=
      newCustomSettings.downloadFaviconsEnabled &&
      WebViewFeature.isFeatureSupported(WebViewFeature.DOWNLOAD_FAVICONS_ENABLED)
    ) {
      WebSettingsCompat.setDownloadFaviconsEnabled(
        settings, newCustomSettings.downloadFaviconsEnabled!!
      )
    }
    if (newSettingsMap["backForwardCacheEnabled"] != null &&
      customSettings.backForwardCacheEnabled !=
      newCustomSettings.backForwardCacheEnabled &&
      WebViewFeature.isFeatureSupported(WebViewFeature.BACK_FORWARD_CACHE)
    ) {
      WebSettingsCompat.setBackForwardCacheEnabled(
        settings, newCustomSettings.backForwardCacheEnabled!!
      )
    }
    if (newSettingsMap["attributionRegistrationBehavior"] != null &&
      customSettings.attributionRegistrationBehavior !=
      newCustomSettings.attributionRegistrationBehavior &&
      WebViewFeature.isFeatureSupported(
        WebViewFeature.ATTRIBUTION_REGISTRATION_BEHAVIOR
      )
    ) {
      WebSettingsCompat.setAttributionRegistrationBehavior(
        settings, newCustomSettings.attributionRegistrationBehavior!!
      )
    }
    if (newSettingsMap["webViewMediaIntegrityApiStatus"] != null &&
      customSettings.webViewMediaIntegrityApiStatus !=
      newCustomSettings.webViewMediaIntegrityApiStatus &&
      WebViewFeature.isFeatureSupported(
        WebViewFeature.WEBVIEW_MEDIA_INTEGRITY_API_STATUS
      )
    ) {
      WebSettingsCompat.setWebViewMediaIntegrityApiStatus(
        settings,
        buildMediaIntegrityConfig(newCustomSettings.webViewMediaIntegrityApiStatus!!)
      )
    }
    if (newSettingsMap["userAgentMetadata"] != null &&
      customSettings.userAgentMetadata != newCustomSettings.userAgentMetadata &&
      WebViewFeature.isFeatureSupported(WebViewFeature.USER_AGENT_METADATA)
    ) {
      WebSettingsCompat.setUserAgentMetadata(
        settings, buildUserAgentMetadata(newCustomSettings.userAgentMetadata!!)
      )
    }
    // "profileName" has no branch here on purpose, and it is the only settings field in this
    // method's contract that does not. WebViewCompat.setProfile throws IllegalStateException once
    // the WebView has been used at all -- navigated, or had evaluateJavascript called on it -- and
    // by the time setSettings can run, both have happened. It is applied once at creation
    // (FlutterWebView.init, InAppBrowserActivity) and is documented as creation-time only.
    if (newSettingsMap["enterpriseAuthenticationAppLinkPolicyEnabled"] != null &&
      !Util.objEquals(
        customSettings.enterpriseAuthenticationAppLinkPolicyEnabled,
        newCustomSettings.enterpriseAuthenticationAppLinkPolicyEnabled
      ) &&
      WebViewFeature.isFeatureSupported(
        WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY
      )
    ) {
      WebSettingsCompat.setEnterpriseAuthenticationAppLinkPolicyEnabled(
        settings, newCustomSettings.enterpriseAuthenticationAppLinkPolicyEnabled
      )
    }

    // Toggleable at runtime rather than creation-only: registering and unregistering a navigation
    // listener costs nothing and holds no state that a live WebView depends on. Turning it back on
    // starts fresh ids, because the old listener's identity maps went with it — which is why the
    // dartdoc says ids are unique within a WebView and must not be persisted.
    if (newSettingsMap["useNavigationListener"] != null &&
      customSettings.useNavigationListener != newCustomSettings.useNavigationListener
    ) {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.NAVIGATION_LISTENER)) {
        inAppWebViewNavigationListener?.let {
          WebViewCompat.removeNavigationListener(this, it)
          it.dispose()
        }
        inAppWebViewNavigationListener = null
        if (newCustomSettings.useNavigationListener) {
          val navigationListener = InAppWebViewNavigationListener(this)
          inAppWebViewNavigationListener = navigationListener
          WebViewCompat.addNavigationListener(this, navigationListener)
        }
      }
    }

    plugin?.let {
      webViewAssetLoaderExt?.dispose()
      webViewAssetLoaderExt =
        WebViewAssetLoaderExt.fromMap(customSettings.webViewAssetLoader, it, context)
    }

    customSettings = newCustomSettings
  }

  override fun getCustomSettingsMap(): Map<String, Any?> = customSettings.getRealSettings(this)

  fun enablePluginScriptAtRuntime(
    flagVariable: String,
    enable: Boolean,
    pluginScript: PluginScript?
  ) {
    evaluateJavascript(
      "((window.top == null || window.top === window) ? window : window.top).$flagVariable",
      null
    ) { value ->
      val alreadyLoaded = value != null && !value.equals("null", ignoreCase = true)
      if (alreadyLoaded) {
        val enableSource =
          "((window.top == null || window.top === window) ? window : window.top)." +
            flagVariable + " = " + enable + ";"
        evaluateJavascript(enableSource, null, null)
        if (!enable && pluginScript != null) {
          userContentController.removePluginScript(pluginScript)
        }
      } else if (enable && javaScriptBridgeEnabled && pluginScript != null) {
        evaluateJavascript(pluginScript.source, null, null)
        userContentController.addPluginScript(pluginScript)
      }
    }
  }

  fun injectDeferredObject(
    source: String,
    contentWorld: ContentWorld?,
    jsWrapper: String?,
    resultCallback: ValueCallback<String>?
  ) {
    val resultUuid =
      if (contentWorld != null && contentWorld != ContentWorld.PAGE) {
        UUID.randomUUID().toString()
      } else {
        null
      }
    var scriptToInject = source
    if (jsWrapper != null) {
      val jsonEsc = JSONArray()
      jsonEsc.put(source)
      val jsonRepr = jsonEsc.toString()
      val jsonSourceString = jsonRepr.substring(1, jsonRepr.length - 1)
      scriptToInject = String.format(jsWrapper, jsonSourceString)
    }
    if (resultUuid != null && resultCallback != null) {
      evaluateJavaScriptContentWorldCallbacks[resultUuid] = resultCallback
      scriptToInject = Util.replaceAll(
        PluginScriptsUtil.EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE(),
        PluginScriptsUtil.VAR_RANDOM_NAME,
        "_" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_" +
          Math.round(Math.random() * 1000000)
      )
        .replace(
          PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, UserContentController.escapeCode(source)
        )
        .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)
    }
    val finalScriptToInject = scriptToInject
    mainLooperHandler.post {
      val generated =
        userContentController.generateCodeForScriptEvaluation(finalScriptToInject, contentWorld)
      evaluateJavascript(generated) { s ->
        if (resultUuid == null && resultCallback != null) {
          resultCallback.onReceiveValue(s)
        }
      }
    }
  }

  override fun evaluateJavascript(
    source: String,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>?
  ) {
    injectDeferredObject(source, contentWorld, null, resultCallback)
  }

  override fun injectJavascriptFileFromUrl(
    urlFile: String,
    scriptHtmlTagAttributes: Map<String, Any?>?
  ) {
    var scriptAttributes = ""
    if (scriptHtmlTagAttributes != null) {
      val typeAttr = scriptHtmlTagAttributes["type"] as String?
      if (typeAttr != null) {
        scriptAttributes += " script.type = '" + escapeSingleQuotes(typeAttr) + "'; "
      }
      val idAttr = scriptHtmlTagAttributes["id"] as String?
      if (idAttr != null) {
        val scriptIdEscaped = escapeSingleQuotes(idAttr)
        val bridge = JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()
        scriptAttributes += " script.id = '$scriptIdEscaped'; "
        scriptAttributes += " script.onload = function() {" +
          "  if (window.$bridge != null) {" +
          "    window.$bridge.callHandler('onInjectedScriptLoaded', '$scriptIdEscaped');" +
          "  }" +
          "};"
        scriptAttributes += " script.onerror = function() {" +
          "  if (window.$bridge != null) {" +
          "    window.$bridge.callHandler('onInjectedScriptError', '$scriptIdEscaped');" +
          "  }" +
          "};"
      }
      if (scriptHtmlTagAttributes["async"] as Boolean? == true) {
        scriptAttributes += " script.async = true; "
      }
      if (scriptHtmlTagAttributes["defer"] as Boolean? == true) {
        scriptAttributes += " script.defer = true; "
      }
      val crossOriginAttr = scriptHtmlTagAttributes["crossOrigin"] as String?
      if (crossOriginAttr != null) {
        scriptAttributes += " script.crossOrigin = '" + escapeSingleQuotes(crossOriginAttr) + "'; "
      }
      val integrityAttr = scriptHtmlTagAttributes["integrity"] as String?
      if (integrityAttr != null) {
        scriptAttributes += " script.integrity = '" + escapeSingleQuotes(integrityAttr) + "'; "
      }
      if (scriptHtmlTagAttributes["noModule"] as Boolean? == true) {
        scriptAttributes += " script.noModule = true; "
      }
      val nonceAttr = scriptHtmlTagAttributes["nonce"] as String?
      if (nonceAttr != null) {
        scriptAttributes += " script.nonce = '" + escapeSingleQuotes(nonceAttr) + "'; "
      }
      val referrerPolicyAttr = scriptHtmlTagAttributes["referrerPolicy"] as String?
      if (referrerPolicyAttr != null) {
        scriptAttributes +=
          " script.referrerPolicy = '" + escapeSingleQuotes(referrerPolicyAttr) + "'; "
      }
    }
    val jsWrapper = "(function(d) { var script = d.createElement('script'); " +
      scriptAttributes +
      " script.src = %s; if (d.body != null) { d.body.appendChild(script); } })(document);"
    injectDeferredObject(urlFile, null, jsWrapper, null)
  }

  override fun injectCSSCode(source: String) {
    val jsWrapper = "(function(d) { var style = d.createElement('style'); style.innerHTML = %s;" +
      " if (d.head != null) { d.head.appendChild(style); } })(document);"
    injectDeferredObject(source, null, jsWrapper, null)
  }

  override fun injectCSSFileFromUrl(
    urlFile: String,
    cssLinkHtmlTagAttributes: Map<String, Any?>?
  ) {
    var cssLinkAttributes = ""
    var alternateStylesheet = ""
    if (cssLinkHtmlTagAttributes != null) {
      val idAttr = cssLinkHtmlTagAttributes["id"] as String?
      if (idAttr != null) {
        cssLinkAttributes += " link.id = '" + escapeSingleQuotes(idAttr) + "'; "
      }
      val mediaAttr = cssLinkHtmlTagAttributes["media"] as String?
      if (mediaAttr != null) {
        cssLinkAttributes += " link.media = '" + escapeSingleQuotes(mediaAttr) + "'; "
      }
      val crossOriginAttr = cssLinkHtmlTagAttributes["crossOrigin"] as String?
      if (crossOriginAttr != null) {
        cssLinkAttributes += " link.crossOrigin = '" + escapeSingleQuotes(crossOriginAttr) + "'; "
      }
      val integrityAttr = cssLinkHtmlTagAttributes["integrity"] as String?
      if (integrityAttr != null) {
        cssLinkAttributes += " link.integrity = '" + escapeSingleQuotes(integrityAttr) + "'; "
      }
      val referrerPolicyAttr = cssLinkHtmlTagAttributes["referrerPolicy"] as String?
      if (referrerPolicyAttr != null) {
        cssLinkAttributes +=
          " link.referrerPolicy = '" + escapeSingleQuotes(referrerPolicyAttr) + "'; "
      }
      if (cssLinkHtmlTagAttributes["disabled"] as Boolean? == true) {
        cssLinkAttributes += " link.disabled = true; "
      }
      if (cssLinkHtmlTagAttributes["alternate"] as Boolean? == true) {
        alternateStylesheet = "alternate "
      }
      val titleAttr = cssLinkHtmlTagAttributes["title"] as String?
      if (titleAttr != null) {
        cssLinkAttributes += " link.title = '" + escapeSingleQuotes(titleAttr) + "'; "
      }
    }
    val jsWrapper = "(function(d) { var link = d.createElement('link'); link.rel='" +
      alternateStylesheet + "stylesheet'; link.type='text/css'; " + cssLinkAttributes +
      " link.href = %s; if (d.head != null) { d.head.appendChild(link); } })(document);"
    injectDeferredObject(urlFile, null, jsWrapper, null)
  }

  override fun getCopyBackForwardList(): HashMap<String, Any?> {
    val currentList = copyBackForwardList()
    val currentSize = currentList.size
    val currentIndex = currentList.currentIndex

    val history = mutableListOf<HashMap<String, Any?>>()

    for (i in 0 until currentSize) {
      val historyItem = currentList.getItemAtIndex(i)
      history.add(
        hashMapOf(
          "originalUrl" to historyItem.originalUrl,
          "title" to historyItem.title,
          "url" to historyItem.url,
          "index" to i,
          "offset" to i - currentIndex
        )
      )
    }

    return hashMapOf(
      "list" to history,
      "currentIndex" to currentIndex
    )
  }

  override fun onScrollChanged(x: Int, y: Int, oldX: Int, oldY: Int) {
    super.onScrollChanged(x, y, oldX, oldY)

    floatingContextMenu?.let {
      it.alpha = 0f
      it.visibility = View.GONE
    }

    channelDelegate?.onScrollChanged(x, y)
  }

  override fun scrollTo(x: Int?, y: Int?, animated: Boolean?) {
    if (animated == true) {
      val pvhX = PropertyValuesHolder.ofInt("scrollX", x!!)
      val pvhY = PropertyValuesHolder.ofInt("scrollY", y!!)
      ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY).setDuration(300).start()
    } else {
      scrollTo(x!!, y!!)
    }
  }

  override fun scrollBy(x: Int?, y: Int?, animated: Boolean?) {
    if (animated == true) {
      val pvhX = PropertyValuesHolder.ofInt("scrollX", scrollX + x!!)
      val pvhY = PropertyValuesHolder.ofInt("scrollY", scrollY + y!!)
      ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY).setDuration(300).start()
    } else {
      scrollBy(x!!, y!!)
    }
  }

  inner class DownloadStartListener : DownloadListener {
    override fun onDownloadStart(
      url: String,
      userAgent: String,
      contentDisposition: String,
      mimeType: String,
      contentLength: Long
    ) {
      val downloadStartRequest = DownloadStartRequest(
        url,
        userAgent,
        contentDisposition,
        mimeType,
        contentLength,
        URLUtil.guessFileName(url, contentDisposition, mimeType),
        null
      )
      channelDelegate?.onDownloadStarting(downloadStartRequest)
    }
  }

  fun setDesktopMode(enabled: Boolean) {
    val webSettings = settings

    val newUserAgent = if (enabled) {
      webSettings.userAgentString.replace("Mobile", "eliboM").replace("Android", "diordnA")
    } else {
      webSettings.userAgentString.replace("eliboM", "Mobile").replace("diordnA", "Android")
    }

    webSettings.userAgentString = newUserAgent
    webSettings.useWideViewPort = enabled
    webSettings.loadWithOverviewMode = enabled
    webSettings.setSupportZoom(enabled)
    webSettings.builtInZoomControls = enabled
  }

  override fun printCurrentPage(settings: PrintJobSettings?): String? {
    val currentPlugin = plugin ?: return null
    val activity = currentPlugin.activity ?: return null

    // Get a PrintManager instance
    val printManager = activity.getSystemService(Context.PRINT_SERVICE) as PrintManager?
    if (printManager == null) {
      Log.e(LOG_TAG, "No PrintManager available")
      return null
    }

    val builder = PrintAttributes.Builder()

    var jobName = (title ?: url) + " Document"

    if (settings != null) {
      if (!settings.jobName.isNullOrEmpty()) {
        jobName = settings.jobName!!
      }
      settings.orientation?.let { orientation ->
        when (orientation) {
          // PORTRAIT
          0 -> builder.setMediaSize(PrintAttributes.MediaSize.UNKNOWN_PORTRAIT)
          // LANDSCAPE
          1 -> builder.setMediaSize(PrintAttributes.MediaSize.UNKNOWN_LANDSCAPE)
        }
      }
      // if (settings.margins != null) {
      //   // for some reason, Android doesn't set the margins
      //   builder.setMinMargins(settings.margins.toMargins());
      // }
      settings.mediaSize?.let { builder.setMediaSize(it.toMediaSize()) }
      settings.colorMode?.let { builder.setColorMode(it) }
      settings.duplexMode?.let { builder.setDuplexMode(it) }
      settings.resolution?.let { builder.setResolution(it.toResolution()) }
    }

    // Get a printCurrentPage adapter instance
    var printAdapter: PrintDocumentAdapter = createPrintDocumentAdapter(jobName)

    var printJobController: PrintJobController? = null
    var id: String? = null

    val printJobManager = currentPlugin.printJobManager
    if (settings != null && settings.handledByClient && printJobManager != null) {
      id = UUID.randomUUID().toString()
      val controller = PrintJobController(id, settings, currentPlugin)
      printJobController = controller
      printJobManager.jobs[controller.id] = controller
      printAdapter = InAppWebViewPrintDocumentAdapter(
        printAdapter,
        object : InAppWebViewPrintDocumentAdapter.PrintDocumentAdapterCallback() {
          override fun onFinish() {
            controller.onComplete(true, null)
          }
        }
      )
    }

    // Create a printCurrentPage job with name and adapter instance
    val job = printManager.print(jobName, printAdapter, builder.build())
    printJobController?.setJob(job)

    return id
  }

  public override fun onCreateContextMenu(menu: ContextMenu) {
    super.onCreateContextMenu(menu)
    sendOnCreateContextMenuEvent()
  }

  private fun sendOnCreateContextMenuEvent() {
    val hitTestResult =
      dev.nosferatu500.inappwebview.types.HitTestResult.fromWebViewHitTestResult(
        getHitTestResult()
      )
    channelDelegate?.onCreateContextMenu(hitTestResult)
  }

  // WebView implements its own click and accessibility handling over the rendered page; there is
  // no single "click" on the View itself for performClick() to represent. Overriding it would
  // announce a control that does not exist to accessibility services.
  @SuppressLint("ClickableViewAccessibility")
  override fun onTouchEvent(ev: MotionEvent): Boolean {
    if (!customSettings.isUserInteractionEnabled) {
      return true
    }

    lastTouch = Point(ev.x.toInt(), ev.y.toInt())

    val parent = parent
    if (parent is PullToRefreshLayout && ev.actionMasked == MotionEvent.ACTION_DOWN) {
      parent.isEnabled = false
    }

    return super.onTouchEvent(ev)
  }

  override fun onOverScrolled(scrollX: Int, scrollY: Int, clampedX: Boolean, clampedY: Boolean) {
    super.onOverScrolled(scrollX, scrollY, clampedX, clampedY)

    val overScrolledHorizontally = canScrollHorizontally() && clampedX
    val overScrolledVertically = canScrollVertically() && clampedY

    val parent = parent
    if (parent is PullToRefreshLayout && overScrolledVertically && scrollY <= 10) {
      // change over scroll mode to OVER_SCROLL_NEVER in order to disable temporarily the glow
      // effect
      overScrollMode = OVER_SCROLL_NEVER
      parent.isEnabled = parent.settings.enabled
      // reset over scroll mode
      overScrollMode = customSettings.overScrollMode
    }

    if (overScrolledHorizontally || overScrolledVertically) {
      channelDelegate?.onOverScrolled(
        scrollX, scrollY, overScrolledHorizontally, overScrolledVertically
      )
    }
  }

  override fun dispatchTouchEvent(event: MotionEvent): Boolean =
    super.dispatchTouchEvent(event)

  override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
    val connection = super.onCreateInputConnection(outAttrs)
    val currentContainerView = containerView
    if (connection == null && !customSettings.useHybridComposition &&
      currentContainerView != null
    ) {
      // workaround to hide the Keyboard when the user click outside
      // on something not focusable such as input or a textarea.
      currentContainerView.handler.postDelayed({
        val imm =
          context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?

        var isAcceptingText = false
        if (imm != null) {
          try {
            // imm.isAcceptingText() seems to sometimes crash on some devices
            isAcceptingText = imm.isAcceptingText
          } catch (ignored: Exception) {
          }
        }

        if (containerView != null && imm != null && !isAcceptingText) {
          hideSoftInputNotAlways(imm, containerView?.windowToken)
        }
      }, 128)
    }
    return connection
  }

  override fun startActionMode(callback: ActionMode.Callback?): ActionMode? {
    if (customSettings.useHybridComposition && !customSettings.disableContextMenu &&
      contextMenu.isNullOrEmpty()
    ) {
      return super.startActionMode(callback)
    }
    return rebuildActionMode(super.startActionMode(callback), callback)
  }

  override fun startActionMode(callback: ActionMode.Callback?, type: Int): ActionMode? {
    if (customSettings.useHybridComposition && !customSettings.disableContextMenu &&
      contextMenu.isNullOrEmpty()
    ) {
      return super.startActionMode(callback, type)
    }
    return rebuildActionMode(super.startActionMode(callback, type), callback)
  }

  // AbsoluteLayout.LayoutParams is deprecated, but WebView extends AbsoluteLayout and
  // AbsoluteLayout.onLayout casts every child's params to it. Any other LayoutParams type is
  // silently replaced by ViewGroup.addView via generateLayoutParams, which drops the x/y
  // position and would render the floating context menu at (0,0). There is no alternative
  // while the menu is a child of the WebView.
  @Suppress("DEPRECATION")
  fun rebuildActionMode(
    actionMode: ActionMode?,
    callback: ActionMode.Callback?
  ): ActionMode? {
    // fix Android 10 clipboard not working properly
    // https://github.com/pichillilorenzo/flutter_inappwebview/issues/678
    val currentContainerView = containerView
    if (!customSettings.useHybridComposition && currentContainerView != null) {
      onWindowFocusChanged(currentContainerView.isFocused)
    }

    var hasBeenRemovedAndRebuilt = false
    if (floatingContextMenu != null) {
      hideContextMenu()
      hasBeenRemovedAndRebuilt = true
    }
    if (actionMode == null) {
      return null
    }

    val actionMenu = actionMode.menu
    actionMode.hide(3000)

    val defaultMenuItems = mutableListOf<MenuItem>()
    for (i in 0 until actionMenu.size()) {
      defaultMenuItems.add(actionMenu.getItem(i))
    }
    actionMenu.clear()
    actionMode.finish()
    if (customSettings.disableContextMenu) {
      return actionMode
    }

    val menu = LayoutInflater.from(context)
      .inflate(R.layout.floating_action_mode, this, false) as LinearLayout
    floatingContextMenu = menu
    val horizontalScrollView = menu.getChildAt(0) as HorizontalScrollView
    val menuItemListLayout = horizontalScrollView.getChildAt(0) as LinearLayout

    var customMenuItems: List<Map<String, Any?>>? = ArrayList()
    val contextMenuSettings = ContextMenuSettings()
    contextMenu?.let { cm ->
      customMenuItems = cm["menuItems"] as List<Map<String, Any?>>?
      val contextMenuSettingsMap = cm["settings"] as Map<String, Any?>?
      if (contextMenuSettingsMap != null) {
        contextMenuSettings.parse(contextMenuSettingsMap)
      }
    }
    val menuItems = customMenuItems ?: ArrayList()

    if (!contextMenuSettings.hideDefaultSystemContextMenuItems) {
      for (menuItem in defaultMenuItems) {
        val itemId = menuItem.itemId
        val itemTitle = menuItem.title.toString()

        val text = LayoutInflater.from(context)
          .inflate(R.layout.floating_action_mode_item, this, false) as TextView
        text.text = itemTitle
        text.setOnClickListener {
          hideContextMenu()
          callback?.onActionItemClicked(actionMode, menuItem)

          channelDelegate?.onContextMenuActionItemClicked(itemId, itemTitle)
        }
        if (floatingContextMenu != null) {
          menuItemListLayout.addView(text)
        }
      }
    }

    for (menuItem in menuItems) {
      val itemId = menuItem["id"] as Int
      val itemTitle = menuItem["title"] as String?
      val text = LayoutInflater.from(context)
        .inflate(R.layout.floating_action_mode_item, this, false) as TextView
      text.text = itemTitle
      text.setOnClickListener {
        hideContextMenu()

        channelDelegate?.onContextMenuActionItemClicked(itemId, itemTitle)
      }
      if (floatingContextMenu != null) {
        menuItemListLayout.addView(text)
      }
    }

    val x = lastTouch.x
    val y = lastTouch.y
    contextMenuPoint = Point(x, y)

    menu.viewTreeObserver.addOnGlobalLayoutListener(
      object : ViewTreeObserver.OnGlobalLayoutListener {
        override fun onGlobalLayout() {
          floatingContextMenu?.let {
            it.viewTreeObserver.removeOnGlobalLayoutListener(this)
            if (settings.javaScriptEnabled) {
              onScrollStopped()
            } else {
              onFloatingActionGlobalLayout(x, y)
            }
          }
        }
      }
    )
    addView(
      menu,
      android.widget.AbsoluteLayout.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, x, y
      )
    )
    if (hasBeenRemovedAndRebuilt) {
      sendOnCreateContextMenuEvent()
    }
    checkContextMenuShouldBeClosedTask?.run()

    return actionMode
  }

  // AbsoluteLayout.LayoutParams is deprecated, but WebView extends AbsoluteLayout and
  // AbsoluteLayout.onLayout casts every child's params to it. Any other LayoutParams type is
  // silently replaced by ViewGroup.addView via generateLayoutParams, which drops the x/y
  // position and would render the floating context menu at (0,0). There is no alternative
  // while the menu is a child of the WebView.
  @Suppress("DEPRECATION")
  fun onFloatingActionGlobalLayout(x: Int, y: Int) {
    val menu = floatingContextMenu ?: return
    val maxWidth = width
    val maxHeight = height
    val menuWidth = menu.width
    val menuHeight = menu.height
    var curx = x - (menuWidth / 2)
    if (curx < 0) {
      curx = 0
    } else if (curx + menuWidth > maxWidth) {
      curx = maxWidth - menuWidth
    }
    // float size = 12 * scale;
    var cury = y - (menuHeight * 1.5f)
    if (cury < 0) {
      cury = (y + menuHeight).toFloat()
    }

    updateViewLayout(
      menu,
      android.widget.AbsoluteLayout.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT,
        curx + scrollX, cury.toInt() + scrollY
      )
    )

    mainLooperHandler.post {
      floatingContextMenu?.let {
        it.visibility = View.VISIBLE
        it.animate().alpha(1f).setDuration(100).setListener(null)
      }
    }
  }

  fun hideContextMenu() {
    removeView(floatingContextMenu)
    floatingContextMenu = null

    channelDelegate?.onHideContextMenu()
  }

  fun onScrollStopped() {
    if (floatingContextMenu != null) {
      adjustFloatingContextMenuPosition()
    }
  }

  fun adjustFloatingContextMenuPosition() {
    evaluateJavascript(
      "(function(){" +
        "  var selection = window.getSelection();" +
        "  var rangeY = null;" +
        "  if (selection != null && selection.rangeCount > 0) {" +
        "    var range = selection.getRangeAt(0);" +
        "    var clientRect = range.getClientRects();" +
        "    if (clientRect.length > 0) {" +
        "      rangeY = clientRect[0].y;" +
        "    } else if (document.activeElement != null && " +
        "document.activeElement.tagName.toLowerCase() !== 'iframe') {" +
        "      var boundingClientRect = document.activeElement.getBoundingClientRect();" +
        "      rangeY = boundingClientRect.y;" +
        "    }" +
        "  }" +
        "  return rangeY;" +
        "})();"
    ) { value ->
      floatingContextMenu?.let { menu ->
        if (value != null && !value.equals("null", ignoreCase = true)) {
          val x = contextMenuPoint.x
          val y = (
            (value.toFloat() * Util.getPixelDensity(context)) +
              (menu.height / 3.5)
            ).toInt()
          contextMenuPoint.y = y
          onFloatingActionGlobalLayout(x, y)
        } else {
          menu.visibility = View.VISIBLE
          menu.animate().alpha(1f).setDuration(100).setListener(null)
          onFloatingActionGlobalLayout(contextMenuPoint.x, contextMenuPoint.y)
        }
      }
    }
  }

  override fun getSelectedText(callback: ValueCallback<String>) {
    evaluateJavascript(PluginScriptsUtil.GET_SELECTED_TEXT_JS_SOURCE) { value ->
      val text = if (value != null && !value.equals("null", ignoreCase = true)) {
        value.substring(1, value.length - 1)
      } else {
        null
      }
      callback.onReceiveValue(text)
    }
  }

  override fun requestFocusNodeHref(): Map<String, Any?> {
    val msg = mHandler.obtainMessage()
    requestFocusNodeHref(msg)
    val bundle = msg.peekData()!!

    return hashMapOf(
      "src" to bundle.getString("src"),
      "url" to bundle.getString("url"),
      "title" to bundle.getString("title")
    )
  }

  override fun requestImageRef(): Map<String, Any?> {
    val msg = mHandler.obtainMessage()
    requestImageRef(msg)
    val bundle = msg.peekData()!!

    return hashMapOf("url" to bundle.getString("url"))
  }

  override fun callAsyncJavaScript(
    functionBody: String,
    arguments: Map<String, Any?>,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>?
  ) {
    val resultUuid = UUID.randomUUID().toString()
    if (resultCallback != null) {
      callAsyncJavaScriptCallbacks[resultUuid] = resultCallback
    }

    val functionArguments = JSONObject(arguments)
    val keys = functionArguments.keys()

    val functionArgumentNamesList = mutableListOf<String>()
    val functionArgumentValuesList = mutableListOf<String>()
    while (keys.hasNext()) {
      val key = keys.next()
      functionArgumentNamesList.add(key)
      functionArgumentValuesList.add("obj.$key")
    }

    val functionArgumentNames = TextUtils.join(", ", functionArgumentNamesList)
    val functionArgumentValues = TextUtils.join(", ", functionArgumentValuesList)
    val functionArgumentsObj = Util.JSONStringify(arguments)

    var sourceToInject = PluginScriptsUtil.CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE()
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES, functionArgumentNames)
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES, functionArgumentValues)
      .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ, functionArgumentsObj)
      .replace(PluginScriptsUtil.VAR_FUNCTION_BODY, functionBody)
      .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)
      .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)

    sourceToInject =
      userContentController.generateCodeForScriptEvaluation(sourceToInject, contentWorld)
    evaluateJavascript(sourceToInject, null)
  }

  override fun isSecureContext(resultCallback: ValueCallback<Boolean>) {
    evaluateJavascript("window.isSecureContext") { value ->
      if (value.isNullOrEmpty() || value.equals("null", ignoreCase = true) ||
        value.equals("false", ignoreCase = true)
      ) {
        resultCallback.onReceiveValue(false)
      } else {
        resultCallback.onReceiveValue(true)
      }
    }
  }

  override fun canScrollVertically(): Boolean =
    computeVerticalScrollRange() > computeVerticalScrollExtent()

  override fun canScrollHorizontally(): Boolean =
    computeHorizontalScrollRange() > computeHorizontalScrollExtent()

  override fun createCompatWebMessageChannel(): WebMessageChannel {
    val id = UUID.randomUUID().toString()
    val webMessageChannel = WebMessageChannel(id, this)
    webMessageChannels[id] = webMessageChannel
    return webMessageChannel
  }

  override fun createWebMessageChannel(
    callback: ValueCallback<WebMessageChannel>
  ): WebMessageChannel {
    val webMessageChannel = createCompatWebMessageChannel()
    callback.onReceiveValue(webMessageChannel)
    return webMessageChannel
  }

  @Throws(Exception::class)
  override fun addWebMessageListener(webMessageListener: WebMessageListener) {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
      WebViewCompat.addWebMessageListener(
        this,
        webMessageListener.jsObjectName,
        webMessageListener.allowedOriginRules,
        webMessageListener.listener!!
      )
      webMessageListeners.add(webMessageListener)
    }
  }

  override fun disposeWebMessageChannels() {
    for (webMessageChannel in webMessageChannels.values) {
      webMessageChannel.dispose()
    }
    webMessageChannels.clear()
  }

  override fun disposeWebMessageListeners() {
    for (webMessageListener in webMessageListeners) {
      webMessageListener.dispose()
    }
    webMessageListeners.clear()
  }

  override fun getWebViewLooper(): Looper = super.getWebViewLooper()

  override fun isInFullscreen(): Boolean = inFullscreen

  override fun setInFullscreen(inFullscreen: Boolean) {
    this.inFullscreen = inFullscreen
  }

  @Throws(Exception::class)
  override fun postWebMessage(
    message: dev.nosferatu500.inappwebview.types.WebMessage,
    targetOrigin: Uri,
    callback: ValueCallback<String>?
  ) {
    throw UnsupportedOperationException()
  }

  override fun onWindowVisibilityChanged(visibility: Int) {
    if (customSettings.allowBackgroundAudioPlaying) {
      if (visibility != View.GONE) {
        super.onWindowVisibilityChanged(View.VISIBLE)
      }
      return
    }
    super.onWindowVisibilityChanged(visibility)
  }

  override fun getZoomScale(): Float = zoomScale

  override fun getZoomScale(callback: ValueCallback<Float>) {
    callback.onReceiveValue(zoomScale)
  }

  override fun getContextMenu(): Map<String, Any?>? = contextMenu

  override fun setContextMenu(contextMenu: Map<String, Any?>?) {
    this.contextMenu = contextMenu
  }

  override fun getPlugin(): InAppWebViewFlutterPlugin? = plugin

  override fun setPlugin(plugin: InAppWebViewFlutterPlugin?) {
    this.plugin = plugin
  }

  override fun getInAppBrowserDelegate(): InAppBrowserDelegate? = inAppBrowserDelegate

  override fun setInAppBrowserDelegate(inAppBrowserDelegate: InAppBrowserDelegate?) {
    this.inAppBrowserDelegate = inAppBrowserDelegate
  }

  override fun getUserContentController(): UserContentController = userContentController

  override fun setUserContentController(userContentController: UserContentController) {
    this.userContentController = userContentController
  }

  override fun getWebMessageChannels(): MutableMap<String, WebMessageChannel> = webMessageChannels

  override fun setWebMessageChannels(
    webMessageChannels: MutableMap<String, WebMessageChannel>?
  ) {
    this.webMessageChannels = webMessageChannels ?: HashMap()
  }

  override fun getContentHeight(callback: ValueCallback<Int>) {
    callback.onReceiveValue(contentHeight)
  }

  override fun getContentWidth(callback: ValueCallback<Int>) {
    evaluateJavascript("document.documentElement.scrollWidth;") { value ->
      var contentWidth: Int? = null
      if (value != null && !value.equals("null", ignoreCase = true)) {
        contentWidth = value.toInt()
      }
      callback.onReceiveValue(contentWidth)
    }
  }

  override fun getHitTestResult(
    callback: ValueCallback<dev.nosferatu500.inappwebview.types.HitTestResult>
  ) {
    callback.onReceiveValue(
      dev.nosferatu500.inappwebview.types.HitTestResult.fromWebViewHitTestResult(
        getHitTestResult()
      )
    )
  }

  override fun getChannelDelegate(): WebViewChannelDelegate? = channelDelegate

  override fun setChannelDelegate(eventWebViewChannelDelegate: WebViewChannelDelegate?) {
    channelDelegate = eventWebViewChannelDelegate
  }

  override fun getCustomSettings(): InAppWebViewSettings = customSettings

  override fun showInputMethod() {
    val activity = plugin?.activity ?: return
    val imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
    imm?.showSoftInput(this, 0)
  }

  override fun setAudioMuted(muted: Boolean) {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.MUTE_AUDIO)) {
      WebViewCompat.setAudioMuted(this, muted)
    }
  }

  // False rather than throwing when the feature is missing: audio cannot have been muted through
  // setAudioMuted in that case, so "not muted" is the accurate answer.
  override fun isAudioMuted(): Boolean =
    if (WebViewFeature.isFeatureSupported(WebViewFeature.MUTE_AUDIO)) {
      WebViewCompat.isAudioMuted(this)
    } else {
      false
    }

  /**
   * Starts a prerender of [url] for this WebView. Returns whether the request was issued.
   *
   * `PrerenderOperationCallback` reports two later outcomes -- `onPrerenderActivated`, meaning this
   * WebView eventually navigated to the prerendered url, and `onError`. Neither is surfaced to Dart:
   * activation may happen much later or never, so completing the channel reply on it would leave a
   * Dart Future dangling for the lifetime of the WebView. The reply is therefore sent as soon as the
   * request is issued, and the outcomes are logged. See the Dart doc and TODO.md P0c.
   *
   * The CancellationSignal is null on purpose: cancelling would need a handle passed back to Dart
   * and a cancel method, which is a separate design. A prerender that is never activated is
   * discarded by the WebView on its own.
   */
  override fun prerenderUrl(url: String): Boolean {
    if (!WebViewFeature.isFeatureSupported(WebViewFeature.PRERENDER_WITH_URL)) {
      return false
    }
    WebViewCompat.prerenderUrlAsync(
      this,
      url,
      null,
      Executor { command -> command.run() },
      object : PrerenderOperationCallback {
        override fun onPrerenderActivated() {
          Log.d(LOG_TAG, "prerender of $url was activated")
        }

        override fun onError(e: PrerenderException) {
          Log.e(LOG_TAG, "prerender of $url failed", e)
        }
      }
    )
    return true
  }

  override fun hideInputMethod() {
    val activity = plugin?.activity ?: return
    val imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
    if (imm != null) {
      var token: IBinder? = windowToken
      val currentContainerView = containerView
      if (!customSettings.useHybridComposition && currentContainerView != null) {
        token = currentContainerView.windowToken
      }
      imm.hideSoftInputFromWindow(token, 0)
    }
  }

  /**
   * Serialises this WebView's back/forward state.
   *
   * With neither [maxSize] nor [includeForwardState] this is the framework `WebView.saveState`,
   * exactly as before androidx grew an alternative, and it needs no feature. Measured on API 33 and
   * API 37: `WebViewCompat.saveState(this, bundle, Int.MAX_VALUE, true)` returns a **byte-identical**
   * result, so routing the unconstrained case through the compat API would buy nothing and would
   * make an unconditional call depend on `SAVE_STATE`.
   *
   * With either argument the compat API is the only one that can honour it. When `SAVE_STATE` is
   * unsupported this returns `null` rather than falling back: the caller asked for a bounded state,
   * and handing back an unbounded one would break the single guarantee they asked for. That follows
   * `isAudioMuted` above -- answer with the accurate neutral value rather than throwing.
   *
   * The two APIs report failure differently and that is why the result is read off the bundle here.
   * `WebView.saveState` returns a `WebBackForwardList?` and signals failure with null;
   * `WebViewCompat.saveState` returns `void` and signals it by leaving the bundle untouched, which
   * is what happens when [maxSize] is smaller than the current entry alone (measured: a 9-entry
   * 2.0 MB history with `maxSize = 200000` produced an empty bundle, not a smaller state).
   *
   * [maxSize] bounds what the WebView writes into the bundle, not the marshalled bytes returned
   * here, so the result can exceed it by the Parcel's own framing -- measured at 40 bytes over on
   * API 33. The Dart doc says so; do not "fix" it by shrinking the value passed through.
   */
  override fun saveState(maxSize: Int?, includeForwardState: Boolean?): ByteArray? {
    val constrained = maxSize != null || includeForwardState != null
    if (constrained && !WebViewFeature.isFeatureSupported(WebViewFeature.SAVE_STATE)) {
      return null
    }
    // androidx annotates maxSizeBytes @IntRange(from = 1); nothing can be saved below that anyway.
    if (maxSize != null && maxSize < 1) {
      return null
    }
    val bundle = Bundle()
    val saved =
      if (constrained) {
        WebViewCompat.saveState(this, bundle, maxSize ?: Int.MAX_VALUE, includeForwardState ?: true)
        !bundle.isEmpty
      } else {
        saveState(bundle) != null
      }
    if (saved) {
      val parcel = Parcel.obtain()
      bundle.writeToParcel(parcel, 0)
      val bytes = parcel.marshall()
      parcel.recycle()
      return bytes
    }
    return null
  }

  override fun restoreState(state: ByteArray): Boolean {
    var restored = false
    val parcel = Parcel.obtain()
    try {
      parcel.unmarshall(state, 0, state.size)
      parcel.setDataPosition(0)
      val bundle = Bundle.CREATOR.createFromParcel(parcel)
      restored = restoreState(bundle) != null
    } catch (e: Exception) {
      e.printStackTrace()
    } finally {
      parcel.recycle()
    }
    return restored
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    settings.javaScriptEnabled = false
    removeJavascriptInterface(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)) {
      WebViewCompat.setWebViewRenderProcessClient(this, null)
    }
    webChromeClient = WebChromeClient()
    webViewClient = object : WebViewClient() {
      override fun onPageFinished(view: WebView, url: String) {
        destroy()
      }
    }
    interceptOnlyAsyncAjaxRequestsPluginScript = null
    userContentController.dispose()
    findInteractionController?.dispose()
    findInteractionController = null
    webViewAssetLoaderExt?.dispose()
    webViewAssetLoaderExt = null
    val currentWindowId = windowId
    if (currentWindowId != null) {
      plugin?.inAppWebViewManager?.windowWebViewMessages?.remove(currentWindowId)
    }
    mainLooperHandler.removeCallbacksAndMessages(null)
    mHandler.removeCallbacksAndMessages(null)
    disposeWebMessageChannels()
    disposeWebMessageListeners()
    removeAllViews()
    checkContextMenuShouldBeClosedTask?.let { removeCallbacks(it) }
    checkScrollStoppedTask?.let { removeCallbacks(it) }
    callAsyncJavaScriptCallbacks.clear()
    evaluateJavaScriptContentWorldCallbacks.clear()
    inAppBrowserDelegate = null
    // Guarded by the field rather than by the setting: `setSettings` can flip
    // `useNavigationListener` after `prepare()`, so the setting no longer says whether a listener
    // was actually registered — only a non-null field does.
    inAppWebViewNavigationListener?.let {
      WebViewCompat.removeNavigationListener(this, it)
      it.dispose()
    }
    inAppWebViewNavigationListener = null
    inAppWebViewRenderProcessClient?.dispose()
    inAppWebViewRenderProcessClient = null
    inAppWebViewChromeClient?.dispose()
    inAppWebViewChromeClient = null
    inAppWebViewClientCompat?.dispose()
    inAppWebViewClientCompat = null
    inAppWebViewClient?.dispose()
    inAppWebViewClient = null
    javaScriptBridgeInterface?.dispose()
    javaScriptBridgeInterface = null
    plugin = null
    loadUrl("about:blank")
  }

  override fun destroy() {
    super.destroy()
  }

  companion object {
    private const val LOG_TAG = "InAppWebView"
    const val METHOD_CHANNEL_NAME_PREFIX = "dev.nosferatu500.inappwebview/inappwebview_"

    @JvmField
    val mHandler = Handler(Looper.getMainLooper())

    private fun escapeSingleQuotes(value: String): String = value.replace("'", "\\'")

    // The three setters below are deprecated by Android with no replacement offered. They still
    // work, and the plugin exposes each as a documented setting, so they are kept deliberately.
    //
    // They are isolated into one-line helpers so that @Suppress("DEPRECATION") covers exactly the
    // deprecated call. Annotating the enclosing prepare() / setSettings() instead would blanket
    // several hundred lines of settings code and silently swallow any *new* deprecation
    // introduced there -- which is the opposite of what the zero-warning baseline is for.

    @Suppress("DEPRECATION")
    private fun applyDatabaseEnabled(settings: WebSettings, enabled: Boolean) {
      settings.databaseEnabled = enabled
    }

    @Suppress("DEPRECATION")
    private fun applyAllowFileAccessFromFileURLs(settings: WebSettings, allow: Boolean) {
      settings.allowFileAccessFromFileURLs = allow
    }

    @Suppress("DEPRECATION")
    private fun applyAllowUniversalAccessFromFileURLs(settings: WebSettings, allow: Boolean) {
      settings.allowUniversalAccessFromFileURLs = allow
    }

    // `InputMethodManager.HIDE_NOT_ALWAYS` is deprecated as of **API 37**, which this module now
    // compiles against (androidx.core 1.19.0 requires it). Isolated for the same reason as the
    // three above: the suppression covers exactly the deprecated constant.
    //
    // Kept rather than migrated. The documented replacement is
    // `WindowInsetsControllerCompat.hide(WindowInsetsCompat.Type.ime())`, which is not equivalent
    // here: HIDE_NOT_ALWAYS means "hide only if the user did not explicitly request the keyboard",
    // and the insets API has no such conditional. Swapping it would change behaviour on the
    // click-outside-to-dismiss path this workaround exists for, on every Android version, to
    // silence a warning on one. Filed instead.
    @Suppress("DEPRECATION")
    private fun hideSoftInputNotAlways(imm: InputMethodManager, windowToken: IBinder?) {
      imm.hideSoftInputFromWindow(windowToken, InputMethodManager.HIDE_NOT_ALWAYS)
    }
  }
}
