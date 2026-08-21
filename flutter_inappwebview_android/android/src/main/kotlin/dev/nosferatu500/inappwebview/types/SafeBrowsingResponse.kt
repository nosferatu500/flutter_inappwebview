package dev.nosferatu500.inappwebview.types

class SafeBrowsingResponse(var isReport: Boolean, var action: Int?) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as SafeBrowsingResponse
    if (isReport != other.isReport) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = if (isReport) 1 else 0
    result = 31 * result + (action?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String = "SafeBrowsingResponse{report=$isReport, action=$action}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): SafeBrowsingResponse? {
      if (map == null) {
        return null
      }
      val report = map["report"] as Boolean
      val action = map["action"] as Int?
      return SafeBrowsingResponse(report, action)
    }
  }
}
