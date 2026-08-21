package dev.nosferatu500.inappwebview.in_app_browser

import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.InAppBrowserMenuItem
import io.flutter.plugin.common.MethodChannel

class InAppBrowserChannelDelegate(channel: MethodChannel) : ChannelDelegateImpl(channel) {

  fun onBrowserCreated() {
    val channel = this.channel ?: return
    channel.invokeMethod("onBrowserCreated", hashMapOf<String, Any?>())
  }

  fun onMenuItemClicked(menuItem: InAppBrowserMenuItem) {
    val channel = this.channel ?: return
    channel.invokeMethod("onMenuItemClicked", hashMapOf<String, Any?>("id" to menuItem.id))
  }

  fun onExit() {
    val channel = this.channel ?: return
    channel.invokeMethod("onExit", hashMapOf<String, Any?>())
  }
}
