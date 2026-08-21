package dev.nosferatu500.inappwebview.types

import io.flutter.plugin.common.MethodChannel

interface IChannelDelegate : MethodChannel.MethodCallHandler, Disposable {
  val channel: MethodChannel?
}
