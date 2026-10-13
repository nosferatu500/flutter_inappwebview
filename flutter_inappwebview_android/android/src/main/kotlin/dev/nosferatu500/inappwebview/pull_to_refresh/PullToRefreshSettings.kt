package dev.nosferatu500.inappwebview.pull_to_refresh

import dev.nosferatu500.inappwebview.ISettings

class PullToRefreshSettings : ISettings<PullToRefreshLayout> {

  @JvmField var enabled: Boolean = true
  @JvmField var color: String? = null
  @JvmField var backgroundColor: String? = null
  @JvmField var distanceToTriggerSync: Int? = null
  @JvmField var slingshotDistance: Int? = null
  @JvmField var size: Int? = null

  override fun parse(settings: Map<String, Any?>): PullToRefreshSettings {
    for ((key, value) in settings) {
      if (value == null) {
        continue
      }
      when (key) {
        "enabled" -> enabled = value as Boolean
        "color" -> color = value as String
        "backgroundColor" -> backgroundColor = value as String
        "distanceToTriggerSync" -> distanceToTriggerSync = value as Int
        "slingshotDistance" -> slingshotDistance = value as Int
        "size" -> size = value as Int
      }
    }
    return this
  }

  override fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "enabled" to enabled,
    "color" to color,
    "backgroundColor" to backgroundColor,
    "distanceToTriggerSync" to distanceToTriggerSync,
    "slingshotDistance" to slingshotDistance,
    "size" to size
  )

  override fun getRealSettings(obj: PullToRefreshLayout): MutableMap<String, Any?> = toMap()

  companion object {
    const val LOG_TAG = "PullToRefreshSettings"
  }
}
