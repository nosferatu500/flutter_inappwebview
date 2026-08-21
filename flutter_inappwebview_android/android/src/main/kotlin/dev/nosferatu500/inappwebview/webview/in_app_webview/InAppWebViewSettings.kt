package dev.nosferatu500.inappwebview.webview.in_app_webview

import android.annotation.SuppressLint
import android.view.View
import android.webkit.WebSettings
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.ISettings
import dev.nosferatu500.inappwebview.types.PreferredContentModeOptionType
import dev.nosferatu500.inappwebview.webview.InAppWebViewInterface
import java.util.regex.Pattern

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class InAppWebViewSettings : ISettings<InAppWebViewInterface> {

  @JvmField var useShouldOverrideUrlLoading: Boolean = false
  @JvmField var useOnLoadResource: Boolean = false
  @JvmField var useOnDownloadStart: Boolean = false
  @JvmField var userAgent: String = ""
  @JvmField var applicationNameForUserAgent: String = ""
  @JvmField var javaScriptEnabled: Boolean = true
  @JvmField var javaScriptCanOpenWindowsAutomatically: Boolean = false
  @JvmField var mediaPlaybackRequiresUserGesture: Boolean = true
  @JvmField var minimumFontSize: Int = 8
  @JvmField var verticalScrollBarEnabled: Boolean = true
  @JvmField var horizontalScrollBarEnabled: Boolean = true
  @JvmField var resourceCustomSchemes: List<String> = ArrayList()
  @JvmField var contentBlockers: List<Map<String, Map<String, Any?>>>? = ArrayList()
  @JvmField var preferredContentMode: Int = PreferredContentModeOptionType.RECOMMENDED.toValue()
  @JvmField var useShouldInterceptAjaxRequest: Boolean = false
  @JvmField var useOnAjaxReadyStateChange: Boolean = false
  @JvmField var useOnAjaxProgress: Boolean = false
  @JvmField var interceptOnlyAsyncAjaxRequests: Boolean = true
  @JvmField var useShouldInterceptFetchRequest: Boolean = false
  @JvmField var incognito: Boolean = false
  @JvmField var cacheEnabled: Boolean = true
  @JvmField var transparentBackground: Boolean = false
  @JvmField var disableVerticalScroll: Boolean = false
  @JvmField var disableHorizontalScroll: Boolean = false
  @JvmField var disableContextMenu: Boolean = false
  @JvmField var supportZoom: Boolean = true
  @JvmField var allowFileAccessFromFileURLs: Boolean = false
  @JvmField var allowUniversalAccessFromFileURLs: Boolean = false
  @JvmField var allowBackgroundAudioPlaying: Boolean = false
  @JvmField var textZoom: Int? = null
  @JvmField var builtInZoomControls: Boolean = true
  @JvmField var displayZoomControls: Boolean = false
  @JvmField var databaseEnabled: Boolean = false
  @JvmField var domStorageEnabled: Boolean = true
  @JvmField var useWideViewPort: Boolean = true
  @JvmField var safeBrowsingEnabled: Boolean = true
  @JvmField var mixedContentMode: Int? = null
  @JvmField var allowContentAccess: Boolean = true
  @JvmField var allowFileAccess: Boolean = true
  @JvmField var appCachePath: String? = null
  @JvmField var blockNetworkImage: Boolean = false
  @JvmField var blockNetworkLoads: Boolean = false
  @JvmField var cacheMode: Int = WebSettings.LOAD_DEFAULT
  @JvmField var cursiveFontFamily: String = "cursive"
  @JvmField var defaultFixedFontSize: Int = 16
  @JvmField var defaultFontSize: Int = 16
  @JvmField var defaultTextEncodingName: String = "UTF-8"
  @JvmField var disabledActionModeMenuItems: Int? = null
  @JvmField var fantasyFontFamily: String = "fantasy"
  @JvmField var fixedFontFamily: String = "monospace"
  @JvmField var geolocationEnabled: Boolean = true
  @JvmField var layoutAlgorithm: WebSettings.LayoutAlgorithm? = null
  @JvmField var loadWithOverviewMode: Boolean = true
  @JvmField var loadsImagesAutomatically: Boolean = true
  @JvmField var minimumLogicalFontSize: Int = 8
  @JvmField var initialScale: Int = 0
  @JvmField var needInitialFocus: Boolean = true
  @JvmField var offscreenPreRaster: Boolean = false
  @JvmField var sansSerifFontFamily: String = "sans-serif"
  @JvmField var serifFontFamily: String = "sans-serif"
  @JvmField var standardFontFamily: String = "sans-serif"
  @JvmField var thirdPartyCookiesEnabled: Boolean = true
  @JvmField var hardwareAcceleration: Boolean = true
  @JvmField var supportMultipleWindows: Boolean = false
  @JvmField var regexToCancelSubFramesLoading: Pattern? = null
  @JvmField var regexToAllowSyncUrlLoading: Pattern? = null
  @JvmField var overScrollMode: Int = View.OVER_SCROLL_IF_CONTENT_SCROLLS
  @JvmField var networkAvailable: Boolean? = null
  @JvmField var scrollBarStyle: Int = View.SCROLLBARS_INSIDE_OVERLAY
  @JvmField var verticalScrollbarPosition: Int = View.SCROLLBAR_POSITION_DEFAULT
  @JvmField var scrollBarDefaultDelayBeforeFade: Int? = null
  @JvmField var scrollbarFadingEnabled: Boolean = true
  @JvmField var scrollBarFadeDuration: Int? = null
  @JvmField var rendererPriorityPolicy: Map<String, Any?>? = null
  @JvmField var useShouldInterceptRequest: Boolean = false
  @JvmField var useOnRenderProcessGone: Boolean = false
  @JvmField var disableDefaultErrorPage: Boolean = false
  @JvmField var useHybridComposition: Boolean = true
  @JvmField var verticalScrollbarThumbColor: String? = null
  @JvmField var verticalScrollbarTrackColor: String? = null
  @JvmField var horizontalScrollbarThumbColor: String? = null
  @JvmField var horizontalScrollbarTrackColor: String? = null
  @JvmField var algorithmicDarkeningAllowed: Boolean = false
  @JvmField var enterpriseAuthenticationAppLinkPolicyEnabled: Boolean = true
  @JvmField var webViewAssetLoader: Map<String, Any?>? = null
  @JvmField var defaultVideoPoster: ByteArray? = null
  @JvmField var javaScriptHandlersOriginAllowList: MutableSet<Pattern>? = null
  @JvmField var javaScriptHandlersForMainFrameOnly: Boolean = false
  @JvmField var javaScriptBridgeEnabled: Boolean = true
  @JvmField var javaScriptBridgeOriginAllowList: Set<String>? = null
  @JvmField var javaScriptBridgeForMainFrameOnly: Boolean? = null
  @JvmField var pluginScriptsOriginAllowList: Set<String>? = null
  @JvmField var pluginScriptsForMainFrameOnly: Boolean = false
  @JvmField var isUserInteractionEnabled: Boolean = true
  @JvmField var alpha: Double? = null
  @JvmField var useOnShowFileChooser: Boolean = false

  override fun parse(settings: Map<String, Any?>): InAppWebViewSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "useShouldOverrideUrlLoading" -> useShouldOverrideUrlLoading = value as Boolean
        "useOnLoadResource" -> useOnLoadResource = value as Boolean
        "useOnDownloadStart" -> useOnDownloadStart = value as Boolean
        "userAgent" -> userAgent = value as String
        "applicationNameForUserAgent" -> applicationNameForUserAgent = value as String
        "javaScriptEnabled" -> javaScriptEnabled = value as Boolean
        "javaScriptCanOpenWindowsAutomatically" ->
          javaScriptCanOpenWindowsAutomatically = value as Boolean
        "mediaPlaybackRequiresUserGesture" -> mediaPlaybackRequiresUserGesture = value as Boolean
        "minimumFontSize" -> minimumFontSize = value as Int
        "verticalScrollBarEnabled" -> verticalScrollBarEnabled = value as Boolean
        "horizontalScrollBarEnabled" -> horizontalScrollBarEnabled = value as Boolean
        "resourceCustomSchemes" -> resourceCustomSchemes = value as List<String>
        "contentBlockers" -> contentBlockers = value as List<Map<String, Map<String, Any?>>>
        "preferredContentMode" -> preferredContentMode = value as Int
        "useShouldInterceptAjaxRequest" -> useShouldInterceptAjaxRequest = value as Boolean
        "useOnAjaxReadyStateChange" -> useOnAjaxReadyStateChange = value as Boolean
        "useOnAjaxProgress" -> useOnAjaxProgress = value as Boolean
        "interceptOnlyAsyncAjaxRequests" -> interceptOnlyAsyncAjaxRequests = value as Boolean
        "useShouldInterceptFetchRequest" -> useShouldInterceptFetchRequest = value as Boolean
        "incognito" -> incognito = value as Boolean
        "cacheEnabled" -> cacheEnabled = value as Boolean
        "transparentBackground" -> transparentBackground = value as Boolean
        "disableVerticalScroll" -> disableVerticalScroll = value as Boolean
        "disableHorizontalScroll" -> disableHorizontalScroll = value as Boolean
        "disableContextMenu" -> disableContextMenu = value as Boolean
        "textZoom" -> textZoom = value as Int
        "builtInZoomControls" -> builtInZoomControls = value as Boolean
        "displayZoomControls" -> displayZoomControls = value as Boolean
        "supportZoom" -> supportZoom = value as Boolean
        "databaseEnabled" -> databaseEnabled = value as Boolean
        "domStorageEnabled" -> domStorageEnabled = value as Boolean
        "useWideViewPort" -> useWideViewPort = value as Boolean
        "safeBrowsingEnabled" -> safeBrowsingEnabled = value as Boolean
        "mixedContentMode" -> mixedContentMode = value as Int
        "allowContentAccess" -> allowContentAccess = value as Boolean
        "allowFileAccess" -> allowFileAccess = value as Boolean
        "allowFileAccessFromFileURLs" -> allowFileAccessFromFileURLs = value as Boolean
        "allowUniversalAccessFromFileURLs" -> allowUniversalAccessFromFileURLs = value as Boolean
        "appCachePath" -> appCachePath = value as String
        "blockNetworkImage" -> blockNetworkImage = value as Boolean
        "blockNetworkLoads" -> blockNetworkLoads = value as Boolean
        "cacheMode" -> cacheMode = value as Int
        "cursiveFontFamily" -> cursiveFontFamily = value as String
        "defaultFixedFontSize" -> defaultFixedFontSize = value as Int
        "defaultFontSize" -> defaultFontSize = value as Int
        "defaultTextEncodingName" -> defaultTextEncodingName = value as String
        "disabledActionModeMenuItems" -> disabledActionModeMenuItems = value as Int
        "fantasyFontFamily" -> fantasyFontFamily = value as String
        "fixedFontFamily" -> fixedFontFamily = value as String
        "geolocationEnabled" -> geolocationEnabled = value as Boolean
        "layoutAlgorithm" -> setLayoutAlgorithm(value as String)
        "loadWithOverviewMode" -> loadWithOverviewMode = value as Boolean
        "loadsImagesAutomatically" -> loadsImagesAutomatically = value as Boolean
        "minimumLogicalFontSize" -> minimumLogicalFontSize = value as Int
        "initialScale" -> initialScale = value as Int
        "needInitialFocus" -> needInitialFocus = value as Boolean
        "offscreenPreRaster" -> offscreenPreRaster = value as Boolean
        "sansSerifFontFamily" -> sansSerifFontFamily = value as String
        "serifFontFamily" -> serifFontFamily = value as String
        "standardFontFamily" -> standardFontFamily = value as String
        "thirdPartyCookiesEnabled" -> thirdPartyCookiesEnabled = value as Boolean
        "hardwareAcceleration" -> hardwareAcceleration = value as Boolean
        "supportMultipleWindows" -> supportMultipleWindows = value as Boolean
        "regexToCancelSubFramesLoading" ->
          regexToCancelSubFramesLoading = Pattern.compile(value as String)
        "regexToAllowSyncUrlLoading" ->
          regexToAllowSyncUrlLoading = Pattern.compile(value as String)
        "overScrollMode" -> overScrollMode = value as Int
        "networkAvailable" -> networkAvailable = value as Boolean
        "scrollBarStyle" -> scrollBarStyle = value as Int
        "verticalScrollbarPosition" -> verticalScrollbarPosition = value as Int
        "scrollBarDefaultDelayBeforeFade" -> scrollBarDefaultDelayBeforeFade = value as Int
        "scrollbarFadingEnabled" -> scrollbarFadingEnabled = value as Boolean
        "scrollBarFadeDuration" -> scrollBarFadeDuration = value as Int
        "rendererPriorityPolicy" -> rendererPriorityPolicy = value as Map<String, Any?>
        "useShouldInterceptRequest" -> useShouldInterceptRequest = value as Boolean
        "useOnRenderProcessGone" -> useOnRenderProcessGone = value as Boolean
        "disableDefaultErrorPage" -> disableDefaultErrorPage = value as Boolean
        "useHybridComposition" -> useHybridComposition = value as Boolean
        "verticalScrollbarThumbColor" -> verticalScrollbarThumbColor = value as String
        "verticalScrollbarTrackColor" -> verticalScrollbarTrackColor = value as String
        "horizontalScrollbarThumbColor" -> horizontalScrollbarThumbColor = value as String
        "horizontalScrollbarTrackColor" -> horizontalScrollbarTrackColor = value as String
        "algorithmicDarkeningAllowed" -> algorithmicDarkeningAllowed = value as Boolean
        "enterpriseAuthenticationAppLinkPolicyEnabled" ->
          enterpriseAuthenticationAppLinkPolicyEnabled = value as Boolean
        "allowBackgroundAudioPlaying" -> allowBackgroundAudioPlaying = value as Boolean
        "webViewAssetLoader" -> webViewAssetLoader = value as Map<String, Any?>
        "defaultVideoPoster" -> defaultVideoPoster = value as ByteArray
        "javaScriptHandlersOriginAllowList" -> {
          val patterns = HashSet<Pattern>()
          for (pattern in value as List<String>) {
            patterns.add(Pattern.compile(pattern))
          }
          javaScriptHandlersOriginAllowList = patterns
        }
        "javaScriptHandlersForMainFrameOnly" ->
          javaScriptHandlersForMainFrameOnly = value as Boolean
        "javaScriptBridgeEnabled" -> javaScriptBridgeEnabled = value as Boolean
        "javaScriptBridgeOriginAllowList" ->
          javaScriptBridgeOriginAllowList = HashSet(value as List<String>)
        "javaScriptBridgeForMainFrameOnly" -> javaScriptBridgeForMainFrameOnly = value as Boolean
        "pluginScriptsOriginAllowList" ->
          pluginScriptsOriginAllowList = HashSet(value as List<String>)
        "pluginScriptsForMainFrameOnly" -> pluginScriptsForMainFrameOnly = value as Boolean
        "isUserInteractionEnabled" -> isUserInteractionEnabled = value as Boolean
        "alpha" -> alpha = value as Double
        "useOnShowFileChooser" -> useOnShowFileChooser = value as Boolean
      }
    }

    return this
  }

  override fun toMap(): MutableMap<String, Any?> {
    val settings = HashMap<String, Any?>()
    settings["useShouldOverrideUrlLoading"] = useShouldOverrideUrlLoading
    settings["useOnLoadResource"] = useOnLoadResource
    settings["useOnDownloadStart"] = useOnDownloadStart
    settings["userAgent"] = userAgent
    settings["applicationNameForUserAgent"] = applicationNameForUserAgent
    settings["javaScriptEnabled"] = javaScriptEnabled
    settings["javaScriptCanOpenWindowsAutomatically"] = javaScriptCanOpenWindowsAutomatically
    settings["mediaPlaybackRequiresUserGesture"] = mediaPlaybackRequiresUserGesture
    settings["minimumFontSize"] = minimumFontSize
    settings["verticalScrollBarEnabled"] = verticalScrollBarEnabled
    settings["horizontalScrollBarEnabled"] = horizontalScrollBarEnabled
    settings["resourceCustomSchemes"] = resourceCustomSchemes
    settings["contentBlockers"] = contentBlockers
    settings["preferredContentMode"] = preferredContentMode
    settings["useShouldInterceptAjaxRequest"] = useShouldInterceptAjaxRequest
    settings["useOnAjaxReadyStateChange"] = useOnAjaxReadyStateChange
    settings["useOnAjaxProgress"] = useOnAjaxProgress
    settings["interceptOnlyAsyncAjaxRequests"] = interceptOnlyAsyncAjaxRequests
    settings["useShouldInterceptFetchRequest"] = useShouldInterceptFetchRequest
    settings["incognito"] = incognito
    settings["cacheEnabled"] = cacheEnabled
    settings["transparentBackground"] = transparentBackground
    settings["disableVerticalScroll"] = disableVerticalScroll
    settings["disableHorizontalScroll"] = disableHorizontalScroll
    settings["disableContextMenu"] = disableContextMenu
    settings["textZoom"] = textZoom
    settings["builtInZoomControls"] = builtInZoomControls
    settings["displayZoomControls"] = displayZoomControls
    settings["supportZoom"] = supportZoom
    settings["databaseEnabled"] = databaseEnabled
    settings["domStorageEnabled"] = domStorageEnabled
    settings["useWideViewPort"] = useWideViewPort
    settings["safeBrowsingEnabled"] = safeBrowsingEnabled
    settings["mixedContentMode"] = mixedContentMode
    settings["allowContentAccess"] = allowContentAccess
    settings["allowFileAccess"] = allowFileAccess
    settings["allowFileAccessFromFileURLs"] = allowFileAccessFromFileURLs
    settings["allowUniversalAccessFromFileURLs"] = allowUniversalAccessFromFileURLs
    settings["appCachePath"] = appCachePath
    settings["blockNetworkImage"] = blockNetworkImage
    settings["blockNetworkLoads"] = blockNetworkLoads
    settings["cacheMode"] = cacheMode
    settings["cursiveFontFamily"] = cursiveFontFamily
    settings["defaultFixedFontSize"] = defaultFixedFontSize
    settings["defaultFontSize"] = defaultFontSize
    settings["defaultTextEncodingName"] = defaultTextEncodingName
    settings["disabledActionModeMenuItems"] = disabledActionModeMenuItems
    settings["fantasyFontFamily"] = fantasyFontFamily
    settings["fixedFontFamily"] = fixedFontFamily
    settings["geolocationEnabled"] = geolocationEnabled
    settings["layoutAlgorithm"] = getLayoutAlgorithm()
    settings["loadWithOverviewMode"] = loadWithOverviewMode
    settings["loadsImagesAutomatically"] = loadsImagesAutomatically
    settings["minimumLogicalFontSize"] = minimumLogicalFontSize
    settings["initialScale"] = initialScale
    settings["needInitialFocus"] = needInitialFocus
    settings["offscreenPreRaster"] = offscreenPreRaster
    settings["sansSerifFontFamily"] = sansSerifFontFamily
    settings["serifFontFamily"] = serifFontFamily
    settings["standardFontFamily"] = standardFontFamily
    settings["thirdPartyCookiesEnabled"] = thirdPartyCookiesEnabled
    settings["hardwareAcceleration"] = hardwareAcceleration
    settings["supportMultipleWindows"] = supportMultipleWindows
    settings["regexToCancelSubFramesLoading"] = regexToCancelSubFramesLoading?.pattern()
    settings["regexToAllowSyncUrlLoading"] = regexToAllowSyncUrlLoading?.pattern()
    settings["overScrollMode"] = overScrollMode
    settings["networkAvailable"] = networkAvailable
    settings["scrollBarStyle"] = scrollBarStyle
    settings["verticalScrollbarPosition"] = verticalScrollbarPosition
    settings["scrollBarDefaultDelayBeforeFade"] = scrollBarDefaultDelayBeforeFade
    settings["scrollbarFadingEnabled"] = scrollbarFadingEnabled
    settings["scrollBarFadeDuration"] = scrollBarFadeDuration
    settings["rendererPriorityPolicy"] = rendererPriorityPolicy
    settings["useShouldInterceptRequest"] = useShouldInterceptRequest
    settings["useOnRenderProcessGone"] = useOnRenderProcessGone
    settings["disableDefaultErrorPage"] = disableDefaultErrorPage
    settings["useHybridComposition"] = useHybridComposition
    settings["verticalScrollbarThumbColor"] = verticalScrollbarThumbColor
    settings["verticalScrollbarTrackColor"] = verticalScrollbarTrackColor
    settings["horizontalScrollbarThumbColor"] = horizontalScrollbarThumbColor
    settings["horizontalScrollbarTrackColor"] = horizontalScrollbarTrackColor
    settings["algorithmicDarkeningAllowed"] = algorithmicDarkeningAllowed
    settings["enterpriseAuthenticationAppLinkPolicyEnabled"] =
      enterpriseAuthenticationAppLinkPolicyEnabled
    settings["allowBackgroundAudioPlaying"] = allowBackgroundAudioPlaying
    settings["defaultVideoPoster"] = defaultVideoPoster
    settings["javaScriptHandlersOriginAllowList"] =
      javaScriptHandlersOriginAllowList?.map { it.pattern() }
    settings["javaScriptHandlersForMainFrameOnly"] = javaScriptHandlersForMainFrameOnly
    settings["javaScriptBridgeEnabled"] = javaScriptBridgeEnabled
    settings["javaScriptBridgeOriginAllowList"] = javaScriptBridgeOriginAllowList?.toList()
    settings["javaScriptBridgeForMainFrameOnly"] = javaScriptBridgeForMainFrameOnly
    settings["pluginScriptsOriginAllowList"] = pluginScriptsOriginAllowList?.toList()
    settings["pluginScriptsForMainFrameOnly"] = pluginScriptsForMainFrameOnly
    settings["isUserInteractionEnabled"] = isUserInteractionEnabled
    settings["alpha"] = alpha
    settings["useOnShowFileChooser"] = useOnShowFileChooser
    return settings
  }

  @SuppressLint("RestrictedApi")
  override fun getRealSettings(obj: InAppWebViewInterface): MutableMap<String, Any?> {
    val realSettings = toMap()
    if (obj is InAppWebView) {
      realSettings["alpha"] = obj.alpha

      val settings = obj.settings
      realSettings["userAgent"] = settings.userAgentString
      realSettings["javaScriptEnabled"] = settings.javaScriptEnabled
      realSettings["javaScriptCanOpenWindowsAutomatically"] =
        settings.javaScriptCanOpenWindowsAutomatically
      realSettings["mediaPlaybackRequiresUserGesture"] = settings.mediaPlaybackRequiresUserGesture
      realSettings["minimumFontSize"] = settings.minimumFontSize
      realSettings["verticalScrollBarEnabled"] = obj.isVerticalScrollBarEnabled
      realSettings["horizontalScrollBarEnabled"] = obj.isHorizontalScrollBarEnabled
      realSettings["textZoom"] = settings.textZoom
      realSettings["builtInZoomControls"] = settings.builtInZoomControls
      realSettings["supportZoom"] = settings.supportZoom()
      realSettings["displayZoomControls"] = settings.displayZoomControls
      realSettings["databaseEnabled"] = readDatabaseEnabled(settings)
      realSettings["domStorageEnabled"] = settings.domStorageEnabled
      realSettings["useWideViewPort"] = settings.useWideViewPort
      if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
        realSettings["safeBrowsingEnabled"] = WebSettingsCompat.getSafeBrowsingEnabled(settings)
      } else {
        realSettings["safeBrowsingEnabled"] = settings.safeBrowsingEnabled
      }
      realSettings["mixedContentMode"] = settings.mixedContentMode

      realSettings["allowContentAccess"] = settings.allowContentAccess
      realSettings["allowFileAccess"] = settings.allowFileAccess
      realSettings["allowFileAccessFromFileURLs"] = settings.allowFileAccessFromFileURLs
      realSettings["allowUniversalAccessFromFileURLs"] = settings.allowUniversalAccessFromFileURLs
      realSettings["blockNetworkImage"] = settings.blockNetworkImage
      realSettings["blockNetworkLoads"] = settings.blockNetworkLoads
      realSettings["cacheMode"] = settings.cacheMode
      realSettings["cursiveFontFamily"] = settings.cursiveFontFamily
      realSettings["defaultFixedFontSize"] = settings.defaultFixedFontSize
      realSettings["defaultFontSize"] = settings.defaultFontSize
      realSettings["defaultTextEncodingName"] = settings.defaultTextEncodingName
      if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
        realSettings["disabledActionModeMenuItems"] =
          WebSettingsCompat.getDisabledActionModeMenuItems(settings)
      }
      // NOTE: unconditionally overwrites the WebSettingsCompat value read just above. Carried
      // over from the Java verbatim.
      realSettings["disabledActionModeMenuItems"] = settings.disabledActionModeMenuItems

      realSettings["fantasyFontFamily"] = settings.fantasyFontFamily
      realSettings["fixedFontFamily"] = settings.fixedFontFamily
      realSettings["layoutAlgorithm"] = settings.layoutAlgorithm.name
      realSettings["loadWithOverviewMode"] = settings.loadWithOverviewMode
      realSettings["loadsImagesAutomatically"] = settings.loadsImagesAutomatically
      realSettings["minimumLogicalFontSize"] = settings.minimumLogicalFontSize
      if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
        realSettings["offscreenPreRaster"] = WebSettingsCompat.getOffscreenPreRaster(settings)
      } else {
        realSettings["offscreenPreRaster"] = settings.offscreenPreRaster
      }
      realSettings["sansSerifFontFamily"] = settings.sansSerifFontFamily
      realSettings["serifFontFamily"] = settings.serifFontFamily
      realSettings["standardFontFamily"] = settings.standardFontFamily
      realSettings["supportMultipleWindows"] = settings.supportMultipleWindows()
      realSettings["overScrollMode"] = obj.overScrollMode
      realSettings["scrollBarStyle"] = obj.scrollBarStyle
      realSettings["verticalScrollbarPosition"] = obj.verticalScrollbarPosition
      realSettings["scrollBarDefaultDelayBeforeFade"] = obj.scrollBarDefaultDelayBeforeFade
      realSettings["scrollbarFadingEnabled"] = obj.isScrollbarFadingEnabled
      realSettings["scrollBarFadeDuration"] = obj.scrollBarFadeDuration
      realSettings["rendererPriorityPolicy"] = hashMapOf<String, Any?>(
        "rendererRequestedPriority" to obj.rendererRequestedPriority,
        "waivedWhenNotVisible" to obj.rendererPriorityWaivedWhenNotVisible
      )

      if (WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING)) {
        realSettings["algorithmicDarkeningAllowed"] =
          WebSettingsCompat.isAlgorithmicDarkeningAllowed(settings)
      }
      if (WebViewFeature.isFeatureSupported(
          WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY
        )
      ) {
        realSettings["enterpriseAuthenticationAppLinkPolicyEnabled"] =
          WebSettingsCompat.getEnterpriseAuthenticationAppLinkPolicyEnabled(settings)
      }
    }
    return realSettings
  }

  private fun setLayoutAlgorithm(value: String?) {
    if (value != null) {
      when (value) {
        "NORMAL" -> layoutAlgorithm = WebSettings.LayoutAlgorithm.NORMAL
        "TEXT_AUTOSIZING" -> layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
      }
    }
  }

  private fun getLayoutAlgorithm(): String? = when (layoutAlgorithm) {
    WebSettings.LayoutAlgorithm.NORMAL -> "NORMAL"
    WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING -> "TEXT_AUTOSIZING"
    else -> null
  }

  companion object {
    const val LOG_TAG = "InAppWebViewSettings"

    // WebSettings.getDatabaseEnabled() is deprecated by Android with no replacement offered. The
    // matching setter is kept too (see InAppWebView.applyDatabaseEnabled), since `databaseEnabled`
    // is a documented plugin setting. Isolated so @Suppress covers only this call rather than the
    // whole of getRealSettings().
    @Suppress("DEPRECATION")
    private fun readDatabaseEnabled(settings: WebSettings): Boolean = settings.databaseEnabled
  }
}
