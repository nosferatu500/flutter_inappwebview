package dev.nosferatu500.inappwebview.proxy

import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class ProxyManager(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    init()

    when (call.method) {
      "setProxyOverride" -> {
        if (proxyController != null) {
          val settingsMap = call.argument<Map<String, Any?>>("settings")
          val settings = ProxySettings()
          if (settingsMap != null) {
            settings.parse(settingsMap)
          }
          setProxyOverride(settings, result)
        } else {
          result.success(false)
        }
      }

      "clearProxyOverride" -> {
        if (proxyController != null) {
          clearProxyOverride(result)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  private fun setProxyOverride(settings: ProxySettings, result: MethodChannel.Result) {
    val controller = proxyController ?: return
    val proxyConfigBuilder = ProxyConfig.Builder()
    for (bypassRule in settings.bypassRules) {
      proxyConfigBuilder.addBypassRule(bypassRule)
    }
    for (direct in settings.directs) {
      proxyConfigBuilder.addDirect(direct)
    }
    for (proxyRule in settings.proxyRules) {
      val schemeFilter = proxyRule.schemeFilter
      if (schemeFilter != null) {
        proxyConfigBuilder.addProxyRule(proxyRule.url, schemeFilter)
      } else {
        proxyConfigBuilder.addProxyRule(proxyRule.url)
      }
    }
    if (settings.bypassSimpleHostnames == true) {
      proxyConfigBuilder.bypassSimpleHostnames()
    }
    if (settings.removeImplicitRules == true) {
      proxyConfigBuilder.removeImplicitRules()
    }
    val reverseBypassEnabled = settings.reverseBypassEnabled
    if (reverseBypassEnabled != null &&
      WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS)
    ) {
      proxyConfigBuilder.setReverseBypassEnabled(reverseBypassEnabled)
    }
    controller.setProxyOverride(
      proxyConfigBuilder.build(),
      Executor { command -> command.run() }
    ) { result.success(true) }
  }

  private fun clearProxyOverride(result: MethodChannel.Result) {
    val controller = proxyController ?: return
    controller.clearProxyOverride(Executor { command -> command.run() }) { result.success(true) }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
  }

  companion object {
    protected const val LOG_TAG = "ProxyManager"
    const val METHOD_CHANNEL_NAME = "dev.nosferatu500.inappwebview/inappwebview_proxycontroller"

    @JvmField
    var proxyController: ProxyController? = null

    @JvmStatic
    fun init() {
      if (proxyController == null &&
        WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)
      ) {
        proxyController = ProxyController.getInstance()
      }
    }
  }
}
