package dev.nosferatu500.inappwebview.types

// The unchecked cast below is the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode.
@Suppress("UNCHECKED_CAST")
class PermissionResponse(var resources: List<String>, var action: Int?) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as PermissionResponse
    if (resources != other.resources) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = resources.hashCode()
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "PermissionResponse{resources=$resources, action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): PermissionResponse? {
      if (map == null) {
        return null
      }
      val resources = map["resources"] as List<String>
      val action = map["action"] as Int?
      return PermissionResponse(resources, action)
    }
  }
}
