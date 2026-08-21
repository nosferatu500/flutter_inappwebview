package dev.nosferatu500.inappwebview.types

import androidx.annotation.CallSuper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The constructor publishes `this` before construction completes. Safe here: everything it is
// published to (the MethodChannel handler, the activity-result listener list, the static manager
// registries) is only ever reached from the platform/main-thread message loop, and these objects
// are also constructed on that thread -- so no callback can interleave with the constructor.
// Restructuring to a two-phase init would change the lifecycle of 12 classes for no real-world gain.
open class ChannelDelegateImpl(channel: MethodChannel) : IChannelDelegate {
  final override var channel: MethodChannel? = channel
    private set

  init {
    channel.setMethodCallHandler(this)
  }

  @CallSuper
  override fun dispose() {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
  }
}
