package dev.nosferatu500.inappwebview.types

import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewFeature
import dev.nosferatu500.inappwebview.pigeons.WebMessageData
import java.util.Objects

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class WebMessageCompatExt(
  var data: Any?,
  @get:WebMessageCompat.Type var type: Int,
  var ports: List<WebMessagePortCompatExt>?
) {

  /**
   * Converts to the Pigeon transport type for the two web-message channels (§165).
   *
   * The polymorphic [data] is split by [type] into the two typed fields the schema declares, which
   * is what lets the bytes cross as a real `ByteArray` instead of an `Any?` that happens to be
   * one. [ports] is deliberately not carried: the map this replaces omitted it too, because an
   * event coming *from* the platform never has ports to report.
   */
  fun toPigeon(): WebMessageData = WebMessageData(
    type = type.toLong(),
    stringData = if (type == WebMessageCompat.TYPE_ARRAY_BUFFER) null else data as? String,
    arrayBufferData = if (type == WebMessageCompat.TYPE_ARRAY_BUFFER) data as? ByteArray else null
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as WebMessageCompatExt
    if (type != other.type) return false
    if (data != other.data) return false
    return ports == other.ports
  }

  override fun hashCode(): Int {
    var result = data?.hashCode() ?: 0
    result = 31 * result + type
    result = 31 * result + (ports?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "WebMessageCompatExt{data=$data, type=$type, ports=$ports}"

  companion object {
    @JvmStatic
    fun fromMapWebMessageCompat(message: WebMessageCompat): WebMessageCompatExt {
      val data = if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
        message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
      ) {
        message.arrayBuffer
      } else {
        message.data
      }
      return WebMessageCompatExt(data, message.type, null)
    }

    /**
     * Builds from the Pigeon transport type (§165).
     *
     * The schema's two typed payload fields collapse back into the single `Any?` that
     * `WebMessageCompat` is constructed from; [WebMessageData.type] decides which one is read, so
     * a `STRING` message with null data stays distinguishable from an `ARRAY_BUFFER` one.
     */
    @JvmStatic
    fun fromPigeon(message: WebMessageData): WebMessageCompatExt {
      val type = message.type.toInt()
      val data: Any? = if (type == WebMessageCompat.TYPE_ARRAY_BUFFER) {
        message.arrayBufferData
      } else {
        message.stringData
      }
      return WebMessageCompatExt(
        data,
        type,
        message.ports?.map { WebMessagePortCompatExt(it.index.toInt(), it.webMessageChannelId) }
      )
    }

    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): WebMessageCompatExt? {
      if (map == null) {
        return null
      }
      val data = map["data"]
      val type = map["type"] as Int
      val portMapList = map["ports"] as List<Map<String, Any?>>?
      var ports: MutableList<WebMessagePortCompatExt>? = null
      if (!portMapList.isNullOrEmpty()) {
        ports = mutableListOf()
        for (portMap in portMapList) {
          WebMessagePortCompatExt.fromMap(portMap)?.let { ports.add(it) }
        }
      }
      return WebMessageCompatExt(data, type, ports)
    }
  }
}
