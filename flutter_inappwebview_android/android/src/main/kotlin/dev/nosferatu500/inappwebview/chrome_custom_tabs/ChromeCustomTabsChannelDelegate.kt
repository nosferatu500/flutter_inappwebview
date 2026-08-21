package dev.nosferatu500.inappwebview.chrome_custom_tabs

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsService
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import dev.nosferatu500.inappwebview.types.CustomTabsSecondaryToolbar
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// The unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. A wrong shape throws ClassCastException at the cast site, which is the intended
// failure mode. Suppressed at class level because the whole class is that boundary.
@Suppress("UNCHECKED_CAST")
class ChromeCustomTabsChannelDelegate(
  chromeCustomTabsActivity: ChromeCustomTabsActivity,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {

  private var chromeCustomTabsActivity: ChromeCustomTabsActivity? = chromeCustomTabsActivity

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val activity = chromeCustomTabsActivity
    val session = activity?.customTabsSession

    when (call.method) {
      "launchUrl" -> {
        val url = call.argument<String>("url")
        if (activity != null && url != null) {
          activity.launchUrl(
            url,
            call.argument<Map<String, String>>("headers"),
            call.argument("referrer"),
            call.argument<List<String>>("otherLikelyURLs")
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "mayLaunchUrl" -> {
        if (activity != null) {
          result.success(
            activity.mayLaunchUrl(
              call.argument("url"), call.argument<List<String>>("otherLikelyURLs")
            )
          )
        } else {
          result.success(false)
        }
      }

      "updateActionButton" -> {
        if (activity != null) {
          activity.updateActionButton(
            call.argument<ByteArray>("icon")!!, call.argument<String>("description")!!
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "validateRelationship" -> {
        if (session != null) {
          val relation = call.argument<Int>("relation")!!
          val origin = call.argument<String>("origin")
          result.success(session.validateRelationship(relation, Uri.parse(origin), null))
        } else {
          result.success(false)
        }
      }

      "updateSecondaryToolbar" -> {
        if (activity != null) {
          activity.updateSecondaryToolbar(
            CustomTabsSecondaryToolbar.fromMap(
              call.argument<Map<String, Any?>>("secondaryToolbar")
            )
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "requestPostMessageChannel" -> {
        if (session != null) {
          val sourceOrigin = call.argument<String>("sourceOrigin")
          val targetOrigin = call.argument<String>("targetOrigin")
          result.success(
            session.requestPostMessageChannel(
              Uri.parse(sourceOrigin),
              targetOrigin?.let { Uri.parse(it) },
              Bundle()
            )
          )
        } else {
          result.success(false)
        }
      }

      "postMessage" -> {
        if (session != null) {
          result.success(session.postMessage(call.argument("message")!!, Bundle()))
        } else {
          result.success(CustomTabsService.RESULT_FAILURE_MESSAGING_ERROR)
        }
      }

      "isEngagementSignalsApiAvailable" -> {
        if (session != null) {
          try {
            result.success(session.isEngagementSignalsApiAvailable(Bundle()))
          } catch (e: Throwable) {
            result.success(false)
          }
        } else {
          result.success(false)
        }
      }

      "close" -> {
        if (activity != null) {
          activity.onStop()
          activity.onDestroy()
          activity.close()

          val hostActivity = activity.manager?.plugin?.activity
          if (hostActivity != null) {
            // https://stackoverflow.com/a/41596629/4637638
            val myIntent = Intent(hostActivity, hostActivity.javaClass)
            myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            myIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            hostActivity.startActivity(myIntent)
          }
          activity.dispose()
          result.success(true)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  fun onServiceConnected() {
    channel?.invokeMethod("onServiceConnected", hashMapOf<String, Any?>())
  }

  fun onOpened() {
    channel?.invokeMethod("onOpened", hashMapOf<String, Any?>())
  }

  fun onCompletedInitialLoad() {
    channel?.invokeMethod("onCompletedInitialLoad", hashMapOf<String, Any?>())
  }

  fun onNavigationEvent(navigationEvent: Int) {
    channel?.invokeMethod(
      "onNavigationEvent", hashMapOf<String, Any?>("navigationEvent" to navigationEvent)
    )
  }

  fun onClosed() {
    channel?.invokeMethod("onClosed", hashMapOf<String, Any?>())
  }

  fun onItemActionPerform(id: Int, url: String?, title: String?) {
    channel?.invokeMethod(
      "onItemActionPerform",
      hashMapOf<String, Any?>("id" to id, "url" to url, "title" to title)
    )
  }

  fun onSecondaryItemActionPerform(name: String?, url: String?) {
    channel?.invokeMethod(
      "onSecondaryItemActionPerform", hashMapOf<String, Any?>("name" to name, "url" to url)
    )
  }

  fun onRelationshipValidationResult(relation: Int, requestedOrigin: Uri, result: Boolean) {
    channel?.invokeMethod(
      "onRelationshipValidationResult",
      hashMapOf<String, Any?>(
        "relation" to relation,
        "requestedOrigin" to requestedOrigin.toString(),
        "result" to result
      )
    )
  }

  fun onMessageChannelReady() {
    channel?.invokeMethod("onMessageChannelReady", hashMapOf<String, Any?>())
  }

  fun onPostMessage(message: String) {
    channel?.invokeMethod("onPostMessage", hashMapOf<String, Any?>("message" to message))
  }

  fun onVerticalScrollEvent(isDirectionUp: Boolean) {
    channel?.invokeMethod(
      "onVerticalScrollEvent", hashMapOf<String, Any?>("isDirectionUp" to isDirectionUp)
    )
  }

  fun onGreatestScrollPercentageIncreased(scrollPercentage: Int) {
    channel?.invokeMethod(
      "onGreatestScrollPercentageIncreased",
      hashMapOf<String, Any?>("scrollPercentage" to scrollPercentage)
    )
  }

  fun onSessionEnded(didUserInteract: Boolean) {
    channel?.invokeMethod(
      "onSessionEnded", hashMapOf<String, Any?>("didUserInteract" to didUserInteract)
    )
  }

  override fun dispose() {
    super.dispose()
    chromeCustomTabsActivity = null
  }
}
