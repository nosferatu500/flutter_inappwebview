package dev.nosferatu500.inappwebview.find_interaction

import dev.nosferatu500.inappwebview.ISettings

class FindInteractionSettings : ISettings<FindInteractionController> {

  override fun parse(settings: Map<String, Any?>): FindInteractionSettings = this

  override fun toMap(): MutableMap<String, Any?> = hashMapOf()

  override fun getRealSettings(obj: FindInteractionController): MutableMap<String, Any?> = toMap()

  companion object {
    const val LOG_TAG = "FindInteractionSettings"
  }
}
