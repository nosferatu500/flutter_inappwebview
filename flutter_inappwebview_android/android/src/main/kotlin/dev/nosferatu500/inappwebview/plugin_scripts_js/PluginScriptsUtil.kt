package dev.nosferatu500.inappwebview.plugin_scripts_js

import dev.nosferatu500.inappwebview.types.PluginScript
import dev.nosferatu500.inappwebview.types.UserScriptInjectionTime

object PluginScriptsUtil {

  @JvmField
  val VAR_PLACEHOLDER_VALUE: String = "\$IN_APP_WEBVIEW_PLACEHOLDER_VALUE"
  @JvmField
  val VAR_CONTENT_WORLD_NAME_ARRAY: String = "\$IN_APP_WEBVIEW_CONTENT_WORLD_NAME_ARRAY"
  @JvmField
  val VAR_CONTENT_WORLD_NAME: String = "\$IN_APP_WEBVIEW_CONTENT_WORLD_NAME"
  @JvmField
  val VAR_JSON_SOURCE_ENCODED: String = "\$IN_APP_WEBVIEW_JSON_SOURCE_ENCODED"
  @JvmField
  val VAR_FUNCTION_ARGUMENT_NAMES: String = "\$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_NAMES"
  @JvmField
  val VAR_FUNCTION_ARGUMENT_VALUES: String = "\$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_VALUES"
  @JvmField
  val VAR_FUNCTION_ARGUMENTS_OBJ: String = "\$IN_APP_WEBVIEW_FUNCTION_ARGUMENTS_OBJ"
  @JvmField
  val VAR_FUNCTION_BODY: String = "\$IN_APP_WEBVIEW_FUNCTION_BODY"
  @JvmField
  val VAR_RESULT_UUID: String = "\$IN_APP_WEBVIEW_RESULT_UUID"
  @JvmField
  val VAR_RANDOM_NAME: String = "\$IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME"
  @JvmStatic
  fun CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE(): String =
    "(function(obj) {" +
      "  (async function(" + VAR_FUNCTION_ARGUMENT_NAMES + ") {" +
      "    \n" + VAR_FUNCTION_BODY + "\n" +
      "  })(" + VAR_FUNCTION_ARGUMENT_VALUES + ").then(function(value) {" +
      "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('callAsyncJavaScript', {'value': value, 'error': null, 'resultUuid': '" + VAR_RESULT_UUID + "'});" +
      "  }).catch(function(error) {" +
      "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('callAsyncJavaScript', {'value': null, 'error': error + '', 'resultUuid': '" + VAR_RESULT_UUID + "'});" +
      "  });" +
      "  return null;" +
      "})(" + VAR_FUNCTION_ARGUMENTS_OBJ + ");"
  @JvmStatic
  fun EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE(): String =
    "var \$IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME = null;" +
      "try {" +
      "  \$IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME = eval(" + VAR_PLACEHOLDER_VALUE + ");" +
      "} catch(e) {" +
      "  console.error(e);" +
      "}" +
      "window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('evaluateJavaScriptWithContentWorld', {'value': \$IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME, 'resultUuid': '" + VAR_RESULT_UUID + "'});"
  @JvmField
  val IS_ACTIVE_ELEMENT_INPUT_EDITABLE_JS_SOURCE: String =
    "var activeEl = document.activeElement;" +
      "var nodeName = (activeEl != null) ? activeEl.nodeName.toLowerCase() : '';" +
      "var isActiveElementInputEditable = activeEl != null && " +
      "(activeEl.nodeType == 1 && (nodeName == 'textarea' || (nodeName == 'input' && /^(?:text|email|number|search|tel|url|password)\$/i.test(activeEl.type != null ? activeEl.type : 'text')))) && " +
      "!activeEl.disabled && !activeEl.readOnly;" +
      "var isActiveElementEditable = isActiveElementInputEditable || (activeEl != null && activeEl.isContentEditable) || document.designMode === 'on';"

  // android Workaround to hide context menu when selected text is empty
  // and the document active element is not an input element.
  @JvmField
  val CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE: String = "(function(){" +
    "  var txt;" +
    "  if (window.getSelection) {" +
    "    txt = window.getSelection().toString();" +
    "  } else if (window.document.getSelection) {" +
    "    txt = window.document.getSelection().toString();" +
    "  } else if (window.document.selection) {" +
    "    txt = window.document.selection.createRange().text;" +
    "  }" +
    IS_ACTIVE_ELEMENT_INPUT_EDITABLE_JS_SOURCE +
    "  return txt === '' && !isActiveElementEditable;" +
    "})();"
  @JvmField
  val GET_SELECTED_TEXT_JS_SOURCE: String = "(function(){" +
    "  var txt;" +
    "  if (window.getSelection) {" +
    "    txt = window.getSelection().toString();" +
    "  } else if (window.document.getSelection) {" +
    "    txt = window.document.getSelection().toString();" +
    "  } else if (window.document.selection) {" +
    "    txt = window.document.selection.createRange().text;" +
    "  }" +
    "  return txt;" +
    "})();"
  @JvmField
  val CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT_GROUP_NAME: String = "CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT"
  @JvmStatic
  fun CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT(allowedOriginRules: Set<String>?, forMainFrameOnly: Boolean): PluginScript =
    PluginScript(
      PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT_GROUP_NAME,
      PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_SOURCE(),
      UserScriptInjectionTime.AT_DOCUMENT_START,
      null,
      false,
      allowedOriginRules,
      forMainFrameOnly
    )

  // android Workaround to hide context menu when user emit a keydown event
  @JvmStatic
  fun CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_SOURCE(): String =
    "(function(){" +
      "  document.addEventListener('keydown', function(e) {" +
      "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "._hideContextMenu();" +
      "  });" +
      "})();"
}
