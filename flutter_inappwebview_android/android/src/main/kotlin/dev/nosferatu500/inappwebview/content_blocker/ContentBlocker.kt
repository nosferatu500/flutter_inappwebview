package dev.nosferatu500.inappwebview.content_blocker

class ContentBlocker(
  var trigger: ContentBlockerTrigger,
  var action: ContentBlockerAction
) {

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as ContentBlocker
    if (trigger != other.trigger) return false
    return action == other.action
  }

  override fun hashCode(): Int {
    var result = trigger.hashCode()
    result = 31 * result + action.hashCode()
    return result
  }

  override fun toString(): String = "ContentBlocker{trigger=$trigger, action=$action}"
}
