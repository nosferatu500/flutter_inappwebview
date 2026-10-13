package dev.nosferatu500.inappwebview.webview

import dev.nosferatu500.inappwebview.ISettings

class ContextMenuSettings : ISettings<Any> {

  @JvmField
  var hideDefaultSystemContextMenuItems: Boolean = false

  override fun parse(settings: Map<String, Any?>): ContextMenuSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "hideDefaultSystemContextMenuItems" -> hideDefaultSystemContextMenuItems = value as Boolean
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "hideDefaultSystemContextMenuItems" to hideDefaultSystemContextMenuItems
  )

  override fun getRealSettings(obj: Any): MutableMap<String, Any?> = toMap()

  companion object {
    const val LOG_TAG = "ContextMenuOptions"
  }
}
