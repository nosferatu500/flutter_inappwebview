package dev.nosferatu500.inappwebview.types

class WebMessage(
  @JvmField var data: String?,
  @JvmField var ports: MutableList<WebMessagePort>?
) {
  fun dispose() {
    ports?.clear()
  }
}
