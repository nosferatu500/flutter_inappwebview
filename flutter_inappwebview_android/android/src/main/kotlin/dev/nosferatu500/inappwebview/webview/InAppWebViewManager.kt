package dev.nosferatu500.inappwebview.webview

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Message
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.pigeons.InAppWebViewManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.WebViewPackageInfoData
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.types.Disposable
import dev.nosferatu500.inappwebview.types.replyingOnThrow
import dev.nosferatu500.inappwebview.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.BinaryMessenger

/**
 * The process-wide statics of `InAppWebViewController`, plus the keep-alive and window-message
 * registries the rest of the plugin reads.
 *
 * Transport is Pigeon-generated ([InAppWebViewManagerHostApi]) rather than a hand-written
 * `MethodChannel`; the seventeenth channel migrated, at **fifteen host methods and no events**. The
 * manager implements the generated interface directly, as `FindInteractionController` does — it is
 * not a separate delegate because nothing else on it is channel-shaped.
 *
 * **Two of the fifteen are `@async`** — [clearClientCertPreferences] and [setSafeBrowsingAllowlist]
 * answer from a platform callback — and Pigeon wraps `@async` handlers in nothing, so both run inside
 * §172's [replyingOnThrow]. The other thirteen answer inline and Pigeon's own `try`/`catch` covers
 * them (read in the generated output: thirteen wrapped handlers, two bare).
 *
 * The class-level `@Suppress("UNCHECKED_CAST")` is **gone** with the `call.argument` reads.
 *
 * 🚨 **Two internal helpers were renamed to make room for the host methods**, because the generated
 * interface contributes `disposeKeepAlive(String): Boolean` — the same name and parameters as the old
 * `disposeKeepAlive(String): Unit`, which Kotlin rejects (§177's collision, third occurrence). They
 * are now private [disposeKeepAliveWebView] and [clearAllCacheWith]; nothing outside this file called
 * either (checked).
 */
class InAppWebViewManager(plugin: InAppWebViewFlutterPlugin) :
  Disposable,
  InAppWebViewManagerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  private var messenger: BinaryMessenger? = plugin.messenger

  // Values go null rather than being removed: disposeKeepAlive() nulls the slot so the id stays
  // known.
  @JvmField
  val keepAliveWebViews: MutableMap<String, FlutterWebView?> = HashMap()

  @JvmField
  val windowWebViewMessages: MutableMap<Int, Message> = HashMap()

  @JvmField
  var windowAutoincrementId = 0

  init {
    InAppWebViewManagerHostApi.setUp(plugin.messenger, this)
  }

  override fun getDefaultUserAgent(): String? =
    plugin?.let { WebSettings.getDefaultUserAgent(it.applicationContext) }

  override fun clearClientCertPreferences(callback: (Result<Boolean>) -> Unit) {
    replyingOnThrow("clearClientCertPreferences", callback) { reply ->
      WebView.clearClientCertPreferences { reply(Result.success(true)) }
    }
  }

  override fun getSafeBrowsingPrivacyPolicyUrl(): String? =
    if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL)) {
      WebViewCompat.getSafeBrowsingPrivacyPolicyUrl().toString()
    } else {
      null
    }

  override fun setSafeBrowsingAllowlist(hosts: List<String>, callback: (Result<Boolean>) -> Unit) {
    replyingOnThrow("setSafeBrowsingAllowlist", callback) { reply ->
      if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ALLOWLIST)) {
        WebViewCompat.setSafeBrowsingAllowlist(HashSet(hosts)) { value ->
          reply(Result.success(value))
        }
      } else {
        reply(Result.success(false))
      }
    }
  }

  override fun getCurrentWebViewPackage(): WebViewPackageInfoData? {
    val context = plugin?.let { it.activity ?: it.applicationContext }
    return context?.let { WebViewCompat.getCurrentWebViewPackage(it) }?.toPigeon()
  }

  override fun setWebContentsDebuggingEnabled(debuggingEnabled: Boolean): Boolean {
    WebView.setWebContentsDebuggingEnabled(debuggingEnabled)
    return true
  }

  override fun getVariationsHeader(): String? =
    if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_VARIATIONS_HEADER)) {
      WebViewCompat.getVariationsHeader()
    } else {
      null
    }

  override fun isMultiProcessEnabled(): Boolean =
    if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROCESS)) {
      WebViewCompat.isMultiProcessEnabled()
    } else {
      false
    }

  /**
   * `toInt()` keeps the low 32 bits, so the unsigned form the androidx javadoc writes the reserved
   * tags in (`0xFFFFFF00`, above `Int.MAX_VALUE` and so a `Long` on the wire) still maps to the same
   * tag — exactly what the hand-written `call.argument<Number>("tag")!!.toInt()` did.
   */
  override fun setDefaultTrafficStatsTag(tag: Long): Boolean {
    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DEFAULT_TRAFFICSTATS_TAGGING)) {
      // setDefaultTrafficStatsTag throws UnsupportedOperationException when the feature is
      // missing, so the gate is required, not defensive.
      return false
    }
    WebViewCompat.setDefaultTrafficStatsTag(tag.toInt())
    return true
  }

  override fun disableWebView(): Boolean {
    WebView.disableWebView()
    return true
  }

  override fun disposeKeepAlive(keepAliveId: String): Boolean {
    disposeKeepAliveWebView(keepAliveId)
    return true
  }

  override fun clearAllCache(includeDiskFiles: Boolean): Boolean {
    val context = plugin?.let { it.activity ?: it.applicationContext }
    if (context != null) {
      clearAllCacheWith(context, includeDiskFiles)
    }
    return true
  }

  override fun enableSlowWholeDocumentDraw(): Boolean {
    WebView.enableSlowWholeDocumentDraw()
    return true
  }

  override fun setJavaScriptBridgeName(bridgeName: String): Boolean {
    JavaScriptBridgeJS.set_JAVASCRIPT_BRIDGE_NAME(bridgeName)
    return true
  }

  override fun getJavaScriptBridgeName(): String = JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()

  private fun disposeKeepAliveWebView(keepAliveId: String) {
    val flutterWebView = keepAliveWebViews[keepAliveId]
    if (flutterWebView != null) {
      flutterWebView.keepAliveId = null
      // be sure to remove the view from the previous parent.
      val view = flutterWebView.getView()
      (view?.parent as ViewGroup?)?.removeView(view)
      flutterWebView.dispose()
    }
    if (keepAliveWebViews.containsKey(keepAliveId)) {
      keepAliveWebViews[keepAliveId] = null
    }
  }

  private fun clearAllCacheWith(context: Context, includeDiskFiles: Boolean) {
    val tempWebView = WebView(context)
    tempWebView.clearCache(includeDiskFiles)
    tempWebView.destroy()
  }

  override fun dispose() {
    // Unregisters every generated handler. Skipping it would leave them bound to a disposed manager
    // for the life of the messenger.
    messenger?.let { InAppWebViewManagerHostApi.setUp(it, null) }
    messenger = null
    for (flutterWebView in keepAliveWebViews.values.toList()) {
      flutterWebView?.keepAliveId?.let { disposeKeepAliveWebView(it) }
    }
    keepAliveWebViews.clear()
    windowWebViewMessages.clear()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "InAppWebViewManager"
    // METHOD_CHANNEL_NAME is gone with the migration: Pigeon derives its own channel names from the
    // schema. Checked unfiltered for other users first (§182's rule); there were none in Kotlin.
  }
}

private fun PackageInfo.toPigeon(): WebViewPackageInfoData =
  WebViewPackageInfoData(versionName = versionName, packageName = packageName)
