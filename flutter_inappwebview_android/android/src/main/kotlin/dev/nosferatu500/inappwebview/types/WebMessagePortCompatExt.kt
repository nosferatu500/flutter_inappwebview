package dev.nosferatu500.inappwebview.types

class WebMessagePortCompatExt(var index: Int, var webMessageChannelId: String) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "index" to index,
    "webMessageChannelId" to webMessageChannelId
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebMessagePortCompatExt
    if (index != other.index) return false
    return webMessageChannelId == other.webMessageChannelId
  }

  override fun hashCode(): Int {
    var result = index
    result = 31 * result + webMessageChannelId.hashCode()
    return result
  }

  override fun toString(): String =
    "WebMessagePortCompatExt{index=$index, webMessageChannelId='$webMessageChannelId'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): WebMessagePortCompatExt? {
      if (map == null) {
        return null
      }
      val index = map["index"] as Int
      val webMessageChannelId = map["webMessageChannelId"] as String
      return WebMessagePortCompatExt(index, webMessageChannelId)
    }
  }
}
