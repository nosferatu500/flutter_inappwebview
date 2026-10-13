package dev.nosferatu500.inappwebview.webview

import io.flutter.plugin.platform.PlatformView

interface PlatformWebView : PlatformView {
  fun makeInitialLoad(params: HashMap<String, Any?>)
}
