package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.Serializable
import java.util.UUID

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
//
// See ChannelDelegateImpl: `this` is published to a platform-thread-only dispatcher.
@Suppress("UNCHECKED_CAST")
class ChromeSafariBrowserManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  @JvmField
  var id: String = UUID.randomUUID().toString()

  @JvmField
  val browsers: MutableMap<String, ChromeCustomTabsActivity?> = HashMap()

  init {
    shared[id] = this
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val viewId = call.argument<String>("id")
    val activity = plugin?.activity

    when (call.method) {
      "open" -> {
        if (activity != null) {
          open(
            activity,
            viewId,
            call.argument("url"),
            call.argument<HashMap<String, Any?>>("headers"),
            call.argument("referrer"),
            call.argument<ArrayList<String>>("otherLikelyURLs"),
            call.argument<HashMap<String, Any?>>("settings"),
            call.argument<HashMap<String, Any?>>("actionButton"),
            call.argument<HashMap<String, Any?>>("secondaryToolbar"),
            call.argument<List<HashMap<String, Any?>>>("menuItemList"),
            result
          )
        } else {
          result.success(false)
        }
      }

      "isAvailable" -> {
        if (activity != null) {
          result.success(CustomTabActivityHelper.isAvailable(activity))
        } else {
          result.success(false)
        }
      }

      "getMaxToolbarItems" -> result.success(CustomTabsIntent.getMaxToolbarItems())

      "getPackageName" -> {
        if (activity != null) {
          val packages = call.argument<ArrayList<String>>("packages")
          val ignoreDefault = call.argument<Boolean>("ignoreDefault")!!
          result.success(CustomTabsClient.getPackageName(activity, packages, ignoreDefault))
        } else {
          result.success(null)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun open(
    activity: Activity,
    viewId: String?,
    url: String?,
    headers: HashMap<String, Any?>?,
    referrer: String?,
    otherLikelyURLs: ArrayList<String>?,
    settings: HashMap<String, Any?>?,
    actionButton: HashMap<String, Any?>?,
    secondaryToolbar: HashMap<String, Any?>?,
    menuItemList: List<HashMap<String, Any?>>?,
    result: MethodChannel.Result
  ) {
    val extras = Bundle()
    extras.putString("url", url)
    extras.putString("id", viewId)
    extras.putString("managerId", id)
    extras.putSerializable("headers", headers)
    extras.putString("referrer", referrer)
    extras.putSerializable("otherLikelyURLs", otherLikelyURLs)
    extras.putSerializable("settings", settings)
    extras.putSerializable("actionButton", actionButton as Serializable?)
    extras.putSerializable("secondaryToolbar", secondaryToolbar as Serializable?)
    extras.putSerializable("menuItemList", menuItemList as Serializable?)

    val settingsMap: Map<String, Any?> = settings ?: emptyMap()
    val isSingleInstance = Util.getOrDefault(settingsMap, "isSingleInstance", false)
    val isTrustedWebActivity = Util.getOrDefault(settingsMap, "isTrustedWebActivity", false)
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
      if (Util.getOrDefault(settingsMap, "noHistory", false)) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
      }
      activity.startActivity(intent)
      result.success(true)
      return
    }

    result.error(LOG_TAG, "ChromeCustomTabs is not available!", null)
  }

  override fun dispose() {
    super.dispose()
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
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/chromesafaribrowser"

    @JvmField
    val shared: MutableMap<String, ChromeSafariBrowserManager> = HashMap()
  }
}
