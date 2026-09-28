package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.pigeons.ChromeSafariBrowserManagerHostApi
import dev.nosferatu500.inappwebview.pigeons.ChromeSafariBrowserOpenRequestData
import dev.nosferatu500.inappwebview.pigeons.FlutterError
import io.flutter.plugin.common.BinaryMessenger
import java.io.Serializable
import java.util.UUID

/**
 * Opens Custom Tabs, over Pigeon (§201). Implements [ChromeSafariBrowserManagerHostApi] directly,
 * as `InAppBrowserManager` does since §197.
 *
 * The four map-valued fields of [ChromeSafariBrowserOpenRequestData] go into the Bundle as the maps
 * Dart sent (§194, decision B). Each passes through [Util.normalizeCodecInts] first, because Pigeon
 * delivers their nested ints as `Long` where the Activity's parsers cast `as Int` (§197). The
 * normalized settings map is also the one this manager reads its three launch settings from, by
 * key presence, so a null-valued key still fails as it did (§200).
 */
class ChromeSafariBrowserManager(plugin: InAppWebViewFlutterPlugin) :
  ChromeSafariBrowserManagerHostApi {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var id: String = UUID.randomUUID().toString()

  @JvmField
  val browsers: MutableMap<String, ChromeCustomTabsActivity?> = HashMap()

  private var messenger: BinaryMessenger? = plugin.messenger

  init {
    shared[id] = this
    ChromeSafariBrowserManagerHostApi.setUp(plugin.messenger, this)
  }

  override fun open(request: ChromeSafariBrowserOpenRequestData): Boolean {
    val activity = plugin?.activity ?: return false
    startBrowser(activity, request)
    return true
  }

  override fun isAvailable(): Boolean {
    val activity = plugin?.activity ?: return false
    return CustomTabActivityHelper.isAvailable(activity)
  }

  override fun getMaxToolbarItems(): Long = CustomTabsIntent.getMaxToolbarItems().toLong()

  override fun getPackageName(packages: List<String>?, ignoreDefault: Boolean): String? {
    val activity = plugin?.activity ?: return null
    return CustomTabsClient.getPackageName(activity, packages, ignoreDefault)
  }

  /**
   * Renamed from `open` (rule 7: it shared the host method's name). Throws [FlutterError] when
   * Custom Tabs are unavailable, with the code, message and details the hand-written channel's
   * `result.error` used, so Dart sees the same `PlatformException`.
   */
  private fun startBrowser(activity: Activity, request: ChromeSafariBrowserOpenRequestData) {
    @Suppress("UNCHECKED_CAST")
    val settings = Util.normalizeCodecInts(request.settings) as HashMap<String, Any?>

    val extras = Bundle()
    extras.putString("url", request.url)
    extras.putString("id", request.id)
    extras.putString("managerId", id)
    // Copied into the `Serializable` types the Activity reads back (`HashMap`, and `ArrayList` for
    // `getStringArrayList`); the codec's own collection types are not part of Pigeon's contract.
    extras.putSerializable("headers", request.headers?.let { HashMap(it) })
    extras.putString("referrer", request.referrer)
    extras.putSerializable("otherLikelyURLs", request.otherLikelyURLs?.let { ArrayList(it) })
    extras.putSerializable("settings", settings)
    extras.putSerializable(
      "actionButton", Util.normalizeCodecInts(request.actionButton) as Serializable?
    )
    extras.putSerializable(
      "secondaryToolbar", Util.normalizeCodecInts(request.secondaryToolbar) as Serializable?
    )
    extras.putSerializable(
      "menuItemList", Util.normalizeCodecInts(request.menuItemList) as Serializable
    )

    val isSingleInstance = Util.getOrDefault(settings, "isSingleInstance", false)
    val isTrustedWebActivity = Util.getOrDefault(settings, "isTrustedWebActivity", false)
    if (CustomTabActivityHelper.isAvailable(activity)) {
      val target = if (!isSingleInstance) {
        if (!isTrustedWebActivity) {
          ChromeCustomTabsActivity::class.java
        } else {
          TrustedWebActivity::class.java
        }
      } else {
        if (!isTrustedWebActivity) {
          ChromeCustomTabsActivitySingleInstance::class.java
        } else {
          TrustedWebActivitySingleInstance::class.java
        }
      }
      val intent = Intent(activity, target)
      intent.putExtras(extras)
      if (Util.getOrDefault(settings, "noHistory", false)) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
      }
      activity.startActivity(intent)
      return
    }

    throw FlutterError(LOG_TAG, "ChromeCustomTabs is not available!", null)
  }

  fun dispose() {
    messenger?.let { ChromeSafariBrowserManagerHostApi.setUp(it, null) }
    messenger = null
    for (browser in browsers.values) {
      if (browser != null) {
        browser.close()
        browser.dispose()
      }
    }
    browsers.clear()
    shared.remove(id)
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "ChromeBrowserManager"

    @JvmField
    val shared: MutableMap<String, ChromeSafariBrowserManager> = HashMap()
  }
}
