package dev.nosferatu500.inappwebview.find_interaction

import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.FindSession
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FindInteractionChannelDelegate(
  findInteractionController: FindInteractionController,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var findInteractionController: FindInteractionController? = findInteractionController

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val controller = findInteractionController
    when (call.method) {
      "findAll" -> {
        controller?.findAll(call.argument("find"))
        result.success(true)
      }

      "findNext" -> {
        controller?.findNext(call.argument<Boolean>("forward")!!)
        result.success(true)
      }

      "clearMatches" -> {
        controller?.clearMatches()
        result.success(true)
      }

      "setSearchText" -> {
        if (controller != null) {
          controller.searchText = call.argument("searchText")
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "getSearchText" -> {
        if (controller != null) {
          result.success(controller.searchText)
        } else {
          result.success(false)
        }
      }

      "getActiveFindSession" -> result.success(controller?.activeFindSession?.toMap())

      else -> result.notImplemented()
    }
  }

  fun onFindResultReceived(
    activeMatchOrdinal: Int,
    numberOfMatches: Int,
    isDoneCounting: Boolean
  ) {
    val channel = this.channel ?: return

    val controller = findInteractionController
    if (isDoneCounting && controller?.webView != null) {
      controller.activeFindSession = FindSession(numberOfMatches, activeMatchOrdinal)
    }

    channel.invokeMethod(
      "onFindResultReceived",
      hashMapOf<String, Any?>(
        "activeMatchOrdinal" to activeMatchOrdinal,
        "numberOfMatches" to numberOfMatches,
        "isDoneCounting" to isDoneCounting
      )
    )
  }

  override fun dispose() {
    super.dispose()
    findInteractionController = null
  }
}
