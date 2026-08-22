package dev.nosferatu500.inappwebview

import android.webkit.ValueCallback
import android.webkit.WebStorage
import androidx.webkit.WebStorageCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MyWebStorage(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    init()

    when (call.method) {
      "getOrigins" -> getOrigins(result)

      "deleteAllData" -> {
        val manager = webStorageManager
        if (manager != null) {
          manager.deleteAllData()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "deleteOrigin" -> {
        val manager = webStorageManager
        if (manager != null) {
          manager.deleteOrigin(call.argument("origin"))
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "deleteBrowsingData" -> deleteBrowsingData(result)

      "deleteBrowsingDataForSite" ->
        deleteBrowsingDataForSite(call.argument("site")!!, result)

      "getQuotaForOrigin" -> getQuotaForOrigin(call.argument("origin"), result)

      "getUsageForOrigin" -> getUsageForOrigin(call.argument("origin"), result)

      else -> result.notImplemented()
    }
  }

  // The raw Map is forced by the platform signature, which is literally
  // WebStorage.getOrigins(ValueCallback<Map>) -- verified against android.jar. Parameterizing the
  // callback would no longer match the parameter type, so this cannot be typed away.
  @Suppress("UNCHECKED_CAST")
  fun getOrigins(result: MethodChannel.Result) {
    val manager = webStorageManager
    if (manager == null) {
      result.success(ArrayList<Any?>())
      return
    }
    manager.getOrigins(ValueCallback<Map<*, *>> { value ->
      val origins = mutableListOf<Map<String, Any?>>()
      for (key in value.keys) {
        val originObj = value[key] as WebStorage.Origin
        origins.add(
          hashMapOf(
            "origin" to originObj.origin,
            "quota" to originObj.quota,
            "usage" to originObj.usage
          )
        )
      }
      result.success(origins)
    } as ValueCallback<Map<Any?, Any?>>)
  }

  // Both of these deliberately use the WebStorageCompat overloads that post the done callback to
  // the main looper, rather than the Executor ones: onMethodCall already runs there, a
  // MethodChannel.Result must be replied to on the main thread anyway, and -- for
  // deleteBrowsingDataForSite -- it is what makes reading the returned domain inside the callback
  // safe. See deleteBrowsingDataForSite below.
  fun deleteBrowsingData(result: MethodChannel.Result) {
    val manager = webStorageManager
    if (manager == null ||
      !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)
    ) {
      // WebStorageCompat.deleteBrowsingData throws UnsupportedOperationException when the feature
      // is missing, so the gate is required rather than defensive.
      result.success(false)
      return
    }
    WebStorageCompat.deleteBrowsingData(manager) { result.success(true) }
  }

  fun deleteBrowsingDataForSite(site: String, result: MethodChannel.Result) {
    val manager = webStorageManager
    if (manager == null ||
      !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)
    ) {
      result.success(null)
      return
    }
    try {
      // deleteBrowsingDataForSite returns the domain it actually deleted for -- the site part of
      // the argument, so "www.example.com" comes back as "example.com" -- and reports completion
      // through the callback. Assigning the return value before the callback can run is safe only
      // because the callback is posted to the main looper we are currently on; with the Executor
      // overload this would be a genuine race.
      var domain: String? = null
      domain = WebStorageCompat.deleteBrowsingDataForSite(manager, site) {
        result.success(domain)
      }
    } catch (e: IllegalArgumentException) {
      // Thrown when the site cannot be parsed as a domain name.
      result.error(LOG_TAG, e.message, null)
    }
  }

  fun getQuotaForOrigin(origin: String?, result: MethodChannel.Result) {
    val manager = webStorageManager
    if (manager == null) {
      result.success(0)
      return
    }
    manager.getQuotaForOrigin(origin) { value -> result.success(value) }
  }

  fun getUsageForOrigin(origin: String?, result: MethodChannel.Result) {
    val manager = webStorageManager
    if (manager == null) {
      result.success(0)
      return
    }
    manager.getUsageForOrigin(origin) { value -> result.success(value) }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "MyWebStorage"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_webstoragemanager"

    @JvmField
    var webStorageManager: WebStorage? = null

    @JvmStatic
    fun init() {
      if (webStorageManager == null) {
        webStorageManager = WebStorage.getInstance()
      }
    }
  }
}
