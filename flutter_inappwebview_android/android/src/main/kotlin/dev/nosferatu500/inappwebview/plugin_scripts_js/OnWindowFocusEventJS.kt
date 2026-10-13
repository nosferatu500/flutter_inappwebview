package dev.nosferatu500.inappwebview.plugin_scripts_js

import dev.nosferatu500.inappwebview.types.PluginScript
import dev.nosferatu500.inappwebview.types.UserScriptInjectionTime

object OnWindowFocusEventJS {
  @JvmField
  val ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME: String = "IN_APP_WEBVIEW_ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT"

  // This plugin is only for main frame
  @JvmStatic
  fun ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT(allowedOriginRules: Set<String>?): PluginScript =
    PluginScript(
      OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
      OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_SOURCE(),
      UserScriptInjectionTime.AT_DOCUMENT_START,
      null,
      false,
      allowedOriginRules,
      true
    )
  @JvmStatic
  fun ON_WINDOW_FOCUS_EVENT_JS_SOURCE(): String =
    "(function(){" +
      "  window.addEventListener('focus', function(e) {" +
      "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('onWindowFocus');" +
      "  });" +
      "})();"
}
