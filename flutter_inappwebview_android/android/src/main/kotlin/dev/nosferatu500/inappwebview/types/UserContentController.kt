package dev.nosferatu500.inappwebview.types

import android.annotation.SuppressLint
import android.text.TextUtils
import android.webkit.WebView
import androidx.webkit.ScriptHandler
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.Util
import dev.nosferatu500.inappwebview.plugin_scripts_js.JavaScriptBridgeJS
import dev.nosferatu500.inappwebview.plugin_scripts_js.PluginScriptsUtil
import org.json.JSONObject

@SuppressLint("RestrictedApi")
class UserContentController(@JvmField var webView: WebView?) : Disposable {

  private val contentWorlds: MutableSet<ContentWorld> = hashSetOf(ContentWorld.PAGE)

  private val scriptHandlerMap: MutableMap<UserScript, ScriptHandler> = HashMap()

  private var contentWorldsCreatorScript: ScriptHandler? = null

  private val userOnlyScripts: Map<UserScriptInjectionTime, LinkedHashSet<UserScript>> = mapOf(
    UserScriptInjectionTime.AT_DOCUMENT_START to LinkedHashSet(),
    UserScriptInjectionTime.AT_DOCUMENT_END to LinkedHashSet()
  )

  private val pluginScripts: Map<UserScriptInjectionTime, LinkedHashSet<PluginScript>> = mapOf(
    UserScriptInjectionTime.AT_DOCUMENT_START to LinkedHashSet(),
    UserScriptInjectionTime.AT_DOCUMENT_END to LinkedHashSet()
  )

  fun generateWrappedCodeForDocumentStart(): String = Util.replaceAll(
    DOCUMENT_READY_WRAPPER_JS_SOURCE,
    PluginScriptsUtil.VAR_PLACEHOLDER_VALUE,
    generateCodeForDocumentStart()
  )

  fun generateWrappedCodeForDocumentEnd(): String {
    val injectionTime = UserScriptInjectionTime.AT_DOCUMENT_END
    var js = ""
    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      // try to reload scripts if they were not loaded during the AT_DOCUMENT_START event
      js += generateCodeForDocumentStart()
    }
    js += generatePluginScriptsCodeAt(injectionTime)
    js += generateUserOnlyScriptsCodeAt(injectionTime)
    return USER_SCRIPTS_AT_DOCUMENT_END_WRAPPER_JS_SOURCE()
      .replace(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, js)
  }

  fun generateCodeForDocumentStart(): String {
    val injectionTime = UserScriptInjectionTime.AT_DOCUMENT_START
    var js = ""
    js += generatePluginScriptsCodeAt(injectionTime)
    js += generateContentWorldsCreatorCode()
    js += generateUserOnlyScriptsCodeAt(injectionTime)
    return USER_SCRIPTS_AT_DOCUMENT_START_WRAPPER_JS_SOURCE()
      .replace(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, js)
  }

  fun generateContentWorldsCreatorCode(): String {
    if (contentWorlds.size == 1) {
      return ""
    }

    val source = StringBuilder()
    for (script in getPluginScriptsRequiredInAllContentWorlds()) {
      source.append(script.source)
    }
    val contentWorldsNames = mutableListOf<String>()
    for (contentWorld in contentWorlds) {
      if (contentWorld == ContentWorld.PAGE) {
        continue
      }
      contentWorldsNames.add("'" + escapeContentWorldName(contentWorld.name) + "'")
    }

    return CONTENT_WORLDS_GENERATOR_JS_SOURCE()
      .replace(
        PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY,
        TextUtils.join(", ", contentWorldsNames)
      )
      .replace(PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED, escapeCode(source.toString()))
  }

  fun generatePluginScriptsCodeAt(injectionTime: UserScriptInjectionTime): String {
    val js = StringBuilder()
    for (script in getPluginScriptsAt(injectionTime)) {
      var source = ";" + script.source
      source = wrapSourceCodeInContentWorld(script.contentWorld, source)
      source = wrapSourceCodeAddChecks(source, script)
      js.append(source)
    }
    return js.toString()
  }

  fun generateUserOnlyScriptsCodeAt(injectionTime: UserScriptInjectionTime): String {
    val js = StringBuilder()
    for (script in getUserOnlyScriptsAt(injectionTime)) {
      var source = ";" + script.source
      source = wrapSourceCodeInContentWorld(script.contentWorld, source)
      source = wrapSourceCodeAddChecks(source, script)
      js.append(source)
    }
    return js.toString()
  }

  fun generateCodeForScriptEvaluation(source: String, contentWorld: ContentWorld?): String {
    if (contentWorld != null && contentWorld != ContentWorld.PAGE) {
      val sourceWrapped = StringBuilder()
      if (!contentWorlds.contains(contentWorld)) {
        contentWorlds.add(contentWorld)

        val pluginScriptsSource = StringBuilder()
        for (script in getPluginScriptsRequiredInAllContentWorlds()) {
          pluginScriptsSource.append(script.source)
        }
        val contentWorldCreatorCode = CONTENT_WORLDS_GENERATOR_JS_SOURCE()
          .replace(
            PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY,
            "'" + escapeContentWorldName(contentWorld.name) + "'"
          )
          .replace(
            PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED,
            escapeCode(pluginScriptsSource.toString())
          )
        sourceWrapped.append(contentWorldCreatorCode).append(";")
      }
      return sourceWrapped.append(wrapSourceCodeInContentWorld(contentWorld, source)).toString()
    }
    return source
  }

  fun wrapSourceCodeInContentWorld(contentWorld: ContentWorld?, source: String): String =
    if (contentWorld == null || contentWorld == ContentWorld.PAGE) {
      source
    } else {
      CONTENT_WORLD_WRAPPER_JS_SOURCE()
        .replace(
          PluginScriptsUtil.VAR_CONTENT_WORLD_NAME,
          escapeContentWorldName(contentWorld.name)
        )
        .replace(PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED, escapeCode(source))
    }

  fun getUserOnlyScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<UserScript> =
    LinkedHashSet(userOnlyScripts[injectionTime]!!)

  private fun updateContentWorldsCreatorScript() {
    val source = generateContentWorldsCreatorCode()
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      contentWorldsCreatorScript?.remove()
      val view = webView
      if (source.isNotEmpty() && view != null) {
        contentWorldsCreatorScript =
          WebViewCompat.addDocumentStartJavaScript(view, source, hashSetOf("*"))
      }
    }
  }

  fun addUserOnlyScript(userOnlyScript: UserScript): Boolean {
    contentWorlds.add(userOnlyScript.contentWorld)
    updateContentWorldsCreatorScript()
    val view = webView
    if (view != null && WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      var source = userOnlyScript.source
      if (userOnlyScript.injectionTime == UserScriptInjectionTime.AT_DOCUMENT_END) {
        source = "if (document.readyState === 'complete') { $source} else { " +
          "window.addEventListener('load', function() { $source }); }"
      }
      source = wrapSourceCodeAddChecks(source, userOnlyScript)

      val scriptHandler = WebViewCompat.addDocumentStartJavaScript(
        view,
        wrapSourceCodeInContentWorld(userOnlyScript.contentWorld, source),
        userOnlyScript.allowedOriginRules
      )
      scriptHandlerMap[userOnlyScript] = scriptHandler
    }
    return userOnlyScripts[userOnlyScript.injectionTime]!!.add(userOnlyScript)
  }

  fun addUserOnlyScripts(userOnlyScripts: List<UserScript>) {
    for (userOnlyScript in userOnlyScripts) {
      addUserOnlyScript(userOnlyScript)
    }
  }

  fun removeUserOnlyScript(userOnlyScript: UserScript): Boolean {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      scriptHandlerMap[userOnlyScript]?.let {
        it.remove()
        scriptHandlerMap.remove(userOnlyScript)
      }
      updateContentWorldsCreatorScript()
    }
    return userOnlyScripts[userOnlyScript.injectionTime]!!.remove(userOnlyScript)
  }

  fun removeUserOnlyScriptAt(index: Int, injectionTime: UserScriptInjectionTime): Boolean {
    val userOnlyScript = ArrayList(userOnlyScripts[injectionTime]!!)[index]
    return removeUserOnlyScript(userOnlyScript)
  }

  fun removeAllUserOnlyScripts() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      for (injectionTime in UserScriptInjectionTime.entries) {
        for (userOnlyScript in userOnlyScripts[injectionTime]!!) {
          scriptHandlerMap[userOnlyScript]?.let {
            it.remove()
            scriptHandlerMap.remove(userOnlyScript)
          }
        }
      }
    }
    userOnlyScripts[UserScriptInjectionTime.AT_DOCUMENT_START]!!.clear()
    userOnlyScripts[UserScriptInjectionTime.AT_DOCUMENT_END]!!.clear()
  }

  fun getPluginScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<PluginScript> =
    LinkedHashSet(pluginScripts[injectionTime]!!)

  fun getPluginScriptsRequiredInAllContentWorlds(): LinkedHashSet<PluginScript> {
    val pluginScriptsRequired = LinkedHashSet<PluginScript>()
    for (script in getPluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START)) {
      if (script.isRequiredInAllContentWorlds) {
        pluginScriptsRequired.add(script)
      }
    }
    return pluginScriptsRequired
  }

  fun addPluginScript(pluginScript: PluginScript): Boolean {
    contentWorlds.add(pluginScript.contentWorld)
    updateContentWorldsCreatorScript()
    val view = webView
    if (view != null && WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      var source = pluginScript.source
      if (pluginScript.injectionTime == UserScriptInjectionTime.AT_DOCUMENT_END) {
        source = "if (document.readyState === 'complete') { $source} else { " +
          "window.addEventListener('load', function() { $source }); }"
      }
      source = wrapSourceCodeAddChecks(source, pluginScript)

      val scriptHandler = WebViewCompat.addDocumentStartJavaScript(
        view,
        wrapSourceCodeInContentWorld(pluginScript.contentWorld, source),
        pluginScript.allowedOriginRules
      )
      scriptHandlerMap[pluginScript] = scriptHandler
    }
    return pluginScripts[pluginScript.injectionTime]!!.add(pluginScript)
  }

  fun addPluginScripts(pluginScripts: List<PluginScript>) {
    for (pluginScript in pluginScripts) {
      addPluginScript(pluginScript)
    }
  }

  fun removePluginScript(pluginScript: PluginScript): Boolean {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      scriptHandlerMap[pluginScript]?.let {
        it.remove()
        scriptHandlerMap.remove(pluginScript)
      }
      updateContentWorldsCreatorScript()
    }
    return pluginScripts[pluginScript.injectionTime]!!.remove(pluginScript)
  }

  fun removeAllPluginScripts() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      for (injectionTime in UserScriptInjectionTime.entries) {
        for (pluginScript in pluginScripts[injectionTime]!!) {
          scriptHandlerMap[pluginScript]?.let {
            it.remove()
            scriptHandlerMap.remove(pluginScript)
          }
        }
      }
    }
    pluginScripts[UserScriptInjectionTime.AT_DOCUMENT_START]!!.clear()
    pluginScripts[UserScriptInjectionTime.AT_DOCUMENT_END]!!.clear()
  }

  fun getUserOnlyScriptAsList(): LinkedHashSet<UserScript> {
    val result = LinkedHashSet<UserScript>()
    for (list in userOnlyScripts.values) {
      result.addAll(list)
    }
    return result
  }

  fun getPluginScriptAsList(): LinkedHashSet<PluginScript> {
    val result = LinkedHashSet<PluginScript>()
    for (list in pluginScripts.values) {
      result.addAll(list)
    }
    return result
  }

  fun resetContentWorlds() {
    contentWorlds.clear()
    contentWorlds.add(ContentWorld.PAGE)

    for (pluginScript in getPluginScriptAsList()) {
      contentWorlds.add(pluginScript.contentWorld)
    }

    for (userOnlyScript in getUserOnlyScriptAsList()) {
      contentWorlds.add(userOnlyScript.contentWorld)
    }
  }

  fun containsPluginScript(pluginScript: PluginScript): Boolean =
    getPluginScriptAsList().contains(pluginScript)

  fun containsPluginScriptByGroupName(groupName: String?): Boolean {
    for (pluginScript in getPluginScriptAsList()) {
      if (Util.objEquals(groupName, pluginScript.groupName)) {
        return true
      }
    }
    return false
  }

  fun containsUserOnlyScript(userOnlyScript: UserScript): Boolean =
    getUserOnlyScriptAsList().contains(userOnlyScript)

  fun containsUserOnlyScriptByGroupName(groupName: String?): Boolean {
    for (userOnlyScript in getUserOnlyScriptAsList()) {
      if (Util.objEquals(groupName, userOnlyScript.groupName)) {
        return true
      }
    }
    return false
  }

  fun removePluginScriptsByGroupName(groupName: String?) {
    for (pluginScript in getPluginScriptAsList()) {
      if (Util.objEquals(groupName, pluginScript.groupName)) {
        removePluginScript(pluginScript)
      }
    }
  }

  fun removeUserOnlyScriptsByGroupName(groupName: String?) {
    for (userOnlyScript in getUserOnlyScriptAsList()) {
      if (Util.objEquals(groupName, userOnlyScript.groupName)) {
        removeUserOnlyScript(userOnlyScript)
      }
    }
  }

  fun getContentWorlds(): LinkedHashSet<ContentWorld> = LinkedHashSet(contentWorlds)

  override fun dispose() {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      contentWorldsCreatorScript?.remove()
    }
    removeAllUserOnlyScripts()
    removeAllPluginScripts()
    webView = null
  }

  companion object {
    protected const val LOG_TAG = "UserContentController"

    @JvmStatic
    fun escapeCode(code: String): String = JSONObject.quote(code)

    @JvmStatic
    fun escapeContentWorldName(name: String): String = name.replace("'", "\\'")

    private fun wrapSourceCodeAddChecks(source: String, userScript: UserScript): String {
      val ifStatement = StringBuilder("if (")
      val allowedOriginRules = userScript.allowedOriginRules
      val forMainFrameOnly = userScript.isForMainFrameOnly
      if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT) &&
        !allowedOriginRules.contains("*")
      ) {
        if (allowedOriginRules.isEmpty()) {
          // return empty source string if allowedOriginRules is an empty list.
          // an empty list means that this UserScript is not allowed for any origin.
          return ""
        }
        val jsRegExpArray = StringBuilder("[")
        for (allowedOriginRule in allowedOriginRules) {
          if (jsRegExpArray.length > 1) {
            jsRegExpArray.append(", ")
          }
          jsRegExpArray.append("new RegExp(").append(escapeCode(allowedOriginRule)).append(")")
        }
        if (jsRegExpArray.length > 1) {
          jsRegExpArray.append("]")
          ifStatement.append(jsRegExpArray)
            .append(".some(function(rx) { return rx.test(window.location.origin); })")
        }
      }
      if (forMainFrameOnly) {
        if (ifStatement.length > 4) {
          ifStatement.append(" && ")
        }
        ifStatement.append("window === window.top")
      }
      return if (ifStatement.length > 4) {
        ifStatement.append(") {").append(source).append("}").toString()
      } else {
        source
      }
    }

    private fun USER_SCRIPTS_AT_DOCUMENT_START_WRAPPER_JS_SOURCE(): String =
      "if (window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentStartLoaded == null || !window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentStartLoaded) {" +
        "  window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentStartLoaded = true;" +
        "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
        "}"

    private fun USER_SCRIPTS_AT_DOCUMENT_END_WRAPPER_JS_SOURCE(): String =
      "if (window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentEndLoaded == null || !window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentEndLoaded) {" +
        "  window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_userScriptsAtDocumentEndLoaded = true;" +
        "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
        "}"

    private fun CONTENT_WORLDS_GENERATOR_JS_SOURCE(): String =
      "(function() {" +
        "  var interval = setInterval(function() {" +
        "    if (document.body == null) {return;}" +
        "    var contentWorldNames = [" + PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY + "];" +
        "    for (var contentWorldName of contentWorldNames) {" +
        "      var iframeId = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_' + contentWorldName;" +
        "      var iframe = document.getElementById(iframeId);" +
        "      if (iframe == null) {" +
        "        iframe = document.createElement('iframe');" +
        "        iframe.id = iframeId;" +
        "        iframe.style = 'display: none; z-index: 0; position: absolute; width: 0px; height: 0px';" +
        "        document.body.append(iframe);" +
        "      }" +
        "      if (iframe.contentWindow.document.getElementById('" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_plugin_scripts') == null) {" +
        "        var script = iframe.contentWindow.document.createElement('script');" +
        "        script.id = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_plugin_scripts';" +
        "        script.innerHTML = " + PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED + ";" +
        "        iframe.contentWindow.document.body.append(script);" +
        "      }" +
        "    }" +
        "    clearInterval(interval);" +
        "  });" +
        "})();"

    private fun CONTENT_WORLD_WRAPPER_JS_SOURCE(): String =
      "(function() {" +
        "  var interval = setInterval(function() {" +
        "    if (document.body == null) {return;}" +
        "    var iframeId = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_" + PluginScriptsUtil.VAR_CONTENT_WORLD_NAME + "';" +
        "    var iframe = document.getElementById(iframeId);" +
        "    if (iframe == null) {" +
        "      iframe = document.createElement('iframe');" +
        "      iframe.id = iframeId;" +
        "      iframe.style = 'display: none; z-index: 0; position: absolute; width: 0px; height: 0px';" +
        "      document.body.append(iframe);" +
        "    }" +
        "    if (iframe.contentWindow.document.querySelector('#" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "_plugin_scripts') == null) {" +
        "      return;" +
        "    }" +
        "    var script = iframe.contentWindow.document.createElement('script');" +
        "    script.innerHTML = " + PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED + ";" +
        "    iframe.contentWindow.document.body.append(script);" +
        "    clearInterval(interval);" +
        "  });" +
        "})();"

    private val DOCUMENT_READY_WRAPPER_JS_SOURCE: String =
      "if (document.readyState === 'interactive' || document.readyState === 'complete') { " +
        "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
        "}"
  }
}
