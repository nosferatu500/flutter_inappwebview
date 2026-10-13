package dev.nosferatu500.inappwebview.plugin_scripts_js

import dev.nosferatu500.inappwebview.types.PluginScript
import dev.nosferatu500.inappwebview.types.UserScriptInjectionTime

object PrintJS {
  @JvmField
  val PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME: String = "IN_APP_WEBVIEW_PRINT_JS_PLUGIN_SCRIPT"
  @JvmStatic
  fun PRINT_JS_PLUGIN_SCRIPT(allowedOriginRules: Set<String>?, forMainFrameOnly: Boolean): PluginScript =
    PluginScript(
      PrintJS.PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME,
      PrintJS.PRINT_JS_SOURCE(),
      UserScriptInjectionTime.AT_DOCUMENT_START,
      null,
      false,
      allowedOriginRules,
      forMainFrameOnly
    )
  @JvmStatic
  fun PRINT_JS_SOURCE(): String =
    "window.print = function() {" +
      "  if (window.top == null || window.top === window) {" +
      "     window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('onPrintRequest', window.location.href);" +
      "  } else {" +
      "     window.top.print();" +
      "  }" +
      "};"
}
